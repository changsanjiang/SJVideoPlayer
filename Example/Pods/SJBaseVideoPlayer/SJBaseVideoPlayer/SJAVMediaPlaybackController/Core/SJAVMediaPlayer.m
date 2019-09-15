//
//  SJAVMediaPlayer.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/8/26.
//

#import "SJAVMediaPlayer.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NSNotificationName const SJAVMediaPlayerAssetStatusDidChangeNotification = @"SJAVMediaPlayerAssetStatusDidChangeNotification";
NSNotificationName const SJAVMediaPlayerTimeControlStatusDidChangeNotification = @"SJAVMediaPlayerTimeControlStatusDidChangeNotification";
NSNotificationName const SJAVMediaPlayerDurationDidChangeNotification = @"SJAVMediaPlayerDurationDidChangeNotification";
NSNotificationName const SJAVMediaPlayerPlayableDurationDidChangeNotification = @"SJAVMediaPlayerPlayableDurationDidChangeNotification";
NSNotificationName const SJAVMediaPlayerPresentationSizeDidChangeNotification = @"SJAVMediaPlayerPresentationSizeDidChangeNotification";
NSNotificationName const SJAVMediaPlayerPlaybackTypeDidChangeNotification = @"SJAVMediaPlayerPlaybackTypeDidChangeNotification";
NSNotificationName const SJAVMediaPlayerDidPlayToEndTimeNotification = @"SJAVMediaPlayerDidPlayToEndTimeNotification";

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlayer()

@end

@implementation SJAVMediaPlayer
@synthesize sj_playbackInfo = _sj_playbackInfo;
@synthesize sj_minBufferedDuration = _sj_minBufferedDuration;

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%d - %s", (int)__LINE__, __func__);
}
#endif
- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime {
    return [self initWithAVAsset:[AVAsset assetWithURL:URL] specifyStartTime:specifyStartTime];
}
- (instancetype)initWithAVAsset:(__kindof AVAsset *)asset specifyStartTime:(NSTimeInterval)specifyStartTime {
    return [self initWithPlayerItem:[[AVPlayerItem alloc] initWithAsset:asset] specifyStartTime:specifyStartTime];
}
- (instancetype)initWithPlayerItem:(nullable AVPlayerItem *)item {
    return [self initWithPlayerItem:item specifyStartTime:0];
}
- (instancetype)initWithPlayerItem:(AVPlayerItem *)item specifyStartTime:(NSTimeInterval)specifyStartTime {
    self = [super initWithPlayerItem:item];
    if ( self ) {
        _sj_playbackInfo.rate = 1;
        _sj_playbackInfo.specifyStartTime = specifyStartTime;
        [self _sj_initObservations];
    }
    return self;
}

- (void)setSj_minBufferedDuration:(NSTimeInterval)sj_minBufferedDuration {
    _sj_playbackInfo.minBufferedDuration = sj_minBufferedDuration;
}
- (NSTimeInterval)sj_minBufferedDuration {
    return _sj_playbackInfo.minBufferedDuration;
}

- (void)setSj_rate:(float)sj_rate {
    _sj_playbackInfo.rate = sj_rate;
    if ( self.sj_timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
        self.rate = sj_rate;
    }
}
- (float)sj_rate {
    return _sj_playbackInfo.rate;
}

- (void)replay {
    _sj_playbackInfo.isPlayed = YES;
    _sj_playbackInfo.isPlayedToEndTime = NO;
    
    [self seekToTime:kCMTimeZero];
    [super play];
    self.rate = _sj_playbackInfo.rate;
}

- (void)play {
    _sj_playbackInfo.isPlayed = YES;
    
    if ( self.sj_playbackInfo.isPlayedToEndTime ) {
        [self replay];
    }
    else {
        [super play];
        self.rate = _sj_playbackInfo.rate;
    }
}

- (void)report {
    [self sj_postNotification:SJAVMediaPlayerAssetStatusDidChangeNotification];
    [self sj_postNotification:SJAVMediaPlayerTimeControlStatusDidChangeNotification];
    [self sj_postNotification:SJAVMediaPlayerDurationDidChangeNotification];
    [self sj_postNotification:SJAVMediaPlayerPlayableDurationDidChangeNotification];
    [self sj_postNotification:SJAVMediaPlayerPresentationSizeDidChangeNotification];
    [self sj_postNotification:SJAVMediaPlayerPlaybackTypeDidChangeNotification];
}

#pragma mark -

- (void)sj_postNotification:(NSNotificationName)name {
    [NSNotificationCenter.defaultCenter postNotificationName:name object:self];
}

