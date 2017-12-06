//
//  SJVideoPlayer.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayer.h"
#import "SJVideoPlayerAssetCarrier.h"
#import <Masonry/Masonry.h>
#import "SJVideoPlayerPresentView.h"
#import "SJVideoPlayerControlView.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/message.h>
#import "SJVideoPlayerResources.h"
#import <MediaPlayer/MPVolumeView.h>
#import "SJVideoPlayerMoreSettingsView.h"
#import "SJVideoPlayerMoreSettingSecondaryView.h"
#import <SJPrompt/SJPrompt.h>
#import "SJOrentationObserver.h"
#import "SJVideoPlayerRegistrar.h"
#import "SJVolumeAndBrightness.h"
#import "SJTimerControl.h"


#define MoreSettingWidth (MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) * 0.382)

inline static void _sjErrorLog(NSString *msg) {
    NSLog(@"__error__: %@", msg);
}

inline static void _sjHiddenViews(NSArray<UIView *> *views) {
    [views enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.alpha = 0.001;
    }];
}

inline static void _sjShowViews(NSArray<UIView *> *views) {
    [views enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.alpha = 1;
    }];
}

inline static void _sjAnima(void(^block)(void)) {
    if ( block ) {
        [UIView animateWithDuration:0.3 animations:^{
            block();
        }];
    }
}

inline static NSString *_formatWithSec(NSInteger sec) {
    NSInteger seconds = sec % 60;
    NSInteger minutes = sec / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}




#pragma mark -

@interface SJVideoPlayer ()<SJVideoPlayerControlViewDelegate, SJSliderDelegate>

@property (nonatomic, strong, readonly) SJVideoPlayerPresentView *presentView;
@property (nonatomic, strong, readonly) SJVideoPlayerControlView *controlView;
@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingsView *moreSettingView;
@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingSecondaryView *moreSecondarySettingView;
@property (nonatomic, strong, readonly) SJOrentationObserver *orentation;
@property (nonatomic, strong, readonly) SJMoreSettingsFooterViewModel *moreSettingFooterViewModel;
@property (nonatomic, strong, readonly) SJVideoPlayerRegistrar *registrar;
@property (nonatomic, strong, readonly) SJVolumeAndBrightness *volBrig;

@property (nonatomic, assign, readwrite) SJVideoPlayerPlayState state;
@property (nonatomic, assign, readwrite) BOOL hiddenMoreSettingView;
@property (nonatomic, assign, readwrite) BOOL hiddenMoreSecondarySettingView;
@property (nonatomic, assign, readwrite) BOOL hiddenLeftControlView;
@property (nonatomic, assign, readwrite) BOOL userClickedPause;

- (void)_play;
- (void)_pause;

@end





#pragma mark - State

@interface SJVideoPlayer (State)

@property (nonatomic, assign, readwrite, getter=isHiddenControl) BOOL hideControl;
@property (nonatomic, assign, readwrite, getter=isLockedScrren) BOOL lockScreen;

- (void)_cancelDelayHiddenControl;

- (void)_delayHiddenControl;

- (void)_prepareState;

- (void)_playState;

- (void)_pauseState;

- (void)_stopState;

- (void)_playEndState;

- (void)_playFailedState;

@end

@implementation SJVideoPlayer (State)

