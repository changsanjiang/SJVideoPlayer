//
//  FILEReader.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "FILEReader.h"
#import "FILEAsset.h" 
#import "MCSAssetManager.h" 
#import "MCSAssetFileRead.h"
#import "MCSError.h"
#import "MCSLogger.h" 
#import "FILEContentReader.h"
#import "MCSQueue.h"
#import "MCSResponse.h"
#import "MCSConsts.h"
#import "MCSUtils.h"

static dispatch_queue_t mcs_queue;

@interface FILEReader ()<MCSAssetDataReaderDelegate>
@property (nonatomic, weak, nullable) FILEAsset *asset;
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isClosed;

@property (nonatomic, copy, nullable) NSArray<id<MCSAssetDataReader>> *subreaders;
@property (nonatomic, strong, readonly, nullable) id<MCSAssetDataReader> current;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) NSUInteger readLength;

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic) NSRange range;
@end

@implementation FILEReader
@synthesize readDataDecoder = _readDataDecoder;
@synthesize response = _response;
@synthesize isReadingEndOfData = _isReadingEndOfData;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mcs_queue = dispatch_queue_create("queue.FILEReader", DISPATCH_QUEUE_CONCURRENT);
    });
}

- (instancetype)initWithAsset:(__weak FILEAsset *)asset request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority readDataDecoder:(NSData *(^_Nullable)(NSURLRequest *request, NSUInteger offset, NSData *data))readDataDecoder delegate:(id<MCSAssetReaderDelegate>)delegate {
    self = [super init];
    if ( self ) {
#ifdef DEBUG
        MCSAssetReaderDebugLog(@"%@: <%p>.init { URL: %@, asset: %@, proxyURL: %@, headers: %@ };\n", NSStringFromClass(self.class), self, [MCSURLRecognizer.shared URLWithProxyURL:request.URL], asset, request.URL, request.allHTTPHeaderFields);
#endif

        _asset = asset;
        _request = request;
        _networkTaskPriority = networkTaskPriority;
        _readDataDecoder = readDataDecoder;
        _delegate = delegate;
        _currentIndex = NSNotFound;

        [_asset readwriteRetain];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willRemoveAssetWithNote:) name:MCSAssetWillRemoveAssetNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    if ( !_isClosed ) [self _close];
    [_asset readwriteRelease];
    MCSAssetReaderDebugLog(@"%@: <%p>.dealloc;\n", NSStringFromClass(self.class), self);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { request: %@\n };", NSStringFromClass(self.class), self, _request.mcs_description];
}

- (void)willRemoveAssetWithNote:(NSNotification *)note {
    id<MCSAsset> asset = note.object;
    if ( asset == _asset )  {
        dispatch_barrier_sync(mcs_queue, ^{
            if ( _isClosed )
                return;
            [self _onError:[NSError mcs_errorWithCode:MCSFileError userInfo:@{
                MCSErrorUserInfoObjectKey : _request,
                MCSErrorUserInfoReasonKey : @"资源将要被删除!"
            }]];
        });
    }
}

- (void)prepare {
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSAssetReaderDebugLog(@"%@: <%p>.prepare;\n", NSStringFromClass(self.class), self);
        
        _isCalledPrepare = YES;
        
        [self _prepare];
    });
}

- (NSData *)readDataOfLength:(NSUInteger)length {
    __block NSData *data = nil;
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _isClosed || _isReadingEndOfData )
            return;
        
        id<MCSAssetDataReader> current = self.current;
        if ( !current.isPrepared )
            return;
        
        data = [current readDataOfLength:length];
        NSUInteger readLength = data.length;
        if ( _readDataDecoder != nil )
            data = _readDataDecoder(_request, _subreaders.firstObject.range.location + _readLength, data);
        _readLength += readLength;
        
        if ( current.isDone ) [self _prepareNextReader];
    });
    return data;
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    __block BOOL result = NO;
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _isClosed || !_isPrepared  )
            return;

        for ( NSInteger i = 0 ; i < _subreaders.count ; ++ i ) {
            id<MCSAssetDataReader> reader = _subreaders[i];
            if ( NSLocationInRange(offset - 1, reader.range) ) {
                _currentIndex = i;
                result = [reader seekToOffset:offset];
                if ( reader.isDone ) [self _prepareNextReader];
                return;
            }
        }
    });
    return result;
}

