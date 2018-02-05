//
//  SJVideoPlayer.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayer.h"
#import <SJVideoPlayerAssetCarrier/SJVideoPlayerAssetCarrier.h>
#import "SJVideoPlayerPresentView.h"
#import <Masonry/Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import <SJOrentationObserver/SJOrentationObserver.h>
#import "SJPlayerGestureControl.h"
#import <SJVolBrigControl/SJVolBrigControl.h>
#import "UIView+SJVideoPlayerAdd.h"
#import <objc/message.h>
#import "SJTimerControl.h"
#import <SJObserverHelper/NSObject+SJObserverHelper.h>
#import "SJVideoPlayerRegistrar.h"

@interface SJVideoPlayerAssetCarrier (SJVideoPlayerAdd)
@property (nonatomic, assign) CGSize videoPresentationSize;
@end

@implementation SJVideoPlayerAssetCarrier (SJVideoPlayerAdd)
- (void)setVideoPresentationSize:(CGSize)videoPresentationSize {
    objc_setAssociatedObject(self, @selector(videoPresentationSize), [NSValue valueWithCGSize:videoPresentationSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGSize)videoPresentationSize {
    return [objc_getAssociatedObject(self, _cmd) CGSizeValue];
}
@end


NS_ASSUME_NONNULL_BEGIN
@interface _SJVideoPlayerControlDisplayRecorder : NSObject
- (instancetype)initWithVideoPlayer:(SJVideoPlayer *)videoPlayer;
- (void)considerDisplay;
- (void)needDisplay;
- (void)needHidden;
@end
NS_ASSUME_NONNULL_END


#pragma mark -

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayer () {
    UIView *_view;
    SJVideoPlayerPresentView *_presentView;
    UIView *_controlContentView;
    SJOrentationObserver *_orentationObserver;
    SJPlayerGestureControl *_gestureControl;
    SJVolBrigControl *_volBrigControl;
    _SJVideoPlayerControlDisplayRecorder *_displayRecorder;
    SJVideoPlayerRegistrar *_registrar;
}

@property (nonatomic, assign, readwrite) BOOL userClickedPause;
@property (nonatomic, assign, readwrite) SJVideoPlayerPlayState state;
@property (nonatomic, strong, readwrite, nullable) NSError *error;
@property (nonatomic, strong, readwrite, nullable) SJVideoPlayerAssetCarrier *asset;
@property (nonatomic, assign, readwrite) BOOL scrollIn;
@property (nonatomic, assign, readwrite) BOOL touchedScrollView; // 如果为`YES`, 则不旋转
@property (nonatomic, assign, readwrite) BOOL suspend; // Set it when the [`pause` + `play` + `stop`] is called.
@property (nonatomic, assign, readwrite) BOOL stopped; // Set it when the [`play` + `stop`] is called.

@property (nonatomic, strong, readonly) SJVideoPlayerRegistrar *registrar;
@property (nonatomic, strong, readonly) UIView *controlContentView;
@property (nonatomic, strong, readonly) SJVideoPlayerPresentView *presentView;
@property (nonatomic, strong, readonly) SJOrentationObserver *orentationObserver;
@property (nonatomic, strong, readonly) SJPlayerGestureControl *gestureControl;
@property (nonatomic, strong, readonly) SJVolBrigControl *volBrigControl;
@property (nonatomic, strong, readonly) _SJVideoPlayerControlDisplayRecorder *displayRecorder;

- (void)clear;

@end
NS_ASSUME_NONNULL_END

@implementation SJVideoPlayer

+ (instancetype)player {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    self.autoPlay = YES;
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&error];
    if ( error ) NSLog(@"%@", error.userInfo);
    [self registrar];
    return self;
}

- (void)dealloc {
    [self stop];
}

#pragma mark -

- (void)setAsset:(SJVideoPlayerAssetCarrier *)asset {
    _asset = asset;
    self.presentView.asset = self.asset;
    [self _itemPrepareToPlay];
    
    __weak typeof(self) _self = self;
    
    self.asset.playerItemStateChanged = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, AVPlayerItemStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.state == SJVideoPlayerPlayState_PlayEnd ) return;
        switch ( status ) {
            case AVPlayerItemStatusUnknown:  break;
            case  AVPlayerItemStatusFailed: {
                [self _itemPlayFailed];
            }
                break;
            case AVPlayerItemStatusReadyToPlay: {
                [self _itemReadyToPlay];
            }
                break;
        }
    };
    
    self.asset.playTimeChanged = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlViewDelegate respondsToSelector:@selector(videoPlayer:currentTime:currentTimeStr:totalTime:totalTimeStr:)] ) {
            [self.controlViewDelegate videoPlayer:self currentTime:currentTime currentTimeStr:self.currentTimeStr totalTime:duration totalTimeStr:self.totalTimeStr];
        }
    };

    self.asset.playDidToEnd = ^(SJVideoPlayerAssetCarrier * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _itemPlayDidToEnd];
    };

    self.asset.loadedTimeProgress = ^(float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlViewDelegate respondsToSelector:@selector(videoPlayer:loadedTimeProgress:)] ) {
            [self.controlViewDelegate videoPlayer:self loadedTimeProgress:progress];
        }
    };

    asset.beingBuffered = ^(BOOL state) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.state == SJVideoPlayerPlayState_Buffing ) return;
        [self _itemBuffering];
    };

    self.asset.rateChanged = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, float rate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlViewDelegate respondsToSelector:@selector(videoPlayer:rateChanged:)] ) {
            [self.controlViewDelegate videoPlayer:self rateChanged:rate];
        }
    };

    if ( asset.indexPath ) {
        /// 默认滑入
        self.scrollIn = YES;
    }
    else {
        self.scrollIn = NO;
    }

    // scroll view
    if ( asset.scrollView ) {
        /// 滑入
        asset.scrollIn = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, UIView * _Nonnull superview) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.scrollIn ) return;
            self.scrollIn = YES;
            [self.displayRecorder needDisplay];
            if ( superview && self.view.superview != superview ) {
                [self.view removeFromSuperview];
                [superview addSubview:self.view];
                [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.view.superview);
                }];
            }

            if ( [self.controlViewDelegate respondsToSelector:@selector(scrollViewWillDisplayVideoPlayer:)] ) {
                [self.controlViewDelegate scrollViewWillDisplayVideoPlayer:self];
            }
            //            if ( !self.userPaused &&
            //                 self.state != SJVideoPlayerPlayState_PlayEnd ) [self play];
        };

        /// 滑出
        asset.scrollOut = ^(SJVideoPlayerAssetCarrier * _Nonnull asset) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( !self.scrollIn ) return;
            self.scrollIn = NO;
            if ( [self.controlViewDelegate respondsToSelector:@selector(scrollViewDidEndDisplayingVideoPlayer:)] ) {
                [self.controlViewDelegate scrollViewDidEndDisplayingVideoPlayer:self];
            }
        };

        ///
        asset.touchedScrollView = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, BOOL tracking) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.touchedScrollView = tracking;
        };
    }

    self.asset.presentationSize = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, CGSize size) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( CGSizeEqualToSize(asset.videoPresentationSize, size) ) return;
        if ( self.presentationSize ) self.presentationSize(self, size);
        asset.videoPresentationSize = size;
        if ( [self.controlViewDelegate respondsToSelector:@selector(videoPlayer:presentationSize:)] ) {
            [self.controlViewDelegate videoPlayer:self presentationSize:size];
        }
    };

    if ( self.asset.rateChanged ) self.asset.rateChanged(asset, 1);
}

