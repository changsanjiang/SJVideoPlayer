//
//  AppDelegate.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/29.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "AppDelegate.h"
#import "SJVideoPlayer.h"
#import <SJRouter/SJRouter.h>

@interface AppDelegate ()

@end
// 200, 450, 850, 1200, 2000
// http://asp.cntv.qingcdn.com/asp/hls/main/0303000a/3/default/72c4a73d7294652f71f5fbdabb82b3fb/2000.m3u8
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {
        commonSettings.placeholder = [UIImage imageNamed:@"cover"];
        commonSettings.progress_thumbSize = 8;
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SJRouter shared];
    });
    
    [UIApplication.sharedApplication setStatusBarOrientation:UIInterfaceOrientationPortrait];
    _window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    _window.backgroundColor = UIColor.whiteColor;
    _window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    [_window makeKeyAndVisible];
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
