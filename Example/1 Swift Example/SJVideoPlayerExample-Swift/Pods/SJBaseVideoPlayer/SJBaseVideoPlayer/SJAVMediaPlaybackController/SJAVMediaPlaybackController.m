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
@synthesize periodicTimeInterval = _periodicTimeInterval;
@synthesize delegate = _delegate;
@synthesize volume = _volume;
@synthesize rate = _rate;
@synthesize muted = _muted;
@synthesize media = _media;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _rate =
    _volume = 1;
    _periodicTimeInterval = 0.5;
    _mainPresenter = [SJAVMediaMainPresenter mainPresenter];
    _pauseWhenAppDidEnterBackground = YES;
    [self _observeEvents];
    return self;
}

- (void)dealloc {
    [self _removePeriodicTimeObserver];
}
- (void)setPeriodicTimeInterval:(NSTimeInterval)periodicTimeInterval {
    if ( periodicTimeInterval == _periodicTimeInterval )
        return;
    _periodicTimeInterval = periodicTimeInterval;
    [self _removePeriodicTimeObserver];
    [self _addPeriodicTimeObserver];
}
- (NSError *_Nullable)error {
    return _player.sj_error;
}
- (UIView *)playerView {
    return _mainPresenter;
}
- (SJPlaybackType)playbackType {
    return _player.sj_playbackInfo.playbackType;
}
- (void)setVideoGravity:(SJVideoGravity)videoGravity {
    _mainPresenter.videoGravity = videoGravity;
}
- (SJVideoGravity)videoGravity {
    return _mainPresenter.videoGravity;
}
- (SJAssetStatus)assetStatus {
    return _media == nil ? SJAssetStatusUnknown : _player.sj_assetStatus;
}
- (SJPlaybackTimeControlStatus)timeControlStatus {
    return _player.sj_timeControlStatus;
}
- (nullable SJWaitingReason)reasonForWaitingToPlay {
    return _player.sj_reasonForWaitingToPlay;
}
- (NSTimeInterval)currentTime {
    return _player ? CMTimeGetSeconds(_player.currentTime) : 0;
}
- (NSTimeInterval)duration {
    return _player.sj_playbackInfo.duration;
}
- (NSTimeInterval)playableDuration {
    return _player.sj_playbackInfo.playableDuration;
}
- (NSTimeInterval)durationWatched {
    NSTimeInterval time = 0;
    for ( AVPlayerItemAccessLogEvent *event in self.player.currentItem.accessLog.events) {
        if ( event.durationWatched <= 0 ) continue;
        time += event.durationWatched;
    }
    return time;
}
- (CGSize)presentationSize {
    return _player.sj_playbackInfo.presentationSize;
}
- (BOOL)isReadyForDisplay {
    return _mainPresenter.isReadyForDisplay;
}
- (BOOL)isPlayed {
    return _player.sj_playbackInfo.isPlayed;
}
- (BOOL)isReplayed {
    return _player.sj_playbackInfo.isReplayed;
}
- (BOOL)isPlayedToEndTime {
    return _player.sj_playbackInfo.isPlayedToEndTime;
}
- (void)setVolume:(float)volume {
    _volume = volume;
    _player.volume = volume;
}
- (void)setRate:(float)rate {
    _rate = rate;
    _player.sj_rate = rate;
}
- (void)setMuted:(BOOL)muted {
    _muted = muted;
    _player.muted = muted;
}
- (void)_reset:(id<SJMediaModelProtocol>)meida player:(SJAVMediaPlayer *)player presenter:(id<SJAVMediaPresenter>)presenter {
    [SJAVMediaPlayerLoader clearPlayerForMedia:_media];
    _media = meida;
    [self.player pause];
    self.player = player;
    [self.mainPresenter takeOverSubPresenter:presenter];
    [player report];
    [self play];
}

- (void)setMedia:(id<SJMediaModelProtocol> _Nullable)media {
    [self stop];
    _media = media;
}

