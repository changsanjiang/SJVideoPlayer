//
//  SJAVMediaPlaybackController.m
//  Project
//
//  Created by BlueDancer on 2018/8/10.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJAVMediaPlaybackController.h"
#import <AVFoundation/AVFoundation.h>
#import "SJVideoPlayerRegistrar.h"
#import "SJPlayAsset.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVPlayerLayerPresentView: UIView
/// default is AVLayerVideoGravityResizeAspect
@property (nonatomic, strong) AVLayerVideoGravity videoGravity;
@property (nonatomic, strong, nullable) AVPlayer *player;
@end

@implementation SJAVPlayerLayerPresentView
#ifdef SJ_MAC
- (void)dealloc {
    NSLog(@"%d - %s", (int)__LINE__, __func__);
}
#endif

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)avLayer {
    return (AVPlayerLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    return self;
}

- (void)setPlayer:(nullable AVPlayer *)player {
    if ( player == self.avLayer.player ) return;
    self.avLayer.player = player;
    
    CATransition *anima = [CATransition animation];
    anima.type = kCATransitionFade;
    anima.duration = 1.0f;
    [self.layer addAnimation:anima forKey:@"fadeAnimation"];
}

- (nullable AVPlayer *)player {
    return self.avLayer.player;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    if ( videoGravity == self.videoGravity ) return;
    [self avLayer].videoGravity = videoGravity;
}

- (AVLayerVideoGravity)videoGravity {
    return [self avLayer].videoGravity;
}

@end


@interface SJAVMediaPlaybackController()<SJPlayAssetPropertiesObserverDelegate>
@property (nonatomic, strong, nullable) SJPlayAssetPropertiesObserver *playAssetObserver;
@property (nonatomic, strong, readonly) AVAssetImageGenerator *screenshotGenerator;
@property (nonatomic, strong, readonly) SJVideoPlayerRegistrar *registrar;
@property (nonatomic, strong, nullable) SJPlayAsset *playAsset;
@property (nonatomic) BOOL isPreparing;
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
@synthesize screenshotGenerator = _screenshotGenerator;
@synthesize prepareStatus = _prepareStatus;
/**
 关于后台播放视频, 引用自: https://juejin.im/post/5a38e1a0f265da4327185a26
 
 当您想在后台播放视频时:
 1. 需要设置 videoPlayer.pauseWhenAppDidEnterBackground = NO; 该值默认为YES, 即App进入后台默认暂停.
 2. 前往 `TARGETS` -> `Capability` -> enable `Background Modes` -> select this mode `Audio, AirPlay, and Picture in Picture`
 */
@synthesize pauseWhenAppDidEnterBackground = _pauseWhenAppDidEnterBackground;
@synthesize registrar = _registrar;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _rate = 1;
    [self registrar];
    return self;
}

- (SJAVPlayerLayerPresentView *)playerView {
    if ( _playerView ) return _playerView;
    return _playerView = [SJAVPlayerLayerPresentView new];
}

- (void)setMedia:(nullable id<SJMediaModel>)media {
    [_playAsset.player pause];
    _playAssetObserver = nil;
    _error = nil;
    _media = media;
}

- (void)setRate:(float)rate {
    _rate = rate;
    _playAsset.player.rate = self.rate;
}

- (void)prepareToPlay {
    if ( !_media ) return;
    if ( _isPreparing ) return; _isPreparing = YES;
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.media ) {
            self.playAsset = [[SJPlayAsset alloc] initWithURL:self.media.mediaURL specifyStartTime:self.media.specifyStartTime];
            self.playAssetObserver = [[SJPlayAssetPropertiesObserver alloc] initWithPlayerAsset:self.playAsset];
            self.playAssetObserver.delegate = self;
            [self.playAsset load];
        }
    });
}

#pragma mark -
- (void)observer:(SJPlayAssetPropertiesObserver *)observer durationDidChange:(NSTimeInterval)duration {
    _duration = duration;
    if ( [self.delegate respondsToSelector:@selector(playbackController:durationDidChange:)] ) {
        [self.delegate playbackController:self durationDidChange:duration];
    }
}
- (void)observer:(SJPlayAssetPropertiesObserver *)observer currentTimeDidChange:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    if ( [self.delegate respondsToSelector:@selector(playbackController:currentTimeDidChange:)] ) {
        [self.delegate playbackController:self currentTimeDidChange:currentTime];
    }
}
- (void)observer:(SJPlayAssetPropertiesObserver *)observer bufferLoadedTimeDidChange:(NSTimeInterval)bufferLoadedTime {
    _bufferLoadedTime = bufferLoadedTime;
    if ( [self.delegate respondsToSelector:@selector(playbackController:bufferLoadedTimeDidChange:)] ) {
        [self.delegate playbackController:self bufferLoadedTimeDidChange:bufferLoadedTime];
    }
}
- (void)observer:(SJPlayAssetPropertiesObserver *)observer bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus {
    _bufferStatus = bufferStatus;
    if ( [self.delegate respondsToSelector:@selector(playbackController:bufferStatusDidChange:)] ) {
        [self.delegate playbackController:self bufferStatusDidChange:bufferStatus];
    }
}
- (void)observer:(SJPlayAssetPropertiesObserver *)observer presentationSizeDidChange:(CGSize)presentationSize {
    _presentationSize = presentationSize;
    if ( [self.delegate respondsToSelector:@selector(playbackController:presentationSizeDidChange:)] ) {
        [self.delegate playbackController:self presentationSizeDidChange:presentationSize];
    }
}
- (void)observer:(SJPlayAssetPropertiesObserver *)observer playerItemStatusDidChange:(AVPlayerItemStatus)playerItemStatus {
    _isPreparing = NO;
    _prepareStatus = (SJMediaPlaybackPrepareStatus)playerItemStatus;
    if ( playerItemStatus == AVPlayerItemStatusReadyToPlay ) {
        if ( self.registrar.state != SJVideoPlayerAppState_Background ) {
            ((SJAVPlayerLayerPresentView *)self.playerView).player = self.playAsset.player;
        }
        
        /// seek to specify start time
        if ( 0 != self.media.specifyStartTime ) {
            __weak typeof(self) _self = self;
            [self seekToTime:self.media.specifyStartTime completionHandler:^(BOOL finished) {
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                if ( [self.delegate respondsToSelector:@selector(playbackController:prepareToPlayStatusDidChange:)] ) {
                    [self.delegate playbackController:self prepareToPlayStatusDidChange:self.prepareStatus];
                }
            }];
            return;
        }
    }
    
    if ( [self.delegate respondsToSelector:@selector(playbackController:prepareToPlayStatusDidChange:)] ) {
        [self.delegate playbackController:self prepareToPlayStatusDidChange:_prepareStatus];
    }
}
- (void)assetLoadIsCompletedForObserver:(SJPlayAssetPropertiesObserver *)observer {
#warning next ...
    [self play];
}
- (void)playDidToEndForObserver:(SJPlayAssetPropertiesObserver *)observer {
    if ( [self.delegate respondsToSelector:@selector(mediaDidPlayToEndForPlaybackController:)] ) {
        [self.delegate mediaDidPlayToEndForPlaybackController:self];
    }
}

