//
//  MCSVODNetworkDataReader.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSVODNetworkDataReader.h"
#import "MCSError.h"
#import "MCSDownload.h"
#import "MCSResourceResponse.h"
#import "MCSResourcePartialContent.h"
#import "MCSLogger.h"
#import "MCSVODResource.h"
#import "MCSUtils.h"
#import "NSFileHandle+MCS.h"
#import "MCSQueue.h"

@interface MCSVODNetworkDataReader ()<MCSDownloadTaskDelegate>
@property (nonatomic, weak, nullable) MCSVODResource *resource;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic) NSRange range;

@property (nonatomic, strong, nullable) NSURLSessionTask *task;
@property (nonatomic, strong, nullable) NSHTTPURLResponse *response;

@property (nonatomic, strong, nullable) NSFileHandle *reader;
@property (nonatomic, strong, nullable) NSFileHandle *writer;

@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isDone;
@property (nonatomic) BOOL isSought;

@property (nonatomic, strong, nullable) MCSResourcePartialContent *content;
@property (nonatomic) NSUInteger availableLength;
@property (nonatomic) NSUInteger readLength;

@property (nonatomic) float networkTaskPriority;
@end

@implementation MCSVODNetworkDataReader
@synthesize delegate = _delegate;
@synthesize isPrepared = _isPrepared;

- (instancetype)initWithResource:(__weak MCSVODResource *)resource request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<MCSResourceDataReaderDelegate>)delegate {
    self = [super init];
    if ( self ) {
        _resource = resource;
        _request = request;
        _range = request.mcs_range;
        _networkTaskPriority = networkTaskPriority;
        _delegate = delegate;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"MCSVODNetworkDataReader:<%p> { URL: %@, headers: %@, range: %@\n};", self, _request.URL, _request.mcs_headers, NSStringFromRange(_range)];
}

- (void)prepare {
    dispatch_barrier_sync(MCSVODNetworkDataReaderQueue(), ^{
        if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSLog(@"%@: <%p>.prepare { range: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_range));
        
        _isCalledPrepare = YES;
        
        _task = [MCSDownload.shared downloadWithRequest:[_request mcs_requestWithHTTPAdditionalHeaders:[_resource.configuration HTTPAdditionalHeadersForDataRequestsOfType:MCSDataTypeVOD]] priority:_networkTaskPriority delegate:self];
    });
}

- (nullable NSData *)readDataOfLength:(NSUInteger)lengthParam {
    __block NSData *data = nil;
    dispatch_barrier_sync(MCSVODNetworkDataReaderQueue(), ^{
        @try {
            if ( _isClosed || _isDone || !_isPrepared )
                return;
            
            if ( _isSought ) {
                _isSought = NO;
                NSError *error = nil;
                if ( ![_reader mcs_seekToFileOffset:_readLength error:&error] ) {
                    [self _onError:error];
                    return;
                }
            }
            
            data = [_reader readDataOfLength:lengthParam];
            NSUInteger readLength = data.length;
            if ( readLength == 0 )
                return;
            
            _readLength += readLength;
            _isDone = (_readLength == _range.length);
            
#ifdef DEBUG
            MCSLog(@"%@: <%p>.read { offset: %lu, length: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)(_range.location + _readLength), (unsigned long)readLength);
            if ( _isDone ) {
                MCSLog(@"%@: <%p>.done { range: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_range));
            }
#endif
        } @catch (NSException *exception) {
            [self _onError:[NSError mcs_exception:exception]];
        }
    });
    return data;
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    __block BOOL result = NO;
    dispatch_barrier_sync(MCSVODNetworkDataReaderQueue(), ^{
        if ( _isClosed || !_isPrepared )
            return;
        
        NSRange range = NSMakeRange(_range.location, _availableLength);
        if ( !NSLocationInRange(offset - 1, range) )
            return;
        
        // offset   = range.location + readLength;
        NSUInteger readLength = offset - range.location;
        if ( readLength != _readLength ) {
            _isSought = YES;
            _readLength = readLength;
            _isDone = (_readLength == _range.length);
        }
        result = YES;
    });
    return result;
}

- (void)close {
    dispatch_barrier_sync(MCSVODNetworkDataReaderQueue(), ^{
        [self _close];
    });
}

#pragma mark -

- (NSUInteger)offset {
    __block NSUInteger offset = 0;
    dispatch_sync(MCSVODNetworkDataReaderQueue(), ^{
        offset = _range.location + _readLength;
    });
    return offset;
}

- (BOOL)isPrepared {
    __block BOOL isPrepared = NO;
    dispatch_sync(MCSVODNetworkDataReaderQueue(), ^{
        isPrepared = _isPrepared;
    });
    return isPrepared;
}

- (BOOL)isDone {
    __block BOOL isDone = NO;
    dispatch_sync(MCSVODNetworkDataReaderQueue(), ^{
        isDone = _isDone;
    });
    return isDone;
}

#pragma mark - MCSDownloadTaskDelegate

- (void)downloadTask:(NSURLSessionTask *)task didReceiveResponse:(NSHTTPURLResponse *)response {
    dispatch_barrier_sync(MCSVODNetworkDataReaderQueue(), ^{
        if ( _isClosed )
            return;
        _response = response;
        _content = [_resource createContentWithOffset:_range.location];
        NSString *filePath = [_resource filePathOfContent:_content];
        _reader = [NSFileHandle fileHandleForReadingAtPath:filePath];
        _writer = [NSFileHandle fileHandleForWritingAtPath:filePath];
        
        if ( _reader == nil || _writer == nil ) {
            [self _onError:[NSError mcs_fileNotExistError:_request.URL]];
            return;
        }
        
        _isPrepared = YES;
        
        dispatch_async(MCSDelegateQueue(), ^{
            [self->_delegate readerPrepareDidFinish:self];
        });
    });
}

- (void)downloadTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data {
    dispatch_barrier_sync(MCSVODNetworkDataReaderQueue(), ^{
        @try {
            if ( _isClosed )
                return;
            
            if ( _resource == nil ) {
                [self _close];
                return;
            }
            
            [_writer writeData:data];
            NSUInteger length = data.length;
            _availableLength += length;
            [_content didWriteDataWithLength:length];
            
            dispatch_async(MCSDelegateQueue(), ^{
                [self->_delegate reader:self hasAvailableDataWithLength:length];
            });
        } @catch (NSException *exception) {
            [self _onError:[NSError mcs_exception:exception]];
        }
    });
}

- (void)downloadTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    dispatch_barrier_sync(MCSVODNetworkDataReaderQueue(), ^{
        if ( _isClosed )
            return;
        
        if ( error != nil && error.code != NSURLErrorCancelled ) {
            [self _onError:error];
        }
        //    else {
        //        // finished download
        //    }
    });
}

#pragma mark -

- (void)_onError:(NSError *)error {
    [self _close];
    
    dispatch_async(MCSDelegateQueue(), ^{
        [self->_delegate reader:self anErrorOccurred:error];
    });
}

- (void)_close {
    if ( _isClosed )
        return;
    
    @try {
        if ( _task.state == NSURLSessionTaskStateRunning ) [_task cancel];
        _task = nil;
        [_writer synchronizeFile];
        [_writer closeFile];
        _writer = nil;
        [_reader closeFile];
        _reader = nil;
        _isClosed = YES;
        
        MCSLog(@"%@: <%p>.close;\n", NSStringFromClass(self.class), self);
    } @catch (__unused NSException *exception) {
        
    }
}
@end
