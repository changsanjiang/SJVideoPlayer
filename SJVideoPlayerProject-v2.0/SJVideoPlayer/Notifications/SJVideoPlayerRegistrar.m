//
//  SJVideoPlayerRegistrar.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerRegistrar.h"
#import <AVFoundation/AVFoundation.h>

@implementation SJVideoPlayerRegistrar

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    // 耳机
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    // 后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    
    // 前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// 耳机
- (void)audioSessionRouteChangeNotification:(NSNotification*)notifi {
    NSDictionary *interuptionDict = notifi.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
            // 插入耳机
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable: {
            
        }
            break;
            // 拔掉耳机
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
        }
            break;
            // 当其他音频想要播放时
        case AVAudioSessionRouteChangeReasonCategoryChange:
            NSLog(@"%zd - %s", __LINE__, __func__);
            break;
    }
}

// 后台
- (void)applicationWillResignActiveNotification {
    //    [self.backstageRegistrar registrar:_controlView];
    //    [self _clickedPause];
    //    if ( _backstageRegistrar.hiddenLockBtn ) [self clickedUnlock];
}

// 前台
- (void)applicationDidBecomeActiveNotification {
    //    if ( _backstageRegistrar.hiddenLockBtn ) [self clickedLock];
    //    if ( _backstageRegistrar.hiddenPlayBtn ) [self _clickedPlay];
}

@end