#pragma mark -

- (id<MCSResponse>)response {
    __block id<MCSResponse> response = nil;
    dispatch_sync(mcs_queue, ^{
        response = _response;
    });
    return response;
}
 
- (NSUInteger)availableLength {
    __block NSUInteger availableLength;
    dispatch_sync(mcs_queue, ^{
        id<MCSAssetDataReader> current = self.current;
        availableLength = current.range.location + current.availableLength;
    });
    return availableLength;
}
 
- (NSUInteger)offset {
    __block NSUInteger offset = 0;
    dispatch_sync(mcs_queue, ^{
        offset = _range.location + _readLength;
    });
    return offset;
}

- (BOOL)isPrepared {
    __block BOOL isPrepared = NO;
    dispatch_sync(mcs_queue, ^{
        isPrepared = _isPrepared;
    });
    return isPrepared;
}

- (BOOL)isReadingEndOfData {
    __block BOOL isReadingEndOfData = NO;
    dispatch_sync(mcs_queue, ^{
        isReadingEndOfData = _isReadingEndOfData;
    });
    return isReadingEndOfData;
}

- (BOOL)isClosed {
    __block BOOL isClosed = NO;
    dispatch_sync(mcs_queue, ^{
        isClosed = _isClosed;
    });
    return isClosed;
}

- (void)close {
    dispatch_barrier_sync(mcs_queue, ^{
        [self _close];
    });
}

#pragma mark -

