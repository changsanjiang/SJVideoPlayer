//
//  HLSContentTs.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/25.
//

#import "HLSContentTs.h"

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
    }
    return self;
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
