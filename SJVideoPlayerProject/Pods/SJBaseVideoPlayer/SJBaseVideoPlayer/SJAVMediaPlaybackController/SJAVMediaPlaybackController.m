//
//  SJAVMediaPlaybackController.m
//  Project
//
//  Created by BlueDancer on 2018/8/10.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJAVMediaPlaybackController.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/message.h>
#import "SJAVMediaPlayAsset+SJAVMediaPlaybackControllerAdd.h"
#import "SJVideoPlayerRegistrar.h"
#import "SJAVMediaPlayAsset.h"
#import "NSTimer+SJAssetAdd.h"
#import "SJAVMediaPlayAssetSwitcher.h"

NS_ASSUME_NONNULL_BEGIN
inline static bool isFloatZero(float value) {
    return fabsf(value) <= 0.00001f;
}

@interface SJAVMediaPlaybackController()<SJAVMediaPlayAssetPropertiesObserverDelegate>
@property (nonatomic, strong, readonly) SJVideoPlayerRegistrar *registrar;

@property (nonatomic, strong, readonly) SJAVMediaPresentView *presentView;
@property (nonatomic, strong, readonly) id<SJAVPlayerLayerPresenterObserver> mainPresenterObserver;
@property (nonatomic, strong, nullable) SJAVMediaPlayAssetSwitcher *switcher;
@property (nonatomic, strong, nullable) SJAVMediaPlayAssetPropertiesObserver *playAssetObserver;
@property (nonatomic, strong, nullable) SJAVMediaPlayAsset *playAsset;
@property (nonatomic) BOOL isPreparing;
@property (nonatomic) BOOL isPlaying;
@end

@implementation SJAVMediaPlaybackController
@synthesize delegate = _delegate;
@synthesize media = _media;
@synthesize playerView = _playerView;
@synthesize error = _error;
@synthesize videoGravity = _videoGravity;
@synthesize currentTime = _currentTime;
@synthesize duration = _duration;
@synthesize bufferLoadedTime = _bufferLoadedTime;
@synthesize bufferStatus = _bufferStatus;
@synthesize rate = _rate;
@synthesize mute = _mute;
@synthesize presentationSize = _presentationSize;
@synthesize prepareStatus = _prepareStatus;
@synthesize pauseWhenAppDidEnterBackground = _pauseWhenAppDidEnterBackground;
@synthesize registrar = _registrar;
@synthesize volume = _volume;

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    [_playerView removeFromSuperview];
    [self _cancelOperations];
}

- (void)_cancelOperations {
    [self cancelPendingSeeks];
    [self cancelExportOperation];
    [self cancelGenerateGIFOperation];
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _rate = 1;
    _volume = 1;
    _presentView = [SJAVMediaPresentView new];
    _mainPresenterObserver = [_presentView.mainPresenter getObserver];
    __weak typeof(self) _self = self;
    _mainPresenterObserver.isReadyForDisplayExeBlock = ^(id<SJAVPlayerLayerPresenter>  _Nonnull presenter) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.delegate respondsToSelector:@selector(playbackControllerIsReadyForDisplay:)] ) {
            [self.delegate playbackControllerIsReadyForDisplay:self];
        }
    #ifdef SJ_MAC
        printf("\n_presentView.mainPresenter.isReadyForDisplay\n");
    #endif
    };
    [self registrar];
    return self;
}

- (UIView *)playerView {
    return _presentView;
}

- (BOOL)isReadyForDisplay {
    return _presentView.mainPresenter.isReadyForDisplay;
}

- (void)setMedia:(nullable id<SJMediaModelProtocol>)media {
    [_playAsset.player pause];
    [_presentView reset];
    [self _cancelOperations];
    _playAssetObserver = nil;
    _playAsset = nil;
    _isPreparing = NO;
    _media = media;
    _error = nil;
    _currentTime = 0;
    _duration = 0;
    _bufferLoadedTime = 0;
    _bufferStatus = 0;
    _presentationSize = CGSizeZero;
    _prepareStatus = 0;
    _switcher = nil;
    _isPlaying = NO;
}

