//
//  MCSResourceFileDataReader.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSResourceFileDataReader.h"
#import "MCSError.h"
#import "MCSLogger.h"

@interface MCSResourceFileDataReader() {
    dispatch_semaphore_t _semaphore;
}

@property (nonatomic) NSRange range;
@property (nonatomic) NSRange readRange;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSFileHandle *reader;

@property (nonatomic) NSUInteger offset;

@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isDone;
@end

@implementation MCSResourceFileDataReader
@synthesize delegate = _delegate;
@synthesize delegateQueue = _delegateQueue;

- (instancetype)initWithRange:(NSRange)range path:(NSString *)path readRange:(NSRange)readRange delegate:(id<MCSResourceDataReaderDelegate>)delegate delegateQueue:(dispatch_queue_t)queue {
    self = [super init];
    if ( self ) {
        _path = path.copy;
        _range = range;
        _readRange = readRange;
        _delegate = delegate;
        _delegateQueue = queue;
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { range: %@\n };", NSStringFromClass(self.class), self, NSStringFromRange(_range)];
}

- (void)prepare {
    [self lock];
    @try {
        if ( _isClosed || _isCalledPrepare )
            return;
        
        _isCalledPrepare = YES;
        MCSLog(@"%@: <%p>.prepare { range: %@, file: %@.%@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_range), _path.lastPathComponent, NSStringFromRange(_readRange));

        _reader = [NSFileHandle fileHandleForReadingAtPath:_path];

        [_reader seekToFileOffset:_readRange.location];
        _isPrepared = YES;
        
        dispatch_async(_delegateQueue, ^{
            [self.delegate readerPrepareDidFinish:self];
        });
    } @catch (NSException *exception) {
        [self _onError:[NSError mcs_exception:exception]];
    } @finally {
        [self unlock];
    }
}

- (nullable NSData *)readDataOfLength:(NSUInteger)lengthParam {
    [self lock];
    @try {
        if ( _isClosed || _isDone || !_isPrepared )
            return nil;
        
        NSUInteger length = MIN(lengthParam, _readRange.length - _offset);
        NSData *data = [_reader readDataOfLength:length];

        MCSLog(@"%@: <%p>.read { offset: %lu, readLength: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_offset, (unsigned long)data.length);
        
        _offset += data.length;
        _isDone = _offset == _readRange.length;
                
#ifdef DEBUG
        if ( _isDone ) {
            MCSLog(@"%@: <%p>.done { range: %@ , file: %@.%@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_range), _path.lastPathComponent, NSStringFromRange(_readRange));
        }
#endif
        return data;
    } @catch (NSException *exception) {
        [self _onError:[NSError mcs_exception:exception]];
    } @finally {
           [self unlock];
    }
}

- (void)close {
    [self lock];
    [self _close];
    [self unlock];
}

- (void)onError:(NSError *)error {
    [self lock];
    [self _onError:error];
    [self unlock];
}

#pragma mark -

- (BOOL)isPrepared {
    [self lock];
    @try {
        return _isPrepared;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (BOOL)isDone {
    [self lock];
    @try {
        return _isDone;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

#pragma mark -

- (void)_onError:(NSError *)error {
    [self _close];
    dispatch_async(_delegateQueue, ^{
        [self.delegate reader:self anErrorOccurred:error];
    });
}

- (void)_close {
    if ( _isClosed )
        return;
    
    @try {
        [_reader closeFile];
        _reader = nil;
        _isClosed = YES;
        
        MCSLog(@"%@: <%p>.close;\n", NSStringFromClass(self.class), self);
    } @catch (__unused NSException *exception) {
        
    }
}

#pragma mark -

- (void)lock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_semaphore);
}
@end
