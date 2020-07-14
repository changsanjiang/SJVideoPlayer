//
//  MCSHLSPrefetcher.m
//  CocoaAsyncSocket
//
//  Created by BlueDancer on 2020/6/11.
//

#import "MCSHLSPrefetcher.h"
#import "MCSLogger.h"
#import "MCSResourceManager.h"
#import "NSURLRequest+MCS.h"  
#import "MCSHLSResource.h"
#import "MCSHLSTSDataReader.h"
#import "MCSHLSIndexDataReader.h"

@interface MCSHLSPrefetcher ()<MCSResourceReaderDelegate>
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isDone;
 
@property (nonatomic, strong, nullable) id<MCSResourceReader> reader;
@property (nonatomic) NSUInteger loadedLength;
@property (nonatomic) float progress;

@property (nonatomic, weak, nullable) MCSHLSResource *resource;
@property (nonatomic) NSUInteger fragmentIndex;

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic) NSUInteger preloadSize;

@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation MCSHLSPrefetcher
@synthesize delegate = _delegate;
@synthesize delegateQueue = _delegateQueue;
- (instancetype)initWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes delegate:(nullable id<MCSPrefetcherDelegate>)delegate delegateQueue:(nonnull dispatch_queue_t)queue {
    self = [super init];
    if ( self ) {
        _delegate = delegate;
        _delegateQueue = queue;
        _URL = URL;
        _preloadSize = bytes;
        _fragmentIndex = NSNotFound;
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
        self->_resource = [MCSResourceManager.shared resourceWithURL:self->_URL];

        NSURLRequest *request = [NSURLRequest.alloc initWithURL:self->_URL];
        self->_reader = [MCSResourceManager.shared readerWithRequest:request];
        self->_reader.delegate = self;
        [self->_reader prepare];
    });
}

- (void)close {
    dispatch_barrier_sync(_queue, ^{
        [self _close];
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
    __block BOOL isClosed = NO;
    dispatch_sync(_queue, ^{
        isClosed = _isClosed;
    });
    return isClosed;
}

- (BOOL)isDone {
    __block BOOL isDone = NO;
    dispatch_sync(_queue, ^{
        isDone = _isDone;
    });
    return isDone;
}

#pragma mark -

- (void)_prepareNextFragment {
    _fragmentIndex = (_fragmentIndex == NSNotFound) ? 0 : (_fragmentIndex + 1);
    
    NSString *TsURI = [_resource.parser URIAtIndex:_fragmentIndex];
    NSURL *proxyURL = [MCSURLRecognizer.shared proxyURLWithTsURI:TsURI];
    NSURLRequest *request = [NSURLRequest requestWithURL:proxyURL];
    _reader = [MCSResourceManager.shared readerWithRequest:request];
    _reader.networkTaskPriority = 0;
    _reader.delegate = self;
    [_reader prepare];
}

#pragma mark -

- (void)readerPrepareDidFinish:(id<MCSResourceReader>)reader {
    /* nothing */
}

- (void)reader:(id<MCSResourceReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    dispatch_barrier_sync(_queue, ^{
        if ( [reader seekToOffset:reader.offset + length] ) {
            if ( self->_fragmentIndex != NSNotFound )
                self->_loadedLength += length;
            
            CGFloat progress = self->_loadedLength * 1.0 / self->_preloadSize;
            if ( progress >= 1 ) progress = 1;
            self->_progress = progress;
            
            MCSLog(@"%@: <%p>.preload { preloadSize: %lu, progress: %f };\n", NSStringFromClass(self.class), self, (unsigned long)self->_preloadSize, self->_progress);
            
            if ( self->_delegate != nil ) {
                dispatch_sync(self->_delegateQueue, ^{
                    [self.delegate prefetcher:self progressDidChange:progress];
                });
            }
            
            if ( progress >= 1 || reader.isReadingEndOfData ) {
                BOOL isLastFragment = reader.isReadingEndOfData && self->_fragmentIndex == self->_resource.parser.TsCount - 1;
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