- (SJTimerControl *)timerControl {
    SJTimerControl *timerControl = objc_getAssociatedObject(self, _cmd);
    if ( timerControl ) return timerControl;
    timerControl = [SJTimerControl new];
    objc_setAssociatedObject(self, _cmd, timerControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return timerControl;
}

- (void)_cancelDelayHiddenControl {
    [self.timerControl reset];
}

- (void)_delayHiddenControl {
    __weak typeof(self) _self = self;
    [self.timerControl start:^(SJTimerControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        _sjAnima(^{
            self.hideControl = YES;
        });
    }];
}

- (void)setLockScreen:(BOOL)lockScreen {
    if ( self.isLockedScrren == lockScreen ) return;
    objc_setAssociatedObject(self, @selector(isLockedScrren), @(lockScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _sjAnima(^{
        if ( lockScreen ) {
            [self _lockScreenState];
        }
        else {
            [self _unlockScreenState];
        }
    });
    
    if ( self.orentation.fullScreen ) {
        [UIApplication sharedApplication].statusBarHidden = lockScreen;
    }
}

- (BOOL)isLockedScrren {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setHideControl:(BOOL)hideControl {
    if ( self.isHiddenControl == hideControl ) return;
    if ( self.isLockedScrren ) return;
    objc_setAssociatedObject(self, @selector(isHiddenControl), @(hideControl), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.timerControl reset];
    if ( hideControl ) [self _hideControlState];
    else {
        [self _showControlState];
        [self _delayHiddenControl];
    }
}

- (BOOL)isHiddenControl {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)_prepareState {
    
    // show
    _sjShowViews(@[self.presentView.placeholderImageView]);
    
    // hidden
    self.controlView.previewView.hidden = YES;
    _sjHiddenViews(@[
                     self.controlView.draggingProgressView,
                     self.controlView.topControlView.previewBtn,
                     self.controlView.leftControlView.lockBtn,
                     self.controlView.centerControlView.failedBtn,
                     self.controlView.centerControlView.replayBtn,
                     self.controlView.bottomControlView.playBtn,
                     self.controlView.bottomProgressSlider,
                     ]);
    
    if ( self.orentation.fullScreen ) {
        _sjShowViews(@[self.controlView.topControlView.moreBtn,]);
        self.hiddenLeftControlView = NO;
        if ( self.asset.hasBeenGeneratedPreviewImages ) {
            _sjShowViews(@[self.controlView.topControlView.previewBtn]);
        }
    }
    else {
        self.hiddenLeftControlView = YES;
        _sjHiddenViews(@[self.controlView.topControlView.moreBtn,
                         self.controlView.topControlView.previewBtn,]);
    }
    
    self.state = SJVideoPlayerPlayState_Prepare;
}

- (void)_playState {
    
    // show
    _sjShowViews(@[self.controlView.bottomControlView.pauseBtn]);
    
    // hidden
    _sjHiddenViews(@[
                     self.presentView.placeholderImageView,
                     self.controlView.bottomControlView.playBtn,
                     self.controlView.centerControlView.replayBtn,
                     ]);
    
    self.state = SJVideoPlayerPlayState_Playing;
}

- (void)_pauseState {
    
    // show
    _sjShowViews(@[self.controlView.bottomControlView.playBtn]);
    
    // hidden
    _sjHiddenViews(@[self.controlView.bottomControlView.pauseBtn]);
    
    self.state = SJVideoPlayerPlayState_Pause;
}

- (void)_stopState {
    
    // show
    [self _pauseState];
    _sjShowViews(@[self.presentView.placeholderImageView,]);
    
    
    self.state = SJVideoPlayerPlayState_Unknown;
}

- (void)_playEndState {
    
    // show
    _sjShowViews(@[self.controlView.centerControlView.replayBtn,
                   self.controlView.bottomControlView.playBtn]);
    
    // hidden
    _sjHiddenViews(@[self.controlView.bottomControlView.pauseBtn]);
    
    
    self.state = SJVideoPlayerPlayState_PlayEnd;
}

- (void)_playFailedState {
    // show
    _sjShowViews(@[self.controlView.centerControlView.failedBtn]);
    
    // hidden
    _sjHiddenViews(@[self.controlView.centerControlView.replayBtn]);
    
    self.state = SJVideoPlayerPlayState_PlayFailed;
}

- (void)_lockScreenState {
    
    // show
    _sjShowViews(@[self.controlView.leftControlView.lockBtn]);
    
    // hidden
    _sjHiddenViews(@[self.controlView.leftControlView.unlockBtn]);
    
    // transform hidden
    self.controlView.topControlView.transform = CGAffineTransformMakeTranslation(0, - self.controlView.topControlView.frame.size.height);
    self.controlView.bottomControlView.transform = CGAffineTransformMakeTranslation(0, self.controlView.bottomControlView.frame.size.height);
}

- (void)_unlockScreenState {
    
    // show
    _sjShowViews(@[self.controlView.leftControlView.unlockBtn]);
    
    // hidden
    _sjHiddenViews(@[self.controlView.leftControlView.lockBtn]);
    
    // transform show
    self.controlView.topControlView.transform = self.controlView.bottomControlView.transform = CGAffineTransformIdentity;
}

- (void)_hideControlState {

    // show
    _sjShowViews(@[self.controlView.bottomProgressSlider]);
    
    // hidden
    self.controlView.previewView.hidden = YES;
    
    // transform hidden
    self.controlView.topControlView.transform = CGAffineTransformMakeTranslation(0, - self.controlView.topControlView.frame.size.height);
    self.controlView.bottomControlView.transform = CGAffineTransformMakeTranslation(0, self.controlView.bottomControlView.frame.size.height);

    self.hiddenLeftControlView = YES;
}

- (void)_showControlState {
    
    // hidden
    _sjHiddenViews(@[self.controlView.bottomProgressSlider]);
    self.controlView.previewView.hidden = YES;
    
    // transform show
    self.controlView.topControlView.transform = self.controlView.bottomControlView.transform = CGAffineTransformIdentity;
    
    self.hiddenLeftControlView = !self.orentation.fullScreen;
}

@end





#pragma mark - Gesture

@interface SJVideoPlayer (GestureRecognizer)<UIGestureRecognizerDelegate>

- (void)_settingControlViewGestureDelegate;

@end

typedef NS_ENUM(NSUInteger, SJPanDirection) {
    SJPanDirection_Unknown,
    SJPanDirection_V,
    SJPanDirection_H,
};


typedef NS_ENUM(NSUInteger, SJVerticalPanLocation) {
    SJVerticalPanLocation_Unknown,
    SJVerticalPanLocation_Left,
    SJVerticalPanLocation_Right,
};

@implementation SJVideoPlayer (GestureRecognizer)

- (void)_settingControlViewGestureDelegate {
    self.controlView.singleTap.delegate = self;
    self.controlView.doubleTap.delegate = self;
    self.controlView.panGR.delegate = self;
}

- (void)setPanDirection:(SJPanDirection)panDirection {
    objc_setAssociatedObject(self, @selector(panDirection), @(panDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJPanDirection)panDirection {
    return (SJPanDirection)[objc_getAssociatedObject(self , _cmd) integerValue];
}

- (void)setPanLocation:(SJVerticalPanLocation)panLocation {
    objc_setAssociatedObject(self, @selector(panLocation), @(panLocation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJVerticalPanLocation)panLocation {
    return (SJVerticalPanLocation)[objc_getAssociatedObject(self , _cmd) integerValue];
}

- (BOOL)_isFadeAreaWithGesture:(UIGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:gesture.view];
    if ( CGRectContainsPoint(self.moreSettingView.frame, point) ||
        CGRectContainsPoint(self.moreSecondarySettingView.frame, point) ||
        CGRectContainsPoint(self.controlView.previewView.frame, point) ) {
        [gesture setValue:@(UIGestureRecognizerStateCancelled) forKey:@"state"];
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ( self.isLockedScrren ) return NO;
    if ( [self _isFadeAreaWithGesture:gestureRecognizer] ) return NO;
    return YES;
}

- (void)controlView:(SJVideoPlayerControlView *)controlView handleSingleTap:(UITapGestureRecognizer *)tap {
    _sjAnima(^{
        if ( !self.hiddenMoreSettingView ) {
            self.hiddenMoreSettingView = YES;
        }
        else if ( !self.hiddenMoreSecondarySettingView ) {
            self.hiddenMoreSecondarySettingView = YES;
        }
        else {
            self.hideControl = !self.isHiddenControl;
        }
    });
}

- (void)controlView:(SJVideoPlayerControlView *)controlView handleDoubleTap:(UITapGestureRecognizer *)tap {
    switch (self.state) {
        case SJVideoPlayerPlayState_Unknown:
        case SJVideoPlayerPlayState_Prepare:
            break;
        case SJVideoPlayerPlayState_Buffing:
        case SJVideoPlayerPlayState_Playing: {
            [self pause];
        }
            break;
        case SJVideoPlayerPlayState_Pause:
        case SJVideoPlayerPlayState_PlayEnd: {
            [self play];
        }
            break;
        case SJVideoPlayerPlayState_PlayFailed:
            break;
    }
}

static UIView *target = nil;
- (void)controlView:(SJVideoPlayerControlView *)controlView handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint offset = [pan translationInView:pan.view];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            CGPoint velocity = [pan velocityInView:pan.view];
            CGFloat x = fabs(velocity.x);
            CGFloat y = fabs(velocity.y);
            if (x > y) {
                /// 水平移动, 调整进度
                self.panDirection = SJPanDirection_H;
                [self _pause];
                _sjAnima(^{
                    _sjShowViews(@[self.controlView.draggingProgressView]);
                });
                self.controlView.draggingProgressView.progressSlider.value = self.asset.progress;
                self.controlView.draggingProgressView.progressLabel.text = _formatWithSec(self.asset.currentTime);
                self.hideControl = YES;
            }
            else {
                /// 垂直移动, 调整音量 或者 亮度
                self.panDirection = SJPanDirection_V;
                CGPoint locationPoint = [pan locationInView:pan.view];
                if ( locationPoint.x > self.controlView.bounds.size.width / 2 ) {
                    self.panLocation = SJVerticalPanLocation_Right;
                    target = self.volBrig.volumeView;
                }
                else {
                    self.panLocation = SJVerticalPanLocation_Left;
                    target = self.volBrig.brightnessView;
                }
                [[UIApplication sharedApplication].keyWindow addSubview:target];
                [target mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_offset(CGSizeMake(155, 155));
                    make.center.equalTo([UIApplication sharedApplication].keyWindow);
                }];
                target.transform = self.controlView.superview.transform;
                _sjAnima(^{
                    _sjShowViews(@[target]);
                });
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case SJPanDirection_H:{
                    self.controlView.draggingProgressView.progressSlider.value += offset.x * 0.003;
                    self.controlView.draggingProgressView.progressLabel.text =  _formatWithSec(self.asset.duration * self.controlView.draggingProgressView.progressSlider.value);
                }
                    break;
                case SJPanDirection_V:{
                    switch (self.panLocation) {
                        case SJVerticalPanLocation_Left: {
                            CGFloat value = self.volBrig.brightness - offset.y * 0.006;
                            if ( value < 1.0 / 16 ) value = 1.0 / 16;
                            self.volBrig.brightness = value;
                        }
                            break;
                        case SJVerticalPanLocation_Right: {
                            self.volBrig.volume -= offset.y * 0.006;
                        }
                            break;
                        case SJVerticalPanLocation_Unknown: break;
                    }
                }
                    break;
                case SJPanDirection_Unknown: break;
            }
            break;
        }
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            switch ( self.panDirection ) {
                case SJPanDirection_H:{
                    _sjAnima(^{
                        _sjHiddenViews(@[self.controlView.draggingProgressView]);
                    });
                    __weak typeof(self) _self = self;
                    [self jumpedToTime:self.controlView.draggingProgressView.progressSlider.value * self.asset.duration completionHandler:^(BOOL finished) {
                        __strong typeof(_self) self = _self;
                        if ( !self ) return ;
                        [self play];
                    }];
                }
                    break;
                case SJPanDirection_V:{
                    _sjAnima(^{
                        _sjHiddenViews(@[target]);
                    });
                }
                    break;
                case SJPanDirection_Unknown: break;
            }
            break;
        }
        default: break;
    }


    [pan setTranslation:CGPointZero inView:pan.view];
}


@end




#pragma mark - SJVideoPlayer
#import "SJMoreSettingsFooterViewModel.h"
#import "JDradualLoadingView.h"

@implementation SJVideoPlayer {
    SJVideoPlayerPresentView *_presentView;
    SJVideoPlayerControlView *_controlView;
    SJVideoPlayerMoreSettingsView *_moreSettingView;
    SJVideoPlayerMoreSettingSecondaryView *_moreSecondarySettingView;
    SJOrentationObserver *_orentation;
    UIView *_view;
    SJMoreSettingsFooterViewModel *_moreSettingFooterViewModel;
    SJVideoPlayerRegistrar *_registrar;
    SJVolumeAndBrightness *_volBrig;
    JDradualLoadingView *_loadingView;
}

+ (instancetype)sharedPlayer {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark

- (instancetype)init {
    self = [super init];
    if ( !self )  return nil;
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&error];
    if ( error ) {
        _sjErrorLog([NSString stringWithFormat:@"%@", error.userInfo]);
    }

    [self view];
    [self orentation];
    [self volBrig];
    [self _settingControlViewGestureDelegate];
    
    // default values
    self.autoplay = YES;
    self.generatePreviewImages = YES;
    
    return self;
}

- (SJVideoPlayerPresentView *)presentView {
    if ( _presentView ) return _presentView;
    _presentView = [SJVideoPlayerPresentView new];
    _presentView.clipsToBounds = YES;
    return _presentView;
}

- (SJVideoPlayerControlView *)controlView {
    if ( _controlView ) return _controlView;
    _controlView = [SJVideoPlayerControlView new];
    return _controlView;
}

- (UIView *)view {
    if ( _view ) return _view;
    _view = [UIView new];
    _view.backgroundColor = [UIColor blackColor];
    [_view addSubview:self.presentView];
    [_presentView addSubview:self.controlView];
    [_controlView addSubview:self.moreSettingView];
    [_controlView addSubview:self.moreSecondarySettingView];
    self.hiddenMoreSettingView = YES;
    self.hiddenMoreSecondarySettingView = YES;
    _controlView.delegate = self;
    _controlView.bottomControlView.progressSlider.delegate = self;
    
    [_presentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_moreSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.offset(0);
        make.width.offset(MoreSettingWidth);
    }];
    
    [_moreSecondarySettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_moreSettingView);
    }];
    
    _loadingView = [JDradualLoadingView new];
    _loadingView.lineWidth = 0.6;
    _loadingView.lineColor = [UIColor whiteColor];
    
    return _view;
}

