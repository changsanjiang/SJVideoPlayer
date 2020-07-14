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
#import "MCSQueue.h"

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
@end

@implementation MCSHLSPrefetcher
@synthesize delegate = _delegate;
@synthesize delegateQueue = _delegateQueue;
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
        _resource = [MCSResourceManager.shared resourceWithURL:_URL];

        NSURLRequest *request = [NSURLRequest.alloc initWithURL:_URL];
        _reader = [MCSResourceManager.shared readerWithRequest:request];
        _reader.delegate = self;
        [_reader prepare];
    });
}

- (void)close {
    dispatch_barrier_sync(MCSPrefetcherQueue(), ^{
        [self _close];
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
    __block BOOL isClosed = NO;
    dispatch_sync(MCSPrefetcherQueue(), ^{
        isClosed = _isClosed;
    });
    return isClosed;
}

- (BOOL)isDone {
    __block BOOL isDone = NO;
    dispatch_sync(MCSPrefetcherQueue(), ^{
        isDone = _isDone;
    });
    return isDone;
}

#pragma mark - MCSResourceReaderDelegate

- (void)readerPrepareDidFinish:(id<MCSResourceReader>)reader {
    /* nothing */
}

- (void)reader:(id<MCSResourceReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    dispatch_barrier_sync(MCSPrefetcherQueue(), ^{
        if ( _isClosed )
            return;
        
        if ( [reader seekToOffset:reader.offset + length] ) {
            if ( _fragmentIndex != NSNotFound )
                _loadedLength += length;
            
            CGFloat progress = _loadedLength * 1.0 / _preloadSize;
            if ( progress >= 1 ) progress = 1;
            _progress = progress;
            
            MCSLog(@"%@: <%p>.preload { preloadSize: %lu, progress: %f };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize, _progress);
            
            if ( _delegate != nil ) {
                dispatch_async(_delegateQueue, ^{
                    [self.delegate prefetcher:self progressDidChange:progress];
                });
            }
            
            if ( reader.isReadingEndOfData ) {
                BOOL isLastFragment = reader.isReadingEndOfData && _fragmentIndex == _resource.parser.TsCount - 1;
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
    dispatch_barrier_sync(MCSPrefetcherQueue(), ^{
        [self _didCompleteWithError:error];
    });
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
