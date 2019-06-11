//
//  SJAVMediaPlaybackController.m
//  Project
//
//  Created by BlueDancer on 2018/8/10.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJAVMediaPlaybackController.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif
#if __has_include(<SJUIKit/SJRunLoopTaskQueue.h>)
#import <SJUIKit/SJRunLoopTaskQueue.h>
#else
#import "SJRunLoopTaskQueue.h"
#endif
#import "SJAVMediaMainPresenter.h"
#import "SJAVMediaPlayer.h"
#import "SJAVMediaPlayerLoader.h"
#import "SJAVMediaDefinitionLoader.h"
#import "SJReachability.h"
#import "SJVideoPlayerRegistrar.h"
#import "AVAsset+SJAVMediaExport.h"
#import "NSTimer+SJAssetAdd.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlaybackController()
@property (nonatomic, strong, nullable) SJAVMediaDefinitionLoader *definitionLoader;
@property (nonatomic, strong, readonly) SJAVMediaMainPresenter *mainPresenter;
@property (nonatomic, strong, readonly) SJVideoPlayerRegistrar *registrar;
@property (nonatomic, strong, nullable) SJAVMediaPlayer *player;
@property (nonatomic, strong, nullable) id periodicTimeObserver;
@end

@implementation SJAVMediaPlaybackController
@synthesize pauseWhenAppDidEnterBackground = _pauseWhenAppDidEnterBackground;
@synthesize refreshTimeInterval = _refreshTimeInterval;
@synthesize delegate = _delegate;
@synthesize volume = _volume;
@synthesize rate = _rate;
@synthesize mute = _mute;
@synthesize media = _media;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _rate =
    _volume = 1;
    _refreshTimeInterval = 0.5;
    _mainPresenter = [SJAVMediaMainPresenter mainPresenter];
    [self _observeEvents];
    return self;
}

- (void)dealloc {
    [self removePeriodicTimeObserver];
}

- (void)_observeEvents {
    __weak typeof(self) _self = self;
    sjkvo_observe(_mainPresenter, @"readyForDisplay", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(playbackControllerIsReadyForDisplay:)] ) {
            [self.delegate playbackControllerIsReadyForDisplay:self];
        #ifdef SJMAC
            printf("\nSJAVMediaPlaybackController<%p>.isReadyForDisplay = %d\n", self, self.isReadyForDisplay);
        #endif
        }
    });
    
    [self sj_observeWithNotification:SJAVMediaPlaybackStatusDidChangeNotification target:nil usingBlock:^(SJAVMediaPlaybackController *self, NSNotification * _Nonnull note) {
        if ( self.player == note.object ) {
            [self _playStatusDidChange];
        }
    }];
    [self sj_observeWithNotification:SJAVMediaBufferStatusDidChangeNotification target:nil usingBlock:^(SJAVMediaPlaybackController *self, NSNotification * _Nonnull note) {
        id<SJAVMediaPlayerProtocol> player = self.player;
        if ( player == note.object ) {
            if ( [self.delegate respondsToSelector:@selector(playbackController:bufferStatusDidChange:)] ) {
                [self.delegate playbackController:self bufferStatusDidChange:player.sj_bufferStatus];
            }
        }
    }];
    [self sj_observeWithNotification:SJAVMediaPlayableDurationDidChangeNotification target:nil usingBlock:^(SJAVMediaPlaybackController *self, NSNotification * _Nonnull note) {
        id<SJAVMediaPlayerProtocol> player = self.player;
        if ( player == note.object ) {
            if ( [self.delegate respondsToSelector:@selector(playbackController:bufferLoadedTimeDidChange:)] ) {
                [self.delegate playbackController:self bufferLoadedTimeDidChange:player.sj_getPlayableDuration];
            }
        }
    }];
    [self sj_observeWithNotification:SJAVMediaPlayDidToEndTimeNotification target:nil usingBlock:^(SJAVMediaPlaybackController *self, NSNotification * _Nonnull note) {
        id<SJAVMediaPlayerProtocol> player = self.player;
        if ( player == note.object ) {
            if ( [self.delegate respondsToSelector:@selector(mediaDidPlayToEndForPlaybackController:)] ) {
                [self.delegate mediaDidPlayToEndForPlaybackController:self];
            }
        }
    }];
    [self sj_observeWithNotification:SJAVMediaLoadedPresentationSizeNotification target:nil usingBlock:^(SJAVMediaPlaybackController *self, NSNotification * _Nonnull note) {
        id<SJAVMediaPlayerProtocol> player = self.player;
        if ( player == note.object ) {
            if ( [self.delegate respondsToSelector:@selector(playbackController:presentationSizeDidChange:)] ) {
                [self.delegate playbackController:self presentationSizeDidChange:player.sj_getPresentationSize];
            }
        }
    }];
    [self sj_observeWithNotification:SJAVMediaLoadedPlaybackTypeNotification target:nil usingBlock:^(SJAVMediaPlaybackController *self, NSNotification * _Nonnull note) {
        id<SJAVMediaPlayerProtocol> player = self.player;
        if ( player == note.object ) {
            if ( [self.delegate respondsToSelector:@selector(playbackController:playbackTypeLoaded:)] ) {
                [self.delegate playbackController:self playbackTypeLoaded:player.sj_getPlaybackType];
            }
        }
    }];
    
    
    _registrar = [[SJVideoPlayerRegistrar alloc] init];
    _registrar.didBecomeActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _resetMainPresenterIfNeeded];
    };
    _registrar.didEnterBackground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _applicationEnterBackgrond];
    };
}