- (void)_sj_initObservations {
    if ( self.currentItem == nil ) return;
    
    __weak typeof(self) _self = self;
    sjkvo_observe(self, @"sj_assetStatus", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self sj_postNotification:SJAVMediaPlayerAssetStatusDidChangeNotification];
        
        
#ifdef DEBUG
        if ( self.sj_error ) {
            NSLog(@"SJAVMediaPlayer: %d - %s - %@", (int)__LINE__, __func__, self.sj_error);
        }
#endif
    });
    
    sjkvo_observe(self, @"sj_timeControlStatus", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self sj_postNotification:SJAVMediaPlayerTimeControlStatusDidChangeNotification];
    });
    
    sjkvo_observe(self.currentItem, @"status", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.currentItem.status == AVPlayerItemStatusReadyToPlay && self.sj_playbackInfo.specifyStartTime != 0 ) {
                [self seekToTime:CMTimeMakeWithSeconds(self.sj_playbackInfo.specifyStartTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {}];
            }
        });
    });
    
    sjkvo_observe(self.currentItem, @"loadedTimeRanges", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _sj_playableDurationDidChange];
        });
    });
    
    sjkvo_observe(self.currentItem, @"presentationSize", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _sj_presentationSizeDidChange];
        });
    });
    
    [self.currentItem.asset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _sj_durationDidChange];
        });
    }];
    
    [self sj_observeWithNotification:AVPlayerItemNewAccessLogEntryNotification target:self.currentItem usingBlock:^(SJAVMediaPlayer *self, NSNotification * _Nonnull note) {
        [self _sj_newAcessLogEntry];
    }];
    
    [self sj_observeWithNotification:AVPlayerItemDidPlayToEndTimeNotification target:self.currentItem usingBlock:^(SJAVMediaPlayer *self, NSNotification * _Nonnull note) {
        [self _sj_didPlayToEndTime];
    }];
    
    [self sj_observeWithNotification:AVAudioSessionInterruptionNotification target:nil usingBlock:^(SJAVMediaPlayer *self, NSNotification * _Nonnull note) {
        NSDictionary *info = note.userInfo;
        if( (AVAudioSessionInterruptionType)[info[AVAudioSessionInterruptionTypeKey] integerValue] == AVAudioSessionInterruptionTypeBegan ) {
            [self pause];
        }
    }];
    
    [self sj_observeWithNotification:AVAudioSessionRouteChangeNotification target:nil usingBlock:^(SJAVMediaPlayer *self, NSNotification * _Nonnull note) {
        NSDictionary *interuptionDict = note.userInfo;
        NSInteger reason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
        if ( reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable ) {
            [self pause];
        }
    }];
}

- (void)_sj_playableDurationDidChange {
    NSValue *_Nullable value = self.currentItem.loadedTimeRanges.firstObject;
    NSTimeInterval playableDuration = value ? CMTimeGetSeconds(CMTimeRangeGetEnd(value.CMTimeRangeValue)) : 0;
    _sj_playbackInfo.playableDuration = playableDuration;
    [self sj_postNotification:SJAVMediaPlayerPlayableDurationDidChangeNotification];
    
    if ( self.currentItem.isPlaybackBufferEmpty == false && self.sj_reasonForWaitingToPlay == SJWaitingToMinimizeStallsReason ) {
        NSTimeInterval currTime = CMTimeGetSeconds(self.currentTime);
        NSInteger playableMilli = playableDuration * 1000;
        NSInteger currentMilli  = currTime * 1000;
        NSInteger bufferedMilli = playableMilli - currentMilli;
        if ( bufferedMilli > 0 ) {
            NSInteger maxMilli = ( self.sj_minBufferedDuration != 0 ? self.sj_minBufferedDuration : 5) * 1000;
            if ( bufferedMilli >= maxMilli ) {
                [self sj_playImmediatelyAtRate:self.sj_rate];
            }
            
#ifdef SJDEBUG
            printf("SJAVMediaPlayer: 缓冲中...  进度: \t %ld \t %ld \n", (long)bufferedMilli, (long)maxMilli);
#endif
        }
    }
}

- (void)_sj_presentationSizeDidChange {
    _sj_playbackInfo.presentationSize = self.currentItem.presentationSize;
    [self sj_postNotification:SJAVMediaPlayerPresentationSizeDidChangeNotification];
}

- (void)_sj_durationDidChange {
    NSTimeInterval duration = CMTimeGetSeconds(self.currentItem.asset.duration);
    _sj_playbackInfo.duration = duration;
    [self sj_postNotification:SJAVMediaPlayerDurationDidChangeNotification];
}

- (void)_sj_newAcessLogEntry {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AVPlayerItem *item = self.currentItem;
        AVPlayerItemAccessLogEvent *event = item.accessLog.events.firstObject;
        SJPlaybackType playbackType = SJPlaybackTypeUnknown;
        NSString *type = event.playbackType;
        if ( [type isEqualToString:@"LIVE"] ) {
            playbackType = SJPlaybackTypeLIVE;
        }
        else if ( [type isEqualToString:@"VOD"] ) {
            playbackType = SJPlaybackTypeVOD;
        }
        else if ( [type isEqualToString:@"FILE"] ) {
            playbackType = SJPlaybackTypeFILE;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( playbackType != self.sj_playbackInfo.playbackType ) {
                [self _sj_playbackTypeDidChange:playbackType];
            }
        });
    });
}

- (void)_sj_playbackTypeDidChange:(SJPlaybackType)playbackType {
    _sj_playbackInfo.playbackType = playbackType;
    [self sj_postNotification:SJAVMediaPlayerPlaybackTypeDidChangeNotification];
}

- (void)_sj_didPlayToEndTime {
    _sj_playbackInfo.isPlayedToEndTime = YES;
    [self sj_postNotification:SJAVMediaPlayerDidPlayToEndTimeNotification];
}
@end
NS_ASSUME_NONNULL_END
