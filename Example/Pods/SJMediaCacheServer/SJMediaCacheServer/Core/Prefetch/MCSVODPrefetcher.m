//
//  MCSVODPrefetcher.m
//  CocoaAsyncSocket
//
//  Created by BlueDancer on 2020/6/11.
//

#import "MCSVODPrefetcher.h"
#import "MCSLogger.h"
#import "MCSResourceManager.h"
#import "NSURLRequest+MCS.h"
#import "MCSQueue.h"

@interface MCSVODPrefetcher () <MCSResourceReaderDelegate>
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isDone;

@property (nonatomic, strong, nullable) id<MCSResourceReader> reader;
@property (nonatomic) NSUInteger loadedLength;

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic) NSUInteger preloadSize;
@property (nonatomic) float progress;
@end

@implementation MCSVODPrefetcher
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

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)self.preloadSize];
}

- (void)dealloc {
    MCSLog(@"%@: <%p>.dealloc;\n", NSStringFromClass(self.class), self);
}

- (void)prepare {
    dispatch_barrier_sync(MCSPrefetcherQueue(), ^{
       if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSLog(@"%@: <%p>.prepare { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize);

        _isCalledPrepare = YES;
        
        NSURLRequest *request = [NSURLRequest mcs_requestWithURL:_URL range:NSMakeRange(0, _preloadSize)];
        _reader = [MCSResourceManager.shared readerWithRequest:request];
        _reader.networkTaskPriority = 0;
        _reader.delegate = self;
        [_reader prepare];
    });
}

- (void)close {
    dispatch_barrier_sync(MCSPrefetcherQueue(), ^{
        if ( _isClosed )
            return;
        
        [_reader close];
        _isClosed = YES;
        MCSLog(@"%@: <%p>.close { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)self.preloadSize);
    });
}

- (float)progress {
    __block float progress = 0;
    dispatch_sync(MCSPrefetcherQueue(), ^{
        progress = _progress;
    });
    return progress;
}

- (BOOL)isClosed {
    __block BOOL isClosed;
    dispatch_sync(MCSPrefetcherQueue(), ^{
        isClosed = _reader.isClosed;
    });
    return isClosed;
}

- (BOOL)isDone {
    __block BOOL isDone;
    dispatch_sync(MCSPrefetcherQueue(), ^{
        isDone = _isDone;
    });
    return isDone;
}

#pragma mark -

- (void)readerPrepareDidFinish:(id<MCSResourceReader>)reader {
    /* nothing */
}

- (void)reader:(nonnull id<MCSResourceReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    dispatch_barrier_sync(MCSPrefetcherQueue(), ^{
        if ( _isDone || _isClosed )
            return;
        
        if ( [reader seekToOffset:reader.offset + length] ) {
            _loadedLength += length;
            
            float progress = _loadedLength * 1.0 / reader.response.contentRange.length;
            if ( progress >= 1 ) progress = 1;
            _progress = progress;
            
            MCSLog(@"%@: <%p>.preload { preloadSize: %lu, progress: %f };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize, progress);
            
            if ( _delegate != nil ) {
                dispatch_async(_delegateQueue, ^{
                    [self.delegate prefetcher:self progressDidChange:progress];
                });
            }
            
            if ( _progress >= 1 || _reader.isReadingEndOfData ) {
                [self _didCompleteWithError:nil];
            }
        }
    });
}

- (void)reader:(id<MCSResourceReader>)reader anErrorOccurred:(NSError *)error {
    dispatch_barrier_sync(MCSPrefetcherQueue(), ^{
        [self _didCompleteWithError:error];
    });
}

#pragma mark -

- (void)_didCompleteWithError:(nullable NSError *)error {
    if ( _isClosed )
        return;
    
    _isDone = (error == nil);
    
#ifdef DEBUG
    if ( _isDone )
        MCSLog(@"%@: <%p>.done { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize);
    else
        MCSLog(@"%@: <%p>.error { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize);
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

    MCSLog(@"%@: <%p>.close { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize);
}
@end