- (SJVideoPlayerMoreSettingsView *)moreSettingView {
    if ( _moreSettingView ) return _moreSettingView;
    _moreSettingView = [SJVideoPlayerMoreSettingsView new];
    _moreSettingView.backgroundColor = [UIColor blackColor];
    return _moreSettingView;
}

- (SJVideoPlayerMoreSettingSecondaryView *)moreSecondarySettingView {
    if ( _moreSecondarySettingView ) return _moreSecondarySettingView;
    _moreSecondarySettingView = [SJVideoPlayerMoreSettingSecondaryView new];
    _moreSecondarySettingView.backgroundColor = [UIColor blackColor];
    _moreSettingFooterViewModel = [SJMoreSettingsFooterViewModel new];
    __weak typeof(self) _self = self;
    _moreSettingFooterViewModel.needChangeBrightness = ^(float brightness) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.volBrig.brightness = brightness;
    };
    
    _moreSettingFooterViewModel.needChangePlayerRate = ^(float rate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !self.asset ) return;
        self.asset.player.rate = rate;
        self.userClickedPause = NO;
        _sjAnima(^{
            [self _playState];
        });
    };
    
    _moreSettingFooterViewModel.needChangeVolume = ^(float volume) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.volBrig.volume = volume;
    };
    
    _moreSettingFooterViewModel.initialVolumeValue = ^float{
        __strong typeof(_self) self = _self;
        if ( !self ) return 0;
        return self.volBrig.volume;
    };
    
    _moreSettingFooterViewModel.initialBrightnessValue = ^float{
        __strong typeof(_self) self = _self;
        if ( !self ) return 0;
        return self.volBrig.brightness;
    };
    
    _moreSettingFooterViewModel.initialPlayerRateValue = ^float{
        __strong typeof(_self) self = _self;
        if ( !self ) return 0;
       return self.asset.player.rate;
    };
    
    _moreSettingView.footerViewModel = _moreSettingFooterViewModel;
    return _moreSecondarySettingView;
}

