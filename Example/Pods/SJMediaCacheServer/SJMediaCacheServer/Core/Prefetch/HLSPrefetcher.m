//
//  HLSPrefetcher.m
//  CocoaAsyncSocket
//
//  Created by BlueDancer on 2020/6/11.
//

#import "HLSPrefetcher.h"
#import "MCSLogger.h"
#import "MCSAssetManager.h"
#import "NSURLRequest+MCS.h"  
#import "HLSAsset.h" 
#import "MCSQueue.h"
#import "MCSUtils.h"
#import "MCSError.h"

@interface HLSURIItemProvider : NSObject
@property (nonatomic, weak, nullable) HLSAsset *asset;
@property (nonatomic, readonly, nullable) id<HLSURIItem> next;
@property (nonatomic, readonly) NSUInteger curTsIndex;
@property (nonatomic, readonly) NSUInteger curFragmentIndex;
- (BOOL)isVariantItem:(id<HLSURIItem>)item;
- (nullable NSArray<id<HLSURIItem>> *)renditionsItemsForVariantItem:(id<HLSURIItem>)item;
@end

@implementation HLSURIItemProvider

- (void)dealloc {
    [_asset readwriteRelease];
}

- (void)setAsset:(nullable HLSAsset *)asset {
    if ( asset != _asset ) {
        [asset readwriteRetain];
        [_asset readwriteRelease];
        
        _asset = asset;
        _curFragmentIndex = NSNotFound;
        _curTsIndex = NSNotFound;
    }
}

- (nullable id<HLSURIItem>)next {
    if ( _asset == nil )
        return nil;

    NSUInteger nextIndex = NSNotFound;
    id<HLSURIItem> item = nil;
    HLSAssetParser *parser = _asset.parser;
    while ( YES ) {
        nextIndex = (_curFragmentIndex == NSNotFound) ? 0 : (_curFragmentIndex + 1);
        item = [parser itemAtIndex:nextIndex];
        if ( item.type == MCSDataTypeHLSPlaylist && ![parser isVariantItem:item] )
            continue;
        if ( item.type == MCSDataTypeHLSTs )
            _curTsIndex = (_curTsIndex == NSNotFound) ? 0 : (_curTsIndex + 1);
        _curFragmentIndex = nextIndex;
        break;
    }
    return item;
}

- (BOOL)isVariantItem:(id<HLSURIItem>)item {
    return [_asset.parser isVariantItem:item];
}

- (nullable NSArray<id<HLSURIItem>> *)renditionsItemsForVariantItem:(id<HLSURIItem>)item {
    return [_asset.parser renditionsItemsForVariantItem:item];
}
@end

@interface HLSPrefetcher ()<MCSAssetReaderDelegate> {
    id<MCSAssetReader>_Nullable _reader;
    id<HLSURIItem> _Nullable _cur;
    NSArray<id<HLSURIItem>> *_Nullable _renditionsItems;
    HLSURIItemProvider *_itemProvider;
    NSUInteger _TsLoadedLength;
    NSUInteger _TsResponsedSize;
    float _TsProgress;
    float _renditionsProgress;
    NSURL *_URL;
    NSUInteger _preloadSize;
    NSUInteger _numberOfPreloadedFiles;
    BOOL _isCalledPrepare;
    BOOL _isClosed;
    BOOL _isDone;
}
@property (nonatomic) float renditionsProgress;
@end

@interface HLSRenditionsPrefetcher : NSObject<MCSPrefetcherDelegate>
- (instancetype)initWithURL:(NSURL *)URL numberOfPreloadedFiles:(NSUInteger)num progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock;
@property (nonatomic, readonly) float progress;
- (void)prepare;
- (void)close;
@end

