//
//  SJAVMediaPlaybackController.m
//  Project
//
//  Created by 畅三江 on 2018/8/10.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "SJAVMediaPlaybackController.h"
#if __has_include(<SJUIKit/SJRunLoopTaskQueue.h>)
#import <SJUIKit/SJRunLoopTaskQueue.h>
#else
#import "SJRunLoopTaskQueue.h"
#endif
#import "SJAVMediaPlayer.h"
#import "SJAVMediaPlayerLoader.h" 
#import "SJVideoPlayerRegistrar.h"
#import "AVAsset+SJAVMediaExport.h"
#import "NSTimer+SJAssetAdd.h"
#import "SJAVMediaPresentController.h"
#import "SJAVMediaPlayerDefinitionLoader.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlaybackController()<SJAVMediaPresentControllerDelegate, SJAVMediaPlayerDefinitionLoaderDataSource>
@property (nonatomic, strong, nullable) SJAVMediaPlayerDefinitionLoader *definitionLoader;
@property (nonatomic, strong, readonly) SJVideoPlayerRegistrar *registrar;
@property (nonatomic, strong, nullable) SJAVMediaPlayer *player;
@property (nonatomic, strong, nullable) id periodicTimeObserver;
@end

@implementation SJAVMediaPlaybackController
@synthesize presentController = _presentController;
@synthesize pauseWhenAppDidEnterBackground = _pauseWhenAppDidEnterBackground;
@synthesize periodicTimeInterval = _periodicTimeInterval;
@synthesize minBufferedDuration = _minBufferedDuration;
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
    _minBufferedDuration = 8.0;
    _pauseWhenAppDidEnterBackground = YES;
    _presentController = SJAVMediaPresentController.alloc.init;
    _presentController.delegate = self;
    [self _initObservations];
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
- (void)setPeriodicTimeInterval:(NSTimeInterval)periodicTimeInterval {
    if ( periodicTimeInterval == _periodicTimeInterval )
        return;
    _periodicTimeInterval = periodicTimeInterval;
    [self _removePeriodicTimeObserver];
    [self _addPeriodicTimeObserver];
}
- (void)setMinBufferedDuration:(NSTimeInterval)minBufferedDuration {
    _minBufferedDuration = minBufferedDuration;
    self.player.sj_minBufferedDuration = minBufferedDuration;
}
- (NSError *_Nullable)error {
    return _player.sj_error;
}
- (UIView *)playerView {
    return _presentController.view;
}
- (SJPlaybackType)playbackType {
    return _player.sj_playbackInfo.playbackType;
}
- (void)setVideoGravity:(SJVideoGravity)videoGravity {
    _presentController.videoGravity = videoGravity;
}
- (SJVideoGravity)videoGravity {
    return _presentController.videoGravity;
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
    return _presentController.keyPresentView.isReadyForDisplay;
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
    player.sj_minBufferedDuration = self.minBufferedDuration;
    [self _addPeriodicTimeObserver];
}

- (void)prepareToPlay {
    if ( _media == nil ) return;
    
    __weak typeof(self) _self = self;
    id<SJMediaModelProtocol> media = _media;
    SJAVMediaPlayer *player = [SJAVMediaPlayerLoader loadPlayerForMedia:media];
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( media != self.media ) return ;
        self.player = player;
        SJAVMediaPresentView *view = [SJAVMediaPresentView.alloc initWithFrame:CGRectZero player:(self.registrar.state == SJVideoPlayerAppState_Background) ? nil : player];
        [self.presentController makeKeyPresentView:view];
        
        if ( player.sj_playbackInfo.isPlayed ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SJRunLoopTaskQueue.main.enqueue(^{
                    [player report];
                });
            });
        }
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self play];
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
    [self _stop];
    _media = nil;
}
- (void)_stop {
    [_presentController removeAllPresentView];
    if ( self.player.sj_timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
        [self.player pause];
    }
    self.player = nil;
    [_definitionLoader cancel];
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
    
    // clean
    if ( _definitionLoader != nil ) {
        [_definitionLoader cancel];
        _definitionLoader = nil;
    }
    
    // reset status
    [self _definitionSwitchingStatusDidChange:media status:SJDefinitionSwitchStatusUnknown];
    
    // begin
    [self _definitionSwitchingStatusDidChange:media status:SJDefinitionSwitchStatusSwitching];

    // prepare
    __weak typeof(self) _self = self;
    _definitionLoader = [SJAVMediaPlayerDefinitionLoader.alloc initWithMedia:media dataSource:self completionHandler:^(SJAVMediaPlayerDefinitionLoader * _Nonnull loader) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.definitionLoader = nil;
        SJAVMediaPlayer *_Nullable player = loader.player;
        if ( player == nil ) {
            [self _definitionSwitchingStatusDidChange:media status:SJDefinitionSwitchStatusFailed];
        }
        else {
            id<SJMediaModelProtocol> newMedia = media;
            self.media = newMedia;
            
            SJAVMediaPlayer *oldPlayer = self.player;
            SJAVMediaPlayer *newPlayer = player;
            self.player = newPlayer;
            [oldPlayer pause];
            [newPlayer play];
            [newPlayer report];
            
            SJAVMediaPresentView *oldPresentView = self.presentController.keyPresentView;
            [self.presentController makeKeyPresentView:loader.presentView];
            [self.presentController removePresentView:oldPresentView];
            [self _definitionSwitchingStatusDidChange:media status:SJDefinitionSwitchStatusFinished];
        }
    }];
}

