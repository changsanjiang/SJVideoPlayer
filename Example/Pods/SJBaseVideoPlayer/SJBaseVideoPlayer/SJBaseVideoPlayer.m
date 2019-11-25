//
//  SJBaseVideoPlayer.m
//  SJBaseVideoPlayerProject
//
//  Created by 畅三江 on 2018/2/2.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "SJBaseVideoPlayer.h"
#import <objc/message.h>
#import "SJRotationManager.h"
#import "SJDeviceVolumeAndBrightnessManager.h"
#import "SJVideoPlayerRegistrar.h"
#import "SJVideoPlayerPresentView.h"
#import "SJPlayModelPropertiesObserver.h"
#import "SJTimerControl.h"
#import "UIScrollView+ListViewAutoplaySJAdd.h"
#import "SJAVMediaPlaybackController.h"
#import "SJReachability.h"
#import "SJControlLayerAppearStateManager.h"
#import "SJFitOnScreenManager.h"
#import "SJFlipTransitionManager.h"
#import "SJPlayerView.h"
#import "SJFloatSmallViewController.h"
#import "SJEdgeFastForwardViewController.h"
#import "SJVideoDefinitionSwitchingInfo+Private.h"
#import "SJPopPromptController.h"
#import "SJPrompt.h"
#import "SJBaseVideoPlayerConst.h"
#import "SJSubtitlesPromptController.h"
#import "SJBaseVideoPlayer+TestLog.h"
#import "SJVideoPlayerURLAsset+SJSubtitlesAdd.h"
#import "SJBarrageQueueController.h"
#import "SJViewControllerManager.h"
#import "UIView+SJBaseVideoPlayerExtended.h"

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN
typedef struct _SJPlayerControlInfo {
    struct {
        NSTimeInterval offsetTime; ///< pan手势触发过程中的偏移量(secs)
    } pan;
    
    struct {
        BOOL needToHiddenWhenPlayerIsReadyForDisplay;
        NSTimeInterval delayHidden;
    } placeholder;
    
    struct {
        BOOL isScrollAppeared;
        BOOL pauseWhenScrollDisappeared;
        BOOL hiddenPlayerViewWhenScrollDisappeared;
        BOOL resumePlaybackWhenScrollAppeared;
    } scrollControl;
    
    struct {
        BOOL disableBrightnessSetting;
        BOOL disableVolumeSetting;
    } deviceVolumeAndBrightness;
    
    struct {
        BOOL accurateSeeking;
        BOOL autoplayWhenSetNewAsset;
        BOOL resumePlaybackWhenAppDidEnterForeground;
        BOOL resumePlaybackWhenPlayerHasFinishedSeeking;
    } plabackControl;
    
    struct {
        BOOL pausedToKeepAppearState;
    } controlLayer;
    
    struct {
        BOOL isAppeared;
        BOOL autoDisappearFloatSmallView;
    } floatSmallViewControl;
    
    
    struct {
        BOOL allowHorizontalTriggeringOfPanGesturesInCells;
        SJPlayerGestureTypeMask disabledGestures;
    } gestureControl;
    
} _SJPlayerControlInfo;

@interface SJBaseVideoPlayer ()<SJVideoPlayerPresentViewDelegate, SJPlayerViewDelegate>
@property (nonatomic) _SJPlayerControlInfo *controlInfo;

/// - 管理对象: 监听 App在前台, 后台, 耳机插拔, 来电等的通知
@property (nonatomic, strong, readonly) SJVideoPlayerRegistrar *registrar;

/// - observe视图的滚动
@property (nonatomic, strong, nullable) SJPlayModelPropertiesObserver *playModelObserver;
@property (nonatomic, strong, readonly) SJViewControllerManager *viewControllerManager;
@end

@implementation SJBaseVideoPlayer {
    SJPlayerView *_view;
    
    ///
    /// 视频画面的呈现层
    ///
    SJVideoPlayerPresentView *_presentView;
    
    SJVideoPlayerRegistrar *_registrar;
    
    /// 当前资源是否播放过
    /// mpc => Media Playback Controller
    id<SJVideoPlayerURLAssetObserver> _Nullable _mpc_assetObserver;
    
    /// device volume And brightness manager
    id<SJDeviceVolumeAndBrightnessManager> _deviceVolumeAndBrightnessManager;
    id<SJDeviceVolumeAndBrightnessManagerObserver> _deviceVolumeAndBrightnessManagerObserver;

    /// gestures
    id<SJEdgeFastForwardViewController> _fastForwardViewController;
    
    /// playback controller
    NSError *_Nullable _error;
    id<SJVideoPlayerPlaybackController> _playbackController;
    SJVideoPlayerURLAsset *_URLAsset;
    
    /// control layer appear manager
    id<SJControlLayerAppearManager> _controlLayerAppearManager;
    id<SJControlLayerAppearManagerObserver> _controlLayerAppearManagerObserver;
    
    /// rotation manager
    id<SJRotationManager> _rotationManager;
    id<SJRotationManagerObserver> _rotationManagerObserver;
    
    /// Fit on screen manager
    id<SJFitOnScreenManager> _fitOnScreenManager;
    id<SJFitOnScreenManagerObserver> _fitOnScreenManagerObserver;
    BOOL _useFitOnScreenAndDisableRotation;
    BOOL _autoManageViewToFitOnScreenOrRotation;
    
    /// Flip Transition manager
    id<SJFlipTransitionManager> _flipTransitionManager;
    
    /// Network status
    id<SJReachability> _reachability;
    id<SJReachabilityObserver> _reachabilityObserver;
    
    /// Scroll
    id<SJFloatSmallViewController> _Nullable _floatSmallViewController;
    id<SJFloatSmallViewControllerObserverProtocol> _Nullable _floatSmallViewControllerObesrver;
    
    id<SJSubtitlesPromptController> _Nullable _subtitlesPromptController;
    id<SJBarrageQueueController> _Nullable _barrageQueueController;
}

+ (instancetype)player {
    return [[self alloc] init];
}

+ (NSString *)version {
    return @"v3.1.4";
}

- (void)setVideoGravity:(SJVideoGravity)videoGravity {
    self.playbackController.videoGravity = videoGravity;
}
- (SJVideoGravity)videoGravity {
    return self.playbackController.videoGravity;
}

- (nullable __kindof UIViewController *)atViewController {
    UIView *view = nil;
    if ( self.useFitOnScreenAndDisableRotation )
        view = _view;
    else
        view = _presentView;
    
    return [view lookupResponderForClass:UIViewController.class];
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _controlInfo = (_SJPlayerControlInfo *)calloc(1, sizeof(struct _SJPlayerControlInfo));
    _controlInfo->placeholder.needToHiddenWhenPlayerIsReadyForDisplay = YES;
    _controlInfo->placeholder.delayHidden = 0.8;
    _controlInfo->scrollControl.pauseWhenScrollDisappeared = YES;
    _controlInfo->scrollControl.hiddenPlayerViewWhenScrollDisappeared = YES;
    _controlInfo->scrollControl.resumePlaybackWhenScrollAppeared = YES;
    _controlInfo->plabackControl.autoplayWhenSetNewAsset = YES;
    _controlInfo->plabackControl.resumePlaybackWhenPlayerHasFinishedSeeking = YES;
    _controlInfo->floatSmallViewControl.autoDisappearFloatSmallView = YES;
    self.autoManageViewToFitOnScreenOrRotation = YES;
    
    [self _setupViews];
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
    [self rotationManager];
    [self registrar];
    dispatch_async(dispatch_get_main_queue(), ^{    
        [self.deviceVolumeAndBrightnessManager prepare];
    });

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self reachability];
        [self gestureControl];
        [self _configAVAudioSession];
    });
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
    if ( _URLAsset != nil && self.assetDeallocExeBlock )
        self.assetDeallocExeBlock(self);
    [_presentView removeFromSuperview];
    [_view removeFromSuperview];
    free(_controlInfo);
}

- (void)playerViewDidLayoutSubviews:(SJPlayerView *)playerView {
    if ( _presentView.superview == playerView ) {
        _presentView.frame = playerView.bounds;
    }
}

- (void)playerViewWillMoveToWindow:(SJPlayerView *)playerView {
    [self.playModelObserver refreshAppearState];
}

