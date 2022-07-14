//
//  SJSmallViewFloatingControllerDefines.h
//  Pods
//
//  Created by 畅三江 on 2019/6/6.
//

#ifndef SJSmallViewFloatingControllerDefines_h
#define SJSmallViewFloatingControllerDefines_h
@protocol SJSmallViewFloatingControllerObserverProtocol;
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJSmallViewFloatingController
- (id<SJSmallViewFloatingControllerObserverProtocol>)getObserver;

/// 开启小浮窗, 注意: 默认为 不开启
///
/// - default value is NO.
@property (nonatomic, getter=isEnabled) BOOL enabled;

/// 小浮窗视图是否已显示
///
/// - default value is NO.
@property (nonatomic, readonly) BOOL isAppeared;

/// 显示小浮窗视图
///
/// - 只有`floatingViewShouldAppear`返回YES, 小浮窗才会显示.
- (void)show;

/// 隐藏小浮窗视图
///
/// - 调用该方法将会立刻隐藏小浮窗视图.
- (void)dismiss;

/// 该block将会在`showFloatView`时被调用
///
/// - 如果返回NO, 将不显示小浮窗.
@property (nonatomic, copy, nullable) BOOL(^floatingViewShouldAppear)(id<SJSmallViewFloatingController> controller);

/// 该block将会在单击小浮窗视图时被调用
///
@property (nonatomic, copy, nullable) void(^onSingleTapped)(id<SJSmallViewFloatingController> controller);

/// 该block将会在双击小浮窗视图时被调用
///
@property (nonatomic, copy, nullable) void(^onDoubleTapped)(id<SJSmallViewFloatingController> controller);

/// 小浮窗视图是否可以移动
///
/// - default value is YES.
@property (nonatomic, getter=isSlidable) BOOL slidable;
 
@property (nonatomic, strong, readonly) __kindof UIView *floatingView; ///< float view
  
/// 以下属性由播放器维护
///
/// - target 为播放器呈现视图
/// - targetSuperview 为播放器视图
/// 当显示小浮窗时, 可以将target添加到小浮窗中
/// 当隐藏小浮窗时, 可以将target恢复到targetSuperview中
@property (nonatomic, weak, nullable) UIView *target;
@property (nonatomic, weak, nullable) UIView *targetSuperview;
@end


@protocol SJSmallViewFloatingControllerObserverProtocol
@property (nonatomic, weak, readonly, nullable) id<SJSmallViewFloatingController> controller;

@property (nonatomic, copy, nullable) void(^onAppearChanged)(id<SJSmallViewFloatingController> controller);
@property (nonatomic, copy, nullable) void(^onEnabled)(id<SJSmallViewFloatingController> controller);
@end
NS_ASSUME_NONNULL_END

#endif /* SJSmallViewFloatingControllerDefines_h */
