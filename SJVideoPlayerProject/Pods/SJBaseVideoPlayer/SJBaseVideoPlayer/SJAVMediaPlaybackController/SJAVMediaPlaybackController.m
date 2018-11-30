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
#import "SJAVMediaPresentView.h"
#import "NSTimer+SJAssetAdd.h"

NS_ASSUME_NONNULL_BEGIN
/// 切换分辨率
/// 切换完成后, 为避免延时, 请调用play
@interface SJAVMediaPlayAssetSwitcher : NSObject
- (instancetype)initWithURL:(NSURL *)URL
           replyCurrentTime:(CMTime(^)(SJAVMediaPlayAssetSwitcher *switcher))replyCurrentTime
                  presenter:(id<SJAVPlayerLayerPresenter>(^)(SJAVMediaPlayAssetSwitcher *switcher, AVPlayer *player))presenter
          completionHandler:(void(^)(SJAVMediaPlayAssetSwitcher *switcher, BOOL result, SJAVMediaPlayAsset *_Nullable playAsset, id<SJAVPlayerLayerPresenter> _Nullable presenter))completionHandler;
@end


@interface SJAVMediaPlaybackController()<SJAVMediaPlayAssetPropertiesObserverDelegate>
@property (nonatomic, strong, readonly) SJVideoPlayerRegistrar *registrar;

@property (nonatomic, strong, readonly) SJAVMediaPresentView *presentView;
@property (nonatomic, strong, nullable) SJAVMediaPlayAssetSwitcher *switcher;
@property (nonatomic, strong, nullable) SJAVMediaPlayAssetPropertiesObserver *playAssetObserver;
@property (nonatomic, strong, nullable) SJAVMediaPlayAsset *playAsset;
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
    _presentView = [SJAVMediaPresentView new];
    [self registrar];
    return self;
}

- (UIView *)playerView {
    return _presentView;
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
    _switcher = nil;
    [_presentView removeAllPresenter];
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
    self.presentView.presenters.lastObject.videoGravity = videoGravity;
}

- (SJVideoGravity)videoGravity {
    return self.presentView.presenters.lastObject.videoGravity;
}

- (void)prepareToPlay {
    if ( !_media ) return;
    if ( _isPreparing ) return; _isPreparing = YES;
    _playAsset = [self _getPlayAssetForMedia:_media];
    _playAssetObserver = [[SJAVMediaPlayAssetPropertiesObserver alloc] initWithPlayerAsset:_playAsset];
    _playAssetObserver.delegate = self;
    [_playAsset load];
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
    }
    [self _refreshPlayAssetForMedia:media playAsset:playAsset];
    return playAsset;
}

