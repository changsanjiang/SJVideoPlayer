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
#import "SJPlayerGestureControl.h"
#import "SJVolBrigControl.h"
#import "UIView+SJVideoPlayerAdd.h"
#import "SJVideoPlayerRegistrar.h"
#import "SJVideoPlayerPresentView.h"
#import "SJPlayModelPropertiesObserver.h"
#import "SJAVMediaPlayAsset+SJAVMediaPlaybackControllerAdd.h"
#import "SJBaseVideoPlayer+PlayStatus.h"
#import "SJTimerControl.h"
#import "UIScrollView+ListViewAutoplaySJAdd.h"
#import "SJAVMediaPlaybackController.h"

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

#if __has_include(<Reachability/Reachability.h>)
#import <Reachability/Reachability.h>
#else
#import "Reachability.h"
#endif

#if __has_include(<SJFullscreenPopGesture/UINavigationController+SJVideoPlayerAdd.h>)
#import <SJFullscreenPopGesture/UINavigationController+SJVideoPlayerAdd.h>
#endif

NS_ASSUME_NONNULL_BEGIN
static UIScrollView *_Nullable _getScrollViewOfPlayModel(SJPlayModel *playModel) {
    if ( playModel.isPlayInTableView || playModel.isPlayInCollectionView ) {
        __kindof UIView *superview = playModel.playerSuperview;
        while ( superview && ![superview isKindOfClass:[UIScrollView class]] ) {
            superview = superview.superview;
        }
        return superview;
    }
    return nil;
}

@interface SJPlayerView : UIView
@property (nonatomic, copy, nullable) void(^willMoveToWindowExeBlock)(SJPlayerView *view, UIWindow *_Nullable window);
@end

@implementation SJPlayerView
- (void)willMoveToWindow:(nullable UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if ( _willMoveToWindowExeBlock ) _willMoveToWindowExeBlock(self, newWindow);
}
@end

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
@property (nonatomic, strong, null_resettable) id<SJRotationManagerProtocol> rotationManager;

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
 管理对象: 播放控制
 */
@property (null_resettable, nonatomic, strong) id<SJMediaPlaybackController> playbackController;

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

/// 临时显示状态栏
@property (nonatomic) BOOL tmpShowStatusBar;
/// 临时隐藏状态栏
@property (nonatomic) BOOL tmpHiddenStatusBar;
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
    CGFloat _rate;
    SJVideoPlayerPlayStatus _playStatus;
    SJVideoPlayerPausedReason _pausedReason;
    SJVideoPlayerInactivityReason _inactivityReason;
    SJVideoPlayerURLAsset *_URLAsset;
}

+ (instancetype)player {
    return [[self alloc] init];
}

+ (NSString *)version {
    return @"1.7.1";
}

- (nullable __kindof UIViewController *)atViewController {
    if ( _view.superview == nil ) return nil;
    UIResponder *responder = _view.nextResponder;
    while ( ![responder isKindOfClass:[UIViewController class]] ) {
        responder = responder.nextResponder;
        if ( [responder isMemberOfClass:[UIResponder class]] || !responder ) return nil;
    }
    return (__kindof UIViewController *)responder;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    if ( AVAudioSession.sharedInstance.category != AVAudioSessionCategoryPlayback ||
         AVAudioSession.sharedInstance.category != AVAudioSessionCategoryPlayAndRecord ) {
        NSError *error = nil;
        // 使播放器在静音状态下也能放出声音
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        if ( error ) NSLog(@"%@", error.userInfo);
    }
    self.rate = 1;
    self.autoPlay = YES; // 是否自动播放, 默认yes
    self.pauseWhenAppDidEnterBackground = YES; // App进入后台是否暂停播放, 默认yes
    self.enableControlLayerDisplayController = YES; // 是否启用控制层管理器, 默认yes
    self.playFailedToKeepAppearState = YES; // 播放失败是否保持控制层显示, 默认yes
    [self registrar];
    [self view];
    [self rotationManager];
    [self gestureControl];
    [self reachabilityObserver];
    [self addInterceptTapGR];
    [self _considerShowOrHiddenPlaceholder];
    return self;
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
}

