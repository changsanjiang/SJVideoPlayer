//
//  SJAVMediaPlayer.m
//  Pods
//
//  Created by BlueDancer on 2019/4/9.
//

#import "SJAVMediaPlayer.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif
#import "SJReachability.h"

//#define SJTEST_PLAYER

NS_ASSUME_NONNULL_BEGIN
typedef struct SJAVMediaPlaybackControlInfo {
    BOOL isPrerolling;      ///< buffer为空的状态
    BOOL isPlayed;          ///< 是否播放过
    BOOL isPaused;          ///< 是否调用了暂停
    BOOL isPlaying;         ///< 是否调用了播放
    BOOL isError;           ///< 是否播放错误
    BOOL isPlayedToEndTime; ///< 是否播放结束
    BOOL isReplayed;
    BOOL isForceDuration;
    
    NSTimeInterval specifyStartTime;
    NSTimeInterval playableDuration;
    NSTimeInterval bufferTimeToContinuePlaying;
    NSTimeInterval duration;
    NSInteger bufferingProgress;
    SJPlayerBufferStatus bufferStatus;
    SJVideoPlayerInactivityReason inactivityReason;
    SJVideoPlayerPausedReason pausedReason;
    SJVideoPlayerPlayStatus playbackStatus;
    SJMediaPlaybackType playbackType;
    
    enum SJAVMediaPrepareStatus: int {
        SJAVMediaPrepareStatusUnknown,
        SJAVMediaPrepareStatusPreparing,
        SJAVMediaPrepareStatusSuccessfullyToPrepare,
        SJAVMediaPrepareStatusFailedToPrepare
    } prepareStatus;
    
    struct SJAVMediaPlayerSeekingInfo {
        BOOL isSeeking;
        CMTime time;
    } seekingInfo;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    AVPlayerTimeControlStatus timeControlStatus NS_AVAILABLE(10_12, 10_0);
#endif
} SJAVMediaPlaybackControlInfo;

// resume play after stall
static const float kMaxHighWaterMarkMilli = 15 * 1000;

inline static bool isFloatZero(float value) {
    return fabsf(value) <= 0.00001f;
}

@interface SJAVMediaPlayer ()
@property (nonatomic, readonly) SJAVMediaPlaybackControlInfo *sj_controlInfo;
@property (nonatomic, strong, nullable) NSError *sj_error;
@end

@implementation SJAVMediaPlayer
@synthesize sj_playbackRate = _sj_playbackRate;

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithURL:URL specifyStartTime:0];
}
- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime {
    return [self initWithAVAsset:[AVAsset assetWithURL:URL] specifyStartTime:specifyStartTime];
}
- (instancetype)initWithAVAsset:(__kindof AVAsset *)asset specifyStartTime:(NSTimeInterval)specifyStartTime {
    return [self initWithPlayerItem:[[AVPlayerItem alloc] initWithAsset:asset] specifyStartTime:specifyStartTime];
}
- (instancetype)initWithPlayerItem:(nullable AVPlayerItem *)item {
    return [self initWithPlayerItem:item specifyStartTime:0];
}
- (instancetype)initWithPlayerItem:(AVPlayerItem *_Nullable)item specifyStartTime:(NSTimeInterval)specifyStartTime {
    self = [super initWithPlayerItem:item];
    if ( self ) {
        _sj_playbackRate = 1.0;
        _sj_controlInfo = (SJAVMediaPlaybackControlInfo *)calloc(1, sizeof(SJAVMediaPlaybackControlInfo));
        _sj_controlInfo->bufferTimeToContinuePlaying = 2;
        _sj_controlInfo->specifyStartTime = specifyStartTime;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _sj_prepareToPlay];
        });
    }
    return self;
}
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    if ( _sj_controlInfo->seekingInfo.isSeeking )
        [self.currentItem cancelPendingSeeks];
    free(_sj_controlInfo);
}

