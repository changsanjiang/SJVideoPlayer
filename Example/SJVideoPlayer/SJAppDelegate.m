//
//  SJAppDelegate.m
//  SJVideoPlayer
//
//  Created by changsanjiang on 06/08/2019.
//  Copyright (c) 2019 changsanjiang. All rights reserved.
//

#import "SJAppDelegate.h"
#import "SJVideoPlayer.h"

@protocol SJTestProtocol <NSObject>
@end


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
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#ifdef DEBUG
    NSLog(@"%@", NSTemporaryDirectory());
#endif
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.backgroundColor = [UIColor whiteColor];
    NSString *name = UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM()?@"Main":@"iPadMain";
    _window.rootViewController = [[UIStoryboard storyboardWithName:name bundle:nil] instantiateInitialViewController];
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


#warning Configuring rotation control. 请配置旋转控制!

@implementation UIViewController (RotationControl)
///
/// 控制器是否可以旋转
///
- (BOOL)shouldAutorotate {
    // iPhone的demo用到了播放器的旋转, 这里返回NO, 除播放器外, 项目中的其他视图控制器都禁止旋转
    if ( UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM() ) {
        return NO;
    }
    
    // iPad的demo未用到播放器的旋转, 这里返回YES, 允许所有控制器旋转
    else if ( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() ) {
        return YES;
    }
    
    // 如果你的项目仅支持竖屏, 可以直接返回NO, 无需进行上述的判断区分.
    return NO;
}

///
/// 控制器旋转支持的方向
///
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // 此处为设置 iPhone demo 仅支持竖屏的方向
    if ( UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM() ) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    // 此处为设置 iPad demo 仅支持横屏的方向
    else if ( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() ) {
        return UIInterfaceOrientationMaskLandscape;
    }
    
    // 如果你的项目仅支持竖屏, 可以直接返回UIInterfaceOrientationMaskPortrait, 无需进行上述的判断区分.
    return UIInterfaceOrientationMaskPortrait;
}

@end


@implementation UITabBarController (RotationControl)
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

@implementation UINavigationController (RotationControl)
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

