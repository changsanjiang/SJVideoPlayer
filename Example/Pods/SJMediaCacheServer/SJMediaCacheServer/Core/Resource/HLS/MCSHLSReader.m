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

@interface MCSHLSReader ()<MCSResourceDataReaderDelegate> 
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic, weak, nullable) MCSHLSResource *resource;
@property (nonatomic, strong, nullable) NSURLRequest *request;
@property (nonatomic, strong, nullable) id<MCSHLSDataReader> reader;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation MCSHLSReader
@synthesize readDataDecoder = _readDataDecoder;
@synthesize isClosed = _isClosed;

- (instancetype)initWithResource:(__weak MCSHLSResource *)resource request:(NSURLRequest *)request {
    self = [super init];
    if ( self ) {
        _queue = dispatch_get_global_queue(0, 0);
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
    if ( !_isClosed ) [self close];
    MCSLog(@"%@: <%p>.dealloc;\n", NSStringFromClass(self.class), self);
}

- (void)didRemoveResource:(NSNotification *)note {
    MCSResource *resource = note.userInfo[MCSResourceManagerUserInfoResourceKey];
    if ( resource == _resource )  {
        dispatch_barrier_sync(_queue, ^{
            if ( self->_isClosed )
                return;
            [self _onError:[NSError mcs_removedResource:self->_request.URL]];
        });
    }
}

- (void)userCancelledReading:(NSNotification *)note {
    MCSResource *resource = note.userInfo[MCSResourceManagerUserInfoResourceKey];
    if ( resource == _resource && !self.isClosed )  {
        dispatch_barrier_sync(_queue, ^{
           if ( self->_isClosed )
               return;
            [self _onError:[NSError mcs_userCancelledError:self->_request.URL]];
        });
    }
}

- (void)prepare {
    dispatch_barrier_sync(_queue, ^{
        if ( self->_isClosed || self->_isCalledPrepare )
            return;
        
        MCSLog(@"%@: <%p>.prepare { name: %@, URL: %@ };\n", NSStringFromClass(self.class), self, self->_resource.name, self->_request.URL);

        
        self->_isCalledPrepare = YES;
        NSURL *URL = [MCSURLRecognizer.shared URLWithProxyURL:self->_request.URL];
        NSMutableURLRequest *request = [self->_request mcs_requestWithRedirectURL:URL];
        if      ( [self->_request.URL.absoluteString containsString:MCSHLSIndexFileExtension] ) {
            self->_reader = [MCSHLSIndexDataReader.alloc initWithResource:self->_resource request:request networkTaskPriority:self->_networkTaskPriority delegate:self];
        }
        else if ( [self->_request.URL.absoluteString containsString:MCSHLSAESKeyFileExtension] ) {
            NSAssert(self->_resource.parser != nil, @"`parser`不能为nil!");
            self->_reader = [MCSHLSAESKeyDataReader.alloc initWithResource:self->_resource request:request networkTaskPriority:self->_networkTaskPriority delegate:self];
        }
        else {
            NSAssert(self->_resource.parser != nil, @"`parser`不能为nil!");
            self->_reader = [MCSHLSTSDataReader.alloc initWithResource:self->_resource request:request networkTaskPriority:self->_networkTaskPriority delegate:self];
        }
        
        [self->_reader prepare];
    });
}

- (nullable id<MCSHLSDataReader>)reader {
    __block id<MCSHLSDataReader> reader = nil;
    dispatch_sync(_queue, ^{
        reader = _reader;
    });
    return reader;
}

- (NSData *)readDataOfLength:(NSUInteger)length {
    __block NSData *data = nil;
    dispatch_barrier_sync(_queue, ^{
        NSUInteger offset = self->_reader.offset;
        data = [self->_reader readDataOfLength:length];
        
        if ( data != nil && self->_readDataDecoder != nil ) {
            data = self->_readDataDecoder(self->_request, offset, data);
        }
        
#ifdef DEBUG
        if ( self->_reader.isDone ) {
            MCSLog(@"%@: <%p>.done { URL: %@ };\n", NSStringFromClass(self.class), self, self->_request.URL);
        }
#endif
    });
    return data;
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    return [self.reader seekToOffset:offset];
}

- (void)close {
    dispatch_barrier_sync(_queue, ^{
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
    dispatch_sync(_queue, ^{
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
    dispatch_barrier_sync(_queue, ^{
        if ( [reader isKindOfClass:MCSHLSIndexDataReader.class] ) {
            MCSHLSParser *parser = [(MCSHLSIndexDataReader *)reader parser];
            if ( parser != nil && self->_resource.parser != parser )
                self->_resource.parser = parser;
        }
        
    });
    [_delegate readerPrepareDidFinish:self];
}

- (void)reader:(id<MCSResourceDataReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    [_delegate reader:self hasAvailableDataWithLength:length];
}

- (void)reader:(id<MCSResourceDataReader>)reader anErrorOccurred:(NSError *)error {
    dispatch_barrier_sync(_queue, ^{
        [self _onError:error];
    });
}

- (void)_onError:(NSError *)error {
    [self _close];
    MCSLog(@"%@: <%p>.error { error: %@ };\n", NSStringFromClass(self.class), self, error);
    
    [_delegate reader:self anErrorOccurred:error];
}
@end
