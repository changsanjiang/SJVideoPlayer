//
//  SJVideoPlayerRegistrar.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerRegistrar.h"
#import <AVFoundation/AVFoundation.h>

@interface SJVideoPlayerRegistrar ()

@property (nonatomic, assign, readwrite) SJVideoPlayerAppState state;

@end

@implementation SJVideoPlayerRegistrar

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];

    switch ( UIApplication.sharedApplication.applicationState ) {
        case UIApplicationStateActive:
            _state = SJVideoPlayerAppState_Forground;
            break;
        case UIApplicationStateInactive:
            _state = SJVideoPlayerAppState_ResignActive;
            break;
        case UIApplicationStateBackground:
            _state = SJVideoPlayerAppState_Background;
            break;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)audioSessionRouteChangeNotification:(NSNotification*)notifi {
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        NSDictionary *interuptionDict = notifi.userInfo;
        NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
        switch (routeChangeReason) {
            case AVAudioSessionRouteChangeReasonNewDeviceAvailable: {
                if ( self.newDeviceAvailable ) self.newDeviceAvailable(self);
            }
                break;
            case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
                if ( self.oldDeviceUnavailable ) self.oldDeviceUnavailable(self);
            }
                break;
            case AVAudioSessionRouteChangeReasonCategoryChange: {
                if ( self.categoryChange ) self.categoryChange(self);
            }
                break;
        }
    });
}

- (void)applicationWillResignActiveNotification {
    self.state = SJVideoPlayerAppState_ResignActive;
    if ( _willResignActive ) _willResignActive(self);
}

- (void)applicationDidBecomeActiveNotification {
    self.state = SJVideoPlayerAppState_BecomeActive;
    if ( _didBecomeActive ) _didBecomeActive(self);
}

- (void)applicationWillEnterForegroundNotification {
    self.state = SJVideoPlayerAppState_Forground;
    if ( _willEnterForeground ) _willEnterForeground(self);
}

- (void)applicationDidEnterBackgroundNotification {
    self.state = SJVideoPlayerAppState_Background;
    if ( _didEnterBackground ) _didEnterBackground(self);
}

- (void)audioSessionInterruptionNotification:(NSNotification *)notification{
    NSDictionary *info = notification.userInfo;
    if( (AVAudioSessionInterruptionType)[info[AVAudioSessionInterruptionTypeKey] integerValue] == AVAudioSessionInterruptionTypeBegan ) {
        if ( _audioSessionInterruption ) _audioSessionInterruption(self);
    }
}
@end
