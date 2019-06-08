//
//  SJApplicationObserver.m
//  SJUIKit
//
//  Created by 畅三江 on 2018/12/23.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "SJApplicationObserver.h"
#import "NSDate+SJAdded.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJApplicationObserver {
    id _UIApplicationWillTerminateToken;
}
+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    __weak typeof(self) _self = self;
    _UIApplicationWillTerminateToken = [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationWillTerminateNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _update_isFirstLaunchedAtTodayState];
    }];
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:_UIApplicationWillTerminateToken];
}

- (BOOL)isFirstLaunchedAtToday {
    NSString *key = NSStringFromSelector(_cmd);
    NSString *recordStr = [NSUserDefaults.standardUserDefaults stringForKey:key];
    NSString *currentStr = NSDate.date.sj_dd;

    return !recordStr || (![recordStr isEqualToString:currentStr]);
}

- (void)_update_isFirstLaunchedAtTodayState {
    NSString *key = NSStringFromSelector(@selector(isFirstLaunchedAtToday));
    NSString *currentStr = NSDate.date.sj_dd;
    [NSUserDefaults.standardUserDefaults setValue:currentStr forKey:key];
}

- (nullable __kindof UIViewController *)topViewController {
    __kindof UIViewController *_Nullable vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (  [vc isKindOfClass:[UINavigationController class]] ||
             [vc isKindOfClass:[UITabBarController class]] ||
             [vc presentedViewController] ) {
        
        if ( [vc isKindOfClass:[UINavigationController class]] ) {
            vc = [(UINavigationController *)vc topViewController];
        }
        
        if ( [vc isKindOfClass:[UITabBarController class]] ) {
            vc = [(UITabBarController *)vc selectedViewController];
        }
        
        while ( vc.presentedViewController ) {
            vc = vc.presentedViewController;
        }
    }
    return vc;
}
@end
NS_ASSUME_NONNULL_END
