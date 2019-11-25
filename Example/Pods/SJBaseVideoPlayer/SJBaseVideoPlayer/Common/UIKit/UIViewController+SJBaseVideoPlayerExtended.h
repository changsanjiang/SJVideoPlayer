//
//  UIViewController+SJBaseVideoPlayerExtended.h
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2019/11/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^SJAnimationCompletionHandler)(void);
typedef void(^SJPresentedAnimationHandler)(__kindof UIViewController *vc, SJAnimationCompletionHandler completion);
typedef void(^SJDismissedAnimationHandler)(__kindof UIViewController *vc, SJAnimationCompletionHandler completion);

@interface UIViewController (SJBaseVideoPlayerExtended)

- (void)setTransitionDuration:(NSTimeInterval)dutaion presentedAnimation:(SJPresentedAnimationHandler)presentedAnimation dismissedAnimation:(SJDismissedAnimationHandler)dismissedAnimation;

@end
NS_ASSUME_NONNULL_END
