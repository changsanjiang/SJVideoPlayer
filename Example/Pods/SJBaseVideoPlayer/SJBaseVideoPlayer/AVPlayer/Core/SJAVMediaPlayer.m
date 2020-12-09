//
//  SJAVMediaPlayer.m
//  Pods
//
//  Created by 畅三江 on 2020/2/18.
//

#import "SJAVMediaPlayer.h"
#import "AVAsset+SJAVMediaExport.h"
#import "NSTimer+SJAssetAdd.h"

#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlayer ()
@property (nonatomic, strong, nullable) NSError *innerError;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval playableDuration;
@property (nonatomic, nullable) SJWaitingReason reasonForWaitingToPlay;
@property (nonatomic) NSTimeInterval startPosition;
@property (nonatomic) BOOL needSeekToStartPosition;
@property (nonatomic) BOOL isPlaybackFinished;                        ///< 播放结束
@property (nonatomic, nullable) SJFinishedReason finishedReason;      ///< 播放结束的reason
@property (nonatomic, strong, nullable) NSTimer *refreshTimer;
@property (nonatomic, readonly) BOOL isPlayedToTrialEndPosition;
@end

@implementation SJAVMediaPlayer
@synthesize assetStatus = _assetStatus;
@synthesize reasonForWaitingToPlay = _reasonForWaitingToPlay;
@synthesize timeControlStatus = _timeControlStatus;
@synthesize rate = _rate;
@synthesize seekingInfo = _seekingInfo;
@synthesize duration = _duration;
@synthesize isPlayed = _isPlayed;
@synthesize isReplayed = _isReplayed;
@synthesize playableDuration = _playableDuration;

- (instancetype)initWithAVPlayer:(AVPlayer *)player startPosition:(NSTimeInterval)time {
    self = [super init];
    if ( self ) {
        _rate = 1;
        _avPlayer = player;
        _assetStatus = SJAssetStatusPreparing;
        _startPosition = time;
        _needSeekToStartPosition = time != 0;
        _minBufferedDuration = 8;
        [self _prepareToPlay];
    }
    return self;
}

- (void)play {
    if ( self.assetStatus == SJAssetStatusFailed ) {
        return;
    }
    
    if ( self.isPlaybackFinished ) {
        [self replay];
        return;
    }
    
    _isPlayed = YES;
    
    if ( self.timeControlStatus == SJPlaybackTimeControlStatusPaused ) {
        _reasonForWaitingToPlay = SJWaitingWhileEvaluatingBufferingRateReason;
        self.timeControlStatus = SJPlaybackTimeControlStatusWaitingToPlay;
    }
    
    [self.avPlayer play];
    self.avPlayer.rate = self.rate;
    [self _toEvaluating];
}

- (void)pause {
    self.timeControlStatus = SJPlaybackTimeControlStatusPaused;
    [self.avPlayer pause];
}

- (void)replay {
    if ( self.assetStatus == SJAssetStatusFailed ) {
        return;
    }
    
    _isReplayed = YES;
    
    if ( self.timeControlStatus == SJPlaybackTimeControlStatusPaused ) {
        _reasonForWaitingToPlay = SJWaitingWhileEvaluatingBufferingRateReason;
        self.timeControlStatus = SJPlaybackTimeControlStatusWaitingToPlay;
    }
    
    __weak typeof(self) _self = self;
    [self seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _postNotification:SJMediaPlayerDidReplayNotification];
        [self play];
    }];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^_Nullable)(BOOL))completionHandler {
    CMTime tolerance = _accurateSeeking ? kCMTimeZero : kCMTimePositiveInfinity;
    [self seekToTime:time toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^_Nullable)(BOOL))completionHandler {
    if ( self.avPlayer.currentItem.status != AVPlayerItemStatusReadyToPlay ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    time = [self _adjustSeekTimeIfNeeded:time];
    
    [self _willSeeking:time];
    __weak typeof(self) _self = self;
    [self.avPlayer seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _didEndSeeking];
        if ( completionHandler ) completionHandler(finished);
    }];
}

- (void)report {
    [self _postNotification:SJMediaPlayerAssetStatusDidChangeNotification];
    [self _postNotification:SJMediaPlayerTimeControlStatusDidChangeNotification];
    [self _postNotification:SJMediaPlayerDurationDidChangeNotification];
    [self _postNotification:SJMediaPlayerPlayableDurationDidChangeNotification];
    [self _postNotification:SJMediaPlayerPlaybackTypeDidChangeNotification];
}

