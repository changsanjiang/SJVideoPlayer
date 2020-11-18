//
//  MCSAsset.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSAsset.h"
#import "MCSFileManager.h"
#import "MCSAssetSubclass.h"
#import "MCSAssetManager.h"
#import "MCSConfiguration.h"
#import "MCSQueue.h"

@interface MCSAsset ()<MCSAssetContentDelegate>
@property (nonatomic) NSInteger id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) MCSAssetUsageLog *log;
@property (nonatomic) NSInteger readWriteCount;
@property (nonatomic) BOOL isCacheFinished;
@end

@implementation MCSAsset

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _configuration = MCSConfiguration.alloc.init;
        _m = NSMutableArray.array;
    }
    return self;
} 

- (MCSAssetType)type {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
      reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
    userInfo:nil];
}

- (id<MCSAssetReader>)readerWithRequest:(NSURLRequest *)request {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
      reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
    userInfo:nil];
}
 
- (void)readWriteCountDidChangeForPartialContent:(MCSAssetContent *)content {
//#ifdef DEBUG
//    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
//#endif
}

- (void)partialContent:(MCSAssetContent *)content didWriteDataWithLength:(NSUInteger)length {
    [MCSAssetManager.shared didWriteDataForAsset:self length:length];
}

#pragma mark -

- (BOOL)isCacheFinished {
    __block BOOL isCacheFinished = NO;
    dispatch_sync(MCSAssetQueue(), ^{
        isCacheFinished = self->_isCacheFinished;
    });
    return isCacheFinished;
}

- (nullable NSURL *)playbackURLForCacheWithURL:(NSURL *)URL {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
      reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
    userInfo:nil];
}

- (void)prepareContents {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
      reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
    userInfo:nil];
}

@synthesize readWriteCount = _readWriteCount;
- (void)setReadWriteCount:(NSInteger)readWriteCount {
    dispatch_barrier_sync(MCSAssetQueue(), ^{
        self->_readWriteCount = readWriteCount;
    });
}

- (NSInteger)readWriteCount {
    __block NSInteger readWriteCount;
    dispatch_sync(MCSAssetQueue(), ^{
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

- (NSArray<MCSAssetContent *> *)contents {
    __block NSArray<MCSAssetContent *> *contents = nil;
    dispatch_sync(MCSAssetQueue(), ^{
        contents = self->_m.count > 0 ? self->_m.copy : nil;
    });
    return contents;
}

- (void)addContents:(NSArray<MCSAssetContent *> *)contents {
    if ( contents.count != 0 ) {
        dispatch_barrier_sync(MCSAssetQueue(), ^{
            for ( MCSAssetContent *content in contents )
                content.delegate = self;
            [self->_m addObjectsFromArray:contents];
            [self contentsDidChange:self->_m.copy];
        });
    }
}

- (void)addContent:(MCSAssetContent *)content {
    if ( content != nil ) [self addContents:@[content]];
}

- (void)removeContent:(MCSAssetContent *)content {
    if ( content != nil ) {
        [self removeContents:@[content]];
    }
}

- (void)removeContents:(NSArray<MCSAssetContent *> *)contents {
    __block NSUInteger length = 0;
    dispatch_barrier_sync(MCSAssetQueue(), ^{
        for ( MCSAssetContent *content in contents ) {
            length += content.length;
            [MCSFileManager removeContentWithName:content.filename inAsset:_name error:NULL];
        }
        [self->_m removeObjectsInArray:contents];
        [self contentsDidChange:self->_m.copy];
    });
    [MCSAssetManager.shared didRemoveDataForAsset:self length:length];
}

- (NSString *)filePathOfContent:(MCSAssetContent *)content {
    return [MCSFileManager getFilePathWithName:content.filename inAsset:_name];
}

- (void)contentsDidChange:(NSArray<MCSAssetContent *> *)contents {
    /* subclass */
}
@end