- (void)setPlayer:(SJAVMediaPlayer * _Nullable)player {
    [self _removePeriodicTimeObserver];
    _player = player;
    player.muted = self.muted;
    player.volume = self.volume;
    player.sj_rate = self.rate;
    [self _addPeriodicTimeObserver];
}

- (void)prepareToPlay {
    if ( _media == nil ) return;
    self.player = [SJAVMediaPlayerLoader loadPlayerForMedia:_media];
    [self _resetMainPresenterIfNeeded];
    [self.player report];
}

- (void)replay {
    SJRunLoopTaskQueue.main.enqueue(^{
        [self.player replay];
    });
}
- (void)refresh {
    if ( self.player.sj_playbackInfo.isPlayed )
        self.media.specifyStartTime = self.currentTime;
    [self _stop];
    [SJAVMediaPlayerLoader clearPlayerForMedia:self.media];
    [self prepareToPlay];
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
    [self _stop];
    _media = nil;
}
- (void)_stop {
    [_mainPresenter removeAllPresenters];
    if ( self.player.sj_timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
        [self.player pause];
    }
    self.player = nil;
    _definitionLoader = nil;
}
- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^_Nullable)(BOOL))completionHandler {
    [self.player seekToTime:CMTimeMakeWithSeconds(secs, NSEC_PER_SEC) completionHandler:completionHandler];
}
- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^_Nullable)(BOOL))completionHandler {
    [self.player seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
}
- (void)switchVideoDefinition:(id<SJMediaModelProtocol>)media {
    if ( !media ) return;
    
    [self _definitionSwitchingStatusDidChange:media status:SJDefinitionSwitchStatusSwitching];
    __weak typeof(self) _self = self;
    _definitionLoader = [SJAVMediaDefinitionLoader.alloc initWithMedia:media assetStatudDidChangeHandler:^(SJAVMediaDefinitionLoader * _Nonnull loader) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch ( loader.player.sj_assetStatus ) {
            case SJAssetStatusUnknown:
            case SJAssetStatusPreparing: break;
            case SJAssetStatusReadyToPlay: {
                // - 切换清晰度将在未来继续完善 -
                
                // present
                SJAVMediaSubPresenter *presenter = [[SJAVMediaSubPresenter alloc] initWithAVPlayer:loader.player];
                [self.mainPresenter insertSubPresenterToBack:presenter];
                __weak typeof(self) _self = self;
                SJKVOObserverToken __block token = sjkvo_observe(presenter, @"readyForDisplay", ^(SJAVMediaSubPresenter *subPresenter, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    // ready for display
                    if ( [subPresenter isReadyForDisplay] ) {
                        // seek to current time
                        [loader.player seekToTime:self.player ? CMTimeMakeWithSeconds(self.currentTime, NSEC_PER_SEC):kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                            if ( !finished ) {
                                [self.mainPresenter removeSubPresenter:subPresenter];
                                [self _definitionSwitchingStatusDidChange:media status:SJDefinitionSwitchStatusFailed];
                                return;
                            }
                            // remove `isReadyForDisplay` observer
                            sjkvo_remove(subPresenter, token);
                            [self _reset:media player:loader.player presenter:subPresenter];
                            [self _definitionSwitchingStatusDidChange:media status:SJDefinitionSwitchStatusFinished];
                        }];
                    }
                });
            }
                break;
            case SJAssetStatusFailed: {
                [self _definitionSwitchingStatusDidChange:media status:SJDefinitionSwitchStatusFailed];
            }
                break;
        }
    }];
}

