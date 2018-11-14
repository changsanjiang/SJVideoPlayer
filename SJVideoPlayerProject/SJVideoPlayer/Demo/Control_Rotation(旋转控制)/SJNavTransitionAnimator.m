//
//  SJNavTransitionAnimator.m
//  SJTransitionAnimator
//
//  Created by BlueDancer on 2017/12/19.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJNavTransitionAnimator.h"

@interface SJNavTransitionAnimator ()<UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning>
@property (nonatomic) UINavigationControllerOperation operation;
@property (nonatomic, copy) SJNavTransitionAnimation pushAnimation;
@property (nonatomic, copy) SJNavTransitionAnimation popAnimation;
@end

@implementation SJNavTransitionAnimator {
    CGRect _fromViewRect;
}
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _duration = 0.3;
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    _operation = operation;
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return _duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    switch ( _operation ) {
        case UINavigationControllerOperationNone: break;
        case UINavigationControllerOperationPush: {
            UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
            [transitionContext.containerView addSubview:toView];
            UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
            _fromViewRect = fromView.frame;
            if ( _pushAnimation ) _pushAnimation(self, transitionContext, toView, fromView);
        }
            break;
        case UINavigationControllerOperationPop: {
            UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
            UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
            toView.frame = _fromViewRect;
            [transitionContext.containerView insertSubview:toView belowSubview:fromView];
            if ( _popAnimation ) _popAnimation(self, transitionContext, toView, fromView);
        }
            break;
    }
}

- (void)setNavigationController:(UINavigationController *)navigationController {
    if ( navigationController == _navigationController ) return;
    _navigationController = navigationController;
    _navigationController.delegate = self;
}

- (void)dealloc {
    if ( _navigationController.delegate == self ) _navigationController.delegate = nil;
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
}

- (void)pushAnimation:(SJNavTransitionAnimation)pushAnimation popAnimation:(SJNavTransitionAnimation)popAnimation {
    _pushAnimation = pushAnimation;
    _popAnimation = popAnimation;
}
@end
