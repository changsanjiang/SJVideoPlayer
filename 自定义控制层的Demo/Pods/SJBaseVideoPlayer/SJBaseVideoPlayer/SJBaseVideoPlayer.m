//
//  SJBaseVideoPlayer.m
//  SJBaseVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//
//  GitHub:     https://github.com/changsanjiang/SJBaseVideoPlayer
//
//  Contact:    changsanjiang@gmail.com
//
//  QQGroup:    719616775
//

#import "SJBaseVideoPlayer.h"
#import <Masonry/Masonry.h>
#import "SJRotationManager.h"
#import "SJPlayerGestureControl.h"
#import "SJVolBrigControl.h"
#import "UIView+SJVideoPlayerAdd.h"
#import <objc/message.h>
#import <SJObserverHelper/NSObject+SJObserverHelper.h>
#import "SJVideoPlayerRegistrar.h"
#import "SJVideoPlayerPresentView.h"
#import "SJPlayModelPropertiesObserver.h"
#import "SJPlayAsset+SJBaseVideoPlayerAdd.h"
#import "SJBaseVideoPlayer+PlayStatus.h"
#import "SJTimerControl.h"
#import <Reachability/Reachability.h>
#import "UIScrollView+ListViewAutoplaySJAdd.h"

NS_ASSUME_NONNULL_BEGIN

/**
 管理类: 控制层显示与隐藏
 */
@interface _SJControlLayerAppearStateManager : NSObject

/**
 初始化构造方法
 */
- (instancetype)initWithVideoPlayer:(SJBaseVideoPlayer *)videoPlayer;

/**
 是否开启管理类去管理控制层的显示与隐藏. 见 `videoPlayer.enableControlLayerDisplayController`
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

/**
 控制层的显示状态. YES -> appear, NO -> disappear.
 */
@property (nonatomic, readonly) BOOL controlLayerAppearedState;
- (void)setControlLayerAppearedState:(BOOL)controlLayerAppearedState;

/**
 在视频第一次播放之前, 控制层会默认在1秒后显示. 如果在这1秒期间, 用户点击触发显示控制层, 则这个值为YES. 否则1秒显示控制层后, 才会设置这个值为YES.
 这个属性用于是否1秒后显示控制层.
 */
@property (nonatomic, readonly) BOOL initialization;

/**
 重置`self.initialization`, 当播放新的资源时, 该方法会被调用.
 */
- (void)resetInitialization;

/**
 当单击手势触发时, 会调用这个方法. 考虑是否显示或隐藏控制层, 或不做任何事情.
 */
- (void)considerChangeState;

/**
 在`self.enabled == YES`的情况下, 立即显示控制层.
 */
- (void)layerAppear;

/**
 在`self.enabled == YES`的情况下, 立即隐藏控制层.
 */
- (void)layerDisappear;

/**
 当播放被暂停时, 是否保持控制层一直显示.  见 `videoPlayer.pausedToKeepAppearState`.
 */
@property (nonatomic) BOOL pausedToKeepAppearState;

/**
 当播放失败时, 是否保持控制层一直显示. 见 `videoPlayer.playFailedToKeepAppearState`
 */
@property (nonatomic) BOOL playFailedToKeepAppearState;

- (void)start;

@end

/**
 管理类: 监测 网络状态
 */
@interface _SJReachabilityObserver : NSObject

/**
 网络状态只需一个监测对象即可, 所以将其作为单例使用.
 */
+ (instancetype)sharedInstance;

/**
 当前的网络状态.
 */
@property (nonatomic, assign, readonly) SJNetworkStatus networkStatus;

/**
 当网络状态变更时, 将会调用这个Block.
 */
@property (nonatomic, copy, nullable) void(^reachabilityChangedExeBlock)(_SJReachabilityObserver *observer, SJNetworkStatus status);
@end

/**
 Base Video Player
 */
@interface SJBaseVideoPlayer ()<SJRotationManagerDelegate>
/**
 当前播放器播放视频的状态
 */
@property (nonatomic) SJVideoPlayerPlayState state __deprecated_msg("已弃用, 请使用`playStatus`");

@property (nonatomic, copy, nullable) void(^operationOfInitializing)(SJBaseVideoPlayer *player);

/**
 当前播放如果出错, 可以查看这个error
 */
@property (nonatomic, strong, nullable) NSError *error;

/**
 当用户触摸到TableView或者ScrollView时, 这个值为YES.
 这个值用于旋转的条件之一, 如果用户触摸在TableView或者ScrollView上时, 将不会自动旋转.
 */
@property (nonatomic) BOOL touchedScrollView; // 如果为`YES`, 则不旋转

/**
 管理对象: 监听 App在前台, 后台, 耳机插拔, 来电等的通知
 */
@property (nonatomic, strong, readonly) SJVideoPlayerRegistrar *registrar;

/**
 控制层的父视图
 */
@property (nonatomic, strong, readonly) UIView *controlContentView;

/**
 视频画面的呈现层
 */
@property (nonatomic, strong, readonly) SJVideoPlayerPresentView *presentView;

/**
 管理对象: 指定旋转及管理视图的自动旋转
 */
@property (nonatomic, strong, readonly) SJRotationManager *rotationManager;

/**
 管理对象: 单击+双击+上下左右移动+捏合手势
 */
@property (nonatomic, strong, readonly) SJPlayerGestureControl *gestureControl;

/**
 管理对象: 音量+声音
 */
@property (nonatomic, strong, readonly) SJVolBrigControl *volBrigControl;

/**
 管理对象: 控制层的显示与隐藏
 */
@property (nonatomic, strong, readonly) _SJControlLayerAppearStateManager *displayRecorder;

/**
 管理对象: 网络状态监测
 */
@property (nonatomic, strong, readonly) _SJReachabilityObserver *reachabilityObserver;

/**
 锁屏状态下触发的手势.
 当播放器被锁屏时, 用户单击后, 会触发这个手势, 调用`controlLayerDelegate`的方法: `tappedPlayerOnTheLockedState:`
 */
@property (nonatomic, strong, readonly) UITapGestureRecognizer *lockStateTapGesture;

@property (nonatomic, strong, nullable) SJPlayAssetPropertiesObserver *playAssetObserver;
@property (nonatomic, strong, nullable) SJPlayModelPropertiesObserver *playModelObserver;

@property (nonatomic) SJVideoPlayerPlayStatus playStatus;
@property (nonatomic) SJVideoPlayerPausedReason pausedReason;
@property (nonatomic) SJVideoPlayerInactivityReason inactivityReason;

@end

@implementation SJBaseVideoPlayer {
    UIView *_view;
    SJVideoPlayerPresentView *_presentView;
    UIView *_controlContentView;
    SJRotationManager *_rotationManager;
    SJPlayerGestureControl *_gestureControl;
    SJVolBrigControl *_volBrigControl;
    _SJControlLayerAppearStateManager *_displayRecorder;
    SJVideoPlayerRegistrar *_registrar;
    _SJReachabilityObserver *_reachabilityObserver;
    UITapGestureRecognizer *_lockStateTapGesture;
    SJVideoPlayerURLAsset *_URLAsset;
    CGFloat _rate;
    SJVideoPlayerPlayStatus _playStatus;
    SJVideoPlayerPausedReason _pausedReason;
    SJVideoPlayerInactivityReason _inactivityReason;
}

+ (instancetype)player {
    return [[self alloc] init];
}

+ (NSString *)version {
    return @"1.3.0";
}

