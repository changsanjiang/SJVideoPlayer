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
    NSRecursiveLock *_lock;
}
@property (nonatomic, weak, nullable) id<MCSResourcePartialContentDelegate> delegate;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic) NSInteger readWriteCount;
@property (nonatomic, copy) NSString *tsName;
@property (nonatomic) NSUInteger tsTotalLength;

- (void)readWrite_retain;
- (void)readWrite_release;
@end

@implementation MCSResourcePartialContent
- (instancetype)initWithName:(NSString *)name tsName:(NSString *)tsName tsTotalLength:(NSUInteger)tsTotalLength length:(NSUInteger)length {
    self = [self initWithName:name offset:0 length:length];
    if ( self ) {
        _tsName = tsName.copy;
        _tsTotalLength = tsTotalLength;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name offset:(NSUInteger)offset {
    return [self initWithName:name offset:offset length:0];
}

- (instancetype)initWithName:(NSString *)name offset:(NSUInteger)offset length:(NSUInteger)length {
    self = [super init];
    if ( self ) {
        _lock = NSRecursiveLock.alloc.init;
        _name = name;
        _offset = offset;
        _length = length;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%s: <%p> { name: %@, offset: %lu, length: %lu };", NSStringFromClass(self.class).UTF8String, self, _name, (unsigned long)_offset, (unsigned long)self.length];
}

@synthesize length = _length;
- (void)didWriteDataWithLength:(NSUInteger)length {
    if ( length == 0 )
        return;
    
    [self lock];
    @try {
        _length += length;
        [_delegate partialContent:self didWriteDataWithLength:length];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
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
            
            [_delegate readWriteCountDidChangeForPartialContent:self];
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
    [_lock lock];
}

- (void)unlock {
    [_lock unlock];
}
@end
