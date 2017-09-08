//
//  UITabBarController+SJExtension.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/8.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "UITabBarController+SJExtension.h"

@implementation UITabBarController (SJExtension)

- (BOOL)shouldAutorotate {
    UIViewController *vc = self.viewControllers[self.selectedIndex];
    if ( [vc isKindOfClass:[UINavigationController class]] )
         return [((UINavigationController *)vc).topViewController shouldAutorotate];
    else return [vc shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *vc = self.viewControllers[self.selectedIndex];
    if ( [vc isKindOfClass:[UINavigationController class]] )
         return ((UINavigationController *)vc).topViewController.supportedInterfaceOrientations;
    else return vc.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *vc = self.viewControllers[self.selectedIndex];
    if ( [vc isKindOfClass:[UINavigationController class]] )
        return ((UINavigationController *)vc).topViewController.preferredInterfaceOrientationForPresentation;
    else
        return vc.preferredInterfaceOrientationForPresentation;
}

@end
