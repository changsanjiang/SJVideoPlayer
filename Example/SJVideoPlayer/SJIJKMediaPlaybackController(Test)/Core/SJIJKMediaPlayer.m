//
//  SJIJKMediaPlayer.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/10/12.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJIJKMediaPlayer.h"

NS_ASSUME_NONNULL_BEGIN
NSNotificationName const SJIJKMediaPlayerAssetStatusDidChangeNotification = @"SJIJKMediaPlayerAssetStatusDidChangeNotification";
NSNotificationName const SJIJKMediaPlayerTimeControlStatusDidChangeNotification = @"SJIJKMediaPlayerTimeControlStatusDidChangeNotification";
NSNotificationName const SJIJKMediaPlayerDurationDidChangeNotification = @"SJIJKMediaPlayerDurationDidChangeNotification";
NSNotificationName const SJIJKMediaPlayerPlayableDurationDidChangeNotification = @"SJIJKMediaPlayerPlayableDurationDidChangeNotification";
NSNotificationName const SJIJKMediaPlayerPresentationSizeDidChangeNotification = @"SJIJKMediaPlayerPresentationSizeDidChangeNotification";
NSNotificationName const SJIJKMediaPlayerPlaybackTypeDidChangeNotification = @"SJIJKMediaPlayerPlaybackTypeDidChangeNotification";
NSNotificationName const SJIJKMediaPlayerDidPlayToEndTimeNotification = @"SJIJKMediaPlayerDidPlayToEndTimeNotification";

typedef struct {
    BOOL isFinished;
    IJKMPMovieFinishReason reason;
} SJIJKFinishedInfo;

@interface SJIJKMediaPlayer ()
@property (nonatomic, strong, nullable) NSError *sj_error;
@property (nonatomic, nullable) SJWaitingReason sj_reasonForWaitingToPlay;
@property (nonatomic) SJPlaybackTimeControlStatus sj_timeControlStatus;
@property (nonatomic) SJAssetStatus sj_assetStatus;
@property (nonatomic) SJSeekingInfo sj_seekingInfo;
@property (nonatomic) SJAVMediaPlayerPlaybackInfo sj_playbackInfo;
@property (nonatomic) SJIJKFinishedInfo sj_finishedInfo;
@end

@implementation SJIJKMediaPlayer
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifdef DEBUG
        [IJKFFMoviePlayerController setLogReport:YES];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_ERROR];
#else
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    });
}

- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime {
    self = [super initWithContentURL:URL withOptions:IJKFFOptions.optionsByDefault];
    if ( self ) {
        _sj_URL = URL;
        _sj_playbackInfo.rate = 1;
        _sj_playbackInfo.specifyStartTime = specifyStartTime;
         
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_sj_preparedToPlayDidChange:) name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:self];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_sj_playbackDidFinish:) name:IJKMPMoviePlayerPlaybackDidFinishNotification object:self];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_sj_playbackStateDidChange:) name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:self];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_sj_loadStateDidChange:) name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_sj_naturalSizeAvailable:) name:IJKMPMovieNaturalSizeAvailableNotification object:self];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_sj_didSeekComplete:) name:IJKMPMoviePlayerDidSeekCompleteNotification object:self];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_sj_accurateSeekComplete:) name:IJKMPMoviePlayerAccurateSeekCompleteNotification object:self];

        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sj_audioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sj_audioSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
        
        self.shouldAutoplay = NO;
        self.sj_assetStatus = SJAssetStatusPreparing;
        [self setPauseInBackground:YES];
        [self prepareToPlay];
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    printf("%d - %s", (int)__LINE__, __func__);
#endif
    [self stop];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)sj_playImmediatelyAtRate:(float)rate {
    [self play];
}

- (id)sj_addPeriodicTimeObserverForInterval:(CMTime)interval queue:(nullable dispatch_queue_t)queue usingBlock:(void (^)(CMTime))block {
    return nil;
}

- (void)sj_removeTimeObserver:(id)observer {
    
}

- (void)sj_setPauseInBackground:(BOOL)pause {
    [self setPauseInBackground:pause];
}

- (void)replay {
    
}

- (void)report {
    
}

- (void)play {
    self.sj_reasonForWaitingToPlay = SJWaitingWhileEvaluatingBufferingRateReason;
    self.sj_timeControlStatus = SJPlaybackTimeControlStatusWaitingToPlay;
    
    [super play];
}

- (void)pause {
    self.sj_reasonForWaitingToPlay = nil;
    self.sj_timeControlStatus = SJPlaybackTimeControlStatusPaused;
    
    [super pause];
}

- (void)stop {
    self.sj_reasonForWaitingToPlay = nil;
    self.sj_timeControlStatus = SJPlaybackTimeControlStatusPaused;
    
    [super stop];
}

#pragma mark -

- (void)setSj_rate:(float)sj_rate {
    _sj_playbackInfo.rate = sj_rate;
}
- (float)sj_rate {
    return _sj_playbackInfo.rate;
}

#pragma mark -

- (void)_sj_preparedToPlayDidChange:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _updateAssetStatus];
        if ( self.sj_assetStatus == SJAssetStatusReadyToPlay ) {
            if ( self.sj_timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
                [super play];
            }
        }
    });
}