- (void)setHiddenMoreSettingView:(BOOL)hiddenMoreSettingView {
    if ( hiddenMoreSettingView == _hiddenMoreSettingView ) return;
    _hiddenMoreSettingView = hiddenMoreSettingView;
    if ( hiddenMoreSettingView ) {
        _moreSettingView.transform = CGAffineTransformMakeTranslation(MoreSettingWidth, 0);
    }
    else {
        _moreSettingView.transform = CGAffineTransformIdentity;
    }
}

- (void)setHiddenMoreSecondarySettingView:(BOOL)hiddenMoreSecondarySettingView {
    if ( hiddenMoreSecondarySettingView == _hiddenMoreSecondarySettingView ) return;
    _hiddenMoreSecondarySettingView = hiddenMoreSecondarySettingView;
    if ( hiddenMoreSecondarySettingView ) {
        _moreSecondarySettingView.transform = CGAffineTransformMakeTranslation(MoreSettingWidth, 0);
    }
    else {
        _moreSecondarySettingView.transform = CGAffineTransformIdentity;
    }
}

- (void)setHiddenLeftControlView:(BOOL)hiddenLeftControlView {
    if ( hiddenLeftControlView == _hiddenLeftControlView ) return;
    _hiddenLeftControlView = hiddenLeftControlView;
    if ( _hiddenLeftControlView ) {
        self.controlView.leftControlView.transform = CGAffineTransformMakeTranslation(-[UIScreen mainScreen].bounds.size.width, 0);
    }
    else {
        self.controlView.leftControlView.transform =  CGAffineTransformIdentity;
    }
}

