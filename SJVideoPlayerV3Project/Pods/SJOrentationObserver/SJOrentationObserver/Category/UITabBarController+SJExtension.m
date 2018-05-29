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
    if ( self.viewControllers.count <= 5 || self.selectedIndex < 4 ) {
        UIViewController *vc = self.selectedViewController;
        if ( [vc isKindOfClass:[UINavigationController class]] )
            return [((UINavigationController *)vc).topViewController shouldAutorotate];
        
        return [vc shouldAutorotate];
    }
    
    if ( self.selectedViewController == self.moreNavigationController )
        return [self.moreNavigationController shouldAutorotate];
    
    return [self.moreNavigationController.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ( self.viewControllers.count <= 5 || self.selectedIndex < 4 ) {
        UIViewController *vc = self.selectedViewController;
        if ( [vc isKindOfClass:[UINavigationController class]] )
            return [((UINavigationController *)vc).topViewController supportedInterfaceOrientations];
        
        return [vc supportedInterfaceOrientations];
    }
    
    if ( self.selectedViewController == self.moreNavigationController )
        return [self.moreNavigationController supportedInterfaceOrientations];
    
    return [self.moreNavigationController.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if ( self.viewControllers.count <= 5 || self.selectedIndex < 4 ) {
        UIViewController *vc = self.selectedViewController;
        if ( [vc isKindOfClass:[UINavigationController class]] )
            return [((UINavigationController *)vc).topViewController preferredInterfaceOrientationForPresentation];
        
        return [vc preferredInterfaceOrientationForPresentation];
    }
    
    if ( self.selectedViewController == self.moreNavigationController )
        return [self.moreNavigationController preferredInterfaceOrientationForPresentation];
    
    return [self.moreNavigationController.topViewController preferredInterfaceOrientationForPresentation];
}
@end