#pragma mark -
- (void)play {
    if ( !_media ) return;
    if ( _isPreparing ) return;
    
    [_playAsset.player play];
    _playAsset.player.rate = self.rate;
    _playAsset.player.muted = self.mute;
    
#ifdef DEBUG
    printf("SJAVMediaPlaybackController<%p>.rate == %lf\n", self, self.rate);
    printf("SJAVMediaPlaybackController<%p>.mute == %s\n",  self, self.mute?"YES":"NO");
#endif
}
- (void)replay {
    if ( !_media ) return;
    if ( _isPreparing ) return;
    
    if ( _prepareStatus == SJMediaPlaybackPrepareStatusFailed ) {
        [self prepareToPlay];
        return;
    }
    
    [self seekToTime:0 completionHandler:nil];
}
- (void)pause {
    if ( !_media ) return;
    if ( _isPreparing ) return;
    
    [_playAsset.player pause];
}
- (void)stop {
    if ( !_playAsset.isOtherAsset ) {
        [((SJAVPlayerLayerPresentView *)self.playerView).player replaceCurrentItemWithPlayerItem:nil];
        ((SJAVPlayerLayerPresentView *)self.playerView).player = nil;
    }

    _playAssetObserver = nil;
    _playAsset = nil;
    _prepareStatus = SJMediaPlaybackPrepareStatusUnknown;
    _bufferStatus = SJPlayerBufferStatusUnknown;
    _isPreparing = NO;
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

    NSTimeInterval current = floor(self.playAssetObserver.currentTime);
    NSTimeInterval seek = floor(secs);

    if ( current == seek ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    if ( [self.delegate respondsToSelector:@selector(playbackController:willSeekToTime:)] ) {
        [self.delegate playbackController:self willSeekToTime:secs];
    }
    __weak typeof(self) _self = self;
    [_playAsset.playerItem seekToTime:CMTimeMakeWithSeconds(secs, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( completionHandler ) completionHandler(finished);
        if ( [self.delegate respondsToSelector:@selector(playbackController:didSeekToTime:finished:)] ) {
            [self.delegate playbackController:self didSeekToTime:secs finished:finished];
        }
    }];
}

- (void)cancelPendingSeeks {
    [_playAsset.playerItem cancelPendingSeeks];
}

- (nullable UIImage *)screenshot {
    if ( !_playAsset ) return nil;
    CMTime time = _playAsset.playerItem.currentTime;
    CGImageRef imgRef = [self.screenshotGenerator copyCGImageAtTime:time actualTime:&time error:nil];
    if ( !imgRef ) return nil;
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    return image;
}

- (AVAssetImageGenerator *)screenshotGenerator {
    if ( !_screenshotGenerator ) {
        _screenshotGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_playAsset.URLAsset];
        _screenshotGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        _screenshotGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        _screenshotGenerator.appliesPreferredTrackTransform = YES;
    }
    return _screenshotGenerator;
}

- (SJVideoPlayerRegistrar *)registrar {
    if ( _registrar ) return _registrar;
    _registrar = [SJVideoPlayerRegistrar new];
    __weak typeof(self) _self = self;
    _registrar.willEnterForeground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( !self.media ) return;
        if ( self.isPreparing ) return;
        if ( self.prepareStatus == SJMediaPlaybackPrepareStatusReadyToPlay ) ((SJAVPlayerLayerPresentView *)self.playerView).player = self.playAsset.player;
    };
    
    _registrar.didEnterBackground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( !self.media ) return;
        if ( self.isPreparing ) return;
        if ( self.pauseWhenAppDidEnterBackground ) {
            [self pause];
            if ( [self.delegate respondsToSelector:@selector(pausedForAppDidEnterBackgroundOfPlaybackController:)] ) {
                [self.delegate pausedForAppDidEnterBackgroundOfPlaybackController:self];
            }
        }
        else {
            ((SJAVPlayerLayerPresentView *)self.playerView).player = nil;
        }
    };
    return _registrar;
}
@end
NS_ASSUME_NONNULL_END