- (void)_sj_prepareToPlay {
    if ( _sj_controlInfo->prepareStatus != SJAVMediaPrepareStatusUnknown ) ///< 防止准备过程多次调用
        return;
    
    _sj_controlInfo->prepareStatus = SJAVMediaPrepareStatusPreparing;
    
    AVPlayerItem *item = self.currentItem;
    __weak typeof(self) _self = self;
    // - prepare -
    sjkvo_observe(item, @"status", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _playerItemStatusDidChange];
    });
    
    // - did play to end time -
    [self sj_observeWithNotification:AVPlayerItemDidPlayToEndTimeNotification target:item usingBlock:^(SJAVMediaPlayer  *self, NSNotification * _Nonnull note) {
        [self _successfullyToPlayEndTime:note];
    }];
    
    [self sj_observeWithNotification:AVPlayerItemFailedToPlayToEndTimeNotification target:item usingBlock:^(SJAVMediaPlayer  *self, NSNotification * _Nonnull note) {
        [self _failedToPlayEndTime:note];
    }];
    
    // - buffer -
    sjkvo_observe(item, @"loadedTimeRanges", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _playerItemLoadedTimeRangesDidChange];
    });
    
    if ( @available(iOS 10.0, *) ) {
        sjkvo_observe(self, @"timeControlStatus", ^(SJAVMediaPlayer *self, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            self.sj_controlInfo->timeControlStatus = [change[NSKeyValueChangeNewKey] integerValue];
            [self _bufferStatusDidChange];
            [self _playbackStatusDidChange];
        });
    }
    else {
        sjkvo_observe(item, @"playbackLikelyToKeepUp", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _bufferStatusDidChange];
        });
        sjkvo_observe(item, @"playbackBufferEmpty", NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld, ^(AVPlayerItem *target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.sj_controlInfo->isPrerolling = target.isPlaybackBufferEmpty;
            [self _bufferStatusDidChange];
        });
        sjkvo_observe(item, @"playbackBufferFull", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _bufferStatusDidChange];
        });
    }
    sjkvo_observe(self, @"rate", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _rateDidChange];
    });
    sjkvo_observe(item, @"presentationSize", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _postNotificationWithName:SJAVMediaLoadedPresentationSizeNotification];
    });
    [self.currentItem.asset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _durationDidChange];
    }];

    // - interruption -
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
    
    // - playback type -
    [self sj_observeWithNotification:AVPlayerItemNewAccessLogEntryNotification target:item usingBlock:^(SJAVMediaPlayer *self, NSNotification * _Nonnull note) {
        [self _playbackTypeDidLoad];
    }];
}

#ifdef SJTEST_PLAYER
- (void)test_log {
    /// next
    /// - 接入`timeControlStatus`
    /// - 增加当缓冲超过多少秒时候, 恢复播放. `bufferTimeToContinuePlaying`
    
    /// timeControlStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate
    /// reasonForWaitingToPlay
    /// - AVPlayerWaitingWhileEvaluatingBufferingRateReason
    /// It is recommended that you do not show UI indicating a waiting state to the user when this is the reason the player is in a wait state.
    /// 正在监视回放缓冲区的填充率，以确定回放是否可能在没有中断的情况下完成。
    
    /// - AVPlayerWaitingToMinimizeStallsReason
    /// Playback will continue when playback can continue without a stall at the player specified rate. Playback will also continue if the player item’s playback buffer becomes full and no further buffering of media data is possible.
    /// 当回放能够在没有中断的情况下完成或者AVPlayerItem缓冲为full时, playback will continue
    
    if (@available(iOS 10.0, *)) {
        switch ( _sj_controlInfo->timeControlStatus ) {
            case AVPlayerTimeControlStatusPaused:
                NSLog(@"AVPlayerTimeControlStatusPaused - %@ - %d - %d - %d - %lf", self.reasonForWaitingToPlay, self.currentItem.isPlaybackBufferEmpty, self.currentItem.isPlaybackBufferFull, self.currentItem.isPlaybackLikelyToKeepUp, self.rate);
                break;
            case AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate:
                NSLog(@"AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate - %@ - %d - %d - %d - %lf", self.reasonForWaitingToPlay, self.currentItem.isPlaybackBufferEmpty, self.currentItem.isPlaybackBufferFull, self.currentItem.isPlaybackLikelyToKeepUp, self.rate);
                break;
            case AVPlayerTimeControlStatusPlaying:
                NSLog(@"AVPlayerTimeControlStatusPlaying - %@ - %d - %d - %d - %lf", self.reasonForWaitingToPlay, self.currentItem.isPlaybackBufferEmpty, self.currentItem.isPlaybackBufferFull, self.currentItem.isPlaybackLikelyToKeepUp, self.rate);
                break;
        }
    }
}
#endif

