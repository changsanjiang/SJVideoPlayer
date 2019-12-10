//
//  SJFilmEditingGenerateResultControlLayer.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJVideoPlayerFilmEditingDefines.h"
#import "SJControlLayerDefines.h"

@class SJFilmEditingResultShareItem;

NS_ASSUME_NONNULL_BEGIN
@interface SJFilmEditingGenerateResultControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>
@property (nonatomic, strong, nullable) NSArray<SJFilmEditingResultShareItem *> *shareItems;
@property (nonatomic, strong, nullable) id<SJVideoPlayerFilmEditingParameters> parameters;

@property (nonatomic, copy, nullable) void(^cancelledOperationExeBlock)(SJFilmEditingGenerateResultControlLayer *control);
@property (nonatomic, copy, nullable) void(^clickedResultShareItemExeBlock)(__kindof SJBaseVideoPlayer *player, SJFilmEditingResultShareItem * item, id<SJVideoPlayerFilmEditingResult> result);
@end
NS_ASSUME_NONNULL_END