- (void)_definitionSwitchingStatusDidChange:(id<SJMediaModelProtocol>)media status:(SJDefinitionSwitchStatus)status {
    if ( status == SJDefinitionSwitchStatusFinished || status == SJDefinitionSwitchStatusFailed ) {
        _definitionLoader = nil;
    }
    
    if ( [self.delegate respondsToSelector:@selector(playbackController:switchingDefinitionStatusDidChange:media:)] ) {
        [self.delegate playbackController:self switchingDefinitionStatusDidChange:status media:media];
    }
    
#ifdef DEBUG
    char *str = nil;
    switch ( status ) {
        case SJDefinitionSwitchStatusUnknown: break;
        case SJDefinitionSwitchStatusSwitching:
            str = "Switching";
            break;
        case SJDefinitionSwitchStatusFinished:
            str = "Finished";
            break;
        case SJDefinitionSwitchStatusFailed:
            str = "Failed";
            break;
    }
    printf("\nSJAVMediaPlaybackController<%p>.switchStatus = %s\n", self, str);
#endif
}

- (UIImage *_Nullable)screenshot {
    return [_player.currentItem.asset sj_screenshotWithTime:CMTimeMakeWithSeconds(self.currentTime, NSEC_PER_SEC)];
}

#pragma mark -
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
    
    [self sj_observeWithNotification:SJAVMediaPlayerAssetStatusDidChangeNotification target:nil usingBlock:^(SJAVMediaPlaybackController *self, NSNotification * _Nonnull note) {
        if ( self.player == note.object ) {
            if ( [self.delegate respondsToSelector:@selector(playbackController:assetStatusDidChange:)] ) {
                [self.delegate playbackController:self assetStatusDidChange:self.assetStatus];
            }
        }
    }];
    
    [self sj_observeWithNotification:SJAVMediaPlayerTimeControlStatusDidChangeNotification target:nil usingBlock:^(SJAVMediaPlaybackController *self, NSNotification * _Nonnull note) {
        if ( self.player == note.object ) {
            if ( [self.delegate respondsToSelector:@selector(playbackController:timeControlStatusDidChange:)] ) {
                [self.delegate playbackController:self timeControlStatusDidChange:self.timeControlStatus];
            }
        }
    }];
    
    [self sj_observeWithNotification:SJAVMediaPlayerDurationDidChangeNotification target:nil usingBlock:^(SJAVMediaPlaybackController *self, NSNotification * _Nonnull note) {
        if ( self.player == note.object ) {
            if ( [self.delegate respondsToSelector:@selector(playbackController:durationDidChange:)] ) {
                [self.delegate playbackController:self durationDidChange:self.duration];
            }
        }
    }];

    [self sj_observeWithNotification:SJAVMediaPlayerDidPlayToEndTimeNotification target:nil usingBlock:^(SJAVMediaPlaybackController *self, NSNotification * _Nonnull note) {
        if ( self.player == note.object ) {
            if ( [self.delegate respondsToSelector:@selector(mediaDidPlayToEndForPlaybackController:)] ) {
                [self.delegate mediaDidPlayToEndForPlaybackController:self];
            }
        }
    }];

    [self sj_observeWithNotification:SJAVMediaPlayerPresentationSizeDidChangeNotification target:nil usingBlock:^(SJAVMediaPlaybackController *self, NSNotification * _Nonnull note) {
        if ( self.player == note.object ) {
            if ( [self.delegate respondsToSelector:@selector(playbackController:presentationSizeDidChange:)] ) {
                [self.delegate playbackController:self presentationSizeDidChange:self.presentationSize];
            }
        }
    }];
    
    [self sj_observeWithNotification:SJAVMediaPlayerPlaybackTypeDidChangeNotification target:nil usingBlock:^(SJAVMediaPlaybackController *self, NSNotification * _Nonnull note) {
        if ( self.player == note.object ) {
            if ( [self.delegate respondsToSelector:@selector(playbackController:playbackTypeDidChange:)] ) {
                [self.delegate playbackController:self playbackTypeDidChange:self.playbackType];
            }
        }
    }];
    
    [self sj_observeWithNotification:SJAVMediaPlayerPlayableDurationDidChangeNotification target:nil usingBlock:^(SJAVMediaPlaybackController *self, NSNotification * _Nonnull note) {
        if ( self.player == note.object ) {
            if ( [self.delegate respondsToSelector:@selector(playbackController:playableDurationDidChange:)] ) {
                [self.delegate playbackController:self playableDurationDidChange:self.playableDuration];
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

#pragma mark -

- (void)_resetMainPresenterIfNeeded {
    if ( self.registrar.state == SJVideoPlayerAppState_Background )
        return;
    
    AVPlayer *player = self.player;
    if ( self.mainPresenter.player != self.player ) {
        SJAVMediaSubPresenter *presenter = [[SJAVMediaSubPresenter alloc] initWithAVPlayer:player];
        [self.mainPresenter takeOverSubPresenter:presenter];
    }
}

- (void)_applicationEnterBackgrond {
    if ( self.pauseWhenAppDidEnterBackground ) {
        [self pause];
    }
    else {
        [self.mainPresenter removeAllPresenters];
    }
}

#pragma mark -

- (void)_addPeriodicTimeObserver {
    __weak typeof(self) _self = self;
    _periodicTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(_periodicTimeInterval, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(playbackController:currentTimeDidChange:)] ) {
            [self.delegate playbackController:self currentTimeDidChange:CMTimeGetSeconds(self.player.currentTime)];
        }
    }];
}
- (void)_removePeriodicTimeObserver {
    if ( _periodicTimeObserver != nil ) {
        [_player removeTimeObserver:_periodicTimeObserver];
        _periodicTimeObserver = nil;
    }
}
@end


@implementation SJAVMediaPlaybackController (Screenshot)

- (void)screenshotWithTime:(NSTimeInterval)time size:(CGSize)size completion:(nonnull void (^)(id<SJVideoPlayerPlaybackController> _Nonnull, UIImage * _Nullable, NSError * _Nullable))block {
    __weak typeof(self) _self = self;
    [_player.currentItem.asset sj_screenshotWithTime:time size:size completionHandler:^(AVAsset * _Nonnull a, UIImage * _Nullable image, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self, image, error);
    }];
}

