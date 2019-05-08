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
#import "SJBaseVideoPlayerStatistics.h"
#import "SJBaseVideoPlayerAutoRefreshController.h"
#import "SJVCRotationManager.h"
#import "SJPlayerView.h"
#import "SJPlayStatusObserver.h"

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
static NSInteger _SJBaseVideoPlayerViewTag = 10000;

typedef struct _SJPlayerControlInfo {
    struct _PanGesture {
        NSTimeInterval offsetTime; ///< pan手势触发过程中的偏移量(secs)
    } pan;
    
    struct _StatusBar {
        BOOL tmpShow :1;
        BOOL tmpHidden :1;
    } statusBar;
    
    struct _PlaceholderImageView {
        BOOL hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay :1;
        NSTimeInterval delayInSecondsForHiddenPlaceholderImageView;
    } placeholder;
    
    struct _ViewController {
        BOOL isDisappeared :1;
    } vc;
    
    struct _ScrollControl {
        BOOL pauseWhenScrollDisappeared :1;
        BOOL hiddenViewWhenScrollDisappeared :1;
        BOOL resumePlaybackWhenScrollAppeared :1;
    } scrollControl;
    
    struct _DeviceVolumeAndBrightnableess {
        BOOL disableBrightnessSetting :1;
        BOOL disableVolumeSetting :1;
    } deviceVolumeAndBrightness;
    
    struct _Rotation {
        BOOL able;
    } rotation;
    
//    struct _PlaybackControl {
//
//    } plaback;
    
} _SJPlayerControlInfo;

@interface SJBaseVideoPlayer ()
@property (nonatomic) SJVideoPlayerPlayState state __deprecated_msg("已弃用, 请使用`playStatus`");
@property (nonatomic) SJVideoPlayerPlayStatus playStatus;
@property (nonatomic) _SJPlayerControlInfo *controlInfo;

/// - 记录资源初始化期间用户的操作(初始化完成后, 将会调用该block)
@property (nonatomic, copy, nullable) void(^operationOfInitializing)(SJBaseVideoPlayer *player);

/// - 管理对象: 监听 App在前台, 后台, 耳机插拔, 来电等的通知
@property (nonatomic, strong, readonly) SJVideoPlayerRegistrar *registrar;

/// - 控制层的父视图
@property (nonatomic, strong, readonly) UIView *controlContentView;

/// - 视频画面的呈现层
@property (nonatomic, strong, readonly) SJVideoPlayerPresentView *presentView;

/// - 锁屏状态下触发的手势.
/// - 当播放器被锁屏时, 用户单击后, 会触发这个手势, 调用`controlLayerDelegate`的方法: `tappedPlayerOnTheLockedState:`
@property (nonatomic, strong, readonly) UITapGestureRecognizer *lockStateTapGesture;

/// - observe视图的滚动
@property (nonatomic, strong, nullable) SJPlayModelPropertiesObserver *playModelObserver;

/// - 播放失败时, 自动刷新(当设置 `delayToAutoRefreshWhenPlayFailed` 才会触发)
@property (nonatomic, strong, nullable) SJBaseVideoPlayerAutoRefreshController *autoRefresh;
@end

@implementation UITabBarController (SJBaseVideoPlayerAdded)
- (UIViewController *)sj_topViewController {
    if ( self.selectedIndex == NSNotFound )
        return self.viewControllers.firstObject;
    return self.selectedViewController;
}

- (BOOL)shouldAutorotate {
    return [[self sj_topViewController] shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [[self sj_topViewController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self sj_topViewController] preferredInterfaceOrientationForPresentation];
}
@end

@implementation UINavigationController (SJBaseVideoPlayerAdded)
- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}
@end

@interface UIViewController (SJBaseVideoPlayerAdded)
- (BOOL)sj_shouldAutorotate;
- (UIInterfaceOrientationMask)sj_supportedInterfaceOrientations;
@end

