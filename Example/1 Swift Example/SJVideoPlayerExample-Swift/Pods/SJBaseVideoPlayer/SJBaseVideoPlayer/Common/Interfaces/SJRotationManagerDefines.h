//
//  SJRotationManagerDefines.h
//  Pods
//
//  Created by 畅三江 on 2018/9/19.
//

#ifndef SJRotationManagerProtocol_h
#define SJRotationManagerProtocol_h

#import <UIKit/UIKit.h>
@protocol SJRotationManager, SJRotationManagerObserver;
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

typedef enum : NSUInteger {
    SJOrientationMaskPortrait = 1 << SJOrientation_Portrait,
    SJOrientationMaskLandscapeLeft = 1 << SJOrientation_LandscapeLeft,
    SJOrientationMaskLandscapeRight = 1 << SJOrientation_LandscapeRight,
    SJOrientationMaskAll = SJOrientationMaskPortrait | SJOrientationMaskLandscapeLeft | SJOrientationMaskLandscapeRight,
} SJOrientationMask;

NS_ASSUME_NONNULL_BEGIN
@protocol SJRotationManager<NSObject>
- (id<SJRotationManagerObserver>)getObserver;


@property (nonatomic, copy, nullable) BOOL(^shouldTriggerRotation)(id<SJRotationManager> mgr);

///
/// 是否禁止自动旋转
/// - 该属性只会禁止自动旋转, 当调用 rotate 等方法还是可以旋转的
/// - 默认为 false
///
@property (nonatomic, getter=isDisabledAutorotation) BOOL disabledAutorotation;

///
/// 自动旋转时, 所支持的方法
/// - 默认为 .all
///
@property (nonatomic) SJOrientationMask autorotationSupportedOrientations;

///
/// 旋转
/// - Animated
///
- (void)rotate;

///
/// 旋转到指定方向
///
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated;

///
/// 旋转到指定方向
///
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void(^)(id<SJRotationManager> mgr))completionHandler;

///
/// 当前的方向
///
@property (nonatomic, readonly) SJOrientation currentOrientation;

///
/// 是否全屏
/// - landscapeRight 或者 landscapeLeft 即为全屏
///
@property (nonatomic, readonly) BOOL isFullscreen;
@property (nonatomic, readonly, getter=isTransitioning) BOOL transitioning; // 是否正在旋转


///
/// 以下属性由播放器维护
///
@property (nonatomic, weak, nullable) UIView *superview;
@property (nonatomic, weak, nullable) UIView *target;
@end

@protocol SJRotationManagerProtocol <SJRotationManager> @end

@protocol SJRotationManagerObserver <NSObject>
@property (nonatomic, copy, nullable) void(^rotationDidStartExeBlock)(id<SJRotationManager> mgr);
@property (nonatomic, copy, nullable) void(^rotationDidEndExeBlock)(id<SJRotationManager> mgr);
@end
NS_ASSUME_NONNULL_END
#endif