#pragma mark -

- (void)setTrialEndPosition:(NSTimeInterval)trialEndPosition {
    if ( trialEndPosition != _trialEndPosition ) {
        _trialEndPosition = trialEndPosition;
        [self _refreshOrStop];
    }
}

- (void)setAssetStatus:(SJAssetStatus)assetStatus {
    _assetStatus = assetStatus;
    [self _postNotification:SJMediaPlayerAssetStatusDidChangeNotification];
    
#ifdef DEBUG
    if ( _assetStatus == SJAssetStatusFailed ) {
        if ( _innerError != nil ) {
            NSLog(@"SJAVMediaPlayer: %@", _innerError);
        }
        else if ( _avPlayer.error ) {
            NSLog(@"SJAVMediaPlayer: %@", self.avPlayer.error);
        }
        else if ( _avPlayer.currentItem.error ) {
            NSLog(@"SJAVMediaPlayer: %@", self.avPlayer.currentItem.error);
        }
    }
#endif
}

- (void)setTimeControlStatus:(SJPlaybackTimeControlStatus)timeControlStatus {
    _timeControlStatus = timeControlStatus;
    
    [self _refreshOrStop];
    
    [self _postNotification:SJMediaPlayerTimeControlStatusDidChangeNotification];
}

- (void)setIsPlaybackFinished:(BOOL)isPlaybackFinished {
    if ( isPlaybackFinished != _isPlaybackFinished ) {
        if ( !isPlaybackFinished ) _finishedReason = nil;
        _isPlaybackFinished = isPlaybackFinished;
        if ( isPlaybackFinished ) {
            [self _postNotification:SJMediaPlayerPlaybackDidFinishNotification];
        }
    }
}

- (void)setPlaybackType:(SJPlaybackType)playbackType {
    _playbackType = playbackType;
    [self _postNotification:SJMediaPlayerPlaybackTypeDidChangeNotification];
}

- (void)setMuted:(BOOL)muted {
    _avPlayer.muted = muted;
}
- (BOOL)isMuted {
    return _avPlayer.isMuted;
}

- (void)setVolume:(float)volume {
    _avPlayer.volume = volume;
}
- (float)volume {
    return _avPlayer.volume;
}

- (void)setRate:(float)rate {
    _rate = rate;
    
    if ( rate != 0 ) {
        self.timeControlStatus == SJPlaybackTimeControlStatusPaused ? [self play] : (_avPlayer.rate = rate);
    }
    else {
        [self pause];
    }
}

- (void)setInnerError:(nullable NSError *)innerError {
    _innerError = innerError;
    [self _toEvaluating];
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    [self _postNotification:SJMediaPlayerDurationDidChangeNotification];
}

- (void)setPlayableDuration:(NSTimeInterval)playableDuration {
    _playableDuration = playableDuration;
    [self _postNotification:SJMediaPlayerPlayableDurationDidChangeNotification];
}

- (NSTimeInterval)currentTime {
    if ( _isPlaybackFinished ) {
        if ( _finishedReason == SJFinishedReasonToEndTimePosition )
            return _duration;
        else if ( _finishedReason == SJFinishedReasonToTrialEndPosition )
            return _trialEndPosition;
    }
    return CMTimeGetSeconds(_avPlayer.currentTime);
}

- (NSTimeInterval)playableDuration {
    if ( _trialEndPosition != 0 && _playableDuration >= _trialEndPosition ) {
        return _trialEndPosition;
    }
    return _playableDuration;
}

- (CGSize)presentationSize {
    return _avPlayer.currentItem.presentationSize;
}

- (nullable UIImage *)screenshot {
    return [_avPlayer.currentItem.asset sj_screenshotWithTime:_avPlayer.currentTime];
}

#pragma mark -

- (void)_postNotification:(NSNotificationName)name {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSNotificationCenter.defaultCenter postNotificationName:name object:self];
    });
}

- (void)_willSeeking:(CMTime)time {
    [_avPlayer.currentItem cancelPendingSeeks];
    
    self.isPlaybackFinished = NO;
    _seekingInfo.time = time;
    _seekingInfo.isSeeking = YES;
}

- (void)_didEndSeeking {
    _seekingInfo.time = kCMTimeZero;
    _seekingInfo.isSeeking = NO;
}

- (void)_playImmediately {
    if ( @available(iOS 10.0, *) ) {
        [_avPlayer playImmediatelyAtRate:self.rate];
    }
    else {
        [self play];
    }
    [self _toEvaluating];
}

