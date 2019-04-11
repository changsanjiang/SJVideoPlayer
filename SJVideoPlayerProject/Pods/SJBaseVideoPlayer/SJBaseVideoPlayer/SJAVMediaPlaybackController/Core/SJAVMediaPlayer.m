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

NS_ASSUME_NONNULL_BEGIN
typedef struct SJAVMediaPlaybackInfo {
    BOOL isPrerolling;      ///< buffer为空的状态
    BOOL isPlayed;          ///< 是否播放过
    BOOL isPaused;          ///< 是否调用了暂停
    BOOL isPlaying;         ///< 是否调用了播放
    BOOL isError;           ///< 是否播放错误
    BOOL isPlayedToEndTime; ///< 是否播放结束
    
    NSTimeInterval specifyStartTime;
    NSTimeInterval playableDuration;
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
} SJAVMediaPlaybackInfo;

static NSString *kDuration = @"duration";
static NSString *kLoadedTimeRanges = @"loadedTimeRanges";
static NSString *kPlaybackBufferEmpty = @"playbackBufferEmpty";
static NSString *kPresentationSize = @"presentationSize";
static NSString *kPlayerItemStatus = @"status";

static NSString *kPlaybackLikelyToKeeyUp = @"playbackLikelyToKeepUp";
static NSString *kPlaybackBufferFull = @"playbackBufferFull";
static NSString *kRate = @"rate";

// resume play after stall
static const float kMaxHighWaterMarkMilli = 15 * 1000;

inline static bool isFloatZero(float value) {
    return fabsf(value) <= 0.00001f;
}

@interface SJAVMediaPlayer ()
@property (nonatomic, readonly) SJAVMediaPlaybackInfo *sj_playbackInfo;
@property (nonatomic, strong, nullable) NSError *sj_error;
@property (nonatomic, getter=sj_isReplayed) BOOL sj_replayed;
@end

@implementation SJAVMediaPlayer
@synthesize sj_playbackRate = _sj_playbackRate;

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithURL:URL specifyStartTime:0];
}
- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime {
    AVAsset *asset = [AVAsset assetWithURL:URL];
    return [self initWithAVAsset:asset specifyStartTime:specifyStartTime];
}
- (instancetype)initWithAVAsset:(__kindof AVAsset *)asset specifyStartTime:(NSTimeInterval)specifyStartTime {
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    return [self initWithPlayerItem:playerItem specifyStartTime:specifyStartTime];
}
- (instancetype)initWithPlayerItem:(AVPlayerItem *_Nullable)item specifyStartTime:(NSTimeInterval)specifyStartTime {
    self = [super initWithPlayerItem:item];
    if ( self ) {
        _sj_playbackRate = 1.0;
        _sj_playbackInfo = (SJAVMediaPlaybackInfo *)malloc(sizeof(SJAVMediaPlaybackInfo));
        _sj_playbackInfo->isPrerolling = NO;
        _sj_playbackInfo->isPaused = NO;
        _sj_playbackInfo->isPlayed = NO;
        _sj_playbackInfo->isPlaying = NO;
        _sj_playbackInfo->isError = NO;
        _sj_playbackInfo->isPlayedToEndTime = NO;
        
        _sj_playbackInfo->specifyStartTime = specifyStartTime;
        _sj_playbackInfo->playableDuration = 0;
        _sj_playbackInfo->duration = 0;
        _sj_playbackInfo->bufferingProgress = 0;
        _sj_playbackInfo->bufferStatus = SJPlayerBufferStatusUnknown;
        _sj_playbackInfo->inactivityReason = 0;
        _sj_playbackInfo->pausedReason = 0;
        _sj_playbackInfo->playbackStatus = 0;
        _sj_playbackInfo->playbackType = SJMediaPlaybackTypeUnknown;
        
        _sj_playbackInfo->prepareStatus = SJAVMediaPrepareStatusUnknown;
        _sj_playbackInfo->seekingInfo = (struct SJAVMediaPlayerSeekingInfo){NO, kCMTimeZero};
        
        if (@available(iOS 10.0, *) ) {
            AVURLAsset *asset = (AVURLAsset *)item.asset;
            if ( [asset respondsToSelector:@selector(URL)] ) {
                self.automaticallyWaitsToMinimizeStalling = [asset.URL.pathExtension isEqualToString:@"m3u8"];
            }
        }
        
        [self _sj_prepareToPlay];
    }
    return self;
}
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    if ( _sj_playbackInfo->seekingInfo.isSeeking )
        [self.currentItem cancelPendingSeeks];
    free(_sj_playbackInfo);
}

