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
#import "MCSResource.h"
#import "MCSQueue.h"

@interface MCSResourceFileDataReader()
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

@property (nonatomic, weak, nullable) MCSResource *resource;
@end

@implementation MCSResourceFileDataReader
@synthesize delegate = _delegate;

- (instancetype)initWithResource:(MCSResource *)resource range:(NSRange)range path:(NSString *)path readRange:(NSRange)readRange delegate:(id<MCSResourceDataReaderDelegate>)delegate {
    self = [super init];
    if ( self ) {
        _resource = resource;
        _range = range;
        _path = path.copy;
        _readRange = readRange;
        _delegate = delegate;
        _availableLength = readRange.length;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { range: %@\n };", NSStringFromClass(self.class), self, NSStringFromRange(_range)];
}

- (void)prepare {
    dispatch_barrier_sync(MCSFileDataReaderQueue(), ^{
        @try {
            if ( _isClosed || _isCalledPrepare )
                return;
            
            _isCalledPrepare = YES;
            
            MCSLog(@"%@: <%p>.prepare { range: %@, file: %@.%@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_range), _path.lastPathComponent, NSStringFromRange(_readRange));
            
            _reader = [NSFileHandle fileHandleForReadingAtPath:_path];
            
            [_reader seekToFileOffset:_readRange.location];
            _isPrepared = YES;
            
            dispatch_async(MCSDelegateQueue(), ^{
                [self->_delegate readerPrepareDidFinish:self];
                [self->_delegate reader:self hasAvailableDataWithLength:self->_readRange.length];
            });
            
        } @catch (NSException *exception) {
            [self _onError:[NSError mcs_exception:exception]];
        }
    });
}

- (nullable NSData *)readDataOfLength:(NSUInteger)lengthParam {
    __block NSData *data = nil;
    dispatch_barrier_sync(MCSFileDataReaderQueue(), ^{
        @try {
            if ( _isClosed || _isDone || !_isPrepared )
                return;
            
            if ( _isSought ) {
                _isSought = NO;
                NSError *error = nil;
                NSUInteger offset = _readRange.location + _readLength;
                if ( ![_reader mcs_seekToFileOffset:offset error:&error] ) {
                    [self _onError:error];
                    return;
                }
            }
            
            NSUInteger length = MIN(lengthParam, _readRange.length - _readLength);
            data = [_reader readDataOfLength:length];
            
            NSUInteger readLength = data.length;
            if ( readLength == 0 )
                return;
            
            _readLength += readLength;
            _isDone = (_readLength == _readRange.length);
            
#ifdef DEBUG
            MCSLog(@"%@: <%p>.read { offset: %lu, readLength: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)(_range.location + _readLength), (unsigned long)readLength);
            if ( _isDone ) {
                MCSLog(@"%@: <%p>.done { range: %@ , file: %@.%@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_range), _path.lastPathComponent, NSStringFromRange(_readRange));
            }
#endif
        } @catch (NSException *exception) {
            [self _onError:[NSError mcs_exception:exception]];
        }
    });
    return data;
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    __block BOOL result = NO;
    dispatch_barrier_sync(MCSFileDataReaderQueue(), ^{
        if ( _isClosed || !_isPrepared )
            return;
        if ( !NSLocationInRange(offset - 1, _range) )
            return;
        
        // offset     = range.location + readLength;
        // readLength = offset - range.location
        NSUInteger readLength = offset - _range.location;
        if ( readLength != _readLength ) {
            _isSought = YES;
            _readLength = readLength;
            _isDone = (_readLength == _readRange.length);
        }
        result = YES;
    });
    return result;
}

- (void)close {
    dispatch_barrier_sync(MCSFileDataReaderQueue(), ^{
        [self _close];
    });
}

#pragma mark -

- (NSUInteger)offset {
    __block NSUInteger offset = 0;
    dispatch_sync(MCSFileDataReaderQueue(), ^{
        offset = _range.location + _readLength;
    });
    return offset;
}

- (BOOL)isPrepared {
    __block BOOL isPrepared = NO;
    dispatch_sync(MCSFileDataReaderQueue(), ^{
        isPrepared = _isPrepared;
    });
    return isPrepared;
}

- (BOOL)isDone {
    __block BOOL isDone = NO;
    dispatch_sync(MCSFileDataReaderQueue(), ^{
        isDone = _isDone;
    });
    return isDone;
}

#pragma mark -

- (void)_onError:(NSError *)error {
    [self _close];
    
    dispatch_async(MCSDelegateQueue(), ^{
        [self->_delegate reader:self anErrorOccurred:error];
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
@end
