//
//  SJEdgeControlLayer.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/24.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJControlLayerDefines.h"
#import "SJEdgeControlLayerLoadingViewDefines.h"
@protocol SJEdgeControlLayerDelegate;

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

///
/// loading 视图
///
///     当需要自定义时, 可以实现指定的协议赋值给该控制层
///
@property (nonatomic, strong, null_resettable) id<SJEdgeControlLayerLoadingViewProtocol> loadingView;

///
/// 是否竖屏时隐藏返回按钮
///
@property (nonatomic, getter=isHiddenBackButtonWhenOrientationIsPortrait) BOOL hiddenBackButtonWhenOrientationIsPortrait;

///
/// 是否禁止网络状态变化提示
///
@property (nonatomic, getter=isDisabledPromptWhenNetworkStatusChanges) BOOL disabledPromptWhenNetworkStatusChanges;

///
/// 是否使返回按钮常驻
///
@property (nonatomic) BOOL showResidentBackButton;

///
/// 是否隐藏底部进度条
///
@property (nonatomic, getter=isHiddenBottomProgressIndicator) BOOL hiddenBottomProgressIndicator;

///
/// 底部进度条高度. default value is 1.0
///
@property (nonatomic) CGFloat bottomProgressIndicatorHeight;

///
/// 是否在loadingView上显示网速. default value is YES
///
@property (nonatomic) BOOL showNetworkSpeedToLoadingView;


@property (nonatomic, weak, nullable) id<SJEdgeControlLayerDelegate> delegate;
@end


@protocol SJEdgeControlLayerDelegate <NSObject>
- (void)backItemWasTappedForControlLayer:(id<SJControlLayer>)controlLayer;
@end
NS_ASSUME_NONNULL_END