- (void)setControlViewDataSource:(id<SJVideoPlayerControlDataSource>)controlViewDataSource {
    if ( controlViewDataSource == _controlViewDataSource ) return;
    [_controlViewDataSource.controlView removeFromSuperview];
    _controlViewDataSource = controlViewDataSource;
    [self.controlContentView addSubview:_controlViewDataSource.controlView];
    [_controlViewDataSource.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (void)setControlViewDelegate:(id<SJVideoPlayerControlDelegate>)controlViewDelegate {
    _controlViewDelegate = controlViewDelegate;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( [controlViewDelegate respondsToSelector:@selector(videoPlayer:volumeChanged:)] ) {
            [controlViewDelegate videoPlayer:self volumeChanged:_volBrigControl.volume];
        }
        if ( [controlViewDelegate respondsToSelector:@selector(videoPlayer:brightnessChanged:)] ) {
            [controlViewDelegate videoPlayer:self brightnessChanged:_volBrigControl.brightness];
        }
        if ( SJVideoPlayerPlayState_Prepare == self.state && [controlViewDelegate respondsToSelector:@selector(startLoading:)] ) {
            [controlViewDelegate startLoading:self];
        }
    });

}

- (void)setPlaceholder:(UIImage *)placeholder {
    _placeholder = placeholder;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.alpha = 1;
        self.presentView.placeholder = placeholder;
    });
}

