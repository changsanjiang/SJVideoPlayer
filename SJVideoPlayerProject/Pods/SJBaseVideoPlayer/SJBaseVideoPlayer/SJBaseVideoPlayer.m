//
//  SJBaseVideoPlayer.m
//  SJBaseVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJBaseVideoPlayer.h"
#import <SJVideoPlayerAssetCarrier/SJVideoPlayerAssetCarrier.h>
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
#import "SJVideoPlayerPresentView.h"

@interface SJVideoPlayerAssetCarrier (SJBaseVideoPlayerAdd)
@property (nonatomic, assign) CGSize videoPresentationSize;
@end

@implementation SJVideoPlayerAssetCarrier (SJBaseVideoPlayerAdd)
- (void)setVideoPresentationSize:(CGSize)videoPresentationSize {
    objc_setAssociatedObject(self, @selector(videoPresentationSize), [NSValue valueWithCGSize:videoPresentationSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGSize)videoPresentationSize {
    return [objc_getAssociatedObject(self, _cmd) CGSizeValue];
}
@end


#pragma mark -

NS_ASSUME_NONNULL_BEGIN
@interface _SJBaseVideoPlayerControlDisplayRecorder : NSObject
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, readonly) BOOL controlLayerAppearedState;
- (instancetype)initWithVideoPlayer:(SJBaseVideoPlayer *)videoPlayer;
- (void)considerDisplay;
- (void)layerAppear;
- (void)layerDisappear;
- (void)clear;
@end
NS_ASSUME_NONNULL_END


#pragma mark -

NS_ASSUME_NONNULL_BEGIN
@interface SJBaseVideoPlayer () {
    UIView *_view;
    SJVideoPlayerPresentView *_presentView;
    UIView *_controlContentView;
    SJOrentationObserver *_orentationObserver;
    SJPlayerGestureControl *_gestureControl;
    SJVolBrigControl *_volBrigControl;
    _SJBaseVideoPlayerControlDisplayRecorder *_displayRecorder;
    SJVideoPlayerRegistrar *_registrar;
}

@property (nonatomic, assign, readwrite) BOOL userClickedPause;
@property (nonatomic, assign, readwrite) SJVideoPlayerPlayState state;
@property (nonatomic, strong, readwrite, nullable) NSError *error;
@property (nonatomic, strong, readwrite, nullable) SJVideoPlayerAssetCarrier *asset;
@property (nonatomic, assign, readwrite) BOOL scrollIn;
@property (nonatomic, assign, readwrite) BOOL touchedScrollView; // 如果为`YES`, 则不旋转
@property (nonatomic, assign, readwrite) BOOL suspend; // Set it when the [`pause` || `play` || `stop`] is called.
@property (nonatomic, assign, readwrite) BOOL resignActive; // app 进入后台, 进入前台时会设置

@property (nonatomic, strong, readonly) SJVideoPlayerRegistrar *registrar;
@property (nonatomic, strong, readonly) UIView *controlContentView;
@property (nonatomic, strong, readonly) SJVideoPlayerPresentView *presentView;
@property (nonatomic, strong, readonly) SJOrentationObserver *orentationObserver;
@property (nonatomic, strong, readonly) SJPlayerGestureControl *gestureControl;
@property (nonatomic, strong, readonly) SJVolBrigControl *volBrigControl;
@property (nonatomic, strong, readonly) _SJBaseVideoPlayerControlDisplayRecorder *displayRecorder;

- (void)clearAsset;

@end
NS_ASSUME_NONNULL_END

@implementation SJBaseVideoPlayer

+ (instancetype)player {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if ( error ) NSLog(@"%@", error.userInfo);
    self.autoPlay = YES;
    self.enableControlLayerDisplayController = YES; 
    [self registrar];
    [self view];
    return self;
}

- (void)dealloc {
#ifndef DEBUG
    NSLog(@"%zd - %s", __LINE__, __func__);
#endif
    [self stop];
}

#pragma mark -

- (void)setAsset:(SJVideoPlayerAssetCarrier *)asset {
    _asset = asset;
    if ( !asset ) return;
    if ( self.mute ) self.mute = YES; // update
    self.presentView.player = self.asset.player;
    [self _itemPrepareToPlay];
    
    __weak typeof(self) _self = self;
    self.asset.playerItemStateChanged = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, AVPlayerItemStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.state == SJVideoPlayerPlayState_PlayEnd ) return;
        switch ( status ) {
            case AVPlayerItemStatusUnknown:  break;
            case AVPlayerItemStatusFailed: {
                [self _itemPlayFailed];
            }
                break;
            case AVPlayerItemStatusReadyToPlay: {
                if ( !self.resignActive ) [self _itemReadyToPlay];
            }
                break;
        }
    };
    
    self.asset.playTimeChanged = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:currentTime:currentTimeStr:totalTime:totalTimeStr:)] ) {
            [self.controlLayerDelegate videoPlayer:self currentTime:currentTime currentTimeStr:self.currentTimeStr totalTime:duration totalTimeStr:self.totalTimeStr];
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
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:loadedTimeProgress:)] ) {
            [self.controlLayerDelegate videoPlayer:self loadedTimeProgress:progress];
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
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:rateChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self rateChanged:rate];
        }
        if ( self.rateChanged ) self.rateChanged(self);
        if ( SJVideoPlayerPlayState_PlayEnd == self.state ) [self replay];
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
            [self.displayRecorder layerAppear];
            if ( superview && self.view.superview != superview ) {
                [self.view removeFromSuperview];
                [superview addSubview:self.view];
                [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.view.superview);
                }];
            }
            
            if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayerWillAppearInScrollView:)] ) {
                [self.controlLayerDelegate videoPlayerWillAppearInScrollView:self];
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
            if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayerWillDisappearInScrollView:)] ) {
                [self.controlLayerDelegate videoPlayerWillDisappearInScrollView:self];
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
        if ( CGSizeEqualToSize(self.asset.videoPresentationSize, size) ) return;
        if ( self.presentationSize ) self.presentationSize(self, size);
        self.asset.videoPresentationSize = size;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:presentationSize:)] ) {
            [self.controlLayerDelegate videoPlayer:self presentationSize:size];
        }
    };
}

