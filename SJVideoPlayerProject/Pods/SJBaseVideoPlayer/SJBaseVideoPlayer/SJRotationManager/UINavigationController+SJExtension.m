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

static UIViewController *_get_top_view_controller(UINavigationController *nav) {
    UIViewController *vc = nav.topViewController;
    while (  [vc isKindOfClass:[UINavigationController class]] || [vc isKindOfClass:[UITabBarController class]] ) {
        if ( [vc isKindOfClass:[UINavigationController class]] ) vc = [(UINavigationController *)vc topViewController];
        if ( [vc isKindOfClass:[UITabBarController class]] ) vc = [(UITabBarController *)vc selectedViewController];
        if ( vc.presentedViewController ) vc = vc.presentedViewController;
    }
    return vc;
}

- (BOOL)shouldAutorotate {
    return _get_top_view_controller(self).shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return _get_top_view_controller(self).supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return _get_top_view_controller(self).preferredInterfaceOrientationForPresentation;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return _get_top_view_controller(self);
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return _get_top_view_controller(self);
}

@end