- (SJOrentationObserver *)orentation {
    if ( _orentation ) return _orentation;
    _orentation = [[SJOrentationObserver alloc] initWithTarget:self.presentView container:self.view];
    __weak typeof(self) _self = self;
    _orentation.orientationChanged = ^(SJOrentationObserver * _Nonnull observer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _cancelDelayHiddenControl];
        [self _delayHiddenControl];
        _sjAnima(^{
            self.hideControl = NO;
            self.hiddenMoreSecondarySettingView = YES;
            self.hiddenMoreSettingView = YES;
            self.hiddenLeftControlView = !observer.isFullScreen;
            if ( observer.isFullScreen ) {
                _sjShowViews(@[self.controlView.topControlView.moreBtn,]);
                if ( self.asset.hasBeenGeneratedPreviewImages ) {
                    _sjShowViews(@[self.controlView.topControlView.previewBtn]);
                }
            }
            else {
                _sjHiddenViews(@[self.controlView.topControlView.moreBtn,
                                 self.controlView.topControlView.previewBtn,]);
            }
        });
    };
    
    _orentation.rotationCondition = ^BOOL(SJOrentationObserver * _Nonnull observer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        switch (self.state) {
            case SJVideoPlayerPlayState_Unknown:
            case SJVideoPlayerPlayState_Prepare:
            case SJVideoPlayerPlayState_PlayFailed: return NO;
            default: break;
        }
        if ( self.disableRotation ) return NO;
        if ( self.isLockedScrren ) return NO;
        return YES;
    };
    return _orentation;
}

- (SJVideoPlayerRegistrar *)registrar {
    if ( _registrar ) return _registrar;
    _registrar = [SJVideoPlayerRegistrar new];
    
    __weak typeof(self) _self = self;
    _registrar.willResignActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _pause];
        self.lockScreen = YES;
    };
    
    _registrar.didBecomeActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.lockScreen = NO;
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