@implementation UIViewController (SJBaseVideoPlayerAdded)
static void
sj_swizzleMethod(Class cls, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (void)load {
    sj_swizzleMethod([UIViewController class], @selector(shouldAutorotate), @selector(sj_shouldAutorotate));
    sj_swizzleMethod([UIViewController class], @selector(supportedInterfaceOrientations), @selector(sj_supportedInterfaceOrientations));
}

- (BOOL)sj_shouldAutorotate {
    if ( !self.nextResponder ) return NO;
    SJBaseVideoPlayer *_Nullable player = [self sj_viewPlayer];
    if ( player ) {
        if ( [player.rotationManager isKindOfClass:[SJVCRotationManager class]] ) {
            SJVCRotationManager *mgr = player.rotationManager;
            return [mgr vc_shouldAutorotate];
        }
        return NO;
    }
    return [self sj_shouldAutorotate];
}

- (UIInterfaceOrientationMask)sj_supportedInterfaceOrientations {
    if ( !self.nextResponder ) return UIInterfaceOrientationMaskPortrait;
    SJBaseVideoPlayer *_Nullable player = [self sj_viewPlayer];
    if ( player ) {
        if ( [player.rotationManager isKindOfClass:[SJVCRotationManager class]] ) {
            SJVCRotationManager *mgr = player.rotationManager;
            return [mgr vc_supportedInterfaceOrientations];
        }
        return UIInterfaceOrientationMaskPortrait;
    }
    return [self sj_supportedInterfaceOrientations];
}

- (SJBaseVideoPlayer *_Nullable)sj_viewPlayer {
    __kindof UIView *_Nullable view = [self.view viewWithTag:_SJBaseVideoPlayerViewTag];
    if ( view && [view isKindOfClass:[SJPlayerView class]] ) {
        return [(SJPlayerView *)view player];
    }
    return nil;
}
@end

@implementation SJBaseVideoPlayer {
    UIView *_view;
    SJVideoPlayerPresentView *_presentView;
    UIView *_controlContentView;
    SJVideoPlayerRegistrar *_registrar;
    
    /// 当前资源是否播放过
    /// mpc => Media Playback Controller
    id<SJVideoPlayerURLAssetObserver> _Nullable _mpc_assetObserver;
    
    /// device volume And brightness manager
    id<SJDeviceVolumeAndBrightnessManager> _deviceVolumeAndBrightnessManager;
    id<SJDeviceVolumeAndBrightnessManagerObserver> _deviceVolumeAndBrightnessManagerObserver;

    /// gestures
    UITapGestureRecognizer *_lockStateTapGesture;
    SJPlayerGestureControl *_gestureControl;
    BOOL(^_Nullable _gestureRecognizerShouldTrigger)(__kindof SJBaseVideoPlayer *player, SJPlayerGestureType type, CGPoint location);
    
    /// playback controller
    NSError *_Nullable _error;
    id<SJMediaPlaybackController> _playbackController;
    void (^_Nullable _assetDeallocExeBlock)(__kindof SJBaseVideoPlayer * _Nonnull);
    BOOL _lockedScreen;
    BOOL _autoPlayWhenPlayStatusIsReadyToPlay;
    BOOL _resumePlaybackWhenAppDidEnterForeground;
    BOOL(^_Nullable _canPlayAnAsset)(__kindof SJBaseVideoPlayer *player);
    void(^_Nullable _rateDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
    void(^_Nullable _playTimeDidChangeExeBlok)(__kindof SJBaseVideoPlayer *videoPlayer);
    void(^_Nullable _playDidToEndExeBlock)(__kindof SJBaseVideoPlayer *player);
    SJVideoPlayerPlayStatus _playStatus;
    void(^_Nullable _playStatusDidChangeExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer);
    SJVideoPlayerURLAsset *_URLAsset;
    BOOL(^_Nullable _canSeekToTime)(__kindof SJBaseVideoPlayer *player);
    NSTimeInterval _delayToAutoRefreshWhenPlayFailed;
    SJBaseVideoPlayerAutoRefreshController *_Nullable _autoRefresh;
    void(^_Nullable _presentationSizeDidChangeExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer);
    BOOL _pauseWhenAppDidEnterBackground;
    
    /// control layer appear manager
    id<SJControlLayerAppearManager> _controlLayerAppearManager;
    id<SJControlLayerAppearManagerObserver> _controlLayerAppearManagerObserver;
    BOOL(^_Nullable _canAutomaticallyDisappear)(__kindof SJBaseVideoPlayer *player);
    void(^_Nullable _controlLayerAppearStateDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player, BOOL state);
    BOOL _pausedToKeepAppearState;
    BOOL _controlLayerAutoAppearWhenAssetInitialized;
    BOOL _disabledControlLayerAppearManager;
    
    /// rotation manager
    id<SJRotationManagerProtocol> _rotationManager;
    id<SJRotationManagerObserver> _rotationManagerObserver;
    BOOL(^_Nullable _shouldTriggerRotation)(__kindof SJBaseVideoPlayer *player);
    void(^_Nullable _viewWillRotateExeBlock)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen);
    void(^_Nullable _viewDidRotateExeBlock)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen);;
    
    /// Fit on screen manager
    id<SJFitOnScreenManager> _fitOnScreenManager;
    id<SJFitOnScreenManagerObserver> _fitOnScreenManagerObserver;
    BOOL _useFitOnScreenAndDisableRotation;
    void(^_Nullable _fitOnScreenWillBeginExeBlock)(__kindof SJBaseVideoPlayer *player);
    void(^_Nullable _fitOnScreenDidEndExeBlock)(__kindof SJBaseVideoPlayer *player);
    
    BOOL _autoManageViewToFitOnScreenOrRotation;
    
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
    return @"2.4.4";
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
    _controlInfo = (_SJPlayerControlInfo *)calloc(1, sizeof(struct _SJPlayerControlInfo));
    _controlInfo->placeholder.hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay = YES;
    _controlInfo->scrollControl.pauseWhenScrollDisappeared = YES;
    _controlInfo->scrollControl.hiddenViewWhenScrollDisappeared = YES;
    _controlInfo->scrollControl.resumePlaybackWhenScrollAppeared = YES;
    
    self.autoPlayWhenPlayStatusIsReadyToPlay = YES; // 是否自动播放, 默认yes
    self.pauseWhenAppDidEnterBackground = YES; // App进入后台是否暂停播放, 默认yes
    self.autoManageViewToFitOnScreenOrRotation = YES;
    
    [self view];
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
    [self _setRotationAbleValue:@(YES)];
    [self rotationManager];
    [self registrar];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self addInterceptTapGR];
        [self reachability];
        [self gestureControl];
        [self _configAVAudioSession];
        if ( SJBaseVideoPlayer.isEnabledStatistics ) [self.statistics observePlayer:(id)self];
    });
    return self;
}

- (void)_configAVAudioSession {
    if ( AVAudioSession.sharedInstance.category != AVAudioSessionCategoryPlayback &&
         AVAudioSession.sharedInstance.category != AVAudioSessionCategoryPlayAndRecord ) {
        NSError *error = nil;
        // 使播放器在静音状态下也能放出声音
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        if ( error ) NSLog(@"%@", error.userInfo);
    }
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"SJVideoPlayerLog: %d - %s", (int)__LINE__, __func__);
#endif
    free(_controlInfo);
    if ( _autoRefresh ) [_autoRefresh cancel];
    if ( _URLAsset && self.assetDeallocExeBlock ) self.assetDeallocExeBlock(self);
    [_presentView removeFromSuperview];
    [_view removeFromSuperview];
}

