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

@interface MCSVODPrefetcher () <MCSResourceReaderDelegate>
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isDone;

@property (nonatomic, strong, nullable) id<MCSResourceReader> reader;
@property (nonatomic) NSUInteger loadedLength;

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic) NSUInteger preloadSize;
@property (nonatomic) float progress;

@property (nonatomic, strong) dispatch_queue_t queue;
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
        _queue = dispatch_get_global_queue(0, 0);
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
    dispatch_barrier_sync(_queue, ^{
       if ( self->_isClosed || self->_isCalledPrepare )
            return;
        
        MCSLog(@"%@: <%p>.prepare { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)self->_preloadSize);

        self->_isCalledPrepare = YES;
        
        NSURLRequest *request = [NSURLRequest mcs_requestWithURL:self->_URL range:NSMakeRange(0, self->_preloadSize)];
        self->_reader = [MCSResourceManager.shared readerWithRequest:request];
        self->_reader.networkTaskPriority = 0;
        self->_reader.delegate = self;
        [self->_reader prepare];
    });
}

- (void)close {
    dispatch_barrier_sync(_queue, ^{
        if ( _isClosed )
            return;
        
        [_reader close];
        _isClosed = YES;
        MCSLog(@"%@: <%p>.close { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)self.preloadSize);
    });
}

- (float)progress {
    __block float progress = 0;
    dispatch_sync(_queue, ^{
        progress = _progress;
    });
    return progress;
}

- (BOOL)isClosed {
    __block BOOL isClosed;
    dispatch_sync(_queue, ^{
        isClosed = _reader.isClosed;
    });
    return isClosed;
}

- (BOOL)isDone {
    __block BOOL isDone;
    dispatch_sync(_queue, ^{
        isDone = _isDone;
    });
    return isDone;
}

#pragma mark -

- (void)readerPrepareDidFinish:(id<MCSResourceReader>)reader {
    /* nothing */
}

- (void)reader:(nonnull id<MCSResourceReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    dispatch_barrier_sync(_queue, ^{
        if ( _isDone )
            return;
        
        if ( [reader seekToOffset:reader.offset + length] ) {
            self->_loadedLength += length;
            
            float progress = _loadedLength * 1.0 / reader.response.contentRange.length;
            if ( progress >= 1 ) progress = 1;
            self->_progress = progress;
            
            MCSLog(@"%@: <%p>.preload { preloadSize: %lu, progress: %f };\n", NSStringFromClass(self.class), self, (unsigned long)self->_preloadSize, progress);
            
            if ( self->_delegate != nil ) {
                dispatch_sync(_delegateQueue, ^{
                    [self.delegate prefetcher:self progressDidChange:progress];
                });
            }
            
            if ( self->_progress >= 1 || self->_reader.isReadingEndOfData ) {
                [self _didCompleteWithError:nil];
            }
        }
    });
}

- (void)reader:(id<MCSResourceReader>)reader anErrorOccurred:(NSError *)error {
    dispatch_barrier_sync(_queue, ^{
        [self _didCompleteWithError:error];
    });
}

#pragma mark -

- (void)_didCompleteWithError:(nullable NSError *)error {
    _isDone = (error == nil);
#ifdef DEBUG
    if ( _isDone )
        MCSLog(@"%@: <%p>.done { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize);
    else
        MCSLog(@"%@: <%p>.error { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize);
#endif
    [self _close];
    
    if ( _delegate != nil ) {
        dispatch_sync(_delegateQueue, ^{
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