- (void)_sj_prepareToPlay {
    if ( ![NSThread.currentThread isMainThread] ) { ///< 确保所有回调都在主线程
        [self performSelectorOnMainThread:@selector(_sj_prepareToPlay) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if ( _sj_playbackInfo->prepareStatus != SJAVMediaPrepareStatusUnknown ) ///< 防止准备过程多次调用
        return;
    
    _sj_playbackInfo->prepareStatus = SJAVMediaPrepareStatusPreparing;
    
    AVPlayerItem *item = self.currentItem;
    __weak typeof(self) _self = self;
    // - prepare -
    sjkvo_observe(item, kPlayerItemStatus, ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
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
    sjkvo_observe(item, kLoadedTimeRanges, ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _playerItemLoadedTimeRangesDidChange];
    });
    sjkvo_observe(item, kPlaybackBufferEmpty, ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _bufferStatusDidChange];
    });
    sjkvo_observe(item, kPlaybackLikelyToKeeyUp, ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _bufferStatusDidChange];
    });
    sjkvo_observe(item, kPlaybackBufferEmpty, NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld, ^(AVPlayerItem *target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.sj_playbackInfo->isPrerolling = target.isPlaybackBufferEmpty;
        [self _bufferStatusDidChange];
    });
    sjkvo_observe(item, kPlaybackBufferFull, ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _bufferStatusDidChange];
    });
    sjkvo_observe(self, kRate, ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _rateDidChange];
    });
    sjkvo_observe(item, kPresentationSize, ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _postNotificationWithName:SJAVMediaLoadedPresentationSizeNotification];
    });
    sjkvo_observe(item, kDuration, ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _durationDidChange];
    });

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