///
/// 此处拦截父视图的Tap手势
///
- (nullable UIView *)playerView:(SJPlayerView *)playerView hitTestForView:(nullable __kindof UIView *)view {

    if ( playerView.hidden ) return nil;
    
    for ( UIGestureRecognizer *gesture in playerView.superview.gestureRecognizers ) {
        if ( [gesture isKindOfClass:UITapGestureRecognizer.class] && gesture.isEnabled ) {
            gesture.enabled = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                gesture.enabled = YES;
            });
        }
    }
    
    return view;
}

- (void)presentViewDidLayoutSubviews:(SJVideoPlayerPresentView *)presentView {
    if ( !CGSizeEqualToSize(_controlLayerDataSource.controlView.frame.size, presentView.bounds.size) ) {    
        _controlLayerDataSource.controlView.frame = presentView.bounds;
    }
}

//- (void)presentViewWillMoveToWindow:(nullable UIWindow *)window { }

#pragma mark -

- (void)_handleSingleTap:(CGPoint)location {
    if ( self.controlInfo->floatSmallViewControl.isAppeared ) {
        if ( self.floatSmallViewController.singleTappedOnTheFloatViewExeBlock ) {
            self.floatSmallViewController.singleTappedOnTheFloatViewExeBlock(self.floatSmallViewController);
        }
        return;
    }
    
    if ( self.isLockedScreen ) {
        if ( [self.controlLayerDelegate respondsToSelector:@selector(tappedPlayerOnTheLockedState:)] ) {
            [self.controlLayerDelegate tappedPlayerOnTheLockedState:self];
        }
    }
    else {
        [self.controlLayerAppearManager switchAppearState];
    }
}

- (void)_handleDoubleTap:(CGPoint)location {
    if ( self.controlInfo->floatSmallViewControl.isAppeared ) {
        if ( self.floatSmallViewController.doubleTappedOnTheFloatViewExeBlock ) {
            self.floatSmallViewController.doubleTappedOnTheFloatViewExeBlock(self.floatSmallViewController);
        }
        return;
    }
    
    if ( _fastForwardViewController.isEnabled ) {
        CGRect bounds = self.presentView.bounds;
        CGFloat width = self.fastForwardViewController.triggerAreaWidth;
        CGRect left = CGRectMake(0, 0, width, bounds.size.height);
        CGFloat spanSecs = self.fastForwardViewController.spanSecs;
        if ( CGRectContainsPoint(left, location) ) {
            // 快退10秒
            [self seekToTime:self.currentTime - spanSecs completionHandler:nil];
            [self.fastForwardViewController showFastForwardView:SJFastForwardTriggeredPosition_Left];
            return;
        }
        
        CGRect right = CGRectMake(bounds.size.width - width, 0, width, bounds.size.height);
        if ( CGRectContainsPoint(right, location) ) {
            // 快进10秒
            [self seekToTime:self.currentTime + spanSecs completionHandler:nil];
            [self.fastForwardViewController showFastForwardView:SJFastForwardTriggeredPosition_Right];
            return;
        }
    }
    
    self.timeControlStatus == SJPlaybackTimeControlStatusPaused ? [self play] : [self pause];
}

- (void)_handlePan:(SJPanGestureTriggeredPosition)position direction:(SJPanGestureMovingDirection)direction state:(SJPanGestureRecognizerState)state translate:(CGPoint)translate {
    switch ( state ) {
        case SJPanGestureRecognizerStateBegan: {
            switch ( direction ) {
                    /// 水平
                case SJPanGestureMovingDirection_H: {
                    if ( self.duration == 0 ) {
                        [_presentView cancelGesture:SJPlayerGestureType_Pan];
                        return;
                    }
                    
                    self.controlInfo->pan.offsetTime = self.currentTime;
                }
                    break;
                    /// 垂直
                case SJPanGestureMovingDirection_V: {
                    switch ( position ) {
                            /// brightness
                        case SJPanGestureTriggeredPosition_Left: {
                            self.deviceVolumeAndBrightnessManager.brightnessTracking = YES;
                        }
                            break;
                            /// volume
                        case SJPanGestureTriggeredPosition_Right: {
                            self.deviceVolumeAndBrightnessManager.volumeTracking = YES;
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
                    NSTimeInterval duration = self.duration;
                    NSTimeInterval beforeOffsetTime = self.controlInfo->pan.offsetTime;
                    CGFloat tlt = translate.x;
                    CGFloat add = tlt / 667 * self.duration;
                    CGFloat offsetTime = beforeOffsetTime + add;
                    if ( offsetTime > duration ) offsetTime = duration;
                    else if ( offsetTime < 0 ) offsetTime = 0;
                    self.controlInfo->pan.offsetTime = offsetTime;
                }
                    break;
                    /// 垂直
                case SJPanGestureMovingDirection_V: {
                    switch ( position ) {
                            /// brightness
                        case SJPanGestureTriggeredPosition_Left: {
                            CGFloat value = self.deviceVolumeAndBrightnessManager.brightness - translate.y * 0.005;
                            if ( value < 0 ) value = 0;
                            self.deviceVolumeAndBrightnessManager.brightness = value;
                        }
                            break;
                            /// volume
                        case SJPanGestureTriggeredPosition_Right: {
                            CGFloat value = translate.y * 0.005;
                            self.deviceVolumeAndBrightnessManager.volume -= value;
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
                case SJPanGestureMovingDirection_H: { }
                    break;
                case SJPanGestureMovingDirection_V: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        switch ( position ) {
                                /// brightness
                            case SJPanGestureTriggeredPosition_Left: {
                                self.deviceVolumeAndBrightnessManager.brightnessTracking = NO;
                            }
                                break;
                                /// volume
                            case SJPanGestureTriggeredPosition_Right: {
                                self.deviceVolumeAndBrightnessManager.volumeTracking = NO;
                            }
                                break;
                        }
                    });
                }
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
}

- (void)_handlePinch:(CGFloat)scale {
    self.playbackController.videoGravity = scale > 1 ?AVLayerVideoGravityResizeAspectFill:AVLayerVideoGravityResizeAspect;
}

#pragma mark -

- (void)setControlLayerDataSource:(nullable id<SJVideoPlayerControlLayerDataSource>)controlLayerDataSource {
    if ( controlLayerDataSource == _controlLayerDataSource ) return;
    _controlLayerDataSource = controlLayerDataSource;
    
    if ( !controlLayerDataSource ) return;
    
    _controlLayerDataSource.controlView.clipsToBounds = YES;
    
    // install
    UIView *controlView = _controlLayerDataSource.controlView;
    controlView.frame = self.presentView.bounds;
    [self.presentView addSubview:controlView];
    
    if ( [self.controlLayerDataSource respondsToSelector:@selector(installedControlViewToVideoPlayer:)] ) {
        [self.controlLayerDataSource installedControlViewToVideoPlayer:self];
    }
}


#pragma mark -

@synthesize viewControllerManager = _viewControllerManager;
- (SJViewControllerManager *)viewControllerManager {
    if ( _viewControllerManager == nil ) {
        _viewControllerManager = SJViewControllerManager.alloc.init;
        _viewControllerManager.fitOnScreenManager = self.fitOnScreenManager;
        _viewControllerManager.rotationManager = self.rotationManager;
        _viewControllerManager.controlLayerAppearManager = self.controlLayerAppearManager;
        _viewControllerManager.presentView = self.presentView;
        _viewControllerManager.lockedScreen = self.isLockedScreen;
    }
    return _viewControllerManager;
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
        BOOL canPlay = self.timeControlStatus == SJPlaybackTimeControlStatusPaused && self.controlInfo->plabackControl.resumePlaybackWhenAppDidEnterForeground;
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
    };
    
    _registrar.didEnterBackground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(receivedApplicationDidEnterBackgroundNotification:)] ) {
            [self.controlLayerDelegate receivedApplicationDidEnterBackgroundNotification:self];
        }
    };
    return _registrar;
}

#pragma mark -

- (void)_setupViews {
    _view = [SJPlayerView new];
    _view.delegate = self;
    _view.backgroundColor = [UIColor blackColor];
    
    _presentView = [SJVideoPlayerPresentView new];
    _presentView.delegate = self;
    [self _configGestureControl:_presentView];
    [_view addSubview:_presentView];
    
    self.viewControllerManager.presentView = _presentView;
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

- (void)_postNotification:(NSNotificationName)name {
    [NSNotificationCenter.defaultCenter postNotificationName:name object:self];
}

- (void)_showOrHiddenPlaceholderImageViewIfNeeded {
    if ( _URLAsset.originMedia != nil ) { ///< URLAsset is subasset
        [_presentView hiddenPlaceholderAnimated:NO delay:0];
        return;
    }
    
    if ( _playbackController.isReadyForDisplay ) {
        if ( _controlInfo->placeholder.needToHiddenWhenPlayerIsReadyForDisplay ) {
            [self.presentView hiddenPlaceholderAnimated:YES delay:_controlInfo->placeholder.delayHidden];
        }
    }
    else {
        [self.presentView showPlaceholderAnimated:NO];
    }
}

- (void)_configGestureControl:(id<SJPlayerGestureControl>)gestureControl {
    
    __weak typeof(self) _self = self;
    gestureControl.gestureRecognizerShouldTrigger = ^BOOL(id<SJPlayerGestureControl>  _Nonnull control, SJPlayerGestureType type, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        
        if ( self.isTransitioning )
            return NO;
        
        if ( type != SJPlayerGestureType_SingleTap && self.isLockedScreen )
            return NO;
        
        if ( SJPlayerGestureType_Pan == type ) {
            switch ( control.movingDirection ) {
                case SJPanGestureMovingDirection_H: {
                    if ( self.playbackType == SJPlaybackTypeLIVE )
                        return NO;
                    
                    if ( self.duration <= 0 )
                        return NO;
                    
                    if ( self.canSeekToTime != nil && !self.canSeekToTime(self) )
                        return NO;
                    
                    if ( self.isPlayOnScrollView ) {
                        if ( NO == self.controlInfo->gestureControl.allowHorizontalTriggeringOfPanGesturesInCells ) {
                            if ( YES == self.useFitOnScreenAndDisableRotation ) {
                                if ( NO == self.isFitOnScreen )
                                    return NO;
                            }
                            else {
                                if ( NO == self.isFullScreen )
                                    return NO;
                            }
                        }
                    }
                }
                    break;
                case SJPanGestureMovingDirection_V: {
                    if ( self.isPlayOnScrollView ) {
                        if ( YES == self.useFitOnScreenAndDisableRotation ) {
                            if ( NO == self.isFitOnScreen )
                                return NO;
                        }
                        else {
                            if ( NO == self.isFullScreen )
                                return NO;
                        }
                    }
                    switch ( control.triggeredPosition ) {
                            /// Brightness
                        case SJPanGestureTriggeredPosition_Left: {
                            if ( self.controlInfo->deviceVolumeAndBrightness.disableBrightnessSetting )
                                return NO;
                        }
                            break;
                            /// Volume
                        case SJPanGestureTriggeredPosition_Right: {
                            if ( self.controlInfo->deviceVolumeAndBrightness.disableVolumeSetting || self.isMuted )
                                return NO;
                        }
                            break;
                    }
                }
            }
        }
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:gestureRecognizerShouldTrigger:location:)] ) {
            if ( ![self.controlLayerDelegate videoPlayer:self gestureRecognizerShouldTrigger:type location:location] )
                return NO;
        }
        
        if ( self.gestureRecognizerShouldTrigger && !self.gestureRecognizerShouldTrigger(self, type, location) ) {
            return NO;
        }
        return YES;
    };
    
    gestureControl.singleTapHandler = ^(id<SJPlayerGestureControl>  _Nonnull control, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _handleSingleTap:location];
    };
    
    gestureControl.doubleTapHandler = ^(id<SJPlayerGestureControl>  _Nonnull control, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _handleDoubleTap:location];
    };
    
    gestureControl.panHandler = ^(id<SJPlayerGestureControl>  _Nonnull control, SJPanGestureTriggeredPosition position, SJPanGestureMovingDirection direction, SJPanGestureRecognizerState state, CGPoint translate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _handlePan:position direction:direction state:state translate:translate];
    };
    
    gestureControl.pinchHandler = ^(id<SJPlayerGestureControl>  _Nonnull control, CGFloat scale) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _handlePinch:scale];
    };
}


