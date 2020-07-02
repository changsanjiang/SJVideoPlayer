//
//  MCSPrefetcherManager.m
//  CocoaAsyncSocket
//
//  Created by BlueDancer on 2020/6/12.
//

#import "MCSPrefetcherManager.h"
#import "MCSHLSPrefetcher.h"
#import "MCSVODPrefetcher.h"
#import "MCSURLRecognizer.h"

@interface MCSPrefetchOperation : NSOperation<MCSPrefetchTask>
- (instancetype)initWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock;

@property (nonatomic, readonly) NSUInteger preloadSize;
@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, copy, readonly, nullable) void(^mcs_progressBlock)(float progress);
@property (nonatomic, copy, readonly, nullable) void(^mcs_completionBlock)(NSError *_Nullable error);

- (void)cancel;
@end

@interface MCSPrefetchOperation ()<MCSPrefetcherDelegate> {
    BOOL _isFinished;
    BOOL _isCancelled;
    BOOL _isExecuting;
    id<MCSPrefetcher> _prefetcher;
}
@end

@implementation MCSPrefetchOperation
@synthesize cancelled = _cancelled;
@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock {
    self = [super init];
    if ( self ) {
        _URL = URL;
        _preloadSize = bytes;
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
    [self _completeOperation];
    if ( _mcs_completionBlock != nil ) {
        _mcs_completionBlock(error);
    }
}

#pragma mark -
 
- (void)start {
    @synchronized (self) {
        if ( _isCancelled || _URL == nil ) {
            // Must move the operation to the finished state if it is canceled.
            [self _completeOperation];
            return;
        }
        
        
        [self willChangeValueForKey:@"isExecuting"];
        _isExecuting = YES;
        [self didChangeValueForKey:@"isExecuting"];
 
        MCSResourceType type = [MCSURLRecognizer.shared resourceTypeForURL:_URL];
        id<MCSPrefetcherDelegate> delegate = _mcs_progressBlock != nil || _mcs_completionBlock != nil ? self : nil;
        switch ( type ) {
            case MCSResourceTypeVOD:
                _prefetcher = [MCSVODPrefetcher.alloc initWithURL:_URL preloadSize:_preloadSize delegate:delegate delegateQueue:dispatch_get_main_queue()];
                break;
            case MCSResourceTypeHLS:
                _prefetcher = [MCSHLSPrefetcher.alloc initWithURL:_URL preloadSize:_preloadSize delegate:delegate delegateQueue:dispatch_get_main_queue()];
                break;
        }
        [_prefetcher prepare];
    }
}

- (void)cancel {
    @synchronized (self) {
        _isCancelled = YES;
        if ( _isExecuting ) [self _completeOperation];
    }
}

#pragma mark -

- (void)_completeOperation {
    @synchronized (self) {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        
        [_prefetcher close];
        _prefetcher = nil;
        _isExecuting = NO;
        _isFinished = YES;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
    }
}

#pragma mark -

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    @synchronized (self) {
        return _isExecuting;
    }
}

- (BOOL)isFinished {
    @synchronized (self) {
        return _isFinished;
    }
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
        _operationQueue.maxConcurrentOperationCount = 3;
        _operationQueue.qualityOfService = NSQualityOfServiceBackground;
    }
    return self;
}

- (id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL preloadSize:(NSUInteger)preloadSize {
    return [self prefetchWithURL:URL preloadSize:preloadSize progress:nil completed:nil];
}

- (id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL preloadSize:(NSUInteger)preloadSize progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock {
    MCSPrefetchOperation *operation = [MCSPrefetchOperation.alloc initWithURL:URL preloadSize:preloadSize progress:progressBlock completed:completionBlock];
    [_operationQueue addOperation:operation];
    return operation;
}
@end
