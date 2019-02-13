//
//  SJVideoPlayerRegistrar.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJVideoPlayerAppState) {
    SJVideoPlayerAppState_ResignActive,
    SJVideoPlayerAppState_BecomeActive,
    SJVideoPlayerAppState_Forground,  // 从后台进入前台
    SJVideoPlayerAppState_Background, // 从前台进入后台
};

@interface SJVideoPlayerRegistrar : NSObject

@property (nonatomic, assign, readonly) SJVideoPlayerAppState state;

@property (nonatomic, copy, readwrite, nullable) void(^willResignActive)(SJVideoPlayerRegistrar *registrar);

@property (nonatomic, copy, readwrite, nullable) void(^didBecomeActive)(SJVideoPlayerRegistrar *registrar);

@property (nonatomic, copy, readwrite, nullable) void(^willEnterForeground)(SJVideoPlayerRegistrar *registrar);

@property (nonatomic, copy, readwrite, nullable) void(^didEnterBackground)(SJVideoPlayerRegistrar *registrar);

@property (nonatomic, copy, readwrite, nullable) void(^newDeviceAvailable)(SJVideoPlayerRegistrar *registrar);

@property (nonatomic, copy, readwrite, nullable) void(^oldDeviceUnavailable)(SJVideoPlayerRegistrar *registrar);

@property (nonatomic, copy, readwrite, nullable) void(^categoryChange)(SJVideoPlayerRegistrar *registrar);

@property (nonatomic, copy, readwrite, nullable) void(^audioSessionInterruption)(SJVideoPlayerRegistrar *registrar);

@end

NS_ASSUME_NONNULL_END
