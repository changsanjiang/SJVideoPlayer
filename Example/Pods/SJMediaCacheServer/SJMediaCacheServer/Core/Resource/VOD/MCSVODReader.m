//
//  MCSVODReader.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSVODReader.h"
#import "MCSResourcePartialContent.h"
#import "MCSResourceResponse.h"
#import "MCSResourceManager.h"
#import "MCSFileManager.h"
#import "MCSResourceFileDataReader.h"
#import "MCSError.h"
#import "MCSLogger.h"
#import "MCSVODResource.h"
#import "MCSResourceSubclass.h"
#import "MCSVODMetaDataReader.h"
#import "MCSVODNetworkDataReader.h"

@interface MCSVODReader ()<NSLocking, MCSResourceDataReaderDelegate, MCSVODMetaDataReaderDelegate> {
    dispatch_semaphore_t _semaphore;
}

@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isClosed;

@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, strong, readonly, nullable) id<MCSResourceDataReader> currentReader;
@property (nonatomic) NSUInteger offset;

@property (nonatomic, weak, nullable) MCSVODResource *resource;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, copy, nullable) NSArray<id<MCSResourceDataReader>> *readers;
@property (nonatomic, strong, nullable) id<MCSResourceResponse> response;

@property (nonatomic, strong, nullable) MCSVODMetaDataReader *metaDataReader;

@property (nonatomic, strong) NSMutableArray<MCSResourcePartialContent *> *readWriteContents;
@end

@implementation MCSVODReader
@synthesize readDataDecoder = _readDataDecoder;