- (void)_playerItemStatusDidChange {
    if ( _sj_controlInfo->prepareStatus == SJAVMediaPrepareStatusPreparing ) { ///< 防止准备过程多次调用
        AVPlayerItem *item = self.currentItem;
        AVPlayerItemStatus status = item.status;
        if ( status == AVPlayerItemStatusReadyToPlay ) {
            NSTimeInterval specifyStartTime = _sj_controlInfo->specifyStartTime;
            if ( isFloatZero(specifyStartTime) ) {
                [self _postNotificationWithName:SJAVMediaItemStatusDidChangeNotification];
                [self _successfullyToPrepare:item];
                return;
            }
            
            // - seek to `specifyStartTime`
            __weak typeof(self) _self = self;
            [item seekToTime:CMTimeMakeWithSeconds(specifyStartTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                [self _postNotificationWithName:SJAVMediaItemStatusDidChangeNotification];
                [self _successfullyToPrepare:item];
            }];
        }
        else if ( status == AVPlayerItemStatusFailed ) {
            [self _postNotificationWithName:SJAVMediaItemStatusDidChangeNotification];
            [self _failedToPrepare:item.error];
        }
    }
}

- (void)_playerItemLoadedTimeRangesDidChange {
    AVPlayerItem *playerItem = self.currentItem;
    NSArray *timeRangeArray = playerItem.loadedTimeRanges;
    CMTime currentTime = [self currentTime];
    
    BOOL foundRange = NO;
    CMTimeRange aTimeRange = {0};
    
    if ( timeRangeArray.count > 0 ) {
        aTimeRange = [[timeRangeArray objectAtIndex:0] CMTimeRangeValue];
        if( CMTimeRangeContainsTime(aTimeRange, currentTime) ) {
            foundRange = YES;
        }
    }
    
    if ( foundRange ) {
        CMTime maxTime = CMTimeRangeGetEnd(aTimeRange);
        NSTimeInterval playableDuration = CMTimeGetSeconds(maxTime);
        if ( playableDuration > 0 ) {
            [self _playableDurationDidChange:playableDuration];
        }
    }
    else {
        [self _playableDurationDidChange:0];
    }
}

- (void)_bufferStatusDidChange {
    SJPlayerBufferStatus bufferStatus = self.sj_bufferStatus;
    if ( _sj_controlInfo->bufferStatus != bufferStatus ) {
         _sj_controlInfo->bufferStatus = bufferStatus;
        [self _postNotificationWithName:SJAVMediaBufferStatusDidChangeNotification];
    }
}

- (void)_rateDidChange {
    if ( !isFloatZero(self.rate) )
        _sj_controlInfo->isPrerolling = NO;
    
    [self _playbackStatusDidChange];
    [self _bufferStatusDidChange];
}

- (void)_durationDidChange {
    if ( !_sj_controlInfo->isForceDuration ) {
        NSTimeInterval duration = CMTimeGetSeconds(self.currentItem.asset.duration);
        if ( _sj_controlInfo->duration != duration ) {
            _sj_controlInfo->duration = duration;
            [self _postNotificationWithName:SJAVMediaLoadedDurationNotification];
        }
    }
}

