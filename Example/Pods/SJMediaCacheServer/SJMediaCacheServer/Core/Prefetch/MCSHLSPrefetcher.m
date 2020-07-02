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

@interface MCSHLSPrefetcher ()<NSLocking, MCSResourceReaderDelegate> {
    dispatch_semaphore_t _semaphore;
}
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isClosed;
 
@property (nonatomic, strong, nullable) id<MCSResourceReader> reader;
@property (nonatomic) NSUInteger offset;
@property (nonatomic) float progress;

@property (nonatomic, weak, nullable) MCSHLSResource *resource;
@property (nonatomic) NSUInteger fragmentIndex;

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic) NSUInteger preloadSize;
@end

@implementation MCSHLSPrefetcher
@synthesize delegate = _delegate;
@synthesize delegateQueue = _delegateQueue;
- (instancetype)initWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes delegate:(nonnull id<MCSPrefetcherDelegate>)delegate delegateQueue:(nonnull dispatch_queue_t)queue {
    self = [super init];
    if ( self ) {
        _delegate = delegate;
        _delegateQueue = queue;
        _URL = URL;
        _preloadSize = bytes;
        _fragmentIndex = NSNotFound;
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
        _resource = [MCSResourceManager.shared resourceWithURL:_URL];
        _resource.parser == nil ? [self _parse] : [self _prepareNextFragment];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)close {
    [self lock];
    [self _close];
    [self unlock];
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
        return _progress >= 1;
    } @catch (__unused NSException *exception) {
            
    } @finally {
        [self unlock];
    }
}

#pragma mark -

- (void)_parse {
    NSURLRequest *request = [NSURLRequest.alloc initWithURL:_URL];
    _reader = [MCSResourceManager.shared readerWithRequest:request];
    _reader.delegate = self;
    [_reader prepare];
}

- (void)_prepareNextFragment {
    _fragmentIndex = (_fragmentIndex == NSNotFound) ? 0 : (_fragmentIndex + 1);
    
    NSString *TsURI = [_resource.parser TsURIAtIndex:_fragmentIndex];
    NSURL *proxyURL = [MCSURLRecognizer.shared proxyURLWithTsURI:TsURI];
    NSURLRequest *request = [NSURLRequest requestWithURL:proxyURL];
    _reader = [MCSResourceManager.shared readerWithRequest:request];
    _reader.networkTaskPriority = 0;
    _reader.delegate = self;
    [_reader prepare];
}

#pragma mark -

- (void)readerPrepareDidFinish:(id<MCSResourceReader>)reader {
    [self readerHasAvailableData:reader];
}

- (void)readerHasAvailableData:(id<MCSResourceReader>)reader {
    [self lock];
    while (true) {
        @autoreleasepool {
            NSData *data = [_reader readDataOfLength:1 * 1024 * 1024];
            if ( data.length == 0 )
                break;
            
            if ( _fragmentIndex != NSNotFound )
                _offset += data.length;
            
            CGFloat progress = _offset * 1.0 / _preloadSize;
            if ( progress >= 1 ) progress = 1;
            _progress = progress;
            
            MCSLog(@"%@: <%p>.preload { preloadSize: %lu, progress: %f };\n", NSStringFromClass(self.class), self, (unsigned long)_preloadSize, _progress);
            
            if ( _delegate != nil ) {
                dispatch_async(_delegateQueue, ^{
                    [self.delegate prefetcher:self progressDidChange:progress];
                });
            }
            
            if ( progress >= 1 || reader.isReadingEndOfData ) {
                BOOL isLastFragment = reader.isReadingEndOfData && _fragmentIndex == _resource.parser.TsCount - 1;
                BOOL isFinished = progress >= 1 || isLastFragment;
                if ( !isFinished ) {
                    [self _prepareNextFragment];
                    break;
                }
                
                [self _didCompleteWithError:nil];
                break;
            }
        }
    }
    [self unlock];
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
