//
//  MCSAsset+Subclass.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSAsset.h"
#import "MCSAssetUsageLog.h"
#import "MCSAssetDefines.h"
#import "MCSAssetContent.h"
@protocol MCSAssetContentDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface MCSAssetContent (MCSPrivate)<MCSReadWrite>
@property (nonatomic, weak, nullable) id<MCSAssetContentDelegate> delegate;
@property (nonatomic, readonly) NSInteger readWriteCount;
- (void)readWrite_retain;
- (void)readWrite_release;
@end

@protocol MCSAssetContentDelegate <NSObject>
- (void)readWriteCountDidChangeForPartialContent:(MCSAssetContent *)content;
- (void)partialContent:(MCSAssetContent *)content didWriteDataWithLength:(NSUInteger)length;
@end

@interface MCSAsset (Private)<MCSAssetContentDelegate>
@property (nonatomic, strong, readonly) dispatch_queue_t queue;
@property (nonatomic) NSInteger id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) MCSAssetUsageLog *log;

#pragma mark -
@property (nonatomic, readonly) NSInteger readWriteCount;
- (void)readWrite_retain;
- (void)readWrite_release;

#pragma mark -

@property (nonatomic, copy, readonly, nullable) NSArray<MCSAssetContent *> *contents;
- (void)addContents:(NSArray<MCSAssetContent *> *)contents;
- (void)addContent:(MCSAssetContent *)content;
- (void)removeContent:(MCSAssetContent *)content;
- (void)removeContents:(NSArray<MCSAssetContent *> *)contents;
- (NSString *)filePathOfContent:(MCSAssetContent *)content;
- (void)contentsDidChange:(NSArray<MCSAssetContent *> *)contents;
@end
NS_ASSUME_NONNULL_END
