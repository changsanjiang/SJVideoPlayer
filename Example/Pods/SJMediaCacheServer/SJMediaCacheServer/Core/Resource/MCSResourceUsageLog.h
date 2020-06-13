//
//  MCSResourceUsageLog.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSResourceUsageLog : NSObject
@property (nonatomic, readonly) NSInteger id;
@property (nonatomic, readonly) NSInteger resource;
@property (nonatomic, readonly) MCSResourceType resourceType;
@property (nonatomic, readonly) NSUInteger usageCount;
@property (nonatomic, readonly) NSTimeInterval updatedTime;
@property (nonatomic, readonly) NSTimeInterval createdTime;
@end

NS_ASSUME_NONNULL_END
