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

@interface MCSVODNetworkDataReader ()<MCSDownloadTaskDelegate> {
    dispatch_semaphore_t _semaphore;
}
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
@synthesize delegateQueue = _delegateQueue;
@synthesize isPrepared = _isPrepared;

- (instancetype)initWithResource:(__weak MCSVODResource *)resource request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<MCSResourceDataReaderDelegate>)delegate delegateQueue:(dispatch_queue_t)queue {
    self = [super init];
    if ( self ) {
        _resource = resource;
        _request = request;
        _range = request.mcs_range;
        _networkTaskPriority = networkTaskPriority;
        _delegate = delegate;
        _delegateQueue = queue;
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"MCSVODNetworkDataReader:<%p> { URL: %@, headers: %@, range: %@\n};", self, _request.URL, _request.mcs_headers, NSStringFromRange(_range)];
}

- (void)prepare {
    [self lock];
    @try {
        if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSLog(@"%@: <%p>.prepare { range: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_range));
        
        _isCalledPrepare = YES;
        
        _task = [MCSDownload.shared downloadWithRequest:[_request mcs_requestWithHTTPAdditionalHeaders:[_resource.configuration HTTPAdditionalHeadersForDataRequestsOfType:MCSDataTypeVOD]] priority:_networkTaskPriority delegate:self];
    } @catch (__unused NSException *exception) {

    } @finally {
        [self unlock];
    }
}

- (nullable NSData *)readDataOfLength:(NSUInteger)lengthParam {
    [self lock];
    @try {
        if ( _isClosed || _isDone || !_isPrepared )
            return nil;
        
        if ( _isSought ) {
            _isSought = NO;
            NSError *error = nil;
            if ( ![_reader mcs_seekToFileOffset:_readLength error:&error] ) {
                [self _onError:error];
                return nil;
            }
        }

        NSData *data = [_reader readDataOfLength:lengthParam];
        NSUInteger readLength = data.length;
        if ( readLength == 0 )
            return nil;
        
        _readLength += readLength;
        _isDone = _readLength == _range.length;
        
#ifdef DEBUG
        MCSLog(@"%@: <%p>.read { offset: %lu, length: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)(_range.location + _readLength), (unsigned long)readLength);
        if ( _isDone ) {
            MCSLog(@"%@: <%p>.done { range: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_range));
        }
#endif
        return data;
    } @catch (NSException *exception) {
        [self _onError:[NSError mcs_exception:exception]];
    }
    @finally {
        [self unlock];
    }
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    [self lock];
    @try {
        if ( _isClosed || !_isPrepared )
            return NO;
    
        NSRange range = NSMakeRange(_range.location, _availableLength);
        if ( !NSLocationInRange(offset - 1, range) )
            return NO;
        
        // offset   = range.location + readLength;
        NSUInteger readLength = offset - range.location;
        if ( readLength != _readLength ) {
            _isSought = YES;
            _readLength = readLength;
            _isDone = _readLength == _range.length;
        }
        return YES;
    } @catch (NSException *exception) {
        [self _onError:[NSError mcs_exception:exception]];
    } @finally {
        [self unlock];
    }
}

- (void)close {
    [self lock];
    [self _close];
    [self unlock];
}

#pragma mark -

- (NSUInteger)offset {
    [self lock];
    @try {
        return _range.location + _readLength;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (BOOL)isPrepared {
    [self lock];
    @try {
        return _isPrepared;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (BOOL)isDone {
    [self lock];
    @try {
        return _isDone;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

#pragma mark - MCSDownloadTaskDelegate

- (void)downloadTask:(NSURLSessionTask *)task didReceiveResponse:(NSHTTPURLResponse *)response {
    [self lock];
    @try {
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
        
        dispatch_async(_delegateQueue, ^{
            [self.delegate readerPrepareDidFinish:self];
        });
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)downloadTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data {
    [self lock];
    @try {
        if ( _isClosed )
            return;

        [_writer writeData:data];
        NSUInteger length = data.length;
        _availableLength += length;
        [_content didWriteDataWithLength:length];
     
        dispatch_async(_delegateQueue, ^{
            [self.delegate reader:self hasAvailableDataWithLength:length];
        });
    } @catch (NSException *exception) {
        [self _onError:[NSError mcs_exception:exception]];
    } @finally {
           [self unlock];
    }
}

- (void)downloadTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [self lock];
    @try {
        if ( _isClosed )
            return;
        
        if ( error != nil && error.code != NSURLErrorCancelled ) {
            [self _onError:error];
        }
        //    else {
        //        // finished download
        //    }
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

#pragma mark -

- (void)_onError:(NSError *)error {
    [self _close];
    
    dispatch_async(_delegateQueue, ^{
        [self.delegate reader:self anErrorOccurred:error];
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

#pragma mark -

- (void)lock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_semaphore);
}
@end