- (void)setPlayStatus:(SJVideoPlayerPlayStatus)playStatus {
    /// 所有播放状态, 均在`PlayControl`分类中维护
    /// 所有播放状态, 均在`PlayControl`分类中维护
    _playStatus = playStatus;
    
#ifdef DEBUG
    printf("%s\n", [self getPlayStatusStr:playStatus].UTF8String);
#endif
    
    if ( _playStatusDidChangeExeBlock )
        _playStatusDidChangeExeBlock(self);
    
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
    
    if ( [self playStatus_isPaused_ReasonPause] ) {
        if ( self.pausedToKeepAppearState ) {
            [self.controlLayerAppearManager keepAppearState];
        }
    }
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:statusDidChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self statusDidChanged:playStatus];
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:stateChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self stateChanged:self.state];
        }
#pragma clang diagnostic pop
    }
    
    if ( [self playStatus_isInactivity_ReasonPlayEnd] ) {
        if ( self.playDidToEndExeBlock ) {
            self.playDidToEndExeBlock(self);
        }
        // auto play next visible asset
        if ( self.view.window ) {
            UIScrollView *scrollView = sj_getScrollView(_URLAsset.playModel);
            if ( scrollView.sj_enabledAutoplay ) {
                [scrollView sj_playNextVisibleAsset];
            }
        }
    }
}

- (void)setControlLayerDataSource:(nullable id<SJVideoPlayerControlLayerDataSource>)controlLayerDataSource {
    if ( controlLayerDataSource == _controlLayerDataSource ) return;
    _controlLayerDataSource = controlLayerDataSource;
    
    if ( !controlLayerDataSource ) return;
    
    _controlLayerDataSource.controlView.clipsToBounds = YES;
    
    // install
    _controlLayerDataSource.controlView.frame = self.controlContentView.bounds;
    _controlLayerDataSource.controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.controlContentView addSubview:_controlLayerDataSource.controlView];
    
    if ( [self.controlLayerDataSource respondsToSelector:@selector(installedControlViewToVideoPlayer:)] ) {
        [self.controlLayerDataSource installedControlViewToVideoPlayer:self];
    }
}

- (void)_showOrHiddenPlaceholderImageViewIfNeeded {
    if ( _playbackController.isReadyForDisplay ) {
        if ( _controlInfo->placeholder.hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay ) {
            [self.presentView hiddenPlaceholderAnimated:YES delay:_controlInfo->placeholder.delayInSecondsForHiddenPlaceholderImageView];
        }
    }
    else {
        [self.presentView showPlaceholderAnimated:NO];
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
    SJPlayerView *view = [SJPlayerView new];
    _view = view;
    view.tag = _SJBaseVideoPlayerViewTag;
    view.player = self;
    view.backgroundColor = [UIColor blackColor];
    
    __weak typeof(self) _self = self;
    [(SJPlayerView *)_view setWillMoveToWindowExeBlock:^(SJPlayerView * _Nonnull view, UIWindow *window) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.playModelObserver refreshAppearState];
    }];
    
    [view addSubview:self.presentView];
    [_presentView addSubview:self.controlContentView];
    _presentView.autoresizingMask =
    _controlContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _presentView.frame =
    _controlContentView.frame = view.bounds;
    return _view;
}

- (void)addInterceptTapGR {
    UITapGestureRecognizer *intercept = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInterceptTapGR:)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addGestureRecognizer:intercept];
    });
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
        if ( [self.controlLayerDelegate respondsToSelector:@selector(receivedApplicationWillResignActiveNotification:)] ) {
            [self.controlLayerDelegate receivedApplicationWillResignActiveNotification:self];
        }
    };
    
    _registrar.didBecomeActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        BOOL canPlay = [self playStatus_isPaused_ReasonPause] && self.resumePlaybackWhenAppDidEnterForeground;
        if ( self.isPlayOnScrollView ) {
            if ( canPlay && self.isScrollAppeared ) [self play];
        }
        else {
            if ( canPlay ) [self play];
        }
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(receivedApplicationDidBecomeActiveNotification:)] ) {
            [self.controlLayerDelegate receivedApplicationDidBecomeActiveNotification:self];
        }
    };
    
    _registrar.willEnterForeground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(receivedApplicationWillEnterForegroundNotification:)] ) {
            [self.controlLayerDelegate receivedApplicationWillEnterForegroundNotification:self];
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_setRotationAbleValue:) object:nil];
        [self performSelector:@selector(_setRotationAbleValue:) withObject:@(YES) afterDelay:1];
    };
    
    _registrar.didEnterBackground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(receivedApplicationDidEnterBackgroundNotification:)] ) {
            [self.controlLayerDelegate receivedApplicationDidEnterBackgroundNotification:self];
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_setRotationAbleValue:) object:nil];
        [self _setRotationAbleValue:@(NO)];
    };
    return _registrar;
}

- (void)_setRotationAbleValue:(NSNumber *)able {
    _controlInfo->rotation.able = [able boolValue];
}