- (nullable __kindof UIViewController *)atViewController {
    if ( _view.superview == nil ) return nil;
    UIResponder *responder = _view.nextResponder;
    while ( ![responder isKindOfClass:[UIViewController class]] ) {
        responder = responder.nextResponder;
        if ( [responder isMemberOfClass:[UIResponder class]] || !responder ) return nil;
    }
    return (UIViewController *)responder;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    NSError *error = nil;
    // 使播放器在静音状态下也能放出声音
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if ( error ) NSLog(@"%@", error.userInfo);
    self.rate = 1;
    self.autoPlay = YES; // 是否自动播放, 默认yes
    self.pauseWhenAppDidEnterBackground = YES; // App进入后台是否暂停播放, 默认yes
    self.enableControlLayerDisplayController = YES; // 是否启用控制层管理器, 默认yes
    self.playFailedToKeepAppearState = YES; // 播放失败是否保持控制层显示, 默认yes
    [self registrar];
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"SJVideoPlayerLog: %d - %s", (int)__LINE__, __func__);
#endif
    [_URLAsset.playAsset cancelOperation];
    if ( _URLAsset && self.assetDeallocExeBlock ) self.assetDeallocExeBlock(self);
    [_presentView removeFromSuperview];
}

- (void)setPlayStatus:(SJVideoPlayerPlayStatus)playStatus {
    /// 所有播放状态, 均在`PlayControl`分类中维护
    /// 所有播放状态, 均在`PlayControl`分类中维护
    _playStatus = playStatus;
    
    if ( [self playStatus_isUnknown] || [self playStatus_isPrepare] ) {
        [self.presentView showPlaceholder];
    }
    else if ( [self playStatus_isReadyToPlay] ) {
        [self.presentView hiddenPlaceholder];
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    switch ( playStatus ) {
        case SJVideoPlayerPlayStatusUnknown:
            self.state = SJVideoPlayerPlayState_Unknown;
            break;
        case SJVideoPlayerPlayStatusPrepare:
        case SJVideoPlayerPlayStatusReadyToPlay:
            self.state = SJVideoPlayerPlayState_Prepare;
            break;
        case SJVideoPlayerPlayStatusPlaying:
            self.state = SJVideoPlayerPlayState_Playing;
            break;
        case SJVideoPlayerPlayStatusPaused: {
            switch ( self.pausedReason ) {
                case SJVideoPlayerPausedReasonBuffering:
                    self.state = SJVideoPlayerPlayState_Buffing;
                    break;
                case SJVideoPlayerPausedReasonPause:
                    self.state = SJVideoPlayerPlayState_Paused;
                    break;
                case SJVideoPlayerPausedReasonSeeking:
                    self.state = SJVideoPlayerPlayState_Buffing;
                    break;
            }
        }
            break;
        case SJVideoPlayerPlayStatusInactivity:
            switch ( self.inactivityReason ) {
                case SJVideoPlayerInactivityReasonPlayEnd:
                    self.state = SJVideoPlayerPlayState_PlayEnd;
                    break;
                case SJVideoPlayerInactivityReasonPlayFailed:
                    self.state = SJVideoPlayerPlayState_PlayFailed;
                    break;
            }
            break;
    }
#pragma clang diagnostic pop
    
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:statusDidChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self statusDidChanged:playStatus];
    }
    
    
#ifdef DEBUG
    switch ( playStatus ) {
        case SJVideoPlayerPlayStatusUnknown:
            printf("SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Unknown\n", self);
            break;
        case SJVideoPlayerPlayStatusPrepare:
            printf("SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Prepare\n", self);
            break;
        case SJVideoPlayerPlayStatusReadyToPlay:
            printf("SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.ReadyToPlay\n", self);
            break;
        case SJVideoPlayerPlayStatusPlaying:
            printf("SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Playing\n", self);
            break;
        case SJVideoPlayerPlayStatusPaused: {
            switch ( self.pausedReason ) {
                case SJVideoPlayerPausedReasonBuffering:
                    printf("SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Paused(Reason: Buffering)\n", self);
                    break;
                case SJVideoPlayerPausedReasonPause:
                    printf("SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Paused(Reason: Pause)\n", self);
                    break;
                case SJVideoPlayerPausedReasonSeeking:
                    printf("SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Paused(Reason: Seeking)\n", self);
                    break;
            }
        }
            break;
        case SJVideoPlayerPlayStatusInactivity: {
            switch ( self.inactivityReason ) {
                case SJVideoPlayerInactivityReasonPlayEnd :
                    printf("SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Inactivity(Reason: PlayEnd)\n", self);
                    break;
                case SJVideoPlayerInactivityReasonPlayFailed:
                    printf("SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Inactivity(Reason: PlayFailed)\n", self);
                    break;
            }
        }
            break;
    }
#endif
}