- (void)setPlayStatus:(SJVideoPlayerPlayStatus)playStatus {
    NSString *playStatusStr = [self getPlayStatusStr:playStatus];
    if ( [playStatusStr isEqualToString:_playStatusStr] ) return;
    
    /// 所有播放状态, 均在`PlayControl`分类中维护
    /// 所有播放状态, 均在`PlayControl`分类中维护
    _playStatus = playStatus;
    _playStatusStr = playStatusStr;
    
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
            }
            break;
    }
#pragma clang diagnostic pop
    
    [self _considerShowOrHiddenPlaceholder];
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:statusDidChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self statusDidChanged:playStatus];
        }
    });
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

- (void)_considerShowOrHiddenPlaceholder {
    if ( [self playStatus_isUnknown] || [self playStatus_isPrepare] ) {
        if ( !self.URLAsset.otherMedia ) {
            if ( [NSThread.currentThread isMainThread] ) [self.presentView showPlaceholder];
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.presentView showPlaceholder];
                });
            }
        }
    }
    else if ( [self playStatus_isPlaying] ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.4 animations:^{
                [self.presentView hiddenPlaceholder];
            }];
        });
    }
}

///
/// Thanks @chjsun
/// https://github.com/changsanjiang/SJVideoPlayer/issues/42
///
- (UIImageView *)placeholderImageView {
    return self.presentView.placeholderImageView;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _playbackController.videoGravity = videoGravity;
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
            [self _observeFullscreenPopGestureState];
        });
    }];
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
- (void)setRotationManager:(nullable id<SJRotationManagerProtocol>)rotationManager {
    if ( !rotationManager ) rotationManager = [SJRotationManager new];
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
    rotationManager.superview = self.view;
    rotationManager.target = self.presentView;
    __weak typeof(self) _self = self;
    rotationManager.rotationCondition = ^BOOL(id<SJRotationManagerProtocol>  _Nonnull mgr) {
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
        return YES;
    };
    rotationManager.delegate = self;
}