- (void)setVolume:(float)volume {
    _volume = volume;
    if ( !_mute ) _playAsset.player.volume = volume;
}
- (float)volume {
    return _volume;
}

- (void)setMute:(BOOL)mute {
    if ( mute == _mute ) return;
    _mute = mute;
    _playAsset.player.muted = mute;
}

- (void)setRate:(float)rate {
    _rate = rate;
    _playAsset.player.rate = rate;
}

- (void)setVideoGravity:(SJVideoGravity)videoGravity {
    _presentView.videoGravity = videoGravity;
}
- (SJVideoGravity)videoGravity {
    return _presentView.videoGravity;
}

- (void)prepareToPlay {
    if ( !_media ) return;
    if ( _isPreparing ) return; _isPreparing = YES;
    
    _playAsset = [self _getPlayAssetForMedia:_media];
    _playAssetObserver = [[SJAVMediaPlayAssetPropertiesObserver alloc] initWithPlayerAsset:_playAsset];
    _playAssetObserver.delegate = self;
    
    if ( _media.otherMedia ) {
        [self _updateDurationIfNeeded];
        [self _updateCurrentTimeIfNeeded];
        [self _updatePresentationSizeIfNeeded];
        [self _updatePrepareStatusIfNeeded];
        [self _updateBufferStatusIfNeeded];
        [self _updateBufferLoadedTimeIfNeeded];
    }
}

static const char *key = "kSJAVMediaPlayAsset";
- (SJAVMediaPlayAsset *)_getPlayAssetForMedia:(id<SJMediaModelProtocol>)media {
    id<SJMediaModelProtocol> other = media.otherMedia;
    while ( other.otherMedia ) other = other.otherMedia;
    SJAVMediaPlayAsset *playAsset = objc_getAssociatedObject(other?:media, key);
    if ( !playAsset ) {
        AVAsset *avAsset = nil;
        if ( [(id)media respondsToSelector:@selector(avAsset)] ) {
            avAsset = [(id<SJAVMediaModelProtocol>)media avAsset];
        }
        /// create by AVAsset
        if ( avAsset ) playAsset = [[SJAVMediaPlayAsset alloc] initWithAVAsset:avAsset specifyStartTime:media.specifyStartTime];
        /// create by URL
        else playAsset = [[SJAVMediaPlayAsset alloc] initWithURL:media.mediaURL specifyStartTime:media.specifyStartTime];
        [self _refreshForMedia:media newAsset:playAsset];
    }
    return playAsset;
}