- (instancetype)initWithResource:(__weak MCSVODResource *)resource request:(NSURLRequest *)request {
    self = [super init];
    if ( self ) {
        _networkTaskPriority = 1.0;
        
        _readWriteContents = NSMutableArray.array;
        _semaphore = dispatch_semaphore_create(1);
        _currentIndex = NSNotFound;

        _resource = resource;
        _request = request;
        _offset = _request.mcs_range.location;
        
        [_resource readWrite_retain];
        [MCSResourceManager.shared reader:self willReadResource:_resource];
        
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

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { range: %@\n };", NSStringFromClass(self.class), self, NSStringFromRange(_request.mcs_range)];
}

- (void)didRemoveResource:(NSNotification *)note {
    MCSResource *resource = note.userInfo[MCSResourceManagerUserInfoResourceKey];
    if ( resource == _resource && !self.isClosed )  {
        [self lock];
        [self _onError:[NSError mcs_removedResource:self.request.URL]];
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
        
        MCSLog(@"%@: <%p>.prepare { name: %@, range: %@ };\n", NSStringFromClass(self.class), self, _resource.name, NSStringFromRange(_request.mcs_range));
        
        _isCalledPrepare = YES;
        
        if ( _resource.totalLength == 0 || _resource.pathExtension.length == 0 ) {
            _metaDataReader = [MCSVODMetaDataReader.alloc initWithRequest:_request delegate:self delegateQueue:_resource.readerOperationQueue];
            return;
        }
        
        [self _prepare];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSData *)readDataOfLength:(NSUInteger)length {
    [self lock];
    @try {
        if ( _isClosed || _currentIndex == NSNotFound || !self.currentReader.isPrepared )
            return nil;
        
        NSData *data = [self.currentReader readDataOfLength:length];
        _offset += data.length;
        if ( _readDataDecoder != nil ) data = _readDataDecoder(_request, _offset, data);
        return data;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        if ( self.currentReader.isDone ) {
            if ( self.currentReader != _readers.lastObject ) {
                [self _prepareNextReader];
            }
            else {
                MCSLog(@"%@: <%p>.done { range: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_request.mcs_range));
                [self _close];
            }
        }
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

- (BOOL)isReadingEndOfData {
    [self lock];
    @try {
        return _readers.lastObject.isDone;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (BOOL)isClosed {
    [self lock];
    @try {
        return _isClosed;
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

- (void)_prepare {
    NSUInteger totalLength = _resource.totalLength;
    NSAssert(totalLength != 0, @"`_resource.totalLength`不能为`0`!");
     
    // `length`经常变动, 暂时这里排序吧
    __auto_type contents = [_resource.contents sortedArrayUsingComparator:^NSComparisonResult(MCSResourcePartialContent *obj1, MCSResourcePartialContent *obj2) {
        if ( obj1.offset == obj2.offset )
            return obj1.length >= obj2.length ? NSOrderedAscending : NSOrderedDescending;
        return obj1.offset < obj2.offset ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    NSRange current = _request.mcs_range;
    // bytes=-500
    if      ( current.location == NSNotFound && current.length != NSNotFound )
        current.location = totalLength - current.length;
    // bytes=9500-
    else if ( current.location != NSNotFound && current.length == NSNotFound ) {
        current.length = totalLength - current.location;
    }
    else if ( current.location == NSNotFound && current.length == NSNotFound ) {
        current.location = 0;
        current.length = totalLength;
    }
    
    _response = [MCSResourceResponse.alloc initWithServer:_resource.server contentType:_resource.contentType totalLength:totalLength contentRange:current];

    NSMutableArray<id<MCSResourceDataReader>> *readers = NSMutableArray.array;
    for ( MCSResourcePartialContent *content in contents ) {
        NSRange available = NSMakeRange(content.offset, content.length);
        NSRange intersection = NSIntersectionRange(current, available);
        if ( intersection.length != 0 ) {
            // undownloaded part
            NSRange leftRange = NSMakeRange(current.location, intersection.location - current.location);
            if ( leftRange.length != 0 ) {
                MCSVODNetworkDataReader *reader = [MCSVODNetworkDataReader.alloc initWithResource:_resource request:[_request mcs_requestWithRange:leftRange] networkTaskPriority:_networkTaskPriority delegate:self delegateQueue:_resource.readerOperationQueue];
                [readers addObject:reader];
            }
            
            // downloaded part
            NSRange matchedRange = NSMakeRange(NSMaxRange(leftRange), intersection.length);
            NSRange fileRange = NSMakeRange(matchedRange.location - content.offset, intersection.length);
            NSString *path = [MCSFileManager getFilePathWithName:content.name inResource:_resource.name];
            MCSResourceFileDataReader *reader = [MCSResourceFileDataReader.alloc initWithRange:matchedRange path:path readRange:fileRange delegate:self delegateQueue:_resource.readerOperationQueue];
            [readers addObject:reader];
            
            // retain
            [content readWrite_retain];
            [_readWriteContents addObject:content];
            
            // next part
            current = NSMakeRange(NSMaxRange(intersection), NSMaxRange(_request.mcs_range) - NSMaxRange(intersection));
        }
        
        if ( current.length == 0 || available.location > NSMaxRange(current) ) break;
    }
    
    if ( current.length != 0 ) {
        // undownloaded part
        MCSVODNetworkDataReader *reader = [MCSVODNetworkDataReader.alloc initWithResource:_resource request:[_request mcs_requestWithRange:current] networkTaskPriority:_networkTaskPriority delegate:self delegateQueue:_resource.readerOperationQueue];
        [readers addObject:reader];
    }
    
    _metaDataReader = nil;
    _readers = readers.copy;
     
    MCSLog(@"%@: <%p>.createSubreaders { range: %@, count: %lu };\n", NSStringFromClass(self.class), self, NSStringFromRange(_request.mcs_range), (unsigned long)_readers.count);

    [self _prepareNextReader];
}

- (void)_prepareNextReader {
    [self.currentReader close];

    if ( self.currentReader == _readers.lastObject )
        return;
    
    if ( _currentIndex == NSNotFound )
        _currentIndex = 0;
    else
        _currentIndex += 1;
    
    [self.currentReader prepare];
}

- (nullable id<MCSResourceDataReader>)currentReader {
    if ( _currentIndex != NSNotFound && _currentIndex < _readers.count ) {
        return _readers[_currentIndex];
    }
    return nil;
}

- (void)_close {
    if ( _isClosed )
        return;
    
    for ( id<MCSResourceDataReader> reader in _readers ) {
        [reader close];
    }
    
    for ( MCSResourcePartialContent *content in _readWriteContents ) {
        [content readWrite_release];
    }
    
    _isClosed = YES;
    MCSLog(@"%@: <%p>.close { range: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_request.mcs_range));
}

#pragma mark -

- (void)lock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_semaphore);
}

#pragma mark - MCSVODMetaDataReaderDelegate

- (void)metaDataReader:(MCSVODMetaDataReader *)reader didCompleteWithError:(NSError *_Nullable)error {
    [self lock];
    @try {
        if ( error ) {
            [self _onError:error];
            return;
        }
        
        [_resource updateServer:reader.server contentType:reader.contentType totalLength:reader.totalLength pathExtension:reader.pathExtension];
        
        [self _prepare];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

#pragma mark - MCSResourceDataReaderDelegate

- (void)readerPrepareDidFinish:(id<MCSResourceDataReader>)reader {
    if ( self.isPrepared )
        return;
    
    [self lock];
    @try {
        _isPrepared = YES;
        
        dispatch_async(_resource.readerOperationQueue, ^{
            [self.delegate readerPrepareDidFinish:self];
        });
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)readerHasAvailableData:(id<MCSResourceDataReader>)reader {
    [self.delegate readerHasAvailableData:self];
}

- (void)reader:(id<MCSResourceDataReader>)reader anErrorOccurred:(NSError *)error {
    [self _onError:error];
}

- (void)_onError:(NSError *)error {
    [self _close];
    
    dispatch_async(_resource.readerOperationQueue, ^{
        
        MCSLog(@"%@: <%p>.error { error: %@ };\n", NSStringFromClass(self.class), self, error);

        [self.delegate reader:self anErrorOccurred:error];
    });
}
@end