- (void)rotationManager:(SJRotationManager *)manager willRotateView:(BOOL)isFullscreen {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:willRotateView:)] ) {
        [self.controlLayerDelegate videoPlayer:self willRotateView:isFullscreen];
    }
    if ( self.viewWillRotateExeBlock ) self.viewWillRotateExeBlock(self, isFullscreen);
    
    [[self atViewController] setNeedsStatusBarAppearanceUpdate];
}
- (void)rotationManager:(SJRotationManager *)manager didRotateView:(BOOL)isFullscreen {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:didEndRotation:)] ) {
        [self.controlLayerDelegate videoPlayer:self didEndRotation:isFullscreen];
    }
    if ( self.viewDidRotateExeBlock ) self.viewDidRotateExeBlock(self, manager.isFullscreen);
    [UIView animateWithDuration:0.25 animations:^{
        [[self atViewController] setNeedsStatusBarAppearanceUpdate];
    }];
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
        
        switch (type) {
            case SJPlayerGestureType_Unknown: break;
            case SJPlayerGestureType_Pan: {
                if ( disableTypes & SJDisablePlayerGestureTypes_Pan )
                    return NO;
            }
                break;
            case SJPlayerGestureType_Pinch: {
                if ( disableTypes & SJDisablePlayerGestureTypes_Pinch )
                    return NO;
            }
                break;
            case SJPlayerGestureType_DoubleTap: {
                if ( disableTypes & SJDisablePlayerGestureTypes_DoubleTap )
                    return NO;
            }
                break;
            case SJPlayerGestureType_SingleTap: {
                if ( disableTypes & SJDisablePlayerGestureTypes_SingleTap )
                    return NO;
            }
                break;
        }
        
        if ( [self playStatus_isInactivity_ReasonPlayFailed] )
            return NO;
        
        if ( SJPlayerGestureType_Pan == type &&
             self.isPlayOnScrollView &&
            !self.rotationManager.isFullscreen )
            return NO;
        
        if ( type != SJPlayerGestureType_Pinch &&
             self.controlLayerDataSource &&
            ![self.controlLayerDataSource triggerGesturesCondition:[gesture locationInView:gesture.view]] )
            return NO;
        
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
        if ( [self playStatus_isPlaying] ) [self pause];
        else [self play];
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
                    case SJPanLocation_Right: {
                        if ( self.mute || self.disableVolumeSetting ) {
                            [control cancelPanGesture];
#ifdef DEBUG
                            printf("SJBaseVideoPlayer<%p>.mute = %s;\n", self, self.mute?"YES":"NO");
                            printf("SJBaseVideoPlayer<%p>.disableVolumeSetting = %s;\n", self, self.disableVolumeSetting?"YES":"NO");
#endif
                            return;
                        }
                    }
                        break;
                    case SJPanLocation_Left: {
                        if ( self.disableBrightnessSetting ) {
                            [control cancelPanGesture];
#ifdef DEBUG
                            printf("SJBaseVideoPlayer<%p>.disableBrightnessSetting = %s;\n", self, self.disableBrightnessSetting?"YES":"NO");
#endif
                            return;
                        }
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
        self.playbackController.videoGravity = scale > 1 ?AVLayerVideoGravityResizeAspectFill:AVLayerVideoGravityResizeAspect;
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
#ifdef SJ_MAC
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

@synthesize playbackController = _playbackController;
- (void)setPlaybackController:(nullable id<SJMediaPlaybackController>)playbackController {
    [_playbackController.playerView removeFromSuperview];
    _playbackController = playbackController;
    if ( playbackController ) [self _needUpdatePlaybackControllerProperties];
}

- (id<SJMediaPlaybackController>)playbackController {
    if ( _playbackController ) return _playbackController;
    _playbackController = [SJAVMediaPlaybackController new];
    [self _needUpdatePlaybackControllerProperties];
    return _playbackController;
}

- (void)_needUpdatePlaybackControllerProperties {
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

@end


#pragma mark -

@interface _SJViewFlipTransitionServer : NSObject<CAAnimationDelegate>
- (instancetype)initWithView:(__weak UIView *)view;
@property (nonatomic) NSTimeInterval flipTransitionDuration;
@property (nonatomic) SJViewFlipTransition direction;
@property (nonatomic, readonly) BOOL isFlipTransitioning;
- (void)setDirection:(SJViewFlipTransition)direction animated:(BOOL)animated;
- (void)setDirection:(SJViewFlipTransition)direction animated:(BOOL)animated completionHandler:(void(^_Nullable)(__kindof _SJViewFlipTransitionServer *s))completionHandler;

@property (nonatomic, copy, nullable) void(^flipTransitionDidStartExeBlock)(__kindof _SJViewFlipTransitionServer *s);
@property (nonatomic, copy, nullable) void(^flipTransitionDidStopExeBlock)(__kindof _SJViewFlipTransitionServer *s);
@end

@implementation _SJViewFlipTransitionServer {
    __weak UIView *_view;
    void(^_Nullable _completionHandler)(__kindof _SJViewFlipTransitionServer *s);
}
- (instancetype)initWithView:(__weak UIView *)view {
    self = [super init];
    if ( !self ) return nil;
    _view = view;
    _flipTransitionDuration = 1.0;
    return self;
}

- (void)setDirection:(SJViewFlipTransition)direction {
    [self setDirection:direction animated:YES];
}

- (void)setDirection:(SJViewFlipTransition)direction animated:(BOOL)animated {
    [self setDirection:direction animated:animated completionHandler:nil];
}

- (void)setDirection:(SJViewFlipTransition)direction animated:(BOOL)animated completionHandler:(void(^_Nullable)(__kindof _SJViewFlipTransitionServer *s))completionHandler {
    if ( direction == _direction ) return;
    if ( _isFlipTransitioning ) return;
    _direction = direction;
    
    CATransform3D transform = CATransform3DIdentity;
    switch ( direction ) {
        case SJViewFlipTransition_Identity: {
            transform = CATransform3DIdentity;
        }
            break;
        case SJViewFlipTransition_Horizontally: {
            transform = CATransform3DConcat(CATransform3DMakeRotation(M_PI, 0, 1, 0), CATransform3DMakeTranslation(0, 0, -10000));
        }
            break;
    }

    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotationAnimation.fromValue = [NSValue valueWithCATransform3D:_view.layer.transform];
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:transform];
    rotationAnimation.duration = _flipTransitionDuration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.delegate = self;
    [_view.layer addAnimation:rotationAnimation forKey:nil];
    _view.layer.transform = transform;
    _isFlipTransitioning = YES;
    _completionHandler = completionHandler;
}

- (void)animationDidStart:(CAAnimation *)anim {
    _isFlipTransitioning = YES;
    if ( _flipTransitionDidStartExeBlock ) _flipTransitionDidStartExeBlock(self);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    _isFlipTransitioning = NO;
    
    if ( _completionHandler ) {
        _completionHandler(self);
        _completionHandler = nil;
    }
    if ( _flipTransitionDidStopExeBlock ) _flipTransitionDidStopExeBlock(self);
}
@end


@implementation SJBaseVideoPlayer (VideoFlipTransition)

- (_SJViewFlipTransitionServer *)flipTransitionServer {
    _SJViewFlipTransitionServer *s = objc_getAssociatedObject(self, _cmd);
    if ( !s ) {
        s = [[_SJViewFlipTransitionServer alloc] initWithView:_playbackController.playerView];
        objc_setAssociatedObject(self, _cmd, s, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return s;
}

- (SJViewFlipTransition)flipTransition {
    return self.flipTransitionServer.direction;
}

- (void)setFlipTransition:(SJViewFlipTransition)t {
    self.flipTransitionServer.direction = t;
}
- (void)setFlipTransition:(SJViewFlipTransition)t animated:(BOOL)animated {
    [self.flipTransitionServer setDirection:t animated:animated];
}
- (void)setFlipTransition:(SJViewFlipTransition)t animated:(BOOL)animated completionHandler:(void(^_Nullable)(__kindof SJBaseVideoPlayer *player))completionHandler {
    __weak typeof(self) _self = self;
    [self.flipTransitionServer setDirection:t animated:animated completionHandler:^(__kindof _SJViewFlipTransitionServer * _Nonnull s) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completionHandler ) completionHandler(self);
    }];
}
- (BOOL)isFlipTransitioning {
    return self.flipTransitionServer.isFlipTransitioning;
}

- (void)setFlipTransitionDidStartExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))block {
    objc_setAssociatedObject(self, @selector(flipTransitionDidStartExeBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    __weak typeof(self) _self = self;
    self.flipTransitionServer.flipTransitionDidStartExeBlock = ^(__kindof _SJViewFlipTransitionServer * _Nonnull s) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self);
    };
}

- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))flipTransitionDidStartExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFlipTransitionDidStopExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))block {
    objc_setAssociatedObject(self, @selector(flipTransitionDidStopExeBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    __weak typeof(self) _self = self;
    self.flipTransitionServer.flipTransitionDidStopExeBlock = ^(__kindof _SJViewFlipTransitionServer * _Nonnull s) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self);
    };
}

- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))flipTransitionDidStopExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFlipTransitionDuration:(NSTimeInterval)flipTransitionDuration {
    self.flipTransitionServer.flipTransitionDuration = flipTransitionDuration;
}

- (NSTimeInterval)flipTransitionDuration {
    return self.flipTransitionServer.flipTransitionDuration;
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

- (void)switchVideoDefinitionByURL:(NSURL *)URL {
    [self.playbackController switchVideoDefinitionByURL:URL];
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
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:loadedTimeProgress:)] ) {
        [self.controlLayerDelegate videoPlayer:self loadedTimeProgress:controller.bufferLoadedTime / controller.duration];
    }
}

- (void)playbackController:(id<SJMediaPlaybackController>)controller bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus {
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

#pragma mark -

// 1.
- (void)setURLAsset:(nullable SJVideoPlayerURLAsset *)URLAsset {
    if ( _URLAsset ) {
        if ( self.assetDeallocExeBlock ) self.assetDeallocExeBlock(self);
    }
    
    _URLAsset = URLAsset;
    
    // 维护当前播放的indexPath
    UIScrollView *scrollView = _getScrollViewOfPlayModel(URLAsset.playModel);
    if ( scrollView.sj_enabledAutoplay ) {
        scrollView.sj_currentPlayingIndexPath = [URLAsset.playModel performSelector:@selector(indexPath)];
    }
    
    self.playbackController.media = URLAsset;
    
    if ( !URLAsset ) {
        self.playStatus = SJVideoPlayerPlayStatusUnknown;
        self.playModelObserver = nil;
    }
    else {
        self.playStatus = SJVideoPlayerPlayStatusPrepare;
        self.playModelObserver = [[SJPlayModelPropertiesObserver alloc] initWithPlayModel:URLAsset.playModel];
        self.playModelObserver.delegate = (id)self;
    
        if ( [self.controlLayerDelegate respondsToSelector:@selector(startLoading:)] ) {
            [self.controlLayerDelegate startLoading:self];
        }
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
    
    if ( !self.isLockedScreen )
        [self.displayRecorder resetInitialization];
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(loadCompletion:)] ) {
        [self.controlLayerDelegate loadCompletion:self];
    }
    
    self.playStatus = SJVideoPlayerPlayStatusReadyToPlay;
    
    if ( self.operationOfInitializing ) {
        self.operationOfInitializing(self);
        self.operationOfInitializing = nil;
    }
    else if ( self.autoPlay ) {
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
    if ( [self.controlLayerDelegate respondsToSelector:@selector(cancelLoading:)] ) {
        [self.controlLayerDelegate cancelLoading:self];
    }
    
    self.error = _playbackController.error;
    self.inactivityReason = SJVideoPlayerInactivityReasonPlayFailed;
    self.playStatus = SJVideoPlayerPlayStatusInactivity;
}

- (void)_mediaDidPlayToEnd {
    if ( !self.vc_isDisappeared ) {
        UIScrollView *scrollView = _getScrollViewOfPlayModel(_URLAsset.playModel);
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
    self.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:_URLAsset.mediaURL specifyStartTime:_URLAsset.specifyStartTime playModel:_URLAsset.playModel];
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
    _playbackController.mute = mute;
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
    if ( pauseWhenAppDidEnterBackground ==  self.pauseWhenAppDidEnterBackground ) return;
    objc_setAssociatedObject(self, @selector(pauseWhenAppDidEnterBackground), @(pauseWhenAppDidEnterBackground), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _playbackController.pauseWhenAppDidEnterBackground = pauseWhenAppDidEnterBackground;
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
            if ( player.autoPlay ) [player play];
        };
        return;
    }
    
    [_playbackController play];
    
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
    
    [self.playbackController pause];
    
    self.pausedReason = reason;
    self.playStatus = SJVideoPlayerPlayStatusPaused;
}