- (SJVideoPlayerPlayState)state {
    switch ( self.playStatus ) {
        case SJVideoPlayerPlayStatusUnknown:
            return SJVideoPlayerPlayState_Unknown;
        case SJVideoPlayerPlayStatusPrepare:
        case SJVideoPlayerPlayStatusReadyToPlay:
            return SJVideoPlayerPlayState_Prepare;
        case SJVideoPlayerPlayStatusPlaying:
            return SJVideoPlayerPlayState_Playing;
        case SJVideoPlayerPlayStatusPaused: {
            switch ( self.pausedReason ) {
                case SJVideoPlayerPausedReasonUnknown: break;
                case SJVideoPlayerPausedReasonBuffering:
                    return SJVideoPlayerPlayState_Buffing;
                case SJVideoPlayerPausedReasonPause:
                    return SJVideoPlayerPlayState_Paused;
                case SJVideoPlayerPausedReasonSeeking:
                    return SJVideoPlayerPlayState_Buffing;
            }
        }
            break;
        case SJVideoPlayerPlayStatusInactivity:
            switch ( self.inactivityReason ) {
                case SJVideoPlayerPausedReasonUnknown: break;
                case SJVideoPlayerInactivityReasonPlayEnd:
                    return SJVideoPlayerPlayState_PlayEnd;
                case SJVideoPlayerInactivityReasonPlayFailed:
                    return SJVideoPlayerPlayState_PlayFailed;
                case SJVideoPlayerInactivityReasonNotReachableAndPlaybackStalled:
                    return SJVideoPlayerPlayState_PlayFailed;
            }
            break;
    }
    return SJVideoPlayerPlayState_Unknown;
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

- (void)_updateCurrentPlayingIndexPathIfNeeded:(SJPlayModel *)playModel {
    if ( !playModel )
        return;
    
    // 维护当前播放的indexPath
    UIScrollView *scrollView = sj_getScrollView(playModel);
    if ( scrollView.sj_enabledAutoplay ) {
        scrollView.sj_currentPlayingIndexPath = [playModel performSelector:@selector(indexPath)];
    }
}

/// - 当用户触摸到TableView或者ScrollView时, 这个值为YES.
/// - 这个值用于旋转的条件之一, 如果用户触摸在TableView或者ScrollView上时, 将不会自动旋转.
- (BOOL)touchedOnTheScrollView {
    return _playModelObserver.isTouchedTablView || _playModelObserver.isTouchedCollectionView;
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
    _controlInfo->placeholder.hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay = hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay;
}

- (BOOL)hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay {
    return _controlInfo->placeholder.hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay;
}

- (void)setDelayInSecondsForHiddenPlaceholderImageView:(NSTimeInterval)delayInSecondsForHiddenPlaceholderImageView {
    _controlInfo->placeholder.delayInSecondsForHiddenPlaceholderImageView = delayInSecondsForHiddenPlaceholderImageView;
}
- (NSTimeInterval)delayInSecondsForHiddenPlaceholderImageView {
    return _controlInfo->placeholder.delayInSecondsForHiddenPlaceholderImageView;
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
    
    _flipTransitionManager = [[SJFlipTransitionManager alloc] initWithTarget:self.playbackController.playerView];
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
    _playbackController.pauseWhenAppDidEnterBackground = _pauseWhenAppDidEnterBackground;
    if ( _playbackController.playerView.superview != self.presentView ) {
        _playbackController.playerView.frame = self.presentView.bounds;
        _playbackController.playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_presentView insertSubview:_playbackController.playerView atIndex:0];
    }
    if ( _playbackController.rate != self.rate ) _playbackController.rate = self.rate;
    if ( _playbackController.videoGravity != self.videoGravity ) _playbackController.videoGravity = self.videoGravity;
}

- (void)switchVideoDefinition:(SJVideoPlayerURLAsset *)URLAsset {
    [self.playbackController switchVideoDefinition:URLAsset];
}

- (SJMediaPlaybackType)playbackType {
    return _playbackController.playbackType;
}

- (id<SJPlayStatusObserver>)getPlayStatusObserver {
    return [[SJPlayStatusObserver alloc] initWithPlayer:(id)self];
}

- (NSError *_Nullable)error {
    return _playbackController.error;
}

- (SJVideoPlayerInactivityReason)inactivityReason {
    return _playbackController.inactivityReason;
}
- (SJVideoPlayerPausedReason)pausedReason {
    return _playbackController.pausedReason;
}

// 1.
- (void)setURLAsset:(nullable SJVideoPlayerURLAsset *)URLAsset {
    if ( _URLAsset ) {
        if ( self.assetDeallocExeBlock )
            self.assetDeallocExeBlock(self);
    }
    _URLAsset = URLAsset;
    [self _updateAssetObservers];
    // prepareToPlay
    self.playbackController.media = URLAsset;
    if ( URLAsset ) {
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:prepareToPlay:)] ) {
            [self.controlLayerDelegate videoPlayer:self prepareToPlay:URLAsset];
        }
        [self.playbackController prepareToPlay];
    }
    else {
        [self stop];
    }
}
- (nullable SJVideoPlayerURLAsset *)URLAsset {
    return _URLAsset;
}

- (void)_updateAssetObservers {
    [self _updateCurrentPlayingIndexPathIfNeeded:_URLAsset.playModel];
    [self _updatePlayModelObserver:_URLAsset.playModel];
    _mpc_assetObserver = [_URLAsset getObserver];
    __weak typeof(self) _self = self;
    _mpc_assetObserver.playModelDidChangeExeBlock = ^(SJVideoPlayerURLAsset * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateCurrentPlayingIndexPathIfNeeded:asset.playModel];
        [self _updatePlayModelObserver:asset.playModel];
    };
}

- (void)refresh {
    if ( !self.URLAsset ) return;
    [_playbackController refresh];
}

- (void)setDelayToAutoRefreshWhenPlayFailed:(NSTimeInterval)delayToAutoRefreshWhenPlayFailed {
    _delayToAutoRefreshWhenPlayFailed = delayToAutoRefreshWhenPlayFailed;
    [_autoRefresh cancel];
    if ( delayToAutoRefreshWhenPlayFailed > 0 ) {
        _autoRefresh = [[SJBaseVideoPlayerAutoRefreshController alloc] initWithPlayer:(id)self];
    }
    else {
        _autoRefresh = nil;
    }
}
- (NSTimeInterval)delayToAutoRefreshWhenPlayFailed {
    return _delayToAutoRefreshWhenPlayFailed;
}

- (void)setAssetDeallocExeBlock:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))assetDeallocExeBlock {
    _assetDeallocExeBlock = assetDeallocExeBlock;
}
- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))assetDeallocExeBlock {
    return _assetDeallocExeBlock;
}

- (void)setPlayerVolume:(float)playerVolume {
    self.playbackController.volume = playerVolume;
}
- (float)playerVolume {
    return self.playbackController.volume;
}