- (SJVolumeAndBrightness *)volBrig {
    if ( _volBrig ) return _volBrig;
    _volBrig  = [SJVolumeAndBrightness new];
    __weak typeof(self) _self = self;
    _volBrig.volumeChanged = ^(float volume) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.moreSettingFooterViewModel.volumeChanged ) self.moreSettingFooterViewModel.volumeChanged(volume);
    };
    
    _volBrig.brightnessChanged = ^(float brightness) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.moreSettingFooterViewModel.brightnessChanged ) self.moreSettingFooterViewModel.brightnessChanged(self.volBrig.brightness);
    };
    return _volBrig;
}

#pragma mark ======================================================

- (void)sliderWillBeginDragging:(SJSlider *)slider {
    switch (slider.tag) {
        case SJVideoPlaySliderTag_Progress: {
            [self _pause];
            NSInteger currentTime = slider.value * self.asset.duration;
            [self _refreshingTimeLabelWithCurrentTime:currentTime duration:self.asset.duration];
            _sjAnima(^{
                _sjShowViews(@[self.controlView.draggingProgressView]);
            });
            [self _cancelDelayHiddenControl];
            self.controlView.draggingProgressView.progressSlider.value = slider.value;
            self.controlView.draggingProgressView.progressLabel.text = _formatWithSec(currentTime);
        }
            break;
            
        default:
            break;
    }
}

- (void)sliderDidDrag:(SJSlider *)slider {
    switch (slider.tag) {
        case SJVideoPlaySliderTag_Progress: {
            NSInteger currentTime = slider.value * self.asset.duration;
            [self _refreshingTimeLabelWithCurrentTime:currentTime duration:self.asset.duration];
            
            self.controlView.draggingProgressView.progressSlider.value = slider.value;
            self.controlView.draggingProgressView.progressLabel.text =  _formatWithSec(self.asset.duration * slider.value);
        }
            break;
            
        default:
            break;
    }
}

- (void)sliderDidEndDragging:(SJSlider *)slider {
    switch (slider.tag) {
        case SJVideoPlaySliderTag_Progress: {
            NSInteger currentTime = slider.value * self.asset.duration;
            __weak typeof(self) _self = self;
            [self jumpedToTime:currentTime completionHandler:^(BOOL finished) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                [self play];
                [self _delayHiddenControl];
                _sjAnima(^{
                    _sjHiddenViews(@[self.controlView.draggingProgressView]);
                });
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark ======================================================

- (void)controlView:(SJVideoPlayerControlView *)controlView clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    switch (tag) {
        case SJVideoPlayControlViewTag_Back: {
            if ( self.orentation.isFullScreen ) {
                if ( self.disableRotation ) return;
                else [self.orentation _changeOrientation];
            }
            else {
                if ( self.clickedBackEvent ) self.clickedBackEvent(self);
            }
        }
            break;
        case SJVideoPlayControlViewTag_Full: {
            [self.orentation _changeOrientation];
        }
            break;
            
        case SJVideoPlayControlViewTag_Play: {
            [self play];
        }
            break;
        case SJVideoPlayControlViewTag_Pause: {
            [self pause];
        }
            break;
        case SJVideoPlayControlViewTag_Replay: {
            _sjAnima(^{
                self.hideControl = NO;
            });
            [self play];
        }
            break;
        case SJVideoPlayControlViewTag_Preview: {
            [self _cancelDelayHiddenControl];
            _sjAnima(^{
                self.controlView.previewView.hidden = !self.controlView.previewView.isHidden;
            });
        }
            break;
        case SJVideoPlayControlViewTag_Lock: {
            // 解锁
            self.lockScreen = NO;
        }
            break;
        case SJVideoPlayControlViewTag_Unlock: {
            // 锁屏
            self.lockScreen = YES;
            [self showTitle:@"已锁定"];
        }
            break;
        case SJVideoPlayControlViewTag_LoadFailed: {
            self.asset = self.asset;
        }
            break;
        case SJVideoPlayControlViewTag_More: {
            _sjAnima(^{
                self.hiddenMoreSettingView = NO;
                self.hideControl = YES;
            });
        }
            break;
    }
}

- (void)controlView:(SJVideoPlayerControlView *)controlView didSelectPreviewItem:(SJVideoPreviewModel *)item {
    [self _pause];
    __weak typeof(self) _self = self;
    [self seekToTime:item.localTime completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self play];
    }];
}

#pragma mark

- (void)_itemPrepareToPlay {
    [self _startLoading];
    _sjAnima(^{
        self.hideControl = YES;
    });
    self.userClickedPause = NO;
    self.hiddenMoreSettingView = YES;
    self.hiddenMoreSecondarySettingView = YES;
    [self _prepareState];
}

- (void)_itemPlayFailed {
    [self _stopLoading];
    [self _playFailedState];
}

- (void)_itemReadyToPlay {
    _sjAnima(^{
        self.hideControl = NO;
    });
    if ( 0 != self.asset.beginTime && !self.asset.jumped ) {
        __weak typeof(self) _self = self;
        [self jumpedToTime:self.asset.beginTime completionHandler:^(BOOL finished) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.asset.jumped = YES;
            if ( self.autoplay ) [self play];
        }];
    }
    else {
        if ( self.autoplay && !self.userClickedPause ) [self play];
    }
}