- (void)setControlLayerDataSource:(id<SJVideoPlayerControlLayerDataSource>)controlLayerDataSource {
    if ( controlLayerDataSource == _controlLayerDataSource ) return;
    [_controlLayerDataSource.controlView removeFromSuperview];
    _controlLayerDataSource = controlLayerDataSource;
    if ( !controlLayerDataSource ) return;
    
    _controlLayerDataSource.controlView.clipsToBounds = YES;
    // install
    [self.controlContentView addSubview:_controlLayerDataSource.controlView];
    [_controlLayerDataSource.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    if ( [self.controlLayerDataSource respondsToSelector:@selector(installedControlViewToVideoPlayer:)] ) {
        [self.controlLayerDataSource installedControlViewToVideoPlayer:self];
    }
}

- (void)setControlLayerDelegate:(id<SJVideoPlayerControlLayerDelegate>)controlLayerDelegate {
    if ( controlLayerDelegate == _controlLayerDelegate ) return;
    _controlLayerDelegate = controlLayerDelegate;
    
    if ( [controlLayerDelegate respondsToSelector:@selector(videoPlayer:volumeChanged:)] ) {
        [controlLayerDelegate videoPlayer:self volumeChanged:_volBrigControl.volume];
    }
    if ( [controlLayerDelegate respondsToSelector:@selector(videoPlayer:brightnessChanged:)] ) {
        [controlLayerDelegate videoPlayer:self brightnessChanged:_volBrigControl.brightness];
    }
    if ( SJVideoPlayerPlayState_Prepare == self.state &&
        [controlLayerDelegate respondsToSelector:@selector(startLoading:)] ) {
        [controlLayerDelegate startLoading:self];
    }
}

- (void)setPlaceholder:(UIImage *)placeholder {
    _placeholder = placeholder;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.presentView.placeholder = placeholder;
    });
}

#pragma mark -
- (void)_itemPrepareToPlay {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:prepareToPlay:)] ) {
        [self.controlLayerDelegate videoPlayer:self prepareToPlay:self.URLAsset];
    }
    
    if ( self.autoPlay && [self.controlLayerDelegate respondsToSelector:@selector(startLoading:)] ) {
        [self.controlLayerDelegate startLoading:self];
    }
    
    self.userClickedPause = NO;
    self.state = SJVideoPlayerPlayState_Prepare;
}

- (void)_itemPlayFailed {
    self.error = self.asset.playerItem.error;
    
    self.state = SJVideoPlayerPlayState_PlayFailed;
}

