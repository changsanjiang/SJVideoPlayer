//
//  SJNavTransitionAnimator.h
//  SJTransitionAnimator
//
//  Created by BlueDancer on 2017/12/19.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SJNavTransitionAnimator;

NS_ASSUME_NONNULL_BEGIN
typedef void(^SJNavTransitionAnimation)(SJNavTransitionAnimator *anim, id <UIViewControllerContextTransitioning> transitionContext, UIView *toView, UIView *fromView);

@interface SJNavTransitionAnimator : NSObject

@property (nonatomic, weak, nullable) UINavigationController *navigationController;

@property (nonatomic) NSTimeInterval duration; // deafult is 0.3

- (void)pushAnimation:(SJNavTransitionAnimation)pushAnimation popAnimation:(SJNavTransitionAnimation)popAnimation;
@end
NS_ASSUME_NONNULL_END