#pragma mark -
- (void)_itemPrepareToPlay {
    if ( self.autoPlay && [self.controlViewDelegate respondsToSelector:@selector(startLoading:)] ) {
        [self.controlViewDelegate startLoading:self];
    }
    
    self.userClickedPause = NO;
    self.state = SJVideoPlayerPlayState_Prepare;
}

- (void)_itemPlayFailed {
    self.error = self.asset.playerItem.error;
    
    self.state = SJVideoPlayerPlayState_PlayFailed;
}

- (void)_itemReadyToPlay {
    if ( !self.autoPlay ) return;
    
    if ( !self.userClickedPause && !self.suspend ) {
        [self play];
    }

    if ( [self.controlViewDelegate respondsToSelector:@selector(loadCompletion:)] ) {
        [self.controlViewDelegate loadCompletion:self];
    }
    
    [self play];
    [self.displayRecorder needDisplay];
}

- (void)_itemPlayDidToEnd {
    
    self.state = SJVideoPlayerPlayState_PlayEnd;
}

- (void)_itemBuffering {
    if ( !self.asset ||
         self.userClickedPause ||
         self.state == SJVideoPlayerPlayState_PlayFailed ||
         self.state == SJVideoPlayerPlayState_PlayEnd ||
         self.state == SJVideoPlayerPlayState_Unknown ||
         self.state == SJVideoPlayerPlayState_Playing ) return;

    if ( [self.controlViewDelegate respondsToSelector:@selector(startLoading:)] ) {
        [self.controlViewDelegate startLoading:self];
    }

    [self.asset.player pause];
    self.state = SJVideoPlayerPlayState_Buffing;
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( !self.asset ||
             self.userClickedPause ||
             self.state == SJVideoPlayerPlayState_PlayFailed ||
             self.state == SJVideoPlayerPlayState_PlayEnd ||
             self.state == SJVideoPlayerPlayState_Unknown ||
             self.state == SJVideoPlayerPlayState_Playing ) return;

        if ( !self.asset.playerItem.isPlaybackLikelyToKeepUp ) {
            [self _itemBuffering];
        }
        else {
            if ( [self.controlViewDelegate respondsToSelector:@selector(loadCompletion:)] ) {
                [self.controlViewDelegate loadCompletion:self];
            }
            if ( !self.suspend ) [self play];
        }
    });
}
#pragma mark -
- (UIView *)view {
    if ( _view ) return _view;
    _view = [SJUIViewFactory viewWithBackgroundColor:[UIColor blackColor]];
    [_view addSubview:self.presentView];
    [self.presentView addSubview:self.controlContentView];
    
    [self.presentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [self.controlContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [self orentationObserver];
    [self gestureControl];
    [self addTapGR];
    return _view;
}

- (void)addTapGR {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGR:)];
    [self.view addGestureRecognizer:tap];
}
- (void)handleTapGR:(UITapGestureRecognizer *)tap {}

- (SJVideoPlayerPresentView *)presentView {
    if ( _presentView ) return _presentView;
    _presentView = [SJVideoPlayerPresentView new]; 
    return _presentView;
}

- (UIView *)controlContentView {
    if ( _controlContentView ) return _controlContentView;
    _controlContentView = [UIView new];
    _controlContentView.clipsToBounds = YES;
    return _controlContentView;
}