- (void)_itemReadyToPlay {
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:currentTime:currentTimeStr:totalTime:totalTimeStr:)] ) {
        [self.controlLayerDelegate videoPlayer:self currentTime:self.currentTime currentTimeStr:self.currentTimeStr totalTime:self.totalTime totalTimeStr:self.totalTimeStr];
    }
    
    if ( !self.autoPlay ) return;
    
    if ( !self.userClickedPause && !self.suspend ) [self play];
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(loadCompletion:)] ) {
        [self.controlLayerDelegate loadCompletion:self];
    }
    
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.displayRecorder layerAppear];
    });
}

- (void)_itemPlayDidToEnd {
    self.state = SJVideoPlayerPlayState_PlayEnd;
    if ( self.playDidToEnd ) self.playDidToEnd(self);
}

- (void)_itemBuffering {
    if ( !self.asset ||
        self.userClickedPause ||
        self.state == SJVideoPlayerPlayState_PlayFailed ||
        self.state == SJVideoPlayerPlayState_PlayEnd ||
        self.state == SJVideoPlayerPlayState_Unknown ||
        self.state == SJVideoPlayerPlayState_Playing ) return;
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(startLoading:)] ) {
        [self.controlLayerDelegate startLoading:self];
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
            if ( [self.controlLayerDelegate respondsToSelector:@selector(loadCompletion:)] ) {
                [self.controlLayerDelegate loadCompletion:self];
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
    [self addInterceptTapGR];
    return _view;
}

- (void)addInterceptTapGR {
    UITapGestureRecognizer *intercept = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInterceptTapGR:)];
    [self.view addGestureRecognizer:intercept];
}
- (void)handleInterceptTapGR:(UITapGestureRecognizer *)tap {}

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
        if ( self.touchedScrollView ) return NO;
        if ( self.playOnCell && !self.scrollIn ) return NO;
        if ( self.disableRotation ) return NO;
        if ( self.isLockedScreen ) return NO;
        if ( self.resignActive ) return NO;
        return YES;
    };
    
    _orentationObserver.orientationWillChange = ^(SJOrentationObserver * _Nonnull observer, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.displayRecorder layerDisappear];
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:willRotateView:)] ) {
            [self.controlLayerDelegate videoPlayer:self willRotateView:isFullScreen];
        }
        if ( self.willRotateScreen ) self.willRotateScreen(self, isFullScreen);
    };
    
    _orentationObserver.orientationChanged = ^(SJOrentationObserver * _Nonnull observer, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( isFullScreen ) {
            // `iPhone_X` remake constraints.
            if ( SJ_is_iPhoneX() ) {
                [self.controlLayerDataSource.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.center.offset(0);
                    make.height.equalTo(self.controlLayerDataSource.controlView.superview);
                    make.width.equalTo(self.controlLayerDataSource.controlView.mas_height).multipliedBy(16 / 9.0f);
                }];
            }
        }
        else {
            // `iPhone_X` remake constraints.
            if ( SJ_is_iPhoneX() ) {
                [self.controlLayerDataSource.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.offset(0);
                }];
            }
        }
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:didEndRotation:)] ) {
            [self.controlLayerDelegate videoPlayer:self didEndRotation:isFullScreen];
        }
        if ( self.rotatedScreen ) self.rotatedScreen(self, observer.isFullScreen);
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
            !self.orentationObserver.isFullScreen ) return NO;
        
        if ( self.controlLayerDataSource &&
            ![self.controlLayerDataSource triggerGesturesCondition:[gesture locationInView:gesture.view]] ) return NO;
        
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
                if ( [self.controlLayerDelegate respondsToSelector:@selector(horizontalDirectionWillBeginDragging:)] ) {
                    [self.controlLayerDelegate horizontalDirectionWillBeginDragging:self];
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
                if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:horizontalDirectionDidDrag:)] ) {
                    [self.controlLayerDelegate videoPlayer:self horizontalDirectionDidDrag:translate.x * 0.003];
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
                if ( [self.controlLayerDelegate respondsToSelector:@selector(horizontalDirectionDidEndDragging:)] ) {
                    [self.controlLayerDelegate horizontalDirectionDidEndDragging:self];
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
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:volumeChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self volumeChanged:volume];
        }
    };
    
    _volBrigControl.brightnessChanged = ^(float brightness) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:brightnessChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self brightnessChanged:brightness];
        }
    };
    
    return _volBrigControl;
}
- (_SJBaseVideoPlayerControlDisplayRecorder *)displayRecorder {
    if ( _displayRecorder ) return _displayRecorder;
    _displayRecorder = [[_SJBaseVideoPlayerControlDisplayRecorder alloc] initWithVideoPlayer:self];
    return _displayRecorder;
}
- (SJVideoPlayerRegistrar *)registrar {
    if ( _registrar ) return _registrar;
    _registrar = [SJVideoPlayerRegistrar new];
    
    __weak typeof(self) _self = self;
    _registrar.willResignActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.resignActive = YES;
        if ( self.state != SJVideoPlayerPlayState_Paused ) [self.asset.player pause];
    };
    
    _registrar.didBecomeActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.resignActive = NO;
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
#if 0
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
#endif
    _presentView.playState = state;
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:stateChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self stateChanged:state];
    }
    if ( SJVideoPlayerPlayState_PlayFailed == state ) {
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:playFailed:)] ) {
            [self.controlLayerDelegate videoPlayer:self playFailed:self.error];
        }
    }
}

