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
#import <objc/message.h>
#import "SJRotationManager.h"
#import "SJDeviceVolumeAndBrightnessManager.h"
#import "UIView+SJVideoPlayerAdd.h"
#import "SJVideoPlayerRegistrar.h"
#import "SJVideoPlayerPresentView.h"
#import "SJPlayModelPropertiesObserver.h"
#import "SJAVMediaPlayAsset+SJAVMediaPlaybackControllerAdd.h"
#import "SJBaseVideoPlayer+PlayStatus.h"
#import "SJTimerControl.h"
#import "UIScrollView+ListViewAutoplaySJAdd.h"
#import "SJAVMediaPlaybackController.h"
#import "SJReachability.h"
#import "SJControlLayerAppearStateManager.h"
#import "SJFitOnScreenManager.h"
#import "SJFlipTransitionManager.h"
#import "SJIsAppeared.h"
#import "SJPlayerGestureControl.h"
#import "SJModalViewControlllerManager.h"

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#if __has_include(<SJObserverHelper/NSObject+SJObserverHelper.h>)
#import <SJObserverHelper/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

#if __has_include(<SJFullscreenPopGesture/UINavigationController+SJVideoPlayerAdd.h>)
#import <SJFullscreenPopGesture/UINavigationController+SJVideoPlayerAdd.h>
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJPlayerView : UIView
@property (nonatomic, copy, nullable) void(^willMoveToWindowExeBlock)(SJPlayerView *view, UIWindow *_Nullable window);
@end

@implementation SJPlayerView
- (void)willMoveToWindow:(nullable UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if ( _willMoveToWindowExeBlock ) _willMoveToWindowExeBlock(self, newWindow);
}
@end

@interface SJPlayStatusObserver : NSObject<SJPlayStatusObserver>
- (instancetype)initWithPlayer:(__kindof SJBaseVideoPlayer *)player;
@property (nonatomic, copy, nullable) void(^playStatusDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@end

@implementation SJPlayStatusObserver
static NSString *_kPlayStatus = @"playStatus";
- (instancetype)initWithPlayer:(__kindof SJBaseVideoPlayer *)player {
    self = [super init];
    if ( !self ) return nil;
    [player sj_addObserver:self forKeyPath:_kPlayStatus context:&_kPlayStatus];
    return self;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable SJBaseVideoPlayer *)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( context == &_kPlayStatus ) {
        if ( _playStatusDidChangeExeBlock ) _playStatusDidChangeExeBlock(object);
    }
}
@end

#pragma mark -

@interface SJBaseVideoPlayer ()
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
 锁屏状态下触发的手势.
 当播放器被锁屏时, 用户单击后, 会触发这个手势, 调用`controlLayerDelegate`的方法: `tappedPlayerOnTheLockedState:`
 */
@property (nonatomic, strong, readonly) UITapGestureRecognizer *lockStateTapGesture;

@property (nonatomic, strong, nullable) SJPlayModelPropertiesObserver *playModelObserver;

@property (nonatomic) SJVideoPlayerPlayStatus playStatus;
@property (nonatomic) SJVideoPlayerPausedReason pausedReason;
@property (nonatomic) SJVideoPlayerInactivityReason inactivityReason;

@property (nonatomic, strong, nullable) NSString *playStatusStr;

@property (nonatomic) BOOL isTriggeringForPopGesture;

@property (nonatomic) NSTimeInterval pan_totalTime;
@property (nonatomic) NSTimeInterval pan_shift;
@end

@implementation SJBaseVideoPlayer {
    UIView *_view;
    SJVideoPlayerPresentView *_presentView;
    UIView *_controlContentView;
    SJVideoPlayerRegistrar *_registrar;
    
    /// 当前资源是否播放过
    /// mpc => Media Playback Controller
    BOOL _mpc_assetIsPlayed;
    id<SJVideoPlayerURLAssetObserver> _Nullable _mpc_assetObserver;
    
    /// Placeholder
    BOOL _hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay;
    
    /// Status Bar
    BOOL _tmpShowStatusBar; // 临时显示状态栏
    BOOL _tmpHiddenStatusBar; // 临时隐藏状态栏
    
    /// device volume And brightness manager
    id<SJDeviceVolumeAndBrightnessManager> _deviceVolumeAndBrightnessManager;
    id<SJDeviceVolumeAndBrightnessManagerObserver> _deviceVolumeAndBrightnessManagerObserver;
    BOOL _disableBrightnessSetting;
    BOOL _disableVolumeSetting;

    /// gestures
    UITapGestureRecognizer *_lockStateTapGesture;
    SJPlayerGestureControl *_gestureControl;
    
    /// view controller
    BOOL _vc_isDisappeared;
    
    /// playback controller
    id<SJMediaPlaybackController> _playbackController;
    void (^_Nullable _assetDeallocExeBlock)(__kindof SJBaseVideoPlayer * _Nonnull);
    BOOL _mute;
    BOOL _lockedScreen;
    BOOL _autoPlayWhenPlayStatusIsReadyToPlay;
    BOOL _pauseWhenAppDidEnterBackground;
    BOOL _resumePlaybackWhenAppDidEnterForeground;
    BOOL(^_Nullable _canPlayAnAsset)(__kindof SJBaseVideoPlayer *player);
    void(^_Nullable _rateDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
    void(^_Nullable _playTimeDidChangeExeBlok)(__kindof SJBaseVideoPlayer *videoPlayer);
    void(^_Nullable _playDidToEndExeBlock)(__kindof SJBaseVideoPlayer *player);
    CGFloat _rate;
    SJVideoPlayerPlayStatus _playStatus;
    SJVideoPlayerPausedReason _pausedReason;
    SJVideoPlayerInactivityReason _inactivityReason;
    void(^_Nullable _playStatusDidChangeExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer);
    SJVideoPlayerURLAsset *_URLAsset;
    NSTimeInterval _playedLastTime;
    
    /// control layer appear manager
    id<SJControlLayerAppearManager> _controlLayerAppearManager;
    id<SJControlLayerAppearManagerObserver> _controlLayerAppearManagerObserver;
    void(^_Nullable _controlLayerAppearStateDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player, BOOL state);
    BOOL _pausedToKeepAppearState;
    BOOL _controlLayerAutoAppearWhenAssetInitialized;
    
    /// rotation manager
    id<SJRotationManagerProtocol> _rotationManager;
    id<SJRotationManagerObserver> _rotationManagerObserver;
    void(^_Nullable _viewWillRotateExeBlock)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen);
    void(^_Nullable _viewDidRotateExeBlock)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen);;
    
    /// Fit on screen manager
    id<SJFitOnScreenManager> _fitOnScreenManager;
    id<SJFitOnScreenManagerObserver> _fitOnScreenManagerObserver;
    BOOL _useFitOnScreenAndDisableRotation;
    BOOL _fitOnScreen;
    void(^_Nullable _fitOnScreenWillBeginExeBlock)(__kindof SJBaseVideoPlayer *player);
    void(^_Nullable _fitOnScreenDidEndExeBlock)(__kindof SJBaseVideoPlayer *player);
    
    /// Flip Transition manager
    id<SJFlipTransitionManager> _flipTransitionManager;
    id<SJFlipTransitionManagerObserver> _flipTransitionManagerObserver;
    void(^_Nullable _flipTransitionDidStartExeBlock)(__kindof SJBaseVideoPlayer *player);
    void(^_Nullable _flipTransitionDidStopExeBlock)(__kindof SJBaseVideoPlayer *player);
    
    /// Network status
    id<SJReachability> _reachability;
    id<SJReachabilityObserver> _reachabilityObserver;
    void(^_Nullable _networkStatusDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
    
    /// Scroll
    void(^_Nullable _playerViewWillAppearExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer);
    void(^_Nullable _playerViewWillDisappearExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer);
    
    /// mvcm => Modal view controller Manager
    id<SJModalViewControlllerManagerProtocol> _mvcm_modalViewControllerManager;
    BOOL _mvcm_needPresentModalViewControlller;
    UIView *_Nullable _mvcm_targetSuperView;
}

+ (instancetype)player {
    return [[self alloc] init];
}

+ (NSString *)version {
    return @"2.0.8";
}

- (nullable __kindof UIViewController *)atViewController {
    UIResponder *responder = nil;
    if ( self.needPresentModalViewControlller &&
         self.modalViewControllerManager.isPresentedModalViewControlller )
        responder = _mvcm_targetSuperView.nextResponder;
    else
        responder = _view.nextResponder;
    
    if ( !responder )
        return nil;
    
    while ( ![responder isKindOfClass:[UIViewController class]] ) {
        responder = responder.nextResponder;
        if ( [responder isMemberOfClass:[UIResponder class]] || !responder ) return nil;
    }
    return (__kindof UIViewController *)responder;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    self.rate = 1;
    self.hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay = YES;
    self.autoPlayWhenPlayStatusIsReadyToPlay = YES; // 是否自动播放, 默认yes
    self.pauseWhenAppDidEnterBackground = YES; // App进入后台是否暂停播放, 默认yes
    self.disabledControlLayerAppearManager = NO; // 是否启用控制层管理器
    [self registrar];
    [self view];
    [self reachability];
    [self rotationManager];
    [self gestureControl];
    [self addInterceptTapGR];
    [self _configAVAudioSession];
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
    return self;
}

- (void)_configAVAudioSession {
    if ( AVAudioSession.sharedInstance.category != AVAudioSessionCategoryPlayback ||
        AVAudioSession.sharedInstance.category != AVAudioSessionCategoryPlayAndRecord ) {
        NSError *error = nil;
        // 使播放器在静音状态下也能放出声音
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        if ( error ) NSLog(@"%@", error.userInfo);
    }
}