- (void)_prepare {
    // `length`经常变动, 暂时这里排序吧
    __auto_type contents = [_asset.contents sortedArrayUsingComparator:^NSComparisonResult(FILEContent *obj1, FILEContent *obj2) {
        if ( obj1.offset == obj2.offset )
            return obj1.length >= obj2.length ? NSOrderedAscending : NSOrderedDescending;
        return obj1.offset < obj2.offset ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    NSUInteger totalLength = _asset.totalLength;
    if ( totalLength == 0 ) {
        // create single sub reader to load asset total length
        NSURL *URL = [MCSURLRecognizer.shared URLWithProxyURL:_request.URL];
        NSMutableURLRequest *request = [_request mcs_requestWithRedirectURL:URL];
        _subreaders = @[
            [FILEContentReader.alloc initWithAsset:_asset request:request networkTaskPriority:_networkTaskPriority delegate:self]
        ];
    }
    else {
        MCSRequestContentRange requestRange = MCSGetRequestContentRange(_request.mcs_headers);
        NSRange current = NSMakeRange(0, 0);
        // 200
        if      ( requestRange.start == NSNotFound && requestRange.end == NSNotFound ) {
            current = NSMakeRange(0, totalLength);
        }
        // bytes=100-500
        else if ( requestRange.start != NSNotFound && requestRange.end != NSNotFound ) {
            NSUInteger location = requestRange.start;
            NSUInteger length = totalLength > requestRange.end ? ((requestRange.end + 1) - location) : 0;
            current = NSMakeRange(location, length);
        }
        // bytes=-500
        else if ( requestRange.start == NSNotFound && requestRange.end != NSNotFound ) {
            NSUInteger length = totalLength > requestRange.end ? (requestRange.end + 1) : 0;
            NSUInteger location = totalLength - length;
            current = NSMakeRange(location, length);
        }
        // bytes=500-
        else if ( requestRange.start != NSNotFound && requestRange.end == NSNotFound ) {
            NSUInteger location = requestRange.start;
            NSUInteger length = totalLength > location ? (totalLength - location) : 0;
            current = NSMakeRange(location, length);
        }

        if ( current.length == 0 ) {
            [self _onError:[NSError mcs_errorWithCode:MCSInvalidRequestError userInfo:@{
                MCSErrorUserInfoObjectKey : _request,
                MCSErrorUserInfoReasonKey : @"请求range参数错误!"
            }]];
            return;
        }
        
        _range = current;
        
        NSMutableArray<id<MCSAssetDataReader>> *subreaders = NSMutableArray.array;
        NSURL *URL = [MCSURLRecognizer.shared URLWithProxyURL:_request.URL];
        for ( FILEContent *content in contents ) {
            NSRange available = NSMakeRange(content.offset, content.length);
            NSRange intersection = NSIntersectionRange(current, available);
            if ( intersection.length != 0 ) {
                // undownloaded part
                NSRange leftRange = NSMakeRange(current.location, intersection.location - current.location);
                if ( leftRange.length != 0 ) {
                    FILEContentReader *reader = [self _networkDataReaderWithURL:URL range:leftRange];
                    [subreaders addObject:reader];
                }
                
                // downloaded part
                NSRange matchedRange = NSMakeRange(NSMaxRange(leftRange), intersection.length);
                NSRange fileRange = NSMakeRange(matchedRange.location - content.offset, intersection.length);
                NSString *path = [_asset contentFilePathForFilename:content.filename];
                MCSAssetFileRead *reader = [MCSAssetFileRead.alloc initWithAsset:_asset inRange:matchedRange reference:content path:path readRange:fileRange delegate:self];
                [subreaders addObject:reader];
                
                // next part
                current = NSMakeRange(NSMaxRange(intersection), NSMaxRange(_range) - NSMaxRange(intersection));
            }
            
            if ( current.length == 0 || available.location > NSMaxRange(current) ) break;
        }
        
        if ( current.length != 0 ) {
            // undownloaded part
            FILEContentReader *reader = [self _networkDataReaderWithURL:URL range:current];
            [subreaders addObject:reader];
        }
         
        _subreaders = subreaders.copy;
    }
     
    MCSAssetReaderDebugLog(@"%@: <%p>.createSubreaders { count: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_subreaders.count);

    [self _prepareNextReader];
}

- (void)_prepareNextReader {
    if ( self.current == _subreaders.lastObject ) {
        _isReadingEndOfData = YES;
        MCSAssetReaderDebugLog(@"%@: <%p>.done;\n", NSStringFromClass(self.class), self);
        [self _close];
        return;
    }
    
    if ( _currentIndex == NSNotFound )
        _currentIndex = 0;
    else
        _currentIndex += 1;
    
    MCSAssetReaderDebugLog(@"%@: <%p>.subreader.prepare { index: %ld, sub: %@, count: %lu };\n", NSStringFromClass(self.class), self, (long)_currentIndex, self.current, (unsigned long)_subreaders.count);

    [self.current prepare];
}

- (nullable id<MCSAssetDataReader>)current {
    if ( _currentIndex != NSNotFound && _currentIndex < _subreaders.count ) {
        return _subreaders[_currentIndex];
    }
    return nil;
}

- (void)_close {
    if ( _isClosed )
        return;
    
    for ( id<MCSAssetDataReader> reader in _subreaders ) {
        [reader close];
    }
    
    _subreaders = nil;
    _isClosed = YES;

    MCSAssetReaderDebugLog(@"%@: <%p>.close;\n", NSStringFromClass(self.class), self);
}

#pragma mark - MCSAssetDataReaderDelegate

- (void)readerPrepareDidFinish:(__kindof id<MCSAssetDataReader>)reader {
    __block BOOL isChanged = NO;
    dispatch_barrier_sync(mcs_queue, ^{
        if ( !_isPrepared || !_isClosed ) {
            NSRange range = _range;
            if ( _subreaders.count == 1 ) range = reader.range;
            _response = [MCSResponse.alloc initWithTotalLength:_asset.totalLength range:range contentType:_asset.contentType];
            _isPrepared = YES;
            isChanged = YES;
        }
    });
    
    if ( isChanged )
        [_delegate reader:self prepareDidFinish:self.response];
}

- (void)reader:(id<MCSAssetDataReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    [_delegate reader:self hasAvailableDataWithLength:length];
}

- (void)reader:(id<MCSAssetDataReader>)reader anErrorOccurred:(NSError *)error {
    dispatch_barrier_sync(mcs_queue, ^{
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