- (void)_updateCurrentPlayingIndexPathIfNeeded:(SJPlayModel *)playModel {
    if ( !playModel )
        return;
    
    // 维护当前播放的indexPath
    UIScrollView *scrollView = playModel.inScrollView;
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
- (UIView<SJVideoPlayerPresentView> *)presentView {
    return _presentView;
}

- (void)setHiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay:(BOOL)isHidden {
    _controlInfo->placeholder.needToHiddenWhenPlayerIsReadyForDisplay = isHidden;
}
- (BOOL)hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay {
    return _controlInfo->placeholder.needToHiddenWhenPlayerIsReadyForDisplay;
}


- (void)setDelayInSecondsForHiddenPlaceholderImageView:(NSTimeInterval)delayHidden {
    _controlInfo->placeholder.delayHidden = delayHidden;
}
- (NSTimeInterval)delayInSecondsForHiddenPlaceholderImageView {
    return _controlInfo->placeholder.delayHidden;
}
@end


#pragma mark -

@implementation SJBaseVideoPlayer (VideoFlipTransition)
- (void)setFlipTransitionManager:(id<SJFlipTransitionManager> _Nullable)flipTransitionManager {
    _flipTransitionManager = flipTransitionManager;
}
- (id<SJFlipTransitionManager>)flipTransitionManager {
    if ( _flipTransitionManager )
        return _flipTransitionManager;
    
    _flipTransitionManager = [[SJFlipTransitionManager alloc] initWithTarget:self.playbackController.playerView];
    return _flipTransitionManager;
}

- (id<SJFlipTransitionManagerObserver>)flipTransitionObserver {
    id<SJFlipTransitionManagerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.flipTransitionManager getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}
@end

#pragma mark - 控制
@implementation SJBaseVideoPlayer (PlayControl)
- (void)setPlaybackController:(nullable id<SJVideoPlayerPlaybackController>)playbackController {
    [_playbackController.playerView removeFromSuperview];
    _playbackController = playbackController;
    [self _needUpdatePlaybackControllerProperties];
}

- (id<SJVideoPlayerPlaybackController>)playbackController {
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
}

- (SJPlaybackObservation *)playbackObserver {
    SJPlaybackObservation *obs = objc_getAssociatedObject(self, _cmd);
    if ( obs == nil ) {
        obs = [[SJPlaybackObservation alloc] initWithPlayer:self];
        objc_setAssociatedObject(self, _cmd, obs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return obs;
}

- (void)switchVideoDefinition:(SJVideoPlayerURLAsset *)URLAsset {
    self.definitionSwitchingInfo.switchingAsset = URLAsset;
    [self.playbackController switchVideoDefinition:URLAsset];
}

- (SJVideoDefinitionSwitchingInfo *)definitionSwitchingInfo {
    SJVideoDefinitionSwitchingInfo *_Nullable definitionSwitchingInfo = objc_getAssociatedObject(self, _cmd);
    if ( definitionSwitchingInfo == nil ) {
        definitionSwitchingInfo = [SJVideoDefinitionSwitchingInfo new];
        objc_setAssociatedObject(self, @selector(definitionSwitchingInfo), definitionSwitchingInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return definitionSwitchingInfo;
}

- (void)_resetDefinitionSwitchingInfo {
    SJVideoDefinitionSwitchingInfo *info = self.definitionSwitchingInfo;
    info.currentPlayingAsset = nil;
    info.switchingAsset = nil;
    info.status = SJDefinitionSwitchStatusUnknown;
}

- (SJPlaybackType)playbackType {
    return _playbackController.playbackType;
}

#pragma mark -

- (NSError *_Nullable)error {
    return _playbackController.error;
}

- (SJAssetStatus)assetStatus {
    return _playbackController.assetStatus;
}

- (SJPlaybackTimeControlStatus)timeControlStatus {
    return _playbackController.timeControlStatus;
}

- (nullable SJWaitingReason)reasonForWaitingToPlay {
    return _playbackController.reasonForWaitingToPlay;
}

- (BOOL)isPlayedToEndTime {
    return _playbackController.isPlayedToEndTime;
}

- (BOOL)isPlayed {
    return _playbackController.isPlayed;
}

- (BOOL)isReplayed {
    return _playbackController.isReplayed;
}

- (NSTimeInterval)currentTime {
    return self.playbackController.currentTime;
}

- (NSTimeInterval)duration {
    return self.playbackController.duration;
}

- (NSTimeInterval)playableDuration {
    return self.playbackController.playableDuration;
}

- (NSTimeInterval)durationWatched {
    return self.playbackController.durationWatched;
}

- (NSString *)stringForSeconds:(NSInteger)secs {
    long min = 60;
    long hour = 60 * min;
    
    long hours, seconds, minutes;
    hours = secs / hour;
    minutes = (secs - hours * hour) / 60;
    seconds = (NSInteger)secs % 60;
    if ( self.duration < hour ) {
        return [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
    }
    else if ( hours < 100 ) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, seconds];
    }
    else {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", hours, minutes, seconds];
    }
}

#pragma mark -
// 1.
- (void)setURLAsset:(nullable SJVideoPlayerURLAsset *)URLAsset {
    if ( _URLAsset && self.assetDeallocExeBlock != nil ) {
        self.assetDeallocExeBlock(self);
    }

    [self _resetDefinitionSwitchingInfo];
    
    _URLAsset = URLAsset;
      
    //
    // prepareToPlay
    //
    self.playbackController.media = URLAsset;
    self.definitionSwitchingInfo.currentPlayingAsset = URLAsset;
    [self _updateAssetObservers];
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:prepareToPlay:)] ) {
        [self.controlLayerDelegate videoPlayer:self prepareToPlay:URLAsset];
    }
    
    if ( URLAsset == nil ) {
        [self stop];
        return;
    }

    if ( URLAsset.subtitles != nil ) self.subtitlesPromptController.subtitles = URLAsset.subtitles;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.playbackController prepareToPlay];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _tryToPlayIfNeeded];
        });
    });
}
- (nullable SJVideoPlayerURLAsset *)URLAsset {
    return _URLAsset;
}

