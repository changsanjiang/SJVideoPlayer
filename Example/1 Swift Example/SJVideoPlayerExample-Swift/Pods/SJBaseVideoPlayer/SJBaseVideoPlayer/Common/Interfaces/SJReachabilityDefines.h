//
//  SJReachabilityDefines
//  Project
//
//  Created by 畅三江 on 2018/6/1.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#ifndef SJNetworkStatus_h
#define SJNetworkStatus_h
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@protocol SJReachabilityObserver;
/**
 This enumeration lists the three state values of the network.
 It is used to identify the current network state. You can obtain the current network state as follows:
 
 这个枚举列出了网络的3种状态值, 用来标识当前的网络状态, 你可以像下面这样获取当前的网络状态:
 ```
 _videoPlayer.networkStatus;
 ```
 */
typedef NS_ENUM(NSInteger, SJNetworkStatus) {
    SJNetworkStatus_NotReachable = 0,
    SJNetworkStatus_ReachableViaWWAN = 1,
    SJNetworkStatus_ReachableViaWiFi = 2
};


@protocol SJReachability <NSObject>
- (id<SJReachabilityObserver>)getObserver;

@property (nonatomic, readonly) SJNetworkStatus networkStatus;

@property (nonatomic, strong, readonly) NSString *networkSpeedStr;

- (void)startRefresh;
- (void)stopRefresh;
@end

@protocol SJReachabilityObserver <NSObject>
@property (nonatomic, copy, nullable) void(^networkStatusDidChangeExeBlock)(id<SJReachability> r);
@property (nonatomic, copy, nullable) void(^networkSpeedDidChangeExeBlock)(id<SJReachability> r);
@end
NS_ASSUME_NONNULL_END
#endif /* SJNetworkStatus_h */
