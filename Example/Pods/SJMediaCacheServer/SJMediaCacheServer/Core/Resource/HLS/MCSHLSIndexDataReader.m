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

@interface MCSHLSIndexDataReader ()<MCSHLSParserDelegate, MCSResourceDataReaderDelegate>
@property (nonatomic, strong) NSURL *URL;

@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isDone;

@property (nonatomic, weak, nullable) MCSHLSResource *resource;
@property (nonatomic, strong, nullable) MCSResourceFileDataReader *reader;
@end

@implementation MCSHLSIndexDataReader
@synthesize delegate = _delegate;
- (instancetype)initWithResource:(MCSHLSResource *)resource URL:(NSURL *)URL {
    self = [super init];
    if ( self ) {
        _URL = URL;
        _resource = resource;
        _parser = resource.parser;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { URL: %@\n };", NSStringFromClass(self.class), self, _URL];
}

- (void)prepare {
    if ( _isClosed || _isCalledPrepare )
        return;
    
    MCSLog(@"%@: <%p>.prepare { URL: %@ };\n", NSStringFromClass(self.class), self, _URL);

    _isCalledPrepare = YES;
    
    if ( _parser == nil ) {
        _parser = [MCSHLSParser.alloc initWithURL:_URL inResource:_resource.name delegate:self];
        [_parser prepare];
    }
    else {
        [self _parseDidFinish];
    }
}

- (NSData *)readDataOfLength:(NSUInteger)length {
    return [_reader readDataOfLength:length];
}

- (BOOL)isDone {
    return _reader.isDone;
}

- (void)close {
    if ( _isClosed )
        return;
    _isClosed = YES;
    [_reader close];
    
    MCSLog(@"%@: <%p>.close { URL: %@ };\n", NSStringFromClass(self.class), self, _URL);
}

#pragma mark -

- (void)_parseDidFinish {
    if ( _resource.parser != _parser ) {
        _resource.parser = _parser;
    }
    
    NSString *indexFilePath = _parser.indexFilePath;
    NSUInteger fileSize = (NSUInteger)[NSFileManager.defaultManager attributesOfItemAtPath:indexFilePath error:NULL].fileSize;
    NSRange range = NSMakeRange(0, fileSize);
    _reader = [MCSResourceFileDataReader.alloc initWithRange:range path:indexFilePath readRange:range];
    _reader.delegate = self;
    [_reader prepare];
}

#pragma mark -

- (void)parserParseDidFinish:(MCSHLSParser *)parser {
    [self _parseDidFinish];
}

- (void)parser:(MCSHLSParser *)parser anErrorOccurred:(NSError *)error {
    [_delegate reader:self anErrorOccurred:error];
}

#pragma mark -

- (void)readerPrepareDidFinish:(id<MCSResourceDataReader>)reader {
    NSString *indexFilePath = _parser.indexFilePath;
    NSUInteger length = (NSUInteger)[NSFileManager.defaultManager attributesOfItemAtPath:indexFilePath error:NULL].fileSize;
    _response = [MCSResourceResponse.alloc initWithServer:@"localhost" contentType:@"application/x-mpegurl" totalLength:length];
    [_delegate readerPrepareDidFinish:self];
}

- (void)readerHasAvailableData:(id<MCSResourceDataReader>)reader {
    [_delegate readerHasAvailableData:self];
}

- (void)reader:(id<MCSResourceDataReader>)reader anErrorOccurred:(NSError *)error {
    [_delegate reader:self anErrorOccurred:error];
}

@end
