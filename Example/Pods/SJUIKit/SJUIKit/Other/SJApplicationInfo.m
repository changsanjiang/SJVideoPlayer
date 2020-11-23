//
//  SJApplicationInfo.m
//  SJUIKit
//
//  Created by 畅三江 on 2018/12/23.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "SJApplicationInfo.h"
#import "NSDate+SJAdded.h"
#import <sys/utsname.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJApplicationInfo {
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

- (NSString *)machineModel {
    static NSString *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        if ( [machine rangeOfString:@"iPhone"].location != NSNotFound ) {
            model = [self _iPhonePlatform:machine];
        }
        else if ( [machine rangeOfString:@"iPad"].location != NSNotFound ) {
            model = [self _iPadPlatform:machine];
        }
        else if ( [machine rangeOfString:@"iPod"].location != NSNotFound ) {
            model = [self _iPodPlatform:machine];
        }
        else if ( [machine isEqualToString:@"i386"] || [machine isEqualToString:@"x86_64"] ) {
            model = @"Simulator";
        }
        else model = @"Unknown iOS Device";
    });
    return model;
}

- (NSString *)version {
    static NSString *version = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    });
    return version;
}

- (NSString *)systemVersion {
    static NSString *version = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion;
    });
    return version;
}

#pragma mark -

//iPhone设备
- (NSString *)_iPhonePlatform:(NSString *)platform{
    if ([platform isEqualToString:@"iPhone1,1"])   return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"])   return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])   return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])   return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])   return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])   return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])   return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])   return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])   return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"])   return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"])   return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"])   return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"])   return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,2"])   return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])   return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"])   return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])   return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])   return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])   return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,3"])   return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])   return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,4"])   return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone10,1"])  return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"])  return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"])  return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"])  return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"])  return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"])  return @"iPhone X";
    //2018年10月发布：
    if ([platform isEqualToString:@"iPhone11,8"])  return @"iPhone XR";
    if ([platform isEqualToString:@"iPhone11,2"])  return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,4"])  return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,6"])  return @"iPhone XS Max";
    
    return @"Unknown iPhone";
}

//iPad设备
- (NSString *)_iPadPlatform:(NSString *)platform {
    
    if([platform isEqualToString:@"iPad1,1"])   return @"iPad";
    if([platform isEqualToString:@"iPad1,2"])   return @"iPad 3G";
    if([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (WiFi)";
    if([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    if([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (CDMA)";
    if([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    if([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini (WiFi)";
    if([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini";
    if([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini (GSM+CDMA)";
    if([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (WiFi)";
    if([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (GSM+CDMA)";
    if([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    if([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (WiFi)";
    if([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    if([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (GSM+CDMA)";
    if([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (WiFi)";
    if([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (Cellular)";
    if([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2 (WiFi)";
    if([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2 (Cellular)";
    if([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2";
    if([platform isEqualToString:@"iPad4,7"])   return @"iPad Mini 3";
    if([platform isEqualToString:@"iPad4,8"])   return @"iPad Mini 3";
    if([platform isEqualToString:@"iPad4,9"])   return @"iPad Mini 3";
    if([platform isEqualToString:@"iPad5,1"])   return @"iPad Mini 4 (WiFi)";
    if([platform isEqualToString:@"iPad5,2"])   return @"iPad Mini 4 (LTE)";
    if([platform isEqualToString:@"iPad5,3"])   return @"iPad Air 2";
    if([platform isEqualToString:@"iPad5,4"])   return @"iPad Air 2";
    if([platform isEqualToString:@"iPad6,3"])   return @"iPad Pro 9.7";
    if([platform isEqualToString:@"iPad6,4"])   return @"iPad Pro 9.7";
    if([platform isEqualToString:@"iPad6,7"])   return @"iPad Pro 12.9";
    if([platform isEqualToString:@"iPad6,8"])   return @"iPad Pro 12.9";
    if([platform isEqualToString:@"iPad6,11"])  return @"iPad 5 (WiFi)";
    if([platform isEqualToString:@"iPad6,12"])  return @"iPad 5 (Cellular)";
    if([platform isEqualToString:@"iPad7,1"])   return @"iPad Pro 12.9 inch 2nd gen (WiFi)";
    if([platform isEqualToString:@"iPad7,2"])   return @"iPad Pro 12.9 inch 2nd gen (Cellular)";
    if([platform isEqualToString:@"iPad7,3"])   return @"iPad Pro 10.5 inch (WiFi)";
    if([platform isEqualToString:@"iPad7,4"])   return @"iPad Pro 10.5 inch (Cellular)";
    //2019年3月发布:
    if ([platform isEqualToString:@"iPad11,1"])   return @"iPad mini (5th generation)";
    if ([platform isEqualToString:@"iPad11,2"])   return @"iPad mini (5th generation)";
    if ([platform isEqualToString:@"iPad11,3"])   return @"iPad Air (3rd generation)";
    if ([platform isEqualToString:@"iPad11,4"])   return @"iPad Air (3rd generation)";
    
    return @"Unknown iPad";
}

//iPod设备
- (NSString *)_iPodPlatform:(NSString *)platform {
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod touch (6th generation)";
    //2019年5月发布
    if ([platform isEqualToString:@"iPod9,1"])      return @"iPod touch (7th generation)";
    return @"Unknown iPod";
}
@end
NS_ASSUME_NONNULL_END