static NSString *_kGestureState = @"state";
- (void)_observeFullscreenPopGestureState {
    UINavigationController *nav = self.atViewController.navigationController;
    if ( !nav ) return;
    UIGestureRecognizer *gesture = nil;
#if __has_include(<SJFullscreenPopGesture/UINavigationController+SJVideoPlayerAdd.h>)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ( nav.sj_gestureType == SJFullscreenPopGestureType_Full ) {
        if ( [nav respondsToSelector:@selector(SJ_pan)] ) {
            gesture = [nav performSelector:@selector(SJ_pan)];
        }
    }
    else {
        if ( [nav respondsToSelector:@selector(SJ_edgePan)] ) {
            gesture = [nav performSelector:@selector(SJ_edgePan)];
        }
    }
#pragma clang diagnostic pop
#else
    gesture = nav.interactivePopGestureRecognizer;
#endif
    if ( !gesture ) return;
    
    [gesture sj_addObserver:self forKeyPath:_kGestureState context:&_kGestureState];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( context == &_kGestureState ) {
        UIGestureRecognizer *g = object;
        _isTriggeringForPopGesture = (g.state == UIGestureRecognizerStateChanged);
    }
}

- (void)dealloc {
#ifdef SJ_MAC
    NSLog(@"SJVideoPlayerLog: %d - %s", (int)__LINE__, __func__);
#endif
    if ( _URLAsset && self.assetDeallocExeBlock ) self.assetDeallocExeBlock(self);
    [_presentView removeFromSuperview];
    [_view removeFromSuperview];
}

- (void)setPlayStatus:(SJVideoPlayerPlayStatus)playStatus {
    NSString *playStatusStr = [self getPlayStatusStr:playStatus];
    if ( [playStatusStr isEqualToString:_playStatusStr] ) return;
    
    /// 所有播放状态, 均在`PlayControl`分类中维护
    /// 所有播放状态, 均在`PlayControl`分类中维护
    _playStatus = playStatus;
    _playStatusStr = playStatusStr;
    
    if ( _playStatusDidChangeExeBlock )
        _playStatusDidChangeExeBlock(self);
    
#ifdef DEBUG
    printf("%s\n", playStatusStr.UTF8String);
#endif
    
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
                case SJVideoPlayerInactivityReasonNotReachableAndPlaybackStalled:
                    self.state = SJVideoPlayerPlayState_PlayFailed;
                    break;
            }
            break;
    }
#pragma clang diagnostic pop
    
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:statusDidChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self statusDidChanged:playStatus];
        }
    });
    
    if ( SJVideoPlayerPlayStatusPlaying == _playStatus ) {
        _mpc_assetIsPlayed = YES;
        _playedLastTime = 0;
    }
}


- (void)setControlLayerDataSource:(nullable id<SJVideoPlayerControlLayerDataSource>)controlLayerDataSource {
    if ( controlLayerDataSource == _controlLayerDataSource ) return;
    _controlLayerDataSource = controlLayerDataSource;
    
    if ( !controlLayerDataSource ) return;
    
    _controlLayerDataSource.controlView.clipsToBounds = YES;
    
    // install
    [self.controlContentView addSubview:_controlLayerDataSource.controlView];
    [_controlLayerDataSource.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    if ( [self.controlLayerDataSource respondsToSelector:@selector(installedControlViewToVideoPlayer:)] ) {
        [self.controlLayerDataSource installedControlViewToVideoPlayer:self];
    }
}

- (void)_showOrHiddenPlaceholderImageViewIfNeeded {
    if ( [self playStatus_isUnknown] || [self playStatus_isPrepare] ) {
        if ( !self.URLAsset.otherMedia && _presentView.placeholderImageViewIsHidden ) {
            [self.presentView showPlaceholder];
        }
    }
    else if ( self.playbackController.isReadyForDisplay &&
              _hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay &&
             !_presentView.placeholderImageViewIsHidden ) {
        [UIView animateWithDuration:0.4 animations:^{
            [self.presentView hiddenPlaceholder];
        }];
    }
}

- (void)setVideoGravity:(AVLayerVideoGravity _Nullable)videoGravity {
    self.playbackController.videoGravity = videoGravity;
}

- (AVLayerVideoGravity)videoGravity {
    if ( _playbackController ) return _playbackController.videoGravity;
    return AVLayerVideoGravityResizeAspect;
}

#pragma mark -
- (UIView *)view {
    if ( _view ) return _view;
    _view = [SJPlayerView new];
    _view.backgroundColor = [UIColor blackColor];
    [_view addSubview:self.presentView];
    [_presentView addSubview:self.controlContentView];
    _presentView.autoresizingMask = _controlContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    __weak typeof(self) _self = self;
    [(SJPlayerView *)_view setWillMoveToWindowExeBlock:^(SJPlayerView * _Nonnull view, UIWindow * _Nullable window) {
        if ( !window ) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            [self.playModelObserver refreshAppearState];
            [self _observeFullscreenPopGestureState];
        });
    }];
    return _view;
}

- (void)addInterceptTapGR {
    UITapGestureRecognizer *intercept = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInterceptTapGR:)];

    [self.view addGestureRecognizer:intercept];
}

- (void)handleInterceptTapGR:(UITapGestureRecognizer *)tap { }

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

- (SJVideoPlayerRegistrar *)registrar {
    if ( _registrar ) return _registrar;
    _registrar = [SJVideoPlayerRegistrar new];
    
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
        if ( [self playStatus_isPaused] && self.resumePlaybackWhenAppDidEnterForeground ) [self play];

        if ( [self.controlLayerDelegate respondsToSelector:@selector(appDidBecomeActive:)] ) {
            [self.controlLayerDelegate appDidBecomeActive:self];
        }
    };
    
    _registrar.willEnterForeground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
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
        if ( [self.controlLayerDelegate respondsToSelector:@selector(appDidEnterBackground:)] ) {
            [self.controlLayerDelegate appDidEnterBackground:self];
        }
    };
    
    _registrar.oldDeviceUnavailable = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( ![self playStatus_isPaused_ReasonPause] ) [self play];
    };
    
    _registrar.audioSessionInterruption = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( ![self playStatus_isPaused_ReasonPause] ) [self pause];
    };
    return _registrar;
}

- (void)setState:(SJVideoPlayerPlayState)state {
    if ( state == _state ) return;
    _state = state;
    
    if ( state == SJVideoPlayerPlayState_Paused &&
         self.pausedToKeepAppearState &&
         self.registrar.state == SJVideoPlayerAppState_Forground )
        [self.controlLayerAppearManager keepAppearState];
    
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


@implementation SJBaseVideoPlayer (Placeholder)
///
/// Thanks @chjsun
/// https://github.com/changsanjiang/SJVideoPlayer/issues/42
///
- (UIImageView *)placeholderImageView {
    return self.presentView.placeholderImageView;
}

- (void)setHiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay:(BOOL)hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay {
    _hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay = hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay;
}

- (BOOL)hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay {
    return _hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay;
}
@end


#pragma mark -

@implementation SJBaseVideoPlayer (VideoFlipTransition)
- (void)setFlipTransitionManager:(id<SJFlipTransitionManager> _Nullable)flipTransitionManager {
    _flipTransitionManager = flipTransitionManager;
    [self _needUpdateFlipTransitionManagerProperties];
}
- (id<SJFlipTransitionManager>)flipTransitionManager {
    if ( _flipTransitionManager )
        return _flipTransitionManager;
    
    _flipTransitionManager = [[SJFlipTransitionManager alloc] initWithTarget:_playbackController.playerView];
    [self _needUpdateFlipTransitionManagerProperties];
    return _flipTransitionManager;
}

- (void)_needUpdateFlipTransitionManagerProperties {
    if ( !_flipTransitionManager )
        return;
    
    _flipTransitionManagerObserver = [_flipTransitionManager getObserver];
    __weak typeof(self) _self = self;
    _flipTransitionManagerObserver.flipTransitionDidStartExeBlock = ^(id<SJFlipTransitionManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.flipTransitionDidStartExeBlock )
            self.flipTransitionDidStartExeBlock(self);
    };
    
    _flipTransitionManagerObserver.flipTransitionDidStopExeBlock = ^(id<SJFlipTransitionManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.flipTransitionDidStopExeBlock )
            self.flipTransitionDidStopExeBlock(self);
    };
}

- (BOOL)isFlipTransitioning {
    return self.flipTransitionManager.state == SJFlipTransitionStateStart;
}
- (SJViewFlipTransition)flipTransition {
    return self.flipTransitionManager.flipTransition;
}
- (void)setFlipTransition:(SJViewFlipTransition)flipTransition {
    [self setFlipTransition:flipTransition animated:YES];
}
- (void)setFlipTransition:(SJViewFlipTransition)t animated:(BOOL)animated {
    [self setFlipTransition:t animated:animated completionHandler:nil];
}
- (void)setFlipTransition:(SJViewFlipTransition)t animated:(BOOL)animated completionHandler:(void(^_Nullable)(__kindof SJBaseVideoPlayer *player))completionHandler {
    __weak typeof(self) _self = self;
    [self.flipTransitionManager setFlipTransition:t animated:animated completionHandler:^(id<SJFlipTransitionManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
      if ( completionHandler )
          completionHandler(self);
    }];
}

- (void)setFlipTransitionDidStartExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))block {
    _flipTransitionDidStartExeBlock = block;
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))flipTransitionDidStartExeBlock {
    return _flipTransitionDidStartExeBlock;
}

- (void)setFlipTransitionDidStopExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))block {
    _flipTransitionDidStopExeBlock = block;
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))flipTransitionDidStopExeBlock {
    return _flipTransitionDidStopExeBlock;
}
@end

#pragma mark - 控制
@implementation SJBaseVideoPlayer (PlayControl)
- (void)setPlaybackController:(nullable id<SJMediaPlaybackController>)playbackController {
    [_playbackController.playerView removeFromSuperview];
    _playbackController = playbackController;
    [self _needUpdatePlaybackControllerProperties];
}

- (id<SJMediaPlaybackController>)playbackController {
    if ( _playbackController ) return _playbackController;
    _playbackController = [SJAVMediaPlaybackController new];
    [self _needUpdatePlaybackControllerProperties];
    return _playbackController;
}

