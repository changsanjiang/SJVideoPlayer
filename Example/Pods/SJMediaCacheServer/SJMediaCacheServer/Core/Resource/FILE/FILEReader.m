//
//  FILEReader.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "FILEReader.h"
#import "MCSAssetContent.h"
#import "MCSAssetManager.h"
#import "MCSFileManager.h"
#import "MCSAssetFileRead.h"
#import "MCSError.h"
#import "MCSLogger.h"
#import "FILEAsset.h"
#import "MCSAssetSubclass.h"
#import "FILEContentReader.h"
#import "MCSQueue.h"
#import "MCSResponse.h"

@interface FILEReader ()<MCSAssetDataReaderDelegate>
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isClosed;

@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, strong, readonly, nullable) id<MCSAssetDataReader> currentReader;
@property (nonatomic) NSUInteger readLength;

@property (nonatomic, weak, nullable) FILEAsset *asset;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, copy, nullable) NSArray<id<MCSAssetDataReader>> *readers;
@property (nonatomic, strong) NSMutableArray<MCSAssetContent *> *readWriteContents;

@property (nonatomic) NSRange range;
@end

@implementation FILEReader
@synthesize readDataDecoder = _readDataDecoder;
@synthesize response = _response;

- (instancetype)initWithAsset:(__weak FILEAsset *)asset request:(NSURLRequest *)request {
    self = [super init];
    if ( self ) {
        _networkTaskPriority = 1.0;
        
        _readWriteContents = NSMutableArray.array;
        _currentIndex = NSNotFound;

        _asset = asset;
        _request = request;
        
        [_asset readWrite_retain];
        [MCSAssetManager.shared reader:self willReadAsset:_asset];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didRemoveAsset:) name:MCSAssetManagerDidRemoveAssetNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(userCancelledReading:) name:MCSAssetManagerUserCancelledReadingNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [_asset readWrite_release];
    [MCSAssetManager.shared reader:self didEndReadAsset:_asset];
    if ( !_isClosed ) [self _close];
    MCSAssetReaderDebugLog(@"%@: <%p>.dealloc;\n", NSStringFromClass(self.class), self);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { request: %@\n };", NSStringFromClass(self.class), self, _request.mcs_description];
}

- (void)didRemoveAsset:(NSNotification *)note {
    MCSAsset *asset = note.userInfo[MCSAssetManagerUserInfoAssetKey];
    if ( asset == _asset )  {
        dispatch_barrier_sync(MCSReaderQueue(), ^{
            if ( _isClosed )
                return;
            [self _onError:[NSError mcs_errorWithCode:MCSFileError userInfo:@{
                MCSErrorUserInfoObjectKey : _request,
                MCSErrorUserInfoReasonKey : @"资源已被删除!"
            }]];
        });
    }
}

- (void)userCancelledReading:(NSNotification *)note {
    MCSAsset *asset = note.userInfo[MCSAssetManagerUserInfoAssetKey];
    if ( asset == _asset )  {
        dispatch_barrier_sync(MCSReaderQueue(), ^{
            if ( _isClosed )
                return;
            [self _onError:[NSError mcs_errorWithCode:MCSUserCancelledError userInfo:@{
                MCSErrorUserInfoObjectKey : _request,
                MCSErrorUserInfoReasonKey : @"读取操作已被取消!"
            }]];
        });
    }
}

- (void)prepare {
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSAssetReaderDebugLog(@"%@: <%p>.prepare { assetName: %@, request: %@ };\n", NSStringFromClass(self.class), self, _asset.name, _request.mcs_description);
        
        _isCalledPrepare = YES;
        
        [self _prepare];
    });
}

- (NSData *)readDataOfLength:(NSUInteger)length {
    __block NSData *data = nil;
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        if ( _isClosed )
            return;
        
        id<MCSAssetDataReader> currentReader = self.currentReader;
        if ( !currentReader.isPrepared )
            return;
        
        data = [currentReader readDataOfLength:length];
        NSUInteger readLength = data.length;
        if ( _readDataDecoder != nil )
            data = _readDataDecoder(_request, _readers.firstObject.range.location + _readLength, data);
        _readLength += readLength;
        
        if ( currentReader.isDone ) {
            currentReader != _readers.lastObject ? [self _prepareNextReader] : [self _close];
#ifdef DEBUG
            if ( currentReader == _readers.lastObject ) {
                MCSAssetReaderDebugLog(@"%@: <%p>.done;\n", NSStringFromClass(self.class), self);
            }
#endif
        }
    });
    return data;
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    __block BOOL result = NO;
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        if ( _isClosed || !_isPrepared  )
            return;

        for ( id<MCSAssetDataReader> reader in _readers ) {
            if ( NSLocationInRange(offset - 1, reader.range) ) {
                result = [reader seekToOffset:offset];
                return;
            }
        }
    });
    return result;
}

#pragma mark -

- (id<MCSResponse>)response {
    __block id<MCSResponse> response = nil;
    dispatch_sync(MCSReaderQueue(), ^{
        response = _response;
    });
    return response;
}
 
- (NSUInteger)availableLength {
    __block NSUInteger availableLength;
    dispatch_sync(MCSReaderQueue(), ^{
        id<MCSAssetDataReader> currentReader = self.currentReader;
        availableLength = currentReader.range.location + currentReader.availableLength;
    });
    return availableLength;
}
 
