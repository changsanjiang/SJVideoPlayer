//
//  SJFullscreenModeStatusBarDefines.h
//  Pods
//
//  Created by 畅三江 on 2019/12/11.
//

#ifndef SJFullscreenModeStatusBarDefines_h
#define SJFullscreenModeStatusBarDefines_h
#import <UIKit/UIKit.h>
#import <SJBaseVideoPlayer/SJReachabilityDefines.h>

NS_ASSUME_NONNULL_BEGIN
NS_AVAILABLE_IOS(11.0)
@protocol SJFullscreenModeStatusBar <NSObject>
///
/// 网络连接类型(无网络, 蜂窝网络, Wi-Fi)
///
@property (nonatomic) SJNetworkStatus networkStatus;

///
/// 系统当前时间
///
@property (nonatomic, strong, nullable) NSDate *date;

///
/// 电池状态
///
@property (nonatomic) UIDeviceBatteryState batteryState;

///
/// 电量
///
@property (nonatomic) float batteryLevel;
@end
NS_ASSUME_NONNULL_END

#endif /* SJFullscreenModeStatusBarDefines_h */
