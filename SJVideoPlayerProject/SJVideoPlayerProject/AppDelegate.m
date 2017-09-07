//
//  AppDelegate.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "AppDelegate.h"

#import "VideoPlayerNavigationController.h"

#import <CoreMedia/CoreMedia.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    _window.backgroundColor = [UIColor whiteColor];
    
    VideoPlayerNavigationController *nav = [[VideoPlayerNavigationController alloc] initWithRootViewController:[NSClassFromString(@"ViewController") new]];
    
    _window.rootViewController = nav;
    
    [self cmtime];
    
    // Override point for customization after application launch.
    return YES;
}


- (void)cmtime {
    
    CMTime time1 = CMTimeMake(6, 1);
    CMTime time2 = CMTimeMake(10, 1);
    CMTime time3 = CMTimeMake(6, 1);
    
    int32_t result1 = CMTimeCompare(time1, time2);
    
    int32_t result2 = CMTimeCompare(time2, time1);
    
    int32_t result3 = CMTimeCompare(time1, time3);
    
    NSLog(@"%d - %d - %d", result1, result2, result3);
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
