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
#import "MCSResourceNetworkDataReader.h"
#import "MCSUtils.h"
#import "MCSError.h"
#import "MCSLogger.h"
#import "MCSVODResource.h"
#import "MCSResourceSubclass.h"

@interface MCSVODReader ()<NSLocking, MCSResourceDataReaderDelegate> {
    dispatch_semaphore_t _semaphore;
}

@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isClosed;

@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, strong, readonly, nullable) id<MCSResourceDataReader> currentReader;
@property (nonatomic, strong, nullable) MCSResourceNetworkDataReader *tmpReader; // 用于获取资源contentLength, contentType等信息
@property (nonatomic) NSUInteger offset;

@property (nonatomic, weak, nullable) MCSVODResource *resource;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, copy, nullable) NSArray<id<MCSResourceDataReader>> *readers;
@property (nonatomic, strong, nullable) id<MCSResourceResponse> response;

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

        [_resource readWrite_retain];
        [MCSResourceManager.shared reader:self willReadResource:_resource];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willRemoveResource:) name:MCSResourceManagerWillRemoveResourceNotification object:nil];
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

- (void)willRemoveResource:(NSNotification *)note {
    MCSResource *resource = note.userInfo[MCSResourceManagerUserInfoResourceKey];
    if ( resource == _resource && !self.isClosed )  {
        [self lock];
        [self _close];
        [self unlock];
        
        [_delegate reader:self anErrorOccurred:[NSError mcs_errorForRemovedResource:self.request.URL]];
    }
}

- (void)prepare {
    [self lock];
    @try {
        if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSLog(@"%@: <%p>.prepare { range: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_request.mcs_range));
        
        _isCalledPrepare = YES;
        
        if ( _resource.totalLength == 0 || _resource.contentType.length == 0 ) {
            _tmpReader = [MCSResourceNetworkDataReader.alloc initWithURL:_request.URL requestHeaders:_request.mcs_headers range:NSMakeRange(0, 2)  networkTaskPriority:_networkTaskPriority];
            _tmpReader.delegate = self;
            
            MCSLog(@"%@: <%p>.createTmpReader: <%p>;\n", NSStringFromClass(self.class), self, _tmpReader);

            [_tmpReader prepare];
        }
        else {
            [self _prepare];
        }
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSData *)readDataOfLength:(NSUInteger)length {
    [self lock];
    @try {
        if ( _isClosed || _currentIndex == NSNotFound )
            return nil;
        
        NSData *data = [self.currentReader readDataOfLength:length];
        if ( _readDataDecoder != nil ) data = _readDataDecoder(_request, _offset, data);
        _offset += data.length;
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
        return _offset + _request.mcs_range.location;
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
    @try {
        [self _close];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
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
                MCSResourceNetworkDataReader *reader = [MCSResourceNetworkDataReader.alloc initWithURL:_request.URL requestHeaders:_request.mcs_headers range:leftRange networkTaskPriority:_networkTaskPriority];
                reader.delegate = self;
                [readers addObject:reader];
            }
            
            // downloaded part
            NSRange matchedRange = NSMakeRange(NSMaxRange(leftRange), intersection.length);
            NSRange fileRange = NSMakeRange(matchedRange.location - content.offset, intersection.length);
            NSString *path = [MCSFileManager getFilePathWithName:content.name inResource:_resource.name];
            MCSResourceFileDataReader *reader = [MCSResourceFileDataReader.alloc initWithRange:matchedRange path:path readRange:fileRange];
            reader.delegate = self;
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
        MCSResourceNetworkDataReader *reader = [MCSResourceNetworkDataReader.alloc initWithURL:_request.URL requestHeaders:_request.mcs_headers range:current  networkTaskPriority:_networkTaskPriority];
        reader.delegate = self;
        [readers addObject:reader];
    }
    
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
    
    _isClosed = YES;
    for ( id<MCSResourceDataReader> reader in _readers ) {
        [reader close];
    }
    
    for ( MCSResourcePartialContent *content in _readWriteContents ) {
        [content readWrite_release];
    }
    
    MCSLog(@"%@: <%p>.close { range: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_request.mcs_range));
}

#pragma mark -

- (void)lock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_semaphore);
}

#pragma mark - MCSResourceNetworkDataReaderDelegate

- (MCSResourcePartialContent *)newPartialContentForReader:(MCSResourceNetworkDataReader *)reader {
    MCSResourcePartialContent *content = [_resource createContentWithOffset:reader.range.location];
    [content readWrite_retain];
    
    [self lock];
    [_readWriteContents addObject:content];
    [self unlock];
    return content;
}

- (NSString *)writePathOfPartialContent:(MCSResourcePartialContent *)content {
    return [_resource filePathOfContent:content];
}

#pragma mark - MCSResourceDataReaderDelegate

- (void)readerPrepareDidFinish:(id<MCSResourceDataReader>)reader {
    if ( self.isPrepared )
        return;
    
    [self lock];
    @try {
        if      ( _response != nil ) {
            _isPrepared = YES;
        }
        else if ( reader == _tmpReader ) {
            // update contentType & totalLength & server for `resource`
            [_resource updateServer:MCSGetResponseServer(_tmpReader.response) contentType:MCSGetResponseContentType(_tmpReader.response) totalLength:MCSGetResponseContentRange(_tmpReader.response).totalLength pathExtension:_tmpReader.response.suggestedFilename.pathExtension];

            // clean
            [_tmpReader close];
            _tmpReader = nil;
            
            // prepare
            [self _prepare];
        }
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
    
    [_delegate readerPrepareDidFinish:self];
}

- (void)readerHasAvailableData:(id<MCSResourceDataReader>)reader {
    [_delegate readerHasAvailableData:self];
}

- (void)reader:(id<MCSResourceDataReader>)reader anErrorOccurred:(NSError *)error {
    [_delegate reader:self anErrorOccurred:error];
}
@end
