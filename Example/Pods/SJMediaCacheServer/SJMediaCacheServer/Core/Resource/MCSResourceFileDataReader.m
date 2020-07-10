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
#import "MCSFileManager.h"
#import "NSFileHandle+MCS.h"

@interface MCSResourceFileDataReader() {
    dispatch_semaphore_t _semaphore;
}

@property (nonatomic) NSRange range;
@property (nonatomic) NSRange readRange;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSFileHandle *reader;

@property (nonatomic) NSUInteger availableLength;
@property (nonatomic) NSUInteger readLength;

@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isDone;
@property (nonatomic) BOOL isSought;
@end

@implementation MCSResourceFileDataReader
@synthesize delegate = _delegate;
@synthesize delegateQueue = _delegateQueue;

- (instancetype)initWithRange:(NSRange)range path:(NSString *)path readRange:(NSRange)readRange delegate:(id<MCSResourceDataReaderDelegate>)delegate delegateQueue:(dispatch_queue_t)queue {
    self = [super init];
    if ( self ) {
        _range = range;
        _path = path.copy;
        _readRange = readRange;
        _delegate = delegate;
        _delegateQueue = queue;
        _semaphore = dispatch_semaphore_create(1);
        _availableLength = readRange.length;
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
        
        NSUInteger length = _readRange.length;
        dispatch_async(_delegateQueue, ^{
            [self.delegate reader:self hasAvailableDataWithLength:length];
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
        
        if ( _isSought ) {
            _isSought = NO;
            NSError *error = nil;
            if ( ![_reader mcs_seekToFileOffset:_readRange.location + _readLength error:&error] ) {
                [self _onError:error];
                return nil;
            }
        }
        
        NSUInteger length = MIN(lengthParam, _readRange.length - _readLength);
        NSData *data = [_reader readDataOfLength:length];

        NSUInteger readLength = data.length;
        if ( readLength == 0 )
            return nil;
        
        _readLength += readLength;
        _isDone = _readLength == _readRange.length;
        
#ifdef DEBUG
        MCSLog(@"%@: <%p>.read { offset: %lu, readLength: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)(_range.location + _readLength), (unsigned long)readLength);
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

- (BOOL)seekToOffset:(NSUInteger)offset {
    [self lock];
    @try {
        if ( _isClosed || !_isPrepared )
            return NO;
    
        if ( !NSLocationInRange(offset - 1, _range) )
            return NO;
        
        // offset     = range.location + readLength;
        // readLength = offset - range.location
        NSUInteger readLength = offset - _range.location;
        if ( readLength != _readLength ) {
            _isSought = YES;
            _readLength = readLength;
            _isDone = _readLength == _readRange.length;
        }
        return YES;
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

- (NSUInteger)offset {
    [self lock];
    @try {
        return _range.location + _readLength;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

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