- (void)_playStatusDidChange {
    SJVideoPlayerPlayStatus status = _player.sj_playbackStatus;
    if ( [self.delegate respondsToSelector:@selector(playbackController:playbackStatusDidChange:)] ) {
        [self.delegate playbackController:self playbackStatusDidChange:status];
    }
}

- (void)_resetMainPresenterIfNeeded {
    if ( self.registrar.state == SJVideoPlayerAppState_Background )
        return;

    SJRunLoopTaskQueue.main.enqueue(^{
        AVPlayer *player = self.player.sj_getAVPlayer;
        if ( self.mainPresenter.player != self.player.sj_getAVPlayer ) {
            SJAVMediaSubPresenter *presenter = [[SJAVMediaSubPresenter alloc] initWithAVPlayer:player];
            [self.mainPresenter takeOverSubPresenter:presenter];
        }
    });
}

- (void)_applicationEnterBackgrond {
    if ( self.pauseWhenAppDidEnterBackground ) {
        [self pause];
    }
    else {
        [self.mainPresenter removeAllPresenters];
    }
}

- (void)setRefreshTimeInterval:(NSTimeInterval)refreshTimeInterval {
    if ( refreshTimeInterval == _refreshTimeInterval )
        return;
    _refreshTimeInterval = refreshTimeInterval;
    [self removePeriodicTimeObserver];
    [self addPeriodicTimeObserver];
}
- (void)addPeriodicTimeObserver {
    __weak typeof(self) _self = self;
    _periodicTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(_refreshTimeInterval, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(playbackController:currentTimeDidChange:)] ) {
            [self.delegate playbackController:self currentTimeDidChange:self.player.sj_getCurrentPlaybackTime];
        }
    }];
}
- (void)removePeriodicTimeObserver {
    if ( _periodicTimeObserver != nil ) {
        [_player removeTimeObserver:_periodicTimeObserver];
        _periodicTimeObserver = nil;
    }
}
- (NSError *_Nullable)error {
    return _player.sj_getError;
}
- (UIView *)playerView {
    return _mainPresenter;
}
- (SJMediaPlaybackType)playbackType {
    return _player.sj_getPlaybackType;
}
- (void)setVideoGravity:(SJVideoGravity)videoGravity {
    _mainPresenter.videoGravity = videoGravity;
}
- (SJVideoGravity)videoGravity {
    return _mainPresenter.videoGravity;
}
- (SJVideoPlayerInactivityReason)inactivityReason {
    return _player.sj_inactivityReason;
}
- (SJVideoPlayerPausedReason)pausedReason {
    return _player.sj_pausedReason;
}
- (SJVideoPlayerPlayStatus)playStatus {
    return _player.sj_playbackStatus;
}
- (SJPlayerBufferStatus)bufferStatus {
    return _player.sj_bufferStatus;
}
- (NSTimeInterval)currentTime {
    return _player.sj_getCurrentPlaybackTime;
}
- (NSTimeInterval)duration {
    return _player.sj_getDuration;
}
- (NSTimeInterval)bufferLoadedTime {
    return _player.sj_getPlayableDuration;
}
- (CGSize)presentationSize {
    return _player.sj_getPresentationSize;
}
- (BOOL)isReadyForDisplay {
    return _mainPresenter.isReadyForDisplay;
}
- (BOOL)isPlayed {
    return _player.sj_getIsPlayed;
}
- (BOOL)isReplayed {
    return _player.sj_isReplayed;
}
- (void)setVolume:(float)volume {
    _volume = volume;
    _player.sj_playbackVolume = volume;
}
- (void)setRate:(float)rate {
    _rate = rate;
    _player.sj_playbackRate = rate;
}
- (void)setMute:(BOOL)mute {
    _mute = mute;
    _player.sj_muted = mute;
}
- (SJMediaPlaybackPrepareStatus)prepareStatus {
    return (NSInteger)_player.sj_getAVPlayerItemStatus;
}
- (void)_reset:(id<SJMediaModelProtocol>)meida player:(id<SJAVMediaPlayerProtocol>)player presenter:(id<SJAVMediaPresenter>)presenter {
    self.media = meida;
    self.player = player;
    SJRunLoopTaskQueue.main.enqueue(^{
        [self.mainPresenter takeOverSubPresenter:presenter];
    });
    [self play];
}