- (void)_tryToPlayIfNeeded {
    if ( self.registrar.state == SJVideoPlayerAppState_Background && self.pauseWhenAppDidEnterBackground )
        return;
    if ( _controlInfo->plabackControl.autoplayWhenSetNewAsset == NO )
        return;
    if ( self.isPlayOnScrollView && self.isScrollAppeared == NO && self.pauseWhenScrollDisappeared )
        return;
    
    [self play];
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
    [self play];
}

- (void)setAssetDeallocExeBlock:(nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))assetDeallocExeBlock {
    objc_setAssociatedObject(self, @selector(assetDeallocExeBlock), assetDeallocExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (nullable void (^)(__kindof SJBaseVideoPlayer * _Nonnull))assetDeallocExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlayerVolume:(float)playerVolume {
    self.playbackController.volume = playerVolume;
    [self _postNotification:SJVideoPlayerVolumeDidChangeNotification];
}
- (float)playerVolume {
    return self.playbackController.volume;
}

- (void)setMuted:(BOOL)muted {
    self.playbackController.muted = muted;
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:muteChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self muteChanged:muted];
    }
    [self _postNotification:SJVideoPlayerMutedDidChangeNotification];
}
- (BOOL)isMuted {
    return self.playbackController.muted;
}

- (void)setAutoplayWhenSetNewAsset:(BOOL)autoplayWhenSetNewAsset {
    _controlInfo->plabackControl.autoplayWhenSetNewAsset = autoplayWhenSetNewAsset;
}
- (BOOL)autoplayWhenSetNewAsset {
    return _controlInfo->plabackControl.autoplayWhenSetNewAsset;
}

- (void)setPauseWhenAppDidEnterBackground:(BOOL)pauseWhenAppDidEnterBackground {
    self.playbackController.pauseWhenAppDidEnterBackground = pauseWhenAppDidEnterBackground;
}
- (BOOL)pauseWhenAppDidEnterBackground {
    return self.playbackController.pauseWhenAppDidEnterBackground;
}

- (void)setResumePlaybackWhenAppDidEnterForeground:(BOOL)resumePlaybackWhenAppDidEnterForeground {
    _controlInfo->plabackControl.resumePlaybackWhenAppDidEnterForeground = resumePlaybackWhenAppDidEnterForeground;
}
- (BOOL)resumePlaybackWhenAppDidEnterForeground {
    return _controlInfo->plabackControl.resumePlaybackWhenAppDidEnterForeground;
}

- (void)setCanPlayAnAsset:(nullable BOOL (^)(__kindof SJBaseVideoPlayer * _Nonnull))canPlayAnAsset {
    objc_setAssociatedObject(self, @selector(canPlayAnAsset), canPlayAnAsset, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (nullable BOOL (^)(__kindof SJBaseVideoPlayer * _Nonnull))canPlayAnAsset {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setResumePlaybackWhenPlayerHasFinishedSeeking:(BOOL)resumePlaybackWhenPlayerHasFinishedSeeking {
    _controlInfo->plabackControl.resumePlaybackWhenPlayerHasFinishedSeeking = resumePlaybackWhenPlayerHasFinishedSeeking;
}
- (BOOL)resumePlaybackWhenPlayerHasFinishedSeeking {
    return _controlInfo->plabackControl.resumePlaybackWhenPlayerHasFinishedSeeking;
}

- (void)play {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(canPerformPlayForVideoPlayer:)] ) {
        if ( ![self.controlLayerDelegate canPerformPlayForVideoPlayer:self] )
            return;
    }
    
    if ( self.canPlayAnAsset && !self.canPlayAnAsset(self) )
        return;
    
    if ( self.registrar.state == SJVideoPlayerAppState_Background && self.pauseWhenAppDidEnterBackground ) return;

    if ( self.assetStatus == SJAssetStatusFailed ) {
        [self refresh];
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
    
    [_playbackController pause];
}

- (void)stop {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(canPerformStopForVideoPlayer:)] ) {
        if ( ![self.controlLayerDelegate canPerformStopForVideoPlayer:self] )
            return;
    }

    if ( _URLAsset != nil && self.assetDeallocExeBlock ) {
        self.assetDeallocExeBlock(self);
    }
    
    _subtitlesPromptController.subtitles = nil;
    _playModelObserver = nil;
    _URLAsset = nil;
    [_playbackController stop];
    [self _resetDefinitionSwitchingInfo];
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
}

- (void)replay {
    if ( !self.URLAsset ) return;
    if ( self.assetStatus == SJAssetStatusFailed ) {
        [self refresh];
        return;
    }
    
    [_playbackController replay];
}

- (void)setCanSeekToTime:(BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))canSeekToTime {
    objc_setAssociatedObject(self, @selector(canSeekToTime), canSeekToTime, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))canSeekToTime {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAccurateSeeking:(BOOL)accurateSeeking {
    _controlInfo->plabackControl.accurateSeeking = accurateSeeking;
}
- (BOOL)accurateSeeking {
    return _controlInfo->plabackControl.accurateSeeking;
}

- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    if ( isnan(secs) ) {
        return;
    }
    
    if ( secs > self.playbackController.duration ) {
        secs = self.playbackController.duration * 0.98;
    }
    else if ( secs < 0 ) {
        secs = 0;
    }
    
    [self seekToTime:CMTimeMakeWithSeconds(secs, NSEC_PER_SEC)
     toleranceBefore:self.accurateSeeking ? kCMTimeZero : kCMTimePositiveInfinity
      toleranceAfter:self.accurateSeeking ? kCMTimeZero : kCMTimePositiveInfinity
   completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^ _Nullable)(BOOL))completionHandler {
    if ( self.canPlayAnAsset && !self.canPlayAnAsset(self) ) {
        return;
    }
    
    if ( self.assetStatus != SJAssetStatusReadyToPlay ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    __weak typeof(self) _self = self;
    [self.playbackController seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( finished && self.controlInfo->plabackControl.resumePlaybackWhenPlayerHasFinishedSeeking ) {
            [self play];
        }
        if ( completionHandler ) completionHandler(finished);
    }];
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
    
    [self _postNotification:SJVideoPlayerRateDidChangeNotification];
}

- (float)rate {
    return self.playbackController.rate;
}

- (void)_updatePlayModelObserver:(SJPlayModel *)playModel {
    // clean
    _playModelObserver = nil;
    _controlInfo->scrollControl.isScrollAppeared = NO;
    
    if ( playModel == nil || [playModel isMemberOfClass:SJPlayModel.class] )
        return;
    
    // update playModel
    self.playModelObserver = [[SJPlayModelPropertiesObserver alloc] initWithPlayModel:playModel];
    self.playModelObserver.delegate = (id)self;
    [self.playModelObserver refreshAppearState];
}