- (void)setMute:(BOOL)mute {
    self.playbackController.mute = mute;
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:muteChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self muteChanged:mute];
    }
}
- (BOOL)isMute {
    return self.playbackController.mute;
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
    if ( [self.controlLayerDelegate respondsToSelector:@selector(canPerformPlayForVideoPlayer:)] ) {
        if ( ![self.controlLayerDelegate canPerformPlayForVideoPlayer:self] )
            return;
    }
    
    if ( !self.URLAsset ) return;
    if ( _canPlayAnAsset && !_canPlayAnAsset(self) ) return;
    if ( self.registrar.state == SJVideoPlayerAppState_Background && self.pauseWhenAppDidEnterBackground ) return;

    if ( [self playStatus_isInactivity_ReasonPlayFailed] ) {
        [self refresh];
        return;
    }

    if ( [self playStatus_isPrepare] && self.playbackController.prepareStatus != SJMediaPlaybackPrepareStatusReadyToPlay ) {
        // 记录操作, 待资源初始化完成后调用
        self.operationOfInitializing = ^(SJBaseVideoPlayer * _Nonnull player) {
            if ( player.autoPlayWhenPlayStatusIsReadyToPlay ) [player play];
        };
        return;
    }

    [_playbackController play];

    [self.controlLayerAppearManager resume];
}

- (void)pause {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(canPerformPauseForVideoPlayer:)] ) {
        if ( ![self.controlLayerDelegate canPerformPauseForVideoPlayer:self] )
            return;
    }
    
    if ( !self.URLAsset ) return;
    if ( [self playStatus_isPaused_ReasonPause] ) return;
    if ( [self playStatus_isPrepare] ) {
        self.operationOfInitializing = ^(SJBaseVideoPlayer * _Nonnull player) {
            [player pause];
        };
        return;
    }
    
    [self.playbackController pause];
}

- (void)stop {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(canPerformStopForVideoPlayer:)] ) {
        if ( ![self.controlLayerDelegate canPerformStopForVideoPlayer:self] )
            return;
    }
    
    _operationOfInitializing = nil;
    [_playbackController stop];
    _playModelObserver = nil;
    _URLAsset = nil;
}

- (void)stopAndFadeOut {
    [self.view sj_fadeOutAndCompletion:^(UIView *view) {
        [view removeFromSuperview];
        [self stop];
    }];
}

- (BOOL)isReplayed {
    return _playbackController.isReplayed;
}

- (void)replay {
    if ( !self.URLAsset ) return;
    if ( [self playStatus_isInactivity_ReasonPlayFailed] ) {
        [self refresh];
        return;
    }
    
    [_playbackController replay];
}

- (void)setCanSeekToTime:(BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))canSeekToTime {
    _canSeekToTime = canSeekToTime;
}
- (BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))canSeekToTime {
    return _canSeekToTime;
}

- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    if ( isnan(secs) ) {
        return;
    }
    
    if ( self.canPlayAnAsset && !self.canPlayAnAsset(self) ) {
        return;
    }

    if ( [self playStatus_isUnknown] || [self playStatus_isInactivity_ReasonPlayFailed] ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    if ( secs > self.playbackController.duration ) {
        secs = self.playbackController.duration * 0.98;
    }
    else if ( secs < 0 ) {
        secs = 0;
    }
    [self.playbackController seekToTime:secs completionHandler:completionHandler];
}

- (void)setRate:(float)rate {
    if ( self.canPlayAnAsset && !self.canPlayAnAsset(self) ) {
        return;
    }
    
    if ( _playbackController.rate == rate )
        return;
    
    self.playbackController.rate = rate;
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:rateChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self rateChanged:rate];
    }
    
    if ( self.rateDidChangeExeBlock ) {
        self.rateDidChangeExeBlock(self);
    }
}

- (float)rate {
    return self.playbackController.rate;
}

- (void)setRateDidChangeExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))rateDidChangeExeBlock {
    _rateDidChangeExeBlock = rateDidChangeExeBlock;
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))rateDidChangeExeBlock {
    return _rateDidChangeExeBlock;
}

- (void)_updatePlayModelObserver:(SJPlayModel *)playModel {
    if ( !playModel )
        return;
    
    // update playModel
    self.playModelObserver = [[SJPlayModelPropertiesObserver alloc] initWithPlayModel:playModel];
    self.playModelObserver.delegate = (id)self;
    [self.playModelObserver refreshAppearState];
}

// - Playback Controll Delegate -
- (void)playbackController:(id<SJMediaPlaybackController>)controller playbackStatusDidChange:(SJVideoPlayerPlayStatus)playbackStatus {
    self.playStatus = playbackStatus;
    
    // ready to play
    if ( [self playStatus_isReadyToPlay] ) {
        // auto appear control layer if needed
        if ( !self.isLockedScreen && self.controlLayerAutoAppearWhenAssetInitialized ) {
            __weak typeof(self) _self = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                [self.controlLayerAppearManager needAppear];
            });
        }
        
        if ( self.operationOfInitializing ) {
            self.operationOfInitializing(self);
            self.operationOfInitializing = nil;
            return;
        }
        
        if ( _autoPlayWhenPlayStatusIsReadyToPlay ) {
            // - application enter forground
            if ( self.registrar.state != SJVideoPlayerAppState_Background ) {
                if ( self.isPlayOnScrollView ) {
                    if ( self.isScrollAppeared ) {
                        [self play];
                    }
                    else {
                        [self pause];
                    }
                }
                else {
                    [self play];
                }
            }
            // - application enter background
            else if ( !_pauseWhenAppDidEnterBackground ) {
                [self play];
            }
        }
    }
}

- (void)playbackController:(id<SJMediaPlaybackController>)controller bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus {
    [self _updateBufferStatus];
}

- (void)playbackController:(id<SJMediaPlaybackController>)controller durationDidChange:(NSTimeInterval)duration {
    [self _playTimeDidChange];
}