- (void)setControlLayerDataSource:(nullable id<SJVideoPlayerControlLayerDataSource>)controlLayerDataSource {
    if ( controlLayerDataSource == _controlLayerDataSource ) return;
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

- (void)setControlLayerDelegate:(nullable id<SJVideoPlayerControlLayerDelegate>)controlLayerDelegate {
    if ( controlLayerDelegate == _controlLayerDelegate ) return;
    _controlLayerDelegate = controlLayerDelegate;
    
    if ( [controlLayerDelegate respondsToSelector:@selector(videoPlayer:volumeChanged:)] ) {
        [controlLayerDelegate videoPlayer:self volumeChanged:_volBrigControl.volume];
    }
    
    if ( [controlLayerDelegate respondsToSelector:@selector(videoPlayer:brightnessChanged:)] ) {
        [controlLayerDelegate videoPlayer:self brightnessChanged:_volBrigControl.brightness];
    }
}

- (void)setPlaceholder:(nullable UIImage *)placeholder {
    self.presentView.placeholder = placeholder;
}

- (nullable UIImage *)placeholder {
    return self.presentView.placeholder;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    self.presentView.videoGravity = videoGravity;
}

- (AVLayerVideoGravity)videoGravity {
    if ( _presentView ) return _presentView.videoGravity;
    return AVLayerVideoGravityResizeAspect;
}

#pragma mark -
- (UIView *)view {
    if ( _view ) return _view;
    _view = [UIView new];
    _view.backgroundColor = [UIColor blackColor];
    [_view addSubview:self.presentView];
    [_presentView addSubview:self.controlContentView];
    _presentView.autoresizingMask = _controlContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self rotationManager];
    [self gestureControl];
    [self reachabilityObserver];
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
- (SJRotationManager *)rotationManager {
    if ( _rotationManager ) return _rotationManager;
    __weak typeof(self) _self = self;
    _rotationManager = [[SJRotationManager alloc] initWithTarget:self.presentView superview:self.view rotationCondition:^BOOL(SJRotationManager * _Nonnull observer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        if ( !self.view.superview ) return NO;
        if ( self.touchedScrollView ) return NO;
        if ( self.isPlayOnScrollView && !self.isScrollAppeared ) return NO;
        if ( self.disableAutoRotation ) return NO;
        if ( self.isLockedScreen ) return NO;
        if ( self.registrar.state == SJVideoPlayerAppState_ResignActive ) return NO;
        return YES;
    }];
    _rotationManager.delegate = self;
    return _rotationManager;
}
- (void)rotationManager:(SJRotationManager *)manager willRotateView:(BOOL)isFullscreen {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:willRotateView:)] ) {
        [self.controlLayerDelegate videoPlayer:self willRotateView:isFullscreen];
    }
    if ( self.viewWillRotateExeBlock ) {
        self.viewWillRotateExeBlock(self, isFullscreen);
    }
    else {
        [UIView animateWithDuration:0.25 animations:^{
            [[self atViewController] setNeedsStatusBarAppearanceUpdate];
        }];
    }
}
- (void)rotationManager:(SJRotationManager *)manager didRotateView:(BOOL)isFullscreen {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:didEndRotation:)] ) {
        [self.controlLayerDelegate videoPlayer:self didEndRotation:isFullscreen];
    }
    if ( self.viewDidRotateExeBlock ) self.viewDidRotateExeBlock(self, manager.isFullscreen);
}
- (SJPlayerGestureControl *)gestureControl {
    if ( _gestureControl ) return _gestureControl;
    _gestureControl = [[SJPlayerGestureControl alloc] initWithTargetView:self.controlContentView];
    __weak typeof(self) _self = self;
    _gestureControl.triggerCondition = ^BOOL(SJPlayerGestureControl * _Nonnull control, SJPlayerGestureType type, UIGestureRecognizer * _Nonnull gesture) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        
        if ( self.isLockedScreen ) return NO;
        
        SJDisablePlayerGestureTypes disableTypes = self.disableGestureTypes;
        if ( SJDisablePlayerGestureTypes_All == (disableTypes & SJDisablePlayerGestureTypes_All)  ) {
            disableTypes = SJDisablePlayerGestureTypes_Pan | SJDisablePlayerGestureTypes_Pinch | SJDisablePlayerGestureTypes_DoubleTap | SJDisablePlayerGestureTypes_SingleTap;
        }
        
        switch (type) {
            case SJPlayerGestureType_Unknown: break;
            case SJPlayerGestureType_Pan: {
                if ( SJDisablePlayerGestureTypes_Pan == (disableTypes & SJDisablePlayerGestureTypes_Pan ) ) {
                    return NO;
                }
            }
                break;
                
            case SJPlayerGestureType_Pinch: {
                if ( SJDisablePlayerGestureTypes_Pinch == (disableTypes & SJDisablePlayerGestureTypes_Pinch ) ) {
                    return NO;
                }
            }
                break;
            case SJPlayerGestureType_DoubleTap: {
                if ( SJDisablePlayerGestureTypes_DoubleTap == (disableTypes & SJDisablePlayerGestureTypes_DoubleTap) ) {
                    return NO;
                }
            }
                break;
            case SJPlayerGestureType_SingleTap: {
                if ( SJDisablePlayerGestureTypes_SingleTap == (disableTypes & SJDisablePlayerGestureTypes_SingleTap ) ) {
                    return NO;
                }
            }
                break;
        }
        
        if ( [self playStatus_isUnknown] ) return NO;
        if ( [self playStatus_isInactivity_ReasonPlayFailed] ) return NO;
        
        if ( SJPlayerGestureType_Pan == type &&
            self.isPlayOnScrollView &&
            !self.rotationManager.isFullscreen ) return NO;
        
        if ( self.controlLayerDataSource &&
            ![self.controlLayerDataSource triggerGesturesCondition:[gesture locationInView:gesture.view]] ) return NO;
        
        if ( type == SJPlayerGestureType_Pan ) {
            switch ( control.panLocation ) {
                case SJPanLocation_Unknown: break;
                case SJPanLocation_Left: {
                    if ( self.disableBrightnessSetting ) return NO;
                }
                    break;
                case SJPanLocation_Right: {
                    if ( self.disableVolumeSetting ) return NO;
                }
                    break;
            }
        }
        return YES;
    };
    
    _gestureControl.singleTapped = ^(SJPlayerGestureControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.displayRecorder considerChangeState];
    };
    
    _gestureControl.doubleTapped = ^(SJPlayerGestureControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self playStatus_isPaused] || [self playStatus_isInactivity_ReasonPlayEnd] ) [self play];
        else [self pause];
    };
    
    static CGFloat __increment;
    static NSTimeInterval __currentTime;
    static NSTimeInterval __totalTime;
    _gestureControl.beganPan = ^(SJPlayerGestureControl * _Nonnull control, SJPanDirection direction, SJPanLocation location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch (direction) {
            case SJPanDirection_H: {
                __increment = 0;
                __currentTime = self.currentTime;
                __totalTime = self.totalTime;
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
                if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:horizontalDirectionDidMove:)] ) {
                    float add = 0;
                    if ( __totalTime > 60 * 2 ) add = translate.x;
                    else add = translate.x * 0.1;
                    __increment += add;
                    CGFloat progress = (__currentTime + __increment) / __totalTime;
                    [self.controlLayerDelegate videoPlayer:self horizontalDirectionDidMove:progress];
                }
                else if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:horizontalDirectionDidDrag:)] ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [self.controlLayerDelegate videoPlayer:self horizontalDirectionDidDrag:translate.x * 0.003];
#pragma clang diagnostic pop
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
- (_SJControlLayerAppearStateManager *)displayRecorder {
    if ( _displayRecorder ) return _displayRecorder;
    _displayRecorder = [[_SJControlLayerAppearStateManager alloc] initWithVideoPlayer:self];
    return _displayRecorder;
}
- (SJVideoPlayerRegistrar *)registrar {
    if ( _registrar ) return _registrar;
    _registrar = [SJVideoPlayerRegistrar new];
    
    /**
     关于后台播放视频, 引用自: https://juejin.im/post/5a38e1a0f265da4327185a26
     
     当您想在后台播放视频时:
     1. 需要设置 videoPlayer.pauseWhenAppDidEnterBackground = NO; 该值默认为YES, 即App进入后台默认暂停.
     2. 前往 `TARGETS` -> `Capability` -> enable `Background Modes` -> select this mode `Audio, AirPlay, and Picture in Picture`
     */
    __weak typeof(self) _self = self;
    _registrar.willResignActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(appWillResignActive:)] ) {
            [self.controlLayerDelegate appWillResignActive:self];
        }
    };
    
    _registrar.didBecomeActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(appDidBecomeActive:)] ) {
            [self.controlLayerDelegate appDidBecomeActive:self];
        }
    };
    
    _registrar.willEnterForeground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        
        self.presentView.player = self.URLAsset.playAsset.player;
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(appWillEnterForeground:)] ) {
            [self.controlLayerDelegate appWillEnterForeground:self];
        }
    };
    
    _registrar.didEnterBackground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        
        if ( self.pauseWhenAppDidEnterBackground ) {
            [self pause];
        }
        else {
            self.presentView.player = nil;
        }
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(appDidEnterBackground:)] ) {
            [self.controlLayerDelegate appDidEnterBackground:self];
        }
    };
    
    _registrar.oldDeviceUnavailable = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( ![self playStatus_isPaused_ReasonPause] ) [self play];
    };
    
    //    _registrar.categoryChange = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
    //        __strong typeof(_self) self = _self;
    //        if ( !self ) return;
    //
    //    };
    
    _registrar.audioSessionInterruption = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( ![self playStatus_isPaused_ReasonPause] ) [self pause];
    };
    return _registrar;
}

- (_SJReachabilityObserver *)reachabilityObserver {
    if ( _reachabilityObserver ) return _reachabilityObserver;
    _reachabilityObserver = [_SJReachabilityObserver sharedInstance];
    __weak typeof(self) _self = self;
    _reachabilityObserver.reachabilityChangedExeBlock = ^(_SJReachabilityObserver * _Nonnull observer, SJNetworkStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:reachabilityChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self reachabilityChanged:status];
        }
#if 0
        switch (status) {
            case SJNetworkStatus_NotReachable: {
                NSLog(@"网络状态: 无法连接网络");
            }
                break;
            case SJNetworkStatus_ReachableViaWiFi: {
                NSLog(@"网络状态: WiFi");
            }
                break;
            case SJNetworkStatus_ReachableViaWWAN: {
                NSLog(@"网络状态: WWAN");
            }
                break;
        }
#endif
    };
    return _reachabilityObserver;
}

- (void)setState:(SJVideoPlayerPlayState)state {
    if ( state == _state ) return;
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
    
    if ( state == SJVideoPlayerPlayState_Paused && self.pausedToKeepAppearState && self.registrar.state == SJVideoPlayerAppState_Forground ) [self.displayRecorder layerAppear];
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:stateChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self stateChanged:state];
    }
}