- (void)_refreshingTimeLabelWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    self.controlView.bottomControlView.currentTimeLabel.text = _formatWithSec(currentTime);
    self.controlView.bottomControlView.durationTimeLabel.text = _formatWithSec(duration);
}

- (void)_refreshingTimeProgressSliderWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    self.controlView.bottomProgressSlider.value = self.controlView.bottomControlView.progressSlider.value = currentTime / duration;
}

- (void)_itemPlayEnd {
    [self jumpedToTime:0 completionHandler:nil];
    [self _playEndState];
}

- (void)_play {
    [self _stopLoading];
    [self.asset.player play];
    self.moreSettingFooterViewModel.playerRateChanged(self.asset.player.rate);
}

- (void)_pause {
    [self.asset.player pause];
}

static BOOL _isLoading;
- (void)_startLoading {
    if ( _isLoading ) return;
    _isLoading = YES;
    [_controlView addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.height.equalTo(_loadingView.superview).multipliedBy(0.2);
        make.width.equalTo(_loadingView.mas_height);
    }];
    [_loadingView startAnimation];
}

- (void)_stopLoading {
    _isLoading = NO;
    [_loadingView stopAnimation];
    [_loadingView removeFromSuperview];
}

- (void)_buffering {
    if ( self.state == SJVideoPlayerPlayState_PlayEnd ) return;
    if ( self.userClickedPause ) return;
    
    [self _startLoading];
    [self _pause];
    self.state = SJVideoPlayerPlayState_Buffing;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ( !self.asset.playerItem.isPlaybackLikelyToKeepUp ) {
            [self _buffering];
        }
        else {
            [self _stopLoading];
            if ( !self.userClickedPause ) [self play];
        }
    });
}

@end





#pragma mark -

@implementation SJVideoPlayer (Setting)

- (void)setAssetURL:(NSURL *)assetURL {
    self.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:assetURL];
}

- (NSURL *)assetURL {
    return self.asset.assetURL;
}

- (void)setAsset:(SJVideoPlayerAssetCarrier *)asset {
    if ( !asset ) return;
    objc_setAssociatedObject(self, @selector(asset), asset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _presentView.asset = asset;
    _controlView.asset = asset;
    
    [self _itemPrepareToPlay];
    
    __weak typeof(self) _self = self;
    _presentView.readyForDisplay = ^(SJVideoPlayerPresentView * _Nonnull view) {
        if ( asset.hasBeenGeneratedPreviewImages ) { return ; }
        if ( !_self.generatePreviewImages ) return;
        CGRect bounds = view.avLayer.videoRect;
        CGFloat width = [UIScreen mainScreen].bounds.size.width * 0.4;
        CGFloat height = width * bounds.size.height / bounds.size.width;
        CGSize size = CGSizeMake(width, height);
        [asset generatedPreviewImagesWithMaxItemSize:size completion:^(SJVideoPlayerAssetCarrier * _Nonnull asset, NSArray<SJVideoPreviewModel *> * _Nullable images, NSError * _Nullable error) {
            if ( error ) {
                _sjErrorLog(@"Generate Preview Image Failed!");
            }
            else {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( self.orentation.fullScreen ) {
                    _sjAnima(^{
                        _sjShowViews(@[self.controlView.topControlView.previewBtn]);
                    });
                }
                self.controlView.previewView.previewImages = images;
            }
        }];
    };
    
    asset.playerItemStateChanged = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, AVPlayerItemStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.state == SJVideoPlayerPlayState_PlayEnd ) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case AVPlayerItemStatusUnknown: break;
                case AVPlayerItemStatusFailed: {
                    [self _itemPlayFailed];
                }
                    break;
                case AVPlayerItemStatusReadyToPlay: {
                    [self performSelector:@selector(_itemReadyToPlay) withObject:nil afterDelay:1];
                }
                    break;
            }
        });

    };
    
    asset.playTimeChanged = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _refreshingTimeProgressSliderWithCurrentTime:currentTime duration:duration];
        [self _refreshingTimeLabelWithCurrentTime:currentTime duration:duration];
    };
    
    asset.playDidToEnd = ^(SJVideoPlayerAssetCarrier * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _itemPlayEnd];
    };
    
    asset.loadedTimeProgress = ^(float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.controlView.bottomControlView.progressSlider.bufferProgress = progress;
    };
    
    asset.beingBuffered = ^(BOOL state) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _buffering];
    };
}

