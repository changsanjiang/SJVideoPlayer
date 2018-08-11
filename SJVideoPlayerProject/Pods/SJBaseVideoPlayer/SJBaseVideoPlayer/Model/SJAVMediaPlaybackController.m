//
//  SJAVMediaPlaybackController.m
//  Project
//
//  Created by BlueDancer on 2018/8/10.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJAVMediaPlaybackController.h"
#import <AVFoundation/AVFoundation.h>
#import "SJPlayAsset.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVPlayerLayerPresentView: UIView
@property (nonatomic, strong, nullable) AVPlayer *player;
/// default is AVLayerVideoGravityResizeAspect
@property (nonatomic, strong) AVLayerVideoGravity videoGravity;
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
@property (nonatomic, strong, nullable) SJPlayAsset *playAsset;
@property (nonatomic, strong, nullable) SJPlayAssetPropertiesObserver *playAssetObserver;
@property (nonatomic, strong, readonly) AVAssetImageGenerator *screenshotGenerator;
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

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _rate = 1;
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
    [self play];
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
    if ( [self.delegate respondsToSelector:@selector(playbackController:prepareStatusDidChange:)] ) {
        [self.delegate playbackController:self prepareStatusDidChange:_prepareStatus];
    }
    
    if ( playerItemStatus == AVPlayerItemStatusReadyToPlay ) ((SJAVPlayerLayerPresentView *)self.playerView).player = self.playAsset.player;
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
    printf("SJAVMediaPlaybackController<%p>.mute == %d\n",  self, self.mute);
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
@end
NS_ASSUME_NONNULL_END