- (void)_definitionSwitchingStatusDidChange:(id<SJMediaModelProtocol>)media status:(SJDefinitionSwitchStatus)status {
    if ( [self.delegate respondsToSelector:@selector(playbackController:switchingDefinitionStatusDidChange:media:)] ) {
        [self.delegate playbackController:self switchingDefinitionStatusDidChange:status media:media];
    }

#ifdef DEBUG
    char *str = nil;
    switch ( status ) {
        case SJDefinitionSwitchStatusUnknown:
            str = "Unknown";
            break;
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
    printf("SJAVMediaPlaybackController<%p>.switchStatus = %s\n", self, str);
#endif
}

- (UIView *)superview {
    return self.playerView;
}

- (UIImage *_Nullable)screenshot {
    return [_player.currentItem.asset sj_screenshotWithTime:CMTimeMakeWithSeconds(self.currentTime, NSEC_PER_SEC)];
}

#pragma mark -

- (void)presentController:(SJAVMediaPresentController *)controller presentViewReadyForDisplayDidChange:(SJAVMediaPresentView *)presentView {
    if ( presentView == self.presentController.keyPresentView ) {
        if ( [self.delegate respondsToSelector:@selector(playbackControllerIsReadyForDisplay:)] ) {
            [self.delegate playbackControllerIsReadyForDisplay:self];
#ifdef SJMAC
            printf("\nSJAVMediaPlaybackController<%p>.isReadyForDisplay = %d\n", self, self.isReadyForDisplay);
#endif
        }
    }
}

- (void)playerAssetStatusDidChange:(NSNotification *)note {
    if ( self.player == note.object ) {
        if ( [self.delegate respondsToSelector:@selector(playbackController:assetStatusDidChange:)] ) {
            [self.delegate playbackController:self assetStatusDidChange:self.assetStatus];
        }
    }
}

- (void)playerTimeControlStatusDidChange:(NSNotification *)note {
    if ( self.player == note.object ) {
        if ( [self.delegate respondsToSelector:@selector(playbackController:timeControlStatusDidChange:)] ) {
            [self.delegate playbackController:self timeControlStatusDidChange:self.timeControlStatus];
        }
    }
}

- (void)playerDurationDidChange:(NSNotification *)note {
    if ( self.player == note.object ) {
        if ( [self.delegate respondsToSelector:@selector(playbackController:durationDidChange:)] ) {
            [self.delegate playbackController:self durationDidChange:self.duration];
        }
    }
}

- (void)playerDidPlayToEndTime:(NSNotification *)note {
    if ( self.player == note.object ) {
        if ( [self.delegate respondsToSelector:@selector(mediaDidPlayToEndForPlaybackController:)] ) {
            [self.delegate mediaDidPlayToEndForPlaybackController:self];
        }
    }
}

- (void)playerPresentationSizeDidChange:(NSNotification *)note {
    if ( self.player == note.object ) {
        if ( [self.delegate respondsToSelector:@selector(playbackController:presentationSizeDidChange:)] ) {
            [self.delegate playbackController:self presentationSizeDidChange:self.presentationSize];
        }
    }
}

- (void)playerPlaybackTypeDidChange:(NSNotification *)note {
    if ( self.player == note.object ) {
        if ( [self.delegate respondsToSelector:@selector(playbackController:playbackTypeDidChange:)] ) {
            [self.delegate playbackController:self playbackTypeDidChange:self.playbackType];
        }
    }
}

- (void)playerPlayableDurationDidChange:(NSNotification *)note {
    if ( self.player == note.object ) {
        if ( [self.delegate respondsToSelector:@selector(playbackController:playableDurationDidChange:)] ) {
            [self.delegate playbackController:self playableDurationDidChange:self.playableDuration];
        }
    }
}

- (void)_initObservations {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerAssetStatusDidChange:) name:SJAVMediaPlayerAssetStatusDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerTimeControlStatusDidChange:) name:SJAVMediaPlayerTimeControlStatusDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerDurationDidChange:) name:SJAVMediaPlayerDurationDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerDidPlayToEndTime:) name:SJAVMediaPlayerDidPlayToEndTimeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerPresentationSizeDidChange:) name:SJAVMediaPlayerPresentationSizeDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerPlaybackTypeDidChange:) name:SJAVMediaPlayerPlaybackTypeDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerPlayableDurationDidChange:) name:SJAVMediaPlayerPlayableDurationDidChangeNotification object:nil];

    __weak typeof(self) _self = self;
    _registrar = [[SJVideoPlayerRegistrar alloc] init];
    _registrar.didBecomeActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.presentController.keyPresentView.player == nil )
            self.presentController.keyPresentView.player = self.player;
    };
    
    _registrar.didEnterBackground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.pauseWhenAppDidEnterBackground == NO ) {
            self.presentController.keyPresentView.player = nil;
        }
        else if ( self.timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
            [self pause];
        }
    };
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
