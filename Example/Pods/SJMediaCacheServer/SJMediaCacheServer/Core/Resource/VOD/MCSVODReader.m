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

@interface MCSVODReader ()<MCSResourceDataReaderDelegate, MCSVODMetaDataReaderDelegate>
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isClosed;

@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, strong, readonly, nullable) id<MCSResourceDataReader> currentReader;
@property (nonatomic) NSUInteger readLength;

@property (nonatomic, weak, nullable) MCSVODResource *resource;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, copy, nullable) NSArray<id<MCSResourceDataReader>> *readers;
@property (nonatomic, strong, nullable) id<MCSResourceResponse> response;

@property (nonatomic, strong, nullable) MCSVODMetaDataReader *metaDataReader;

@property (nonatomic, strong) NSMutableArray<MCSResourcePartialContent *> *readWriteContents;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation MCSVODReader
@synthesize readDataDecoder = _readDataDecoder;

- (instancetype)initWithResource:(__weak MCSVODResource *)resource request:(NSURLRequest *)request {
    self = [super init];
    if ( self ) {
        _queue = dispatch_get_global_queue(0, 0);
        _networkTaskPriority = 1.0;
        
        _readWriteContents = NSMutableArray.array;
        _currentIndex = NSNotFound;

        _resource = resource;
        _request = request;
        
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
    if ( resource == _resource )  {
        dispatch_barrier_sync(_queue, ^{
            if ( self->_isClosed )
                return;
            [self _onError:[NSError mcs_removedResource:self->_request.URL]];
        });
    }
}

- (void)prepare {
    dispatch_barrier_sync(_queue, ^{
        if ( self->_isClosed || self->_isCalledPrepare )
            return;
        
        MCSLog(@"%@: <%p>.prepare { name: %@, range: %@ };\n", NSStringFromClass(self.class), self, self->_resource.name, NSStringFromRange(self->_request.mcs_range));
        
        self->_isCalledPrepare = YES;
        
        if ( self->_resource.totalLength == 0 || self->_resource.pathExtension.length == 0 ) {
            NSURL *URL = [MCSURLRecognizer.shared URLWithProxyURL:self->_request.URL];
            self->_metaDataReader = [MCSVODMetaDataReader.alloc initWithRequest:[self->_request mcs_requestWithRedirectURL:URL] delegate:self delegateQueue:self->_queue];
            return;
        }
        
        [self _prepare];
    });
}

- (NSData *)readDataOfLength:(NSUInteger)length {
    __block NSData *data = nil;
    dispatch_barrier_sync(_queue, ^{
        id<MCSResourceDataReader> currentReader = self.currentReader;
        if ( self->_isClosed || !currentReader.isPrepared )
            return;
        
        data = [currentReader readDataOfLength:length];
        NSUInteger readLength = data.length;
        if ( self->_readDataDecoder != nil )
            data = self->_readDataDecoder(self->_request, self->_response.contentRange.location + self->_readLength, data);
        self->_readLength += readLength;
        
        if ( currentReader.isDone ) {
            currentReader != self->_readers.lastObject ? [self _prepareNextReader] : [self _close];
#ifdef DEBUG
            if ( currentReader == self->_readers.lastObject ) {
                MCSLog(@"%@: <%p>.done { range: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(self->_request.mcs_range));
            }
#endif
        }
    });
    return data;
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    __block BOOL result = NO;
    dispatch_barrier_sync(_queue, ^{
        if ( _isClosed || !_isPrepared  )
            return;

        for ( id<MCSResourceDataReader> reader in _readers ) {
            if ( NSLocationInRange(offset - 1, reader.range) ) {
                result = [reader seekToOffset:offset];
                return;
            }
        }
    });
    return result;
}

#pragma mark -

- (id<MCSResourceResponse>)response {
    __block id<MCSResourceResponse> response;
    dispatch_sync(_queue, ^{
        response = _response;
    });
    return response;
}

- (NSUInteger)availableLength {
    __block NSUInteger availableLength;
    dispatch_sync(_queue, ^{
        id<MCSResourceDataReader> currentReader = self.currentReader;
        availableLength = currentReader.range.location + currentReader.availableLength;
    });
    return availableLength;
}
 
- (NSUInteger)offset {
    __block NSUInteger offset = 0;
    dispatch_sync(_queue, ^{
        offset = self->_response.contentRange.location + self->_readLength;
    });
    return offset;
}

- (BOOL)isPrepared {
    __block BOOL isPrepared = NO;
    dispatch_sync(_queue, ^{
        isPrepared = _isPrepared;
    });
    return isPrepared;
}

- (BOOL)isReadingEndOfData {
    __block BOOL isDone = NO;
    dispatch_sync(_queue, ^{
        isDone = self->_readers.lastObject.isDone;
    });
    return isDone;
}

- (BOOL)isClosed {
    __block BOOL isClosed = NO;
    dispatch_sync(_queue, ^{
        isClosed = self->_isClosed;
    });
    return isClosed;
}

- (void)close {
    dispatch_barrier_sync(_queue, ^{
        [self _close];
    });
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
    NSURL *URL = [MCSURLRecognizer.shared URLWithProxyURL:_request.URL];
    for ( MCSResourcePartialContent *content in contents ) {
        NSRange available = NSMakeRange(content.offset, content.length);
        NSRange intersection = NSIntersectionRange(current, available);
        if ( intersection.length != 0 ) {
            // undownloaded part
            NSRange leftRange = NSMakeRange(current.location, intersection.location - current.location);
            if ( leftRange.length != 0 ) {
                MCSVODNetworkDataReader *reader = [self _networkDataReaderWithURL:URL range:leftRange];
                [readers addObject:reader];
            }
            
            // downloaded part
            NSRange matchedRange = NSMakeRange(NSMaxRange(leftRange), intersection.length);
            NSRange fileRange = NSMakeRange(matchedRange.location - content.offset, intersection.length);
            NSString *path = [MCSFileManager getFilePathWithName:content.filename inResource:_resource.name];
            MCSResourceFileDataReader *reader = [MCSResourceFileDataReader.alloc initWithResource:self->_resource range:matchedRange path:path readRange:fileRange delegate:self];
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
        MCSVODNetworkDataReader *reader = [self _networkDataReaderWithURL:URL range:current];
        [readers addObject:reader];
    }
    
    _metaDataReader = nil;
    _readers = readers.copy;
     
    MCSLog(@"%@: <%p>.createSubreaders { range: %@, count: %lu };\n", NSStringFromClass(self.class), self, NSStringFromRange(_request.mcs_range), (unsigned long)_readers.count);

    [self _prepareNextReader];
}

- (void)_prepareNextReader {
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

#pragma mark - MCSVODMetaDataReaderDelegate

- (void)metaDataReader:(MCSVODMetaDataReader *)reader didCompleteWithError:(NSError *_Nullable)error {
    dispatch_barrier_sync(_queue, ^{
        if ( error ) {
            [self _onError:error];
            return;
        }
        
        [self->_resource updateServer:reader.server contentType:reader.contentType totalLength:reader.totalLength pathExtension:reader.pathExtension];
        
        [self _prepare];
    });
}

#pragma mark - MCSResourceDataReaderDelegate

- (void)readerPrepareDidFinish:(id<MCSResourceDataReader>)reader {
    if ( self.isPrepared )
        return;
    
    dispatch_barrier_sync(_queue, ^{
        _isPrepared = YES;
    });
    
    [self.delegate readerPrepareDidFinish:self];
}

- (void)reader:(id<MCSResourceDataReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    [self.delegate reader:self hasAvailableDataWithLength:length];
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

- (MCSVODNetworkDataReader *)_networkDataReaderWithURL:(NSURL *)URL range:(NSRange)range {
    NSMutableURLRequest *request = [_request mcs_requestWithRedirectURL:URL range:range];
    return [MCSVODNetworkDataReader.alloc initWithResource:_resource request:request networkTaskPriority:_networkTaskPriority delegate:self];;
}
@end
