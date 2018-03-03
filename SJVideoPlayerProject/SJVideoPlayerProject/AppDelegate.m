//
//  AppDelegate.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "AppDelegate.h"
#import "SJVideoPlayer.h"

@interface AppDelegate ()

@end 

@implementation AppDelegate

/// 全局配置播放器样式. 所有播放器对象均采用此`setting`.
/// Configure players globally. This is the setting for all player objects.
- (void)_settingVideoPlayer {
    
    SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {
        // note: 注意这个block 是在子线程进行.
        
        /// 设置占位图
        commonSettings.placeholder = [UIImage imageNamed:@"placeholder"];
        
        // 也可以设置其他部分的.
        
        /// 设置 更多页面中`slider`的样式.
        commonSettings.more_trackColor = [UIColor whiteColor];
        commonSettings.progress_trackColor = [UIColor colorWithWhite:0.4 alpha:1];
        commonSettings.progress_bufferColor = [UIColor whiteColor];
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _window.rootViewController = [sb instantiateInitialViewController];
    [_window makeKeyAndVisible];
    
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    
    [self _settingVideoPlayer];
    
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
