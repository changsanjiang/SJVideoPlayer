//
//  UIViewController+SJBaseVideoPlayerExtended.m
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/11/23.
//

#import "UIViewController+SJBaseVideoPlayerExtended.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, SJModalAction) {
    SJModalActionPresented = 0,
    SJModalActionDismissed = 1
};

@interface SJModalPresentationHandler : NSObject
@property (nonatomic, weak, nullable) UIViewController *modalViewController;
@property (nonatomic) NSTimeInterval transitionDuration;
@property (nonatomic, copy, nullable) SJPresentedAnimationHandler presentedAnimationHandler;
@property (nonatomic, copy, nullable) SJDismissedAnimationHandler dismissedAnimationHandler;
@end

@interface SJModalPresentationHandler ()<UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>
@property (nonatomic) SJModalAction state;
@end

@implementation SJModalPresentationHandler
- (void)setModalViewController:(nullable UIViewController *)modalViewController {
    _modalViewController = modalViewController;
    modalViewController.transitioningDelegate  = self;
    modalViewController.modalPresentationStyle = UIModalPresentationCustom;
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return self.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.state) {
        case SJModalActionPresented: {
            UIView *containerView = [transitionContext containerView];
            UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
            toView.frame = containerView.bounds;
            toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [containerView addSubview:toView];
            
            if ( self.presentedAnimationHandler ) self.presentedAnimationHandler(self.modalViewController, ^{
                [transitionContext completeTransition:YES];
            });
        }
            break;
        case SJModalActionDismissed: {
            if ( self.dismissedAnimationHandler ) self.dismissedAnimationHandler(self.modalViewController, ^{
                [transitionContext completeTransition:YES];
            });
        }
            break;
        default: break;
    }
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.state = SJModalActionPresented;
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.state = SJModalActionDismissed;
    return self;
}
@end

@implementation UIViewController (SJBaseVideoPlayerExtended)
static void *defautKey = &defautKey;

///
/// 设置转场时间, 设置呈现的动画及消失的动画
///
- (void)setTransitionDuration:(NSTimeInterval)dutaion presentedAnimation:(SJPresentedAnimationHandler)presentedAnimation dismissedAnimation:(SJDismissedAnimationHandler)dismissedAnimation {
    SJModalPresentationHandler *_Nullable handler = objc_getAssociatedObject(self, defautKey);
    if ( handler == nil ) {
        handler = SJModalPresentationHandler.alloc.init;
        objc_setAssociatedObject(self, defautKey, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    handler.modalViewController = self;
    handler.transitionDuration = dutaion;
    handler.presentedAnimationHandler = presentedAnimation;
    handler.dismissedAnimationHandler = dismissedAnimation;
}
@end
NS_ASSUME_NONNULL_END
