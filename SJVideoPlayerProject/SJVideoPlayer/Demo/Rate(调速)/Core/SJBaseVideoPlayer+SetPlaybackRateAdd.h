//
//  SJBaseVideoPlayer+SetPlaybackRateAdd.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/3/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJBaseVideoPlayer.h"
#import "SJPlaybackRateLevels.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJBaseVideoPlayer (SetPlaybackRateAdd)
@property (nonatomic, strong, readonly) SJPlaybackRateLevels *rateLevels;
@end
NS_ASSUME_NONNULL_END