@end

@implementation SJAVMediaPlaybackController (Export)

- (void)exportWithBeginTime:(NSTimeInterval)beginTime duration:(NSTimeInterval)duration presetName:(nullable NSString *)presetName progress:(nonnull void (^)(id<SJVideoPlayerPlaybackController> _Nonnull, float))progressBlock completion:(nonnull void (^)(id<SJVideoPlayerPlaybackController> _Nonnull, NSURL * _Nullable, UIImage * _Nullable))completionBlock failure:(nonnull void (^)(id<SJVideoPlayerPlaybackController> _Nonnull, NSError * _Nullable))failureBlock {
    
    NSURL *exportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"Export.mp4"];
    [[NSFileManager defaultManager] removeItemAtURL:exportURL error:nil];
    __weak typeof(self) _self = self;
    [_player.currentItem.asset sj_exportWithStartTime:beginTime duration:duration toFile:exportURL presetName:presetName progress:^(AVAsset * _Nonnull a, float progress) {
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
    [_player.currentItem.asset sj_cancelExportOperation];
}

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime duration:(NSTimeInterval)duration maximumSize:(CGSize)maximumSize interval:(float)interval gifSavePath:(nonnull NSURL *)gifSavePath progress:(nonnull void (^)(id<SJVideoPlayerPlaybackController> _Nonnull, float))progressBlock completion:(nonnull void (^)(id<SJVideoPlayerPlaybackController> _Nonnull, UIImage * _Nonnull, UIImage * _Nonnull))completion failure:(nonnull void (^)(id<SJVideoPlayerPlaybackController> _Nonnull, NSError * _Nonnull))failure {
    __weak typeof(self) _self = self;
    [_player.currentItem.asset sj_generateGIFWithBeginTime:beginTime duration:duration imageMaxSize:maximumSize interval:interval toFile:gifSavePath progress:^(AVAsset * _Nonnull a, float progress) {
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
    [_player.currentItem.asset sj_cancelGenerateGIFOperation];
}
@end
NS_ASSUME_NONNULL_END