- (UITapGestureRecognizer *)lockStateTapGesture {
    if ( _lockStateTapGesture ) return _lockStateTapGesture;
    _lockStateTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLockStateTapGesture:)];
    return _lockStateTapGesture;
}

- (void)handleLockStateTapGesture:(UITapGestureRecognizer *)tap {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(tappedPlayerOnTheLockedState:)] ) {
        [self.controlLayerDelegate tappedPlayerOnTheLockedState:self];
    }
}
@end

#pragma mark - Network

@implementation SJBaseVideoPlayer (Network)

- (SJNetworkStatus)networkStatus {
    return self.reachabilityObserver.networkStatus;
}

@end



#pragma mark - 控制
@implementation SJBaseVideoPlayer (PlayControl)
// 1.
- (void)setURLAsset:(nullable SJVideoPlayerURLAsset *)URLAsset {
    if ( self.URLAsset ) {
        if ( self.assetDeallocExeBlock ) self.assetDeallocExeBlock(self);
    }
    
    [_URLAsset.playAsset.player pause];
    _playAssetObserver = nil;
    _playModelObserver = nil;
    
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( !URLAsset ) {
            self.playStatus = SJVideoPlayerPlayStatusUnknown;
        }
        else {
            self.playStatus = SJVideoPlayerPlayStatusPrepare;
            if ( [self.controlLayerDelegate respondsToSelector:@selector(startLoading:)] ) {
                [self.controlLayerDelegate startLoading:self];
            }
            
            self.playAssetObserver = [[SJPlayAssetPropertiesObserver alloc] initWithPlayerAsset:URLAsset.playAsset];
            self.playAssetObserver.delegate = (id)self;
            self.playModelObserver = [[SJPlayModelPropertiesObserver alloc] initWithPlayModel:URLAsset.playModel];
            self.playModelObserver.delegate = (id)self;
            
            if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:prepareToPlay:)] ) {
                [self.controlLayerDelegate videoPlayer:self prepareToPlay:URLAsset];
            }
        }
    });
    
    _URLAsset = URLAsset;
    
    if ( [URLAsset.playModel isKindOfClass:[SJUITableViewCellPlayModel class]] ) {
        SJUITableViewCellPlayModel *playModel = (id)URLAsset.playModel;
        if ( playModel.tableView.sj_enabledAutoplay ) {
            playModel.tableView.sj_currentPlayingIndexPath = playModel.indexPath;
        }
    }
    else if ( [URLAsset.playModel isKindOfClass:[SJUICollectionViewCellPlayModel class]] ) {
        SJUICollectionViewCellPlayModel *playModel = (id)URLAsset.playModel;
        if ( playModel.collectionView.sj_enabledAutoplay ) {
            playModel.collectionView.sj_currentPlayingIndexPath = playModel.indexPath;
        }
    }
}

- (nullable SJVideoPlayerURLAsset *)URLAsset {
    return _URLAsset;
}

// 2.1
- (void)_playerItemReadyToPlay {
    
    if ( ![self playStatus_isPrepare] ) return;
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:currentTime:currentTimeStr:totalTime:totalTimeStr:)] ) {
        [self.controlLayerDelegate videoPlayer:self currentTime:self.currentTime currentTimeStr:self.currentTimeStr totalTime:self.totalTime totalTimeStr:self.totalTimeStr];
    }
    
    __weak typeof(self) _self = self;
    void(^block)(void) = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( [self.controlLayerDelegate respondsToSelector:@selector(loadCompletion:)] ) {
                [self.controlLayerDelegate loadCompletion:self];
            }
            
            self.playStatus = SJVideoPlayerPlayStatusReadyToPlay;
            
            self.URLAsset.playAsset.player.muted = self.mute;
            
            if ( self.registrar.state == SJVideoPlayerAppState_Background &&
                self.pauseWhenAppDidEnterBackground ) {
                [self pause:SJVideoPlayerPausedReasonPause];
                return;
            }
            
            if ( self.operationOfInitializing ) {
                self.operationOfInitializing(self);
                self.operationOfInitializing = nil;
            }
            else if ( self.autoPlay ) {
                if ( self.isPlayOnScrollView ) {
                    if ( self.isScrollAppeared ) [self play];
                    else [self pause];
                }
                else {
                    [self play];
                }
            }
            
            if ( !self.isLockedScreen ) [self.displayRecorder resetInitialization];
        });
    };
    
    if ( !self.URLAsset.playAsset.isOtherAsset && 0 != self.URLAsset.playAsset.specifyStartTime ) {
        [self seekToTime:self.URLAsset.playAsset.specifyStartTime completionHandler:^(BOOL finished) {
            block();
        }];
    }
    else {
        block();
    }
}

// 2.2
- (void)_playerItemPlayFailed {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(cancelLoading:)] ) {
        [self.controlLayerDelegate cancelLoading:self];
    }
    
    self.error = _URLAsset.playAsset.playerItem.error;
    self.inactivityReason = SJVideoPlayerInactivityReasonPlayFailed;
    self.playStatus = SJVideoPlayerPlayStatusInactivity;
}

- (void)_playDidToEnd {

    if ( !self.vc_isDisappeared ) {
        SJVideoPlayerURLAsset *URLAsset = self.URLAsset;
        if ( [URLAsset.playModel isKindOfClass:[SJUITableViewCellPlayModel class]] ) {
            SJUITableViewCellPlayModel *playModel = (id)URLAsset.playModel;
            if ( playModel.tableView.sj_enabledAutoplay ) {
                [playModel.tableView sj_needPlayNextAsset];
                return;
            }
        }
        else if ( [URLAsset.playModel isKindOfClass:[SJUICollectionViewCellPlayModel class]] ) {
            SJUICollectionViewCellPlayModel *playModel = (id)URLAsset.playModel;
            if ( playModel.collectionView.sj_enabledAutoplay ) {
                [playModel.collectionView sj_needPlayNextAsset];
                return;
            }
        }
    }

    self.inactivityReason = SJVideoPlayerInactivityReasonPlayEnd;
    self.playStatus = SJVideoPlayerPlayStatusInactivity;
    if ( self.playDidToEndExeBlock ) self.playDidToEndExeBlock(self);
}

//- (void)_paused

- (void)refresh {
    if ( !self.URLAsset ) return;
    [self replay];
}

- (void)setAssetDeallocExeBlock:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))assetDeallocExeBlock {
    objc_setAssociatedObject(self, @selector(assetDeallocExeBlock), assetDeallocExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))assetDeallocExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setMute:(BOOL)mute {
    if ( mute == self.mute ) return;
    objc_setAssociatedObject(self, @selector(mute), @(mute), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _URLAsset.playAsset.player.muted = mute;
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:muteChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self muteChanged:mute];
    }
}