static NSString *kStatus = @"status";
static NSString *kPlaybackLikelyToKeepUp = @"playbackLikelyToKeepUp";
static NSString *kPlaybackBufferEmpty = @"playbackBufferEmpty";
static NSString *kPlaybackBufferFull = @"playbackBufferFull";
static NSString *kLoadedTimeRanges = @"loadedTimeRanges";
static NSString *kPresentationSize = @"presentationSize";
static NSString *kTimeControlStatus = @"timeControlStatus";

- (void)dealloc {
#ifdef SJDEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
#ifdef SJDEBUG1
    if (@available(iOS 10.0, *)) {
        if ( context == &kTimeControlStatus ) {
            switch ( _avPlayer.timeControlStatus ) {
                case AVPlayerTimeControlStatusPaused:
                    printf("AVPlayer.TimeControlStatus.Paused\n");
                    break;
                case AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate: {
                    if ( _avPlayer.reasonForWaitingToPlay == AVPlayerWaitingToMinimizeStallsReason ) {
                        printf("AVPlayer.TimeControlStatus.WaitingToPlay(Reason: WaitingToMinimizeStallsReason)\n");
                    }
                    else if ( _avPlayer.reasonForWaitingToPlay == AVPlayerWaitingWithNoItemToPlayReason ) {
                        printf("AVPlayer.TimeControlStatus.WaitingToPlay(Reason: WaitingWithNoItemToPlayReason)\n");
                    }
                    else if ( _avPlayer.reasonForWaitingToPlay == AVPlayerWaitingWhileEvaluatingBufferingRateReason ) {
                        printf("AVPlayer.TimeControlStatus.WaitingToPlay(Reason: WhileEvaluatingBufferingRateReason)\n");
                    }
                }
                    break;
                case AVPlayerTimeControlStatusPlaying:
                    printf("AVPlayer.TimeControlStatus.Playing\n");
                    break;
            }
        }
    }
#endif

    if ( context == &kStatus ||
         context == &kPlaybackLikelyToKeepUp ||
         context == &kPlaybackBufferEmpty ||
         context == &kPlaybackBufferFull ||
         context == &kTimeControlStatus ) {
        [self _toEvaluating];
    }
    else if ( context == &kLoadedTimeRanges ) {
        [self _loadedTimeRangesDidChange];
    }
    else if ( context == &kPresentationSize ) {
        [self _presentationSizeDidChange];
    }
}

- (void)_prepareToPlay {
    AVPlayerItem *playerItem = _avPlayer.currentItem;
    __weak typeof(self) _self = self;
    [playerItem.asset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateDuration];
    }];
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew;
    [playerItem sj_addObserver:self forKeyPath:kStatus options:options context:&kStatus];
    [playerItem sj_addObserver:self forKeyPath:kPlaybackLikelyToKeepUp options:options context:&kPlaybackLikelyToKeepUp];
    [playerItem sj_addObserver:self forKeyPath:kPlaybackBufferEmpty options:options context:&kPlaybackBufferEmpty];
    [playerItem sj_addObserver:self forKeyPath:kPlaybackBufferFull options:options context:&kPlaybackBufferFull];
    [playerItem sj_addObserver:self forKeyPath:kLoadedTimeRanges options:options context:&kLoadedTimeRanges];
    [playerItem sj_addObserver:self forKeyPath:kPresentationSize options:options context:&kPresentationSize];
    
    [_avPlayer sj_addObserver:self forKeyPath:kStatus options:options context:&kStatus];
    if ( @available(iOS 10.0, *) ) {
        [_avPlayer sj_addObserver:self forKeyPath:kTimeControlStatus options:options context:&kTimeControlStatus];
    }
    
    [self sj_observeWithNotification:AVPlayerItemFailedToPlayToEndTimeNotification target:playerItem usingBlock:^(SJAVMediaPlayer *self, NSNotification * _Nonnull note) {
        [self _failedToPlayToEndTime:note];
    }];
    [self sj_observeWithNotification:AVPlayerItemDidPlayToEndTimeNotification target:playerItem usingBlock:^(SJAVMediaPlayer *self, NSNotification * _Nonnull note) {
        [self _didPlayToEndTime:note];
    }];
    [self sj_observeWithNotification:AVPlayerItemNewAccessLogEntryNotification target:playerItem usingBlock:^(SJAVMediaPlayer *self, NSNotification * _Nonnull note) {
        [self _updatePlaybackType:note];
    }];

    [self _toEvaluating];
}