- (void)clearAsset {
    [self.asset.player pause];
    [self.presentView.player replaceCurrentItemWithPlayerItem:nil];
    self.presentView.player = nil;
    self.asset = nil;
}

@end


#pragma mark - 播放

@implementation SJBaseVideoPlayer (Play)

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

- (void)refresh {
    if ( !self.asset ) return;
    [self.URLAsset setValue:[[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:self.asset.assetURL beginTime:self.asset.beginTime indexPath:self.asset.indexPath superviewTag:self.asset.superviewTag scrollViewIndexPath:self.asset.scrollViewIndexPath scrollViewTag:self.asset.scrollViewTag scrollView:self.asset.scrollView rootScrollView:self.asset.rootScrollView] forKey:kSJVideoPlayerAssetKey];
    self.asset = [self.URLAsset valueForKey:kSJVideoPlayerAssetKey];
}

@end


#pragma mark - 时间

@implementation SJBaseVideoPlayer (Time)

- (NSString *)timeStringWithSeconds:(NSInteger)secs {
    return [self.asset timeString:secs];
}

- (float)progress {
    if ( 0 == self.totalTime ) return 0;
    return self.currentTime / self.totalTime;
}

- (NSTimeInterval)currentTime {
    return self.asset.currentTime;
}

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
    if ( [self.controlLayerDelegate respondsToSelector:@selector(startLoading:)] ) {
        [self.controlLayerDelegate startLoading:self];
    }
    __weak typeof(self) _self = self;
    [self.asset seekToTime:time completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(loadCompletion:)] ) {
            [self.controlLayerDelegate loadCompletion:self];
        }
        if ( completionHandler ) completionHandler(finished);
    }];
}
@end


#pragma mark - 控制

@implementation SJBaseVideoPlayer (Control)

- (void)setMute:(BOOL)mute {
    if ( mute == self.mute ) return;
    objc_setAssociatedObject(self, @selector(mute), @(mute), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.asset.player.volume = !mute;
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:muteChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self muteChanged:mute];
    }
}

- (BOOL)mute {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)userPaused {
    return self.userClickedPause;
}

- (void)pauseForUser {
    [self pause];
    self.userClickedPause = YES;
}

