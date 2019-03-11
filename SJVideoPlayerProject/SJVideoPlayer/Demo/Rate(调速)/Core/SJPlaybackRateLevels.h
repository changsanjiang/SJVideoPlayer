//
//  SJPlaybackRateLevels.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/3/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    SJPlaybackRateLevel_1 = 100,
    SJPlaybackRateLevel_2 = 125,
    SJPlaybackRateLevel_3 = 150,
    SJPlaybackRateLevel_4 = 200
} SJPlaybackRateLevel;

@interface SJPlaybackRateLevels : NSObject
@property (nonatomic) SJPlaybackRateLevel level; // 当前等级
- (NSString *)toString:(SJPlaybackRateLevel)level;
@property (nonatomic, copy, nullable) void(^levelDidChangeExeBlock)(SJPlaybackRateLevels *s);
@end
NS_ASSUME_NONNULL_END
