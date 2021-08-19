//
//  FILEPrefetcher.m
//  CocoaAsyncSocket
//
//  Created by BlueDancer on 2020/6/11.
//

#import "FILEPrefetcher.h"
#import "MCSLogger.h"
#import "MCSAssetManager.h"
#import "NSURLRequest+MCS.h"
#import "MCSQueue.h"
#import "MCSUtils.h"
#import "MCSError.h"

@interface FILEPrefetcher () <MCSAssetReaderDelegate>
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isDone;

@property (nonatomic, strong, nullable) id<MCSAssetReader> reader;
@property (nonatomic) NSUInteger loadedLength;

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic) NSUInteger preloadSize;
@property (nonatomic) float progress;
@end

@implementation FILEPrefetcher
@synthesize delegate = _delegate;
@synthesize delegateQueue = _delegateQueue;

- (instancetype)initWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes delegate:(nullable id<MCSPrefetcherDelegate>)delegate delegateQueue:(nonnull dispatch_queue_t)queue {
    self = [super init];
    if ( self ) {
        _delegate = delegate;
        _delegateQueue = queue;
        _URL = URL;
        _preloadSize = bytes;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL delegate:(nullable id<MCSPrefetcherDelegate>)delegate delegateQueue:(dispatch_queue_t)queue {
    return [self initWithURL:URL preloadSize:NSNotFound delegate:delegate delegateQueue:queue];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)self.preloadSize];
}

- (void)dealloc {
    MCSPrefetcherDebugLog(@"%@: <%p>.dealloc;\n", NSStringFromClass(self.class), self);
}

- (void)prepare {
    mcs_queue_sync(^{
       if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSPrefetcherDebugLog(@"%@: <%p>.prepare { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize);

        _isCalledPrepare = YES;
        
        NSURLRequest *request = [NSURLRequest mcs_requestWithURL:_URL range:NSMakeRange(0, _preloadSize)];
        _reader = [MCSAssetManager.shared readerWithRequest:request networkTaskPriority:0 delegate:self];
        [_reader prepare];
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
        progress = _progress;
    });
    return progress;
}

#pragma mark -

- (void)reader:(id<MCSAssetReader>)reader didReceiveResponse:(id<MCSResponse>)response {
    /* nothing */
}

- (void)reader:(nonnull id<MCSAssetReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
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

- (void)_reader:(nonnull id<MCSAssetReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    if ( _isDone || _isClosed )
        return;
    
    if ( [reader seekToOffset:reader.offset + length] ) {
        _loadedLength += length;
        
        float progress = _loadedLength * 1.0 / reader.response.range.length;
        if ( progress >= 1 ) progress = 1;
        _progress = progress;
        
        MCSPrefetcherDebugLog(@"%@: <%p>.preload { preloadSize: %lu, total: %lu, progress: %f };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize, (unsigned long)reader.response.totalLength, progress);
                    
        if ( _delegate != nil ) {
            dispatch_async(_delegateQueue, ^{
                [self.delegate prefetcher:self progressDidChange:progress];
            });
        }
        
        if ( _progress >= 1 || _reader.status == MCSReaderStatusFinished ) {
            [self _didCompleteWithError:nil];
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

    MCSPrefetcherDebugLog(@"%@: <%p>.close;\n", NSStringFromClass(self.class), self);
}
@end