- (void)setMedia:(id<SJMediaModelProtocol> _Nullable)media {
    [self stop];
    _media = media;
    [self _playStatusDidChange];
}

- (void)setPlayer:(id<SJAVMediaPlayerProtocol> _Nullable)player {
    [self removePeriodicTimeObserver];
    _player = player;
    player.sj_muted = self.mute;
    player.sj_playbackVolume = self.volume;
    [self addPeriodicTimeObserver];
}

- (void)prepareToPlay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _prepareToPlay];
    });
}

- (void)_prepareToPlay {
    NSTimeInterval playableLimit = _media.playableLimit;
    if ( playableLimit == 0 || _media.mediaURL == nil ) {
        __weak typeof(self) _self = self;
        [SJAVMediaPlayerLoader loadPlayerForMedia:_media completionHandler:^(id<SJMediaModelProtocol>  _Nonnull media, id<SJAVMediaPlayerProtocol>  _Nonnull player) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( media == self.media ) {
                self.player = player;
                [self.player report];
                [self _resetMainPresenterIfNeeded];
            }
        }];
    }
    else {
        id<SJMediaModelProtocol> media = _media;
        AVURLAsset *source = [[AVURLAsset alloc] initWithURL:media.mediaURL options:nil];
        NSString *kTracks = @"tracks";
        NSString *kDuration = @"duration";
        [source loadValuesAsynchronouslyForKeys:@[kTracks, kDuration] completionHandler:^{
            if ( media != self.media ) {
                return ;
            }
            
            AVKeyValueStatus tracksStatus = [source statusOfValueForKey:kTracks error:nil];
            AVKeyValueStatus durationStatus = [source statusOfValueForKey:kDuration error:nil];
            if ( tracksStatus != AVKeyValueStatusLoaded || durationStatus != AVKeyValueStatusLoaded ) {
                return;
            }
            
            AVMutableComposition *asset = [AVMutableComposition composition];
            CMTime start = kCMTimeZero;
            CMTime duration = CMTimeMakeWithSeconds(playableLimit, NSEC_PER_SEC);
            CMTimeRange sourceRange = CMTimeRangeMake(start, duration);
            AVMutableCompositionTrack *videoTrack = [asset addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:0];
            [videoTrack insertTimeRange:sourceRange ofTrack:[source tracksWithMediaType:AVMediaTypeVideo].lastObject atTime:kCMTimeZero error:nil];
            
            AVMutableCompositionTrack *audioTrack = [asset addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
            [audioTrack insertTimeRange:sourceRange ofTrack:[source tracksWithMediaType:AVMediaTypeAudio].lastObject atTime:kCMTimeZero error:nil];
            
            self.player = [[SJAVMediaPlayer alloc] initWithAVAsset:asset specifyStartTime:media.specifyStartTime];
            [self.player sj_setForceDuration:CMTimeGetSeconds(source.duration)];
            [self.player report];
            [self _resetMainPresenterIfNeeded];
        }];
    }
}

