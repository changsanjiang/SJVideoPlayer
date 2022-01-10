//
//  SJFloatSmallViewTransitionController.h
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2021/1/13.
//  Copyright © 2021 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJFloatSmallViewController.h"
@protocol SJFloatSmallView;

NS_ASSUME_NONNULL_BEGIN
@interface SJFloatSmallViewTransitionController : NSObject<SJFloatSmallViewController>
- (void)resume;
@property (nonatomic, strong, null_resettable) __kindof UIView<SJFloatSmallView> *floatView;
@property (nonatomic) BOOL ignoreSafeAreaInsets API_AVAILABLE(ios(11.0));
/// default value is SJFloatViewLayoutPositionBottomRight.
@property (nonatomic) SJFloatViewLayoutPosition layoutPosition;
/// default value is UIEdgeInsetsMake(20, 12, 20, 12).
@property (nonatomic) UIEdgeInsets layoutInsets;
@property (nonatomic) CGSize layoutSize;
/// vc退出时, 是否自动进入小浮窗模式. 默认 YES
@property (nonatomic) BOOL automaticallyEnterFloatingMode;
@end

@interface UIViewController (SJFloatSmallViewTransitionControllerExtended)
@property (nonatomic, strong, readonly, nullable) SJFloatSmallViewTransitionController *floatSmallViewTransitionController;
@end

@interface UIWindow (SJFloatSmallViewTransitionControllerExtended)
/// 当前处于悬浮播放状态的视图控制器
- (NSArray<__kindof UIViewController *> *_Nullable)SVTC_playbackInFloatingViewControllers;
@end

@protocol SJFloatSmallView <NSObject>
// The player view will be added to the container view.
@property (nonatomic, strong, readonly) UIView *containerView;
@end
NS_ASSUME_NONNULL_END