- (void)_toEvaluating {
    AVPlayerItem *playerItem = _avPlayer.currentItem;
    dispatch_async(dispatch_get_main_queue(), ^{
        __auto_type assetStatus = self.assetStatus;
        if ( self.innerError != nil || playerItem.status == AVPlayerItemStatusFailed || self.avPlayer.status == AVPlayerStatusFailed ) {
            assetStatus = SJAssetStatusFailed;
        }
        else if ( playerItem.status == AVPlayerItemStatusReadyToPlay && self.avPlayer.status == AVPlayerStatusReadyToPlay ) {
            assetStatus = SJAssetStatusReadyToPlay;
        }
        
        if ( assetStatus != self.assetStatus ) {
            self.assetStatus = assetStatus;
        }
        
        if ( assetStatus == SJAssetStatusFailed ) {
            self.timeControlStatus = SJPlaybackTimeControlStatusPaused;
        }
        
        if ( self.isPlayedToTrialEndPosition ) {
            [self _didPlayToTrialEndPosition];
            return ;
        }
        
        if ( self.needSeekToStartPosition && !self.seekingInfo.isSeeking && assetStatus == SJAssetStatusReadyToPlay ) {
            __weak typeof(self) _self = self;
            [self seekToTime:CMTimeMakeWithSeconds(self.startPosition, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL f) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                self.needSeekToStartPosition = NO;
                [self _toEvaluating];
            }];
            return;
        }
        
        if ( @available(iOS 10.0, *) ) {
            __auto_type avt = [self _timeControlStatusForAVPlayerTimeControlStatus:self.avPlayer.timeControlStatus];
            __auto_type avr = [self _waitingReasonForAVPlayerWaitingReason:self.avPlayer.reasonForWaitingToPlay];
            if ( self.timeControlStatus != avt || (avr != SJWaitingWithNoAssetToPlayReason && self.reasonForWaitingToPlay != avr) ) {
                self.reasonForWaitingToPlay = avr;
                self.timeControlStatus = avt;
            }
        }
        else {
            if ( self.timeControlStatus == SJPlaybackTimeControlStatusPaused ) {
                [self.avPlayer pause];
                return ;
            }
            __auto_type timeControlStatus = self.timeControlStatus;
            __auto_type reasonForWaitingToPlay = self.reasonForWaitingToPlay;
            if ( assetStatus == SJAssetStatusReadyToPlay && (playerItem.isPlaybackBufferFull || playerItem.isPlaybackLikelyToKeepUp) ) {
                reasonForWaitingToPlay = nil;
                timeControlStatus = SJPlaybackTimeControlStatusPlaying;
            }
            else {
                reasonForWaitingToPlay = SJWaitingToMinimizeStallsReason;
                timeControlStatus = SJPlaybackTimeControlStatusWaitingToPlay;
            }
            
            if ( self.timeControlStatus != timeControlStatus || reasonForWaitingToPlay != self.reasonForWaitingToPlay ) {
                self.reasonForWaitingToPlay = reasonForWaitingToPlay;
                self.timeControlStatus = timeControlStatus;
                if ( timeControlStatus == SJPlaybackTimeControlStatusPlaying ) {
                    [self.avPlayer play];
                }
            }
        }
    });
}

- (void)_updateDuration {
    NSTimeInterval duration = CMTimeGetSeconds(self.avPlayer.currentItem.asset.duration);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.duration = duration;
    });
}

- (void)_loadedTimeRangesDidChange {
    AVPlayerItem *playerItem = _avPlayer.currentItem;
    NSTimeInterval playbaleDuration = CMTimeGetSeconds(CMTimeRangeGetEnd([playerItem.loadedTimeRanges.firstObject CMTimeRangeValue]));
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playableDuration = playbaleDuration;
        if ( self.timeControlStatus == SJPlaybackTimeControlStatusWaitingToPlay &&
             self.reasonForWaitingToPlay == SJWaitingToMinimizeStallsReason &&
             playerItem.isPlaybackBufferEmpty == false ) {
            NSTimeInterval curTime = CMTimeGetSeconds(playerItem.currentTime);
            NSInteger playableMilli = (long)(playbaleDuration * 1000);
            NSInteger curMilli = (long)(curTime * 1000);
            NSInteger buffMilli = playableMilli - curMilli;
            NSInteger maxBuffMilli = (NSInteger)(self.minBufferedDuration ?: 8 * 1000);
            if ( buffMilli > maxBuffMilli ) {
                [self _playImmediately];
            }
            
#ifdef SJDEBUG
            if ( buffMilli < maxBuffMilli ) {
                printf("SJAVMediaPlayer: 缓冲中...  进度: \t %ld \t %ld \n", (long)buffMilli, (long)maxBuffMilli);
            }
#endif
        }
    });
}