#pragma mark -
- (SJOrentationObserver *)orentationObserver {
    if ( _orentationObserver ) return _orentationObserver;
    _orentationObserver = [[SJOrentationObserver alloc] initWithTarget:self.presentView container:self.view];
    
    __weak typeof(self) _self = self;
    
    _orentationObserver.rotationCondition = ^BOOL(SJOrentationObserver * _Nonnull observer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        if ( self.stopped ) {
            if ( observer.isFullScreen ) return YES;
            else return NO;
        }
        if ( self.touchedScrollView ) return NO;
        switch ( self.state ) {
            case SJVideoPlayerPlayState_Unknown:
            case SJVideoPlayerPlayState_Prepare:
            case SJVideoPlayerPlayState_PlayFailed: return NO;
            default: break;
        }
        if ( self.playOnCell && !self.scrollIn ) return NO;
        if ( self.disableRotation ) return NO;
        if ( self.isLockedScreen ) return NO;
        return YES;
    };
    
    _orentationObserver.orientationWillChange = ^(SJOrentationObserver * _Nonnull observer, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.displayRecorder needHidden];
        if ( isFullScreen ) {
            // `iPhone_X` remake constraints.
            if ( SJ_is_iPhoneX() ) {
                [self.controlViewDataSource.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.center.offset(0);
                    make.height.equalTo(self.view);
                    make.width.equalTo(self.view).multipliedBy(16.0f / 9);
                }];
            }
        }
        else {
            // `iPhone_X` remake constraints.
            if ( SJ_is_iPhoneX() ) {
                [self.controlViewDataSource.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.view);
                }];
            }
        }
        if ( [self.controlViewDelegate respondsToSelector:@selector(videoPlayer:willRotateView:)] ) {
            [self.controlViewDelegate videoPlayer:self willRotateView:isFullScreen];
        }
    };
    
    return _orentationObserver;
}
- (SJPlayerGestureControl *)gestureControl {
    if ( _gestureControl ) return _gestureControl;
    _gestureControl = [[SJPlayerGestureControl alloc] initWithTargetView:self.controlContentView];
    __weak typeof(self) _self = self;
    _gestureControl.triggerCondition = ^BOOL(SJPlayerGestureControl * _Nonnull control, SJPlayerGestureType type, UIGestureRecognizer * _Nonnull gesture) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        if ( self.isLockedScreen ) return NO;
        if ( SJVideoPlayerPlayState_Unknown == self.state ||
             SJVideoPlayerPlayState_Prepare == self.state ||
             SJVideoPlayerPlayState_PlayFailed == self.state ) return NO;
        if ( SJPlayerGestureType_Pan == type &&
             self.playOnCell &&
             !self.orentationObserver.fullScreen ) return NO;
        if ( ![self.controlViewDataSource triggerGesturesCondition:[gesture locationInView:gesture.view]] ) return NO;
        return YES;
    };
    
    _gestureControl.singleTapped = ^(SJPlayerGestureControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.displayRecorder considerDisplay];
    };
    
    _gestureControl.doubleTapped = ^(SJPlayerGestureControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( SJVideoPlayerPlayState_Paused == self.state ) [self play];
        else if ( SJVideoPlayerPlayState_PlayEnd == self.state ) [self replay];
        else [self pauseForUser]; //  用户暂停
    };
    
    _gestureControl.beganPan = ^(SJPlayerGestureControl * _Nonnull control, SJPanDirection direction, SJPanLocation location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch (direction) {
            case SJPanDirection_H: {
                if ( [self.controlViewDelegate respondsToSelector:@selector(horizontalDirectionWillBeginDragging:)] ) {
                    [self.controlViewDelegate horizontalDirectionWillBeginDragging:self];
                }
            }
                break;
            case SJPanDirection_V: {
                switch (location) {
                    case SJPanLocation_Right: break;
                    case SJPanLocation_Left: {
                        self.volBrigControl.brightnessView.transform = self.presentView.transform;
                        [[UIApplication sharedApplication].keyWindow addSubview:self.volBrigControl.brightnessView];
                        [self.volBrigControl.brightnessView sj_fadeIn];
                        [self.volBrigControl.brightnessView mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.size.mas_offset(CGSizeMake(155, 155));
                            make.center.equalTo([UIApplication sharedApplication].keyWindow);
                        }];
                    }
                        break;
                    case SJPanLocation_Unknown: break;
                }
            }
                break;
            case SJPanDirection_Unknown:
                break;
        }
    };
    
    _gestureControl.changedPan = ^(SJPlayerGestureControl * _Nonnull control, SJPanDirection direction, SJPanLocation location, CGPoint translate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch (direction) {
            case SJPanDirection_H: {
                if ( [self.controlViewDelegate respondsToSelector:@selector(videoPlayer:horizontalDirectionDidDrag:)] ) {
                    [self.controlViewDelegate videoPlayer:self horizontalDirectionDidDrag:translate.x * 0.003];
                }
            }
                break;
            case SJPanDirection_V: {
                switch (location) {
                    case SJPanLocation_Left: {
                        CGFloat value = self.volBrigControl.brightness - translate.y * 0.006;
                        if ( value < 1.0 / 16 ) value = 1.0 / 16;
                        self.volBrigControl.brightness = value;
                    }
                        break;
                    case SJPanLocation_Right: {
                        CGFloat value = translate.y * 0.008;
                        self.volBrigControl.volume -= value;
                    }
                        break;
                    case SJPanLocation_Unknown: break;
                }
            }
                break;
            default:
                break;
        }
    };
    
    _gestureControl.endedPan = ^(SJPlayerGestureControl * _Nonnull control, SJPanDirection direction, SJPanLocation location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch ( direction ) {
            case SJPanDirection_H:{
                if ( [self.controlViewDelegate respondsToSelector:@selector(horizontalDirectionDidEndDragging:)] ) {
                    [self.controlViewDelegate horizontalDirectionDidEndDragging:self];
                }
            }
                break;
            case SJPanDirection_V:{
                if ( location == SJPanLocation_Left ) [self.volBrigControl.brightnessView sj_fadeOut];
            }
                break;
            case SJPanDirection_Unknown: break;
        }
    };
    
    _gestureControl.pinched = ^(SJPlayerGestureControl * _Nonnull control, float scale) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( scale > 1 ) {
            self.presentView.videoGravity = AVLayerVideoGravityResizeAspectFill;
        }
        else {
            self.presentView.videoGravity = AVLayerVideoGravityResizeAspect;
        }
    };
    return _gestureControl;
}
- (SJVolBrigControl *)volBrigControl {
    if ( _volBrigControl ) return _volBrigControl;
    _volBrigControl = [[SJVolBrigControl alloc] init];
    __weak typeof(self) _self = self;
    _volBrigControl.volumeChanged = ^(float volume) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlViewDelegate respondsToSelector:@selector(videoPlayer:volumeChanged:)] ) {
            [self.controlViewDelegate videoPlayer:self volumeChanged:volume];
        }
    };

    _volBrigControl.brightnessChanged = ^(float brightness) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlViewDelegate respondsToSelector:@selector(videoPlayer:brightnessChanged:)] ) {
            [self.controlViewDelegate videoPlayer:self brightnessChanged:brightness];
        }
    };

    return _volBrigControl;
}
- (_SJVideoPlayerControlDisplayRecorder *)displayRecorder {
    if ( _displayRecorder ) return _displayRecorder;
    _displayRecorder = [[_SJVideoPlayerControlDisplayRecorder alloc] initWithVideoPlayer:self];
    return _displayRecorder;
}
- (SJVideoPlayerRegistrar *)registrar {
    if ( _registrar ) return _registrar;
    _registrar = [SJVideoPlayerRegistrar new];
    
    __weak typeof(self) _self = self;
    _registrar.willResignActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.lockedScreen = YES;
        [self pause];
    };
    
    _registrar.didBecomeActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.lockedScreen = NO;
        if ( self.playOnCell && !self.scrollIn ) return;
        if ( self.state == SJVideoPlayerPlayState_PlayEnd ||
             self.state == SJVideoPlayerPlayState_Unknown ||
             self.state == SJVideoPlayerPlayState_PlayFailed ) return;
        if ( !self.userClickedPause ) [self play];
    };
    
    _registrar.oldDeviceUnavailable = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !self.userClickedPause ) [self play];
    };
    
    //    _registrar.categoryChange = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
    //        __strong typeof(_self) self = _self;
    //        if ( !self ) return;
    //
    //    };
    
    return _registrar;
}

