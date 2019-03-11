//
//  SJSetPlaybackRateControlLayer.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/3/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJControlLayerCarrier.h"
#import "SJPlaybackRateLevels.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJSetPlaybackRateControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>
@property (nonatomic, copy, nullable) void(^clickedEmptyAreaExeBlock)(void);
@property (nonatomic, copy, nullable) void(^clickedLevelItemExeBlock)(SJPlaybackRateLevel level);
@end
NS_ASSUME_NONNULL_END
