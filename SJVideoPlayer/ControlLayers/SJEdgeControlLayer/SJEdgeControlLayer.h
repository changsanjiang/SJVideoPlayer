//
//  SJEdgeControlLayer.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/24.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJDraggingProgressPopupViewDefines.h"
#import "SJDraggingObservationDefines.h"
#import "SJControlLayerDefines.h"
#import "SJLoadingViewDefines.h"
#import "SJScrollingTextMarqueeViewDefines.h"
#import "SJFullscreenModeStatusBarDefines.h"
#import "SJSpeedupPlaybackPopupViewDefines.h"
#import "SJItemTags.h"

#pragma mark - 边缘控制层

@protocol SJEdgeControlLayerDelegate;

NS_ASSUME_NONNULL_BEGIN
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
@property (nonatomic, strong, null_resettable) __kindof UIView<SJDraggingProgressPopupView> *draggingProgressPopupView;

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
/// 长按手势触发加速播放时弹出的视图
///
@property (nonatomic, strong, null_resettable) UIView<SJSpeedupPlaybackPopupView> *speedupPlaybackPopupView;

///
/// 当设备支持画中画时, 自动显示画中画按钮. default value is Yes
///
@property (nonatomic) BOOL automaticallyShowsPictureInPictureItem API_AVAILABLE(ios(14.0));

///
/// 是否竖屏时隐藏标题
///
@property (nonatomic, getter=isHiddenTitleItemWhenOrientationIsPortrait) BOOL hiddenTitleItemWhenOrientationIsPortrait;

///
/// 是否竖屏时隐藏返回按钮
///
@property (nonatomic, getter=isHiddenBackButtonWhenOrientationIsPortrait) BOOL hiddenBackButtonWhenOrientationIsPortrait;

///
/// 是否将返回按钮固定
///
@property (nonatomic) BOOL fixesBackItem;

///
/// 是否禁止网络状态变化提示
///
@property (nonatomic, getter=isDisabledPromptingWhenNetworkStatusChanges) BOOL disabledPromptingWhenNetworkStatusChanges;

///
/// 是否隐藏底部进度条
///
@property (nonatomic, getter=isHiddenBottomProgressIndicator) BOOL hiddenBottomProgressIndicator;

///
/// 底部进度条高度. default value is 1.0
///
@property (nonatomic) CGFloat bottomProgressIndicatorHeight;

///
/// 自定义状态栏, 当 shouldShowsCustomStatusBar 返回YES, 将会显示该状态栏
///
@property (nonatomic, strong, null_resettable) UIView<SJFullscreenModeStatusBar> *customStatusBar NS_AVAILABLE_IOS(11.0);

///
/// 是否应该显示自定义状态栏
///
@property (nonatomic, copy, null_resettable) BOOL(^shouldShowsCustomStatusBar)(SJEdgeControlLayer *controlLayer) NS_AVAILABLE_IOS(11.0);

///
/// 是否自动选择`Rotation(旋转)`或`FitOnScreen(充满全屏)`
///
/// - Rotation(旋转): 播放器视图将会在横屏(全屏)与竖屏(小屏)之间切换
///
/// - FitOnScreen(充满全屏): 播放器视图将会在竖屏全屏与竖屏小屏之间切换
///
///     当视频`宽 > 高`时, 将执行 Rotation 相关方法.
///     当视频`宽 < 高`时, 将执行 FitOnScreen 相关方法.
///
@property (nonatomic) BOOL automaticallyPerformRotationOrFitOnScreen;

///
/// 处于小屏时, 当点击全屏按钮后, 是否先竖屏撑满全屏.
///
@property (nonatomic) BOOL needsFitOnScreenFirst;

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
@property (nonatomic) BOOL resetsAppearIntervalWhenPerformingItemAction;
@end
NS_ASSUME_NONNULL_END