#pragma mark -
- (void)setState:(SJVideoPlayerPlayState)state {
    _state = state;
    switch ( state ) {
        case SJVideoPlayerPlayState_Unknown: {
            NSLog(@"状态: 未知");
        }
            break;
        case SJVideoPlayerPlayState_Playing: {
            NSLog(@"状态: 播放");
        }
            break;
        case SJVideoPlayerPlayState_PlayFailed: {
            NSLog(@"状态: 失败");
        }
            break;
        case SJVideoPlayerPlayState_Prepare: {
            NSLog(@"状态: 准备");
        }
            break;
        case SJVideoPlayerPlayState_Paused: {
            NSLog(@"状态: 暂停");
        }
            break;
        case SJVideoPlayerPlayState_Buffing: {
            NSLog(@"状态: 缓冲");
        }
            break;
        case SJVideoPlayerPlayState_PlayEnd: {
            NSLog(@"状态: 完毕");
        }
            break;
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _presentView.playState = state;
        if ( [self.controlViewDelegate respondsToSelector:@selector(videoPlayer:stateChanged:)] ) {
            [self.controlViewDelegate videoPlayer:self stateChanged:state];
        }
    });

}

- (void)clear {
    self.asset = nil;
}

@end


#pragma mark - 播放

@implementation SJVideoPlayer (Play)