- (void)_refreshForMedia:(id<SJMediaModelProtocol>)media newAsset:(SJAVMediaPlayAsset *)newAsset {
    id<SJMediaModelProtocol> other = media.otherMedia;
    while ( other.otherMedia ) other = other.otherMedia;
    objc_setAssociatedObject(other?:media, key, newAsset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)switchVideoDefinitionByURL:(NSURL *)URL {
    if ( !_playAsset ) return;
    [self.delegate playbackController:self
                switchVideoDefinitionByURL:URL
                      statusDidChange:SJMediaPlaybackSwitchDefinitionStatusSwitching];
    
    __weak typeof(self) _self = self;
    AVPlayerItem *playerItem = _playAsset.playerItem;
    _switcher = [[SJAVMediaPlayAssetSwitcher alloc] initWithURL:URL presenter:self.presentView.subPresenter currentTime:^CMTime{
        return playerItem.currentTime;
    } completionHandler:^(SJAVMediaPlayAssetSwitcher * _Nonnull switcher, BOOL result, SJAVMediaPlayAsset * _Nullable newAsset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( !result ) {
            [self.delegate playbackController:self switchVideoDefinitionByURL:URL statusDidChange:SJMediaPlaybackSwitchDefinitionStatusFailed];
        #ifdef SJ_MAC
            printf("\n切换清晰度失败!\n");
        #endif
        }
        else {
            self.switcher = nil;
            [self _refreshForMedia:self.media newAsset:newAsset];
            self.media.mediaURL = URL;
            self.playAsset = newAsset;
            self.playAssetObserver = [[SJAVMediaPlayAssetPropertiesObserver alloc] initWithPlayerAsset:newAsset];
            self.playAssetObserver.delegate = self;
            [self play];
            [self.presentView exchangePresenter];
            [self.presentView resetSubPresenter];
        #ifdef SJ_MAC
            printf("\n切换清晰度完成\n");
        #endif
        }
    }];
}

#pragma mark -
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer durationDidChange:(NSTimeInterval)duration {
    [self _updateDurationIfNeeded];
}

- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer currentTimeDidChange:(NSTimeInterval)currentTime {
    [self _updateCurrentTimeIfNeeded];
}
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer bufferLoadedTimeDidChange:(NSTimeInterval)bufferLoadedTime {
    [self _updateBufferLoadedTimeIfNeeded];
    [self _updatePrepareStatusIfNeeded];
}
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus {
    [self _updateBufferStatusIfNeeded];
}
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer presentationSizeDidChange:(CGSize)presentationSize {
    [self _updatePresentationSizeIfNeeded];
}
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer playerItemStatusDidChange:(AVPlayerItemStatus)playerItemStatus {
    [self _updatePrepareStatusIfNeeded];
}
- (void)playDidToEndForObserver:(SJAVMediaPlayAssetPropertiesObserver *)observer {
    _isPlaying = NO;
    if ( [self.delegate respondsToSelector:@selector(mediaDidPlayToEndForPlaybackController:)] ) {
        [self.delegate mediaDidPlayToEndForPlaybackController:self];
    }
}

- (void)_updateDurationIfNeeded {
    NSTimeInterval duration = _playAssetObserver.duration;
    if ( duration != _duration ) {
        _duration = duration;
        if ( [self.delegate respondsToSelector:@selector(playbackController:durationDidChange:)] ) {
            [self.delegate playbackController:self durationDidChange:duration];
        }
    }
}

- (void)_updateCurrentTimeIfNeeded {
    NSTimeInterval currentTime = _playAssetObserver.currentTime;
    if ( currentTime != _currentTime ) {
        _currentTime = currentTime;
        if ( [self.delegate respondsToSelector:@selector(playbackController:currentTimeDidChange:)] ) {
            [self.delegate playbackController:self currentTimeDidChange:currentTime];
        }
    }
}

- (void)_updateBufferLoadedTimeIfNeeded {
    NSTimeInterval bufferLoadedTime = _playAssetObserver.bufferLoadedTime;
    if ( bufferLoadedTime != _bufferLoadedTime ) {
        _bufferLoadedTime = bufferLoadedTime;
        if ( [self.delegate respondsToSelector:@selector(playbackController:bufferLoadedTimeDidChange:)] ) {
            [self.delegate playbackController:self bufferLoadedTimeDidChange:bufferLoadedTime];
        }
    }
}

- (void)_updateBufferStatusIfNeeded {
    SJPlayerBufferStatus bufferStatus = _playAssetObserver.bufferStatus;
    _bufferStatus = bufferStatus;
    if ( [self.delegate respondsToSelector:@selector(playbackController:bufferStatusDidChange:)] ) {
        [self.delegate playbackController:self bufferStatusDidChange:bufferStatus];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 缓存就绪&播放中, rate如果==0, 尝试播放
        if ( bufferStatus == SJPlayerBufferStatusPlayable &&
             self->_isPlaying &&
             isFloatZero(self->_playAsset.player.rate) ) {
            [self.playAsset.player play];
        }
    });
}

- (void)_updatePresentationSizeIfNeeded {
    CGSize presentationSize = _playAssetObserver.presentationSize;
    if ( !CGSizeEqualToSize(presentationSize, _presentationSize) ) {
        _presentationSize = presentationSize;
        if ( [self.delegate respondsToSelector:@selector(playbackController:presentationSizeDidChange:)] ) {
            [self.delegate playbackController:self presentationSizeDidChange:presentationSize];
        }
    }
}

