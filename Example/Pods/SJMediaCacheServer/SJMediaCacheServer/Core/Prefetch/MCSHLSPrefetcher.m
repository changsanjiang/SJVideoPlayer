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
    NSRecursiveLock *_lock;
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
- (instancetype)initWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes {
    self = [super init];
    if ( self ) {
        _URL = URL;
        _preloadSize = bytes;
        _fragmentIndex = NSNotFound;
        _lock = NSRecursiveLock.alloc.init;
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

        MCSLog(@"%@: <%p>.prepare { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)self.preloadSize);
        
        _isCalledPrepare = YES;
        _resource = [MCSResourceManager.shared resourceWithURL:self.URL];
        _resource.parser == nil ? [self _parse] : [self _prepareNextFragment];
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
        
        _isClosed = YES;
        [_reader close];
        
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

- (void)_parse {
    NSURLRequest *request = [NSURLRequest.alloc initWithURL:self.URL];
    _reader = [MCSResourceManager.shared readerWithRequest:request];
    _reader.delegate = self;
    [_reader prepare];
}

- (void)_prepareNextFragment {
    _fragmentIndex = (_fragmentIndex == NSNotFound) ? 0 : (_fragmentIndex + 1);
    
    NSString *name = [_resource.parser tsNameAtIndex:_fragmentIndex];
    NSURL *proxyURL = [MCSURLRecognizer.shared proxyURLWithTsName:name];
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
    @try {
        while (true) {
            @autoreleasepool {
                NSData *data = [_reader readDataOfLength:1 * 1024 * 1024];
                if ( data.length == 0 )
                    break;
                
                if ( _fragmentIndex != NSNotFound )
                    _offset += data.length;
                
                _progress = _offset * 1.0 / self.preloadSize;
                [self.delegate prefetcher:self progressDidChange:_progress];
                
                MCSLog(@"%@: <%p>.preload { preloadSize: %lu, progress: %f };\n", NSStringFromClass(self.class), self, (unsigned long)self.preloadSize, _progress);

                BOOL isEnd = _progress >= 1;
                if ( !isEnd && reader.isReadingEndOfData && _fragmentIndex == _resource.parser.tsCount - 1 ) {
                    isEnd = YES;
                    _progress = 1;
                }
                
                if ( !isEnd ) {
                    if ( reader.isReadingEndOfData ) [self _prepareNextFragment];
                }
                else {
                    MCSLog(@"%@: <%p>.done { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)self.preloadSize);
                    [self close];
                    [self.delegate prefetcher:self didCompleteWithError:nil];
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
    MCSLog(@"%@: <%p>.error { preloadSize: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)self.preloadSize);

    [self close];
    [self.delegate prefetcher:self didCompleteWithError:error];
}

#pragma mark -

- (void)lock {
    [_lock lock];
}

- (void)unlock {
    [_lock unlock];
}
@end