- (void)setAssetURL:(NSURL *)assetURL {
    [self playWithURL:assetURL];
}

/*!
 *  Video URL
 */
- (NSURL *)assetURL {
    return self.asset.assetURL;
}

/*!
 *  Create It By Video URL.
 *
 *  创建一个播放资源.
 *  如果在 `tableView` 或者 `collectionView` 中播放, 使用它来初始化播放资源.
 *  它也可以直接从某个时刻开始播放. 单位是秒.
 **/
- (void)setURLAsset:(SJVideoPlayerURLAsset *)URLAsset {
    objc_setAssociatedObject(self, @selector(URLAsset), URLAsset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.asset = [URLAsset valueForKey:kSJVideoPlayerAssetKey];
    });
}

- (SJVideoPlayerURLAsset *)URLAsset {
    return objc_getAssociatedObject(self, _cmd);
}

/*!
 *  Video URL
 **/
- (void)playWithURL:(NSURL *)playURL {
    [self playWithURL:playURL jumpedToTime:0];
}

/*!
 *  unit: sec.
 *
 *  单位是秒.
 **/
- (void)playWithURL:(NSURL *)playURL jumpedToTime:(NSTimeInterval)time {
    self.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithAssetURL:playURL beginTime:time];
}

@end


#pragma mark - 时间

@implementation SJVideoPlayer (Time)

- (NSString *)timeStringWithSeconds:(NSInteger)secs {
    return [self.asset timeString:secs];
}

- (float)progress {
    if ( 0 == self.totalTime ) return 0;
    return self.currentTime / self.totalTime;
}

/*!
 *  unit sec.
 *
 *  当前播放时间.
 */
- (NSTimeInterval)currentTime {
    return self.asset.currentTime;
}

/*!
 *  unit sec.
 *
 *  当前视频的全部播放时间.
 **/
- (NSTimeInterval)totalTime {
    return self.asset.duration;
}

- (NSString *)currentTimeStr {
    return [self timeStringWithSeconds:self.currentTime];
}

- (NSString *)totalTimeStr {
    return [self timeStringWithSeconds:self.totalTime];
}

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
    if ( isnan(time) ) { return;}
    CMTime seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    [self seekToTime:seekTime completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    if ( [self.controlViewDelegate respondsToSelector:@selector(startLoading:)] ) {
        [self.controlViewDelegate startLoading:self];
    }
    __weak typeof(self) _self = self;
    [self.asset seekToTime:time completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlViewDelegate respondsToSelector:@selector(loadCompletion:)] ) {
            [self.controlViewDelegate loadCompletion:self];
        }
        if ( completionHandler ) completionHandler(finished);
    }];
}
@end


#pragma mark - 控制

@implementation SJVideoPlayer (Control)

- (BOOL)userPaused {
    return self.userClickedPause;
}

- (void)pauseForUser {
    [self pause];
    self.userClickedPause = YES;
}

