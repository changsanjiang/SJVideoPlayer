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
#import "MCSQueue.h"

@interface MCSResource ()<MCSResourcePartialContentDelegate>
@property (nonatomic) NSInteger id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) MCSResourceUsageLog *log;
@property (nonatomic) NSInteger readWriteCount;
@property (nonatomic) BOOL isCacheFinished;
@end

@implementation MCSResource

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _configuration = MCSConfiguration.alloc.init;
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

- (BOOL)isCacheFinished {
    __block BOOL isCacheFinished = NO;
    dispatch_sync(MCSResourceQueue(), ^{
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
    dispatch_barrier_sync(MCSResourceQueue(), ^{
        self->_readWriteCount = readWriteCount;
    });
}

- (NSInteger)readWriteCount {
    __block NSInteger readWriteCount;
    dispatch_sync(MCSResourceQueue(), ^{
        readWriteCount = self->_readWriteCount;
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
    dispatch_sync(MCSResourceQueue(), ^{
        contents = self->_m.count > 0 ? self->_m.copy : nil;
    });
    return contents;
}

- (void)addContents:(NSArray<MCSResourcePartialContent *> *)contents {
    if ( contents.count != 0 ) {
        dispatch_barrier_sync(MCSResourceQueue(), ^{
            for ( MCSResourcePartialContent *content in contents )
                content.delegate = self;
            [self->_m addObjectsFromArray:contents];
            [self contentsDidChange:self->_m.copy];
        });
    }
}

- (void)addContent:(MCSResourcePartialContent *)content {
    if ( content != nil ) [self addContents:@[content]];
}

- (void)removeContent:(MCSResourcePartialContent *)content {
    if ( content != nil ) {
        [self removeContents:@[content]];
    }
}

- (void)removeContents:(NSArray<MCSResourcePartialContent *> *)contents {
    __block NSUInteger length = 0;
    dispatch_barrier_sync(MCSResourceQueue(), ^{
        for ( MCSResourcePartialContent *content in contents ) {
            length += content.length;
            [MCSFileManager removeContentWithName:content.filename inResource:_name error:NULL];
        }
        [self->_m removeObjectsInArray:contents];
        [self contentsDidChange:self->_m.copy];
    });
    [MCSResourceManager.shared didRemoveDataForResource:self length:length];
}

- (NSString *)filePathOfContent:(MCSResourcePartialContent *)content {
    return [MCSFileManager getFilePathWithName:content.filename inResource:_name];
}

- (void)contentsDidChange:(NSArray<MCSResourcePartialContent *> *)contents {
    /* subclass */
}
@end