- (BOOL)mute {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setLockedScreen:(BOOL)lockedScreen {
    objc_setAssociatedObject(self, @selector(isLockedScreen), @(lockedScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( lockedScreen ) {
        [self.controlLayerDataSource.controlView addGestureRecognizer:self.lockStateTapGesture];
    }
    else {
        [self.controlLayerDataSource.controlView removeGestureRecognizer:self.lockStateTapGesture];
    }
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

- (void)setPauseWhenAppDidEnterBackground:(BOOL)pauseWhenAppDidEnterBackground {
    objc_setAssociatedObject(self, @selector(pauseWhenAppDidEnterBackground), @(pauseWhenAppDidEnterBackground), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)pauseWhenAppDidEnterBackground {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setCanPlayAnAsset:(nullable BOOL (^)(__kindof SJBaseVideoPlayer * _Nonnull))canPlayAnAsset {
    objc_setAssociatedObject(self, @selector(canPlayAnAsset), canPlayAnAsset, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable BOOL (^)(__kindof SJBaseVideoPlayer * _Nonnull))canPlayAnAsset {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)play {
    
    if ( self.canPlayAnAsset ) {
        if ( !self.canPlayAnAsset(self) ) return;
    }

    if ( !self.URLAsset ) return;
    
    if ( [self playStatus_isInactivity_ReasonPlayEnd] ) {
        
        [self replay];
        return;
    }
    
    if ( [self playStatus_isInactivity_ReasonPlayFailed] ) {
        // 尝试重新播放
        [self replay];
        return;
    }
    
    if ( [self playStatus_isPrepare] ) {
        // 记录操作, 待资源初始化完成后调用
        self.operationOfInitializing = ^(SJBaseVideoPlayer * _Nonnull player) {
            [player play];
        };
        return;
    }
    
    [_URLAsset.playAsset.player play];
    
    _URLAsset.playAsset.player.rate = self.rate;
    
    self.playStatus = SJVideoPlayerPlayStatusPlaying;
    
    [self.displayRecorder start];
}

- (void)pause {
    [self pause:SJVideoPlayerPausedReasonPause];
}

- (void)pause:(SJVideoPlayerPausedReason)reason {

    if ( !self.URLAsset ) return;
    
    if ( [self playStatus_isPaused_ReasonPause] ) return;
    
    if ( [self playStatus_isInactivity_ReasonPlayEnd] && reason == SJVideoPlayerPausedReasonPause ) return;
    
    if ( [self playStatus_isInactivity_ReasonPlayFailed] ) return;
    
    if ( [self playStatus_isPrepare] ) {
        
        __weak typeof(self) _self = self;
        self.operationOfInitializing = ^(SJBaseVideoPlayer * _Nonnull player) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            [self pause:reason];
        };
        
        return;
    }
    
    [_URLAsset.playAsset.player pause];
    
    self.pausedReason = reason;
    self.playStatus = SJVideoPlayerPlayStatusPaused;
}

- (void)stop {
    _operationOfInitializing = nil;
    
    if ( !self.URLAsset.playAsset.isOtherAsset ) {
        [self.presentView.player replaceCurrentItemWithPlayerItem:nil];
        self.presentView.player = nil;
    }
    
    self.playAssetObserver = nil;
    self.playModelObserver = nil;
    self.URLAsset = nil;
    
    if ( self.playStatus_isPaused_ReasonBuffering ) {
        if ( [self.controlLayerDelegate respondsToSelector:@selector(cancelLoading:)] ){
            [self.controlLayerDelegate cancelLoading:self];
        }
    }
    
    self.playStatus = SJVideoPlayerPlayStatusUnknown;
}

- (void)stopAndFadeOut {
    [self.view sj_fadeOutAndCompletion:^(UIView *view) {
        [self.view removeFromSuperview];
        [self stop];
    }];
}

- (void)replay {
    if ( !self.URLAsset ) return;
    
    if ( [self playStatus_isInactivity_ReasonPlayFailed] ) {
        SJPlayAsset *playAsset = self.URLAsset.playAsset;
        SJPlayModel *playModel = self.URLAsset.playModel;
        self.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithPlayAsset:[[SJPlayAsset alloc] initWithURL:playAsset.URL specifyStartTime:playAsset.specifyStartTime] playModel:playModel];
        
        return;
    }
    
    [self seekToTime:0 completionHandler:nil];
}

- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    
    if ( self.canPlayAnAsset ) {
        if ( !self.canPlayAnAsset(self) ) return;
    }
    
    if ( isnan(secs) ) { return;}
    
    if ( [self playStatus_isUnknown] ||
        [self playStatus_isInactivity_ReasonPlayFailed] ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    if ( _URLAsset.playAsset.playerItem.status != AVPlayerItemStatusReadyToPlay ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    if ( secs > self.playAssetObserver.duration || secs < 0 ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    NSTimeInterval current = floor(self.playAssetObserver.currentTime);
    NSTimeInterval seek = floor(secs);
    
    if ( current == seek ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    if ( [self playStatus_isPaused_ReasonSeeking] ) {
        [_URLAsset.playAsset.playerItem cancelPendingSeeks];
    }
    else {
        if ( ![self playStatus_isPrepare] ) [self pause:SJVideoPlayerPausedReasonSeeking];
    }
    
    __weak typeof(self) _self = self;
    [_URLAsset.playAsset.playerItem seekToTime:CMTimeMakeWithSeconds(secs, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self playStatus_isPaused_ReasonSeeking] ) [self play];
        if ( completionHandler ) completionHandler(finished);
        if ( self.playTimeDidChangeExeBlok ) self.playTimeDidChangeExeBlok(self);
    }];
}

- (void)setVolume:(float)volume {
    if ( self.disableVolumeSetting ) return;
    self.volBrigControl.volume = volume;
}

- (float)volume {
    return self.volBrigControl.volume;
}

- (void)setDisableVolumeSetting:(BOOL)disableVolumeSetting {
    objc_setAssociatedObject(self, @selector(disableVolumeSetting), @(disableVolumeSetting), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableVolumeSetting {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setBrightness:(float)brightness {
    if ( self.disableBrightnessSetting ) return;
    self.volBrigControl.brightness = brightness;
}

- (float)brightness {
    return self.volBrigControl.brightness;
}

- (void)setDisableBrightnessSetting:(BOOL)disableBrightnessSetting {
    objc_setAssociatedObject(self, @selector(disableBrightnessSetting), @(disableBrightnessSetting), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableBrightnessSetting {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setRate:(float)rate {
    if ( _rate == rate ) return;
    _rate = rate;
    if ( _URLAsset.playAsset.player == nil ) return;
    
    _URLAsset.playAsset.player.rate = rate;

    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:rateChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self rateChanged:rate];
    }
    
    if ( self.rateChanged ) self.rateChanged(self);
    
    if ( [self playStatus_isInactivity_ReasonPlayEnd] ) [self replay];
}

- (float)rate {
    return _rate;
}

- (void)setRateChanged:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))rateChanged {
    objc_setAssociatedObject(self, @selector(rateChanged), rateChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))rateChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAssetURL:(nullable NSURL *)assetURL {
    self.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:assetURL];
}

- (nullable NSURL *)assetURL {
    return self.URLAsset.playAsset.URL;
}

- (void)playWithURL:(NSURL *)URL {
    self.assetURL = URL;
}

@end



@implementation SJBaseVideoPlayer (UIViewController)
/// You should call it when view did appear
- (void)vc_viewDidAppear {
    self.disableAutoRotation = NO;
    if ( !self.isPlayOnScrollView || (self.isPlayOnScrollView && self.isScrollAppeared) ) {
        [self play];
    }
    self.vc_isDisappeared = NO;
}
/// You should call it when view will disappear
- (void)vc_viewWillDisappear {
    self.disableAutoRotation = YES;   // 界面将要消失的时候, 禁止旋转.
    self.vc_isDisappeared = YES;
}
- (void)vc_viewDidDisappear {
    if ( ![self playStatus_isPaused_ReasonPause] ) [self pause];
}
- (BOOL)vc_prefersStatusBarHidden {
    // 全屏播放时, 使状态栏根据控制层显示或隐藏
    if ( self.isFullScreen ) return !self.controlLayerAppeared;
    return NO;
}
- (UIStatusBarStyle)vc_preferredStatusBarStyle {
    // 全屏播放时, 使状态栏变成白色
    if ( self.isFullScreen ) return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
}

- (void)setVc_isDisappeared:(BOOL)vc_isDisappeared {
    objc_setAssociatedObject(self, @selector(vc_isDisappeared), @(vc_isDisappeared), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)vc_isDisappeared {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end

#pragma mark - 时间

@implementation SJBaseVideoPlayer (Time)
- (NSString *)timeStringWithSeconds:(NSInteger)secs {
    long min = 60;
    long hour = 60 * min;
    
    long hours, seconds, minutes;
    hours = secs / hour;
    minutes = (secs - hours * hour) / 60;
    seconds = (NSInteger)secs % 60;
    if ( self.totalTime < hour ) {
        return [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
    }
    else {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, seconds];
    }
}

- (float)progress {
    if ( 0 == self.totalTime ) return 0;
    return self.currentTime / self.totalTime;
}

- (float)bufferProgress {
    if ( self.playAssetObserver.duration == 0 ) return 0;
    return self.playAssetObserver.bufferLoadedTime / self.playAssetObserver.duration;
}

- (NSTimeInterval)currentTime {
    return self.playAssetObserver.currentTime;
}

- (NSTimeInterval)totalTime {
    return self.playAssetObserver.duration;
}

- (NSString *)currentTimeStr {
    return [self timeStringWithSeconds:self.currentTime];
}

- (NSString *)totalTimeStr {
    return [self timeStringWithSeconds:self.totalTime];
}

- (void)setPlayTimeDidChangeExeBlok:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))playTimeDidChangeExeBlok {
    objc_setAssociatedObject(self, @selector(playTimeDidChangeExeBlok), playTimeDidChangeExeBlok, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))playTimeDidChangeExeBlok {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlayDidToEndExeBlock:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))playDidToEnd {
    objc_setAssociatedObject(self, @selector(playDidToEndExeBlock), playDidToEnd, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))playDidToEndExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}
@end


#pragma mark - Gesture

@implementation SJBaseVideoPlayer (GestureControl)

- (void)setDisableGestureTypes:(SJDisablePlayerGestureTypes)disableGestureTypes {
    objc_setAssociatedObject(self, @selector(disableGestureTypes), @(disableGestureTypes), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJDisablePlayerGestureTypes)disableGestureTypes {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
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

- (void)setControlLayerAppeared:(BOOL)controlLayerAppeared {
    [self.displayRecorder setControlLayerAppearedState:controlLayerAppeared];
}

- (BOOL)controlLayerAppeared {
    return self.displayRecorder.controlLayerAppearedState;
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlLayerAppearStateChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setControlLayerAppearStateChanged:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlLayerAppearStateChanged {
    objc_setAssociatedObject(self, @selector(controlLayerAppearStateChanged), controlLayerAppearStateChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)controlLayerNeedAppear {
    [self.displayRecorder layerAppear];
}
- (void)controlLayerNeedDisappear {
    [self.displayRecorder layerDisappear];
}

- (void)setPausedToKeepAppearState:(BOOL)pausedToKeepAppearState {
    self.displayRecorder.pausedToKeepAppearState = pausedToKeepAppearState;
}
- (BOOL)pausedToKeepAppearState {
    return self.displayRecorder.pausedToKeepAppearState;
}
- (void)setPlayFailedToKeepAppearState:(BOOL)playFailedToKeepAppearState {
    self.displayRecorder.playFailedToKeepAppearState = playFailedToKeepAppearState;
}
- (BOOL)playFailedToKeepAppearState {
    return self.displayRecorder.playFailedToKeepAppearState;
}
@end


#pragma mark - 屏幕旋转

@implementation SJBaseVideoPlayer (Rotation)

- (void)setSupportedOrientation:(SJAutoRotateSupportedOrientation)supportedOrientation {
    self.rotationManager.autorotationSupportedOrientation = supportedOrientation;
}

- (SJAutoRotateSupportedOrientation)supportedOrientation {
    return self.rotationManager.autorotationSupportedOrientation;
}

- (void)setOrientation:(SJOrientation)orientation {
    [self rotate:orientation animated:YES];
}

- (SJOrientation)orientation {
    return self.rotationManager.currentOrientation;
}

- (UIInterfaceOrientation)currentOrientation {
    UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
    switch ( self.orientation ) {
        case SJOrientation_Portrait: {
            orientation = UIInterfaceOrientationPortrait;
        }
            break;
        case SJOrientation_LandscapeLeft: {
            orientation = UIInterfaceOrientationLandscapeRight;
        }
            break;
        case SJOrientation_LandscapeRight: {
            orientation = UIInterfaceOrientationLandscapeLeft;
        }
            break;
    }
    return orientation;
}

- (void)rotate {
    // 此方法为无条件旋转, 任何时候都可以旋转
    // 外界调用此方法, 就是想要旋转, 不管播放器有没有禁止旋转, 我都暂时解开, 最后恢复设置
    BOOL disableAutoRotation = self.disableAutoRotation;
    self.disableAutoRotation = NO;
    [self.rotationManager rotate];
    // 恢复
    self.disableAutoRotation = disableAutoRotation; // reset
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated {
    [self.rotationManager rotate:orientation animated:animated];
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completion:(void (^ _Nullable)(__kindof SJBaseVideoPlayer *player))block {
    BOOL disableAutoRotation = self.disableAutoRotation;
    self.disableAutoRotation = NO;
    __weak typeof(self) _self = self;
    [self.rotationManager rotate:orientation animated:animated completionHandler:^(SJRotationManager * _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.disableAutoRotation = disableAutoRotation; // reset
        if ( block ) block(self);
    }];
}

- (void)setDisableAutoRotation:(BOOL)disableAutoRotation {
    self.rotationManager.disableAutorotation = disableAutoRotation;
}

- (BOOL)disableAutoRotation {
    return self.rotationManager.disableAutorotation;
}

- (void)setRotationTime:(NSTimeInterval)rotationTime {
    self.rotationManager.duration = rotationTime;
}

- (NSTimeInterval)rotationTime {
    return self.rotationManager.duration;
}

- (BOOL)isTransitioning {
    return self.rotationManager.transitioning;
}

- (BOOL)isFullScreen {
    return self.rotationManager.isFullscreen;
}

- (void)setViewWillRotateExeBlock:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))viewWillRotateExeBlock {
    objc_setAssociatedObject(self, @selector(viewWillRotateExeBlock), viewWillRotateExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))viewWillRotateExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setViewDidRotateExeBlock:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))viewDidRotateExeBlock {
    objc_setAssociatedObject(self, @selector(viewDidRotateExeBlock), viewDidRotateExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))viewDidRotateExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}
@end


#pragma mark - 截图

@implementation SJBaseVideoPlayer (Screenshot)

- (void)setPresentationSize:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, CGSize))presentationSize {
    objc_setAssociatedObject(self, @selector(presentationSize), presentationSize, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, CGSize))presentationSize {
    return objc_getAssociatedObject(self, _cmd);
}

- (UIImage * __nullable)screenshot {
    return [self.URLAsset.playAsset screenshot];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block {
    [self screenshotWithTime:time size:CGSizeZero completion:block];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block {
    __weak typeof(self) _self = self;
    [self.URLAsset.playAsset screenshotWithTime:time size:size completion:^(SJPlayAsset * _Nonnull a, UIImage * _Nullable image, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( block ) block(self, image, error);
        });
    }];
}

- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(__kindof SJBaseVideoPlayer *player, NSArray<id<SJVideoPlayerPreviewInfo>> *__nullable images, NSError *__nullable error))block {
    itemSize = CGSizeMake(ceil(itemSize.width), ceil(itemSize.height));
    __weak typeof(self) _self = self;
    [self.URLAsset.playAsset generatedPreviewImagesWithMaxItemSize:itemSize completion:^(SJPlayAsset * _Nonnull a, NSArray<id<SJVideoPlayerPreviewInfo>> * _Nullable images, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self, images, error);
    }];
}

@end


#pragma mark - 输出

@implementation SJBaseVideoPlayer (Export)

- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    endTime:(NSTimeInterval)endTime
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, float progress))progressBlock
                 completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, NSURL *fileURL, UIImage *thumbnailImage))completion
                    failure:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, NSError *error))failure {
    if ( !self.URLAsset.playAsset.URLAsset ) {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"msg":@"Resources are being initialized and cannot be exported."}];
        if ( failure ) failure(self, error);
        return;
    }
    
    __weak typeof(self) _self = self;
    [self.URLAsset.playAsset exportWithBeginTime:beginTime endTime:endTime presetName:presetName progress:^(SJPlayAsset * _Nonnull a, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( progressBlock ) progressBlock(self, progress);
    } completion:^(SJPlayAsset * _Nonnull a, AVAsset * _Nullable sandboxAsset, NSURL * _Nullable fileURL, UIImage * _Nullable thumbImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completion ) completion(self, fileURL, thumbImage);
    } failure:^(SJPlayAsset * _Nonnull a, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( failure ) failure(self, error);
    }];
}

