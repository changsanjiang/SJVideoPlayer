//
//  MCSResource.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSResource.h"
#import "MCSFileManager.h"
#import "MCSResourceSubclass.h"
#import "MCSResourceManager.h"
#import "MCSConfiguration.h"

@interface MCSResource ()<MCSResourcePartialContentDelegate> {
    NSMutableArray<MCSResourcePartialContent *> *_m;
}
@property (nonatomic) NSInteger id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) MCSResourceUsageLog *log;
@property (nonatomic) NSInteger readWriteCount;
@property (nonatomic) BOOL isCacheFinished;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation MCSResource

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _configuration = MCSConfiguration.alloc.init;
        _queue = dispatch_get_global_queue(0, 0);
        _m = NSMutableArray.array; 
    }
    return self;
}

- (MCSResourceType)type {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
      reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
    userInfo:nil];
}

- (id<MCSResourceReader>)readerWithRequest:(NSURLRequest *)request {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
      reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
    userInfo:nil];
}
 
- (void)readWriteCountDidChangeForPartialContent:(MCSResourcePartialContent *)content {
//#ifdef DEBUG
//    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
//#endif
}

- (void)partialContent:(MCSResourcePartialContent *)content didWriteDataWithLength:(NSUInteger)length {
    [MCSResourceManager.shared didWriteDataForResource:self length:length];
}

#pragma mark -

@synthesize isCacheFinished = _isCacheFinished;
- (void)setIsCacheFinished:(BOOL)isCacheFinished {
    dispatch_barrier_sync(_queue, ^{
        self->_isCacheFinished = isCacheFinished;
    });
}

- (BOOL)isCacheFinished {
    __block BOOL isCacheFinished = NO;
    dispatch_barrier_sync(_queue, ^{
        isCacheFinished = self->_isCacheFinished;
    });
    return isCacheFinished;
}

- (nullable NSURL *)playbackURLForCacheWithURL:(NSURL *)URL {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
      reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
    userInfo:nil];
}

@synthesize readWriteCount = _readWriteCount;
- (void)setReadWriteCount:(NSInteger)readWriteCount {
    dispatch_barrier_sync(_queue, ^{
        self->_readWriteCount = readWriteCount;
    });
}

- (NSInteger)readWriteCount {
    __block NSInteger readWriteCount;
    dispatch_barrier_sync(_queue, ^{
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

#pragma mark -

- (NSArray<MCSResourcePartialContent *> *)contents {
    __block NSArray<MCSResourcePartialContent *> *contents = nil;
    dispatch_barrier_sync(_queue, ^{
        contents = self->_m.count >= 0 ? _m : nil;
    });
    return contents;
}

- (void)addContents:(NSArray<MCSResourcePartialContent *> *)contents {
    if ( contents.count != 0 ) {
        dispatch_barrier_sync(_queue, ^{
            for ( MCSResourcePartialContent *content in contents )
                content.delegate = self;
            [_m addObjectsFromArray:contents];
        });
    }
}

- (void)addContent:(MCSResourcePartialContent *)content {
    if ( content != nil ) [self addContents:@[content]];
}

- (void)removeContent:(MCSResourcePartialContent *)content {
    dispatch_barrier_sync(_queue, ^{
        [self->_m removeObject:content];
        [MCSFileManager removeContentWithName:content.filename inResource:self->_name error:NULL];
        [MCSResourceManager.shared didRemoveDataForResource:self length:content.length];
    });
}

- (NSString *)filePathOfContent:(MCSResourcePartialContent *)content {
    return [MCSFileManager getFilePathWithName:content.filename inResource:_name];
}
@end
