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

@implementation SJVideoPlayerRegistrar {
    id _audioSessionRouteChangeToken;
    id _applicationWillResignActiveToken;
    id _applicationDidBecomeActiveToken;
    id _applicationWillEnterForegroundToken;
    id _applicationDidEnterBackgroundToken;
    id _audioSessionInterruptionToken;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __weak typeof(self) _self = self;
        self->_audioSessionRouteChangeToken = [NSNotificationCenter.defaultCenter addObserverForName:AVAudioSessionRouteChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
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
        
        self->_applicationWillResignActiveToken = [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            self.state = SJVideoPlayerAppState_ResignActive;
            if ( self.willResignActive ) self.willResignActive(self);
        }];
        
        self->_applicationDidBecomeActiveToken = [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            self.state = SJVideoPlayerAppState_BecomeActive;
            if ( self.didBecomeActive ) self.didBecomeActive(self);
        }];
        
        self->_applicationWillEnterForegroundToken = [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            self.state = SJVideoPlayerAppState_Forground;
            if ( self.willEnterForeground ) self.willEnterForeground(self);
        }];
        
        self->_applicationDidEnterBackgroundToken = [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            self.state = SJVideoPlayerAppState_Background;
            if ( self.didEnterBackground ) self.didEnterBackground(self);
        }];
        
        self->_audioSessionInterruptionToken = [NSNotificationCenter.defaultCenter addObserverForName:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance] queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            NSDictionary *info = note.userInfo;
            if( (AVAudioSessionInterruptionType)[info[AVAudioSessionInterruptionTypeKey] integerValue] == AVAudioSessionInterruptionTypeBegan ) {
                if ( self.audioSessionInterruption ) self.audioSessionInterruption(self);
            }
        }];
    });
    
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
   if ( _audioSessionRouteChangeToken ) [[NSNotificationCenter defaultCenter] removeObserver:_audioSessionRouteChangeToken];
    if ( _applicationWillResignActiveToken ) [[NSNotificationCenter defaultCenter] removeObserver:_applicationWillResignActiveToken];
    if ( _applicationDidBecomeActiveToken ) [[NSNotificationCenter defaultCenter] removeObserver:_applicationDidBecomeActiveToken];
    if ( _applicationWillEnterForegroundToken ) [[NSNotificationCenter defaultCenter] removeObserver:_applicationWillEnterForegroundToken];
    if ( _applicationDidEnterBackgroundToken ) [[NSNotificationCenter defaultCenter] removeObserver:_applicationDidEnterBackgroundToken];
    if ( _audioSessionInterruptionToken ) [[NSNotificationCenter defaultCenter] removeObserver:_audioSessionInterruptionToken];
}

@end
