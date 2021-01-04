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
#import "HLSContentTSReader.h"
#import "HLSContentIndexReader.h"
#import "MCSQueue.h"

static dispatch_queue_t mcs_queue;

@interface HLSPrefetcher ()<MCSAssetReaderDelegate>
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isDone;
 
@property (nonatomic, strong, nullable) id<MCSAssetReader> reader;
@property (nonatomic) NSUInteger loadedLength;
@property (nonatomic) float progress;

@property (nonatomic, weak, nullable) HLSAsset *asset;
@property (nonatomic) NSUInteger fragmentIndex;

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic) NSUInteger preloadSize;
@property (nonatomic) NSUInteger numberOfPreloadFiles;
@end

@implementation HLSPrefetcher
@synthesize delegate = _delegate;
@synthesize delegateQueue = _delegateQueue;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mcs_queue = dispatch_queue_create("queue.HLSPrefetcher", DISPATCH_QUEUE_CONCURRENT);
    });
}

- (instancetype)initWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes delegate:(nullable id<MCSPrefetcherDelegate>)delegate delegateQueue:(nonnull dispatch_queue_t)delegateQueue {
    self = [super init];
    if ( self ) {
        _URL = URL;
        _preloadSize = bytes;
        _delegate = delegate;
        _delegateQueue = delegateQueue;
        _fragmentIndex = NSNotFound;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL numberOfPreloadFiles:(NSUInteger)num delegate:(nullable id<MCSPrefetcherDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    self = [super init];
    if ( self ) {
        _URL = URL;
        _numberOfPreloadFiles = num;
        _delegate = delegate;
        _delegateQueue = delegateQueue;
        _fragmentIndex = NSNotFound;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL delegate:(nullable id<MCSPrefetcherDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    return [self initWithURL:URL numberOfPreloadFiles:NSUIntegerMax delegate:delegate delegateQueue:delegateQueue];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { preloadSize: %lu, numberOfPreloadFiles: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize, (unsigned long)_numberOfPreloadFiles];
}

- (void)dealloc {
    MCSPrefetcherDebugLog(@"%@: <%p>.dealloc;\n", NSStringFromClass(self.class), self);
}

- (void)prepare {
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _isClosed || _isCalledPrepare )
            return;

        MCSPrefetcherDebugLog(@"%@: <%p>.prepare { preloadSize: %lu, numberOfPreloadFiles: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize, (unsigned long)_numberOfPreloadFiles);
        
        _isCalledPrepare = YES;
        _asset = [MCSAssetManager.shared assetWithURL:_URL];

        NSURLRequest *request = [NSURLRequest.alloc initWithURL:_URL];
        _reader = [MCSAssetManager.shared readerWithRequest:request networkTaskPriority:0 delegate:self];
        [_reader prepare];
    });
}

- (void)close {
    dispatch_barrier_sync(mcs_queue, ^{
        [self _close];
    });
}

- (float)progress {
    __block float progress = 0;
    dispatch_sync(mcs_queue, ^{
        progress = _progress;
    });
    return progress;
}

- (BOOL)isClosed {
    __block BOOL isClosed = NO;
    dispatch_sync(mcs_queue, ^{
        isClosed = _isClosed;
    });
    return isClosed;
}

- (BOOL)isDone {
    __block BOOL isDone = NO;
    dispatch_sync(mcs_queue, ^{
        isDone = _isDone;
    });
    return isDone;
}

#pragma mark - MCSAssetReaderDelegate

- (void)reader:(id<MCSAssetReader>)reader prepareDidFinish:(id<MCSResponse>)response {
    /* nothing */
}

- (void)reader:(id<MCSAssetReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _isClosed )
            return;
        
        if ( [reader seekToOffset:reader.offset + length] ) {
            if ( _fragmentIndex != NSNotFound )
                _loadedLength += length;
            
            CGFloat progress = 0;
            if ( _preloadSize != 0 ) {
                NSUInteger size = _preloadSize < reader.response.totalLength ? reader.response.totalLength : _preloadSize;
                progress = _loadedLength * 1.0 / size;
            }
            else {
                CGFloat curr = (reader.offset * 1.0) / reader.response.totalLength;
                NSUInteger files = _numberOfPreloadFiles < _asset.TsCount ? _numberOfPreloadFiles : _asset.TsCount;
                progress = ((_fragmentIndex != NSNotFound ? _fragmentIndex : 0) + curr) / files;
            }
            
            if ( progress >= 1 ) progress = 1;
            _progress = progress;
            
            MCSPrefetcherDebugLog(@"%@: <%p>.preload { progress: %f };\n", NSStringFromClass(self.class), self, _progress);
            
            if ( _delegate != nil ) {
                dispatch_async(_delegateQueue, ^{
                    [self.delegate prefetcher:self progressDidChange:progress];
                });
            }
            
            if ( reader.isReadingEndOfData ) {
                BOOL isLastFragment = _fragmentIndex == _asset.parser.TsCount - 1;
                BOOL isFinished = progress >= 1 || isLastFragment;
                if ( !isFinished ) {
                    [self _prepareNextFragment];
                    return;
                }
                
                [self _didCompleteWithError:nil];
            }
        }
    });
}
  
- (void)reader:(id<MCSAssetReader>)reader anErrorOccurred:(NSError *)error {
    dispatch_barrier_sync(mcs_queue, ^{
        [self _didCompleteWithError:error];
    });
}

#pragma mark -

- (void)_prepareNextFragment {
    _fragmentIndex = (_fragmentIndex == NSNotFound) ? 0 : (_fragmentIndex + 1);
    
    NSString *TsURI = [_asset.parser URIAtIndex:_fragmentIndex];
    NSURL *proxyURL = [MCSURLRecognizer.shared proxyURLWithTsURI:TsURI];
    NSURLRequest *request = [NSURLRequest requestWithURL:proxyURL];
    _reader = [MCSAssetManager.shared readerWithRequest:request networkTaskPriority:0 delegate:self];
    [_reader prepare];
    
    MCSPrefetcherDebugLog(@"%@: <%p>.prepareFragment { index:%lu, request: %@ };\n", NSStringFromClass(self.class), self, (unsigned long)_fragmentIndex, request);
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
    
    [_reader close];
    
    _isClosed = YES;

    MCSPrefetcherDebugLog(@"%@: <%p>.close;\n", NSStringFromClass(self.class), self);
}
@end