- (void)setLockedScreen:(BOOL)lockedScreen {
    objc_setAssociatedObject(self, @selector(isLockedScreen), @(lockedScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if      ( lockedScreen && [self.controlLayerDelegate respondsToSelector:@selector(lockedVideoPlayer:)] ) {
        [self.controlLayerDelegate lockedVideoPlayer:self];
    }
    else if ( !lockedScreen && [self.controlLayerDelegate respondsToSelector:@selector(unlockedVideoPlayer:)] ) {
        [self.controlLayerDelegate unlockedVideoPlayer:self];
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
    
    self.userClickedPause = NO;
    if ( !self.asset ) return NO;
    if ( 0 == self.asset.player.rate ) [self.asset.player play];
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
    
    if ( !self.asset ) return;
    [self clearAsset];
    self.state = SJVideoPlayerPlayState_Unknown;
}

- (void)stopAndFadeOut {
    self.suspend = NO;
    [self.asset.player pause];
    [self.view sj_fadeOutAndCompletion:^(UIView *view) {
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

- (void)setRateChanged:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull))rateChanged {
    objc_setAssociatedObject(self, @selector(rateChanged), rateChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull))rateChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlayDidToEnd:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull))playDidToEnd {
    objc_setAssociatedObject(self, @selector(playDidToEnd), playDidToEnd, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull))playDidToEnd {
    return objc_getAssociatedObject(self, _cmd);
}

@end


#pragma mark - 控制层

@implementation SJBaseVideoPlayer (ControlLayer)

- (BOOL)enableControlLayerDisplayController {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setEnableControlLayerDisplayController:(BOOL)enableControlLayerDisplayController {
    objc_setAssociatedObject(self, @selector(enableControlLayerDisplayController), @(enableControlLayerDisplayController), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.displayRecorder.enabled = enableControlLayerDisplayController;
}

- (BOOL)controlLayerAppeared {
    return self.displayRecorder.controlLayerAppearedState;
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlLayerAppearStateChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setControlLayerAppearStateChanged:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlLayerAppearStateChanged {
    objc_setAssociatedObject(self, @selector(controlLayerAppearStateChanged), controlLayerAppearStateChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)controlLayerNeedAppear {
    [self.displayRecorder layerAppear];
}
- (void)controlLayerNeedDisappear {
    [self.displayRecorder layerDisappear];
}

- (void)setControlViewDisplayStatus:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlViewDisplayStatus {
    self.controlLayerAppearStateChanged = controlViewDisplayStatus;
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlViewDisplayStatus {
    return self.controlLayerAppearStateChanged;
}

- (BOOL)controlViewDisplayed {
    return self.controlLayerAppeared;
}

@end


#pragma mark - 屏幕旋转

@implementation SJBaseVideoPlayer (Rotation)

- (void)setSupportedRotateViewOrientation:(SJSupportedRotateViewOrientation)supportedRotateViewOrientation {
    self.orentationObserver.supportedRotateViewOrientation = supportedRotateViewOrientation;
}

- (SJSupportedRotateViewOrientation)supportedRotateViewOrientation {
    return self.orentationObserver.supportedRotateViewOrientation;
}

- (void)setRotateOrientation:(SJRotateViewOrientation)rotateOrientation {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.orentationObserver.rotateOrientation = rotateOrientation;
    });

}

- (SJRotateViewOrientation)rotateOrientation {
    return self.orentationObserver.rotateOrientation;
}

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

- (void)setWillRotateScreen:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))willRotateScreen {
    objc_setAssociatedObject(self, @selector(willRotateScreen), willRotateScreen, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))willRotateScreen {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRotatedScreen:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))rotatedScreen {
    objc_setAssociatedObject(self, @selector(rotatedScreen), rotatedScreen, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))rotatedScreen {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)isFullScreen {
    return self.orentationObserver.isFullScreen;
}

@end


#pragma mark - 截图

@implementation SJBaseVideoPlayer (Screenshot)

- (void)setPresentationSize:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull, CGSize))presentationSize {
    objc_setAssociatedObject(self, @selector(presentationSize), presentationSize, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull, CGSize))presentationSize {
    return objc_getAssociatedObject(self, _cmd);
}

- (UIImage * __nullable)screenshot {
    return [self.asset screenshot];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block {
    [self screenshotWithTime:time size:CGSizeZero completion:block];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block {
    [self.asset screenshotWithTime:time size:size completion:^(SJVideoPlayerAssetCarrier * _Nonnull asset, SJVideoPreviewModel * _Nullable images, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( block ) block(self, images.image, error);
        });
    }];
}

- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(__kindof SJBaseVideoPlayer *player, NSArray<id<SJVideoPlayerPreviewInfo>> *__nullable images, NSError *__nullable error))block {
    itemSize = CGSizeMake(ceil(itemSize.width), ceil(itemSize.height));
    __weak typeof(self) _self = self;
    [self.asset generatedPreviewImagesWithMaxItemSize:itemSize completion:^(SJVideoPlayerAssetCarrier * _Nonnull asset, NSArray<SJVideoPreviewModel *> * _Nullable images, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self, (id)images, error);
    }];
}

@end


#pragma mark - 在`tableView`或`collectionView`上播放

@implementation SJBaseVideoPlayer (ScrollView)

- (BOOL)playOnCell {
    return self.asset.indexPath ? YES : NO;
}

@end


