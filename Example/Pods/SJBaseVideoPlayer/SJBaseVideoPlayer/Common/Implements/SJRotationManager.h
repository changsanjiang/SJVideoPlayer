//
//  SJRotationManager.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJRotationManagerDefines.h"
@protocol SJRotationActionForwarder;

NS_ASSUME_NONNULL_BEGIN
@interface SJRotationManager : NSObject<SJRotationManager>
+ (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window;
+ (instancetype)rotationManager;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (id<SJRotationManagerObserver>)getObserver;

@property (nonatomic, copy, nullable) BOOL(^shouldTriggerRotation)(id<SJRotationManager> mgr);
@property (nonatomic, getter=isDisabledAutorotation) BOOL disabledAutorotation;
@property (nonatomic) SJOrientationMask autorotationSupportedOrientations;

- (void)rotate;
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated;
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void(^)(id<SJRotationManager> mgr))completionHandler;

@property (nonatomic, readonly) SJOrientation currentOrientation;
@property (nonatomic, readonly) BOOL isFullscreen;
@property (nonatomic, readonly, getter=isRotating) BOOL rotating;
@property (nonatomic, readonly, getter=isTransitioning) BOOL transitioning;
@property (nonatomic, weak, nullable) UIView *superview;
@property (nonatomic, weak, nullable) UIView *target;
@property (nonatomic, weak, nullable) id<SJRotationActionForwarder> actionForwarder;
@end

@protocol SJRotationActionForwarder <NSObject>
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIStatusBarStyle)preferredStatusBarStyle;
- (BOOL)prefersStatusBarHidden;
@end
NS_ASSUME_NONNULL_END


#pragma mark - fix safe area

NS_ASSUME_NONNULL_BEGIN
typedef NS_OPTIONS(NSUInteger, SJSafeAreaInsetsMask) {
    SJSafeAreaInsetsMaskNone = 0,
    SJSafeAreaInsetsMaskTop = 1 << 0,
    SJSafeAreaInsetsMaskLeft = 1 << 1,
    SJSafeAreaInsetsMaskBottom = 1 << 2,
    SJSafeAreaInsetsMaskRight = 1 << 3,
    
    SJSafeAreaInsetsMaskHorizontal = SJSafeAreaInsetsMaskLeft | SJSafeAreaInsetsMaskRight,
    SJSafeAreaInsetsMaskVertical = SJSafeAreaInsetsMaskTop | SJSafeAreaInsetsMaskRight,
    SJSafeAreaInsetsMaskAll = SJSafeAreaInsetsMaskHorizontal | SJSafeAreaInsetsMaskVertical
} API_DEPRECATED("deprecated!", ios(13.0, 16.0)) ;


API_DEPRECATED("deprecated!", ios(13.0, 16.0)) @interface UIViewController (SJRotationSafeAreaFixing)
/// 禁止调整哪些方向的安全区
@property (nonatomic) SJSafeAreaInsetsMask disabledAdjustSafeAreaInsetsMask;
@end
NS_ASSUME_NONNULL_END
