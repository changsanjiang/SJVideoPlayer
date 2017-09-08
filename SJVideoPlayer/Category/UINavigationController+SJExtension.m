//
//  UINavigationController+SJExtension.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/8.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "UINavigationController+SJExtension.h"

#import <objc/message.h>

static UIScreenEdgePanGestureRecognizer *_pan;

@implementation UINavigationController (SJExtension)

+ (void)load {
    Method sjMethod = class_getInstanceMethod([self class], @selector(sjPushViewController:animated:));
    Method method = class_getInstanceMethod([self class], @selector(pushViewController:animated:));
    method_exchangeImplementations(sjMethod, method);
}

- (void)sjPushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self sjPushViewController:viewController animated:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    _pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self.interactivePopGestureRecognizer.delegate action:@selector(handleNavigationTransition:)];
#pragma clang diagnostic pop
    _pan.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:_pan];
    self.interactivePopGestureRecognizer.enabled = NO;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return self.childViewControllers.count > 0;
}

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end
