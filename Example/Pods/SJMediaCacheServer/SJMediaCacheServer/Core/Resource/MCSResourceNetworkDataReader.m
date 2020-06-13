//
//  MCSResourceNetworkDataReader.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSResourceNetworkDataReader.h"
#import "MCSError.h"
#import "MCSDownload.h"
#import "MCSResourceResponse.h"
#import "MCSResourcePartialContent.h"
#import "MCSLogger.h"

@interface MCSResourceNetworkDataReader ()<MCSDownloadTaskDelegate>
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, copy) NSDictionary *requestHeaders;
@property (nonatomic) NSRange range;

@property (nonatomic, strong, nullable) NSURLSessionTask *task;
@property (nonatomic, strong, nullable) NSHTTPURLResponse *response;

@property (nonatomic, strong, nullable) NSFileHandle *reader;
@property (nonatomic, strong, nullable) NSFileHandle *writer;

@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isDone;

@property (nonatomic, strong, nullable) MCSResourcePartialContent *content;
@property (nonatomic) NSUInteger downloadedLength;
@property (nonatomic) NSUInteger offset;

@property (nonatomic) float networkTaskPriority;
@end

@implementation MCSResourceNetworkDataReader
@synthesize delegate = _delegate;

- (instancetype)initWithURL:(NSURL *)URL requestHeaders:(NSDictionary *)headers range:(NSRange)range  networkTaskPriority:(float)networkTaskPriority {
    self = [super init];
    if ( self ) {
        _URL = URL;
        _requestHeaders = headers.copy;
        _range = range;
        _networkTaskPriority = networkTaskPriority;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"MCSResourceNetworkDataReader:<%p> { URL: %@, headers: %@, range: %@\n};", self, _URL, _requestHeaders, NSStringFromRange(_range)];
}

- (void)prepare {
    if ( _isClosed || _isCalledPrepare )
        return;
    
    MCSLog(@"%@: <%p>.prepare { range: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_range));
    
    _isCalledPrepare = YES;
    NSMutableURLRequest *request = [NSMutableURLRequest.alloc initWithURL:_URL];
    [request setAllHTTPHeaderFields:_requestHeaders];
    //
    //        https://tools.ietf.org/html/rfc7233#section-4.1
    //
    //        Additional examples, assuming a representation of length 10000:
    //
    //        o  The final 500 bytes (byte offsets 9500-9999, inclusive):
    //
    //             bytes=-500
    //
    //        Or:
    //
    //             bytes=9500-
    //
    //        o  The first and last bytes only (bytes 0 and 9999):
    //
    //             bytes=0-0,-1
    //
    //        o  Other valid (but not canonical) specifications of the second 500
    //           bytes (byte offsets 500-999, inclusive):
    //
    //             bytes=500-600,601-999
    //             bytes=500-700,601-999
    //
    [request setValue:[NSString stringWithFormat:@"bytes=%lu-%lu", (unsigned long)_range.location, (unsigned long)NSMaxRange(_range) - 1] forHTTPHeaderField:@"Range"];
    
    _task = [MCSDownload.shared downloadWithRequest:request priority:_networkTaskPriority delegate:self];

}

- (nullable NSData *)readDataOfLength:(NSUInteger)lengthParam {
    @try {
        if ( _isClosed || _isDone )
            return nil;
        
        NSData *data = nil;
        
        if ( _offset < _downloadedLength ) {
            NSUInteger length = MIN(lengthParam, _downloadedLength - _offset);
            if ( length > 0 ) {
                data = [_reader readDataOfLength:length];
                _offset += data.length;
                _isDone = _offset == _range.length;
                
                MCSLog(@"%@: <%p>.read { offset: %lu, length: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_offset, (unsigned long)data.length);
            }
        }
        return data;
    } @catch (NSException *exception) {
        [self _onError:[NSError mcs_errorForException:exception]];
    }
#ifdef DEBUG
    @finally {
        if ( _isDone ) {
            MCSLog(@"%@: <%p>.done { range: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_range));
        }
    }
#endif
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
    } @catch (__unused NSException *exception) {
        
    }
#ifdef DEBUG
    @finally {
        MCSLog(@"%@: <%p>.close;\n", NSStringFromClass(self.class), self);
    }
#endif
}

#pragma mark -

- (void)downloadTask:(NSURLSessionTask *)task didReceiveResponse:(NSHTTPURLResponse *)response {
    if ( _isClosed )
        return;
    _response = response;
    
    id<MCSResourceNetworkDataReaderDelegate> delegate = (id)self.delegate;
    _content = [delegate newPartialContentForReader:self];
    NSString *filePath = [delegate writePathOfPartialContent:_content];
    _reader = [NSFileHandle fileHandleForReadingAtPath:filePath];
    _writer = [NSFileHandle fileHandleForWritingAtPath:filePath];

    if ( _reader == nil || _writer == nil ) {
        [self _onError:[NSError mcs_errorForFileHandleError:_URL]];
        return;
    }
    
    [_delegate readerPrepareDidFinish:self];
}

- (void)downloadTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data {
    @try {
        if ( _isClosed )
            return;

        [_writer writeData:data];
        NSUInteger length = data.length;
        _downloadedLength += length;
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
//    else {
//        // finished download
//    }
}

#pragma mark -

- (void)_onError:(NSError *)error {
    [_delegate reader:self anErrorOccurred:error];
}
@end