- (SJVideoPlayerAssetCarrier *)asset {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setMoreSettings:(NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    objc_setAssociatedObject(self, @selector(moreSettings), moreSettings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSMutableSet<SJVideoPlayerMoreSetting *> *moreSettingsM = [NSMutableSet new];
    [moreSettings enumerateObjectsUsingBlock:^(SJVideoPlayerMoreSetting * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addSetting:obj container:moreSettingsM];
    }];
    
    [moreSettingsM enumerateObjectsUsingBlock:^(SJVideoPlayerMoreSetting * _Nonnull obj, BOOL * _Nonnull stop) {
        [self dressSetting:obj];
    }];
    self.moreSettingView.moreSettings = moreSettings;
}

- (void)addSetting:(SJVideoPlayerMoreSetting *)setting container:(NSMutableSet<SJVideoPlayerMoreSetting *> *)moreSttingsM {
    [moreSttingsM addObject:setting];
    if ( !setting.showTowSetting ) return;
    [setting.twoSettingItems enumerateObjectsUsingBlock:^(SJVideoPlayerMoreSettingSecondary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addSetting:(SJVideoPlayerMoreSetting *)obj container:moreSttingsM];
    }];
}

- (void)dressSetting:(SJVideoPlayerMoreSetting *)setting {
    if ( !setting.clickedExeBlock ) return;
    void(^clickedExeBlock)(SJVideoPlayerMoreSetting *model) = [setting.clickedExeBlock copy];
    __weak typeof(self) _self = self;
    if ( setting.isShowTowSetting ) {
        setting.clickedExeBlock = ^(SJVideoPlayerMoreSetting * _Nonnull model) {
            clickedExeBlock(model);
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.moreSecondarySettingView.twoLevelSettings = model;
            _sjAnima(^{
                self.hiddenMoreSettingView = YES;
                self.hiddenMoreSecondarySettingView = NO;
            });
        };
        return;
    }
    
    setting.clickedExeBlock = ^(SJVideoPlayerMoreSetting * _Nonnull model) {
        clickedExeBlock(model);
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        _sjAnima(^{
            self.hiddenMoreSettingView = YES;
            if ( !model.isShowTowSetting ) self.hiddenMoreSecondarySettingView = YES;
        });
    };
}

- (NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlaceholder:(UIImage *)placeholder {
    self.presentView.placeholderImageView.image = placeholder;
}

- (void)setScrollView:(UIScrollView *)scrollView indexPath:(NSIndexPath *)indexPath onViewTag:(NSInteger)tag {
    
}

- (void)setAutoplay:(BOOL)autoplay {
    objc_setAssociatedObject(self, @selector(isAutoplay), @(autoplay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isAutoplay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setGeneratePreviewImages:(BOOL)generatePreviewImages {
    objc_setAssociatedObject(self, @selector(generatePreviewImages), @(generatePreviewImages), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)generatePreviewImages {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setClickedBackEvent:(void (^)(SJVideoPlayer *player))clickedBackEvent {
    objc_setAssociatedObject(self, @selector(clickedBackEvent), clickedBackEvent, OBJC_ASSOCIATION_COPY);
}

- (void (^)(SJVideoPlayer * _Nonnull))clickedBackEvent {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDisableRotation:(BOOL)disableRotation {
    objc_setAssociatedObject(self, @selector(disableRotation), @(disableRotation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableRotation {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
} 

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    objc_setAssociatedObject(self, @selector(videoGravity), videoGravity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _presentView.videoGravity = videoGravity;
}

- (AVLayerVideoGravity)videoGravity {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)_cleanSetting {
    [self.asset cancelPreviewImagesGeneration];
    self.asset = nil;
}

@end





#pragma mark -

@implementation SJVideoPlayer (Control)

- (BOOL)play {
    if ( !self.asset ) return NO;
    self.userClickedPause = NO;
    _sjAnima(^{
        [self _playState];
    });
    [self _play];
    return YES;
}

- (BOOL)pause {
    if ( !self.asset ) return NO;
    self.userClickedPause = YES;
    _sjAnima(^{
        [self _pauseState];
    });
    [self _pause];
    [self showTitle:@"已暂停"];
    return YES;
}

- (void)stop {
    [self _pause];
    [self _cleanSetting];
    
    _sjAnima(^{
        [self _stopState];
    });
}

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    CMTime seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    [self seekToTime:seekTime completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    [self _startLoading];
    __weak typeof(self) _self = self;
    [self.asset.playerItem seekToTime:time completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _stopLoading];
        if ( completionHandler ) completionHandler(finished);
    }];
}

- (UIImage *)screenshot {
    return [self.asset screenshot];
}

@end


@implementation SJVideoPlayer (Prompt)

- (SJPrompt *)prompt {
    SJPrompt *prompt = objc_getAssociatedObject(self, _cmd);
    if ( prompt ) return prompt;
    prompt = [SJPrompt promptWithPresentView:self.presentView];
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