- (NSUInteger)offset {
    __block NSUInteger offset = 0;
    dispatch_sync(MCSReaderQueue(), ^{
        offset = _readers.firstObject.range.location + _readLength;
    });
    return offset;
}

- (BOOL)isPrepared {
    __block BOOL isPrepared = NO;
    dispatch_sync(MCSReaderQueue(), ^{
        isPrepared = _isPrepared;
    });
    return isPrepared;
}

- (BOOL)isReadingEndOfData {
    __block BOOL isDone = NO;
    dispatch_sync(MCSReaderQueue(), ^{
        isDone = _readers.lastObject.isDone;
    });
    return isDone;
}

- (BOOL)isClosed {
    __block BOOL isClosed = NO;
    dispatch_sync(MCSReaderQueue(), ^{
        isClosed = _isClosed;
    });
    return isClosed;
}

- (void)close {
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        [self _close];
    });
}

#pragma mark -

- (void)_prepare {
    NSUInteger totalLength = _asset.totalLength ?: NSUIntegerMax;

    // `length`经常变动, 暂时这里排序吧
    __auto_type contents = [_asset.contents sortedArrayUsingComparator:^NSComparisonResult(MCSAssetContent *obj1, MCSAssetContent *obj2) {
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
    
    if ( current.location >= totalLength ) {
        current.location = totalLength - 1;
    }
    
    if ( NSMaxRange(current) >= totalLength ) {
        current.length = totalLength - current.location;
    }
    
    if ( current.length == 0 ) {
        [self _onError:[NSError mcs_errorWithCode:MCSInvalidRequestError userInfo:@{
            MCSErrorUserInfoObjectKey : _request,
            MCSErrorUserInfoReasonKey : @"请求range参数错误!"
        }]];
        return;
    }
    
    _range = current;
    
    NSMutableArray<id<MCSAssetDataReader>> *readers = NSMutableArray.array;
    NSURL *URL = [MCSURLRecognizer.shared URLWithProxyURL:_request.URL];
    for ( MCSAssetContent *content in contents ) {
        NSRange available = NSMakeRange(content.offset, content.length);
        NSRange intersection = NSIntersectionRange(current, available);
        if ( intersection.length != 0 ) {
            // undownloaded part
            NSRange leftRange = NSMakeRange(current.location, intersection.location - current.location);
            if ( leftRange.length != 0 ) {
                FILEContentReader *reader = [self _networkDataReaderWithURL:URL range:leftRange];
                [readers addObject:reader];
            }
            
            // downloaded part
            NSRange matchedRange = NSMakeRange(NSMaxRange(leftRange), intersection.length);
            NSRange fileRange = NSMakeRange(matchedRange.location - content.offset, intersection.length);
            NSString *path = [MCSFileManager getFilePathWithName:content.filename inAsset:_asset.name];
            MCSAssetFileRead *reader = [MCSAssetFileRead.alloc initWithAsset:_asset inRange:matchedRange path:path readRange:fileRange delegate:self];
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
        FILEContentReader *reader = [self _networkDataReaderWithURL:URL range:current];
        [readers addObject:reader];
    }
     
    _readers = readers.copy;
     
    MCSAssetReaderDebugLog(@"%@: <%p>.createSubreaders { range: %@, count: %lu };\n", NSStringFromClass(self.class), self, NSStringFromRange(_range), (unsigned long)_readers.count);

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

- (nullable id<MCSAssetDataReader>)currentReader {
    if ( _currentIndex != NSNotFound && _currentIndex < _readers.count ) {
        return _readers[_currentIndex];
    }
    return nil;
}

- (void)_close {
    if ( _isClosed )
        return;
    
    for ( id<MCSAssetDataReader> reader in _readers ) {
        [reader close];
    }
    
    for ( MCSAssetContent *content in _readWriteContents ) {
        [content readWrite_release];
    }
     
    _isClosed = YES;
    MCSAssetReaderDebugLog(@"%@: <%p>.close;\n", NSStringFromClass(self.class), self);
}

#pragma mark - MCSAssetDataReaderDelegate

- (void)readerPrepareDidFinish:(__kindof id<MCSAssetDataReader>)reader {
    if ( self.isPrepared || self.isClosed )
        return;
    
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        NSRange range = _range;
        if ( _readers.count == 1 ) range = reader.range;
        _response = [MCSResponse.alloc initWithTotalLength:_asset.totalLength range:range];
        _isPrepared = YES;
    });
    
    [_delegate reader:self prepareDidFinish:self.response];
}

- (void)reader:(id<MCSAssetDataReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    [_delegate reader:self hasAvailableDataWithLength:length];
}

- (void)reader:(id<MCSAssetDataReader>)reader anErrorOccurred:(NSError *)error {
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        [self _onError:error];
    });
}

- (void)_onError:(NSError *)error {
    if ( _isClosed )
        return;
    
    [self _close];
    
    MCSAssetReaderErrorLog(@"%@: <%p>.error { error: %@ };\n", NSStringFromClass(self.class), self, error);
    
    dispatch_async(MCSDelegateQueue(), ^{
        [self->_delegate reader:self anErrorOccurred:error];
    });
}

- (FILEContentReader *)_networkDataReaderWithURL:(NSURL *)URL range:(NSRange)range {
    NSMutableURLRequest *request = [_request mcs_requestWithRedirectURL:URL range:range];
    return [FILEContentReader.alloc initWithAsset:_asset request:request networkTaskPriority:_networkTaskPriority delegate:self];
}
@end
