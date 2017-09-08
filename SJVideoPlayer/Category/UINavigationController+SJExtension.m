//
//  UINavigationController+SJExtension.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/8.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "UINavigationController+SJExtension.h"

#import <objc/message.h>

@implementation UINavigationController (SJExtension)

+ (void)load {
    Method sjMethod = class_getInstanceMethod([self class], @selector(sjPushViewController:animated:));
    Method method = class_getInstanceMethod([self class], @selector(pushViewController:animated:));
    method_exchangeImplementations(sjMethod, method);
}

- (void)sjPushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self sjPushViewController:viewController animated:animated];
    [self sjPanGesture];
}

- (UIScreenEdgePanGestureRecognizer *)sjPanGesture {
    UIScreenEdgePanGestureRecognizer *sjPanGesture = objc_getAssociatedObject(self, _cmd);
    if ( sjPanGesture ) return sjPanGesture;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    sjPanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self.interactivePopGestureRecognizer.delegate action:@selector(handleNavigationTransition:)];
#pragma clang diagnostic pop
    sjPanGesture.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:sjPanGesture];
    self.interactivePopGestureRecognizer.enabled = NO;
    objc_setAssociatedObject(self, _cmd, sjPanGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return sjPanGesture;
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
