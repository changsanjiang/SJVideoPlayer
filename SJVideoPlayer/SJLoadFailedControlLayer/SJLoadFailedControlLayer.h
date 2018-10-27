//
//  SJLoadFailedControlLayer.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/27.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#if __has_include(<SJBaseVideoPlayer/SJVideoPlayerControlLayerProtocol.h>)
#import <SJBaseVideoPlayer/SJVideoPlayerControlLayerProtocol.h>
#else
#import "SJVideoPlayerControlLayerProtocol.h"
#endif

NS_ASSUME_NONNULL_BEGIN
extern SJEdgeControlButtonItemTag const SJLoadFailedControlLayerTopItem_Back;             // 返回按钮

@interface SJLoadFailedControlLayer : SJEdgeControlLayerAdapters<SJVideoPlayerControlLayerDelegate, SJVideoPlayerControlLayerDataSource>
- (void)restartControlLayer;
- (void)exitControlLayer;

@property (nonatomic, copy, nullable) void(^clickedBackItemExeBlock)(SJLoadFailedControlLayer *control);
@property (nonatomic, copy, nullable) void(^clickedFaliedButtonExeBlock)(SJLoadFailedControlLayer *control);
@end
NS_ASSUME_NONNULL_END
