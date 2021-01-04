//
//  SJClipsResultsControlLayer.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJVideoPlayerClipsDefines.h"
#import "SJControlLayerDefines.h"

@class SJClipsResultShareItem;

NS_ASSUME_NONNULL_BEGIN
@interface SJClipsResultsControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>
@property (nonatomic, strong, nullable) NSArray<SJClipsResultShareItem *> *shareItems;
@property (nonatomic, strong, nullable) id<SJVideoPlayerClipsParameters> parameters;

@property (nonatomic, copy, nullable) void(^cancelledOperationExeBlock)(SJClipsResultsControlLayer *control);
@property (nonatomic, copy, nullable) void(^clickedResultShareItemExeBlock)(__kindof SJBaseVideoPlayer *player, SJClipsResultShareItem * item, id<SJVideoPlayerClipsResult> result);
@end
NS_ASSUME_NONNULL_END
