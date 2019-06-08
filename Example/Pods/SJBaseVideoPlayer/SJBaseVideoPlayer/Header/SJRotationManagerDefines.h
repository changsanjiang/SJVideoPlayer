//
//  SJRotationManagerDefines.h
//  Pods
//
//  Created by 畅三江 on 2018/9/19.
//

#ifndef SJRotationManagerProtocol_h
#define SJRotationManagerProtocol_h

#import <UIKit/UIKit.h>
@protocol SJRotationManagerProtocol, SJRotationManagerObserver;
@class SJPlayModel;
/**
 视图方向
 
 - SJOrientation_Portrait:       竖屏
 - SJOrientation_LandscapeLeft:  全屏, Home键在右侧
 - SJOrientation_LandscapeRight: 全屏, Home键在左侧
 */
typedef NS_ENUM(NSUInteger, SJOrientation) {
    SJOrientation_Portrait = UIDeviceOrientationPortrait,
    SJOrientation_LandscapeLeft = UIDeviceOrientationLandscapeLeft,
    SJOrientation_LandscapeRight = UIDeviceOrientationLandscapeRight,
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

NS_ASSUME_NONNULL_BEGIN
@protocol SJRotationManagerProtocol<NSObject>
- (id<SJRotationManagerObserver>)getObserver;

/// The block invoked when orientation will changed, if return YES, auto rotate will be triggered
@property (nonatomic, copy, nullable) BOOL(^shouldTriggerRotation)(id<SJRotationManagerProtocol> mgr);

/// 旋转
/// - Animated
- (void)rotate;

/// 旋转到指定方向
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated;

/// 旋转到指定方向
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void(^)(id<SJRotationManagerProtocol> mgr))completionHandler;

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
@property (nonatomic, readonly, getter=isTransitioning) BOOL transitioning; // 是否正在旋转
@property (nonatomic, weak, nullable) UIView *superview;
@property (nonatomic, weak, nullable) UIView *target;
@end


@protocol SJRotationManagerObserver <NSObject>
@property (nonatomic, copy, nullable) void(^rotationDidStartExeBlock)(id<SJRotationManagerProtocol> mgr);
@property (nonatomic, copy, nullable) void(^rotationDidEndExeBlock)(id<SJRotationManagerProtocol> mgr);
@end
NS_ASSUME_NONNULL_END
#endif