- (void)playbackController:(id<SJMediaPlaybackController>)controller currentTimeDidChange:(NSTimeInterval)currentTime {
    [self _playTimeDidChange];
}

- (void)mediaDidPlayToEndForPlaybackController:(id<SJMediaPlaybackController>)controller {
    /* nothing */
}

- (void)playbackController:(id<SJMediaPlaybackController>)controller presentationSizeDidChange:(CGSize)presentationSize {
    if ( _autoManageViewToFitOnScreenOrRotation && !self.isFullScreen && !self.isFitOnScreen ) {
        self.useFitOnScreenAndDisableRotation = presentationSize.width < presentationSize.height;
    }

    if ( self.presentationSizeDidChangeExeBlock )
        self.presentationSizeDidChangeExeBlock(self);
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:presentationSize:)] ) {
        [self.controlLayerDelegate videoPlayer:self presentationSize:presentationSize];
    }
}

- (void)playbackController:(id<SJMediaPlaybackController>)controller playbackTypeLoaded:(SJMediaPlaybackType)playbackType {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:playbackTypeLoaded:)] ) {
        [self.controlLayerDelegate videoPlayer:self playbackTypeLoaded:playbackType];
    }
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

- (void)playbackControllerIsReadyForDisplay:(id<SJMediaPlaybackController>)controller {
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
}

- (void)playbackController:(id<SJMediaPlaybackController>)controller switchingDefinitionStatusDidChange:(SJMediaPlaybackSwitchDefinitionStatus)status media:(id<SJMediaModelProtocol>)media {

    if ( status == SJMediaPlaybackSwitchDefinitionStatusFinished ) {
        _URLAsset = (id)media;
        [self _updateAssetObservers];
    }
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:switchingDefinitionStatusDidChange:media:)] ) {
        [self.controlLayerDelegate videoPlayer:self switchingDefinitionStatusDidChange:status media:media];
    }
}

- (void)_playTimeDidChange {
    if ( [self playStatus_isPaused] ) return;
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:currentTime:currentTimeStr:totalTime:totalTimeStr:)] ) {
        [self.controlLayerDelegate videoPlayer:self currentTime:self.currentTime currentTimeStr:self.currentTimeStr totalTime:self.totalTime totalTimeStr:self.totalTimeStr];
    }
    if ( self.playTimeDidChangeExeBlok ) self.playTimeDidChangeExeBlok(self);
}

- (void)_updateBufferStatus {
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
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:reachabilityChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self reachabilityChanged:status];
        }
        
        if ( self.networkStatusDidChangeExeBlock )
            self.networkStatusDidChangeExeBlock(self);
    };
}

///
/// Thanks @18138870200
/// https://github.com/18138870200/SGNetworkSpeed.git
///
- (NSString *)networkSpeedStr {
    return self.reachability.networkSpeedStr;
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
    if ( _controlInfo->deviceVolumeAndBrightness.disableBrightnessSetting )
        return;
    _deviceVolumeAndBrightnessManager.brightness = deviceBrightness;
}
- (float)deviceBrightness {
    return self.deviceVolumeAndBrightnessManager.brightness;
}

- (void)setDisableBrightnessSetting:(BOOL)disableBrightnessSetting {
    _controlInfo->deviceVolumeAndBrightness.disableBrightnessSetting = disableBrightnessSetting;
}
- (BOOL)disableBrightnessSetting {
    return _controlInfo->deviceVolumeAndBrightness.disableBrightnessSetting;
}

- (void)setDisableVolumeSetting:(BOOL)disableVolumeSetting {
    _controlInfo->deviceVolumeAndBrightness.disableVolumeSetting = disableVolumeSetting;
}
- (BOOL)disableVolumeSetting {
    return _controlInfo->deviceVolumeAndBrightness.disableVolumeSetting;
}

@end



#pragma mark -

@implementation SJBaseVideoPlayer (ViewController)
/// You should call it when view did appear
- (void)vc_viewDidAppear {
    _controlInfo->vc.isDisappeared = NO;
    [self.playModelObserver refreshAppearState];
}
/// You should call it when view will disappear
- (void)vc_viewWillDisappear {
    _controlInfo->vc.isDisappeared = YES;
}
- (void)vc_viewDidDisappear {
    [self pause];
}
- (BOOL)vc_prefersStatusBarHidden {
    if ( _controlInfo->statusBar.tmpShow )
        return NO;
    if ( _controlInfo->statusBar.tmpHidden )
        return YES;
    if ( self.lockedScreen )
        return YES;
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
    _controlInfo->vc.isDisappeared = vc_isDisappeared;
}
- (BOOL)vc_isDisappeared {
    return _controlInfo->vc.isDisappeared;
}

- (void)needShowStatusBar {
    if ( _controlInfo->statusBar.tmpShow ) return;
    _controlInfo->statusBar.tmpShow = YES;
    [self.atViewController setNeedsStatusBarAppearanceUpdate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.controlInfo->statusBar.tmpShow = NO;
    });
}

- (void)needHiddenStatusBar {
    if ( _controlInfo->statusBar.tmpHidden ) return;
    _controlInfo->statusBar.tmpHidden = YES;
    [self.atViewController setNeedsStatusBarAppearanceUpdate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.controlInfo->statusBar.tmpHidden = NO;
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

- (void)setGestureRecognizerShouldTrigger:(BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull, SJPlayerGestureType, CGPoint))gestureRecognizerShouldTrigger {
    _gestureRecognizerShouldTrigger = gestureRecognizerShouldTrigger;
}
- (BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull, SJPlayerGestureType, CGPoint))gestureRecognizerShouldTrigger {
    return _gestureRecognizerShouldTrigger;
}