- (void)stop {
    _operationOfInitializing = nil;
    [self.playbackController stop];
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
    
    if ( secs > self.playbackController.duration || secs < 0 ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    NSTimeInterval current = floor(self.playbackController.currentTime);
    NSTimeInterval seek = floor(secs);
    
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
    if ( self.canPlayAnAsset && !self.canPlayAnAsset(self) ) return;
    if ( _rate == rate ) return;
    _rate = rate;
    _playbackController.rate = rate;
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:rateChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self rateChanged:rate];
    }
    
    if ( self.rateChanged ) self.rateChanged(self);
    
    if ( [self playStatus_isInactivity_ReasonPlayEnd] ) [self replay];
    
    if ( [self playStatus_isPaused] ) [self play];
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
    return self.URLAsset.mediaURL;
}

- (void)playWithURL:(NSURL *)URL {
    self.assetURL = URL;
}

@end



@implementation SJBaseVideoPlayer (UIViewController)
/// You should call it when view did appear
- (void)vc_viewDidAppear {
    if ( !self.isPlayOnScrollView || (self.isPlayOnScrollView && self.isScrollAppeared) ) {
        [self play];
    }
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
        if ( self.enableControlLayerDisplayController && self.controlLayerAppeared ) return NO;
        return YES;
    }
    // 全屏播放时, 使状态栏根据控制层显示或隐藏
    if ( self.isFullScreen ) return !self.controlLayerAppeared;
    return NO;
}
- (UIStatusBarStyle)vc_preferredStatusBarStyle {
    // 全屏播放时, 使状态栏变成白色
    if ( self.isFullScreen || self.fitOnScreen ) return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
}

- (void)setVc_isDisappeared:(BOOL)vc_isDisappeared {
    objc_setAssociatedObject(self, @selector(vc_isDisappeared), @(vc_isDisappeared), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)vc_isDisappeared {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)needShowStatusBar {
    if ( _tmpShowStatusBar ) return;
    _tmpShowStatusBar = YES;
    [self.atViewController setNeedsStatusBarAppearanceUpdate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tmpShowStatusBar = NO;
    });
}