- (void)setLockedScreen:(BOOL)lockedScreen {
    objc_setAssociatedObject(self, @selector(isLockedScreen), @(lockedScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if      ( lockedScreen && [self.controlViewDelegate respondsToSelector:@selector(lockedVideoPlayer:)] ) {
        [self.controlViewDelegate lockedVideoPlayer:self];
    }
    else if ( !lockedScreen && [self.controlViewDelegate respondsToSelector:@selector(unlockedVideoPlayer:)] ) {
        [self.controlViewDelegate unlockedVideoPlayer:self];
    }
}

- (BOOL)isLockedScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setAutoPlay:(BOOL)autoPlay {
    objc_setAssociatedObject(self, @selector(isAutoPlay), @(autoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isAutoPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)play {
    self.suspend = NO;
    self.stopped = NO;
    
    self.userClickedPause = NO;
    if ( !self.asset ) return NO;
    [self.asset.player play];
    self.state = SJVideoPlayerPlayState_Playing;
    return YES;
}

- (BOOL)pause {
    self.suspend = YES;
    self.userClickedPause = NO;
    
    if ( !self.asset ) return NO;
    [self.asset.player pause];
    if ( SJVideoPlayerPlayState_PlayEnd != self.state ) self.state = SJVideoPlayerPlayState_Paused;
    return YES;
}

- (void)stop {
    self.suspend = NO;
    self.stopped = YES;

    if ( !self.asset ) return;
    [self clear];
    self.state = SJVideoPlayerPlayState_Unknown;
}

- (void)stopAndFadeOut {
    self.suspend = NO;
    self.stopped = YES;
    [self.asset.player pause];
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.001;
    } completion:^(BOOL finished) {
        [self stop];
        [_view removeFromSuperview];
    }];
}

- (void)replay {
    if ( !self.asset ) return;
    [self pause];
    __weak typeof(self) _self = self;
    [self jumpedToTime:0 completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self play];
    }];
}

- (void)setVolume:(float)volume {
    self.volBrigControl.volume = volume;
}

- (float)volume {
    return self.volBrigControl.volume;
}

- (void)setBrightness:(float)brightness {
    self.volBrigControl.brightness = brightness;
}

- (float)brightness {
    return self.volBrigControl.brightness;
}

- (void)setRate:(float)rate {
    self.asset.rate = rate;
}

- (float)rate {
    if ( nil == self.asset ) return 1;
    return self.asset.rate;
}

- (void)resetRate {
    self.asset.rate = 1;
}

@end


#pragma mark - 屏幕旋转

@implementation SJVideoPlayer (Rotation)

/// 旋转
- (void)rotation {
    [self.orentationObserver _changeOrientation];
}