- (void)_playbackStatusDidChange {
    SJVideoPlayerPlayStatus playbackStatus = self.sj_playbackStatus;
    BOOL changed = NO;
    if ( playbackStatus == SJVideoPlayerPlayStatusPaused ) {
        SJVideoPlayerPausedReason pausedReason = self.sj_pausedReason;
        if ( pausedReason != SJVideoPlayerPausedReasonUnknown ) {
            if ( pausedReason != _sj_controlInfo->pausedReason ) {
                _sj_controlInfo->inactivityReason = SJVideoPlayerInactivityReasonUnknown;
                _sj_controlInfo->pausedReason = pausedReason;
                _sj_controlInfo->playbackStatus = playbackStatus;
                changed = YES;
            }
        }
    }
    else if ( playbackStatus == SJVideoPlayerPlayStatusInactivity ) {
        SJVideoPlayerInactivityReason inactivityReason = self.sj_inactivityReason;
        if ( inactivityReason != SJVideoPlayerInactivityReasonUnknown ) {
            if ( inactivityReason != _sj_controlInfo->inactivityReason ) {
                _sj_controlInfo->inactivityReason = inactivityReason;
                _sj_controlInfo->pausedReason = SJVideoPlayerPausedReasonUnknown;
                _sj_controlInfo->playbackStatus = playbackStatus;
                changed = YES;
            }
        }
    }
    else if ( playbackStatus != _sj_controlInfo->playbackStatus ) {
        _sj_controlInfo->inactivityReason = SJVideoPlayerInactivityReasonUnknown;
        _sj_controlInfo->pausedReason = SJVideoPlayerPausedReasonUnknown;
        _sj_controlInfo->playbackStatus = playbackStatus;
        changed = YES;
    }
    
    if ( changed )
        [self _postNotificationWithName:SJAVMediaPlaybackStatusDidChangeNotification];
}

- (void)_playbackTypeDidLoad {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AVPlayerItem *item = self.currentItem;
        AVPlayerItemAccessLogEvent *event = item.accessLog.events.firstObject;
        SJMediaPlaybackType playbackType = SJMediaPlaybackTypeUnknown;
        NSString *type = event.playbackType;
        if ( [type isEqualToString:@"LIVE"] ) {
            playbackType = SJMediaPlaybackTypeLIVE;
        }
        else if ( [type isEqualToString:@"VOD"] ) {
            playbackType = SJMediaPlaybackTypeVOD;
        }
        else if ( [type isEqualToString:@"FILE"] ) {
            playbackType = SJMediaPlaybackTypeFILE;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( self.sj_controlInfo->playbackType != playbackType ) {
                self.sj_controlInfo->playbackType = playbackType;
                [self _postNotificationWithName:SJAVMediaLoadedPlaybackTypeNotification];
            }
        });
    });
}

- (void)_successfullyToPrepare:(AVPlayerItem *)item {
    _sj_controlInfo->prepareStatus = SJAVMediaPrepareStatusSuccessfullyToPrepare;
    [self _playbackStatusDidChange];
}

- (void)_failedToPrepare:(NSError *)error {
    _sj_controlInfo->prepareStatus = SJAVMediaPrepareStatusFailedToPrepare;
    [self _onError:error];
}

- (void)_playableDurationDidChange:(NSTimeInterval)playableDuration {
    _sj_controlInfo->playableDuration = playableDuration;
    [self _postNotificationWithName:SJAVMediaPlayableDurationDidChangeNotification];
    
    /// 缓冲时间正在改变时, 需要做的事情
    /// - 当play方法被调用时, 确定播放器是否真正的在播放, 如果没有则在最小缓冲足够时恢复播放
    
    if ( SJReachability.shared.networkStatus != SJNetworkStatus_NotReachable && !self.currentItem.isPlaybackBufferEmpty ) {
        if ( _sj_controlInfo->isPlaying && ![self sj_getPlayerIsPlaying] ) {
            NSTimeInterval currentPlaybackTime = [self sj_getCurrentPlaybackTime];
            int playableDurationMilli = (int)(playableDuration * 1000);
            int currentPlaybackTimeMilli = (int)(currentPlaybackTime * 1000);
            
            int bufferedDurationMilli = playableDurationMilli - currentPlaybackTimeMilli;
            if ( bufferedDurationMilli > 0 ) {
                NSTimeInterval bufferTimeToContinuePlaying = _sj_controlInfo->bufferTimeToContinuePlaying;
                NSTimeInterval maxHighWaterMarkMilli = (bufferTimeToContinuePlaying > 0)?bufferTimeToContinuePlaying * 1000 : kMaxHighWaterMarkMilli;
                _sj_controlInfo->bufferingProgress = bufferedDurationMilli * 100 / maxHighWaterMarkMilli;
                if (_sj_controlInfo->bufferingProgress > 100) {
                    // continue playing
                    if ( @available(iOS 10.0, *) ) {
                        [self playImmediatelyAtRate:_sj_playbackRate];
                    }
                    else {
                        self.rate = _sj_playbackRate;
                        [self _bufferStatusDidChange];
                        [self _playbackStatusDidChange];
                    }
                }
            }
        }
    }
}