- (void)needHiddenStatusBar {
    if ( _tmpHiddenStatusBar ) return;
    _tmpHiddenStatusBar = YES;
    [self.atViewController setNeedsStatusBarAppearanceUpdate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tmpHiddenStatusBar = NO;
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




#pragma mark - 充满屏幕

@implementation SJBaseVideoPlayer (FitOnScreen)
- (void)setUseFitOnScreenAndDisableRotation:(BOOL)useFitOnScreenAndDisableRotation {
    objc_setAssociatedObject(self, @selector(useFitOnScreenAndDisableRotation), @(useFitOnScreenAndDisableRotation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)useFitOnScreenAndDisableRotation {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFitOnScreen:(BOOL)fitOnScreen {
    [self setFitOnScreen:fitOnScreen animated:YES];
}

- (BOOL)isFitOnScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated {
    [self setFitOnScreen:fitOnScreen animated:animated completionHandler:nil];
}

- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated completionHandler:(nullable void(^)(__kindof SJBaseVideoPlayer *player))completionHandler {
    if ( fitOnScreen == self.isFitOnScreen ) { return; }
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if ( !window ) return;
        CGRect origin = [window convertRect:self.view.bounds fromView:self.view];
        if ( fitOnScreen ) {
            self.presentView.frame = origin;
            [window addSubview:self.presentView];
        }
        objc_setAssociatedObject(self, @selector(isFitOnScreen), @(fitOnScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:willFitOnScreen:)] ) {
            [self.controlLayerDelegate videoPlayer:self willFitOnScreen:fitOnScreen];
        }
        if ( self.fitOnScreenWillChangeExeBlock ) self.fitOnScreenWillChangeExeBlock(self);
        [[self atViewController] setNeedsStatusBarAppearanceUpdate];
        [UIView animateWithDuration:animated ? 0.4 : 0 animations:^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( fitOnScreen ) {
                self.presentView.frame = window.bounds;
            }
            else {
                self.presentView.frame = origin;
            }
            [self.presentView layoutIfNeeded];
        } completion:^(BOOL finished) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( !fitOnScreen ) {
                [self.view addSubview:self.presentView];
                self.presentView.frame = self.view.bounds;
            }
            if ( self.fitOnScreenDidChangeExeBlock ) self.fitOnScreenDidChangeExeBlock(self);
            if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:didCompleteFitOnScreen:)] ) {
                [self.controlLayerDelegate videoPlayer:self didCompleteFitOnScreen:fitOnScreen];
            }
        }];
    });
}

- (void)setFitOnScreenWillChangeExeBlock:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))fitOnScreenWillChangeExeBlock {
    objc_setAssociatedObject(self, @selector(fitOnScreenWillChangeExeBlock), fitOnScreenWillChangeExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))fitOnScreenWillChangeExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFitOnScreenDidChangeExeBlock:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))fitOnScreenDidChangeExeBlock {
    objc_setAssociatedObject(self, @selector(fitOnScreenDidChangeExeBlock), fitOnScreenDidChangeExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))fitOnScreenDidChangeExeBlock {
    return objc_getAssociatedObject(self, _cmd);
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
        [(id<SJMediaPlaybackExportController>)_playbackController generateGIFWithBeginTime:beginTime duration:duration maximumSize:CGSizeMake(375, 375) interval:0.25f gifSavePath:filePath progress:^(id<SJMediaPlaybackController>  _Nonnull controller, float progress) {
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
        if ( !self.isEnabled ) return;
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
    
    [UIView animateWithDuration:self.videoPlayer.rotationManager.transitioning ? 0 : 0.25 animations:^{
        [[self.videoPlayer atViewController] setNeedsStatusBarAppearanceUpdate];
    }];
}
@end


#pragma mark -

@interface _SJReachabilityObserver ()
@property (nonatomic, strong, readonly) Reachability *reachability;
@end

@implementation _SJReachabilityObserver {
    id _notifyToken;
}

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
    
    __weak typeof(self) _self = self;
    _notifyToken = [NSNotificationCenter.defaultCenter addObserverForName:kReachabilityChangedNotification object:_reachability queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _reachabilityChangedNotification];
    }];
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
    if ( _notifyToken ) [[NSNotificationCenter defaultCenter] removeObserver:_notifyToken name:kReachabilityChangedNotification object:_reachability];
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

- (void)setPlaceholder:(nullable UIImage *)placeholder __deprecated_msg("use `player.placeholderImageView`") {
    self.placeholderImageView.image = placeholder;
}

- (nullable UIImage *)placeholder __deprecated_msg("use `player.placeholderImageView`") {
    return self.placeholderImageView.image;
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
