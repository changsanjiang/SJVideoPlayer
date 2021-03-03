//
//  HLSContentTs.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/25.
//

#import "HLSContentTs.h"

@interface HLSContentTs ()
@property (nonatomic) NSRange range;
@end

@implementation HLSContentTs {
    dispatch_semaphore_t _lock;
}
@synthesize readwriteCount = _readwriteCount;
@synthesize length = _length;

- (instancetype)initWithName:(NSString *)name filename:(NSString *)filename totalLength:(long long)totalLength {
    return [self initWithName:name filename:filename totalLength:totalLength length:0];
}

- (instancetype)initWithName:(NSString *)name filename:(NSString *)filename totalLength:(long long)totalLength length:(long long)length {
    self = [super init];
    if ( self ) {
        _lock = dispatch_semaphore_create(1);
        _name = name.copy;
        _filename = filename.copy;
        _totalLength = totalLength;
        _length = length;
        _range = NSMakeRange(0, totalLength);
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { name: %@, filename: %@, totalLength: %llu, length: %llu range: %@\n };", NSStringFromClass(self.class), self, _name, _filename, _totalLength, _length, NSStringFromRange(_range)];
}

/// #EXTINF:3.951478,
/// #EXT-X-BYTERANGE:1544984@1007868
+ (instancetype)TsWithName:(NSString *)name filename:(NSString *)filename totalLength:(long long)totalLength inRange:(NSRange)range {
    return [HLSContentTs TsWithName:name filename:filename totalLength:totalLength inRange:range length:0];
}

/// #EXTINF:3.951478,
/// #EXT-X-BYTERANGE:1544984@1007868
+ (instancetype)TsWithName:(NSString *)name filename:(NSString *)filename totalLength:(long long)totalLength inRange:(NSRange)range length:(long long)length {
    HLSContentTs *ts = [HLSContentTs.alloc initWithName:name filename:filename totalLength:totalLength length:length];
    ts.range = range;
    return ts;
}

- (void)didWriteDataWithLength:(NSUInteger)length {
    [self willChangeValueForKey:@"length"];
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _length += length;
    dispatch_semaphore_signal(_lock);
    [self didChangeValueForKey:@"length"];
}

- (long long)length {
    __block long long length = 0;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    length = _length;
    dispatch_semaphore_signal(_lock);
    return length;
}

- (NSInteger)readwriteCount {
    __block NSInteger readwriteCount = 0;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    readwriteCount = _readwriteCount;
    dispatch_semaphore_signal(_lock);
    return readwriteCount;
}

- (void)readwriteRetain {
    [self willChangeValueForKey:@"readwriteCount"];
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _readwriteCount += 1;
    dispatch_semaphore_signal(_lock);
    [self didChangeValueForKey:@"readwriteCount"];
}

- (void)readwriteRelease {
    [self willChangeValueForKey:@"readwriteCount"];
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if ( _readwriteCount > 0 )
        _readwriteCount -= 1;
    dispatch_semaphore_signal(_lock);
    [self didChangeValueForKey:@"readwriteCount"];
}
@end