@implementation HLSRenditionsPrefetcher {
    HLSPrefetcher *_prefetcher;
    void(^_Nullable _progressBlock)(float progress);
    void(^_Nullable _completionBlock)(NSError *_Nullable error);
}
- (instancetype)initWithURL:(NSURL *)URL numberOfPreloadedFiles:(NSUInteger)num progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock {
    self = [super init];
    if ( self ) {
        _progressBlock = progressBlock;
        _completionBlock = completionBlock;
        _prefetcher = [HLSPrefetcher.alloc initWithURL:URL numberOfPreloadedFiles:num delegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (float)progress {
    return _prefetcher.progress;
}

- (void)prepare {
    [_prefetcher prepare];
}

- (void)close {
    [_prefetcher close];
}

#pragma mark - MCSPrefetcherDelegate

- (void)prefetcher:(id<MCSPrefetcher>)prefetcher progressDidChange:(float)progress {
    if ( _progressBlock != nil ) _progressBlock(progress);
}

- (void)prefetcher:(id<MCSPrefetcher>)prefetcher didCompleteWithError:(NSError *_Nullable)error {
    if ( _completionBlock != nil ) _completionBlock(error);
}
@end

@implementation HLSPrefetcher
@synthesize delegate = _delegate;
@synthesize delegateQueue = _delegateQueue;

- (instancetype)initWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes delegate:(nullable id<MCSPrefetcherDelegate>)delegate delegateQueue:(nonnull dispatch_queue_t)delegateQueue {
    self = [super init];
    if ( self ) {
        _URL = URL;
        _preloadSize = bytes;
        _delegate = delegate;
        _delegateQueue = delegateQueue;
        _itemProvider = HLSURIItemProvider.alloc.init;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL numberOfPreloadedFiles:(NSUInteger)num delegate:(nullable id<MCSPrefetcherDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    self = [super init];
    if ( self ) {
        _URL = URL;
        _numberOfPreloadedFiles = num;
        _delegate = delegate;
        _delegateQueue = delegateQueue;
        _itemProvider = HLSURIItemProvider.alloc.init;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL delegate:(nullable id<MCSPrefetcherDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    return [self initWithURL:URL numberOfPreloadedFiles:NSNotFound delegate:delegate delegateQueue:delegateQueue];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { preloadSize: %lu, numberOfPreloadedFiles: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize, (unsigned long)_numberOfPreloadedFiles];
}

- (void)dealloc {
    MCSPrefetcherDebugLog(@"%@: <%p>.dealloc;\n", NSStringFromClass(self.class), self);
}

- (void)prepare {
    mcs_queue_async(^{
        if ( self->_isClosed || self->_isCalledPrepare )
            return;

        MCSPrefetcherDebugLog(@"%@: <%p>.prepare { preloadSize: %lu, numberOfPreloadedFiles: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)self->_preloadSize, (unsigned long)self->_numberOfPreloadedFiles);
        
        self->_isCalledPrepare = YES;

        NSURL *proxyURL = [MCSURL.shared proxyURLWithURL:self->_URL];
        NSURLRequest *proxyRequest = [NSURLRequest.alloc initWithURL:proxyURL];
        self->_reader = [MCSAssetManager.shared readerWithRequest:proxyRequest networkTaskPriority:0 delegate:self];
        [self->_reader prepare];
    });
}

- (void)close {
    mcs_queue_sync(^{
        [self _close];
    });
}

- (float)progress {
    __block float progress = 0;
    mcs_queue_sync(^{
        progress = (_TsProgress + _renditionsProgress) / (1 + (_renditionsItems.count != 0 ? 1 : 0));
    });
    return progress;
}
 
- (void)setRenditionsProgress:(float)renditionsProgress {
    mcs_queue_sync(^{
        _renditionsProgress = renditionsProgress;
    });
}

- (float)renditionsProgress {
    __block float progress = 0;
    mcs_queue_sync(^{
        progress = _renditionsProgress;
    });
    return progress;
}

#pragma mark - MCSAssetReaderDelegate

- (void)reader:(id<MCSAssetReader>)reader didReceiveResponse:(id<MCSResponse>)response {
    mcs_queue_sync(^{
        if ( _cur.type == MCSDataTypeHLSTs ) {
            _TsResponsedSize += response.range.length;
        }
    });
}

- (void)reader:(id<MCSAssetReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    mcs_queue_async(^{
        [self _reader:reader hasAvailableDataWithLength:length];
    });
}
  
- (void)reader:(id<MCSAssetReader>)reader didAbortWithError:(nullable NSError *)error {
    mcs_queue_sync(^{
        if ( _isClosed )
            return;
        [self _didCompleteWithError:error ?: [NSError mcs_errorWithCode:MCSAbortError userInfo:@{
            MCSErrorUserInfoObjectKey : self,
            MCSErrorUserInfoReasonKey : @"预加载已被终止!"
        }]];
    });
}

#pragma mark -

- (void)_prepareNextFragment {
    // update asset
    _itemProvider.asset = _reader.asset;
    
    // next item
    _cur = _itemProvider.next;
    
    // All items loaded
    if ( _cur == nil ) {
        _TsProgress = 1.0;
        [self _prefetchRenditionsItems];
        return;
    }
    
    if ( [_itemProvider isVariantItem:_cur] ) {
        _renditionsItems = [_itemProvider renditionsItemsForVariantItem:_cur];
    }
    
    // prepare for reader
    NSURL *proxyURL = [MCSURL.shared HLS_proxyURLWithProxyURI:_cur.URI];
    NSURLRequest *request = [NSURLRequest mcs_requestWithURL:proxyURL headers:_cur.HTTPAdditionalHeaders];
    _reader = [MCSAssetManager.shared readerWithRequest:request networkTaskPriority:0 delegate:self];
    [_reader prepare];
    
    MCSPrefetcherDebugLog(@"%@: <%p>.prepareFragment { index:%lu, TsIndex: %lu, request: %@ };\n", NSStringFromClass(self.class), self, (unsigned long)_itemProvider.curFragmentIndex, _itemProvider.curTsIndex, request);
}

- (void)_prefetchRenditionsItems {
    if ( _renditionsItems.count == 0 ) {
        [self _didCompleteWithError:nil];
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    NSMutableArray<HLSRenditionsPrefetcher *> *prefetchers = [NSMutableArray arrayWithCapacity:_renditionsItems.count];
    __weak typeof(self) _self = self;
    __weak NSMutableArray<HLSRenditionsPrefetcher *> *weakPrefetchers = prefetchers;
    __block NSError *error = nil;
    for ( id<HLSURIItem> item in _renditionsItems ) {
        dispatch_group_enter(group);
        NSURL *URL = [MCSURL.shared HLS_URLWithProxyURI:item.URI];
        HLSRenditionsPrefetcher *prefetcher = [HLSRenditionsPrefetcher.alloc initWithURL:URL numberOfPreloadedFiles:_itemProvider.curTsIndex + 1 progress:^(float progress) {
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
            float allProgress = 0;
            for ( HLSRenditionsPrefetcher *prefetcher in weakPrefetchers ) {
                allProgress += prefetcher.progress;
            }
            self.renditionsProgress = allProgress;
            if ( self.delegate != nil ) {
                dispatch_async(self.delegateQueue, ^{
                    CGFloat progress = self.progress;
                    MCSPrefetcherDebugLog(@"%@: <%p>.preload { progress: %f };\n", NSStringFromClass(self.class), self, progress);

                    [self.delegate prefetcher:self progressDidChange:progress];
                });
            }
        } completed:^(NSError * _Nullable err) {
            if ( err != nil && error == nil ) {
                error = err;
                for ( HLSRenditionsPrefetcher *cur in prefetchers ) {
                    [cur close];
                }
            }
            dispatch_group_leave(group);
        }];
        [prefetcher prepare];
        [prefetchers addObject:prefetcher];
    }
    
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        mcs_queue_sync(^{
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
            [self _didCompleteWithError:error];
        });
    });
}

- (void)_reader:(id<MCSAssetReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    if ( _isClosed ) {
        [reader abortWithError:nil];
        return;
    }
    
    if ( [reader seekToOffset:reader.offset + length] ) {
        HLSAsset *asset = reader.asset;
        CGFloat progress = 0;
        
        // `Ts reader`
        if ( _cur.type == MCSDataTypeHLSTs ) {
            _TsLoadedLength += length;

            NSInteger totalLength = reader.response.range.length;
            // size mode
            if ( _preloadSize != 0 ) {
                NSUInteger all = _preloadSize > _TsResponsedSize ? _preloadSize : _TsResponsedSize;
                progress = _TsLoadedLength * 1.0 / all;
            }
            // num mode
            else {
                CGFloat curProgress = (reader.offset - reader.response.range.location) * 1.0 / totalLength;
                NSUInteger all = asset.tsCount > _numberOfPreloadedFiles ? _numberOfPreloadedFiles : asset.tsCount;
                progress = (_itemProvider.curTsIndex + curProgress) / all;
            }

            if ( progress > 1 ) progress = 1;
            _TsProgress = progress;
        }
        
        if ( _delegate != nil ) {
            float progress = (_TsProgress + _renditionsProgress) / (1 + (_renditionsItems.count != 0 ? 1 : 0));
            dispatch_async(_delegateQueue, ^{
                MCSPrefetcherDebugLog(@"%@: <%p>.preload { progress: %f };\n", NSStringFromClass(self.class), self, progress);

                [self.delegate prefetcher:self progressDidChange:progress];
            });
        }
        
        if ( reader.status == MCSReaderStatusFinished ) {
            _TsProgress == 1 ? [self _prefetchRenditionsItems] : [self _prepareNextFragment];
        }
    }
}

- (void)_didCompleteWithError:(nullable NSError *)error {
    if ( _isClosed )
        return;
    
    _isDone = (error == nil);
    
#ifdef DEBUG
    if ( _isDone )
        MCSPrefetcherDebugLog(@"%@: <%p>.done;\n", NSStringFromClass(self.class), self);
    else
        MCSPrefetcherErrorLog(@"%@:  <%p>.error { error: %@ };\n", NSStringFromClass(self.class), self, error);
#endif
    
    [self _close];
    
    if ( _delegate != nil ) {
        dispatch_async(_delegateQueue, ^{
            [self.delegate prefetcher:self didCompleteWithError:error];
        });
    }
}

- (void)_close {
    if ( _isClosed )
        return;
    
    _isClosed = YES;

    [_reader abortWithError:nil];
    _reader = nil;
    
    
    _reader = nil;
    MCSPrefetcherDebugLog(@"%@: <%p>.close;\n", NSStringFromClass(self.class), self);
}
@end