- (void)_successfullyToPlayEndTime:(NSNotification *)note {
    _sj_controlInfo->isPlayedToEndTime = YES;
    [self _postNotificationWithName:SJAVMediaPlayDidToEndTimeNotification];
    [self _playbackStatusDidChange];
}

- (void)_failedToPlayEndTime:(NSNotification *)note {
    [self _onError:note.userInfo[@"error"]];
}

- (void)_onError:(NSError *)error {
    _sj_controlInfo->isError = YES;
    _sj_error = error;
    [self _playbackStatusDidChange];
}

- (void)_postNotificationWithName:(NSNotificationName)name {
    [NSNotificationCenter.defaultCenter postNotificationName:name object:self];
}

- (void)setSj_playbackRate:(float)sj_playbackRate {
    _sj_playbackRate = sj_playbackRate;
    if ( _sj_controlInfo->isPlaying )
        self.rate = sj_playbackRate;
}

- (void)setSj_playbackVolume:(float)sj_playbackVolume {
    self.volume = sj_playbackVolume;
}

- (float)sj_playbackVolume {
    return self.volume;
}

- (void)setSj_muted:(BOOL)sj_muted {
    self.muted = sj_muted;
}

- (BOOL)sj_isMuted {
    return self.isMuted;
}

- (void)setSj_bufferTimeToContinuePlaying:(NSTimeInterval)sj_bufferTimeToContinuePlaying {
    _sj_controlInfo->bufferTimeToContinuePlaying = sj_bufferTimeToContinuePlaying;
}

- (NSTimeInterval)sj_bufferTimeToContinuePlaying {
    return _sj_controlInfo->bufferTimeToContinuePlaying;
}

