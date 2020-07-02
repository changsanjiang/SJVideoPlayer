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

@interface MCSVODPrefetcher () <NSLocking, MCSResourceReaderDelegate> {
    dispatch_semaphore_t _semaphore;
}
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isClosed;
 
@property (nonatomic, strong, nullable) id<MCSResourceReader> reader;
@property (nonatomic) NSUInteger offset;

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic) NSUInteger preloadSize;
@property (nonatomic) float progress;
@end

@implementation MCSVODPrefetcher
@synthesize delegate = _delegate;
@synthesize delegateQueue = _delegateQueue;
- (instancetype)initWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes delegate:(nonnull id<MCSPrefetcherDelegate>)delegate delegateQueue:(nonnull dispatch_queue_t)queue {
    self = [super init];
    if ( self ) {
        _delegate = delegate;
        _delegateQueue = queue;
        _URL = URL;
        _preloadSize = bytes;
        _semaphore = dispatch_semaphore_create(1);
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
    [self lock];
    @try {
        if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSLog(@"%@: <%p>.prepare { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize);

        _isCalledPrepare = YES;
        
        NSURLRequest *request = [NSURLRequest mcs_requestWithURL:_URL range:NSMakeRange(0, _preloadSize)];
        _reader = [MCSResourceManager.shared readerWithRequest:request];
        _reader.networkTaskPriority = 0;
        _reader.delegate = self;
        [_reader prepare];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)close {
    [self lock];
    @try {
        if ( _isClosed )
            return;
        
        [_reader close];
        _isClosed = YES;
        
        MCSLog(@"%@: <%p>.close { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)self.preloadSize);
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (float)progress {
    [self lock];
    @try {
        return _progress;
    } @catch (__unused NSException *exception) {
            
    } @finally {
        [self unlock];
    }
}

- (BOOL)isClosed {
    [self lock];
    @try {
        return _reader.isClosed;
    } @catch (__unused NSException *exception) {
            
    } @finally {
        [self unlock];
    }

}

- (BOOL)isDone {
    [self lock];
    @try {
        return _reader.isReadingEndOfData;
    } @catch (__unused NSException *exception) {
            
    } @finally {
        [self unlock];
    }
}

#pragma mark -

- (void)readerPrepareDidFinish:(id<MCSResourceReader>)reader {
    [self readerHasAvailableData:reader];
}

- (void)readerHasAvailableData:(id<MCSResourceReader>)reader {
    [self lock];
    @try {
        while (true) {
            @autoreleasepool {
                NSData *data = [_reader readDataOfLength:1 * 1024 * 1024];
                if ( data.length == 0 )
                    break;
                
                _offset += data.length;
                
                float progress = _offset * 1.0 / reader.response.contentRange.length;
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
                    break;
                }
            }
        }
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)reader:(id<MCSResourceReader>)reader anErrorOccurred:(NSError *)error {
    [self lock];
    [self _didCompleteWithError:error];
    [self unlock];
}

#pragma mark -

- (void)_didCompleteWithError:(nullable NSError *)error {
#ifdef DEBUG
    if ( error == nil )
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

#pragma mark -

- (void)lock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_semaphore);
}
@end