- (void)_playerItemStatusDidChange {
    if ( _sj_playbackInfo->prepareStatus == SJAVMediaPrepareStatusPreparing ) { ///< 防止准备过程多次调用
        AVPlayerItem *item = self.currentItem;
        AVPlayerItemStatus status = item.status;
        if ( status == AVPlayerItemStatusReadyToPlay ) {
            NSTimeInterval specifyStartTime = _sj_playbackInfo->specifyStartTime;
            if ( isFloatZero(specifyStartTime) ) {
                [self _successfullyToPrepare:item];
                return;
            }
            
            // - seek to `specifyStartTime`
            __weak typeof(self) _self = self;
            [item seekToTime:CMTimeMakeWithSeconds(specifyStartTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                [self _successfullyToPrepare:item];
            }];
        }
        else if ( status == AVPlayerItemStatusFailed ) {
            [self _failedToPrepare:item.error];
        }
        
        [self _postNotificationWithName:SJAVMediaItemStatusDidChangeNotification];
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
    if ( _sj_playbackInfo->bufferStatus != bufferStatus ) {
        _sj_playbackInfo->bufferStatus = bufferStatus;
        [self _postNotificationWithName:SJAVMediaBufferStatusDidChangeNotification];
    }
}

- (void)_rateDidChange {
    if ( !isFloatZero(self.rate) )
        _sj_playbackInfo->isPrerolling = NO;
    
    [self _playbackStatusDidChange];
    [self _bufferStatusDidChange];
}

- (void)_durationDidChange {
    NSTimeInterval duration = CMTimeGetSeconds(self.currentItem.duration);
    if ( _sj_playbackInfo->duration != duration ) {
        _sj_playbackInfo->duration = duration;
        [self _postNotificationWithName:SJAVMediaLoadedDurationNotification];
    }
}

- (void)_playbackStatusDidChange {
    SJVideoPlayerPlayStatus playbackStatus = self.sj_playbackStatus;
    BOOL changed = NO;
    if ( playbackStatus == SJVideoPlayerPlayStatusPaused ) {
        SJVideoPlayerPausedReason pausedReason = self.sj_pausedReason;
        if ( pausedReason != SJVideoPlayerPausedReasonUnknown ) {
            if ( pausedReason != _sj_playbackInfo->pausedReason ) {
                _sj_playbackInfo->inactivityReason = SJVideoPlayerInactivityReasonUnknown;
                _sj_playbackInfo->pausedReason = pausedReason;
                _sj_playbackInfo->playbackStatus = playbackStatus;
                changed = YES;
            }
        }
    }
    else if ( playbackStatus == SJVideoPlayerPlayStatusInactivity ) {
        SJVideoPlayerInactivityReason inactivityReason = self.sj_inactivityReason;
        if ( inactivityReason != SJVideoPlayerInactivityReasonUnknown ) {
            if ( inactivityReason != _sj_playbackInfo->inactivityReason ) {
                _sj_playbackInfo->inactivityReason = inactivityReason;
                _sj_playbackInfo->pausedReason = SJVideoPlayerPausedReasonUnknown;
                _sj_playbackInfo->playbackStatus = playbackStatus;
                changed = YES;
            }
        }
    }
    else if ( playbackStatus != _sj_playbackInfo->playbackStatus ) {
        _sj_playbackInfo->inactivityReason = SJVideoPlayerInactivityReasonUnknown;
        _sj_playbackInfo->pausedReason = SJVideoPlayerPausedReasonUnknown;
        _sj_playbackInfo->playbackStatus = playbackStatus;
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
            if ( self.sj_playbackInfo->playbackType != playbackType ) {
                self.sj_playbackInfo->playbackType = playbackType;
                [self _postNotificationWithName:SJAVMediaLoadedPlaybackTypeNotification];
            }
        });
    });
}

- (void)_successfullyToPrepare:(AVPlayerItem *)item {
    _sj_playbackInfo->prepareStatus = SJAVMediaPrepareStatusSuccessfullyToPrepare;
    [self _playbackStatusDidChange];
}

- (void)_failedToPrepare:(NSError *)error {
    _sj_playbackInfo->prepareStatus = SJAVMediaPrepareStatusFailedToPrepare;
    [self _onError:error];
}

- (void)_playableDurationDidChange:(NSTimeInterval)playableDuration {
    _sj_playbackInfo->playableDuration = playableDuration;

    NSTimeInterval currentPlaybackTime = [self sj_getCurrentPlaybackTime];
    int playableDurationMilli = (int)(playableDuration * 1000);
    int currentPlaybackTimeMilli = (int)(currentPlaybackTime * 1000);
    
    int bufferedDurationMilli = playableDurationMilli - currentPlaybackTimeMilli;
    if ( bufferedDurationMilli > 0 ) {
        _sj_playbackInfo->bufferingProgress = bufferedDurationMilli * 100 / kMaxHighWaterMarkMilli;
        if (_sj_playbackInfo->bufferingProgress > 100) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self->_sj_playbackInfo->bufferingProgress > 100) {
                    if ( [self sj_getIsPlaying] ) {
                        self.rate = self->_sj_playbackRate;
                    }
                }
            });
        }
    }

    [self _postNotificationWithName:SJAVMediaPlayableDurationDidChangeNotification];
    
    if ( SJReachability.shared.networkStatus != SJNetworkStatus_NotReachable ) {
        if ( playableDuration != 0 ) {
            if ( _sj_playbackInfo->isPlaying ) {
                if ( ![self sj_getIsPlaying] ) {
                    self.rate = self.sj_playbackRate;
                }
            }
        }
    }
}