- (void)_needUpdateGestureControlProperties {
    if ( !_gestureControl )
        return;
    
    __weak typeof(self) _self = self;
    _gestureControl.gestureRecognizerShouldTrigger = ^BOOL(id<SJPlayerGestureControl>  _Nonnull control, SJPlayerGestureType type, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        
        if ( self.isTransitioning )
            return NO;
        
        if ( self.isLockedScreen )
            return NO;
        
        if ( SJPlayerGestureType_Pan == type ) {
            if ( self.isPlayOnScrollView ) {
                if ( self.useFitOnScreenAndDisableRotation &&
                    !self.isFitOnScreen ) {
                    return NO;
                }
                else if ( !self.isFullScreen ) {
                    return NO;
                }
            }
            
            switch ( control.movingDirection ) {
                case SJPanGestureMovingDirection_H: {
                    if ( [self playStatus_isPrepare] ||
                         [self playStatus_isUnknown] )
                        return NO;
                    
                    if ( self.totalTime <= 0 )
                        return NO;
                    
                    if ( self.canSeekToTime ) {
                        if ( !self.canSeekToTime(self) ) {
                            return NO;
                        }
                    }
                    
                    if ( self.playbackType == SJMediaPlaybackTypeLIVE ) {
                        return NO;
                    }
                }
                    break;
                case SJPanGestureMovingDirection_V: {
                    switch ( control.triggeredPosition ) {
                            /// Brightness
                        case SJPanGestureTriggeredPosition_Left:
                            return !self.controlInfo->deviceVolumeAndBrightness.disableBrightnessSetting;
                            /// Volume
                        case SJPanGestureTriggeredPosition_Right:
                            return !self.controlInfo->deviceVolumeAndBrightness.disableVolumeSetting || self.mute;
                    }
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
        
        if ( self.gestureRecognizerShouldTrigger && !self.gestureRecognizerShouldTrigger(self, type, location) ) {
            return NO;
        }
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
                        if ( self.totalTime == 0 ) {
                            [control cancelGesture:SJPlayerGestureType_Pan];
                            return;
                        }
                        
                        self.controlInfo->pan.offsetTime = self.currentTime;
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        if ( [self.controlLayerDelegate respondsToSelector:@selector(horizontalDirectionWillBeginDragging:)] ) {
                            [self.controlLayerDelegate horizontalDirectionWillBeginDragging:self];
                        }
                    #pragma clang diagnostic pop
                    }
                        break;
                        /// 垂直
                    case SJPanGestureMovingDirection_V: { }
                        break;
                }
            }
                break;
            case SJPanGestureRecognizerStateChanged: {
                switch ( direction ) {
                        /// 水平
                    case SJPanGestureMovingDirection_H: {
                        NSTimeInterval totalTime = self.totalTime;
                        NSTimeInterval beforeOffsetTime = self.controlInfo->pan.offsetTime;
                        CGFloat tlt = translate.x;
                        CGFloat add = tlt / 667 * self.totalTime;
                        CGFloat offsetTime = beforeOffsetTime + add;
                        if ( offsetTime > totalTime ) offsetTime = totalTime;
                        else if ( offsetTime < 0 ) offsetTime = 0;
                        self.controlInfo->pan.offsetTime = offsetTime;
                        
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:horizontalDirectionDidMove:)] ) {
                            CGFloat progress = offsetTime / totalTime;
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
                [self.controlLayerDelegate videoPlayer:self panGestureTriggeredInTheHorizontalDirection:state progressTime:self.controlInfo->pan.offsetTime];
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
    self.gestureControl.disabledGestures = disabledGestures;
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

- (void)setCanAutomaticallyDisappear:(BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))canAutomaticallyDisappear {
    _canAutomaticallyDisappear = canAutomaticallyDisappear;
}
- (BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))canAutomaticallyDisappear {
    return _canAutomaticallyDisappear;
}

- (void)_needUpdateControlLayerAppearManagerProperties {
    if ( !_controlLayerAppearManager )
        return;
    
    _controlLayerAppearManager.disabled = _disabledControlLayerAppearManager;
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
        
        if ( self.canAutomaticallyDisappear && !self.canAutomaticallyDisappear(self) ) {
            return NO;
        }
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
    _disabledControlLayerAppearManager = disabledControlLayerAppearManager;
    _controlLayerAppearManager.disabled = disabledControlLayerAppearManager;
}
- (BOOL)disabledControlLayerAppearManager {
    return _disabledControlLayerAppearManager;
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
    
    if ( self.modalViewControllerManager.isTransitioning )
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

    if ( self.modalViewControllerManager.isTransitioning )
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



@implementation SJBaseVideoPlayer (AutoManageViewToFitOnScreenOrRotation)
- (void)setAutoManageViewToFitOnScreenOrRotation:(BOOL)autoManageViewToFitOnScreenOrRotation {
    _autoManageViewToFitOnScreenOrRotation = autoManageViewToFitOnScreenOrRotation;
}
- (BOOL)autoManageViewToFitOnScreenOrRotation {
    return _autoManageViewToFitOnScreenOrRotation;
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

- (void)setShouldTriggerRotation:(BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))shouldTriggerRotation {
    _shouldTriggerRotation = shouldTriggerRotation;
}
- (BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))shouldTriggerRotation {
    return _shouldTriggerRotation;
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
        UIWindow *_Nullable window = self.view.window;
        if ( window && !window.isKeyWindow ) return NO;
        if ( self.touchedOnTheScrollView ) return NO;
        if ( self.isPlayOnScrollView && !self.isScrollAppeared ) return NO;
        if ( self.isLockedScreen ) return NO;
        if ( self.registrar.state == SJVideoPlayerAppState_ResignActive ) return NO;
        if ( !self.controlInfo->rotation.able ) return NO;
        if ( self.useFitOnScreenAndDisableRotation ) return NO;
        if ( self.controlInfo->vc.isDisappeared ) return NO;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(canTriggerRotationOfVideoPlayer:)] ) {
            if ( ![self.controlLayerDelegate canTriggerRotationOfVideoPlayer:self] )
                return NO;
        }
        if ( self.needPresentModalViewControlller && !self.modalViewControllerManager.isPresentedModalViewControlller ) return NO;
        if ( self.modalViewControllerManager.isTransitioning ) return NO;
        if ( self.atViewController.presentedViewController ) return NO;
        if ( self.shouldTriggerRotation && !self.shouldTriggerRotation(self) ) return NO;
        return YES;
    };
    
    _rotationManagerObserver = [rotationManager getObserver];
    _rotationManagerObserver.rotationDidStartExeBlock = ^(id<SJRotationManagerProtocol>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
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



@implementation SJBaseVideoPlayer (Screenshot)

- (void)setPresentationSizeDidChangeExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))presentationSizeDidChangeExeBlock {
    _presentationSizeDidChangeExeBlock = presentationSizeDidChangeExeBlock;
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))presentationSizeDidChangeExeBlock {
    return _presentationSizeDidChangeExeBlock;
}