- (void)setDisableRotation:(BOOL)disableRotation {
    objc_setAssociatedObject(self, @selector(disableRotation), @(disableRotation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableRotation {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setWillRotateScreen:(void (^)(SJVideoPlayer * _Nonnull, BOOL))willRotateScreen {
    objc_setAssociatedObject(self, @selector(willRotateScreen), willRotateScreen, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(SJVideoPlayer * _Nonnull, BOOL))willRotateScreen {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRotatedScreen:(void (^)(SJVideoPlayer * _Nonnull, BOOL))rotatedScreen {
    objc_setAssociatedObject(self, @selector(rotatedScreen), rotatedScreen, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(SJVideoPlayer * _Nonnull, BOOL))rotatedScreen {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)isFullScreen {
    return self.orentationObserver.isFullScreen;
}

@end


#pragma mark - 截图

@implementation SJVideoPlayer (Screenshot)

- (void)setPresentationSize:(void (^)(SJVideoPlayer * _Nonnull, CGSize))presentationSize {
    objc_setAssociatedObject(self, @selector(presentationSize), presentationSize, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(SJVideoPlayer * _Nonnull, CGSize))presentationSize {
    return objc_getAssociatedObject(self, _cmd);
}

- (UIImage * __nullable)screenshot {
    return [self.asset screenshot];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(SJVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block {
    [self screenshotWithTime:time size:CGSizeZero completion:block];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(SJVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block {
    [self.asset screenshotWithTime:time size:size completion:^(SJVideoPlayerAssetCarrier * _Nonnull asset, SJVideoPreviewModel * _Nullable images, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( block ) block(self, images.image, error);
        });
    }];
}

- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(SJVideoPlayer *player, NSArray<id<SJVideoPlayerPreviewInfo>> *__nullable images, NSError *__nullable error))block {
    itemSize = CGSizeMake(ceil(itemSize.width), ceil(itemSize.height));
    __weak typeof(self) _self = self;
    [self.asset generatedPreviewImagesWithMaxItemSize:itemSize completion:^(SJVideoPlayerAssetCarrier * _Nonnull asset, NSArray<SJVideoPreviewModel *> * _Nullable images, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self, (id)images, error);
    }];
}

@end


@implementation SJVideoPlayer (ScrollView)

- (BOOL)playOnCell {
    return self.asset.indexPath ? YES : NO;
}

@end


#pragma mark - 提示

@implementation SJVideoPlayer (Prompt)

- (SJPrompt *)prompt {
    SJPrompt *prompt = objc_getAssociatedObject(self, _cmd);
    if ( prompt ) return prompt;
    prompt = [SJPrompt promptWithPresentView:self.presentView];
    prompt.update(^(SJPromptConfig * _Nonnull config) {
        config.cornerRadius = 4;
        config.font = [UIFont systemFontOfSize:12];
    });
    objc_setAssociatedObject(self, _cmd, prompt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return prompt;
}

- (void)showTitle:(NSString *)title {
    [self showTitle:title duration:1];
}

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration {
    [self.prompt showTitle:title duration:duration];
}

- (void)hiddenTitle {
    [self.prompt hidden];
}

@end


#pragma mark -

NS_ASSUME_NONNULL_BEGIN
@interface _SJVideoPlayerControlDisplayRecorder ()
@property (nonatomic, readonly) BOOL appearState;
@property (nonatomic, weak, readonly) SJVideoPlayer *videoPlayer;
@property (nonatomic, strong, readonly) SJTimerControl *timerControl;
@end
NS_ASSUME_NONNULL_END

@implementation _SJVideoPlayerControlDisplayRecorder
@synthesize timerControl = _timerControl;

- (instancetype)initWithVideoPlayer:(SJVideoPlayer *)videoPlayer {
    self = [super init];
    if ( !self ) return nil;
    _videoPlayer = videoPlayer;
    [_videoPlayer sj_addObserver:self forKeyPath:@"state"];
    [_videoPlayer sj_addObserver:self forKeyPath:@"locked"];
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( [keyPath isEqualToString:@"state"] ) {
        if      ( SJVideoPlayerPlayState_Paused == self.videoPlayer.state ) {
            [self _keepDisplay];
        }
        else if ( SJVideoPlayerPlayState_Playing == self.videoPlayer.state &&
                 self.appearState ) {
            [self needDisplay];
        }
    }
    else if ( [keyPath isEqualToString:@"locked"] ) {
        if ( _videoPlayer.isLockedScreen ) {
            [self.timerControl clear];
        }
        else {
            [self.timerControl start];
        }
    }
}

- (void)considerDisplay {
    if ( self.appearState ) [self needHidden];
    else [self needDisplay];
}

- (void)needDisplay {
    [self.timerControl start];
    [self _callDelegateMethodWithStatus:YES];
}

- (void)_keepDisplay {
    [self needDisplay];
    [self.timerControl clear];
}

- (void)needHidden {
    [self.timerControl clear];
    [self _callDelegateMethodWithStatus:NO];
}

- (SJTimerControl *)timerControl {
    if ( _timerControl ) return _timerControl;
    _timerControl = [[SJTimerControl alloc] init];
    __weak typeof(self) _self = self;
    _timerControl.exeBlock = ^(SJTimerControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;

        // 是否达到触发时机, 如果没达到时机, 则保持状态.
        if ( !self.videoPlayer.controlViewDataSource.controlLayerAppearCondition ||
             !self.videoPlayer.controlViewDataSource.controlLayerDisappearCondition ||
             ( self.appearState && SJVideoPlayerPlayState_Paused == self.videoPlayer.state ) ) {
            [control reset];
        }
        else {
            if ( self.appearState ) [self needHidden];
            else [control clear];
        }
        
    };
    return _timerControl;
}

#pragma mark -
- (void)_callDelegateMethodWithStatus:(BOOL)status {
    if      ( status && [self.videoPlayer.controlViewDelegate respondsToSelector:@selector(controlLayerNeedAppear:)] ) {
        [self.videoPlayer.controlViewDelegate controlLayerNeedAppear:self.videoPlayer];
    }
    else if ( !status && [self.videoPlayer.controlViewDelegate respondsToSelector:@selector(controlLayerNeedDisappear:)] ) {
        [self.videoPlayer.controlViewDelegate controlLayerNeedDisappear:self.videoPlayer];
    }
}

- (BOOL)appearState {
    return self.videoPlayer.controlViewDataSource.controlLayerAppearedState;
}
@end
