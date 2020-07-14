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
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation MCSVODNetworkDataReader
@synthesize delegate = _delegate;
@synthesize isPrepared = _isPrepared;

- (instancetype)initWithResource:(__weak MCSVODResource *)resource request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<MCSResourceDataReaderDelegate>)delegate {
    self = [super init];
    if ( self ) {
        _queue = dispatch_get_global_queue(0, 0);
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
    dispatch_barrier_sync(_queue, ^{
        if ( self->_isClosed || self->_isCalledPrepare )
            return;
        
        MCSLog(@"%@: <%p>.prepare { range: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(self->_range));
        
        self->_isCalledPrepare = YES;
        
        self->_task = [MCSDownload.shared downloadWithRequest:[self->_request mcs_requestWithHTTPAdditionalHeaders:[self->_resource.configuration HTTPAdditionalHeadersForDataRequestsOfType:MCSDataTypeVOD]] priority:self->_networkTaskPriority delegate:self];
    });
}

- (nullable NSData *)readDataOfLength:(NSUInteger)lengthParam {
    __block NSData *data = nil;
    dispatch_barrier_sync(_queue, ^{
        @try {
            if ( self->_isClosed || self->_isDone || !self->_isPrepared )
                return;
            
            if ( self->_isSought ) {
                self->_isSought = NO;
                NSError *error = nil;
                if ( ![self->_reader mcs_seekToFileOffset:self->_readLength error:&error] ) {
                    [self _onError:error];
                    return;
                }
            }
            
            data = [self->_reader readDataOfLength:lengthParam];
            NSUInteger readLength = data.length;
            if ( readLength == 0 )
                return;
            
            self->_readLength += readLength;
            self->_isDone = (self->_readLength == self->_range.length);
            
#ifdef DEBUG
            MCSLog(@"%@: <%p>.read { offset: %lu, length: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)(self->_range.location + self->_readLength), (unsigned long)readLength);
            if ( self->_isDone ) {
                MCSLog(@"%@: <%p>.done { range: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(self->_range));
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
    dispatch_barrier_sync(_queue, ^{
        if ( self->_isClosed || !self->_isPrepared )
            return;
        
        NSRange range = NSMakeRange(self->_range.location, self->_availableLength);
        if ( !NSLocationInRange(offset - 1, range) )
            return;
        
        // offset   = range.location + readLength;
        NSUInteger readLength = offset - range.location;
        if ( readLength != self->_readLength ) {
            self->_isSought = YES;
            self->_readLength = readLength;
            self->_isDone = (self->_readLength == self->_range.length);
        }
        result = YES;
    });
    return result;
}

- (void)close {
    dispatch_barrier_sync(_queue, ^{
        [self _close];
    });
}

#pragma mark -

- (NSUInteger)offset {
    __block NSUInteger offset = 0;
    dispatch_sync(_queue, ^{
        offset = self->_range.location + self->_readLength;
    });
    return offset;
}

- (BOOL)isPrepared {
    __block BOOL isPrepared = NO;
    dispatch_sync(_queue, ^{
        isPrepared = self->_isPrepared;
    });
    return isPrepared;
}

- (BOOL)isDone {
    __block BOOL isDone = NO;
    dispatch_sync(_queue, ^{
        isDone = _isDone;
    });
    return isDone;
}

#pragma mark - MCSDownloadTaskDelegate

- (void)downloadTask:(NSURLSessionTask *)task didReceiveResponse:(NSHTTPURLResponse *)response {
    dispatch_barrier_sync(_queue, ^{
        if ( self->_isClosed )
            return;
        self->_response = response;
        self->_content = [self->_resource createContentWithOffset:self->_range.location];
        NSString *filePath = [self->_resource filePathOfContent:self->_content];
        self->_reader = [NSFileHandle fileHandleForReadingAtPath:filePath];
        self->_writer = [NSFileHandle fileHandleForWritingAtPath:filePath];
        
        if ( self->_reader == nil || self->_writer == nil ) {
            [self _onError:[NSError mcs_fileNotExistError:self->_request.URL]];
            return;
        }
        
        self->_isPrepared = YES;
        
        [self->_delegate readerPrepareDidFinish:self];
    });
}

- (void)downloadTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data {
    dispatch_barrier_sync(_queue, ^{
        @try {
            if ( self->_isClosed )
                return;
            
            [self->_writer writeData:data];
            NSUInteger length = data.length;
            self->_availableLength += length;
            [self->_content didWriteDataWithLength:length];
            [self->_delegate reader:self hasAvailableDataWithLength:length];
        } @catch (NSException *exception) {
            [self _onError:[NSError mcs_exception:exception]];
        }
    });
}

- (void)downloadTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    dispatch_barrier_sync(_queue, ^{
        if ( self->_isClosed )
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
    
    [_delegate reader:self anErrorOccurred:error];
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
