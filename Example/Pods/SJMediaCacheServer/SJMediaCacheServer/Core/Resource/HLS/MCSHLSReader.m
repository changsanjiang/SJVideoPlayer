//
//  MCSHLSReader.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSHLSReader.h"
#import "MCSHLSResource.h"
#import "MCSHLSIndexDataReader.h"
#import "MCSHLSAESKeyDataReader.h"
#import "MCSHLSTSDataReader.h"
#import "MCSFileManager.h"
#import "MCSLogger.h"
#import "MCSHLSResource.h"
#import "MCSResourceManager.h"
#import "MCSError.h"
#import "MCSQueue.h"

@interface MCSHLSReader ()<MCSResourceDataReaderDelegate> 
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic, weak, nullable) MCSHLSResource *resource;
@property (nonatomic, strong, nullable) NSURLRequest *request;
@property (nonatomic, strong, nullable) id<MCSHLSDataReader> reader;
@end

@implementation MCSHLSReader
@synthesize readDataDecoder = _readDataDecoder;
@synthesize isClosed = _isClosed;

- (instancetype)initWithResource:(__weak MCSHLSResource *)resource request:(NSURLRequest *)request {
    self = [super init];
    if ( self ) {
        _networkTaskPriority = 1.0;
        _resource = resource;
        _request = request;
        [_resource readWrite_retain];
        [MCSResourceManager.shared reader:self willReadResource:resource];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didRemoveResource:) name:MCSResourceManagerDidRemoveResourceNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(userCancelledReading:) name:MCSResourceManagerUserCancelledReadingNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [_resource readWrite_release];
    [MCSResourceManager.shared reader:self didEndReadResource:_resource];
    if ( !_isClosed ) [self _close];
    MCSLog(@"%@: <%p>.dealloc;\n", NSStringFromClass(self.class), self);
}

- (void)didRemoveResource:(NSNotification *)note {
    MCSResource *resource = note.userInfo[MCSResourceManagerUserInfoResourceKey];
    if ( resource == _resource )  {
        dispatch_barrier_sync(MCSReaderQueue(), ^{
            if ( _isClosed )
                return;
            [self _onError:[NSError mcs_removedResource:_request.URL]];
        });
    }
}

- (void)userCancelledReading:(NSNotification *)note {
    MCSResource *resource = note.userInfo[MCSResourceManagerUserInfoResourceKey];
    if ( resource == _resource && !self.isClosed )  {
        dispatch_barrier_sync(MCSReaderQueue(), ^{
           if ( _isClosed )
               return;
            [self _onError:[NSError mcs_userCancelledError:_request.URL]];
        });
    }
}

- (void)prepare {
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSLog(@"%@: <%p>.prepare { name: %@, URL: %@ };\n", NSStringFromClass(self.class), self, _resource.name, _request.URL);

        NSParameterAssert(_resource);
        
        _isCalledPrepare = YES;
        NSURL *URL = [MCSURLRecognizer.shared URLWithProxyURL:_request.URL];
        NSMutableURLRequest *request = [_request mcs_requestWithRedirectURL:URL];
        if      ( [_request.URL.absoluteString containsString:MCSHLSIndexFileExtension] ) {
            _reader = [MCSHLSIndexDataReader.alloc initWithResource:_resource request:request networkTaskPriority:_networkTaskPriority delegate:self];
        }
        else if ( [_request.URL.absoluteString containsString:MCSHLSAESKeyFileExtension] ) {
            if ( _resource.parser == nil ) {
                [self _onError:[NSError mcs_HLSFileParseError:_request.URL]];
                return;
            }
            _reader = [MCSHLSAESKeyDataReader.alloc initWithResource:_resource request:request networkTaskPriority:_networkTaskPriority delegate:self];
        }
        else {
            if ( _resource.parser == nil ) {
                [self _onError:[NSError mcs_HLSFileParseError:_request.URL]];
                return;
            }
            _reader = [MCSHLSTSDataReader.alloc initWithResource:_resource request:request networkTaskPriority:_networkTaskPriority delegate:self];
        }
        
        [_reader prepare];
    });
}

- (nullable id<MCSHLSDataReader>)reader {
    __block id<MCSHLSDataReader> reader = nil;
    dispatch_sync(MCSReaderQueue(), ^{
        reader = _reader;
    });
    return reader;
}

- (NSData *)readDataOfLength:(NSUInteger)length {
    __block NSData *data = nil;
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        NSUInteger offset = _reader.offset;
        data = [_reader readDataOfLength:length];
        
        if ( data != nil && _readDataDecoder != nil ) {
            data = _readDataDecoder(_request, offset, data);
        }
        
#ifdef DEBUG
        if ( _reader.isDone ) {
            MCSLog(@"%@: <%p>.done { URL: %@ };\n", NSStringFromClass(self.class), self, _request.URL);
        }
#endif
    });
    return data;
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    return [self.reader seekToOffset:offset];
}

- (void)close {
    dispatch_barrier_sync(MCSReaderQueue(), ^{
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

- (BOOL)isReadingEndOfData {
    return self.reader.isDone;
}

- (BOOL)isClosed {
    __block BOOL result = NO;
    dispatch_sync(MCSReaderQueue(), ^{
        result = _isClosed;
    });
    return result;
}

- (id<MCSResourceResponse>)response {
    return self.reader.response;
}

#pragma mark -

- (void)_close {
    if ( _isClosed )
        return;
    
    [_reader close];
     
    _isClosed = YES;
    
    MCSLog(@"%@: <%p>.close { URL: %@ };\n", NSStringFromClass(self.class), self, _request.URL);
}

#pragma mark -

- (void)readerPrepareDidFinish:(id<MCSResourceDataReader>)reader {
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        if ( [reader isKindOfClass:MCSHLSIndexDataReader.class] ) {
            MCSHLSParser *parser = [(MCSHLSIndexDataReader *)reader parser];
            if ( parser != nil && _resource.parser != parser )
                _resource.parser = parser;
        }
        
    });
    [_delegate readerPrepareDidFinish:self];
}

- (void)reader:(id<MCSResourceDataReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    [_delegate reader:self hasAvailableDataWithLength:length];
}

- (void)reader:(id<MCSResourceDataReader>)reader anErrorOccurred:(NSError *)error {
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        [self _onError:error];
    });
}

- (void)_onError:(NSError *)error {
    if ( _isClosed )
        return;
    [self _close];
    MCSLog(@"%@: <%p>.error { error: %@ };\n", NSStringFromClass(self.class), self, error);
    
    dispatch_async(MCSDelegateQueue(), ^{
        [self->_delegate reader:self anErrorOccurred:error];
    });
}
@end
