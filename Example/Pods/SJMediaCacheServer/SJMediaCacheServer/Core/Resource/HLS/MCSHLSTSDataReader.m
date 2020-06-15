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
#import "MCSResourceNetworkDataReader.h"
#import "MCSResourceFileDataReader.h"
#import "MCSDownload.h"
#import "MCSUtils.h"
#import "MCSError.h"
#import "MCSFileManager.h"

@interface MCSHLSTSDataReader ()<MCSDownloadTaskDelegate>
@property (nonatomic, weak, nullable) MCSHLSResource *resource;
@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isDone;

@property (nonatomic, strong, nullable) MCSResourcePartialContent *content;
@property (nonatomic) NSUInteger availableLength;
@property (nonatomic) NSUInteger offset;

@property (nonatomic, strong, nullable) NSURLSessionTask *task;
@property (nonatomic, strong, nullable) NSFileHandle *reader;
@property (nonatomic, strong, nullable) NSFileHandle *writer;

@property (nonatomic) float networkTaskPriority;

@property (nonatomic, strong, nullable) NSURL *URL;
@end

@implementation MCSHLSTSDataReader
@synthesize delegate = _delegate;

- (instancetype)initWithResource:(MCSHLSResource *)resource request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority {
    self = [super init];
    if ( self ) {
        _networkTaskPriority = networkTaskPriority;
        _resource = resource;
        _request = request;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { URL: %@\n };", NSStringFromClass(self.class), self, _URL];
}

- (void)prepare {
    if ( _isClosed || _isCalledPrepare )
        return;
    
    NSString *tsName = [_resource tsNameForTsProxyURL:_request.URL];
    _URL = [_resource.parser tsURLWithTsName:tsName];
    
    MCSLog(@"%@: <%p>.prepare { URL: %@ };\n", NSStringFromClass(self.class), self, _URL);

    _isCalledPrepare = YES;
    
    _content = [_resource contentForTsProxyURL:_request.URL];
    if ( _content != nil ) {
        [self _prepare];
    }
    else {
        
        MCSLog(@"%@: <%p>.request { URL: %@ };\n", NSStringFromClass(self.class), self, _URL);

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_URL];
        [_request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
        _task = [MCSDownload.shared downloadWithRequest:request priority:_networkTaskPriority delegate:self];
    }
}

- (NSData *)readDataOfLength:(NSUInteger)lengthParam {
    @try {
        if ( _isClosed || _isDone )
            return nil;
        
        NSData *data = nil;
        
        if ( _offset < _availableLength ) {
            NSUInteger length = MIN(lengthParam, _availableLength - _offset);
            if ( length > 0 ) {
                data = [_reader readDataOfLength:length];
                _offset += data.length;
                _isDone = _offset == _response.totalLength;
                MCSLog(@"%@: <%p>.read { offset: %lu, length: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_offset, (unsigned long)data.length);
#ifdef DEBUG
                if ( _isDone ) {
                    MCSLog(@"%@: <%p>.done { URL: %@ };\n", NSStringFromClass(self.class), self, _URL);
                }
#endif
            }
        }
        
        return data;
    } @catch (NSException *exception) {
        [self _onError:[NSError mcs_errorForException:exception]];
    }
}

- (void)close {
    @try {
        if ( _isClosed )
            return;
        
        _isClosed = YES;
        if ( _task.state == NSURLSessionTaskStateRunning ) [_task cancel];
        _task = nil;
        [_writer synchronizeFile];
        [_writer closeFile];
        _writer = nil;
        [_reader closeFile];
        _reader = nil;
        [_content readWrite_release];
    } @catch (__unused NSException *exception) {
        
    }
    MCSLog(@"%@: <%p>.close;\n", NSStringFromClass(self.class), self);
}

- (void)_prepare {
    [_content readWrite_retain];
    NSString *filepath = [_resource filePathOfContent:_content];
    _availableLength = [MCSFileManager fileSizeAtPath:filepath];
    _reader = [NSFileHandle fileHandleForReadingAtPath:filepath];
    _writer = [NSFileHandle fileHandleForWritingAtPath:filepath];
    _response = [MCSResourceResponse.alloc initWithServer:@"localhost" contentType:_resource.tsContentType totalLength:_content.tsTotalLength];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.delegate readerPrepareDidFinish:self];
    });
}

#pragma mark -

- (void)downloadTask:(NSURLSessionTask *)task didReceiveResponse:(NSHTTPURLResponse *)response {
    if ( _isClosed )
        return;
    
    NSString *contentType = MCSGetResponseContentType(response);
    NSUInteger totalLength = MCSGetResponseContentLength(response);
    [_resource updateTsContentType:contentType];
    _content = [_resource createContentWithTsProxyURL:_request.URL tsTotalLength:totalLength];
    [self _prepare];
}

- (void)downloadTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data {
    @try {
        if ( _isClosed )
            return;
        
        [_writer writeData:data];
        NSUInteger length = data.length;
        _availableLength += length;
        [_content didWriteDataWithLength:length];
        
    } @catch (NSException *exception) {
        [self _onError:[NSError mcs_errorForException:exception]];
        
    }
    
    [_delegate readerHasAvailableData:self];
}

- (void)downloadTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if ( _isClosed )
        return;
    
    if ( error != nil && error.code != NSURLErrorCancelled ) {
        [self _onError:error];
    }
    else {
        // finished download
    }
}

#pragma mark -

- (void)_onError:(NSError *)error {
    [_delegate reader:self anErrorOccurred:error];
}
@end