- (void)_needUpdatePlaybackControllerProperties {
    if ( !_playbackController )
        return;
    
    _playbackController.delegate = self;
    if ( _playbackController.playerView.superview != self.presentView ) {
        _playbackController.playerView.frame = self.presentView.bounds;
        _playbackController.playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_presentView insertSubview:_playbackController.playerView atIndex:0];
    }
    if ( _playbackController.rate != self.rate ) _playbackController.rate = self.rate;
    if ( _playbackController.pauseWhenAppDidEnterBackground != self.pauseWhenAppDidEnterBackground ) _playbackController.pauseWhenAppDidEnterBackground = self.pauseWhenAppDidEnterBackground;
    if ( _playbackController.mute != self.mute ) _playbackController.mute = self.mute;
    if ( _playbackController.videoGravity != self.videoGravity ) _playbackController.videoGravity = self.videoGravity;
}

- (void)switchVideoDefinitionByURL:(NSURL *)URL {
    [self.playbackController switchVideoDefinitionByURL:URL];
}

- (id<SJPlayStatusObserver>)getPlayStatusObserver {
    return [[SJPlayStatusObserver alloc] initWithPlayer:self];
}

/// delegate methods

- (void)playbackControllerIsReadyForDisplay:(id<SJMediaPlaybackController>)controller {
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
}

- (void)playbackController:(id<SJMediaPlaybackController>)controller prepareToPlayStatusDidChange:(SJMediaPlaybackPrepareStatus)prepareStatus {
    switch ( prepareStatus ) {
        case SJMediaPlaybackPrepareStatusUnknown: break;
        case SJMediaPlaybackPrepareStatusReadyToPlay: {
            [self _playerReadyToPlay];
        }
            break;
        case SJMediaPlaybackPrepareStatusFailed: {
            [self _playerPrepareFailed];
        }
            break;
    }
}

- (void)playbackController:(id<SJMediaPlaybackController>)controller durationDidChange:(NSTimeInterval)duration {
    [self _playTimeDidChange];
}

- (void)playbackController:(id<SJMediaPlaybackController>)controller currentTimeDidChange:(NSTimeInterval)currentTime {
    [self _playTimeDidChange];
}

- (void)_playTimeDidChange {
    if ( [self playStatus_isPaused] ) return;
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:currentTime:currentTimeStr:totalTime:totalTimeStr:)] ) {
        [self.controlLayerDelegate videoPlayer:self currentTime:self.currentTime currentTimeStr:self.currentTimeStr totalTime:self.totalTime totalTimeStr:self.totalTimeStr];
    }
    if ( self.playTimeDidChangeExeBlok ) self.playTimeDidChangeExeBlok(self);
}

- (void)mediaDidPlayToEndForPlaybackController:(id<SJMediaPlaybackController>)controller {
    [self _mediaDidPlayToEnd];
}

- (void)playbackController:(id<SJMediaPlaybackController>)controller bufferLoadedTimeDidChange:(NSTimeInterval)bufferLoadedTime {
    if ( controller.duration == 0 ) return;
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:bufferTimeDidChange:)] ) {
        [self.controlLayerDelegate videoPlayer:self bufferTimeDidChange:bufferLoadedTime];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    else if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:loadedTimeProgress:)] ) {
        [self.controlLayerDelegate videoPlayer:self loadedTimeProgress:controller.bufferLoadedTime / controller.duration];
    }
#pragma clang diagnostic pop

}

- (void)playbackController:(id<SJMediaPlaybackController>)controller bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus {
    [self _refreshBufferStatus];
}

- (void)playbackController:(id<SJMediaPlaybackController>)controller presentationSizeDidChange:(CGSize)presentationSize {
    if ( self.presentationSize ) self.presentationSize(self, presentationSize);
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:presentationSize:)] ) {
        [self.controlLayerDelegate videoPlayer:self presentationSize:presentationSize];
    }
}

- (void)playbackController:(id<SJMediaPlaybackController>)controller switchVideoDefinitionByURL:(NSURL *)URL statusDidChange:(SJMediaPlaybackSwitchDefinitionStatus)status {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:switchVideoDefinitionByURL:statusDidChange:)] ) {
        [self.controlLayerDelegate videoPlayer:self switchVideoDefinitionByURL:URL statusDidChange:status];
    }
}

- (void)_refreshBufferStatus {
    if ( [self playStatus_isInactivity_ReasonPlayEnd] ) {
        return;
    }
    
    SJPlayerBufferStatus bufferStatus = self.playbackController.bufferStatus;
#ifdef SJ_MAC
    NSString *network = nil;
    switch ( _reachability.networkStatus ) {
        case SJNetworkStatus_NotReachable:
            network = @"SJNetworkStatus_NotReachable";
            break;
        case SJNetworkStatus_ReachableViaWWAN:
            network = @"SJNetworkStatus_ReachableViaWWAN";
            break;
        case SJNetworkStatus_ReachableViaWiFi:
            network = @"SJNetworkStatus_ReachableViaWiFi";
            break;
    }
    
    switch ( bufferStatus ) {
        case SJPlayerBufferStatusUnknown:
            printf("\nSJPlayerBufferStatusUnknown - %s \n", network.UTF8String);
            break;
        case SJPlayerBufferStatusUnplayable:
            printf("\nSJPlayerBufferStatusUnplayable - %s \n", network.UTF8String);
            break;
        case SJPlayerBufferStatusPlayable:
            printf("\nSJPlayerBufferStatusPlayable - %s \n", network.UTF8String);
            break;
    }
#endif
    
    
    switch ( bufferStatus ) {
        case SJPlayerBufferStatusUnknown:
        case SJPlayerBufferStatusUnplayable: {
            // 有网
            if ( self.reachability.networkStatus != SJNetworkStatus_NotReachable ) {
                if ( (![self playStatus_isPrepare] && ![self playStatus_isReadyToPlay]) || _mpc_assetIsPlayed ) {
                    if ( ![self playStatus_isPaused] )
                        [self pause:SJVideoPlayerPausedReasonBuffering];
                }
            }
            // 无网
            else if ( ![self.URLAsset.mediaURL isFileURL] ) {
                self.inactivityReason = SJVideoPlayerInactivityReasonNotReachableAndPlaybackStalled;
                self.playStatus = SJVideoPlayerPlayStatusInactivity;
            }
        }
            break;
        case SJPlayerBufferStatusPlayable: {
            if ( [self playStatus_isPaused_ReasonBuffering] || [self playStatus_isInactivity_ReasonNotReachableAndPlaybackStalled] ) {
                [self play];
            }
        }
            break;
    }
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:bufferStatusDidChange:)] ) {
        [self.controlLayerDelegate videoPlayer:self bufferStatusDidChange:bufferStatus];
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        switch ( bufferStatus ) {
            case SJPlayerBufferStatusUnknown: break;
            case SJPlayerBufferStatusUnplayable: {
                if ( [self.controlLayerDelegate respondsToSelector:@selector(startLoading:)] ) {
                    [self.controlLayerDelegate startLoading:self];
                }
            }
                break;
            case SJPlayerBufferStatusPlayable: {
                if ( [self.controlLayerDelegate respondsToSelector:@selector(loadCompletion:)] ) {
                    [self.controlLayerDelegate loadCompletion:self];
                }
            }
                break;
        }
#pragma clang diagnostic pop
    }
}

// 1.
- (void)setURLAsset:(nullable SJVideoPlayerURLAsset *)URLAsset {
    if ( _URLAsset ) {
        if ( self.assetDeallocExeBlock )
            self.assetDeallocExeBlock(self);
    }
    
    _mpc_assetIsPlayed = NO;
    
    // update
    [self _updateCurrentPlayingIndexPathIfNeeded:URLAsset.playModel];
    [self _updatePlayModelObserver:URLAsset.playModel];
    _mpc_assetObserver = [URLAsset getObserver];
    __weak typeof(self) _self = self;
    _mpc_assetObserver.playModelDidChangeExeBlock = ^(SJVideoPlayerURLAsset * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateCurrentPlayingIndexPathIfNeeded:URLAsset.playModel];
        [self _updatePlayModelObserver:URLAsset.playModel];
    };
    
    // update
    _URLAsset = URLAsset;
    
    self.playbackController.media = URLAsset;
    
    if ( !URLAsset ) {
        self.playStatus = SJVideoPlayerPlayStatusUnknown;
        self.playModelObserver = nil;
    }
    else {
        self.playStatus = SJVideoPlayerPlayStatusPrepare;
    
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:prepareToPlay:)] ) {
            [self.controlLayerDelegate videoPlayer:self prepareToPlay:URLAsset];
        }
        [self.playbackController prepareToPlay];
    }
}
- (nullable SJVideoPlayerURLAsset *)URLAsset {
    return _URLAsset;
}

// 2.1
- (void)_playerReadyToPlay {
    
    if ( ![self playStatus_isPrepare] )
        return;
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:currentTime:currentTimeStr:totalTime:totalTimeStr:)] ) {
        [self.controlLayerDelegate videoPlayer:self currentTime:self.currentTime currentTimeStr:self.currentTimeStr totalTime:self.totalTime totalTimeStr:self.totalTimeStr];
    }

    if ( self.registrar.state == SJVideoPlayerAppState_Background &&
         self.pauseWhenAppDidEnterBackground ) {
        [self pause:SJVideoPlayerPausedReasonPause];
        return;
    }
    
    if ( !self.isLockedScreen && self.controlLayerAutoAppearWhenAssetInitialized ) {
        __weak typeof(self) _self = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.controlLayerAppearManager needAppear];
        });
    }
    
    self.playStatus = SJVideoPlayerPlayStatusReadyToPlay;
    
    if ( self.operationOfInitializing ) {
        self.operationOfInitializing(self);
        self.operationOfInitializing = nil;
    }
    else if ( self.autoPlayWhenPlayStatusIsReadyToPlay ) {
        if ( self.isPlayOnScrollView ) {
            if ( self.isScrollAppeared )
                [self play];
            else
                [self pause];
        }
        else {
            [self play];
        }
    }
}

