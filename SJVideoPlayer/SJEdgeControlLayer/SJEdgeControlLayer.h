//
//  SJEdgeControlLayer.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/24.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJControlLayerDefines.h"

NS_ASSUME_NONNULL_BEGIN
// - Top Items -
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_Back;             // 返回按钮
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_Title;            // 标题


// - Left Items -
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerLeftItem_Lock;            // 锁屏按钮


// - Bottom Items -
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Play;          // 播放按钮
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_CurrentTime;   // 当前时间
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_DurationTime;  // 全部时长
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Separator;     // 时间分隔符(斜杠/)
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Progress;      // 播放进度条
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_FullBtn;       // 全屏按钮
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_LIVEText;      // 实时直播

// - Center Items -
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerCenterItem_Replay;        // 重播按钮


@interface SJEdgeControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>
@property (nonatomic, copy, nullable) void(^clickedBackItemExeBlock)(SJEdgeControlLayer *control);

@property (nonatomic) BOOL hideBackButtonWhenOrientationIsPortrait; // 竖屏时隐藏返回按钮
@property (nonatomic) BOOL disablePromptWhenNetworkStatusChanges; // 禁止网络状态变化提示
@property (nonatomic) BOOL hideBottomProgressSlider; // 隐藏底部进度条
@property (nonatomic) BOOL showResidentBackButton;   // 返回按钮常驻
@property (nonatomic) BOOL showNetworkSpeedToLoadingView;
@end


// - Deprecated -
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_Preview __deprecated; // 预览按钮
NS_ASSUME_NONNULL_END
