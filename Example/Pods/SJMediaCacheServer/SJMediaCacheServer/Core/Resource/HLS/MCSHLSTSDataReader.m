//
//  MCSHLSTSDataReader.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSHLSTSDataReader.h"
#import "MCSLogger.h"
#import "MCSHLSResource.h"
#import "MCSResourceFileDataReader.h"
#import "MCSDownload.h"
#import "MCSUtils.h"
#import "MCSError.h"
#import "MCSFileManager.h"
#import "MCSResourceResponse.h"
#import "NSFileHandle+MCS.h"

@interface MCSHLSTSDataReader ()<MCSDownloadTaskDelegate, NSLocking> {
    dispatch_semaphore_t _semaphore;
}
@property (nonatomic, weak, nullable) MCSHLSResource *resource;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong, nullable) id<MCSResourceResponse> response;

@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isDone;
@property (nonatomic) BOOL isSought;

@property (nonatomic, strong, nullable) MCSResourcePartialContent *content;
@property (nonatomic) NSUInteger availableLength;
@property (nonatomic) NSUInteger offset;

@property (nonatomic, strong, nullable) NSURLSessionTask *task;
@property (nonatomic, strong, nullable) NSFileHandle *reader;
@property (nonatomic, strong, nullable) NSFileHandle *writer;
@property (nonatomic) float networkTaskPriority;
@end

@implementation MCSHLSTSDataReader
@synthesize delegate = _delegate;
@synthesize delegateQueue = _delegateQueue;
@synthesize range = _range;

- (instancetype)initWithResource:(MCSHLSResource *)resource request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<MCSResourceDataReaderDelegate>)delegate delegateQueue:(dispatch_queue_t)queue {
    self = [super init];
    if ( self ) {
        _networkTaskPriority = networkTaskPriority;
        _resource = resource;
        _request = request;
        _delegate = delegate;
        _delegateQueue = queue;
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { URL: %@\n };", NSStringFromClass(self.class), self, _request.URL];
}

- (void)prepare {
    [self lock];
    @try {
        if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSLog(@"%@: <%p>.prepare { URL: %@ };\n", NSStringFromClass(self.class), self, _request.URL);

        _isCalledPrepare = YES;
        
        _content = [_resource contentForTsURL:_request.URL];
        
        if ( _content != nil ) {
            // go to read the content
            [self _prepare];
            return;
        }
        
        MCSLog(@"%@: <%p>.request { URL: %@ };\n", NSStringFromClass(self.class), self, _request.URL);
        
        // download the content
        _task = [MCSDownload.shared downloadWithRequest:[_request mcs_requestWithHTTPAdditionalHeaders:[_resource.configuration HTTPAdditionalHeadersForDataRequestsOfType:MCSDataTypeHLSTs]] priority:_networkTaskPriority delegate:self];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSData *)readDataOfLength:(NSUInteger)lengthParam {
    [self lock];
    @try {
        if ( _isClosed || _isDone || !_isPrepared )
            return nil;
        
        if ( _isSought ) {
            _isSought = NO;
            NSError *error = nil;
            if ( ![_reader mcs_seekToFileOffset:_offset error:&error] ) {
                [self _onError:error];
                return nil;
            }
        }
        
        NSData *data = nil;
        
        if ( _offset < _availableLength ) {
            NSUInteger length = MIN(lengthParam, _availableLength - _offset);
            if ( length > 0 ) {
                data = [_reader readDataOfLength:length];
                _offset += data.length;
                _isDone = _offset == _response.totalLength;
                MCSLog(@"%@: <%p>.read { offset: %lu, length: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_offset, (unsigned long)data.length);
            }
        }
        
        return data;
    } @catch (NSException *exception) {
        [self _onError:[NSError mcs_exception:exception]];
    } @finally {
#ifdef DEBUG
        if ( _isDone ) {
            MCSLog(@"%@: <%p>.done { URL: %@ };\n", NSStringFromClass(self.class), self, _request.URL);
        }
#endif
        [self unlock];
    }
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    [self lock];
    @try {
        if ( _isClosed || !_isPrepared || offset > _availableLength )
            return NO;
        
        if ( offset != _offset ) {
            _isSought = YES;
            _offset = offset;
            _isDone = _offset == _response.totalLength;
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

- (NSRange)range {
    [self lock];
    @try {
        return _range;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSUInteger)availableLength {
    [self lock];
    @try {
        return _availableLength;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSUInteger)offset {
    [self lock];
    @try {
        return _offset;
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

- (id<MCSResourceResponse>)response {
    [self lock];
    @try {
        return _response;
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
        
        NSString *contentType = MCSGetResponseContentType(response);
        [_resource updateTsContentType:contentType];
        _content = [_resource createContentWithTsURL:_request.URL totalLength:response.expectedContentLength];
        [self _prepare];
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
        else {
            // finished download
        }
        
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

- (void)_prepare {
    [_content readWrite_retain];
    NSString *filePath = [_resource filePathOfContent:_content];
    _availableLength = [MCSFileManager fileSizeAtPath:filePath];
    _range = NSMakeRange(0, _content.tsTotalLength);
    _reader = [NSFileHandle fileHandleForReadingAtPath:filePath];
    _writer = [NSFileHandle fileHandleForWritingAtPath:filePath];
    _response = [MCSResourceResponse.alloc initWithServer:@"localhost" contentType:_resource.TsContentType totalLength:_content.tsTotalLength];
        
    if ( _reader == nil || _writer == nil ) {
        [self _onError:[NSError mcs_fileNotExistError:_request.URL]];
        return;
    }

    _isPrepared = YES;
    dispatch_async(_delegateQueue, ^{
        [self.delegate readerPrepareDidFinish:self];
    });
    
    if ( _availableLength != 0 ) {
        dispatch_async(_delegateQueue, ^{
            [self.delegate reader:self hasAvailableDataWithLength:self.availableLength];
        });
    }
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
        [_content readWrite_release];
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