// 2.2
- (void)_playerPrepareFailed {
    self.error = _playbackController.error;
    self.inactivityReason = SJVideoPlayerInactivityReasonPlayFailed;
    self.playStatus = SJVideoPlayerPlayStatusInactivity;
}

- (void)_mediaDidPlayToEnd {
    if ( !self.vc_isDisappeared ) {
        UIScrollView *scrollView = sj_getScrollView(_URLAsset.playModel);
        if ( scrollView.sj_enabledAutoplay ) {
            if ( self.playDidToEndExeBlock ) self.playDidToEndExeBlock(self);
            [scrollView sj_needPlayNextAsset];
            return;
        }
    }
    
    self.inactivityReason = SJVideoPlayerInactivityReasonPlayEnd;
    self.playStatus = SJVideoPlayerPlayStatusInactivity;
    if ( self.playDidToEndExeBlock ) self.playDidToEndExeBlock(self);
}

- (void)refresh {
    if ( !self.URLAsset ) return;
    if ( self.currentTime != 0 ) {
        _playedLastTime = self.currentTime;
    }
    self.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:_URLAsset.mediaURL specifyStartTime:_playedLastTime playModel:_URLAsset.playModel];
}

- (void)setAssetDeallocExeBlock:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))assetDeallocExeBlock {
    _assetDeallocExeBlock = assetDeallocExeBlock;
}
- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))assetDeallocExeBlock {
    return _assetDeallocExeBlock;
}

- (void)setPlayerVolume:(float)playerVolume {
    _playbackController.volume = playerVolume;
}
- (float)playerVolume {
    return _playbackController.volume;
}

- (void)setMute:(BOOL)mute {
    if ( mute == _mute )
        return;
    _mute = mute;
    _playbackController.mute = mute;
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:muteChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self muteChanged:mute];
    }
}
- (BOOL)isMute {
    return _mute;
}

- (void)setLockedScreen:(BOOL)lockedScreen {
    if ( lockedScreen == _lockedScreen )
        return;
    _lockedScreen = lockedScreen;
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
    return _lockedScreen;
}

- (void)setAutoPlayWhenPlayStatusIsReadyToPlay:(BOOL)autoPlayWhenPlayStatusIsReadyToPlay {
    _autoPlayWhenPlayStatusIsReadyToPlay = autoPlayWhenPlayStatusIsReadyToPlay;
}
- (BOOL)autoPlayWhenPlayStatusIsReadyToPlay {
    return _autoPlayWhenPlayStatusIsReadyToPlay;
}

- (void)setPauseWhenAppDidEnterBackground:(BOOL)pauseWhenAppDidEnterBackground {
    if ( pauseWhenAppDidEnterBackground ==  _pauseWhenAppDidEnterBackground ) return;
    _pauseWhenAppDidEnterBackground = pauseWhenAppDidEnterBackground;
    _playbackController.pauseWhenAppDidEnterBackground = pauseWhenAppDidEnterBackground;
}
- (BOOL)pauseWhenAppDidEnterBackground {
    return _pauseWhenAppDidEnterBackground;
}

- (void)setResumePlaybackWhenAppDidEnterForeground:(BOOL)resumePlaybackWhenAppDidEnterForeground {
    _resumePlaybackWhenAppDidEnterForeground = resumePlaybackWhenAppDidEnterForeground;
}
- (BOOL)resumePlaybackWhenAppDidEnterForeground {
    return _resumePlaybackWhenAppDidEnterForeground;
}

- (void)setCanPlayAnAsset:(nullable BOOL (^)(__kindof SJBaseVideoPlayer * _Nonnull))canPlayAnAsset {
    _canPlayAnAsset = canPlayAnAsset;
}
- (nullable BOOL (^)(__kindof SJBaseVideoPlayer * _Nonnull))canPlayAnAsset {
    return _canPlayAnAsset;
}

- (void)play {
    if ( !self.URLAsset ) return;
    
    if ( self.canPlayAnAsset ) { if ( !self.canPlayAnAsset(self) ) return; }
    
    if ( self.registrar.state == SJVideoPlayerAppState_Background && self.pauseWhenAppDidEnterBackground ) return;
    
    if ( [self playStatus_isInactivity_ReasonPlayEnd] ) {
        [self replay];
        return;
    }
    
    if ( [self playStatus_isInactivity_ReasonPlayFailed] ) {
        // 尝试重新播放
        [self refresh];
        return;
    }
    
    if ( [self playStatus_isPrepare] ) {
        // 记录操作, 待资源初始化完成后调用
        self.operationOfInitializing = ^(SJBaseVideoPlayer * _Nonnull player) {
            if ( player.autoPlayWhenPlayStatusIsReadyToPlay ) [player play];
        };
        return;
    }
    
    [_playbackController play];
    
    self.playStatus = SJVideoPlayerPlayStatusPlaying;
    
    [self.controlLayerAppearManager resume];
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
    
    [self.playbackController pause];
    
    self.pausedReason = reason;
    self.playStatus = SJVideoPlayerPlayStatusPaused;
}

- (void)stop {
    _operationOfInitializing = nil;
    [self.playbackController stop];
    self.playModelObserver = nil;
    self.URLAsset = nil;
    self.playStatus = SJVideoPlayerPlayStatusUnknown;
}

- (void)stopAndFadeOut {
    [self.view sj_fadeOutAndCompletion:^(UIView *view) {
        [view removeFromSuperview];
        [self stop];
    }];
}

- (void)replay {
    if ( !self.URLAsset ) return;
    if ( [self playStatus_isInactivity_ReasonPlayFailed] ) {
        [self refresh];
        return;
    }

    [self seekToTime:0 completionHandler:^(BOOL finished) {
        [self.playbackController play];
        self.playStatus = SJVideoPlayerPlayStatusPlaying;
    }];
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
    
    if ( self.playbackController.prepareStatus != SJMediaPlaybackPrepareStatusReadyToPlay ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    if ( secs > self.playbackController.duration ) {
        secs = self.playbackController.duration;
    }
    else if ( secs < 0 ) {
        secs = 0;
    }
    
    NSTimeInterval current = floor(self.playbackController.currentTime + 0.5);
    NSTimeInterval seek = floor(secs + 0.5);
    
    if ( current == seek ) {
        if ( completionHandler ) completionHandler(YES);
        return;
    }
    
    if ( [self playStatus_isPaused_ReasonSeeking] ) {
        if ( [self.playbackController respondsToSelector:@selector(cancelPendingSeeks)] ) [self.playbackController cancelPendingSeeks];
    }
    else {
        if ( ![self playStatus_isPrepare] ) [self pause:SJVideoPlayerPausedReasonSeeking];
    }
    
    __weak typeof(self) _self = self;
    [self.playbackController seekToTime:secs completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( !finished ) {
            [self _refreshBufferStatus];
        }
        else {
            if ( [self playStatus_isPaused_ReasonSeeking] ) [self play];
            if ( self.playTimeDidChangeExeBlok ) self.playTimeDidChangeExeBlok(self);
        }
        if ( completionHandler ) completionHandler(finished);
    }];
}

- (void)setRate:(float)rate {
    if ( self.canPlayAnAsset && !self.canPlayAnAsset(self) ) return;
    if ( _rate == rate ) return;
    _rate = rate;
    _playbackController.rate = rate;
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:rateChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self rateChanged:rate];
    }
    
    if ( self.rateDidChangeExeBlock ) self.rateDidChangeExeBlock(self);
    
    if ( [self playStatus_isInactivity_ReasonPlayEnd] ) [self replay];
    
    if ( [self playStatus_isPaused] ) [self play];
}

- (float)rate {
    return _rate;
}
- (void)setRateDidChangeExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))rateDidChangeExeBlock {
    _rateDidChangeExeBlock = rateDidChangeExeBlock;
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))rateDidChangeExeBlock {
    return _rateDidChangeExeBlock;
}

- (void)setAssetURL:(nullable NSURL *)assetURL {
    self.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:assetURL];
}

- (nullable NSURL *)assetURL {
    return self.URLAsset.mediaURL;
}

- (void)playWithURL:(NSURL *)URL {
    self.assetURL = URL;
}

- (void)_updateCurrentPlayingIndexPathIfNeeded:(SJPlayModel *)playModel {
    if ( !playModel )
        return;
    
    // 维护当前播放的indexPath
    UIScrollView *scrollView = sj_getScrollView(playModel);
    if ( scrollView.sj_enabledAutoplay ) {
        scrollView.sj_currentPlayingIndexPath = [playModel performSelector:@selector(indexPath)];
    }
}

- (void)_updatePlayModelObserver:(SJPlayModel *)playModel {
    if ( !playModel )
        return;
    
    // update playModel
    self.playModelObserver = [[SJPlayModelPropertiesObserver alloc] initWithPlayModel:playModel];
    self.playModelObserver.delegate = (id)self;
}
@end


#pragma mark - Network

@implementation SJBaseVideoPlayer (Network)

- (void)setReachability:(id<SJReachability> _Nullable)reachability {
    _reachability = reachability;
    [self _needUpdateReachabilityProperties];
}

- (id<SJReachability>)reachability {
    if ( _reachability )
        return _reachability;
    _reachability = [SJReachability shared];
    [self _needUpdateReachabilityProperties];
    return _reachability;
}

- (void)_needUpdateReachabilityProperties {
    if ( !_reachability )
        return;
    
    _reachabilityObserver = [_reachability getObserver];
    __weak typeof(self) _self = self;
    _reachabilityObserver.networkStatusDidChangeExeBlock = ^(id<SJReachability> r, SJNetworkStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
        [self _refreshBufferStatus];
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:reachabilityChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self reachabilityChanged:status];
        }
        
        if ( self.networkStatusDidChangeExeBlock )
            self.networkStatusDidChangeExeBlock(self);
    };
}

