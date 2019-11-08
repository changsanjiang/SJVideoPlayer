//
//  SJFilmEditingControlLayer.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/19.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJVideoPlayerFilmEditingConfig.h"
#import "SJControlLayerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJFilmEditingControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>
@property (nonatomic, copy, nullable) void(^cancelledOperationExeBlock)(SJFilmEditingControlLayer *control);
@property (nonatomic, strong, nullable) SJVideoPlayerFilmEditingConfig *config;
@end
NS_ASSUME_NONNULL_END