- (void)replay {
    SJRunLoopTaskQueue.main.enqueue(^{
        [self.player replay];
    });
}
- (void)refresh {
    SJRunLoopTaskQueue.main.enqueue(^{
        id<SJMediaModelProtocol> media = self.media;
        NSTimeInterval currentTime = self.currentTime;
        if ( 0 != self.currentTime ) media.specifyStartTime = currentTime;
        self.media = media;
        [self prepareToPlay];
    });
}
- (void)play {
    SJRunLoopTaskQueue.main.enqueue(^{
        [self.player play];
    });
}
- (void)pause {
    SJRunLoopTaskQueue.main.enqueue(^{
        [self.player pause];
    });
}
- (void)stop {
    id<SJAVMediaPlayerProtocol> _Nullable player = _player;
    [self removePeriodicTimeObserver];
    _player = nil;
    _media = nil;
    _definitionLoader = nil;
    [_mainPresenter removeAllPresenters];
    [player pause];
}
- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^_Nullable)(BOOL))completionHandler {
    [self.player seekToTime:CMTimeMakeWithSeconds(secs, NSEC_PER_SEC) completionHandler:completionHandler];
}
- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^_Nullable)(BOOL))completionHandler {
    [self.player seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
}
- (void)switchVideoDefinition:(id<SJMediaModelProtocol>)media {
    if ( !media ) return;
    
    [self _definitionSwitchingStatusDidChange:media status:SJMediaPlaybackSwitchDefinitionStatusSwitching];
    __weak typeof(self) _self = self;
    _definitionLoader = [[SJAVMediaDefinitionLoader alloc] initWithMedia:media handler:^(SJAVMediaDefinitionLoader * _Nonnull loader, AVPlayerItemStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch ( status ) {
            case AVPlayerItemStatusFailed: {
                [self _definitionSwitchingStatusDidChange:media status:SJMediaPlaybackSwitchDefinitionStatusFailed];
            }
                break;
            case AVPlayerItemStatusUnknown: break;
            case AVPlayerItemStatusReadyToPlay: {
                
                // - 切换清晰度将在未来继续完善 -
                
                // present
                SJAVMediaSubPresenter *presenter = [[SJAVMediaSubPresenter alloc] initWithAVPlayer:loader.player.sj_getAVPlayer];
                [self.mainPresenter insertSubPresenterToBack:presenter];
                __weak typeof(self) _self = self;
                SJKVOObserverToken __block token = sjkvo_observe(presenter, @"readyForDisplay", ^(SJAVMediaSubPresenter *subPresenter, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    // ready for display
                    if ( [subPresenter isReadyForDisplay] ) {
                        // seek to current time
                        [loader.player.sj_getAVPlayer seekToTime:self.player?CMTimeMakeWithSeconds(self.player.sj_getCurrentPlaybackTime, NSEC_PER_SEC):kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                            if ( !finished ) {
                                [self.mainPresenter removeSubPresenter:subPresenter];
                                [self _definitionSwitchingStatusDidChange:media status:SJMediaPlaybackSwitchDefinitionStatusFailed];
                                return;
                            }
                            // remove `isReadyForDisplay` observer
                            sjkvo_remove(subPresenter, token);
                            [self _reset:media player:loader.player presenter:subPresenter];
                            [self _definitionSwitchingStatusDidChange:media status:SJMediaPlaybackSwitchDefinitionStatusFinished];
                        }];
                    }
                });
            }
                break;
        }
    }];
}

