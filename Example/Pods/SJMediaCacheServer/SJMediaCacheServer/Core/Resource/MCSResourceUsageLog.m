//
//  MCSResourceUsageLog.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSResourceUsageLog.h"

@interface MCSResourceUsageLog ()
@property (nonatomic) NSInteger id;
@property (nonatomic) NSInteger resource;
@property (nonatomic) MCSResourceType resourceType;
@property (nonatomic) NSUInteger usageCount;
@property (nonatomic) NSTimeInterval updatedTime;
@property (nonatomic) NSTimeInterval createdTime;
@end

@implementation MCSResourceUsageLog

@end
