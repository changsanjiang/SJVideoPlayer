//
//  SJAVMediaPlayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/8/26.
//

#import "SJAVMediaPlayer.h"

NSNotificationName const SJAVMediaPlayerAssetStatusDidChangeNotification = @"SJAVMediaPlayerAssetStatusDidChangeNotification";
NSNotificationName const SJAVMediaPlayerTimeControlStatusDidChangeNotification = @"SJAVMediaPlayerTimeControlStatusDidChangeNotification";
NSNotificationName const SJAVMediaPlayerDurationDidChangeNotification = @"SJAVMediaPlayerDurationDidChangeNotification";
NSNotificationName const SJAVMediaPlayerPlayableDurationDidChangeNotification = @"SJAVMediaPlayerPlayableDurationDidChangeNotification";
NSNotificationName const SJAVMediaPlayerPresentationSizeDidChangeNotification = @"SJAVMediaPlayerPresentationSizeDidChangeNotification";
NSNotificationName const SJAVMediaPlayerPlaybackTypeDidChangeNotification = @"SJAVMediaPlayerPlaybackTypeDidChangeNotification";
NSNotificationName const SJAVMediaPlayerDidPlayToEndTimeNotification = @"SJAVMediaPlayerDidPlayToEndTimeNotification";

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlayer()
@property (nonatomic, strong) SJAVBasePlayerItemObserver *itemObsever;
@property (nonatomic) BOOL needSeekToSpecifyStartTime;
@end

@implementation SJAVMediaPlayer
@synthesize sj_playbackInfo = _sj_playbackInfo;
@synthesize sj_minBufferedDuration = _sj_minBufferedDuration;

static NSString *kAssetStatus = @"sj_assetStatus";
static NSString *kTimeControlStatus = @"sj_timeControlStatus";

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
    [self removeObserver:self forKeyPath:kAssetStatus];
    [self removeObserver:self forKeyPath:kTimeControlStatus];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime {
    return [self initWithAVAsset:[AVAsset assetWithURL:URL] specifyStartTime:specifyStartTime];
}
- (instancetype)initWithAVAsset:(__kindof AVAsset *)asset specifyStartTime:(NSTimeInterval)specifyStartTime {
    return [self initWithPlayerItem:[[SJAVBasePlayerItem alloc] initWithAsset:asset] specifyStartTime:specifyStartTime];
}
- (instancetype)initWithPlayerItem:(SJAVBasePlayerItem *)item specifyStartTime:(NSTimeInterval)specifyStartTime {
    self = [super initWithBasePlayerItem:item];
    if ( self ) {
        _sj_playbackInfo.rate = 1;
        _sj_playbackInfo.specifyStartTime = specifyStartTime;
        _needSeekToSpecifyStartTime = specifyStartTime != 0;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self _sj_initObservations];
        });
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

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( context == &kAssetStatus ) {
        [self sj_postNotification:SJAVMediaPlayerAssetStatusDidChangeNotification];
    #ifdef DEBUG
        if ( self.sj_error ) {
            NSLog(@"SJAVMediaPlayer: %d - %s - %@", (int)__LINE__, __func__, self.sj_error);
        }
    #endif
    }
    else if ( context == &kTimeControlStatus ) {
        [self sj_postNotification:SJAVMediaPlayerTimeControlStatusDidChangeNotification];
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)_sj_initObservations {
    NSKeyValueObservingOptions ops = NSKeyValueObservingOptionNew;
    [self addObserver:self forKeyPath:kAssetStatus options:ops context:&kAssetStatus];
    [self addObserver:self forKeyPath:kTimeControlStatus options:ops context:&kTimeControlStatus];
    
    __weak typeof(self) _self = self;
    [self.currentItem.asset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _sj_durationDidChange];
        });
    }];
    
    _itemObsever = [SJAVBasePlayerItemObserver.alloc initWithBasePlayerItem:(SJAVBasePlayerItem *)self.currentItem];
    _itemObsever.statusDidChangeExeBlock = ^(SJAVBasePlayerItem * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.needSeekToSpecifyStartTime && self.currentItem.status == AVPlayerItemStatusReadyToPlay && self.sj_playbackInfo.specifyStartTime != 0 ) {
                self.needSeekToSpecifyStartTime = NO;
                [self seekToTime:CMTimeMakeWithSeconds(self.sj_playbackInfo.specifyStartTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {}];
            }
        });
    };
    
    _itemObsever.loadedTimeRangesDidChangeExeBlock = ^(SJAVBasePlayerItem * _Nonnull item) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSValue *_Nullable value = item.loadedTimeRanges.firstObject;
            NSTimeInterval playableDuration = value ? CMTimeGetSeconds(CMTimeRangeGetEnd(value.CMTimeRangeValue)) : 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                [self _sj_playableDurationDidChange:playableDuration];
            });
        });
    };
    
    _itemObsever.presentationSizeDidChangeExeBlock = ^(SJAVBasePlayerItem * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _sj_presentationSizeDidChange];
        });
    };
    
    _itemObsever.newAccessLogEntryExeBlock = ^(SJAVBasePlayerItem * _Nonnull item) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _sj_newAcessLogEntry];
    };
    
    _itemObsever.didPlayToEndTimeExeBlock = ^(SJAVBasePlayerItem * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _sj_didPlayToEndTime];
        });
    };
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sj_audioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sj_audioSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)_sj_playableDurationDidChange:(NSTimeInterval)playableDuration {
    _sj_playbackInfo.playableDuration = playableDuration;
    [self sj_postNotification:SJAVMediaPlayerPlayableDurationDidChangeNotification];
    
    if ( self.currentItem.isPlaybackBufferEmpty == false && self.sj_reasonForWaitingToPlay == SJWaitingToMinimizeStallsReason ) {
        NSTimeInterval currTime = CMTimeGetSeconds(self.currentTime);
        NSInteger playableMilli = playableDuration * 1000;
        NSInteger currentMilli  = currTime * 1000;
        NSInteger bufferedMilli = playableMilli - currentMilli;
        if ( bufferedMilli > 0 ) {
            NSInteger maxMilli = ( self.sj_minBufferedDuration != 0 ? self.sj_minBufferedDuration : 8) * 1000;
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

- (void)sj_audioSessionInterruption:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *info = note.userInfo;
        if( (AVAudioSessionInterruptionType)[info[AVAudioSessionInterruptionTypeKey] integerValue] == AVAudioSessionInterruptionTypeBegan ) {
            [self pause];
        }
    });
}

- (void)sj_audioSessionRouteChange:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *interuptionDict = note.userInfo;
        NSInteger reason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
        if ( reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable ) {
            [self pause];
        }
    });
}
@end
NS_ASSUME_NONNULL_END