- (void)_definitionSwitchingStatusDidChange:(id<SJMediaModelProtocol>)media status:(SJMediaPlaybackSwitchDefinitionStatus)status {
    if ( status == SJMediaPlaybackSwitchDefinitionStatusFinished || status == SJMediaPlaybackSwitchDefinitionStatusFailed ) {
        _definitionLoader = nil;
    }
    
    if ( [self.delegate respondsToSelector:@selector(playbackController:switchingDefinitionStatusDidChange:media:)] ) {
        [self.delegate playbackController:self switchingDefinitionStatusDidChange:status media:media];
    }
    
#ifdef SJMAC
    char *str = nil;
    switch ( status ) {
        case SJMediaPlaybackSwitchDefinitionStatusUnknown: break;
        case SJMediaPlaybackSwitchDefinitionStatusSwitching:
            str = "Switching";
            break;
        case SJMediaPlaybackSwitchDefinitionStatusFinished:
            str = "Finished";
            break;
        case SJMediaPlaybackSwitchDefinitionStatusFailed:
            str = "Failed";
            break;
    }
    printf("\nSJAVMediaPlaybackController<%p>.switchStatus = %s\n", self, str);
#endif
}

- (UIImage *_Nullable)screenshot {
    return [[_player sj_getAVAsset] sj_screenshotWithTime:CMTimeMakeWithSeconds(_player.sj_getCurrentPlaybackTime, NSEC_PER_SEC)];
}
- (void)screenshotWithTime:(NSTimeInterval)time size:(CGSize)size completion:(nonnull void (^)(id<SJMediaPlaybackController> _Nonnull, UIImage * _Nullable, NSError * _Nullable))block {
    __weak typeof(self) _self = self;
    [[_player sj_getAVAsset] sj_screenshotWithTime:time size:size completionHandler:^(AVAsset * _Nonnull a, UIImage * _Nullable image, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self, image, error);
    }];
}

- (void)exportWithBeginTime:(NSTimeInterval)beginTime endTime:(NSTimeInterval)endTime presetName:(nullable NSString *)presetName progress:(nonnull void (^)(id<SJMediaPlaybackController> _Nonnull, float))progressBlock completion:(nonnull void (^)(id<SJMediaPlaybackController> _Nonnull, NSURL * _Nullable, UIImage * _Nullable))completionBlock failure:(nonnull void (^)(id<SJMediaPlaybackController> _Nonnull, NSError * _Nullable))failureBlock {
    
    NSURL *exportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"Export.mp4"];
    [[NSFileManager defaultManager] removeItemAtURL:exportURL error:nil];
    __weak typeof(self) _self = self;
    [[_player sj_getAVAsset] sj_exportWithStartTime:beginTime duration:endTime - beginTime toFile:exportURL presetName:presetName progress:^(AVAsset * _Nonnull a, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( progressBlock ) progressBlock(self, progress);
    } success:^(AVAsset * _Nonnull a, AVAsset * _Nullable sandboxAsset, NSURL * _Nullable fileURL, UIImage * _Nullable thumbImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completionBlock ) completionBlock(self, fileURL, thumbImage);
    } failure:^(AVAsset * _Nonnull a, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( failureBlock ) failureBlock(self, error);
    }];
}

- (void)cancelExportOperation {
    [[_player sj_getAVAsset] sj_cancelExportOperation];
}

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime duration:(NSTimeInterval)duration maximumSize:(CGSize)maximumSize interval:(float)interval gifSavePath:(nonnull NSURL *)gifSavePath progress:(nonnull void (^)(id<SJMediaPlaybackController> _Nonnull, float))progressBlock completion:(nonnull void (^)(id<SJMediaPlaybackController> _Nonnull, UIImage * _Nonnull, UIImage * _Nonnull))completion failure:(nonnull void (^)(id<SJMediaPlaybackController> _Nonnull, NSError * _Nonnull))failure {
    __weak typeof(self) _self = self;
    [[_player sj_getAVAsset] sj_generateGIFWithBeginTime:beginTime duration:duration imageMaxSize:maximumSize interval:interval toFile:gifSavePath progress:^(AVAsset * _Nonnull a, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( progressBlock ) progressBlock(self, progress);
    } success:^(AVAsset * _Nonnull a, UIImage * _Nonnull GIFImage, UIImage * _Nonnull thumbnailImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completion ) completion(self, GIFImage, thumbnailImage);
    } failure:^(AVAsset * _Nonnull a, NSError * _Nonnull error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( failure ) failure(self, error);
    }];
}

- (void)cancelGenerateGIFOperation {
    [[_player sj_getAVAsset] sj_cancelGenerateGIFOperation];
}
@end
NS_ASSUME_NONNULL_END