// - Playback Controll Delegate -

- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller assetStatusDidChange:(SJAssetStatus)status {
 
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayerPlaybackStatusDidChange:)] ) {
        [self.controlLayerDelegate videoPlayerPlaybackStatusDidChange:self];
    }
    
    [self _postNotification:SJVideoPlayerAssetStatusDidChangeNotification];
    
#ifdef SJDEBUG
    [self showLog_AssetStatus];
#endif
}

- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller timeControlStatusDidChange:(SJPlaybackTimeControlStatus)status {
    
    BOOL isBuffering = controller.reasonForWaitingToPlay == SJWaitingToMinimizeStallsReason;
    isBuffering ? [self.reachability startRefresh] : [self.reachability stopRefresh];
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayerPlaybackStatusDidChange:)] ) {
        [self.controlLayerDelegate videoPlayerPlaybackStatusDidChange:self];
    }

    [self _postNotification:SJVideoPlayerPlaybackTimeControlStatusDidChangeNotification];
        
    if ( status == SJPlaybackTimeControlStatusPaused && self.pausedToKeepAppearState ) {
        [self.controlLayerAppearManager keepAppearState];
    }
    
#ifdef SJDEBUG
    [self showLog_TimeControlStatus];
#endif
}

- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller durationDidChange:(NSTimeInterval)duration {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:durationDidChange:)] ) {
        [self.controlLayerDelegate videoPlayer:self durationDidChange:duration];
    }
    
    [self _postNotification:SJVideoPlayerDurationDidChangeNotification];
}

- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller currentTimeDidChange:(NSTimeInterval)currentTime {
    _subtitlesPromptController.currentTime = currentTime;
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:currentTimeDidChange:)] ) {
        [self.controlLayerDelegate videoPlayer:self currentTimeDidChange:currentTime];
    }
    
    [self _postNotification:SJVideoPlayerCurrentTimeDidChangeNotification];
}

- (void)mediaDidPlayToEndForPlaybackController:(id<SJVideoPlayerPlaybackController>)controller {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayerPlaybackStatusDidChange:)] ) {
        [self.controlLayerDelegate videoPlayerPlaybackStatusDidChange:self];
    }

    [self _postNotification:SJVideoPlayerDidPlayToEndTimeNotification];
}

- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller presentationSizeDidChange:(CGSize)presentationSize {
    if ( _autoManageViewToFitOnScreenOrRotation && !self.isFullScreen && !self.isFitOnScreen ) {
        _useFitOnScreenAndDisableRotation = presentationSize.width < presentationSize.height;
    }

    if ( self.presentationSizeDidChangeExeBlock )
        self.presentationSizeDidChangeExeBlock(self);
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:presentationSizeDidChange:)] ) {
        [self.controlLayerDelegate videoPlayer:self presentationSizeDidChange:presentationSize];
    }
    
    [self _postNotification:SJVideoPlayerPresentationSizeDidChangeNotification];
}

- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller playbackTypeDidChange:(SJPlaybackType)playbackType {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:playbackTypeDidChange:)] ) {
        [self.controlLayerDelegate videoPlayer:self playbackTypeDidChange:playbackType];
    }
    
    [self _postNotification:SJVideoPlayerPlaybackTypeDidChangeNotification];
}

- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller playableDurationDidChange:(NSTimeInterval)playableDuration {
    if ( controller.duration == 0 ) return;

    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:playableDurationDidChange:)] ) {
        [self.controlLayerDelegate videoPlayer:self playableDurationDidChange:playableDuration];
    }
    
    [self _postNotification:SJVideoPlayerPlayableDurationDidChangeNotification];
}

- (void)playbackControllerIsReadyForDisplay:(id<SJVideoPlayerPlaybackController>)controller {
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
}

- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller switchingDefinitionStatusDidChange:(SJDefinitionSwitchStatus)status media:(id<SJMediaModelProtocol>)media {
    
    if ( status == SJDefinitionSwitchStatusFinished ) {
        _URLAsset = (id)media;
        self.definitionSwitchingInfo.currentPlayingAsset = _URLAsset;
        [self _updateAssetObservers];
    }
    
    self.definitionSwitchingInfo.status = status;
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:switchingDefinitionStatusDidChange:media:)] ) {
        [self.controlLayerDelegate videoPlayer:self switchingDefinitionStatusDidChange:status media:media];
    }
    
    [self _postNotification:SJVideoPlayerDefinitionSwitchStatusDidChangeNotification];
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
    if ( _reachability == nil ) return;
    
    _reachabilityObserver = [_reachability getObserver];
    __weak typeof(self) _self = self;
    _reachabilityObserver.networkStatusDidChangeExeBlock = ^(id<SJReachability> r) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:reachabilityChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self reachabilityChanged:r.networkStatus];
        }
    };
}

- (id<SJReachabilityObserver>)reachabilityObserver {
    id<SJReachabilityObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.reachability getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}
@end

#pragma mark -

@implementation SJBaseVideoPlayer (DeviceVolumeAndBrightness)

- (void)setDeviceVolumeAndBrightnessManager:(id<SJDeviceVolumeAndBrightnessManager> _Nullable)deviceVolumeAndBrightnessManager {
    _deviceVolumeAndBrightnessManager = deviceVolumeAndBrightnessManager;
    [self _configDeviceVolumeAndBrightnessManager:self.deviceVolumeAndBrightnessManager];
}

- (id<SJDeviceVolumeAndBrightnessManager>)deviceVolumeAndBrightnessManager {
    if ( _deviceVolumeAndBrightnessManager )
        return _deviceVolumeAndBrightnessManager;
    _deviceVolumeAndBrightnessManager = [SJDeviceVolumeAndBrightnessManager shared];
    [self _configDeviceVolumeAndBrightnessManager:_deviceVolumeAndBrightnessManager];
    return _deviceVolumeAndBrightnessManager;
}

