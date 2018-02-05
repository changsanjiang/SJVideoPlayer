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

@property (nonatomic, assign, readwrite) SJVideoPlayerBackstageState state;

@end

@implementation SJVideoPlayerRegistrar

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)audioSessionRouteChangeNotification:(NSNotification*)notifi {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *interuptionDict = notifi.userInfo;
        NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
        switch (routeChangeReason) {
            case AVAudioSessionRouteChangeReasonNewDeviceAvailable: {
                if ( _newDeviceAvailable ) _newDeviceAvailable(self);
            }
                break;
            case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
                if ( _oldDeviceUnavailable ) _oldDeviceUnavailable(self);
            }
                break;
            case AVAudioSessionRouteChangeReasonCategoryChange: {
                if ( _categoryChange ) _categoryChange(self);
            }
                break;
        }
    });
}

- (void)applicationWillResignActiveNotification {
    self.state = SJVideoPlayerBackstageState_Forground;
    if ( _willResignActive ) _willResignActive(self);
}

- (void)applicationDidBecomeActiveNotification {
    self.state = SJVideoPlayerBackstageState_Background;
    if ( _didBecomeActive ) _didBecomeActive(self);
}

@end