- (SJNetworkStatus)networkStatus {
    return self.reachability.networkStatus;
}

- (void)setNetworkStatusDidChangeExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))networkStatusDidChangeExeBlock {
    _networkStatusDidChangeExeBlock = networkStatusDidChangeExeBlock;
}

- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))networkStatusDidChangeExeBlock {
    return _networkStatusDidChangeExeBlock;
}
@end

#pragma mark -

@implementation SJBaseVideoPlayer (DeviceVolumeAndBrightness)

- (void)setDeviceVolumeAndBrightnessManager:(id<SJDeviceVolumeAndBrightnessManager> _Nullable)deviceVolumeAndBrightnessManager {
    _deviceVolumeAndBrightnessManager = deviceVolumeAndBrightnessManager;
    [self _needUpdateDeviceVolumeAndBrightnessManagerProperties];
}

- (id<SJDeviceVolumeAndBrightnessManager>)deviceVolumeAndBrightnessManager {
    if ( _deviceVolumeAndBrightnessManager )
        return _deviceVolumeAndBrightnessManager;
    _deviceVolumeAndBrightnessManager = [SJDeviceVolumeAndBrightnessManager shared];
    [self _needUpdateDeviceVolumeAndBrightnessManagerProperties];
    return _deviceVolumeAndBrightnessManager;
}

- (void)_needUpdateDeviceVolumeAndBrightnessManagerProperties {
    if ( !_deviceVolumeAndBrightnessManager )
        return;
    _deviceVolumeAndBrightnessManager.targetView = self.presentView;
    
    _deviceVolumeAndBrightnessManagerObserver = [_deviceVolumeAndBrightnessManager getObserver];
    __weak typeof(self) _self = self;
    _deviceVolumeAndBrightnessManagerObserver.volumeDidChangeExeBlock = ^(id<SJDeviceVolumeAndBrightnessManager>  _Nonnull mgr, float volume) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:volumeChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self volumeChanged:volume];
        }
    };
    
    _deviceVolumeAndBrightnessManagerObserver.brightnessDidChangeExeBlock = ^(id<SJDeviceVolumeAndBrightnessManager>  _Nonnull mgr, float brightness) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:brightnessChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self brightnessChanged:brightness];
        }
    };
}

- (void)setDeviceVolume:(float)deviceVolume {
    if ( self.disableVolumeSetting )
        return;
    _deviceVolumeAndBrightnessManager.volume = deviceVolume;
}
- (float)deviceVolume {
    return self.deviceVolumeAndBrightnessManager.volume;
}

- (void)setDeviceBrightness:(float)deviceBrightness {
    if ( self.disableBrightnessSetting )
        return;
    _deviceVolumeAndBrightnessManager.brightness = deviceBrightness;
}
- (float)deviceBrightness {
    return self.deviceVolumeAndBrightnessManager.brightness;
}

- (void)setDisableBrightnessSetting:(BOOL)disableBrightnessSetting {
    _disableBrightnessSetting = disableBrightnessSetting;
}
- (BOOL)disableBrightnessSetting {
    return _disableBrightnessSetting;
}

- (void)setDisableVolumeSetting:(BOOL)disableVolumeSetting {
    _disableVolumeSetting = disableVolumeSetting;
}
- (BOOL)disableVolumeSetting {
    return _disableVolumeSetting;
}

@end



#pragma mark -

@implementation SJBaseVideoPlayer (ViewController)
/// You should call it when view did appear
- (void)vc_viewDidAppear {
    self.vc_isDisappeared = NO;
}
/// You should call it when view will disappear
- (void)vc_viewWillDisappear {
    self.vc_isDisappeared = YES;
}
- (void)vc_viewDidDisappear {
    [self pause];
}
- (BOOL)vc_prefersStatusBarHidden {
    if ( _tmpShowStatusBar ) return NO;
    if ( _tmpHiddenStatusBar ) return YES;
    if ( self.lockedScreen ) return YES;
    if ( self.rotationManager.transitioning ) {
        if ( !self.disabledControlLayerAppearManager && self.controlLayerIsAppeared )
            return NO;
        else
            return YES;
    }
    if ( self.modalViewControllerManager.isPresentedModalViewControlller ) {
        if ( self.modalViewControllerManager.isTransitioning )
            return NO;
        else
            return !self.controlLayerIsAppeared;
    }
    // 全屏播放时, 使状态栏根据控制层显示或隐藏
    if ( self.isFullScreen )
        return !self.controlLayerIsAppeared;
    return NO;
}
- (UIStatusBarStyle)vc_preferredStatusBarStyle {
    if ( self.modalViewControllerManager.isPresentedModalViewControlller ) {
        return UIStatusBarStyleLightContent;
    }
    // 全屏播放时, 使状态栏变成白色
    if ( self.isFullScreen || self.fitOnScreen ) return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
}

- (void)setVc_isDisappeared:(BOOL)vc_isDisappeared {
    _vc_isDisappeared = vc_isDisappeared;
}
- (BOOL)vc_isDisappeared {
    return _vc_isDisappeared;
}

- (void)needShowStatusBar {
    if ( _tmpShowStatusBar ) return;
    _tmpShowStatusBar = YES;
    [self.atViewController setNeedsStatusBarAppearanceUpdate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_tmpShowStatusBar = NO;
    });
}

- (void)needHiddenStatusBar {
    if ( _tmpHiddenStatusBar ) return;
    _tmpHiddenStatusBar = YES;
    [self.atViewController setNeedsStatusBarAppearanceUpdate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_tmpHiddenStatusBar = NO;
    });
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
    if ( self.playbackController.duration == 0 ) return 0;
    return self.playbackController.bufferLoadedTime / self.playbackController.duration;
}

- (NSTimeInterval)currentTime {
    return self.playbackController.currentTime;
}

- (NSTimeInterval)totalTime {
    return self.playbackController.duration;
}

- (NSString *)currentTimeStr {
    return [self timeStringWithSeconds:self.currentTime];
}

- (NSString *)totalTimeStr {
    return [self timeStringWithSeconds:self.totalTime];
}

- (void)setPlayTimeDidChangeExeBlok:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))playTimeDidChangeExeBlok {
    _playTimeDidChangeExeBlok = playTimeDidChangeExeBlok;
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))playTimeDidChangeExeBlok {
    return _playTimeDidChangeExeBlok;
}

- (void)setPlayDidToEndExeBlock:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))playDidToEndExeBlock {
    _playDidToEndExeBlock = playDidToEndExeBlock;
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))playDidToEndExeBlock {
    return _playDidToEndExeBlock;
}
@end


#pragma mark - Gesture

@implementation SJBaseVideoPlayer (GestureControl)

- (void)setGestureControl:(id<SJPlayerGestureControl> _Nullable)gestureControl {
    _gestureControl = gestureControl;
    [self _needUpdateGestureControlProperties];
}

- (id<SJPlayerGestureControl>)gestureControl {
    if ( _gestureControl )
        return _gestureControl;
    _gestureControl = [[SJPlayerGestureControl alloc] initWithTargetView:self.controlContentView];
    [self _needUpdateGestureControlProperties];
    return _gestureControl;
}

- (void)_needUpdateGestureControlProperties {
    if ( !_gestureControl )
        return;
    
    __weak typeof(self) _self = self;
    _gestureControl.gestureRecognizerShouldTrigger = ^BOOL(id<SJPlayerGestureControl>  _Nonnull control, SJPlayerGestureType type, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        
        if ( self.isLockedScreen )
            return NO;
        
        if ( [self playStatus_isInactivity_ReasonPlayFailed] )
            return NO;
        
        if ( SJPlayerGestureType_Pan == type ) {
            if ( self.totalTime <= 0 )
                return NO;
            
            if ( self.isPlayOnScrollView ) {
                if ( self.useFitOnScreenAndDisableRotation &&
                    !self.isFitOnScreen ) {
                    return NO;
                }
                else if ( !self.isFullScreen ) {
                    return NO;
                }
            }
        }
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:gestureRecognizerShouldTrigger:location:)] ) {
            if ( ![self.controlLayerDelegate videoPlayer:self gestureRecognizerShouldTrigger:type location:location] )
                return NO;
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        else if ( [self.controlLayerDelegate respondsToSelector:@selector(triggerGesturesCondition:)] ) {
            if ( ![self.controlLayerDelegate triggerGesturesCondition:location] )
                return NO;
        }
#pragma clang diagnostic pop
        return YES;
    };
    
    _gestureControl.singleTapHandler = ^(id<SJPlayerGestureControl>  _Nonnull control, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.controlLayerAppearManager switchAppearState];
    };
    
    _gestureControl.doubleTapHandler = ^(id<SJPlayerGestureControl>  _Nonnull control, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        
        if ( [self playStatus_isPlaying] )
            [self pause];
        else
            [self play];
    };
    
    _gestureControl.panHandler = ^(id<SJPlayerGestureControl>  _Nonnull control, SJPanGestureTriggeredPosition position, SJPanGestureMovingDirection direction, SJPanGestureRecognizerState state, CGPoint translate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        switch ( state ) {
            case SJPanGestureRecognizerStateBegan: {
                switch ( direction ) {
                        /// 水平
                    case SJPanGestureMovingDirection_H: {
                        self.pan_shift = self.currentTime;
                        self.pan_totalTime = self.totalTime;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        if ( [self.controlLayerDelegate respondsToSelector:@selector(horizontalDirectionWillBeginDragging:)] ) {
                            [self.controlLayerDelegate horizontalDirectionWillBeginDragging:self];
                        }
#pragma clang diagnostic pop
                    }
                        break;
                        /// 垂直
                    case SJPanGestureMovingDirection_V: {
                        switch ( position ) {
                                /// brightness
                            case SJPanGestureTriggeredPosition_Left: {
                                if ( self.disableBrightnessSetting ) {
                                    [control cancelGesture:SJPlayerGestureType_Pan];
                                    #ifdef DEBUG
                                        printf("SJBaseVideoPlayer<%p>.disableBrightnessSetting = %s;\n", self, self.disableBrightnessSetting?"YES":"NO");
                                    #endif
                                }
                            }
                                break;
                                /// Volume
                            case SJPanGestureTriggeredPosition_Right: {
                                if ( self.mute || self.disableVolumeSetting ) {
                                    [control cancelGesture:SJPlayerGestureType_Pan];
                                    #ifdef DEBUG
                                        printf("SJBaseVideoPlayer<%p>.mute = %s;\n", self, self.mute?"YES":"NO");
                                        printf("SJBaseVideoPlayer<%p>.disableVolumeSetting = %s;\n", self, self.disableVolumeSetting?"YES":"NO");
                                    #endif
                                }
                            }
                                break;
                        }
                    }
                        break;
                }
            }
                break;
            case SJPanGestureRecognizerStateChanged: {
                switch ( direction ) {
                        /// 水平
                    case SJPanGestureMovingDirection_H: {
                        CGFloat offset = translate.x;
                        CGFloat add = offset / 667 * self.pan_totalTime;
                        CGFloat shift = self.pan_shift;
                        shift += add;
                        if ( shift > self.pan_totalTime ) shift = self.pan_totalTime;
                        else if ( shift < 0 ) shift = 0;
                        self.pan_shift = shift;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:horizontalDirectionDidMove:)] ) {
                            CGFloat progress = shift / self.pan_totalTime;
                            [self.controlLayerDelegate videoPlayer:self horizontalDirectionDidMove:progress];
                        }
                        else if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:horizontalDirectionDidDrag:)] ) {
                            [self.controlLayerDelegate videoPlayer:self horizontalDirectionDidDrag:add];
                        }