- (void)_sj_playbackDidFinish:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _updateFinishedInfo:note];
        [self _updateAssetStatus];
    });
}

- (void)_sj_playbackStateDidChange:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _sj_toEvaluating];
    });
}

- (void)_sj_loadStateDidChange:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _sj_toEvaluating];
    });
}

- (void)_sj_naturalSizeAvailable:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _updatePresentationSize];
    });
}

- (void)_sj_didSeekComplete:(NSNotification *)note {
    #ifdef DEBUG
        NSLog(@"%d - %s - %@", (int)__LINE__, __func__, note);
    #endif
}

- (void)_sj_accurateSeekComplete:(NSNotification *)note {
    #ifdef DEBUG
        NSLog(@"%d - %s - %@", (int)__LINE__, __func__, note);
    #endif
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

#pragma mark -

- (void)_sj_toEvaluating {
    if ( self.sj_timeControlStatus == SJPlaybackTimeControlStatusWaitingToPlay ) {
        SJPlaybackTimeControlStatus status = self.sj_timeControlStatus;
        SJWaitingReason _Nullable  reason = self.sj_reasonForWaitingToPlay;
        
        if ( self.loadState & IJKMPMovieLoadStateStalled ) {
            reason = SJWaitingToMinimizeStallsReason;
            status = SJPlaybackTimeControlStatusWaitingToPlay;
        }
        else if ( self.loadState & IJKMPMovieLoadStatePlayable ) {
            reason = nil;
            status = SJPlaybackTimeControlStatusPlaying;
        }
        
        if ( status != self.sj_timeControlStatus || reason != self.sj_reasonForWaitingToPlay ) {
            self.sj_reasonForWaitingToPlay = reason;
            self.sj_timeControlStatus = status;
            [self _postNotification:SJIJKMediaPlayerTimeControlStatusDidChangeNotification];
        }
    }
}

- (void)_updatePresentationSize {
    CGSize oldSize = self.sj_playbackInfo.presentationSize;
    CGSize newSize = self.naturalSize;
    if ( !CGSizeEqualToSize(oldSize, newSize) ) {
        _sj_playbackInfo.presentationSize = newSize;
        [self _postNotification:SJIJKMediaPlayerPresentationSizeDidChangeNotification];
    }
}

- (void)_updateFinishedInfo:(NSNotification *)note {
    IJKMPMovieFinishReason reason = [note.userInfo[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    _sj_finishedInfo.isFinished = YES;
    _sj_finishedInfo.reason = reason;
    
    if ( reason == IJKMPMovieFinishReasonPlaybackEnded ) {
        _sj_playbackInfo.isPlayedToEndTime = YES;
    }
}

- (void)_updateAssetStatus {
    SJAssetStatus status = self.sj_assetStatus;
    if ( self.sj_finishedInfo.isFinished ) {
        switch ( self.sj_finishedInfo.reason ) {
            case IJKMPMovieFinishReasonPlaybackEnded: break;
            case IJKMPMovieFinishReasonUserExited: break;
            case IJKMPMovieFinishReasonPlaybackError: {
                status = SJAssetStatusFailed;
            }
                break;
        }
    }
    else if ( self.isPreparedToPlay ) {
        status = SJAssetStatusReadyToPlay;
    }
    
    if ( status != self.sj_assetStatus ) {
        self.sj_assetStatus = status;
        [self _postNotification:SJIJKMediaPlayerAssetStatusDidChangeNotification];
    }
}

- (void)_postNotification:(NSNotificationName)name {
    [NSNotificationCenter.defaultCenter postNotificationName:name object:self];
}

- (void)setSj_assetStatus:(SJAssetStatus)sj_assetStatus {
    _sj_assetStatus = sj_assetStatus;
    
#ifdef SJDEBUG
    switch ( sj_assetStatus ) {
        case SJAssetStatusUnknown:
            printf("SJIJKMediaPlayer.assetStatus.Unknown\n");
            break;
        case SJAssetStatusPreparing:
            printf("SJIJKMediaPlayer.assetStatus.Preparing\n");
            break;
        case SJAssetStatusReadyToPlay:
            printf("SJIJKMediaPlayer.assetStatus.ReadyToPlay\n");
            break;
        case SJAssetStatusFailed:
            printf("SJIJKMediaPlayer.assetStatus.Failed\n");
            break;
    }
#endif
}

- (void)setSj_timeControlStatus:(SJPlaybackTimeControlStatus)sj_timeControlStatus {
    _sj_timeControlStatus = sj_timeControlStatus;

#ifdef SJDEBUG
    switch ( sj_timeControlStatus ) {
        case SJPlaybackTimeControlStatusPaused:
            printf("SJIJKMediaPlayer.timeControlStatus.Pause\n");
            break;
        case SJPlaybackTimeControlStatusWaitingToPlay:
            printf("SJIJKMediaPlayer.timeControlStatus.WaitingToPlay.reason(%s)\n", _sj_reasonForWaitingToPlay.UTF8String);
            break;
        case SJPlaybackTimeControlStatusPlaying:
            printf("SJIJKMediaPlayer.timeControlStatus.Playing\n");
            break;
    }
#endif
}
@end
NS_ASSUME_NONNULL_END
