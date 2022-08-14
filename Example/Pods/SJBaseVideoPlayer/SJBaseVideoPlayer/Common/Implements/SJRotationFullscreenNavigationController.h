//
//  SJRotationFullscreenNavigationController.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SJRotationFullscreenNavigationControllerDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJRotationFullscreenNavigationController : UINavigationController
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController delegate:(nullable id<SJRotationFullscreenNavigationControllerDelegate>)delegate;
@end


@protocol SJRotationFullscreenNavigationControllerDelegate <NSObject>
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end
NS_ASSUME_NONNULL_END