- (void)_refreshPlayAssetForMedia:(id<SJMediaModelProtocol>)media playAsset:(SJAVMediaPlayAsset *)playAsset {
    objc_setAssociatedObject(media.otherMedia?:media, key, playAsset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)switchVideoDefinitionByURL:(NSURL *)URL {
    if ( !_playAsset ) return;
    [self.delegate playbackController:self
                switchVideoDefinitionByURL:URL
                      statusDidChange:SJMediaPlaybackSwitchDefinitionStatusSwitching];
    
    __weak typeof(self) _self = self;
    AVPlayerItem *playerItem = _playAsset.playerItem;
    _switcher = [[SJAVMediaPlayAssetSwitcher alloc] initWithURL:URL replyCurrentTime:^CMTime(SJAVMediaPlayAssetSwitcher * _Nonnull switcher) {
        return playerItem.currentTime;
    } presenter:^id<SJAVPlayerLayerPresenter> _Nonnull(SJAVMediaPlayAssetSwitcher * _Nonnull switcher, AVPlayer * _Nonnull player) {
        id<SJAVPlayerLayerPresenter> presenter = [self.presentView createPresenterForPlayer:player];
        [self.presentView insertPresenter:presenter atIndex:0];
        presenter.videoGravity = self.videoGravity;
        return presenter;
    } completionHandler:^(SJAVMediaPlayAssetSwitcher * _Nonnull switcher, BOOL result, SJAVMediaPlayAsset * _Nullable playAsset, id<SJAVPlayerLayerPresenter> presenter) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( !result ) {
#ifdef DEBUG
            printf("\n切换失败!\n");
#endif

            [self.delegate playbackController:self switchVideoDefinitionByURL:URL statusDidChange:SJMediaPlaybackSwitchDefinitionStatusFailed];
        }
        else {
#ifdef DEBUG
            printf("\n切换完成\n");
#endif
            [self _refreshPlayAssetForMedia:self.media playAsset:playAsset];
            self.media.mediaURL = URL;
            self.playAsset = playAsset;
            self.playAssetObserver = [[SJAVMediaPlayAssetPropertiesObserver alloc] initWithPlayerAsset:playAsset];
            self.playAssetObserver.delegate = self;
            [self play];
            [self.presentView removeAllPresenterAndAddNewPresenter:presenter];
            self.switcher = nil;
        }
    }];
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
    if ( _prepareStatus == (SJMediaPlaybackPrepareStatus)playerItemStatus ) return;
    _isPreparing = NO;
    _prepareStatus = (SJMediaPlaybackPrepareStatus)playerItemStatus;
    
    if ( playerItemStatus != AVPlayerStatusReadyToPlay ||
         self.registrar.state == SJVideoPlayerAppState_Background ) {
        if ( [self.delegate respondsToSelector:@selector(playbackController:prepareToPlayStatusDidChange:)] ) {
            [self.delegate playbackController:self prepareToPlayStatusDidChange:_prepareStatus];
        }
        return;
    }
    
    __weak typeof(self) _self = self;
    void(^_inner_loadPresentationSize)(void) = ^ {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.playAssetObserver _loadPresentationSize:^(CGSize presentationSize) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( !CGSizeEqualToSize(presentationSize, CGSizeZero) ) {
                id<SJAVPlayerLayerPresenter> presenter = [self.presentView createPresenterForPlayer:self.playAsset.player];
                [self.presentView  removeAllPresenterAndAddNewPresenter:presenter];
                void(^inner_isReadyForDisplay)(id<SJAVPlayerLayerPresenter>  _Nonnull presenter) = ^(id<SJAVPlayerLayerPresenter>  _Nonnull presenter) {
                    __strong typeof(_self) self = _self;
                    if ( !self ) return ;
                    if ( [self.delegate respondsToSelector:@selector(playbackController:prepareToPlayStatusDidChange:)] ) {
                        [self.delegate playbackController:self prepareToPlayStatusDidChange:(NSInteger)playerItemStatus];
                    }
                };
                
                if ( presenter.isReadyForDisplay ) {
                    inner_isReadyForDisplay(presenter);
                }
                else {
                    presenter.isReadyForDisplayExeBlock = inner_isReadyForDisplay;
                }
            }
            else {
                if ( [self.delegate respondsToSelector:@selector(playbackController:prepareToPlayStatusDidChange:)] ) {
                    [self.delegate playbackController:self prepareToPlayStatusDidChange:(NSInteger)playerItemStatus];
                }
            }
        }];
    };
    
    /// seek to specify start time
    if ( 0 != self.media.specifyStartTime ) {
        [self seekToTime:self.media.specifyStartTime completionHandler:^(BOOL finished) {
            _inner_loadPresentationSize();
        }];
    }
    else {
        _inner_loadPresentationSize();
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
    
    if ( !_media.otherMedia ) {
        [_playAsset.player replaceCurrentItemWithPlayerItem:nil];
        [_presentView removeAllPresenter];
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

#pragma mark -
- (SJVideoPlayerRegistrar *)registrar {
    if ( _registrar ) return _registrar;
    _registrar = [SJVideoPlayerRegistrar new];
    __weak typeof(self) _self = self;
    _registrar.willEnterForeground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.prepareStatus == SJMediaPlaybackPrepareStatusReadyToPlay ) {
            [self.presentView removeAllPresenterAndAddNewPresenter:[self.presentView createPresenterForPlayer:self.playAsset.player]];
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
            /**
             关于后台播放视频, 引用自: https://juejin.im/post/5a38e1a0f265da4327185a26
             
             当您想在后台播放视频时:
             1. 需要设置 videoPlayer.pauseWhenAppDidEnterBackground = NO; 该值默认为YES, 即App进入后台默认暂停.
             2. 前往 `TARGETS` -> `Capability` -> enable `Background Modes` -> select this mode `Audio, AirPlay, and Picture in Picture`
             */
            [self.presentView removeAllPresenter];
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


#pragma mark -
@interface SJAVMediaPlayAssetSwitcher ()<SJAVMediaPlayAssetPropertiesObserverDelegate>
@property (nonatomic, copy) void(^completionHandler)(SJAVMediaPlayAssetSwitcher *switcher, BOOL result, SJAVMediaPlayAsset *_Nullable playAsset, id<SJAVPlayerLayerPresenter> _Nullable presenter);
@property (nonatomic, copy) CMTime(^replyCurrentTime)(SJAVMediaPlayAssetSwitcher *switcher);
@property (nonatomic, copy) id<SJAVPlayerLayerPresenter>(^presenter)(SJAVMediaPlayAssetSwitcher *switcher, AVPlayer *player);
@property (nonatomic, weak, nullable) id<SJMediaModelProtocol> originMedia;
@property (nonatomic, strong, nullable) NSTimer *timer;
@property (nonatomic, strong, readonly) SJAVMediaPlayAsset *playAsset;
@property (nonatomic, strong, readonly) SJAVMediaPlayAssetPropertiesObserver *playAssetObserver;
@end

@implementation SJAVMediaPlayAssetSwitcher
- (instancetype)initWithURL:(NSURL *)URL
           replyCurrentTime:(CMTime(^)(SJAVMediaPlayAssetSwitcher *switcher))replyCurrentTime
                  presenter:(id<SJAVPlayerLayerPresenter>(^)(SJAVMediaPlayAssetSwitcher *switcher, AVPlayer *player))presenter
          completionHandler:(void(^)(SJAVMediaPlayAssetSwitcher *switcher, BOOL result, SJAVMediaPlayAsset *_Nullable playAsset, id<SJAVPlayerLayerPresenter> _Nullable presenter))completionHandler {
    self = [super init];
    if ( !self ) return nil;
    _replyCurrentTime = replyCurrentTime;
    _completionHandler = completionHandler;
    _presenter = presenter;
    
    // load new asset
    _playAsset = [[SJAVMediaPlayAsset alloc] initWithURL:URL];
    _playAssetObserver = [[SJAVMediaPlayAssetPropertiesObserver alloc] initWithPlayerAsset:_playAsset];
    _playAssetObserver.delegate = self;
    [_playAsset load];
#ifdef DEBUG
    printf("\n切换进度: 1");
#endif
    return self;
}

- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer playerItemStatusDidChange:(AVPlayerItemStatus)playerItemStatus {
    switch ( playerItemStatus ) {
        case AVPlayerItemStatusUnknown: break;
        case AVPlayerItemStatusReadyToPlay: {
            [self _playerItemReadyToPlay];
        }
            break;
        case AVPlayerItemStatusFailed: {
            if ( _completionHandler ) _completionHandler(self, NO, nil, nil);
        }
            break;
    }
}

- (void)_playerItemReadyToPlay {
    AVPlayerItem *playerItem = _playAsset.playerItem;
    CMTime preTime = self.replyCurrentTime(self);
    preTime = CMTimeAdd(preTime, CMTimeMakeWithSeconds(5, NSEC_PER_SEC));
//   -1 is returned if time1 is less than time2.
//    1 is returned if time1 is greater than time2.
//    0 is returned if time1 and time2 are equal.
    int32_t result = CMTimeCompare(preTime, playerItem.duration);
    if ( -1 == result ) {}
    else if ( 0 == result ) {}
    else if ( 1 == result ) {
        preTime = playerItem.duration;
    }
    
#ifdef DEBUG
    printf("\n切换进度: 2, %lf - %lf", CMTimeGetSeconds(preTime), CMTimeGetSeconds(playerItem.duration));
#endif
    __weak typeof(self) _self = self;
    [playerItem seekToTime:preTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
#ifdef DEBUG
        printf("\n切换进度: 3, %d", finished);
#endif
        if ( !finished ) {
            if ( self.completionHandler ) self.completionHandler(self, NO, nil, nil);
        }
        else {
            id<SJAVPlayerLayerPresenter> presenter = self.presenter(self, self.playAsset.player);
            presenter.isReadyForDisplayExeBlock = ^(id<SJAVPlayerLayerPresenter>  _Nonnull presenter) {
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
#ifdef DEBUG
                printf("\n切换进度: 4");
#endif
                // 确定跳转到的时间大于当前播放的进度
                CMTime preTime = self.playAsset.playerItem.currentTime;
                CMTime currentPlayingTime = self.replyCurrentTime(self);
                int32_t result = CMTimeCompare(preTime, currentPlayingTime);
                if ( -1 == result ) {
                    [self _playerItemReadyToPlay];
                }
                else if ( 0 == result ) {
                    if ( self.completionHandler ) self.completionHandler(self, YES, self.playAsset, presenter);
                }
                else if ( 1 == result ) {
                    CMTime sub = CMTimeSubtract(preTime, currentPlayingTime);
                    NSTimeInterval interval = CMTimeGetSeconds(sub);
                    self.timer = [NSTimer assetAdd_timerWithTimeInterval:interval block:^(NSTimer *timer) {
                        [timer invalidate];
                        __strong typeof(_self) self = _self;
                        if ( !self ) return ;
                        if ( self.completionHandler ) self.completionHandler(self, YES, self.playAsset, presenter);
                    } repeats:NO];
                    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
                    [NSRunLoop.mainRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
                }
            };
        }
    }];
}
@end
NS_ASSUME_NONNULL_END