- (void)_presentationSizeDidChange {
    [self _postNotification:SJMediaPlayerPresentationSizeDidChangeNotification];
}

- (void)_failedToPlayToEndTime:(NSNotification *)note {
    NSError *error = note.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.innerError = error;
    });
}

- (void)_didPlayToEndTime:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.finishedReason = SJFinishedReasonToEndTimePosition;
        self.isPlaybackFinished = YES;
        [self pause];
    });
}

- (void)_updatePlaybackType:(NSNotification *)note {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __auto_type event = self.avPlayer.currentItem.accessLog.events.firstObject;
        SJPlaybackType type = SJPlaybackTypeUnknown;
        if ( [event.playbackType isEqualToString:@"LIVE"] ) {
            type = SJPlaybackTypeLIVE;
        }
        else if ( [event.playbackType isEqualToString:@"VOD"] ) {
            type = SJPlaybackTypeVOD;
        }
        else if ( [event.playbackType isEqualToString:@"FILE"] ) {
            type = SJPlaybackTypeFILE;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( type != self.playbackType ) {
                self.playbackType = type;
            }
        });
    });
}

- (nullable SJWaitingReason)_waitingReasonForAVPlayerWaitingReason:(nullable AVPlayerWaitingReason)reason API_AVAILABLE(ios(10.0)) {
    if ( reason == AVPlayerWaitingWithNoItemToPlayReason )
        return SJWaitingWithNoAssetToPlayReason;
    if ( reason == AVPlayerWaitingToMinimizeStallsReason )
        return SJWaitingToMinimizeStallsReason;
    if ( reason == AVPlayerWaitingWhileEvaluatingBufferingRateReason )
        return SJWaitingWhileEvaluatingBufferingRateReason;
    return nil;
}

- (SJPlaybackTimeControlStatus)_timeControlStatusForAVPlayerTimeControlStatus:(AVPlayerTimeControlStatus)status  API_AVAILABLE(ios(10.0)) {
    switch ( status ) {
        case AVPlayerTimeControlStatusPaused:
            return SJPlaybackTimeControlStatusPaused;
        case AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate:
            return SJPlaybackTimeControlStatusWaitingToPlay;
        case AVPlayerTimeControlStatusPlaying:
            return SJPlaybackTimeControlStatusPlaying;
    }
}

- (BOOL)isPlayedToTrialEndPosition {
    return self.trialEndPosition != 0 && self.currentTime >= self.trialEndPosition;
}

- (void)_didPlayToTrialEndPosition {
    if ( self.finishedReason != SJFinishedReasonToTrialEndPosition ) {
        self.finishedReason = SJFinishedReasonToTrialEndPosition;
        self.isPlaybackFinished = YES;
        [self pause];
    }
}

- (CMTime)_adjustSeekTimeIfNeeded:(CMTime)time {
    if ( _trialEndPosition != 0 && CMTimeGetSeconds(time) >= _trialEndPosition ) {
        time = CMTimeMakeWithSeconds(_trialEndPosition * 0.98, NSEC_PER_SEC);
    }
    return time;
}

- (void)_refreshOrStop {
    if ( _trialEndPosition == 0 || _timeControlStatus == SJPlaybackTimeControlStatusPaused ) {
        if ( _refreshTimer != nil ) {
            [_refreshTimer invalidate];
            _refreshTimer = nil;
        }
    }
    else {
        if ( _refreshTimer == nil ) {
            __weak typeof(self) _self = self;
            _refreshTimer = [NSTimer sj_timerWithTimeInterval:0.5 repeats:YES usingBlock:^(NSTimer * _Nonnull timer) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( self.isPlayedToTrialEndPosition ) {
                    [self _didPlayToTrialEndPosition];
                }
            }];
            [_refreshTimer sj_fire];
            [NSRunLoop.mainRunLoop addTimer:_refreshTimer forMode:NSRunLoopCommonModes];
        }
    }
    
}

@end
NS_ASSUME_NONNULL_END
