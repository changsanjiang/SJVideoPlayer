//
//  MCSAssetUsageLog.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSAssetUsageLog.h"

@interface MCSAssetUsageLog ()
@property (nonatomic) NSInteger id;
@property (nonatomic) NSInteger asset;
@property (nonatomic) MCSAssetType assetType;
@property (nonatomic) NSUInteger usageCount;
@property (nonatomic) NSTimeInterval updatedTime;
@property (nonatomic) NSTimeInterval createdTime;
@end

@implementation MCSAssetUsageLog

@end
