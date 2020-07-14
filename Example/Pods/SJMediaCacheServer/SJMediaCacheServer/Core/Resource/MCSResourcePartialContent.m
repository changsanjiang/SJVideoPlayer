//
//  MCSResourcePartialContent.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSResourcePartialContent.h"
#import "MCSResourceSubclass.h"

@interface MCSResourcePartialContent ()
@property (nonatomic, weak, nullable) id<MCSResourcePartialContentDelegate> delegate;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic) NSInteger readWriteCount;
@property (nonatomic, copy) NSString *tsName;
@property (nonatomic) NSUInteger tsTotalLength;
@property (nonatomic, strong) dispatch_queue_t queue;

- (void)readWrite_retain;
- (void)readWrite_release;
@end

@implementation MCSResourcePartialContent
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
        _filename = filename;
        _offset = offset;
        _length = length;
        _queue = dispatch_get_global_queue(0, 0);
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%s: <%p> { name: %@, offset: %lu, length: %lu };", NSStringFromClass(self.class).UTF8String, self, _filename, (unsigned long)_offset, (unsigned long)self.length];
}

@synthesize delegate = _delegate;
- (void)setDelegate:(nullable id<MCSResourcePartialContentDelegate>)delegate {
    dispatch_barrier_sync(_queue, ^{
        self->_delegate = delegate;
    });
}
- (nullable id<MCSResourcePartialContentDelegate>)delegate {
    __block id<MCSResourcePartialContentDelegate> delegate;
    dispatch_sync(_queue, ^{
        delegate = _delegate;
    });
    return delegate;
}

@synthesize length = _length;
- (void)didWriteDataWithLength:(NSUInteger)length {
    if ( length == 0 )
        return;
    
    dispatch_barrier_sync(_queue, ^{
        _length += length;
    });
    [self->_delegate partialContent:self didWriteDataWithLength:length];
}

- (NSUInteger)length {
    __block NSUInteger length;
    dispatch_sync(_queue, ^{
        length = _length;
    });
    return length;
}

@synthesize readWriteCount = _readWriteCount;
- (void)setReadWriteCount:(NSInteger)readWriteCount {
    dispatch_barrier_sync(_queue, ^{
        _readWriteCount = readWriteCount;;
    });
    [self->_delegate readWriteCountDidChangeForPartialContent:self];
}

- (NSInteger)readWriteCount {
    __block NSInteger readWriteCount;
    dispatch_sync(_queue, ^{
        readWriteCount = _readWriteCount;
    });
    return readWriteCount;
}
 
- (void)readWrite_retain {
    self.readWriteCount += 1;
}

- (void)readWrite_release {
    self.readWriteCount -= 1;
}
@end