- (void)cancelExportOperation {
    [self.URLAsset.playAsset cancelExportOperation];
}

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                        progress:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, float progress))progressBlock
                      completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage *imageGIF, UIImage *thumbnailImage, NSURL *filePath))completion
                         failure:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, NSError *error))failure {
    if ( !self.URLAsset ) {
        if ( failure ) {
            failure(self, [NSError errorWithDomain:NSCocoaErrorDomain
                                              code:-1
                                          userInfo:@{@"msg":@"Generate Gif Failed! Because `asset` is nil"}]);
        }
        return;
    }
    
    NSURL *filePath = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"SJGeneratedGif.gif"]];
    __weak typeof(self) _self = self;
    [self.URLAsset.playAsset generateGIFWithBeginTime:beginTime duration:duration maximumSize:CGSizeMake(375, 375) interval:0.25f gifSavePath:filePath progress:^(SJPlayAsset * _Nonnull a, float progress) {
        if ( progressBlock ) progressBlock(self, progress);
    } completion:^(SJPlayAsset * _Nonnull a, UIImage * _Nonnull imageGIF, UIImage * _Nonnull thumbnailImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completion ) completion(self, imageGIF, thumbnailImage, filePath);
    } failure:^(SJPlayAsset * _Nonnull a, NSError * _Nonnull error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( failure ) failure(self, error);
    }];
}

