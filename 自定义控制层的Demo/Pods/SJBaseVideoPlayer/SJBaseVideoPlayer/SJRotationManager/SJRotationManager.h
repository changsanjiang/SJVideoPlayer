//
//  SJRotationManager.h
//  SJOrentationObserverProject
//
//  Created by 畅三江 on 2018/6/25.
//  Copyright © 2018年 SanJiang. All rights reserved.
//
//  https://github.com/changsanjiang/SJOrentationObserver
//  changsanjiang@gmail.com
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SJRotationManager;

@protocol SJRotationManagerDelegate<NSObject>
/// 将要旋转
- (void)rotationManager:(SJRotationManager *)manager willRotateView:(BOOL)isFullscreen;
/// 完成旋转
- (void)rotationManager:(SJRotationManager *)manager didRotateView:(BOOL)isFullscreen;
@end

/**
 视图方向
 
 - SJOrientation_Portrait:       竖屏
 - SJOrientation_LandscapeLeft:  全屏, Home键在右侧
 - SJOrientation_LandscapeRight: 全屏, Home键在左侧
 */
typedef NS_ENUM(NSUInteger, SJOrientation) {
    SJOrientation_Portrait,
    SJOrientation_LandscapeLeft,  // UIDeviceOrientationLandscapeLeft
    SJOrientation_LandscapeRight, // UIDeviceOrientationLandscapeRight
};

/**
 自动旋转支持的方向
 
 - SJAutoRotateSupportedOrientation_Portrait:       竖屏
 - SJAutoRotateSupportedOrientation_LandscapeLeft:  支持全屏, Home键在右侧
 - SJAutoRotateSupportedOrientation_LandscapeRight: 支持全屏, Home键在左侧
 - SJAutoRotateSupportedOrientation_All:            全部方向
 */
typedef NS_ENUM(NSUInteger, SJAutoRotateSupportedOrientation) {
    SJAutoRotateSupportedOrientation_Portrait = 1 << 0,
    SJAutoRotateSupportedOrientation_LandscapeLeft = 1 << 1,  // UIDeviceOrientationLandscapeLeft
    SJAutoRotateSupportedOrientation_LandscapeRight = 1 << 2, // UIDeviceOrientationLandscapeRight
    SJAutoRotateSupportedOrientation_All = SJAutoRotateSupportedOrientation_Portrait | SJAutoRotateSupportedOrientation_LandscapeLeft | SJAutoRotateSupportedOrientation_LandscapeRight,
};

@interface SJRotationManager : NSObject

/// 实例化一个旋转管理对象
///
/// - Parameters:
///   - target:     目标视图, 用来旋转的视图
///   - superview:  父视图, 旋转视图的父视图
///
/// - 注意:
///   - 目标视图(target)的大小需与父视图相等, 如下:
///     ```Swift
///         // - 使用frame布局时:
///         target.frame = superview.bounds
///
///         // - 使用autolayout布局时:
///         target.snp.makeConstraints { (make) in
///             make.edges.equalTo(superview)
///         }
///     ```
- (instancetype)initWithTarget:(__weak UIView *)target
                     superview:(__weak UIView *)superview
             rotationCondition:(BOOL(^)(SJRotationManager *observer))rotationCondition;

/// The block invoked when orientation will changed, if return YES, auto rotate will be triggered
@property (nonatomic, copy) BOOL(^rotationCondition)(SJRotationManager *observer);

@property (nonatomic, weak) id <SJRotationManagerDelegate> delegate;

/// 是否禁止自动旋转
/// - 该属性只会禁止自动旋转, 当调用 rotate 等方法还是可以旋转的
/// - 默认为 false
@property (nonatomic) BOOL disableAutorotation;

/// 自动旋转时, 所支持的方法
/// - 默认为 .all
@property (nonatomic) SJAutoRotateSupportedOrientation autorotationSupportedOrientation;

/// 动画持续的时间
/// - 默认是 0.4
@property (nonatomic) NSTimeInterval duration;

/// 当前的方向
@property (nonatomic, readonly) SJOrientation currentOrientation;

/// 是否全屏
/// - landscapeRight 或者 landscapeLeft 即为全屏
@property (nonatomic, readonly) BOOL isFullscreen;

/// 是否正在旋转
@property (nonatomic, readonly) BOOL transitioning;

/// 旋转
/// - Animated
- (void)rotate;

/// 旋转到指定方向
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated;

/// 旋转到指定方向
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void(^)(SJRotationManager *mgr))completionHandler;

@end
NS_ASSUME_NONNULL_END
