//
//  SJVideoPlayerRegistrar.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/12/5.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "SJVideoPlayerRegistrar.h"
#import <AVFoundation/AVFoundation.h>
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
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
            if ( self.willResignActive ) self.willResignActive(self);
        }];
        
        [self sj_observeWithNotification:UIApplicationDidBecomeActiveNotification target:nil usingBlock:^(SJVideoPlayerRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            if ( self.didBecomeActive ) self.didBecomeActive(self);
        }];
        
        [self sj_observeWithNotification:UIApplicationWillEnterForegroundNotification target:nil usingBlock:^(SJVideoPlayerRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            if ( self.willEnterForeground ) self.willEnterForeground(self);
        }];
        
        [self sj_observeWithNotification:UIApplicationWillTerminateNotification target:nil usingBlock:^(SJVideoPlayerRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            if ( self.willTerminate ) self.willTerminate(self);
        }];
        
        [self sj_observeWithNotification:UIApplicationDidEnterBackgroundNotification target:nil usingBlock:^(SJVideoPlayerRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            if ( self.didEnterBackground ) self.didEnterBackground(self);
        }];
        
        [self sj_observeWithNotification:AVAudioSessionInterruptionNotification target:[AVAudioSession sharedInstance] usingBlock:^(SJVideoPlayerRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            NSDictionary *info = note.userInfo;
            if( (AVAudioSessionInterruptionType)[info[AVAudioSessionInterruptionTypeKey] integerValue] == AVAudioSessionInterruptionTypeBegan ) {
                if ( self.audioSessionInterruption ) self.audioSessionInterruption(self);
            }
        }];
    }); 
    return self;
}

- (SJVideoPlayerAppState)state {
    return UIApplication.sharedApplication.applicationState;
}
@end
NS_ASSUME_NONNULL_END
