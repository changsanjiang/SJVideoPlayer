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

@interface MCSHLSReader ()<NSLocking, MCSResourceDataReaderDelegate> {
    dispatch_semaphore_t _semaphore;
}
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic, weak, nullable) MCSHLSResource *resource;
@property (nonatomic, strong, nullable) NSURLRequest *request;
@property (nonatomic, strong, nullable) id<MCSHLSDataReader> reader;
@end

@implementation MCSHLSReader
@synthesize readDataDecoder = _readDataDecoder;
@synthesize isPrepared = _isPrepared;

- (instancetype)initWithResource:(__weak MCSHLSResource *)resource request:(NSURLRequest *)request {
    self = [super init];
    if ( self ) {
        _networkTaskPriority = 1.0;
        _resource = resource;
        _request = request;
        _semaphore = dispatch_semaphore_create(1);
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
    if ( resource == _resource && !self.isClosed )  {
        [self lock];
        [self _onError:[NSError mcs_removedResource:_request.URL]];
        [self unlock];
    }
}

- (void)userCancelledReading:(NSNotification *)note {
    MCSResource *resource = note.userInfo[MCSResourceManagerUserInfoResourceKey];
    if ( resource == _resource && !self.isClosed )  {
        [self lock];
        [self _onError:[NSError mcs_userCancelledError:_request.URL]];
        [self unlock];
    }
}

- (void)prepare {
    [self lock];
    @try {
        if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSLog(@"%@: <%p>.prepare { name: %@, URL: %@ };\n", NSStringFromClass(self.class), self, _resource.name, _request.URL);

        
        _isCalledPrepare = YES;
        NSURL *URL = [MCSURLRecognizer.shared URLWithProxyURL:_request.URL];
        NSMutableURLRequest *request = [_request mcs_requestWithRedirectURL:URL];
        if      ( [_request.URL.absoluteString containsString:MCSHLSIndexFileExtension] ) {
            _reader = [MCSHLSIndexDataReader.alloc initWithResource:_resource request:request networkTaskPriority:_networkTaskPriority delegate:self delegateQueue:_resource.readerOperationQueue];
        }
        else if ( [_request.URL.absoluteString containsString:MCSHLSAESKeyFileExtension] ) {
            NSAssert(_resource.parser != nil, @"`parser`不能为nil!");
            _reader = [MCSHLSAESKeyDataReader.alloc initWithResource:_resource request:request networkTaskPriority:_networkTaskPriority delegate:self delegateQueue:_resource.readerOperationQueue];
        }
        else {
            NSAssert(_resource.parser != nil, @"`parser`不能为nil!");
            _reader = [MCSHLSTSDataReader.alloc initWithResource:_resource request:request networkTaskPriority:_networkTaskPriority delegate:self delegateQueue:_resource.readerOperationQueue];
        }
        
        [_reader prepare];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSData *)readDataOfLength:(NSUInteger)length {
    [self lock];
    @try {
        NSUInteger offset = _reader.offset;
        NSData *data = [_reader readDataOfLength:length];
        
        if ( data != nil ) {
            if ( _readDataDecoder != nil ) data = _readDataDecoder(_request, offset, data);
            return data;
        }
        return nil;
    } @catch (__unused NSException *exception) {
        
    } @finally {
#ifdef DEBUG
        if ( _reader.isDone ) {
            MCSLog(@"%@: <%p>.done { URL: %@ };\n", NSStringFromClass(self.class), self, _request.URL);
        }
#endif
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

- (BOOL)isReadingEndOfData {
    [self lock];
    @try {
        return _reader.isDone;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

@synthesize isClosed = _isClosed;
- (BOOL)isClosed {
    [self lock];
    @try {
        return _isClosed;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (id<MCSResourceResponse>)response {
    [self lock];
    @try {
        return _reader.response;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
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

- (void)lock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_semaphore);
}

#pragma mark -

- (void)readerPrepareDidFinish:(id<MCSResourceDataReader>)reader {
    [self lock];
    _isPrepared = YES;
    if ( [reader isKindOfClass:MCSHLSIndexDataReader.class] ) {
        MCSHLSParser *parser = [(MCSHLSIndexDataReader *)reader parser];
        if ( parser != nil && _resource.parser != parser )
            _resource.parser = parser;
    }
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

- (void)_onError:(NSError *)error {
    [self _close];
    dispatch_async(_resource.readerOperationQueue, ^{
        
        MCSLog(@"%@: <%p>.error { error: %@ };\n", NSStringFromClass(self.class), self, error);

        [self.delegate reader:self anErrorOccurred:error];
    });
}
@end
