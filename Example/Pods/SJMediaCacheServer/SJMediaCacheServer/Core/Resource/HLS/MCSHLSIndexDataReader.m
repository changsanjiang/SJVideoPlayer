//
//  MCSHLSIndexDataReader.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSHLSIndexDataReader.h"
#import "MCSLogger.h"
#import "MCSResourceFileDataReader.h"
#import "MCSResourceResponse.h"
#import "MCSHLSResource.h"
#import "MCSFileManager.h"

@interface MCSHLSIndexDataReader ()<MCSHLSParserDelegate, MCSResourceDataReaderDelegate, NSLocking> {
    dispatch_semaphore_t _semaphore;
}
@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isClosed;

@property (nonatomic, weak, nullable) MCSHLSResource *resource;
@property (nonatomic, strong, nullable) MCSResourceFileDataReader *reader;
@property (nonatomic, strong, nullable) id<MCSResourceResponse> response;
@property (nonatomic) float networkTaskPriority;
@end

@implementation MCSHLSIndexDataReader
@synthesize delegate = _delegate;
@synthesize delegateQueue = _delegateQueue;
- (instancetype)initWithResource:(MCSHLSResource *)resource request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<MCSResourceDataReaderDelegate>)delegate delegateQueue:(dispatch_queue_t)queue {
    self = [super init];
    if ( self ) {
        _networkTaskPriority = networkTaskPriority;
        _request = request;
        _resource = resource;
        _parser = resource.parser;
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
        
        // parse the m3u8 file
        if ( _parser == nil ) {
            _parser = [MCSHLSParser.alloc initWithResource:_resource.name request:[_request mcs_requestWithHTTPAdditionalHeaders:[_resource.configuration HTTPAdditionalHeadersForDataRequestsOfType:MCSDataTypeHLSPlaylist]] networkTaskPriority:_networkTaskPriority delegate:self delegateQueue:_delegateQueue];
            [_parser prepare];
            return;
        }
        
        [self _parseDidFinish];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    [self lock];
    @try {
        return [_reader seekToOffset:offset];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSData *)readDataOfLength:(NSUInteger)length {
    [self lock];
    @try {
        return [_reader readDataOfLength:length];
    } @catch (__unused NSException *exception) {
    
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

- (NSUInteger)availableLength {
    [self lock];
    @try {
        return _reader.availableLength;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSUInteger)offset {
    [self lock];
    @try {
        return _reader.offset;
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
        return _reader.isDone;
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

#pragma mark - MCSHLSParserDelegate

- (void)parserParseDidFinish:(MCSHLSParser *)parser {
    [self lock];
    [self _parseDidFinish];
    [self unlock];
}

- (void)parser:(MCSHLSParser *)parser anErrorOccurred:(NSError *)error {
    [self lock];
    [self _onError:error];
    [self unlock];
}

#pragma mark - MCSResourceDataReaderDelegate

- (void)readerPrepareDidFinish:(id<MCSResourceDataReader>)reader {
    [self lock];
    NSString *indexFilePath = _parser.indexFilePath;
    NSUInteger length = [MCSFileManager fileSizeAtPath:indexFilePath];
    _response = [MCSResourceResponse.alloc initWithServer:@"localhost" contentType:@"application/x-mpegurl" totalLength:length];
    _isPrepared = YES;
    [self unlock];
    [self.delegate readerPrepareDidFinish:self];
}

- (void)reader:(id<MCSResourceDataReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    [self.delegate reader:self hasAvailableDataWithLength:length];
}

- (void)reader:(id<MCSResourceDataReader>)reader anErrorOccurred:(NSError *)error {
    [self lock];
    [self _onError:error];
    [self unlock];
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
    [_reader close];
    _isClosed = YES;
    
    MCSLog(@"%@: <%p>.close { URL: %@ };\n", NSStringFromClass(self.class), self, _request.URL);
}

- (void)_parseDidFinish {
    if ( _resource.parser != _parser ) {
        _resource.parser = _parser;
    }
    
    NSString *indexFilePath = _parser.indexFilePath;
    NSUInteger fileSize = [MCSFileManager fileSizeAtPath:indexFilePath];
    NSRange range = NSMakeRange(0, fileSize);
    _reader = [MCSResourceFileDataReader.alloc initWithRange:range path:indexFilePath readRange:range delegate:_delegate delegateQueue:_delegateQueue];
    [_reader prepare];
}

#pragma mark -

- (void)lock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_semaphore);
}
@end