#pragma mark - 提示

@implementation SJBaseVideoPlayer (Prompt)

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
@interface _SJBaseVideoPlayerControlDisplayRecorder ()
@property (nonatomic, weak, readonly) SJBaseVideoPlayer *videoPlayer;
@property (nonatomic, strong, readonly) SJTimerControl *controlHiddenTimer;
@property (nonatomic, readwrite) BOOL controlLayerAppearedState;
@end
NS_ASSUME_NONNULL_END

@implementation _SJBaseVideoPlayerControlDisplayRecorder
@synthesize controlHiddenTimer = _controlHiddenTimer;

- (instancetype)initWithVideoPlayer:(SJBaseVideoPlayer *)videoPlayer {
    self = [super init];
    if ( !self ) return nil;
    _videoPlayer = videoPlayer;
    [_videoPlayer sj_addObserver:self forKeyPath:@"state"];
    [_videoPlayer sj_addObserver:self forKeyPath:@"locked"];
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( [keyPath isEqualToString:@"state"] ) {
        if      ( SJVideoPlayerPlayState_Paused == self.videoPlayer.state ||
                 SJVideoPlayerPlayState_PlayEnd == self.videoPlayer.state ) {
            [self _keepDisplay];
        }
        else if ( SJVideoPlayerPlayState_Playing == self.videoPlayer.state &&
                 self.controlLayerAppearedState ) {
            [self layerAppear];
        }
    }
    else if ( [keyPath isEqualToString:@"locked"] ) {
        if ( _videoPlayer.isLockedScreen ) {
            [self.controlHiddenTimer clear];
        }
        else {
            [self.controlHiddenTimer start];
        }
    }
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if ( enabled ) [_controlHiddenTimer start];
    else [_controlHiddenTimer clear];
}

- (void)considerDisplay {
    if ( self.controlLayerAppearedState ) [self layerDisappear];
    else [self layerAppear];
}

- (void)layerAppear {
    if ( !self.isEnabled ) return;
    [self clear];
    if ( !self.videoPlayer.controlLayerDataSource ) return;
    [self.controlHiddenTimer start];
    [self _callDelegateMethodWithStatus:YES];
    self.controlLayerAppearedState = YES;
    if ( self.videoPlayer.controlLayerAppearStateChanged ) self.videoPlayer.controlLayerAppearStateChanged(self.videoPlayer, YES);
}

- (void)_keepDisplay {
    if ( !self.isEnabled ) return;
    [self layerAppear];                      // 显示
    [self.controlHiddenTimer clear];         // 清除timer, 使其一直显示
}

- (void)layerDisappear {
    if ( !self.isEnabled ) return;
    if ( !self.videoPlayer.controlLayerDataSource ) return;
    [self.controlHiddenTimer clear];
    [self _callDelegateMethodWithStatus:NO];
    self.controlLayerAppearedState = NO;
    if ( self.videoPlayer.controlLayerAppearStateChanged ) self.videoPlayer.controlLayerAppearStateChanged(self.videoPlayer, NO);
}

- (void)clear {
    [_controlHiddenTimer clear];
}

- (SJTimerControl *)controlHiddenTimer {
    if ( _controlHiddenTimer ) return _controlHiddenTimer;
    _controlHiddenTimer = [[SJTimerControl alloc] init];
    __weak typeof(self) _self = self;
    _controlHiddenTimer.exeBlock = ^(SJTimerControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        // 如果控制层显示, 当达到隐藏的条件, `timer`将控制层隐藏. 否则, 清除`timer`.
        if ( self.controlLayerAppearedState &&
            self.videoPlayer.controlLayerDataSource.controlLayerDisappearCondition )
            [self layerDisappear];
        else [control clear];
    };
    return _controlHiddenTimer;
}

#pragma mark -
- (void)_callDelegateMethodWithStatus:(BOOL)status {
    if      ( status && [self.videoPlayer.controlLayerDelegate respondsToSelector:@selector(controlLayerNeedAppear:)] ) {
        [self.videoPlayer.controlLayerDelegate controlLayerNeedAppear:self.videoPlayer];
    }
    else if ( !status && [self.videoPlayer.controlLayerDelegate respondsToSelector:@selector(controlLayerNeedDisappear:)] ) {
        [self.videoPlayer.controlLayerDelegate controlLayerNeedDisappear:self.videoPlayer];
    }
}

@end
