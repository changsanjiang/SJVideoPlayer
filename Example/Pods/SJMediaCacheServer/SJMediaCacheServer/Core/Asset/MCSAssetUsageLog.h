//
//  MCSAssetUsageLog.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSInterfaces.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSAssetUsageLog : NSObject<MCSSaveable>
- (instancetype)initWithAsset:(id<MCSAsset>)asset;
@property (nonatomic, readonly) NSInteger id;
@property (nonatomic, readonly) NSInteger asset;
@property (nonatomic, readonly) MCSAssetType assetType;
@property (nonatomic, readonly) NSUInteger usageCount;
@property (nonatomic, readonly) NSTimeInterval updatedTime;
@property (nonatomic, readonly) NSTimeInterval createdTime;
@end

NS_ASSUME_NONNULL_END
