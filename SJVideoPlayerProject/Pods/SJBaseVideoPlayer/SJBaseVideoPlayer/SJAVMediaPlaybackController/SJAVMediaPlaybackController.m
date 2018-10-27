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
    anima.duration = 0.4f;
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


@interface SJAVMediaPlaybackController()<SJAVMediaPlayAssetPropertiesObserverDelegate>
@property (nonatomic, strong, nullable) SJAVMediaPlayAssetPropertiesObserver *playAssetObserver;
@property (nonatomic, strong, readonly) SJVideoPlayerRegistrar *registrar;
@property (nonatomic) BOOL isPreparing;
@property (nonatomic, strong, nullable) SJAVMediaPlayAsset *playAsset;
@property (nonatomic, strong, readonly) dispatch_queue_t serailQueue;
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
    static dispatch_queue_t queue;
    if ( !queue ) queue = dispatch_queue_create("com.SJAVMediaPlaybackController", DISPATCH_QUEUE_SERIAL);
    _serailQueue = queue;
    [self registrar];
    return self;
}

- (SJAVPlayerLayerPresentView *)playerView {
    if ( _playerView ) return _playerView;
    return _playerView = [SJAVPlayerLayerPresentView new];
}

- (void)setMedia:(nullable id<SJMediaModelProtocol>)media {
    [_playAsset.player pause];
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
}

- (void)setMute:(BOOL)mute {
    if ( mute == _mute ) return;
    _mute = mute;
    _playAsset.player.muted = mute;
}

- (void)setRate:(float)rate {
    _rate = rate;
    _playAsset.player.rate = self.rate;
}

- (void)setVideoGravity:(SJVideoGravity)videoGravity {
    ((SJAVPlayerLayerPresentView *)self.playerView).videoGravity = videoGravity;
}

- (SJVideoGravity)videoGravity {
    return [(SJAVPlayerLayerPresentView *)self.playerView videoGravity];
}

static const char *kSJAVMediaPlayAsset = "kSJAVMediaPlayAsset";
SJAVMediaPlayAsset *_Nullable getAVMediaPlayAsset(id<SJMediaModelProtocol> media) {
    return objc_getAssociatedObject(media, kSJAVMediaPlayAsset);
}

void setAVMediaPlayAsset(id<SJMediaModelProtocol> media, SJAVMediaPlayAsset *_Nullable playAsset) {
    objc_setAssociatedObject(media, kSJAVMediaPlayAsset, playAsset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)prepareToPlay {
    if ( !_media ) return;
    if ( _isPreparing ) return; _isPreparing = YES;
    __weak typeof(self) _self = self;
    dispatch_async(_serailQueue, ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !self.media ) return;
        /// played by other media
        if ( self.media.otherMedia ) {
            self.playAsset = getAVMediaPlayAsset(self.media.otherMedia);
        }
        else {
            AVAsset *asset = nil;
            if ( [(id)self.media respondsToSelector:@selector(avAsset)] ) {
                asset = [(id<SJAVMediaModelProtocol>)self.media avAsset];
            }
            /// played by AVAsset
            if ( asset ) self.playAsset = [[SJAVMediaPlayAsset alloc] initWithAVAsset:asset specifyStartTime:self.media.specifyStartTime];
            /// played by URL
            else self.playAsset = [[SJAVMediaPlayAsset alloc] initWithURL:self.media.mediaURL specifyStartTime:self.media.specifyStartTime];
        }
        setAVMediaPlayAsset(self.media, self.playAsset);
        self.playAssetObserver = [[SJAVMediaPlayAssetPropertiesObserver alloc] initWithPlayerAsset:self.playAsset];
        self.playAssetObserver.delegate = self;
        [self.playAsset load];
    });
}

