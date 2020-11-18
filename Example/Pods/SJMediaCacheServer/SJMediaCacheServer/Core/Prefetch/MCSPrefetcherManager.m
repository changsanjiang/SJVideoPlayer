//
//  MCSPrefetcherManager.m
//  CocoaAsyncSocket
//
//  Created by BlueDancer on 2020/6/12.
//

#import "MCSPrefetcherManager.h"
#import "HLSPrefetcher.h"
#import "FILEPrefetcher.h"
#import "MCSURLRecognizer.h"

@interface _MCSPrefetchOperation : NSObject
@property (nonatomic, getter=isCancelled) BOOL cancelled;
@property (nonatomic, getter=isExecuting) BOOL executing;
@property (nonatomic, getter=isFinished) BOOL finished;
@end

@implementation _MCSPrefetchOperation
@synthesize cancelled = _cancelled;
@synthesize executing = _executing;
@synthesize finished = _finished;

- (void)setCancelled:(BOOL)cancelled {
    dispatch_barrier_sync(dispatch_get_global_queue(0, 0), ^{
        _cancelled = cancelled;
    });
}
- (BOOL)isCancelled {
    __block BOOL isCancelled = NO;
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        isCancelled = _cancelled;
    });
    return isCancelled;
}

- (void)setExecuting:(BOOL)executing {
    dispatch_barrier_sync(dispatch_get_global_queue(0, 0), ^{
        _executing = executing;
    });
}
- (BOOL)isExecuting {
    __block BOOL isExecuting = NO;
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        isExecuting = _executing;
    });
    return isExecuting;
}

- (void)setFinished:(BOOL)finished {
    dispatch_barrier_sync(dispatch_get_global_queue(0, 0), ^{
        _finished = finished;
    });
}
- (BOOL)isFinished {
    __block BOOL isFinished = NO;
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        isFinished = _finished;
    });
    return isFinished;
}
@end

@interface MCSPrefetchOperation : NSOperation<MCSPrefetchTask>
- (instancetype)initWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock;

- (instancetype)initWithURL:(NSURL *)URL numberOfPreloadFiles:(NSUInteger)num progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock;

@property (nonatomic, readonly) NSUInteger preloadSize;
@property (nonatomic, readonly) NSUInteger numberOfPreloadFiles;
@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, copy, readonly, nullable) void(^mcs_progressBlock)(float progress);
@property (nonatomic, copy, readonly, nullable) void(^mcs_completionBlock)(NSError *_Nullable error);

- (void)cancel;
@end

@interface MCSPrefetchOperation ()<MCSPrefetcherDelegate> {
    id<MCSPrefetcher> _prefetcher;
    _MCSPrefetchOperation *_op;
}
@end

@implementation MCSPrefetchOperation
- (instancetype)initWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock {
    self = [super init];
    if ( self ) {
        _op = _MCSPrefetchOperation.alloc.init;
        _URL = URL;
        _preloadSize = bytes;
        _mcs_progressBlock = progressBlock;
        _mcs_completionBlock = completionBlock;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL numberOfPreloadFiles:(NSUInteger)num progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock {
    self = [super init];
    if ( self ) {
        _op = _MCSPrefetchOperation.alloc.init;
        _URL = URL;
        _numberOfPreloadFiles = num;
        _mcs_progressBlock = progressBlock;
        _mcs_completionBlock = completionBlock;
    }
    return self;
}

- (void)prefetcher:(id<MCSPrefetcher>)prefetcher progressDidChange:(float)progress {
    if ( _mcs_progressBlock != nil ) {
        _mcs_progressBlock(progress);
    }
}

- (void)prefetcher:(id<MCSPrefetcher>)prefetcher didCompleteWithError:(NSError *_Nullable)error {
    [self _completeOperationIfExecuting];

    if ( _mcs_completionBlock != nil ) {
        _mcs_completionBlock(error);
    }
}

#pragma mark -
 
- (void)start {
    [self willChangeValueForKey:@"isExecuting"];
    _op.executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    if ( _op.isCancelled ) {
        [self _completeOperationIfExecuting];
        return;
    }
    
    MCSAssetType type = [MCSURLRecognizer.shared assetTypeForURL:self->_URL];
    switch ( type ) {
        case MCSAssetTypeFILE:
            self->_prefetcher = [FILEPrefetcher.alloc initWithURL:self->_URL preloadSize:self->_preloadSize delegate:self delegateQueue:dispatch_get_main_queue()];
            break;
        case MCSAssetTypeHLS: {
            self->_prefetcher = _preloadSize != 0 ?
                [HLSPrefetcher.alloc initWithURL:self->_URL preloadSize:self->_preloadSize delegate:self delegateQueue:dispatch_get_main_queue()] :
                [HLSPrefetcher.alloc initWithURL:self->_URL numberOfPreloadFiles:self->_numberOfPreloadFiles delegate:self delegateQueue:dispatch_get_main_queue()];
        }
            break;
    }
    [self->_prefetcher prepare];
}

- (void)cancel {
    if ( _op.isCancelled || _op.isFinished ) return;
    
    _op.cancelled = YES;
    
    [self _completeOperationIfExecuting];
}

#pragma mark -

- (void)_completeOperationIfExecuting {
    if ( !_op.isExecuting || _op.isFinished ) return;
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    [self->_prefetcher close];
    self->_prefetcher = nil;
    _op.executing = NO;
    _op.finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark -

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    return _op.isExecuting;
}

- (BOOL)isFinished {
    return _op.isFinished;
}

- (BOOL)isCancelled {
    return NO;
}
@end



@interface MCSPrefetcherManager ()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation MCSPrefetcherManager
+ (instancetype)shared {
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _operationQueue = NSOperationQueue.alloc.init;
        _operationQueue.maxConcurrentOperationCount = 1;
        _operationQueue.qualityOfService = NSQualityOfServiceBackground;
    }
    return self;
}

- (void)setMaxConcurrentPrefetchCount:(NSInteger)maxConcurrentPrefetchCount {
    _operationQueue.maxConcurrentOperationCount = maxConcurrentPrefetchCount;
}

- (NSInteger)maxConcurrentPrefetchCount {
    return _operationQueue.maxConcurrentOperationCount;
}

- (nullable id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL preloadSize:(NSUInteger)preloadSize {
    return [self prefetchWithURL:URL preloadSize:preloadSize progress:nil completed:nil];
}

- (nullable id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL preloadSize:(NSUInteger)preloadSize progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock {
    if ( URL == nil || preloadSize == 0 ) return nil;
    MCSPrefetchOperation *operation = [MCSPrefetchOperation.alloc initWithURL:URL preloadSize:preloadSize progress:progressBlock completed:completionBlock];
    [_operationQueue addOperation:operation];
    return operation;
}

- (nullable id<MCSPrefetchTask>)prefetchWithHLSURL:(NSURL *)HLSURL numberOfPreloadFiles:(NSUInteger)num progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock {
    if ( HLSURL == nil || num == 0 ) return nil;
    MCSPrefetchOperation *operation = [MCSPrefetchOperation.alloc initWithURL:HLSURL numberOfPreloadFiles:num progress:progressBlock completed:completionBlock];
    [_operationQueue addOperation:operation];
    return operation;
}

- (void)cancelAllPrefetchTasks {
    [_operationQueue cancelAllOperations];
}
@end
