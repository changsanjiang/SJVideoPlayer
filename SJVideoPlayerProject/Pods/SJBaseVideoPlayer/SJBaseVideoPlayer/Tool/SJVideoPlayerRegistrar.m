//
//  SJVideoPlayerRegistrar.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerRegistrar.h"
#import <AVFoundation/AVFoundation.h>
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

@interface SJVideoPlayerRegistrar ()
@property (nonatomic) SJVideoPlayerAppState state;
@end

@implementation SJVideoPlayerRegistrar
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self sj_observeWithNotification:AVAudioSessionRouteChangeNotification target:nil usingBlock:^(SJVideoPlayerRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            NSDictionary *interuptionDict = note.userInfo;
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
        }];

        [self sj_observeWithNotification:UIApplicationWillResignActiveNotification target:nil usingBlock:^(SJVideoPlayerRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            self.state = SJVideoPlayerAppState_ResignActive;
            if ( self.willResignActive ) self.willResignActive(self);
        }];
        
        [self sj_observeWithNotification:UIApplicationDidBecomeActiveNotification target:nil usingBlock:^(SJVideoPlayerRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            self.state = SJVideoPlayerAppState_BecomeActive;
            if ( self.didBecomeActive ) self.didBecomeActive(self);
        }];
        
        [self sj_observeWithNotification:UIApplicationWillEnterForegroundNotification target:nil usingBlock:^(SJVideoPlayerRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            self.state = SJVideoPlayerAppState_Forground;
            if ( self.willEnterForeground ) self.willEnterForeground(self);
        }];
        
        [self sj_observeWithNotification:UIApplicationDidEnterBackgroundNotification target:nil usingBlock:^(SJVideoPlayerRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            self.state = SJVideoPlayerAppState_Background;
            if ( self.didEnterBackground ) self.didEnterBackground(self);
        }];
        
        [self sj_observeWithNotification:AVAudioSessionInterruptionNotification target:[AVAudioSession sharedInstance] usingBlock:^(SJVideoPlayerRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            NSDictionary *info = note.userInfo;
            if( (AVAudioSessionInterruptionType)[info[AVAudioSessionInterruptionTypeKey] integerValue] == AVAudioSessionInterruptionTypeBegan ) {
                if ( self.audioSessionInterruption ) self.audioSessionInterruption(self);
            }
        }];
    });
    
    switch ( UIApplication.sharedApplication.applicationState ) {
        case UIApplicationStateActive:
            self->_state = SJVideoPlayerAppState_Forground;
            break;
        case UIApplicationStateInactive:
            self->_state = SJVideoPlayerAppState_ResignActive;
            break;
        case UIApplicationStateBackground:
            self->_state = SJVideoPlayerAppState_Background;
            break;
    }
    return self;
}
@end