- (void)_configDeviceVolumeAndBrightnessManager:(id<SJDeviceVolumeAndBrightnessManager>)mgr {
    _deviceVolumeAndBrightnessManagerObserver = [mgr getObserver];
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

- (id<SJDeviceVolumeAndBrightnessManagerObserver>)deviceVolumeAndBrightnessObserver {
    id<SJDeviceVolumeAndBrightnessManagerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.deviceVolumeAndBrightnessManager getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
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

@implementation SJBaseVideoPlayer (Life)
/// You should call it when view did appear
- (void)vc_viewDidAppear {
    [self.viewControllerManager viewDidAppear];
    [self.playModelObserver refreshAppearState];
}
/// You should call it when view will disappear
- (void)vc_viewWillDisappear {
    [self.viewControllerManager viewWillDisappear];
}
- (void)vc_viewDidDisappear {
    [self.viewControllerManager viewDidDisappear];
    [self pause];
}
- (BOOL)vc_prefersStatusBarHidden {
    return self.viewControllerManager.prefersStatusBarHidden;
}
- (UIStatusBarStyle)vc_preferredStatusBarStyle {
    return self.viewControllerManager.preferredStatusBarStyle;
}

- (void)setVc_isDisappeared:(BOOL)vc_isDisappeared {
    vc_isDisappeared ?  [self.viewControllerManager viewWillDisappear] :
                        [self.viewControllerManager viewDidAppear];
}
- (BOOL)vc_isDisappeared {
    return self.viewControllerManager.isViewDisappeared;
}

- (void)needShowStatusBar {
    [self.viewControllerManager showStatusBar];
}

- (void)needHiddenStatusBar {
    [self.viewControllerManager hiddenStatusBar];
}
@end

#pragma mark - Gesture

@implementation SJBaseVideoPlayer (GestureControl)

- (id<SJPlayerGestureControl>)gestureControl {
    return _presentView;
}

- (void)setGestureRecognizerShouldTrigger:(BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull, SJPlayerGestureType, CGPoint))gestureRecognizerShouldTrigger {
    objc_setAssociatedObject(self, @selector(gestureRecognizerShouldTrigger), gestureRecognizerShouldTrigger, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull, SJPlayerGestureType, CGPoint))gestureRecognizerShouldTrigger {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFastForwardViewController:(nullable id<SJEdgeFastForwardViewController>)fastForwardViewController {
    _fastForwardViewController = fastForwardViewController;
    [self _needUpdateFastForwardControllerProperties];
}
- (id<SJEdgeFastForwardViewController>)fastForwardViewController {
    if ( _fastForwardViewController == nil ) {
        _fastForwardViewController = [[SJEdgeFastForwardViewController alloc] init];
        [self _needUpdateFastForwardControllerProperties];
    }
    return _fastForwardViewController;
}
- (void)_needUpdateFastForwardControllerProperties {
    _fastForwardViewController.target = self.presentView;
}

- (void)setAllowHorizontalTriggeringOfPanGesturesInCells:(BOOL)allowHorizontalTriggeringOfPanGesturesInCells {
    _controlInfo->gestureControl.allowHorizontalTriggeringOfPanGesturesInCells = allowHorizontalTriggeringOfPanGesturesInCells;
}

- (BOOL)allowHorizontalTriggeringOfPanGesturesInCells {
    return _controlInfo->gestureControl.allowHorizontalTriggeringOfPanGesturesInCells;
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
    [self _setupControlLayerAppearManager];
}

- (id<SJControlLayerAppearManager>)controlLayerAppearManager {
    if ( _controlLayerAppearManager == nil ) {
        [self setControlLayerAppearManager:SJControlLayerAppearStateManager.alloc.init];
    }
    return _controlLayerAppearManager;
}

- (id<SJControlLayerAppearManagerObserver>)controlLayerAppearObserver {
    id<SJControlLayerAppearManagerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.controlLayerAppearManager getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}

- (void)setCanAutomaticallyDisappear:(BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))canAutomaticallyDisappear {
    objc_setAssociatedObject(self, @selector(canAutomaticallyDisappear), canAutomaticallyDisappear, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))canAutomaticallyDisappear {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)_setupControlLayerAppearManager {
    if ( !_controlLayerAppearManager )
        return;
    
    self.viewControllerManager.controlLayerAppearManager = _controlLayerAppearManager;
    
    __weak typeof(self) _self = self;
    _controlLayerAppearManager.canAutomaticallyDisappear = ^BOOL(id<SJControlLayerAppearManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;

        if ( [self.controlLayerDelegate respondsToSelector:@selector(controlLayerOfVideoPlayerCanAutomaticallyDisappear:)] ) {
            if ( ![self.controlLayerDelegate controlLayerOfVideoPlayerCanAutomaticallyDisappear:self] ) {
                return NO;
            }
        }
        
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
        
        if ( !self.rotationManager.isFullscreen ||
              self.rotationManager.isTransitioning ) {
            [UIView animateWithDuration:0 animations:^{
            } completion:^(BOOL finished) {
                [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
            }];
        }
        else {
            [UIView animateWithDuration:0.25 animations:^{
                [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
            }];
        }
    };
}

/// 控制层是否显示
- (void)setControlLayerAppeared:(BOOL)controlLayerAppeared {
    controlLayerAppeared ? [self.controlLayerAppearManager needAppear] :
                           [self.controlLayerAppearManager needDisappear];
}
- (BOOL)isControlLayerAppeared {
    return self.controlLayerAppearManager.isAppeared;
}

/// 暂停时是否保持控制层一直显示
- (void)setPausedToKeepAppearState:(BOOL)pausedToKeepAppearState {
    _controlInfo->controlLayer.pausedToKeepAppearState = pausedToKeepAppearState;
}
- (BOOL)pausedToKeepAppearState {
    return _controlInfo->controlLayer.pausedToKeepAppearState;
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
- (void)setUseFitOnScreenAndDisableRotation:(BOOL)useFitOnScreenAndDisableRotation {
    _useFitOnScreenAndDisableRotation = useFitOnScreenAndDisableRotation;
}
- (BOOL)useFitOnScreenAndDisableRotation {
    return _useFitOnScreenAndDisableRotation;
}

- (void)setFitOnScreenManager:(id<SJFitOnScreenManager> _Nullable)fitOnScreenManager {
    _fitOnScreenManager = fitOnScreenManager;
    [self _setupFitOnScreenManager];
}

- (id<SJFitOnScreenManager>)fitOnScreenManager {
    if ( _fitOnScreenManager == nil ) {
        SJFitOnScreenManager *mgr = [[SJFitOnScreenManager alloc] initWithTarget:self.presentView targetSuperview:self.view];
        mgr.viewControllerManager = self.viewControllerManager;
        [self setFitOnScreenManager:mgr];
    }
    return _fitOnScreenManager;
}

- (id<SJFitOnScreenManagerObserver>)fitOnScreenObserver {
    id<SJFitOnScreenManagerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.fitOnScreenManager getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}

- (void)_setupFitOnScreenManager {
    if ( _fitOnScreenManager == nil ) return;
    
    self.viewControllerManager.fitOnScreenManager = _fitOnScreenManager;
    
    _fitOnScreenManagerObserver = [_fitOnScreenManager getObserver];
    __weak typeof(self) _self = self;
    _fitOnScreenManagerObserver.fitOnScreenWillBeginExeBlock = ^(id<SJFitOnScreenManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.useFitOnScreenAndDisableRotation = YES;
        [self controlLayerNeedDisappear];
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:willFitOnScreen:)] ) {
            [self.controlLayerDelegate videoPlayer:self willFitOnScreen:mgr.isFitOnScreen];
        }
        
        [UIView performWithoutAnimation:^{
            [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
        }];
    };
    
    _fitOnScreenManagerObserver.fitOnScreenDidEndExeBlock = ^(id<SJFitOnScreenManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.autoManageViewToFitOnScreenOrRotation && !mgr.isFitOnScreen ) {
            CGSize presentationSize = self.playbackController.presentationSize;
            self.useFitOnScreenAndDisableRotation = presentationSize.width < presentationSize.height;
        }
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:didCompleteFitOnScreen:)] ) {
            [self.controlLayerDelegate videoPlayer:self didCompleteFitOnScreen:mgr.isFitOnScreen];
        }
        
        [UIView performWithoutAnimation:^{
            [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
        }];
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
    __weak typeof(self) _self = self;
    [self.fitOnScreenManager setFitOnScreen:fitOnScreen animated:animated completionHandler:^(id<SJFitOnScreenManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completionHandler ) completionHandler(self);
    }];
}
@end


#pragma mark - 屏幕旋转

@implementation SJBaseVideoPlayer (Rotation)

- (void)setRotationManager:(nullable id<SJRotationManager>)rotationManager {
    _rotationManager = rotationManager;
    [self _setupRotationManager:rotationManager];
}

- (id<SJRotationManager>)rotationManager {
    if ( _rotationManager == nil ) {
        SJRotationManager *mgr = [SJRotationManager.alloc init];
        mgr.viewControllerManager = self.viewControllerManager;
        [self setRotationManager:mgr];
    }
    return _rotationManager;
}

- (id<SJRotationManagerObserver>)rotationObserver {
    id<SJRotationManagerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.rotationManager getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}

- (void)setShouldTriggerRotation:(BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))shouldTriggerRotation {
    objc_setAssociatedObject(self, @selector(shouldTriggerRotation), shouldTriggerRotation, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))shouldTriggerRotation {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)_setupRotationManager:(id<SJRotationManager>)rotationManager {
    if ( !rotationManager )
        return;
    
    self.viewControllerManager.rotationManager = rotationManager;
    
    rotationManager.superview = self.view;
    rotationManager.target = self.presentView;
    __weak typeof(self) _self = self;
    rotationManager.shouldTriggerRotation = ^BOOL(id<SJRotationManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        if ( mgr.isFullscreen == NO ) {
            if ( self.playModelObserver.isScrolling ) return NO;
            if ( !self.view.superview ) return NO;
//            UIWindow *_Nullable window = self.view.window;
//            if ( window && !window.isKeyWindow ) return NO;
            if ( self.isPlayOnScrollView && !(self.isScrollAppeared || self.controlInfo->floatSmallViewControl.isAppeared) ) return NO;
            if ( self.touchedOnTheScrollView ) return NO;
        }
        if ( self.isLockedScreen ) return NO;
        if ( self.useFitOnScreenAndDisableRotation ) return NO;
        if ( self.viewControllerManager.isViewDisappeared ) return NO;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(canTriggerRotationOfVideoPlayer:)] ) {
            if ( ![self.controlLayerDelegate canTriggerRotationOfVideoPlayer:self] )
                return NO;
        }
        if ( self.atViewController.presentedViewController ) return NO;
        if ( self.shouldTriggerRotation && !self.shouldTriggerRotation(self) ) return NO;
        return YES;
    };
    
    _rotationManagerObserver = [rotationManager getObserver];
    _rotationManagerObserver.rotationDidStartExeBlock = ^(id<SJRotationManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:willRotateView:)] ) {
            [self.controlLayerDelegate videoPlayer:self willRotateView:mgr.isFullscreen];
        }
        
        [self controlLayerNeedDisappear];
        