- (void)_updatePrepareStatusIfNeeded {
    AVPlayerItemStatus playerItemStatus = _playAssetObserver.playerItemStatus;
    
    if ( _prepareStatus != (SJMediaPlaybackPrepareStatus)playerItemStatus ) {
        _isPreparing = NO;
        _prepareStatus = (SJMediaPlaybackPrepareStatus)playerItemStatus;
        _error = _playAsset.playerItem.error;
        
        __weak typeof(self) _self = self;
        void(^_inner_completionHandler)(void) = ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( self.presentView.mainPresenter.player != self.playAsset.player ) {
                self.presentView.mainPresenter.player = self.playAsset.player;
            }
            
            if ( [self.delegate respondsToSelector:@selector(playbackController:prepareToPlayStatusDidChange:)] ) {
                [self.delegate playbackController:self prepareToPlayStatusDidChange:(NSInteger)playerItemStatus];
            }
        };
        
        /// seek to specify start time
        if ( _prepareStatus == SJMediaPlaybackPrepareStatusReadyToPlay &&
             0 != self.media.specifyStartTime ) {
            [self.playAsset.playerItem seekToTime:CMTimeMake(self.media.specifyStartTime * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                _inner_completionHandler();
            }];
        }
        else {
            _inner_completionHandler();
        }
    }
}
#pragma mark -
- (void)play {
    if ( _prepareStatus != SJMediaPlaybackPrepareStatusReadyToPlay ) return;
    
    [_playAsset.player play];
    _playAsset.player.rate = self.rate;
    _playAsset.player.muted = self.mute;
    if ( !_mute ) _playAsset.player.volume = _volume;
    _isPlaying = YES;
    
#ifdef DEBUG
    printf("\n");
    printf("SJAVMediaPlaybackController<%p>.rate == %lf\n", self, self.rate);
    printf("SJAVMediaPlaybackController<%p>.mute == %s\n",  self, self.mute?"YES":"NO");
    printf("SJAVMediaPlaybackController<%p>.playerVolume == %lf\n",  self, _volume);
#endif
}
- (void)pause {
    if ( _prepareStatus != SJMediaPlaybackPrepareStatusReadyToPlay ) return;
    [self.playAsset.player pause];
    _isPlaying = NO;
}
- (void)stop {
    [_playAsset.player pause];
    
    if ( !_media.otherMedia ) {
        [_presentView reset];
        [_playAsset.player replaceCurrentItemWithPlayerItem:nil];
    }

    [self _cancelOperations];
    _playAssetObserver = nil;
    _playAsset = nil;
    _prepareStatus = SJMediaPlaybackPrepareStatusUnknown;
    _bufferStatus = SJPlayerBufferStatusUnknown;
    _isPreparing = NO;
    _isPlaying = NO;
}
- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    if ( isnan(secs) ) { return; }

    if ( _prepareStatus != SJMediaPlaybackPrepareStatusReadyToPlay || _error ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }

    if ( secs > _duration || secs < 0 ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }

    [_playAsset.playerItem seekToTime:CMTimeMakeWithSeconds(secs, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        if ( completionHandler ) completionHandler(finished);
    }];
}

- (void)cancelPendingSeeks {
    [_playAsset.playerItem cancelPendingSeeks];
}

