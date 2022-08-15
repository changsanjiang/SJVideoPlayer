//
//  SJAppDelegate.m
//  SJVideoPlayer
//
//  Created by changsanjiang on 06/08/2019.
//  Copyright (c) 2019 changsanjiang. All rights reserved.
//

#import "SJAppDelegate.h"
#import "SJVideoPlayer.h" 
#import "SJRotationManager.h"

@implementation SJAppDelegate
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( @available(iOS 11.0, *) ) {
            [UITableView appearance].estimatedRowHeight = 0;
            [UITableView appearance].estimatedSectionFooterHeight = 0;
            [UITableView appearance].estimatedSectionHeaderHeight = 0;
            [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if ( @available(iOS 13.0, *) ) {
            [UIScrollView appearance].automaticallyAdjustsScrollIndicatorInsets = NO;
        }
    });
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    UIInterfaceOrientationMask mask = [SJRotationManager supportedInterfaceOrientationsForWindow:window];
    NSLog(@"orientations: %ld, %@", mask, NSStringFromClass(window.class));
    return mask;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#ifdef DEBUG
    NSLog(@"%@", NSTemporaryDirectory());
#endif
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.backgroundColor = [UIColor whiteColor];
    _window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    [_window makeKeyAndVisible];


    SJVideoPlayer.updateResources(^(id<SJVideoPlayerControlLayerResources>  _Nonnull resources) {
        resources.placeholder = [UIImage imageNamed:@"placeholder"];
        resources.progressThumbSize = 8;
        resources.progressTrackColor = [UIColor colorWithWhite:0.8 alpha:1];
        resources.progressBufferColor = [UIColor whiteColor];
        
        resources.progressThumbImage = [UIImage imageNamed:@"thumb"];
        // or
        // resources.progressThumbSize = 8;
        // resources.progressThumbColor = UIColor.blueColor;
    });
    
    // Override point for customization after application launch.
    return YES;
}
@end


#pragma mark -


#warning Configuring rotation. 请配置旋转!!

@implementation UIViewController (RotationConfiguration)
///
/// 控制器是否可以旋转
///
- (BOOL)shouldAutorotate {
    return NO;
}

///
/// 控制器旋转支持的方向
///
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end


@implementation UITabBarController (RotationConfiguration)
- (UIViewController *)sj_topViewController {
    if ( self.selectedIndex == NSNotFound )
        return self.viewControllers.firstObject;
    return self.selectedViewController;
}

- (BOOL)shouldAutorotate {
    return [[self sj_topViewController] shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [[self sj_topViewController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self sj_topViewController] preferredInterfaceOrientationForPresentation];
}
@end

@implementation UINavigationController (RotationConfiguration)
- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}
@end

