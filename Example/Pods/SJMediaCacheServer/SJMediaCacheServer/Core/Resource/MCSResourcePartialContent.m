//
//  MCSResourcePartialContent.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSResourcePartialContent.h"
#import "MCSResourceSubclass.h"

@interface MCSResourcePartialContent ()<NSLocking> {
    dispatch_semaphore_t _semaphore;
}
@property (nonatomic, weak, nullable) id<MCSResourcePartialContentDelegate> delegate;
@property (nonatomic, strong, nullable) dispatch_queue_t delegateQueue;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic) NSInteger readWriteCount;
@property (nonatomic, copy) NSString *AESKeyName;
@property (nonatomic, copy) NSString *tsName;
@property (nonatomic) NSUInteger tsTotalLength;

- (void)readWrite_retain;
- (void)readWrite_release;
@end

@implementation MCSResourcePartialContent
- (instancetype)initWithFilename:(NSString *)filename AESKeyName:(NSString *)AESKeyName length:(NSUInteger)length {
    self = [self initWithFilename:filename offset:0 length:length];
    if ( self ) {
        _AESKeyName = AESKeyName.copy;
    }
    return self;
}
- (instancetype)initWithFilename:(NSString *)filename tsName:(NSString *)tsName tsTotalLength:(NSUInteger)tsTotalLength length:(NSUInteger)length {
    self = [self initWithFilename:filename offset:0 length:length];
    if ( self ) {
        _tsName = tsName.copy;
        _tsTotalLength = tsTotalLength;
    }
    return self;
}

- (instancetype)initWithFilename:(NSString *)filename offset:(NSUInteger)offset {
    return [self initWithFilename:filename offset:offset length:0];
}

- (instancetype)initWithFilename:(NSString *)filename offset:(NSUInteger)offset length:(NSUInteger)length {
    self = [super init];
    if ( self ) {
        _semaphore = dispatch_semaphore_create(1);
        _filename = filename;
        _offset = offset;
        _length = length;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%s: <%p> { name: %@, offset: %lu, length: %lu };", NSStringFromClass(self.class).UTF8String, self, _filename, (unsigned long)_offset, (unsigned long)self.length];
}

- (void)setDelegate:(id<MCSResourcePartialContentDelegate>)delegate delegateQueue:(nonnull dispatch_queue_t)delegateQueue {
    _delegate = delegate;
    _delegateQueue = delegateQueue;
}

@synthesize length = _length;
- (void)didWriteDataWithLength:(NSUInteger)length {
    if ( length == 0 )
        return;
    
    [self lock];
    _length += length;
    dispatch_async(_delegateQueue, ^{
        [self.delegate partialContent:self didWriteDataWithLength:length];
    });
    [self unlock];
}

- (NSUInteger)length {
    [self lock];
    @try {
        return _length;;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

@synthesize readWriteCount = _readWriteCount;
- (void)setReadWriteCount:(NSInteger)readWriteCount {
    [self lock];
    @try {
        if ( _readWriteCount != readWriteCount ) {
            _readWriteCount = readWriteCount;;
            dispatch_async(_delegateQueue, ^{
                [self.delegate readWriteCountDidChangeForPartialContent:self];
            });
        }
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSInteger)readWriteCount {
    [self lock];
    @try {
        return _readWriteCount;;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}
 
- (void)readWrite_retain {
    self.readWriteCount += 1;
}

- (void)readWrite_release {
    self.readWriteCount -= 1;
}

- (void)lock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_semaphore);
}
@end