#pragma mark -
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer durationDidChange:(NSTimeInterval)duration {
    _duration = duration;
    if ( [self.delegate respondsToSelector:@selector(playbackController:durationDidChange:)] ) {
        [self.delegate playbackController:self durationDidChange:duration];
    }
}
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer currentTimeDidChange:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    if ( [self.delegate respondsToSelector:@selector(playbackController:currentTimeDidChange:)] ) {
        [self.delegate playbackController:self currentTimeDidChange:currentTime];
    }
}
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer bufferLoadedTimeDidChange:(NSTimeInterval)bufferLoadedTime {
    _bufferLoadedTime = bufferLoadedTime;
    if ( [self.delegate respondsToSelector:@selector(playbackController:bufferLoadedTimeDidChange:)] ) {
        [self.delegate playbackController:self bufferLoadedTimeDidChange:bufferLoadedTime];
    }
}
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus {
    _bufferStatus = bufferStatus;
    if ( [self.delegate respondsToSelector:@selector(playbackController:bufferStatusDidChange:)] ) {
        [self.delegate playbackController:self bufferStatusDidChange:bufferStatus];
    }
}
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer presentationSizeDidChange:(CGSize)presentationSize {
    _presentationSize = presentationSize;
    if ( [self.delegate respondsToSelector:@selector(playbackController:presentationSizeDidChange:)] ) {
        [self.delegate playbackController:self presentationSizeDidChange:presentationSize];
    }
}
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer playerItemStatusDidChange:(AVPlayerItemStatus)playerItemStatus {
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
- (void)assetLoadIsCompletedForObserver:(SJAVMediaPlayAssetPropertiesObserver *)observer { /* nothing */ }
- (void)playDidToEndForObserver:(SJAVMediaPlayAssetPropertiesObserver *)observer {
    if ( [self.delegate respondsToSelector:@selector(mediaDidPlayToEndForPlaybackController:)] ) {
        [self.delegate mediaDidPlayToEndForPlaybackController:self];
    }
}

#pragma mark -
- (void)play {
    if ( _prepareStatus != SJMediaPlaybackPrepareStatusReadyToPlay ) return;
    
    [_playAsset.player play];
    _playAsset.player.rate = self.rate;
    _playAsset.player.muted = self.mute;
    
#ifdef DEBUG
    printf("\n");
    printf("SJAVMediaPlaybackController<%p>.rate == %lf\n", self, self.rate);
    printf("SJAVMediaPlaybackController<%p>.mute == %s\n",  self, self.mute?"YES":"NO");
#endif
}
- (void)pause {
    if ( _prepareStatus != SJMediaPlaybackPrepareStatusReadyToPlay ) return;
    
    [_playAsset.player pause];
}
- (void)stop {
    [_playAsset.player pause];
    
    if ( !self.media.otherMedia ) {
        [((SJAVPlayerLayerPresentView *)self.playerView).player replaceCurrentItemWithPlayerItem:nil];
        ((SJAVPlayerLayerPresentView *)self.playerView).player = nil;
    }

    [self _cancelOperations];
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

    [_playAsset.playerItem seekToTime:CMTimeMakeWithSeconds(secs, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        if ( completionHandler ) completionHandler(finished);
    }];
}

- (void)cancelPendingSeeks {
    [_playAsset.playerItem cancelPendingSeeks];
}

- (SJVideoPlayerRegistrar *)registrar {
    if ( _registrar ) return _registrar;
    _registrar = [SJVideoPlayerRegistrar new];
    __weak typeof(self) _self = self;
    _registrar.willEnterForeground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.prepareStatus == SJMediaPlaybackPrepareStatusReadyToPlay ) ((SJAVPlayerLayerPresentView *)self.playerView).player = self.playAsset.player;
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
            /**
             关于后台播放视频, 引用自: https://juejin.im/post/5a38e1a0f265da4327185a26
             
             当您想在后台播放视频时:
             1. 需要设置 videoPlayer.pauseWhenAppDidEnterBackground = NO; 该值默认为YES, 即App进入后台默认暂停.
             2. 前往 `TARGETS` -> `Capability` -> enable `Background Modes` -> select this mode `Audio, AirPlay, and Picture in Picture`
             */
            ((SJAVPlayerLayerPresentView *)self.playerView).player = nil;
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