- (void)play {
    _sj_controlInfo->isPrerolling = NO;
    _sj_controlInfo->isPaused = NO;
    _sj_controlInfo->isPlayed = YES;
    _sj_controlInfo->isPlaying = YES;

    if ( _sj_controlInfo->isPlayedToEndTime ) {
        _sj_controlInfo->isPlayedToEndTime = NO;
        _sj_controlInfo->isReplayed = YES;
        [self _willSeekingToTime:kCMTimeZero];
        [self seekToTime:kCMTimeZero];
        [self _didEndSeeking];
    }
    [super play];
    
    if ( floor(self.rate + 0.5) != floor(self.sj_playbackRate + 0.5) ) {
        self.rate = self.sj_playbackRate;
    }
}
- (void)replay {
    _sj_controlInfo->isPlayedToEndTime = YES;
    [self play];
}
- (void)pause {
    _sj_controlInfo->isPrerolling = NO;
    _sj_controlInfo->isPaused = YES;
    _sj_controlInfo->isPlaying = NO;
    [super pause];
}
- (void)reset {
    if ( _sj_controlInfo->prepareStatus == SJAVMediaPrepareStatusSuccessfullyToPrepare ) {
        _sj_controlInfo->isPlayed = NO;
        _sj_controlInfo->isPaused = NO;
        _sj_controlInfo->isPlaying = NO;
        _sj_controlInfo->isPlayedToEndTime = NO;
        
        if ( _sj_controlInfo->seekingInfo.isSeeking ) {
            [self.currentItem cancelPendingSeeks];
            _sj_controlInfo->seekingInfo.isSeeking = NO;
            _sj_controlInfo->seekingInfo.time = kCMTimeZero;
        }
        [self seekToTime:kCMTimeZero];
        [super pause];
    }
}
- (void)report {
    [self _postNotificationWithName:SJAVMediaPlaybackStatusDidChangeNotification];
    [self _postNotificationWithName:SJAVMediaBufferStatusDidChangeNotification];
    [self _postNotificationWithName:SJAVMediaPlayableDurationDidChangeNotification];
    [self _postNotificationWithName:SJAVMediaLoadedPresentationSizeNotification];
    [self _postNotificationWithName:SJAVMediaLoadedPlaybackTypeNotification];
    [self _postNotificationWithName:SJAVMediaLoadedDurationNotification];
    [self _postNotificationWithName:SJAVMediaItemStatusDidChangeNotification];
}
- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL))completionHandler {
    if ( ![self _canSeekToTime:time] ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    [self _willSeekingToTime:time];
    __weak typeof(self) _self = self;
    [super seekToTime:time completionHandler:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _didEndSeeking];
            if ( completionHandler ) completionHandler(finished);
        });
    }];
}
- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL))completionHandler {
    if ( ![self _canSeekToTime:time] ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    [self _willSeekingToTime:time];
    __weak typeof(self) _self = self;
    [super seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _didEndSeeking];
            if ( completionHandler ) completionHandler(finished);
        });
    }];
}
- (BOOL)_canSeekToTime:(CMTime)time {
    return !_sj_controlInfo->isError && _sj_controlInfo->prepareStatus == SJAVMediaPrepareStatusSuccessfullyToPrepare;
}
- (void)_willSeekingToTime:(CMTime)time {
    if ( _sj_controlInfo->isPlayedToEndTime ) {
        _sj_controlInfo->isPlayedToEndTime = NO;
        _sj_controlInfo->isReplayed = YES;
    }
    
    if ( _sj_controlInfo->seekingInfo.isSeeking ) {
        [self.currentItem cancelPendingSeeks];
    }
    _sj_controlInfo->seekingInfo.isSeeking = YES;
    _sj_controlInfo->seekingInfo.time = time;
    if ( _sj_controlInfo->isPrerolling )
        [self pause];
    [self _playbackStatusDidChange];
}
- (void)_didEndSeeking {
    if ( _sj_controlInfo->isPrerolling )
        [self play];
    _sj_controlInfo->seekingInfo.isSeeking = NO;
    _sj_controlInfo->seekingInfo.time = kCMTimeZero;
    [self _playbackStatusDidChange];
}
- (void)sj_setForceDuration:(NSTimeInterval)forceDuration {
    _sj_controlInfo->isForceDuration = YES;
    _sj_controlInfo->duration = forceDuration;
    [self _postNotificationWithName:SJAVMediaLoadedDurationNotification];
}
- (SJVideoPlayerPlayStatus)sj_playbackStatus {
    if      ( _sj_controlInfo->isPlayedToEndTime ) ///< 已播放完毕
        return SJVideoPlayerPlayStatusInactivity;
    else if ( _sj_controlInfo->prepareStatus == SJAVMediaPrepareStatusUnknown ) ///< 未准备就绪
        return SJVideoPlayerPlayStatusUnknown;
    else if ( _sj_controlInfo->prepareStatus == SJAVMediaPrepareStatusPreparing ) ///< 初始化, 准备中
        return SJVideoPlayerPlayStatusPrepare;
    else if ( _sj_controlInfo->prepareStatus == SJAVMediaPrepareStatusFailedToPrepare ) ///< 初始化失败
        return SJVideoPlayerPlayStatusInactivity;
    else if ( !_sj_controlInfo->isPlayed && _sj_controlInfo->prepareStatus == SJAVMediaPrepareStatusSuccessfullyToPrepare ) ///< 初始化完成
        return SJVideoPlayerPlayStatusReadyToPlay;
    else if ( _sj_controlInfo->isError )   ///< 播放报错
        return SJVideoPlayerPlayStatusInactivity;
    else if ( _sj_controlInfo->seekingInfo.isSeeking ) ///< 调用了 seekToTime:
        return SJVideoPlayerPlayStatusPaused;
    else if ( _sj_controlInfo->isPaused )  ///< 调用了暂停
        return SJVideoPlayerPlayStatusPaused;
    else if ( _sj_controlInfo->isPlaying ) {   ///< 调用了播放
        if ( [self sj_getPlayerIsPlaying] )   ///< 确定是否正在播放
            return SJVideoPlayerPlayStatusPlaying;
        
        if ( [self sj_bufferStatus] == SJPlayerBufferStatusUnplayable ) {   ///< 缓冲不够播放
            if ( SJReachability.shared.networkStatus != SJNetworkStatus_NotReachable ) ///< 是否有网
                return SJVideoPlayerPlayStatusPaused;
            else
                return SJVideoPlayerPlayStatusInactivity;
        }
    }
    return SJVideoPlayerPlayStatusPaused;
}
- (SJVideoPlayerPausedReason)sj_pausedReason {
    if      ( _sj_controlInfo->isPaused )  ///< 调用了暂停
        return SJVideoPlayerPausedReasonPause;
    else if ( _sj_controlInfo->seekingInfo.isSeeking ) ///< 调用了 seekToTime:
        return SJVideoPlayerPausedReasonSeeking;
    else if ( [self sj_bufferStatus] == SJPlayerBufferStatusUnplayable )    ///< 缓冲不够播放了
        return SJVideoPlayerPausedReasonBuffering;
    
    return SJVideoPlayerPausedReasonUnknown;
}
- (SJVideoPlayerInactivityReason)sj_inactivityReason {
    if      ( _sj_controlInfo->isPlayedToEndTime ) ///< 播放完毕
        return SJVideoPlayerInactivityReasonPlayEnd;
    else if ( _sj_controlInfo->isError )  ///< 播放报错了
        return SJVideoPlayerInactivityReasonPlayFailed;
    else if ( [self sj_bufferStatus] == SJPlayerBufferStatusUnplayable && SJReachability.shared.networkStatus == SJNetworkStatus_NotReachable ) ///< 无网了
        return SJVideoPlayerInactivityReasonNotReachableAndPlaybackStalled;
    
    return SJVideoPlayerInactivityReasonUnknown;
}
- (SJPlayerBufferStatus)sj_bufferStatus {
    if      ( _sj_controlInfo->seekingInfo.isSeeking )     ///< 调用了 seekToTime:
        return SJPlayerBufferStatusUnplayable;
    else if ( [self sj_getPlayerIsPlaying] )  ///< 确定正在播放中
        return SJPlayerBufferStatusPlayable;
    else if ( @available(iOS 10.0, *) ) {
        /// next
        /// - 接入`timeControlStatus`
        /// - 增加`当缓冲超过多少秒时候, 恢复播放`
        switch ( _sj_controlInfo->timeControlStatus ) {
            case AVPlayerTimeControlStatusPaused:
            case AVPlayerTimeControlStatusPlaying:
                return SJPlayerBufferStatusPlayable;
            case AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate:
                /// timeControlStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate
                /// reasonForWaitingToPlay
                /// - AVPlayerWaitingWhileEvaluatingBufferingRateReason
                /// It is recommended that you do not show UI indicating a waiting state to the user when this is the reason the player is in a wait state.
                /// 正在监视回放缓冲区的填充率，以确定回放是否可能在没有中断的情况下完成。
                if ( self.reasonForWaitingToPlay == AVPlayerWaitingWhileEvaluatingBufferingRateReason )
                    return SJPlayerBufferStatusPlayable;
                
                /// - AVPlayerWaitingToMinimizeStallsReason
                /// Playback will continue when playback can continue without a stall at the player specified rate. Playback will also continue if the player item’s playback buffer becomes full and no further buffering of media data is possible.
                /// 当回放能够在没有中断的情况下完成或者AVPlayerItem缓冲为full时, playback will continue
                return SJPlayerBufferStatusUnplayable;
        }
    }
    else {
        AVPlayerItem *item = self.currentItem;
        if ( [item isPlaybackBufferFull] ) ///< 缓冲足够播放
            return SJPlayerBufferStatusPlayable;
        else if ( [item isPlaybackLikelyToKeepUp] ) ///< 缓冲足够播放
            return SJPlayerBufferStatusPlayable;
        else if ( [item isPlaybackBufferEmpty] )    ///< 缓冲空了
            return SJPlayerBufferStatusUnplayable;
    }
    return SJPlayerBufferStatusUnknown;
}
- (BOOL)sj_getIsPlayed {
    return _sj_controlInfo->isPlayed;
}
- (BOOL)sj_getPlayerIsPlaying { ///< 确定播放器是否真正的在播放
    if ( @available(iOS 10.0, *) ) {
        switch ( _sj_controlInfo->timeControlStatus ) {
            case AVPlayerTimeControlStatusPaused:
            case AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate:
                return NO;
            case AVPlayerTimeControlStatusPlaying:
                return YES;
        }
    }
    else {
        if ( !isFloatZero(self.rate) )
            return YES;
        if ( _sj_controlInfo->isPrerolling && SJReachability.shared.networkStatus != SJNetworkStatus_NotReachable )
            return YES;
    }
    return NO;
}
- (BOOL)sj_isReplayed {
    return _sj_controlInfo->isReplayed;
}
- (SJMediaPlaybackType)sj_getPlaybackType {
    return _sj_controlInfo->playbackType;
}
- (NSTimeInterval)sj_getDuration {
    return _sj_controlInfo->duration;
}
- (NSTimeInterval)sj_getCurrentPlaybackTime {
    if ( _sj_controlInfo->prepareStatus != SJAVMediaPrepareStatusSuccessfullyToPrepare )
        return 0;
    if ( _sj_controlInfo->seekingInfo.isSeeking )
        return CMTimeGetSeconds(_sj_controlInfo->seekingInfo.time);
    return CMTimeGetSeconds(self.currentTime);
}
- (NSTimeInterval)sj_getPlayableDuration {
    if ( _sj_controlInfo->prepareStatus != SJAVMediaPrepareStatusSuccessfullyToPrepare )
        return 0;
    return _sj_controlInfo->playableDuration;
}
- (AVPlayerItemStatus)sj_getAVPlayerItemStatus {
    return self.currentItem.status;
}
- (NSError *_Nullable)sj_getError {
    return _sj_error;
}
- (CGSize)sj_getPresentationSize {
    return self.currentItem.presentationSize;
}
- (AVPlayer *)sj_getAVPlayer {
    return self;
}
- (AVAsset *)sj_getAVAsset {
    return self.currentItem.asset;
}
@end

NSNotificationName const SJAVMediaPlaybackStatusDidChangeNotification = @"SJAVMediaPlaybackStatusDidChangeNotification";
NSNotificationName const SJAVMediaBufferStatusDidChangeNotification = @"SJAVMediaBufferStatusDidChangeNotification";
NSNotificationName const SJAVMediaPlayableDurationDidChangeNotification = @"SJAVMediaPlayableDurationDidChangeNotification";
NSNotificationName const SJAVMediaPlayDidToEndTimeNotification = @"SJAVMediaPlayDidToEndTimeNotification";
NSNotificationName const SJAVMediaLoadedPresentationSizeNotification = @"SJAVMediaLoadedPresentationSizeNotification";
NSNotificationName const SJAVMediaLoadedPlaybackTypeNotification = @"SJAVMediaLoadedPlaybackTypeNotification";
NSNotificationName const SJAVMediaLoadedDurationNotification = @"SJAVMediaLoadedDurationNotification";
NSNotificationName const SJAVMediaItemStatusDidChangeNotification = @"SJAVMediaItemStatusDidChangeNotification";
NS_ASSUME_NONNULL_END
