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
#import "MCSQueue.h"

@interface MCSHLSIndexDataReader ()<MCSHLSParserDelegate, MCSResourceDataReaderDelegate>
@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isClosed;

@property (nonatomic, weak, nullable) MCSHLSResource *resource;
@property (nonatomic, strong, nullable) MCSResourceFileDataReader *reader;
@property (nonatomic, strong, nullable) id<MCSResourceResponse> response;
@property (nonatomic) float networkTaskPriority;
@end

@implementation MCSHLSIndexDataReader
@synthesize delegate = _delegate;
- (instancetype)initWithResource:(MCSHLSResource *)resource request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<MCSResourceDataReaderDelegate>)delegate {
    self = [super init];
    if ( self ) {
        _networkTaskPriority = networkTaskPriority;
        _request = request;
        _resource = resource;
        _parser = resource.parser;
        _delegate = delegate;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { URL: %@\n };", NSStringFromClass(self.class), self, _request.URL];
}

- (void)prepare {
    dispatch_barrier_sync(MCSHLSIndexDataReaderQueue(), ^{
        if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSLog(@"%@: <%p>.prepare { URL: %@ };\n", NSStringFromClass(self.class), self, _request.URL);
        
        NSParameterAssert(_resource);
        
        _isCalledPrepare = YES;
        
        // parse the m3u8 file
        if ( _parser == nil ) {
            _parser = [MCSHLSParser.alloc initWithResource:_resource.name request:[_request mcs_requestWithHTTPAdditionalHeaders:[_resource.configuration HTTPAdditionalHeadersForDataRequestsOfType:MCSDataTypeHLSPlaylist]] networkTaskPriority:_networkTaskPriority delegate:self];
            [_parser prepare];
            return;
        }
        
        [self _parseDidFinish];
    });
}

- (nullable MCSResourceFileDataReader *)reader {
    __block MCSResourceFileDataReader *reader = nil;
    dispatch_sync(MCSHLSIndexDataReaderQueue(), ^{
        reader = _reader;
    });
    return reader;
}

- (NSData *)readDataOfLength:(NSUInteger)length {
    return [self.reader readDataOfLength:length];
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    return [self.reader seekToOffset:offset];
}

- (void)close {
    dispatch_barrier_sync(MCSHLSIndexDataReaderQueue(), ^{
        [self _close];
    });
}

#pragma mark -

- (NSUInteger)availableLength {
    return self.reader.availableLength;
}

- (NSUInteger)offset {
    return self.reader.offset;
}

- (BOOL)isPrepared {
    return self.reader.isPrepared;
}

- (BOOL)isDone {
    return self.reader.isDone;
}

- (id<MCSResourceResponse>)response {
    __block id<MCSResourceResponse> response = nil;
    dispatch_sync(MCSHLSIndexDataReaderQueue(), ^{
        response = _response;
    });
    return response;
}

#pragma mark - MCSHLSParserDelegate

- (void)parserParseDidFinish:(MCSHLSParser *)parser {
    dispatch_barrier_sync(MCSHLSIndexDataReaderQueue(), ^{
        [self _parseDidFinish];
    });
}

- (void)parser:(MCSHLSParser *)parser anErrorOccurred:(NSError *)error {
    dispatch_barrier_sync(MCSHLSIndexDataReaderQueue(), ^{
        [self _onError:error];
    });
}

#pragma mark - MCSResourceDataReaderDelegate

- (void)readerPrepareDidFinish:(id<MCSResourceDataReader>)reader {
    dispatch_barrier_sync(MCSHLSIndexDataReaderQueue(), ^{
        NSString *indexFilePath = _parser.indexFilePath;
        NSUInteger length = [MCSFileManager fileSizeAtPath:indexFilePath];
        _response = [MCSResourceResponse.alloc initWithServer:@"localhost" contentType:@"application/x-mpegurl" totalLength:length];
    });
    [_delegate readerPrepareDidFinish:self];
}

- (void)reader:(id<MCSResourceDataReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    [_delegate reader:self hasAvailableDataWithLength:length];
}

- (void)reader:(id<MCSResourceDataReader>)reader anErrorOccurred:(NSError *)error {
    dispatch_barrier_sync(MCSHLSIndexDataReaderQueue(), ^{
        [self _onError:error];
    });
}

#pragma mark -

- (void)_onError:(NSError *)error {
    if ( _isClosed )
        return;
    
    [self _close];
    
    dispatch_async(MCSDelegateQueue(), ^{
        [self->_delegate reader:self anErrorOccurred:error];
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
    if ( _reader != nil )
        return;
    
    if ( _resource.parser != _parser ) {
        _resource.parser = _parser;
    }
    
    NSString *indexFilePath = _parser.indexFilePath;
    NSUInteger fileSize = [MCSFileManager fileSizeAtPath:indexFilePath];
    NSRange range = NSMakeRange(0, fileSize);
    _reader = [MCSResourceFileDataReader.alloc initWithResource:_resource range:range path:indexFilePath readRange:range delegate:_delegate];
    [_reader prepare];
}
@end