#pragma clang diagnostic pop
                    }
                        break;
                        /// 垂直
                    case SJPanGestureMovingDirection_V: {
                        switch ( position ) {
                                /// brightness
                            case SJPanGestureTriggeredPosition_Left: {
                                CGFloat value = self.deviceBrightness - translate.y * 0.005;
                                if ( value < 1.0 / 16 ) value = 1.0 / 16;
                                self.deviceBrightness = value;
                            }
                                break;
                                /// volume
                            case SJPanGestureTriggeredPosition_Right: {
                                CGFloat value = translate.y * 0.005;
                                self.deviceVolume -= value;
                            }
                                break;
                        }
                    }
                        break;
                }
            }
                break;
            case SJPanGestureRecognizerStateEnded: {
                switch ( direction ) {
                    case SJPanGestureMovingDirection_H: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        if ( [self.controlLayerDelegate respondsToSelector:@selector(horizontalDirectionDidEndDragging:)] ) {
                            [self.controlLayerDelegate horizontalDirectionDidEndDragging:self];
                        }
#pragma clang diagnostic pop
                    }
                        break;
                    case SJPanGestureMovingDirection_V: { }
                        break;
                }
            }
                break;
        }
        
        if ( direction == SJPanGestureMovingDirection_H ) {
            if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:panGestureTriggeredInTheHorizontalDirection:progressTime:)] ) {
                [self.controlLayerDelegate videoPlayer:self panGestureTriggeredInTheHorizontalDirection:state progressTime:self.pan_shift];
            }
        }
    };
    
    _gestureControl.pinchHandler = ^(id<SJPlayerGestureControl>  _Nonnull control, CGFloat scale) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.playbackController.videoGravity = scale > 1 ?AVLayerVideoGravityResizeAspectFill:AVLayerVideoGravityResizeAspect;
    };
}

- (void)setDisabledGestures:(SJPlayerDisabledGestures)disabledGestures {
    _gestureControl.disabledGestures = disabledGestures;
}

- (SJPlayerDisabledGestures)disabledGestures {
    return _gestureControl.disabledGestures;
}

@end


#pragma mark - 控制层

@implementation SJBaseVideoPlayer (ControlLayer)
/// 控制层需要显示
- (void)controlLayerNeedAppear {
    [self.controlLayerAppearManager needAppear];
}

/// 控制层需要隐藏
- (void)controlLayerNeedDisappear {
    [self.controlLayerAppearManager needDisappear];
}

- (void)setControlLayerAppearManager:(id<SJControlLayerAppearManager> _Nullable)controlLayerAppearManager {
    _controlLayerAppearManager = controlLayerAppearManager;
    [self _needUpdateControlLayerAppearManagerProperties];
}
- (id<SJControlLayerAppearManager>)controlLayerAppearManager {
    if ( _controlLayerAppearManager )
        return _controlLayerAppearManager;
    _controlLayerAppearManager = [[SJControlLayerAppearStateManager alloc] init];
    [self _needUpdateControlLayerAppearManagerProperties];
    return _controlLayerAppearManager;
}

- (void)_needUpdateControlLayerAppearManagerProperties {
    if ( !_controlLayerAppearManager )
        return;
    
    __weak typeof(self) _self = self;
    _controlLayerAppearManager.canAutomaticallyDisappear = ^BOOL(id<SJControlLayerAppearManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;

        if ( [self.controlLayerDelegate respondsToSelector:@selector(controlLayerOfVideoPlayerCanAutomaticallyDisappear:)] ) {
            if ( ![self.controlLayerDelegate controlLayerOfVideoPlayerCanAutomaticallyDisappear:self] ) {
                return NO;
            }
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        else if ( [self.controlLayerDelegate respondsToSelector:@selector(controlLayerDisappearCondition)] ) {
            if ( !self.controlLayerDelegate.controlLayerDisappearCondition )
                return NO;
        }
#pragma clang diagnostic pop
        return YES;
    };
    
    _controlLayerAppearManagerObserver = [_controlLayerAppearManager getObserver];
    _controlLayerAppearManagerObserver.appearStateDidChangeExeBlock = ^(id<SJControlLayerAppearManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
        if ( mgr.isAppeared ) {
            if ( [self.controlLayerDelegate respondsToSelector:@selector(controlLayerNeedAppear:)] ) {
                [self.controlLayerDelegate controlLayerNeedAppear:self];
            }
        }
        else {
            if ( [self.controlLayerDelegate respondsToSelector:@selector(controlLayerNeedDisappear:)] ) {
                [self.controlLayerDelegate controlLayerNeedDisappear:self];
            }
        }
        
        if ( self.controlLayerAppearStateDidChangeExeBlock )
            self.controlLayerAppearStateDidChangeExeBlock(self, mgr.isAppeared);

        if ( !self.rotationManager.isFullscreen ||
              self.rotationManager.transitioning ) {
            [UIView animateWithDuration:0 animations:^{
            } completion:^(BOOL finished) {
                [[self atViewController] setNeedsStatusBarAppearanceUpdate];
            }];
        }
        else {
            [UIView animateWithDuration:0.25 animations:^{
                [[self atViewController] setNeedsStatusBarAppearanceUpdate];
            }];
        }
    };
}

/// 是否禁止控制层管理
- (void)setDisabledControlLayerAppearManager:(BOOL)disabledControlLayerAppearManager {
    self.controlLayerAppearManager.disabled = disabledControlLayerAppearManager;
}
- (BOOL)disabledControlLayerAppearManager {
    return self.controlLayerAppearManager.isDisabled;
}

/// 控制层是否显示
- (void)setControlLayerIsAppeared:(BOOL)controlLayerIsAppeared {
    if ( controlLayerIsAppeared ) {
        [self.controlLayerAppearManager needAppear];
    }
    else {
        [self.controlLayerAppearManager needDisappear];
    }
}
- (BOOL)controlLayerIsAppeared {
    return self.controlLayerAppearManager.isAppeared;
}

/// 暂停时是否保持控制层一直显示
- (void)setPausedToKeepAppearState:(BOOL)pausedToKeepAppearState {
    _pausedToKeepAppearState = pausedToKeepAppearState;
}
- (BOOL)pausedToKeepAppearState {
    return _pausedToKeepAppearState;
}

/// 资源初始化完成后, 是否自动显示控制层
- (void)setControlLayerAutoAppearWhenAssetInitialized:(BOOL)controlLayerAutoAppearWhenAssetInitialized {
    _controlLayerAutoAppearWhenAssetInitialized = controlLayerAutoAppearWhenAssetInitialized;
}
- (BOOL)controlLayerAutoAppearWhenAssetInitialized {
    return _controlLayerAutoAppearWhenAssetInitialized;
}

/// 控制层显示状态改变时的回调
- (void)setControlLayerAppearStateDidChangeExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlLayerAppearStateDidChangeExeBlock {
    _controlLayerAppearStateDidChangeExeBlock = controlLayerAppearStateDidChangeExeBlock;
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlLayerAppearStateDidChangeExeBlock {
    return _controlLayerAppearStateDidChangeExeBlock;
}
@end


@implementation SJBaseVideoPlayer (ModalViewControlller)

- (void)setModalViewControllerManager:(nullable id<SJModalViewControlllerManagerProtocol>)modalViewControllerManager {
    _mvcm_modalViewControllerManager = modalViewControllerManager;
    [self _needUpdateModalViewControllerManagerProperties];
}
- (id<SJModalViewControlllerManagerProtocol>)modalViewControllerManager {
    if ( _mvcm_modalViewControllerManager )
        return _mvcm_modalViewControllerManager;
    _mvcm_modalViewControllerManager = [[SJModalViewControlllerManager alloc] init];
    [self _needUpdateModalViewControllerManagerProperties];
    return _mvcm_modalViewControllerManager;
}

- (void)setNeedPresentModalViewControlller:(BOOL)needPresentModalViewControlller {
    _mvcm_needPresentModalViewControlller = needPresentModalViewControlller;
}
- (BOOL)needPresentModalViewControlller {
    return _mvcm_needPresentModalViewControlller;
}

- (void)_needUpdateModalViewControllerManagerProperties {
    if ( !_mvcm_modalViewControllerManager )
        return;
    
}

- (void)presentModalViewControlller {
    NSAssert(self.needPresentModalViewControlller, @"You must set `player.needPresentModalViewControlller` to Yes.");

    if ( self.modalViewControllerManager.isPresentedModalViewControlller )
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_mvcm_targetSuperView = [[UIView alloc] initWithFrame:self.view.bounds];
        self->_mvcm_targetSuperView.backgroundColor = UIColor.blackColor;
        self->_mvcm_targetSuperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:self->_mvcm_targetSuperView atIndex:0];
        [self->_mvcm_targetSuperView addSubview:self.presentView];
        self.rotationManager.superview = self->_mvcm_targetSuperView;
        
        [self.modalViewControllerManager presentModalViewControlllerWithTarget:self->_mvcm_targetSuperView targetSuperView:self.view player:(id)self completion:nil];
    });
}
- (void)dismissModalViewControlller {
    if ( !self.needPresentModalViewControlller )
        return;
    
    if ( !self.modalViewControllerManager.isPresentedModalViewControlller )
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.modalViewControllerManager dismissModalViewControlllerCompletion:^{
            [self controlLayerNeedAppear];
            [self.view insertSubview:self.presentView atIndex:0];
            self.rotationManager.superview = self.view;
            [self->_mvcm_targetSuperView removeFromSuperview];
            self->_mvcm_targetSuperView = nil;
        }];
    });
}