//        UINavigationController *nav = [self.view lookupResponderForClass:UINavigationController.class];
////        _updateBarsForCurrentInterfaceOrientation
//        [nav performSelector:@selector(_updateBarsForCurrentInterfaceOrientation)];
                
        ///
        /// Thanks @SuperEvilRabbit
        /// https://github.com/changsanjiang/SJVideoPlayer/issues/58
        ///
        [UIView animateWithDuration:0 animations:^{ } completion:^(BOOL finished) {
            if ( mgr.isFullscreen )
                [self needHiddenStatusBar];
            else
                [self needShowStatusBar];
        }];
    };
    
    _rotationManagerObserver.rotationDidEndExeBlock = ^(id<SJRotationManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.autoManageViewToFitOnScreenOrRotation && !mgr.isFullscreen ) {
            CGSize presentationSize = self.playbackController.presentationSize;
            self.useFitOnScreenAndDisableRotation = presentationSize.width < presentationSize.height;
        }
        [self.playModelObserver refreshAppearState];
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:didEndRotation:)] ) {
            [self.controlLayerDelegate videoPlayer:self didEndRotation:mgr.isFullscreen];
        }
        
        if ( mgr.isFullscreen ) {
            [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
        }
        else {
            [UIView animateWithDuration:0.25 animations:^{
                [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
            }];
        }
    };
}

- (void)rotate {
    [self.rotationManager rotate];
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated {
    [self.rotationManager rotate:orientation animated:animated];
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completion:(void (^ _Nullable)(__kindof SJBaseVideoPlayer *player))block {
    __weak typeof(self) _self = self;
    [self.rotationManager rotate:orientation animated:animated completionHandler:^(id<SJRotationManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self);
    }];
}

- (BOOL)isTransitioning {
    return self.rotationManager.isTransitioning;
}

- (BOOL)isFullScreen {
    return self.rotationManager.isFullscreen;
}

- (UIInterfaceOrientation)currentOrientation {
    return (NSInteger)self.rotationManager.currentOrientation;
}

- (void)setLockedScreen:(BOOL)lockedScreen {
    if ( lockedScreen != self.isLockedScreen ) {
        self.viewControllerManager.lockedScreen = lockedScreen;
        objc_setAssociatedObject(self, @selector(isLockedScreen), @(lockedScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if      ( lockedScreen && [self.controlLayerDelegate respondsToSelector:@selector(lockedVideoPlayer:)] ) {
            [self.controlLayerDelegate lockedVideoPlayer:self];
        }
        else if ( !lockedScreen && [self.controlLayerDelegate respondsToSelector:@selector(unlockedVideoPlayer:)] ) {
            [self.controlLayerDelegate unlockedVideoPlayer:self];
        }
        
        [self _postNotification:SJVideoPlayerLockedScreenDidChangeNotification];
    }
}

- (BOOL)isLockedScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end



@implementation SJBaseVideoPlayer (Screenshot)

- (void)setPresentationSizeDidChangeExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))presentationSizeDidChangeExeBlock {
    objc_setAssociatedObject(self, @selector(presentationSizeDidChangeExeBlock), presentationSizeDidChangeExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))presentationSizeDidChangeExeBlock {
    return objc_getAssociatedObject(self, _cmd);
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
        [(id<SJMediaPlaybackScreenshotController>)_playbackController screenshotWithTime:time size:size completion:^(id<SJVideoPlayerPlaybackController>  _Nonnull controller, UIImage * _Nullable image, NSError * _Nullable error) {
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
                    duration:(NSTimeInterval)duration
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, float progress))progressBlock
                 completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, NSURL *fileURL, UIImage *thumbnailImage))completion
                    failure:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, NSError *error))failure {
    if ( [_playbackController respondsToSelector:@selector(exportWithBeginTime:duration:presetName:progress:completion:failure:)] ) {
        __weak typeof(self) _self = self;
        [(id<SJMediaPlaybackExportController>)_playbackController exportWithBeginTime:beginTime duration:duration presetName:presetName progress:^(id<SJVideoPlayerPlaybackController>  _Nonnull controller, float progress) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( progressBlock ) progressBlock(self, progress);
        } completion:^(id<SJVideoPlayerPlaybackController>  _Nonnull controller, NSURL * _Nullable fileURL, UIImage * _Nullable thumbImage) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( completion ) completion(self, fileURL, thumbImage);
        } failure:^(id<SJVideoPlayerPlaybackController>  _Nonnull controller, NSError * _Nullable error) {
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
        [(id<SJMediaPlaybackExportController>)_playbackController generateGIFWithBeginTime:beginTime duration:duration maximumSize:CGSizeMake(375, 375) interval:0.1f gifSavePath:filePath progress:^(id<SJVideoPlayerPlaybackController>  _Nonnull controller, float progress) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( progressBlock ) progressBlock(self, progress);
        } completion:^(id<SJVideoPlayerPlaybackController>  _Nonnull controller, UIImage * _Nonnull imageGIF, UIImage * _Nonnull screenshot) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( completion ) completion(self, imageGIF, screenshot, filePath);
        } failure:^(id<SJVideoPlayerPlaybackController>  _Nonnull controller, NSError * _Nonnull error) {
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

- (void)setFloatSmallViewController:(nullable id<SJFloatSmallViewController>)floatSmallViewController {
    _floatSmallViewController = floatSmallViewController;
    [self _resetFloatSmallViewControllerObserver:floatSmallViewController];
}
- (id<SJFloatSmallViewController>)floatSmallViewController {
    if ( _floatSmallViewController == nil ) {
        _floatSmallViewController = [[SJFloatSmallViewController alloc] init];

        __weak typeof(self) _self = self;
        _floatSmallViewController.floatViewShouldAppear = ^BOOL(id<SJFloatSmallViewController>  _Nonnull controller) {
            __strong typeof(_self) self = _self;
            if ( !self ) return NO;
            return self.timeControlStatus != SJPlaybackTimeControlStatusPaused && self.assetStatus != SJAssetStatusUnknown;
        };
        
        [self _resetFloatSmallViewControllerObserver:_floatSmallViewController];
    }
    return _floatSmallViewController;
}
- (void)_resetFloatSmallViewControllerObserver:(nullable id<SJFloatSmallViewController>)floatSmallViewController {
    if ( _floatSmallViewController == nil ) {
        _floatSmallViewControllerObesrver = nil;
        return;
    }
    
    floatSmallViewController.targetSuperview = self.view;
    floatSmallViewController.target = self.presentView;
    
    __weak typeof(self) _self = self;
    _floatSmallViewControllerObesrver = [_floatSmallViewController getObserver];
    _floatSmallViewControllerObesrver.appearStateDidChangeExeBlock = ^(id<SJFloatSmallViewController>  _Nonnull controller) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        BOOL isAppeared = controller.isAppeared;
        self.controlInfo->floatSmallViewControl.isAppeared = isAppeared;
        self.rotationManager.superview = isAppeared?controller.floatView:self.view;
    };
}

- (void)setAutoDisappearFloatSmallView:(BOOL)autoDisappearFloatSmallView {
    _controlInfo->floatSmallViewControl.autoDisappearFloatSmallView = autoDisappearFloatSmallView;
}
- (BOOL)autoDisappearFloatSmallView {
    return _controlInfo->floatSmallViewControl.autoDisappearFloatSmallView;
}

- (void)setPauseWhenScrollDisappeared:(BOOL)pauseWhenScrollDisappeared {
    _controlInfo->scrollControl.pauseWhenScrollDisappeared = pauseWhenScrollDisappeared;
}
- (BOOL)pauseWhenScrollDisappeared {
    return _controlInfo->scrollControl.pauseWhenScrollDisappeared;
}

- (void)setHiddenViewWhenScrollDisappeared:(BOOL)hiddenViewWhenScrollDisappeared {
    _controlInfo->scrollControl.hiddenPlayerViewWhenScrollDisappeared = hiddenViewWhenScrollDisappeared;
}
- (BOOL)hiddenViewWhenScrollDisappeared {
    return _controlInfo->scrollControl.hiddenPlayerViewWhenScrollDisappeared;
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
    return _controlInfo->scrollControl.isScrollAppeared;
}

- (void)setPlayerViewWillAppearExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))playerViewWillAppearExeBlock {
    objc_setAssociatedObject(self, @selector(playerViewWillAppearExeBlock), playerViewWillAppearExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))playerViewWillAppearExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlayerViewWillDisappearExeBlock:(void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))playerViewWillDisappearExeBlock {
    objc_setAssociatedObject(self, @selector(playerViewWillDisappearExeBlock), playerViewWillDisappearExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^_Nullable)(__kindof SJBaseVideoPlayer * _Nonnull))playerViewWillDisappearExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}