- (void)_successfullyToPlayEndTime:(NSNotification *)note {
    _sj_playbackInfo->isPlayedToEndTime = YES;
    [self _postNotificationWithName:SJAVMediaPlayDidToEndTimeNotification];
    [self _playbackStatusDidChange];
}

- (void)_failedToPlayEndTime:(NSNotification *)note {
    [self _onError:note.userInfo[@"error"]];
}

- (void)_onError:(NSError *)error {
    _sj_playbackInfo->isError = YES;
    _sj_error = error;
    [self _playbackStatusDidChange];
}

- (void)_postNotificationWithName:(NSNotificationName)name {
    [NSNotificationCenter.defaultCenter postNotificationName:name object:self];
}

- (void)setSj_playbackRate:(float)sj_playbackRate {
    _sj_playbackRate = sj_playbackRate;
    if ( _sj_playbackInfo->isPlaying )
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

- (void)play {
    _sj_playbackInfo->isPrerolling = NO;
    _sj_playbackInfo->isPaused = NO;
    _sj_playbackInfo->isPlayed = YES;
    _sj_playbackInfo->isPlaying = YES;

    if ( _sj_playbackInfo->isPlayedToEndTime ) {
        _sj_playbackInfo->isPlayedToEndTime = NO;
        _sj_replayed = YES;
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
    _sj_playbackInfo->isPlayedToEndTime = YES;
    [self play];
}
- (void)pause {
    _sj_playbackInfo->isPrerolling = NO;
    _sj_playbackInfo->isPaused = YES;
    _sj_playbackInfo->isPlaying = NO;
    [super pause];
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
    return !_sj_playbackInfo->isError && _sj_playbackInfo->prepareStatus == SJAVMediaPrepareStatusSuccessfullyToPrepare;
}
- (void)_willSeekingToTime:(CMTime)time {
    if ( _sj_playbackInfo->seekingInfo.isSeeking ) {
        [self.currentItem cancelPendingSeeks];
    }
    _sj_playbackInfo->seekingInfo.isSeeking = YES;
    _sj_playbackInfo->seekingInfo.time = time;
    if ( _sj_playbackInfo->isPrerolling )
        [self pause];
    [self _playbackStatusDidChange];
}
- (void)_didEndSeeking {
    if ( _sj_playbackInfo->isPrerolling )
        [self play];
    _sj_playbackInfo->seekingInfo.isSeeking = NO;
    _sj_playbackInfo->seekingInfo.time = kCMTimeZero;
    [self _playbackStatusDidChange];
}
- (SJVideoPlayerPlayStatus)sj_playbackStatus {
    if      ( _sj_playbackInfo->isPlayedToEndTime ) ///< 已播放完毕
        return SJVideoPlayerPlayStatusInactivity;
    else if ( _sj_playbackInfo->prepareStatus == SJAVMediaPrepareStatusUnknown ) ///< 未准备就绪
        return SJVideoPlayerPlayStatusUnknown;
    else if ( _sj_playbackInfo->prepareStatus == SJAVMediaPrepareStatusPreparing ) ///< 初始化, 准备中
        return SJVideoPlayerPlayStatusPrepare;
    else if ( _sj_playbackInfo->prepareStatus == SJAVMediaPrepareStatusFailedToPrepare ) ///< 初始化失败
        return SJVideoPlayerPlayStatusInactivity;
    else if ( !_sj_playbackInfo->isPlayed && _sj_playbackInfo->prepareStatus == SJAVMediaPrepareStatusSuccessfullyToPrepare ) ///< 初始化完成
        return SJVideoPlayerPlayStatusReadyToPlay;
    else if ( _sj_playbackInfo->isError )   ///< 播放报错
        return SJVideoPlayerPlayStatusInactivity;
    else if ( _sj_playbackInfo->seekingInfo.isSeeking ) ///< 调用了 seekToTime:
        return SJVideoPlayerPlayStatusPaused;
    else if ( _sj_playbackInfo->isPaused )  ///< 调用了暂停
        return SJVideoPlayerPlayStatusPaused;
    else if ( _sj_playbackInfo->isPlaying ) {   ///< 调用了播放
        if ( [self sj_getIsPlaying] )   ///< 确定是否正在播放
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
    if      ( _sj_playbackInfo->isPaused )  ///< 调用了暂停
        return SJVideoPlayerPausedReasonPause;
    else if ( _sj_playbackInfo->seekingInfo.isSeeking ) ///< 调用了 seekToTime:
        return SJVideoPlayerPausedReasonSeeking;
    else if ( [self sj_bufferStatus] == SJPlayerBufferStatusUnplayable )    ///< 缓冲不够播放了
        return SJVideoPlayerPausedReasonBuffering;
    
    return SJVideoPlayerPausedReasonUnknown;
}
- (SJVideoPlayerInactivityReason)sj_inactivityReason {
    if      ( _sj_playbackInfo->isPlayedToEndTime ) ///< 播放完毕
        return SJVideoPlayerInactivityReasonPlayEnd;
    else if ( _sj_playbackInfo->isError )  ///< 播放报错了
        return SJVideoPlayerInactivityReasonPlayFailed;
    else if ( [self sj_bufferStatus] == SJPlayerBufferStatusUnplayable && SJReachability.shared.networkStatus == SJNetworkStatus_NotReachable ) ///< 无网了
        return SJVideoPlayerInactivityReasonNotReachableAndPlaybackStalled;
    
    return SJVideoPlayerInactivityReasonUnknown;
}
- (SJPlayerBufferStatus)sj_bufferStatus {
    AVPlayerItem *item = self.currentItem;
    
    if      ( _sj_playbackInfo->seekingInfo.isSeeking )     ///< 调用了 seekToTime:
        return SJPlayerBufferStatusUnplayable;
    else if ( [self sj_getIsPlaying] )  ///< 确定正在播放中
        return SJPlayerBufferStatusPlayable;
    else if ( [item isPlaybackBufferFull] ) ///< 缓冲足够播放
        return SJPlayerBufferStatusPlayable;
    else if ( [item isPlaybackLikelyToKeepUp] ) ///< 缓冲足够播放
        return SJPlayerBufferStatusPlayable;
    else if ( [item isPlaybackBufferEmpty] )    ///< 缓冲空了
        return SJPlayerBufferStatusUnplayable;
    
    return SJPlayerBufferStatusUnknown;
}
- (BOOL)sj_getIsPlayed {
    return _sj_playbackInfo->isPlayed;
}
- (BOOL)sj_getIsPlaying {
    if ( !isFloatZero(self.rate) )
        return YES;
    if ( _sj_playbackInfo->isPrerolling && SJReachability.shared.networkStatus != SJNetworkStatus_NotReachable )
        return YES;
    
    return NO;
}
- (SJMediaPlaybackType)sj_getPlaybackType {
    return _sj_playbackInfo->playbackType;
}
- (NSTimeInterval)sj_getDuration {
    return _sj_playbackInfo->duration;
}
- (NSTimeInterval)sj_getCurrentPlaybackTime {
    if ( _sj_playbackInfo->prepareStatus != SJAVMediaPrepareStatusSuccessfullyToPrepare )
        return 0;
    if ( _sj_playbackInfo->seekingInfo.isSeeking )
        return CMTimeGetSeconds(_sj_playbackInfo->seekingInfo.time);
    return CMTimeGetSeconds(self.currentTime);
}
- (NSTimeInterval)sj_getPlayableDuration {
    if ( _sj_playbackInfo->prepareStatus != SJAVMediaPrepareStatusSuccessfullyToPrepare )
        return 0;
    return _sj_playbackInfo->playableDuration;
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