- (CGSize)videoPresentationSize {
    return _playbackController.presentationSize;
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
- (void)setPauseWhenScrollDisappeared:(BOOL)pauseWhenScrollDisappeared {
    _controlInfo->scrollControl.pauseWhenScrollDisappeared = pauseWhenScrollDisappeared;
}
- (BOOL)pauseWhenScrollDisappeared {
    return _controlInfo->scrollControl.pauseWhenScrollDisappeared;
}

- (void)setHiddenViewWhenScrollDisappeared:(BOOL)hiddenViewWhenScrollDisappeared {
    _controlInfo->scrollControl.hiddenViewWhenScrollDisappeared = hiddenViewWhenScrollDisappeared;
}
- (BOOL)hiddenViewWhenScrollDisappeared {
    return _controlInfo->scrollControl.hiddenViewWhenScrollDisappeared;
}

- (void)setResumePlaybackWhenScrollAppeared:(BOOL)resumePlaybackWhenScrollAppeared {
    _controlInfo->scrollControl.resumePlaybackWhenScrollAppeared = resumePlaybackWhenScrollAppeared;
}
- (BOOL)resumePlaybackWhenScrollAppeared {
    return _controlInfo->scrollControl.resumePlaybackWhenScrollAppeared;
}

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
@implementation SJBaseVideoPlayer (Statistics)
static BOOL _enabledStatistics;
+ (void)setEnabledStatistics:(BOOL)enabledStatistics {
    _enabledStatistics = enabledStatistics;
}
+ (BOOL)isEnabledStatistics {
    return _enabledStatistics;
}

static id<SJBaseVideoPlayerStatistics> _statistics;
+ (void)setStatistics:(nullable id<SJBaseVideoPlayerStatistics>)statistics {
    _statistics = statistics;
}
+ (id<SJBaseVideoPlayerStatistics>)statistics {
    if ( !_statistics ) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _statistics = [SJBaseVideoPlayerStatistics new];
        });
    }
    return _statistics;
}
- (void)setStatistics:(nullable id<SJBaseVideoPlayerStatistics>)statistics {
    SJBaseVideoPlayer.statistics = statistics;
}
- (id<SJBaseVideoPlayerStatistics>)statistics {
    return SJBaseVideoPlayer.statistics;
}
@end


#pragma mark -

@interface SJBaseVideoPlayer (SJPlayModelPropertiesObserverDelegate)<SJPlayModelPropertiesObserverDelegate>
@end

@implementation SJBaseVideoPlayer (SJPlayModelPropertiesObserverDelegate)
- (void)observer:(nonnull SJPlayModelPropertiesObserver *)observer userTouchedCollectionView:(BOOL)touched { /* nothing */ }
- (void)observer:(nonnull SJPlayModelPropertiesObserver *)observer userTouchedTableView:(BOOL)touched { /* nothing */ }

- (void)playerWillAppearForObserver:(nonnull SJPlayModelPropertiesObserver *)observer superview:(nonnull UIView *)superview {
    if ( _controlInfo->scrollControl.hiddenViewWhenScrollDisappeared ) {
        _view.hidden = NO;
    }
    
    if ( _playbackController.isPlayed ) {
        if ( !_controlInfo->vc.isDisappeared ) {
            if ( self.isPlayOnScrollView ) {
                if ( _controlInfo->scrollControl.resumePlaybackWhenScrollAppeared ) {
                    [self play];
                }
            }
        }
    }
    
    if ( superview && self.view.superview != superview ) {
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
    if ( _controlInfo->scrollControl.pauseWhenScrollDisappeared ) {
        [self pause];
    }

    _view.hidden = _controlInfo->scrollControl.hiddenViewWhenScrollDisappeared;
    
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

- (void)setPlayStatusDidChangeExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))playStatusDidChangeExeBlock {
    _playStatusDidChangeExeBlock = playStatusDidChangeExeBlock;
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))playStatusDidChangeExeBlock {
    return _playStatusDidChangeExeBlock;
}
- (void)playWithURL:(NSURL *)URL {
    self.assetURL = URL;
}
- (void)setAssetURL:(nullable NSURL *)assetURL {
    self.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:assetURL];
}

- (nullable NSURL *)assetURL {
    return self.URLAsset.mediaURL;
}

- (void)setPresentationSize:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, CGSize))presentationSize __deprecated_msg("use `presentationSizeDidChangeExeBlock`") {
    __weak typeof(self) _self = self;
    self.presentationSizeDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( presentationSize ) presentationSize(self, videoPlayer.videoPresentationSize);
    };
    objc_setAssociatedObject(self, @selector(presentationSize), presentationSize, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull, CGSize))presentationSize __deprecated_msg("use `presentationSizeDidChangeExeBlock`") {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)switchVideoDefinitionByURL:(NSURL *)URL {
    [self switchVideoDefinition:[[SJVideoPlayerURLAsset alloc] initWithURL:URL playModel:_URLAsset.playModel]];
}
@end
NS_ASSUME_NONNULL_END