@end



#pragma mark - 充满屏幕

@implementation SJBaseVideoPlayer (FitOnScreen)
- (void)setFitOnScreenManager:(id<SJFitOnScreenManager> _Nullable)fitOnScreenManager {
    _fitOnScreenManager = fitOnScreenManager;
    [self _needUpdateFitOnScreenManagerProperties];
}
- (id<SJFitOnScreenManager>)fitOnScreenManager {
    if ( _fitOnScreenManager )
        return _fitOnScreenManager;
    _fitOnScreenManager = [[SJFitOnScreenManager alloc] initWithTarget:self.presentView targetSuperview:self.view];
    [self _needUpdateFitOnScreenManagerProperties];
    return _fitOnScreenManager;
}
- (void)_needUpdateFitOnScreenManagerProperties {
    if ( !_fitOnScreenManager )
        return;
    
    _fitOnScreenManagerObserver = [_fitOnScreenManager getObserver];
    __weak typeof(self) _self = self;
    _fitOnScreenManagerObserver.fitOnScreenWillBeginExeBlock = ^(id<SJFitOnScreenManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self controlLayerNeedDisappear];
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:willFitOnScreen:)] ) {
            [self.controlLayerDelegate videoPlayer:self willFitOnScreen:mgr.isFitOnScreen];
        }
        
        if ( self.fitOnScreenWillBeginExeBlock )
            self.fitOnScreenWillBeginExeBlock(self);
        
        [UIView performWithoutAnimation:^{
            [[self atViewController] setNeedsStatusBarAppearanceUpdate];
        }];
    };
    
    _fitOnScreenManagerObserver.fitOnScreenDidEndExeBlock = ^(id<SJFitOnScreenManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:didCompleteFitOnScreen:)] ) {
            [self.controlLayerDelegate videoPlayer:self didCompleteFitOnScreen:mgr.isFitOnScreen];
        }
        
        if ( self.fitOnScreenDidEndExeBlock )
            self.fitOnScreenDidEndExeBlock(self);
    };
}

- (BOOL)isFitOnScreen {
    return self.fitOnScreenManager.isFitOnScreen;
}
- (void)setFitOnScreen:(BOOL)fitOnScreen {
    [self setFitOnScreen:fitOnScreen animated:YES];
}
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated {
    [self setFitOnScreen:fitOnScreen animated:animated completionHandler:nil];
}

- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated completionHandler:(nullable void(^)(__kindof SJBaseVideoPlayer *player))completionHandler {
    self.useFitOnScreenAndDisableRotation = YES;
    
    __weak typeof(self) _self = self;
    [self.fitOnScreenManager setFitOnScreen:fitOnScreen animated:animated completionHandler:^(id<SJFitOnScreenManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completionHandler ) completionHandler(self);
    }];
}

- (void)setUseFitOnScreenAndDisableRotation:(BOOL)useFitOnScreenAndDisableRotation {
    _useFitOnScreenAndDisableRotation = useFitOnScreenAndDisableRotation;
}
- (BOOL)useFitOnScreenAndDisableRotation {
    return _useFitOnScreenAndDisableRotation;
}

- (void)setFitOnScreenWillBeginExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))fitOnScreenWillBeginExeBlock {
    _fitOnScreenWillBeginExeBlock = fitOnScreenWillBeginExeBlock;
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))fitOnScreenWillBeginExeBlock {
    return _fitOnScreenWillBeginExeBlock;
}

- (void)setFitOnScreenDidEndExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))fitOnScreenDidEndExeBlock {
    _fitOnScreenDidEndExeBlock = fitOnScreenDidEndExeBlock;
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))fitOnScreenDidEndExeBlock {
    return _fitOnScreenDidEndExeBlock;
}
@end


#pragma mark - 屏幕旋转

@implementation SJBaseVideoPlayer (Rotation)

- (void)setRotationManager:(nullable id<SJRotationManagerProtocol>)rotationManager {
    _rotationManager = rotationManager;
    [self _configRotationManager:rotationManager];
}

- (id<SJRotationManagerProtocol>)rotationManager {
    if ( _rotationManager ) return _rotationManager;
    _rotationManager = [[SJRotationManager alloc] init];
    [self _configRotationManager:_rotationManager];
    return _rotationManager;
}

- (void)_configRotationManager:(id<SJRotationManagerProtocol>)rotationManager {
    if ( !rotationManager )
        return;
    rotationManager.superview = self.view;
    rotationManager.target = self.presentView;
    __weak typeof(self) _self = self;
    rotationManager.shouldTriggerRotation = ^BOOL(id<SJRotationManagerProtocol>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        if ( !self.view.superview ) return NO;
        if ( self.touchedScrollView ) return NO;
        if ( self.isPlayOnScrollView && !self.isScrollAppeared ) return NO;
        if ( self.isLockedScreen ) return NO;
        if ( self.registrar.state == SJVideoPlayerAppState_ResignActive ) return NO;
        if ( self.useFitOnScreenAndDisableRotation ) return NO;
        if ( self.vc_isDisappeared ) return NO;
        if ( self.isTriggeringForPopGesture ) return NO;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(canTriggerRotationOfVideoPlayer:)] ) {
            if ( ![self.controlLayerDelegate canTriggerRotationOfVideoPlayer:self] )
                return NO;
        }
        if ( self.needPresentModalViewControlller && !self.modalViewControllerManager.isPresentedModalViewControlller ) return NO;
        if ( self.modalViewControllerManager.isTransitioning ) return NO;
        if ( self.atViewController.presentedViewController ) return NO;
        return YES;
    };
    
    _rotationManagerObserver = [rotationManager getObserver];
    _rotationManagerObserver.rotationDidStartExeBlock = ^(id<SJRotationManagerProtocol>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.atViewController.navigationController.view.userInteractionEnabled = NO;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:willRotateView:)] ) {
            [self.controlLayerDelegate videoPlayer:self willRotateView:mgr.isFullscreen];
        }
        
        if ( self.viewWillRotateExeBlock )
            self.viewWillRotateExeBlock(self, mgr.isFullscreen);
        
        [self controlLayerNeedDisappear];
        
        ///
        /// Thanks @SuperEvilRabbit
        /// https://github.com/changsanjiang/SJVideoPlayer/issues/58
        ///
        [UIView animateWithDuration:0 animations:^{
        } completion:^(BOOL finished) {
            if ( mgr.isFullscreen )
                [self needHiddenStatusBar];
            else
                [self needShowStatusBar];
        }];
    };
    
    _rotationManagerObserver.rotationDidEndExeBlock = ^(id<SJRotationManagerProtocol>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.atViewController.navigationController.view.userInteractionEnabled = YES;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:didEndRotation:)] ) {
            [self.controlLayerDelegate videoPlayer:self didEndRotation:mgr.isFullscreen];
        }
        if ( self.viewDidRotateExeBlock ) self.viewDidRotateExeBlock(self, mgr.isFullscreen);
        [UIView animateWithDuration:0.25 animations:^{
            [[self atViewController] setNeedsStatusBarAppearanceUpdate];
        }];
    };
}

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
    [self.rotationManager rotate];
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated {
    [self.rotationManager rotate:orientation animated:animated];
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completion:(void (^ _Nullable)(__kindof SJBaseVideoPlayer *player))block {
    __weak typeof(self) _self = self;
    [self.rotationManager rotate:orientation animated:animated completionHandler:^(id<SJRotationManagerProtocol>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
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
    _viewWillRotateExeBlock = viewWillRotateExeBlock;
}
- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))viewWillRotateExeBlock {
    return _viewWillRotateExeBlock;
}

- (void)setViewDidRotateExeBlock:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))viewDidRotateExeBlock {
    _viewDidRotateExeBlock = viewDidRotateExeBlock;
}
- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))viewDidRotateExeBlock {
    return _viewDidRotateExeBlock;
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
    return [_playbackController screenshot];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block {
    [self screenshotWithTime:time size:CGSizeZero completion:block];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block {
    if ( [_playbackController respondsToSelector:@selector(screenshotWithTime:size:completion:)] ) {
        __weak typeof(self) _self = self;
        [(id<SJMediaPlaybackScreenshotController>)_playbackController screenshotWithTime:time size:size completion:^(id<SJMediaPlaybackController>  _Nonnull controller, UIImage * _Nullable image, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                if ( block ) block(self, image, error);
            });
        }];
    }
    else {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"errorMsg":[NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.playbackController does not implement the screenshot method", self]}];
        if ( block ) block(self, nil, error);
#ifdef DEBUG
        printf("%s\n", error.userInfo.description.UTF8String);
#endif
    }
}

- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(__kindof SJBaseVideoPlayer *player, NSArray<id<SJVideoPlayerPreviewInfo>> *__nullable images, NSError *__nullable error))block {
    if ( [_playbackController respondsToSelector:@selector(generatedPreviewImagesWithMaxItemSize:completion:)] ) {
        itemSize = CGSizeMake(ceil(itemSize.width), ceil(itemSize.height));
        __weak typeof(self) _self = self;
        [(id<SJMediaPlaybackScreenshotController>)_playbackController generatedPreviewImagesWithMaxItemSize:itemSize completion:^(__kindof id<SJMediaPlaybackController>  _Nonnull controller, NSArray<id<SJVideoPlayerPreviewInfo>> * _Nullable images, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( block ) block(self, images, error);
        }];
    }
    else {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"errorMsg":[NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.playbackController does not implement the generatedPreviewImages method", self]}];
        if ( block ) block(self, nil, error);
#ifdef DEBUG
        printf("%s\n", error.userInfo.description.UTF8String);
#endif
    }
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
    if ( [_playbackController respondsToSelector:@selector(exportWithBeginTime:endTime:presetName:progress:completion:failure:)] ) {
        __weak typeof(self) _self = self;
        [(id<SJMediaPlaybackExportController>)_playbackController exportWithBeginTime:beginTime endTime:endTime presetName:presetName progress:^(id<SJMediaPlaybackController>  _Nonnull controller, float progress) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( progressBlock ) progressBlock(self, progress);
        } completion:^(id<SJMediaPlaybackController>  _Nonnull controller, NSURL * _Nullable fileURL, UIImage * _Nullable thumbImage) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( completion ) completion(self, fileURL, thumbImage);
        } failure:^(id<SJMediaPlaybackController>  _Nonnull controller, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( failure ) failure(self, error);
        }];
    }
    else {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"errorMsg":[NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.playbackController does not implement the exportWithBeginTime:endTime:presetName:progress:completion:failure: method", self]}];
        if ( failure ) failure(self, error);
#ifdef DEBUG
        printf("%s\n", error.userInfo.description.UTF8String);
#endif
    }
}