- (void)cancelGenerateGIFOperation {
    [self.URLAsset.playAsset cancelGenerateGIFOperation];
}
@end


#pragma mark - 在`tableView`或`collectionView`上播放

@implementation SJBaseVideoPlayer (ScrollView)

- (BOOL)isPlayOnScrollView {
    return [self.playModelObserver isPlayInCollectionView] || [self.playModelObserver isPlayInTableView];
}

- (BOOL)isScrollAppeared {
    return self.playModelObserver.isAppeared;
}

@end


#pragma mark - 提示

@implementation SJBaseVideoPlayer (Prompt)

- (SJPrompt *)prompt {
    SJPrompt *prompt = objc_getAssociatedObject(self, _cmd);
    if ( prompt ) return prompt;
    prompt = [SJPrompt promptWithPresentView:self.controlContentView];
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

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration hiddenExeBlock:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))hiddenExeBlock {
    __weak typeof(self) _self = self;
    [self.prompt showTitle:title duration:duration hiddenExeBlock:^(SJPrompt * _Nonnull prompt) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( hiddenExeBlock ) hiddenExeBlock(self);
    }];
}

- (void)showAttributedString:(NSAttributedString *)attributedString duration:(NSTimeInterval)duration {
    [self showAttributedString:attributedString duration:duration hiddenExeBlock:nil];
}

- (void)showAttributedString:(NSAttributedString *)attributedString duration:(NSTimeInterval)duration hiddenExeBlock:(void(^__nullable)(__kindof SJBaseVideoPlayer *player))hiddenExeBlock {
    __weak typeof(self) _self = self;
    [self.prompt showAttributedString:attributedString duration:duration hiddenExeBlock:^(SJPrompt * _Nonnull prompt) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( hiddenExeBlock ) hiddenExeBlock(self);
    }];
}

- (void)hiddenTitle {
    [self.prompt hidden];
}

@end


#pragma mark -
@interface _SJControlLayerAppearStateManager ()
@property (nonatomic, weak, readonly) SJBaseVideoPlayer *videoPlayer;
@property (nonatomic, strong, readonly) SJTimerControl *controlHiddenTimer;
@property (nonatomic) BOOL controlLayerAppearedState;
@end

@implementation _SJControlLayerAppearStateManager
@synthesize controlHiddenTimer = _controlHiddenTimer;

- (instancetype)initWithVideoPlayer:(SJBaseVideoPlayer *)videoPlayer {
    self = [super init];
    if ( !self ) return nil;
    _videoPlayer = videoPlayer;
    [_videoPlayer sj_addObserver:self forKeyPath:@"locked"];
    [_videoPlayer sj_addObserver:self forKeyPath:@"playStatus"];
    return self;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( [keyPath isEqualToString:@"locked"] ) {
        if ( _videoPlayer.isLockedScreen ) {
            [self.controlHiddenTimer clear];
        }
        else {
            [self.controlHiddenTimer start];
        }
    }
    else if ( [keyPath isEqualToString:@"playStatus"] ) {
        if ( [_videoPlayer playStatus_isInactivity_ReasonPlayFailed] ) {
            [self layerAppear];
        }
    }
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if ( enabled ) [_controlHiddenTimer start];
    else [_controlHiddenTimer clear];
}

- (void)start {
    if ( !_enabled ) return;
    [_controlHiddenTimer start];
}

- (void)considerChangeState {
    if ( _playFailedToKeepAppearState && [_videoPlayer playStatus_isInactivity_ReasonPlayFailed] ) return;
    if ( self.controlLayerAppearedState ) [self layerDisappear];
    else [self layerAppear];
}

- (void)layerAppear {
    if ( _pausedToKeepAppearState && [_videoPlayer playStatus_isPaused] ) [self.controlHiddenTimer clear];
    else if ( _playFailedToKeepAppearState && [_videoPlayer playStatus_isInactivity_ReasonPlayFailed] ) [self.controlHiddenTimer clear];
    else [self.controlHiddenTimer start];
    [self _changing:YES];
    _initialization = YES;
}

- (void)layerDisappear {
    [self.controlHiddenTimer clear];
    [self _changing:NO];
}

- (void)resetInitialization {
    _initialization = NO;
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !self.initialization && !self.controlLayerAppearedState ) [self layerAppear];
    });
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
- (void)_changing:(BOOL)status {
    if ( !self.isEnabled ) return;
    if ( !self.videoPlayer.controlLayerDataSource ) return;
    self.controlLayerAppearedState = status;
    if ( status && [self.videoPlayer.controlLayerDelegate respondsToSelector:@selector(controlLayerNeedAppear:)] ) {
        [_videoPlayer.controlLayerDelegate controlLayerNeedAppear:_videoPlayer];
    }
    else if ( !status && [self.videoPlayer.controlLayerDelegate respondsToSelector:@selector(controlLayerNeedDisappear:)] ) {
        [_videoPlayer.controlLayerDelegate controlLayerNeedDisappear:_videoPlayer];
    }
}

- (void)setControlLayerAppearedState:(BOOL)status {
    _controlLayerAppearedState = status;
    if ( _videoPlayer.controlLayerAppearStateChanged ) {
        _videoPlayer.controlLayerAppearStateChanged(_videoPlayer, status);
    }
    else {
        [UIView animateWithDuration:0.25 animations:^{
            [[self.videoPlayer atViewController] setNeedsStatusBarAppearanceUpdate];
        }];
    }
}
@end


