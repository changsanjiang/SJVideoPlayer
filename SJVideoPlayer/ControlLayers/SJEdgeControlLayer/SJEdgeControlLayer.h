//
//  SJEdgeControlLayer.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/24.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJDraggingProgressPopViewDefines.h"
#import "SJDraggingObservationDefines.h"
#import "SJControlLayerDefines.h"
#import "SJLoadingViewDefinies.h"
#import "SJScrollingTextMarqueeViewDefines.h"
#import "SJFullscreenCustomStatusBarDefines.h"
#import "SJFastForwardViewDefines.h"

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
@property (nonatomic, strong, null_resettable) __kindof UIView<SJLoadingView> *loadingView;

///
/// 拖拽进度视图
///
///     当需要自定义时, 可以实现指定的协议赋值给该控制层
///
@property (nonatomic, strong, null_resettable) __kindof UIView<SJDraggingProgressPopView> *draggingProgressPopView;

///
/// 拖拽进度观察者
///
///     拖拽开始, 移动, 完成的回调
///
@property (nonatomic, strong, readonly) id<SJDraggingObservation> draggingObserver;

///
/// 标题视图
///
///     当需要自定义时, 可以实现指定的协议赋值给该控制层
///
@property (nonatomic, strong, null_resettable) __kindof UIView<SJScrollingTextMarqueeView> *titleView;

///
/// 长按手势触发加速播放时显示的视图
///
@property (nonatomic, strong, null_resettable) UIView<SJFastForwardView> *fastForwardView;

///
/// 是否竖屏时隐藏标题
///
@property (nonatomic, getter=isHiddenTitleItemWhenOrientationIsPortrait) BOOL hiddenTitleItemWhenOrientationIsPortrait;

///
/// 是否竖屏时隐藏返回按钮
///
@property (nonatomic, getter=isHiddenBackButtonWhenOrientationIsPortrait) BOOL hiddenBackButtonWhenOrientationIsPortrait;

///
/// 是否使返回按钮常驻
///
@property (nonatomic) BOOL showResidentBackButton;

///
/// 是否禁止网络状态变化提示
///
@property (nonatomic, getter=isDisabledPromptWhenNetworkStatusChanges) BOOL disabledPromptWhenNetworkStatusChanges;

///
/// 是否隐藏底部进度条
///
@property (nonatomic, getter=isHiddenBottomProgressIndicator) BOOL hiddenBottomProgressIndicator;

///
/// 底部进度条高度. default value is 1.0
///
@property (nonatomic) CGFloat bottomProgressIndicatorHeight;

///
/// 自定义状态栏, 当 shouldShowCustomStatusBar 返回YES, 将会显示该状态栏
///
@property (nonatomic, strong, null_resettable) UIView<SJFullscreenCustomStatusBar> *customStatusBar NS_AVAILABLE_IOS(11.0);

///
/// 是否应该显示自定义状态栏
///
@property (nonatomic, copy, null_resettable) BOOL(^shouldShowCustomStatusBar)(SJEdgeControlLayer *controlLayer) NS_AVAILABLE_IOS(11.0);

@property (nonatomic, weak, nullable) id<SJEdgeControlLayerDelegate> delegate;
@end


@protocol SJEdgeControlLayerDelegate <NSObject>
- (void)backItemWasTappedForControlLayer:(id<SJControlLayer>)controlLayer;
@end


@interface SJEdgeControlButtonItem (SJControlLayerExtended)
///
/// 点击item时是否重置控制层的显示间隔
///
///     default value is YES
///
@property (nonatomic) BOOL resetAppearIntervalWhenPerformingItemAction;
@end
NS_ASSUME_NONNULL_END