@end


@implementation SJBaseVideoPlayer (Subtitles)
- (void)setSubtitlesPromptController:(nullable id<SJSubtitlesPromptController>)subtitlesPromptController {
    [_subtitlesPromptController.view removeFromSuperview];
    _subtitlesPromptController = subtitlesPromptController;
    if ( subtitlesPromptController ) {
        [self.presentView insertSubview:subtitlesPromptController.view aboveSubview:self.playbackController.playerView];
        [subtitlesPromptController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_greaterThanOrEqualTo(self.subtitleHorizontalMinMargin);
            make.right.mas_lessThanOrEqualTo(-self.subtitleHorizontalMinMargin);
            make.centerX.offset(0);
            make.bottom.offset(-self.subtitleBottomMargin);
        }];
    }
}

- (id<SJSubtitlesPromptController>)subtitlesPromptController {
    if ( _subtitlesPromptController == nil ) {
        self.subtitlesPromptController = SJSubtitlesPromptController.alloc.init;
    }
    return _subtitlesPromptController;
}

- (void)setSubtitleBottomMargin:(CGFloat)subtitleBottomMargin {
    objc_setAssociatedObject(self, @selector(subtitleBottomMargin), @(subtitleBottomMargin), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.subtitlesPromptController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-subtitleBottomMargin);
    }];
}
- (CGFloat)subtitleBottomMargin {
    id value = objc_getAssociatedObject(self, _cmd);
    return value != nil ? [value doubleValue] : 22;
}

- (void)setSubtitleHorizontalMinMargin:(CGFloat)subtitleHorizontalMinMargin {
    objc_setAssociatedObject(self, @selector(subtitleHorizontalMinMargin), @(subtitleHorizontalMinMargin), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.subtitlesPromptController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_greaterThanOrEqualTo(subtitleHorizontalMinMargin);
        make.right.mas_lessThanOrEqualTo(-subtitleHorizontalMinMargin);
    }];
}
- (CGFloat)subtitleHorizontalMinMargin {
    id value = objc_getAssociatedObject(self, _cmd);
    return value != nil ? [value doubleValue] : 22;
}
@end


#pragma mark - 提示

@implementation SJBaseVideoPlayer (PromptControl)
- (void)setPopPromptController:(nullable id<SJPopPromptController>)popPromptController {
    objc_setAssociatedObject(self, @selector(popPromptController), popPromptController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( popPromptController != nil ) {
        [self _setupPopPromptController];
    }
}

- (id<SJPopPromptController>)popPromptController {
    id<SJPopPromptController>_Nullable controller = objc_getAssociatedObject(self, _cmd);
    if ( controller == nil ) {
        controller = [SJPopPromptController new];
        objc_setAssociatedObject(self, _cmd, controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self _setupPopPromptController];
    }
    return controller;
}
- (void)_setupPopPromptController {
    id<SJPopPromptController>_Nullable controller = objc_getAssociatedObject(self, @selector(popPromptController));
    controller.target = self.presentView;
}

- (void)setPrompt:(nullable id<SJPromptProtocol>)prompt {
    objc_setAssociatedObject(self, @selector(prompt), prompt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _setupPrompt];
}
- (id<SJPromptProtocol>)prompt {
    id<SJPromptProtocol> prompt = objc_getAssociatedObject(self, _cmd);
    if ( prompt == nil ) {
        prompt = SJPrompt.alloc.init;
        objc_setAssociatedObject(self, _cmd, prompt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self _setupPrompt];
    }
    return prompt;
}
- (void)_setupPrompt {
    id<SJPromptProtocol> prompt = objc_getAssociatedObject(self, @selector(prompt));
    prompt.target = self.presentView;
}
@end


@implementation SJBaseVideoPlayer (Barrages)
- (void)setBarrageQueueController:(nullable id<SJBarrageQueueController>)barrageQueueController {
    if ( _barrageQueueController != nil )
        [_barrageQueueController.view removeFromSuperview];
    
    _barrageQueueController = barrageQueueController;
    if ( barrageQueueController != nil ) {
        [self.presentView insertSubview:barrageQueueController.view aboveSubview:self.presentView.placeholderImageView];
        [barrageQueueController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.offset(0);
        }];
    }
}
- (id<SJBarrageQueueController>)barrageQueueController {
    id<SJBarrageQueueController> controller = _barrageQueueController;
    if ( controller == nil ) {
        controller = [SJBarrageQueueController.alloc initWithLines:4];
        [self setBarrageQueueController:controller];
    }
    return controller;
}
@end


#pragma mark -

@interface SJBaseVideoPlayer (SJPlayModelPropertiesObserverDelegate)<SJPlayModelPropertiesObserverDelegate>
@end

@implementation SJBaseVideoPlayer (SJPlayModelPropertiesObserverDelegate)
- (void)observer:(nonnull SJPlayModelPropertiesObserver *)observer userTouchedCollectionView:(BOOL)touched { /* nothing */ }
- (void)observer:(nonnull SJPlayModelPropertiesObserver *)observer userTouchedTableView:(BOOL)touched { /* nothing */ }

- (void)playerWillAppearForObserver:(nonnull SJPlayModelPropertiesObserver *)observer superview:(nonnull UIView *)superview {
    if ( _controlInfo->scrollControl.isScrollAppeared ) {
        return;
    }
    
    _controlInfo->scrollControl.isScrollAppeared = YES;
    
    if ( _controlInfo->scrollControl.hiddenPlayerViewWhenScrollDisappeared ) {
        _view.hidden = NO;
    }
    
    if ( _playbackController.isPlayed ) {
        if ( !self.viewControllerManager.isViewDisappeared ) {
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
    
    if ( _floatSmallViewController.isAppeared ) {
        [_floatSmallViewController dismissFloatView];
    }
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayerWillAppearInScrollView:)] ) {
        [self.controlLayerDelegate videoPlayerWillAppearInScrollView:self];
    }
    
    if ( self.playerViewWillAppearExeBlock )
        self.playerViewWillAppearExeBlock(self);
}
- (void)playerWillDisappearForObserver:(nonnull SJPlayModelPropertiesObserver *)observer {
    if ( _controlInfo->scrollControl.isScrollAppeared == NO ) {
        return;
    }
    
    if ( _rotationManager.isTransitioning )
        return;

    _controlInfo->scrollControl.isScrollAppeared = NO;
    
    _view.hidden = _controlInfo->scrollControl.hiddenPlayerViewWhenScrollDisappeared;
    
    if ( _floatSmallViewController.isEnabled ) {
        [_floatSmallViewController showFloatView];
    }
    else if ( _controlInfo->scrollControl.pauseWhenScrollDisappeared ) {
        [self pause];
    }
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayerWillDisappearInScrollView:)] ) {
        [self.controlLayerDelegate videoPlayerWillDisappearInScrollView:self];
    }
    
    if ( self.playerViewWillDisappearExeBlock )
        self.playerViewWillDisappearExeBlock(self);
}
@end


#pragma mark -

@implementation SJBaseVideoPlayer (Deprecated)
- (void)playWithURL:(NSURL *)URL {
    self.assetURL = URL;
}
- (void)setAssetURL:(nullable NSURL *)assetURL {
    self.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:assetURL];
}

- (nullable NSURL *)assetURL {
    return self.URLAsset.mediaURL;
}
@end
NS_ASSUME_NONNULL_END
