//
//  AppDelegate.m
//  iPadDemo
//
//  Created by 畅三江 on 2022/7/11.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.backgroundColor = [UIColor whiteColor];
    _window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    [_window makeKeyAndVisible];

    // Override point for customization after application launch.
    return YES;
}

@end