#pragma mark -

@interface _SJReachabilityObserver ()
@property (nonatomic, strong, readonly) Reachability *reachability;
@end

@implementation _SJReachabilityObserver

+ (instancetype)sharedInstance {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _reachability = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_reachabilityChangedNotification) name:kReachabilityChangedNotification object:_reachability];
    [_reachability startNotifier];
    return self;
}

- (void)_reachabilityChangedNotification {
    if ( self.reachabilityChangedExeBlock ) {
        SJNetworkStatus status = (NSInteger)[self.reachability currentReachabilityStatus];
        self.reachabilityChangedExeBlock(self, status);
    }
}

- (SJNetworkStatus)networkStatus {
    return (NSInteger)[self.reachability currentReachabilityStatus];
}

- (void)dealloc {
    [_reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:_reachability];
}
@end


@implementation SJBaseVideoPlayer (Deprecated)
- (void)setPlayDidToEnd:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))playDidToEnd __deprecated_msg("use `playDidToEndExeBlock`") {
    self.playDidToEndExeBlock = playDidToEnd;
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))playDidToEnd __deprecated_msg("use `playDidToEndExeBlock`") {
    return self.playDidToEndExeBlock;
}

- (BOOL)playOnCell __deprecated_msg("use `isPlayOnScrollView`") {
    return [self isPlayOnScrollView];
}

- (BOOL)scrollIntoTheCell __deprecated_msg("use `isScrollAppeared`") {
    return self.isScrollAppeared;
}

- (void)jumpedToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler __deprecated_msg("use `seekToTime:completionHandler:`") {
    [self seekToTime:secs completionHandler:completionHandler];
}

- (BOOL)controlViewDisplayed __deprecated_msg("use `controlLayerAppeared`") {
    return self.controlLayerAppeared;
}

- (void)setControlViewDisplayStatus:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlViewDisplayStatus __deprecated_msg("use `controlLayerAppearStateChanged`") {
    self.controlLayerAppearStateChanged = controlViewDisplayStatus;
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlViewDisplayStatus __deprecated_msg("use `controlLayerAppearStateChanged`") {
    return self.controlLayerAppearStateChanged;
}
- (void)setWillRotateScreen:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))willRotateScreen __deprecated_msg("use `viewWillRotateExeBlock`") {
    self.viewWillRotateExeBlock = willRotateScreen;
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))willRotateScreen __deprecated_msg("use `viewWillRotateExeBlock`") {
    return self.viewWillRotateExeBlock;
}

- (void)setRotatedScreen:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))rotatedScreen  __deprecated_msg("use `viewDidRotateExeBlock`") {
    self.viewDidRotateExeBlock = rotatedScreen;
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))rotatedScreen  __deprecated_msg("use `viewDidRotateExeBlock`") {
    return self.viewDidRotateExeBlock;
}
@end


#pragma mark - Observer

@interface SJBaseVideoPlayer (SJPlayAssetPropertiesObserverDelegate)<SJPlayAssetPropertiesObserverDelegate>
@end

@implementation SJBaseVideoPlayer (SJPlayAssetPropertiesObserverDelegate)

- (void)observer:(SJPlayAssetPropertiesObserver *)observer durationDidChange:(NSTimeInterval)duration {
    [self timeDidChange];
}
- (void)observer:(SJPlayAssetPropertiesObserver *)observer currentTimeDidChange:(NSTimeInterval)currentTime {
    [self timeDidChange];
}
- (void)timeDidChange {
    if ( [self playStatus_isPaused] ) return;
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:currentTime:currentTimeStr:totalTime:totalTimeStr:)] ) {
        [self.controlLayerDelegate videoPlayer:self currentTime:self.currentTime currentTimeStr:self.currentTimeStr totalTime:self.totalTime totalTimeStr:self.totalTimeStr];
    }
    if ( self.playTimeDidChangeExeBlok ) self.playTimeDidChangeExeBlok(self);
}
- (void)observer:(SJPlayAssetPropertiesObserver *)observer bufferLoadedTimeDidChange:(NSTimeInterval)bufferLoadedTime {
    if ( observer.duration == 0 ) return;
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:loadedTimeProgress:)] ) {
        [self.controlLayerDelegate videoPlayer:self loadedTimeProgress:observer.bufferLoadedTime / observer.duration];
    }
}
- (void)observer:(SJPlayAssetPropertiesObserver *)observer bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus {
    switch ( bufferStatus ) {
        case SJPlayerBufferStatusUnknown: break;
        case SJPlayerBufferStatusEmpty: {
            [self pause:SJVideoPlayerPausedReasonBuffering];
            if ( [self.controlLayerDelegate respondsToSelector:@selector(startLoading:)] ) {
                [self.controlLayerDelegate startLoading:self];
            }
        }
            break;
        case SJPlayerBufferStatusFull: {
            if ( [self playStatus_isPaused_ReasonBuffering] ) [self play];
            if ( [self.controlLayerDelegate respondsToSelector:@selector(loadCompletion:)] ) {
                [self.controlLayerDelegate loadCompletion:self];
            }
        }
            break;
    }
}
- (void)observer:(SJPlayAssetPropertiesObserver *)observer presentationSizeDidChange:(CGSize)presentationSize {
    if ( self.presentationSize ) self.presentationSize(self, presentationSize);
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:presentationSize:)] ) {
        [self.controlLayerDelegate videoPlayer:self presentationSize:presentationSize];
    }
}
- (void)observer:(SJPlayAssetPropertiesObserver *)observer playerItemStatusDidChange:(AVPlayerItemStatus)playerItemStatus {
    switch ( playerItemStatus ) {
        case AVPlayerItemStatusUnknown: { } break;
        case AVPlayerItemStatusReadyToPlay: {
            [self _playerItemReadyToPlay];
        }
            break;
        case AVPlayerItemStatusFailed: {
            [self _playerItemPlayFailed];
        }
            break;
    }
}
- (void)assetLoadIsCompletedForObserver:(SJPlayAssetPropertiesObserver *)observer {
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self playStatus_isInactivity_ReasonPlayFailed] ) { return; }
        self.presentView.player = self.URLAsset.playAsset.player;
    });
}
- (void)playDidToEndForObserver:(SJPlayAssetPropertiesObserver *)observer {
    [self _playDidToEnd];
}
@end


@interface SJBaseVideoPlayer (SJPlayModelPropertiesObserverDelegate)<SJPlayModelPropertiesObserverDelegate>
@end

@implementation SJBaseVideoPlayer (SJPlayModelPropertiesObserverDelegate)
- (void)observer:(nonnull SJPlayModelPropertiesObserver *)observer userTouchedCollectionView:(BOOL)touched {
    self.touchedScrollView = touched;
}
- (void)observer:(nonnull SJPlayModelPropertiesObserver *)observer userTouchedTableView:(BOOL)touched {
    self.touchedScrollView = touched;
}
- (void)playerWillAppearForObserver:(nonnull SJPlayModelPropertiesObserver *)observer superview:(nonnull UIView *)superview {
    [self.displayRecorder layerAppear];
    if ( superview && self.view.superview != superview ) {
        [self.view removeFromSuperview];
        [superview addSubview:self.view];
        [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superview);
        }];
    }

    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayerWillAppearInScrollView:)] ) {
        [self.controlLayerDelegate videoPlayerWillAppearInScrollView:self];
    }
}
- (void)playerWillDisappearForObserver:(nonnull SJPlayModelPropertiesObserver *)observer {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayerWillDisappearInScrollView:)] ) {
        [self.controlLayerDelegate videoPlayerWillDisappearInScrollView:self];
    }
}
@end

NS_ASSUME_NONNULL_END