#pragma mark -
- (SJVideoPlayerRegistrar *)registrar {
    if ( _registrar ) return _registrar;
    _registrar = [SJVideoPlayerRegistrar new];
    __weak typeof(self) _self = self;
    _registrar.willEnterForeground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.prepareStatus == SJMediaPlaybackPrepareStatusReadyToPlay ) {
            self.presentView.mainPresenter.player = self.playAsset.player;
        }
    };
    
    _registrar.didEnterBackground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.prepareStatus != SJMediaPlaybackPrepareStatusReadyToPlay ) return;
        
        if ( self.pauseWhenAppDidEnterBackground ) {
            [self pause];
            if ( [self.delegate respondsToSelector:@selector(pausedForAppDidEnterBackgroundOfPlaybackController:)] ) {
                [self.delegate pausedForAppDidEnterBackgroundOfPlaybackController:self];
            }
        }
        else {
            [self.presentView reset];
        }
    };
    return _registrar;
}
- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize completion:(nonnull void (^)(__kindof id<SJMediaPlaybackController> _Nonnull, NSArray<id<SJVideoPlayerPreviewInfo>> * _Nullable, NSError * _Nullable))block {
    __weak typeof(self) _self = self;
    [self.playAsset generatedPreviewImagesWithMaxItemSize:itemSize completion:^(SJAVMediaPlayAsset * _Nonnull a, NSArray<id<SJVideoPlayerPreviewInfo>> * _Nullable images, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( block ) block(self, images, error);
    }];
}
- (nullable UIImage *)screenshot {
    return [_playAsset screenshot];
}
- (void)screenshotWithTime:(NSTimeInterval)time size:(CGSize)size completion:(nonnull void (^)(id<SJMediaPlaybackController> _Nonnull, UIImage * _Nullable, NSError * _Nullable))block {
    __weak typeof(self) _self = self;
    [self.playAsset screenshotWithTime:time size:size completion:^(SJAVMediaPlayAsset * _Nonnull a, UIImage * _Nullable image, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( block ) block(self, image, error);
    }];
}

- (void)cancelExportOperation {
    [self.playAsset cancelExportOperation];
}

- (void)cancelGenerateGIFOperation {
    [self.playAsset cancelGenerateGIFOperation];
}

- (void)exportWithBeginTime:(NSTimeInterval)beginTime endTime:(NSTimeInterval)endTime presetName:(nullable NSString *)presetName progress:(nonnull void (^)(id<SJMediaPlaybackController> _Nonnull, float))progressBlock completion:(nonnull void (^)(id<SJMediaPlaybackController> _Nonnull, NSURL * _Nullable, UIImage * _Nullable))completionBlock failure:(nonnull void (^)(id<SJMediaPlaybackController> _Nonnull, NSError * _Nullable))failureBlock {
    __weak typeof(self) _self = self;
    [self.playAsset exportWithBeginTime:beginTime endTime:endTime presetName:presetName progress:^(SJAVMediaPlayAsset * _Nonnull a, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( progressBlock ) progressBlock(self, progress);
    } completion:^(SJAVMediaPlayAsset * _Nonnull a, AVAsset * _Nullable sandboxAsset, NSURL * _Nullable fileURL, UIImage * _Nullable thumbImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( completionBlock ) completionBlock(self, fileURL, thumbImage);
    } failure:^(SJAVMediaPlayAsset * _Nonnull a, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( failureBlock ) failureBlock(self, error);
    }];
}

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime duration:(NSTimeInterval)duration maximumSize:(CGSize)maximumSize interval:(float)interval gifSavePath:(nonnull NSURL *)gifSavePath progress:(nonnull void (^)(id<SJMediaPlaybackController> _Nonnull, float))progressBlock completion:(nonnull void (^)(id<SJMediaPlaybackController> _Nonnull, UIImage * _Nonnull, UIImage * _Nonnull))completion failure:(nonnull void (^)(id<SJMediaPlaybackController> _Nonnull, NSError * _Nonnull))failure {
    __weak typeof(self) _self = self;
    [self.playAsset generateGIFWithBeginTime:beginTime duration:duration maximumSize:maximumSize interval:interval gifSavePath:gifSavePath progress:^(SJAVMediaPlayAsset * _Nonnull a, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( progressBlock ) progressBlock(self, progress);
    } completion:^(SJAVMediaPlayAsset * _Nonnull a, UIImage * _Nonnull imageGIF, UIImage * _Nonnull thumbnailImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( completion ) completion(self, imageGIF, thumbnailImage);
    } failure:^(SJAVMediaPlayAsset * _Nonnull a, NSError * _Nonnull error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( failure ) failure(self, error);
    }];
}
@end
NS_ASSUME_NONNULL_END