- (void)cancelExportOperation {
    if ( [_playbackController respondsToSelector:@selector(cancelExportOperation)] ) {
        [(id<SJMediaPlaybackExportController>)_playbackController cancelExportOperation];
    }
}

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                        progress:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, float progress))progressBlock
                      completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage *imageGIF, UIImage *thumbnailImage, NSURL *filePath))completion
                         failure:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, NSError *error))failure {
    if ( [_playbackController respondsToSelector:@selector(generateGIFWithBeginTime:duration:maximumSize:interval:gifSavePath:progress:completion:failure:)] ) {
        NSURL *filePath = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"SJGeneratedGif.gif"]];
        __weak typeof(self) _self = self;
        [(id<SJMediaPlaybackExportController>)_playbackController generateGIFWithBeginTime:beginTime duration:duration maximumSize:CGSizeMake(375, 375) interval:0.1f gifSavePath:filePath progress:^(id<SJMediaPlaybackController>  _Nonnull controller, float progress) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( progressBlock ) progressBlock(self, progress);
        } completion:^(id<SJMediaPlaybackController>  _Nonnull controller, UIImage * _Nonnull imageGIF, UIImage * _Nonnull screenshot) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( completion ) completion(self, imageGIF, screenshot, filePath);
        } failure:^(id<SJMediaPlaybackController>  _Nonnull controller, NSError * _Nonnull error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( failure ) failure(self, error);
        }];
    }
    else {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"errorMsg":[NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.playbackController does not implement the generateGIFWithBeginTime:duration:maximumSize:interval:gifSavePath:progress:completion:failure: method", self]}];
        if ( failure ) failure(self, error);
#ifdef DEBUG
        printf("%s\n", error.userInfo.description.UTF8String);
#endif
    }
}

- (void)cancelGenerateGIFOperation {
    if ( [_playbackController respondsToSelector:@selector(cancelGenerateGIFOperation)] ) {
        [(id<SJMediaPlaybackExportController>)_playbackController cancelGenerateGIFOperation];
    }
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

- (void)setPlayerViewWillAppearExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))playerViewWillAppearExeBlock {
    _playerViewWillAppearExeBlock = playerViewWillAppearExeBlock;
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))playerViewWillAppearExeBlock {
    return _playerViewWillAppearExeBlock;
}

- (void)setPlayerViewWillDisappearExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))playerViewWillDisappearExeBlock {
    _playerViewWillDisappearExeBlock = playerViewWillDisappearExeBlock;
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))playerViewWillDisappearExeBlock {
    return _playerViewWillDisappearExeBlock;
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
        config.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
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
    
    if ( _playerViewWillAppearExeBlock )
        _playerViewWillAppearExeBlock(self);
}
- (void)playerWillDisappearForObserver:(nonnull SJPlayModelPropertiesObserver *)observer {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayerWillDisappearInScrollView:)] ) {
        [self.controlLayerDelegate videoPlayerWillDisappearInScrollView:self];
    }
    
    if ( _playerViewWillDisappearExeBlock )
        _playerViewWillDisappearExeBlock(self);
}
@end


#pragma mark -

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

- (BOOL)controlViewDisplayed __deprecated_msg("use `controlLayerIsAppeared`") {
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

- (void)setPlaceholder:(nullable UIImage *)placeholder __deprecated_msg("use `player.placeholderImageView`") {
    self.placeholderImageView.image = placeholder;
}

- (nullable UIImage *)placeholder __deprecated_msg("use `player.placeholderImageView`") {
    return self.placeholderImageView.image;
}

- (void)setPlayFailedToKeepAppearState:(BOOL)playFailedToKeepAppearState __deprecated { }
- (BOOL)playFailedToKeepAppearState __deprecated {
    return NO;
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlLayerAppearStateChanged __deprecated_msg("use `controlLayerAppearStateDidChangeExeBlock`") {
    return self.controlLayerAppearStateDidChangeExeBlock;
}

- (void)setControlLayerAppearStateChanged:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlLayerAppearStateChanged __deprecated_msg("use `controlLayerAppearStateDidChangeExeBlock`") {
    self.controlLayerAppearStateDidChangeExeBlock = controlLayerAppearStateChanged;
}

- (void)setControlLayerAppeared:(BOOL)controlLayerAppeared __deprecated_msg("use `controlLayerIsAppeared`") {
    self.controlLayerIsAppeared = controlLayerAppeared;
}

- (BOOL)controlLayerAppeared __deprecated_msg("use `controlLayerIsAppeared`") {
    return self.controlLayerIsAppeared;
}

- (BOOL)enableControlLayerDisplayController __deprecated_msg("use `disabledControlLayerAppearManager`") {
    return !self.controlLayerAppearManager.disabled;
}

- (void)setEnableControlLayerDisplayController:(BOOL)enableControlLayerDisplayController __deprecated_msg("use `disabledControlLayerAppearManager`") {
    self.controlLayerAppearManager.disabled = !enableControlLayerDisplayController;
}

- (void)setFitOnScreenWillChangeExeBlock:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))fitOnScreenWillChangeExeBlock __deprecated_msg("use `fitOnScreenWillBeginExeBlock`") {
    self.fitOnScreenWillBeginExeBlock = fitOnScreenWillChangeExeBlock;
}
- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))fitOnScreenWillChangeExeBlock __deprecated_msg("use `fitOnScreenWillBeginExeBlock`") {
    return self.fitOnScreenWillBeginExeBlock;
}

- (void)setFitOnScreenDidChangeExeBlock:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))fitOnScreenDidChangeExeBlock __deprecated_msg("use `fitOnScreenDidEndExeBlock`") {
    self.fitOnScreenDidEndExeBlock = fitOnScreenDidChangeExeBlock;
}
- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))fitOnScreenDidChangeExeBlock __deprecated_msg("use `fitOnScreenDidEndExeBlock`") {
    return self.fitOnScreenDidEndExeBlock;
}

- (void)setAutoPlay:(BOOL)autoPlay __deprecated_msg("use `autoPlayWhenPlayStatusIsReadyToPlay`") {
    self.autoPlayWhenPlayStatusIsReadyToPlay = autoPlay;
}
- (BOOL)isAutoPlay __deprecated_msg("use `autoPlayWhenPlayStatusIsReadyToPlay`") {
    return self.autoPlayWhenPlayStatusIsReadyToPlay;
}

- (void)setRateChanged:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))rateChanged __deprecated_msg("use `rateDidChangeExeBlock`") {
    self.rateDidChangeExeBlock = rateChanged;
}
- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))rateChanged __deprecated_msg("use `rateDidChangeExeBlock`") {
    return self.rateDidChangeExeBlock;
}

- (void)setDisableGestureTypes:(SJDisablePlayerGestureTypes)disableGestureTypes __deprecated_msg("use `disabledGestures`") {
    self.disabledGestures = (NSInteger)disableGestureTypes;
}
- (SJDisablePlayerGestureTypes)disableGestureTypes __deprecated_msg("use `disabledGestures`") {
    return (NSInteger)self.disabledGestures;
}

- (void)setVolume:(float)volume __deprecated_msg("use `deviceVolume`") {
    self.deviceVolume = volume;
}
- (float)volume __deprecated_msg("use `deviceVolume`") {
    return self.deviceVolume;
}

- (void)setBrightness:(float)brightness __deprecated_msg("use `deviceBrightness`") {
    self.deviceBrightness = brightness;
}
- (float)brightness __deprecated_msg("use `deviceBrightness`") {
    return self.deviceBrightness;
}

- (void)setPlayStatusDidChangeExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))playStatusDidChangeExeBlock __deprecated_msg("use `_playStatusObserver = [_player getPlayStatusObserver]`") {
    _playStatusDidChangeExeBlock = playStatusDidChangeExeBlock;
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))playStatusDidChangeExeBlock __deprecated_msg("use `_playStatusObserver = [_player getPlayStatusObserver]`") {
    return _playStatusDidChangeExeBlock;
}
@end
NS_ASSUME_NONNULL_END
