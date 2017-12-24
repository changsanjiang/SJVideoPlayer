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
#import <SJOrentationObserver/SJOrentationObserver.h>
#import "SJVideoPlayerRegistrar.h"
#import "SJVolBrigControl.h"
#import "SJTimerControl.h"
#import "SJVideoPlayerView.h"
#import <SJLoadingView/SJLoadingView.h>
#import "SJPlayerGestureControl.h"

#define MoreSettingWidth (MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) * 0.382)

inline static void _sjErrorLog(id msg) {
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
@property (nonatomic, strong, readonly) SJVolBrigControl *volBrigControl;
@property (nonatomic, strong, readonly) SJPlayerGestureControl *gestureControl;
@property (nonatomic, strong, readonly) SJLoadingView *loadingView;


@property (nonatomic, assign, readwrite) SJVideoPlayerPlayState state;
@property (nonatomic, assign, readwrite) BOOL hiddenMoreSettingView;
@property (nonatomic, assign, readwrite) BOOL hiddenMoreSecondarySettingView;
@property (nonatomic, assign, readwrite) BOOL hiddenLeftControlView;
@property (nonatomic, assign, readwrite) BOOL userClickedPause;
@property (nonatomic, assign, readwrite) BOOL playOnCell;
@property (nonatomic, assign, readwrite) BOOL scrollIn;
@property (nonatomic, strong, readwrite) NSError *error;

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

- (void)_playEndState;

- (void)_playFailedState;

- (void)_unknownState;

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
        if ( self.state == SJVideoPlayerPlayState_Pause ) return;
        _sjAnima(^{
            self.hideControl = YES;
        });
    }];
}

- (void)setLockScreen:(BOOL)lockScreen {
    if ( self.isLockedScrren == lockScreen ) return;
    objc_setAssociatedObject(self, @selector(isLockedScrren), @(lockScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _cancelDelayHiddenControl];
    _sjAnima(^{
        if ( lockScreen ) {
            [self _lockScreenState];
        }
        else {
            [self _unlockScreenState];
        }
    });
}

- (BOOL)isLockedScrren {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setHideControl:(BOOL)hideControl {
//    if ( self.isHiddenControl == hideControl ) return;
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

- (void)_unknownState {
    // show
    _sjShowViews(@[self.presentView.placeholderImageView,]);
    
    // hidden
    _sjHiddenViews(@[self.controlView]);
    
    self.state = SJVideoPlayerPlayState_Unknown;
}

- (void)_prepareState {
    // show
    _sjShowViews(@[self.controlView,
                   self.presentView.placeholderImageView]);
    
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
    self.hideControl = YES;
}

- (void)_unlockScreenState {
    
    // show
    _sjShowViews(@[self.controlView.leftControlView.unlockBtn]);
    self.hideControl = NO;
    
    // hidden
    _sjHiddenViews(@[self.controlView.leftControlView.lockBtn]);
    
}

- (void)_hideControlState {

    // show
    _sjShowViews(@[self.controlView.bottomProgressSlider]);
    
    // hidden
    self.controlView.previewView.hidden = YES;
    
    // transform hidden
    self.controlView.topControlView.transform = CGAffineTransformMakeTranslation(0, -SJControlTopH);
    self.controlView.bottomControlView.transform = CGAffineTransformMakeTranslation(0, SJControlBottomH);

    if ( self.orentation.fullScreen ) {
        if ( self.isLockedScrren ) self.hiddenLeftControlView = NO;
        else self.hiddenLeftControlView = YES;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ( self.orentation.fullScreen ) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
    }
#pragma clang diagnostic pop
}

- (void)_showControlState {
    
    // hidden
    _sjHiddenViews(@[self.controlView.bottomProgressSlider]);
    self.controlView.previewView.hidden = YES;
    
    // transform show
    if ( self.playOnCell && !self.orentation.fullScreen ) {
        self.controlView.topControlView.transform = CGAffineTransformMakeTranslation(0, -SJControlTopH);
    }
    else {
        self.controlView.topControlView.transform = CGAffineTransformIdentity;
    }
    self.controlView.bottomControlView.transform = CGAffineTransformIdentity;
    
    self.hiddenLeftControlView = !self.orentation.fullScreen;
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
#pragma clang diagnostic pop
}

@end


#pragma mark - SJVideoPlayer
#import "SJMoreSettingsFooterViewModel.h"

@implementation SJVideoPlayer {
    SJVideoPlayerPresentView *_presentView;
    SJVideoPlayerControlView *_controlView;
    SJVideoPlayerMoreSettingsView *_moreSettingView;
    SJVideoPlayerMoreSettingSecondaryView *_moreSecondarySettingView;
    SJOrentationObserver *_orentation;
    SJVideoPlayerView *_view;
    SJMoreSettingsFooterViewModel *_moreSettingFooterViewModel;
    SJVideoPlayerRegistrar *_registrar;
    SJVolBrigControl *_volBrigControl;
    SJLoadingView *_loadingView;
    SJPlayerGestureControl *_gestureControl;
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
    [self settingPlayer:^(SJVideoPlayerSettings * _Nonnull settings) {
        [self resetSetting];
    }];
    [self registrar];
    
    // default values
    self.autoplay = YES;
    self.generatePreviewImages = YES;
    
    [self _unknownState];
    
    return self;
}

- (SJVideoPlayerPresentView *)presentView {
    if ( _presentView ) return _presentView;
    _presentView = [SJVideoPlayerPresentView new];
    _presentView.clipsToBounds = YES;
    __weak typeof(self) _self = self;
    _presentView.readyForDisplay = ^(SJVideoPlayerPresentView * _Nonnull view) {
        if ( _self.asset.hasBeenGeneratedPreviewImages ) { return ; }
        if ( !_self.generatePreviewImages ) return;
        CGRect bounds = view.avLayer.videoRect;
        CGFloat width = [UIScreen mainScreen].bounds.size.width * 0.4;
        CGFloat height = width * bounds.size.height / bounds.size.width;
        CGSize size = CGSizeMake(width, height);
        [_self.asset generatedPreviewImagesWithMaxItemSize:size completion:^(SJVideoPlayerAssetCarrier * _Nonnull asset, NSArray<SJVideoPreviewModel *> * _Nullable images, NSError * _Nullable error) {
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
    return _presentView;
}

- (SJVideoPlayerControlView *)controlView {
    if ( _controlView ) return _controlView;
    _controlView = [SJVideoPlayerControlView new];
    _controlView.clipsToBounds = YES;
    return _controlView;
}

- (UIView *)view {
    if ( _view ) return _view;
    _view = [SJVideoPlayerView new];
    _view.backgroundColor = [UIColor blackColor];
    [_view addSubview:self.presentView];
    [_presentView addSubview:self.controlView];
    [_controlView addSubview:self.moreSettingView];
    [_controlView addSubview:self.moreSecondarySettingView];
    [self gesturesHandleWithTargetView:_controlView];
    self.hiddenMoreSettingView = YES;
    self.hiddenMoreSecondarySettingView = YES;
    _controlView.delegate = self;
    _controlView.bottomControlView.progressSlider.delegate = self;
    
    [_presentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_presentView.superview);
    }];
    
    [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_controlView.superview);
    }];
    
    [_moreSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.offset(0);
        make.width.offset(MoreSettingWidth);
    }];
    
    [_moreSecondarySettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_moreSettingView);
    }];
    
    _loadingView = [SJLoadingView new];
    [_controlView addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];

    __weak typeof(self) _self = self;
    _view.setting = ^(SJVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.loadingView.lineColor = setting.loadingLineColor;
    };
    
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
        self.volBrigControl.brightness = brightness;
    };
    
    _moreSettingFooterViewModel.needChangePlayerRate = ^(float rate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !self.asset ) return;
        self.rate = rate;
        if ( self.internallyChangedRate ) self.internallyChangedRate(self, rate);
    };
    
    _moreSettingFooterViewModel.needChangeVolume = ^(float volume) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.volBrigControl.volume = volume;
    };
    
    _moreSettingFooterViewModel.initialVolumeValue = ^float{
        __strong typeof(_self) self = _self;
        if ( !self ) return 0;
        return self.volBrigControl.volume;
    };
    
    _moreSettingFooterViewModel.initialBrightnessValue = ^float{
        __strong typeof(_self) self = _self;
        if ( !self ) return 0;
        return self.volBrigControl.brightness;
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
        self.controlView.leftControlView.transform = CGAffineTransformMakeTranslation(-SJControlLeftH, 0);
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
        self.hideControl = NO;
        _sjAnima(^{
            self.controlView.previewView.hidden = YES;
            self.hiddenMoreSecondarySettingView = YES;
            self.hiddenMoreSettingView = YES;
            self.hiddenLeftControlView = !observer.isFullScreen;
            if ( observer.isFullScreen ) {
                _sjShowViews(@[self.controlView.topControlView.moreBtn,]);
                if ( self.asset.hasBeenGeneratedPreviewImages ) {
                    _sjShowViews(@[self.controlView.topControlView.previewBtn]);
                }
                
                [self.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.center.offset(0);
                    make.height.equalTo(self.controlView.superview);
                    make.width.equalTo(self.controlView.mas_height).multipliedBy(16.0 / 9.0);
                }];
            }
            else {
                _sjHiddenViews(@[self.controlView.topControlView.moreBtn,
                                 self.controlView.topControlView.previewBtn,]);
                
                [self.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.controlView.superview);
                }];
            }
        });
        if ( self.rotatedScreen ) self.rotatedScreen(self, observer.isFullScreen);
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
        if ( self.playOnCell && !self.scrollIn ) return NO;
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
        self.lockScreen = YES;
        [self _pause];
    };
    
    _registrar.didBecomeActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.lockScreen = NO;
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

- (SJVolBrigControl *)volBrig {
    if ( _volBrigControl ) return _volBrigControl;
    _volBrigControl  = [SJVolBrigControl new];
    __weak typeof(self) _self = self;
    _volBrigControl.volumeChanged = ^(float volume) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.moreSettingFooterViewModel.volumeChanged ) self.moreSettingFooterViewModel.volumeChanged(volume);
    };
    
    _volBrigControl.brightnessChanged = ^(float brightness) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.moreSettingFooterViewModel.brightnessChanged ) self.moreSettingFooterViewModel.brightnessChanged(self.volBrigControl.brightness);
    };
    
    return _volBrigControl;
}

- (void)gesturesHandleWithTargetView:(UIView *)targetView {
    
    _gestureControl = [[SJPlayerGestureControl alloc] initWithTargetView:targetView];

    __weak typeof(self) _self = self;
    _gestureControl.triggerCondition = ^BOOL(SJPlayerGestureControl * _Nonnull control, UIGestureRecognizer *gesture) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        if ( self.isLockedScrren ) return NO;
        CGPoint point = [gesture locationInView:gesture.view];
        if ( CGRectContainsPoint(self.moreSettingView.frame, point) ||
             CGRectContainsPoint(self.moreSecondarySettingView.frame, point) ||
             CGRectContainsPoint(self.controlView.previewView.frame, point) ) {
            return NO;
        }
        if ( [gesture isKindOfClass:[UIPanGestureRecognizer class]] &&
             self.playOnCell &&
            !self.orentation.fullScreen ) return NO;
        else return YES;
    };
    
    _gestureControl.singleTapped = ^(SJPlayerGestureControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
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
    };
    
    _gestureControl.doubleTapped = ^(SJPlayerGestureControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch (self.state) {
            case SJVideoPlayerPlayState_Unknown:
            case SJVideoPlayerPlayState_Prepare:
                break;
            case SJVideoPlayerPlayState_Buffing:
            case SJVideoPlayerPlayState_Playing: {
                [self pause];
                self.userClickedPause = YES;
            }
                break;
            case SJVideoPlayerPlayState_Pause:
            case SJVideoPlayerPlayState_PlayEnd: {
                [self play];
                self.userClickedPause = NO;
            }
                break;
            case SJVideoPlayerPlayState_PlayFailed:
                break;
        }
    };
    
    static __weak UIView *target = nil;
    _gestureControl.beganPan = ^(SJPlayerGestureControl * _Nonnull control, SJPanDirection direction, SJPanLocation location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch (direction) {
            case SJPanDirection_H: {
                [self _pause];
                _sjAnima(^{
                    _sjShowViews(@[self.controlView.draggingProgressView]);
                });
                self.controlView.draggingProgressView.progressSlider.value = self.asset.progress;
                self.controlView.draggingProgressView.progressLabel.text = _formatWithSec(self.asset.currentTime);
                self.hideControl = YES;
            }
                break;
            case SJPanDirection_V: {
                switch (location) {
                    case SJPanLocation_Right: break;
                    case SJPanLocation_Left: {
                        [[UIApplication sharedApplication].keyWindow addSubview:self.volBrigControl.brightnessView];
                        [self.volBrigControl.brightnessView mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.size.mas_offset(CGSizeMake(155, 155));
                            make.center.equalTo([UIApplication sharedApplication].keyWindow);
                        }];
                        self.volBrigControl.brightnessView.transform = self.controlView.superview.transform;
                        _sjAnima(^{
                            _sjShowViews(@[self.volBrigControl.brightnessView]);
                        });
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
                self.controlView.draggingProgressView.progressSlider.value += translate.x * 0.003;
                self.controlView.draggingProgressView.progressLabel.text =  _formatWithSec(self.asset.duration * self.controlView.draggingProgressView.progressSlider.value);
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
                        CGFloat value = translate.y * 0.015;
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
        switch ( direction ) {
            case SJPanDirection_H:{
                _sjAnima(^{
                    _sjHiddenViews(@[_self.controlView.draggingProgressView]);
                });
                [_self jumpedToTime:_self.controlView.draggingProgressView.progressSlider.value * _self.asset.duration completionHandler:^(BOOL finished) {
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    [self play];
                }];
            }
                break;
            case SJPanDirection_V:{
                if ( location == SJPanLocation_Left ) {
                    _sjAnima(^{
                        __strong typeof(_self) self = _self;
                        if ( !self ) return;
                        _sjHiddenViews(@[self.volBrigControl.brightnessView]);
                    });
                }
            }
                break;
            case SJPanDirection_Unknown: break;
        }
        target = nil;
    };
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
            self.userClickedPause = NO;
        }
            break;
        case SJVideoPlayControlViewTag_Pause: {
            [self pause];
            self.userClickedPause = YES;
        }
            break;
        case SJVideoPlayControlViewTag_Replay: {
            _sjAnima(^{
                if ( !self.isLockedScrren ) self.hideControl = NO;
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
            self.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:self.asset.assetURL beginTime:self.asset.beginTime scrollView:self.asset.scrollView indexPath:self.asset.indexPath superviewTag:self.asset.superviewTag];
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
    self.hideControl = YES;
    self.userClickedPause = NO;
    self.hiddenMoreSettingView = YES;
    self.hiddenMoreSecondarySettingView = YES;
    self.controlView.bottomProgressSlider.value = 0;
    self.controlView.bottomProgressSlider.bufferProgress = 0;
    self.rate = 1;
    if ( self.moreSettingFooterViewModel.volumeChanged ) {
        self.moreSettingFooterViewModel.volumeChanged(self.volBrigControl.volume);
    }
    if ( self.moreSettingFooterViewModel.brightnessChanged ) {
        self.moreSettingFooterViewModel.brightnessChanged(self.volBrigControl.brightness);
    }
    [self _prepareState];
}

- (void)_itemPlayFailed {
    [self _stopLoading];
    [self _playFailedState];
    self.error = self.asset.playerItem.error;
    _sjErrorLog(self.error);
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
}

- (void)_pause {
    [self.asset.player pause];
}

- (void)_startLoading {
    if ( _loadingView.isAnimating ) return;
    [_loadingView start];
}

- (void)_stopLoading {
    if ( !_loadingView.isAnimating ) return;
    [_loadingView stop];
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

- (void)playWithURL:(NSURL *)playURL {
    [self playWithURL:playURL jumpedToTime:0];
}

// unit: sec.
- (void)playWithURL:(NSURL *)playURL jumpedToTime:(NSTimeInterval)time {
    self.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:playURL beginTime:time];
}

- (void)setAssetURL:(NSURL *)assetURL {
    [self playWithURL:assetURL jumpedToTime:0];
}

- (NSURL *)assetURL {
    return self.asset.assetURL;
}

- (void)setAsset:(SJVideoPlayerAssetCarrier *)asset {
    [self stop];
    objc_setAssociatedObject(self, @selector(asset), asset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( !asset ) return;
    _presentView.asset = asset;
    _controlView.asset = asset;
    
    [self _itemPrepareToPlay];
    
    __weak typeof(self) _self = self;
    
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
    
    asset.deallocCallBlock = ^(SJVideoPlayerAssetCarrier * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.view.alpha = 1;
    };
    
    if ( asset.indexPath ) {
        self.playOnCell = YES;
        self.scrollIn = YES;
    }
    else {
        self.playOnCell = NO;
        self.scrollIn = NO;
    }
    
    asset.scrollViewDidScroll = ^(SJVideoPlayerAssetCarrier * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [asset.scrollView isKindOfClass:[UITableView class]] ) {
            UITableView *tableView = (UITableView *)asset.scrollView;
            __block BOOL visable = NO;
            [tableView.indexPathsForVisibleRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ( [obj compare:self.asset.indexPath] == NSOrderedSame ) {
                    visable = YES;
                    *stop = YES;
                }
            }];
            if ( visable ) {
                if ( YES == self.scrollIn ) return;
                /// 滑入时
                self.scrollIn = YES;
                self.view.alpha = 1;
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.asset.indexPath];
                UIView *superview = [cell.contentView viewWithTag:self.asset.superviewTag];
                if ( superview && self.view.superview != superview ) {
                    [self.view removeFromSuperview];
                    [superview addSubview:self.view];
                    [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.edges.equalTo(self.view.superview);
                    }];
                }
            }
            else {
                if ( NO == self.scrollIn ) return;
                /// 滑出时
                self.scrollIn = NO;
                self.view.alpha = 0.001;
                [self pause];
                self.hideControl = NO;
            }
        }
        else if ( [asset.scrollView isKindOfClass:[UICollectionView class]] ) {
            UICollectionView *collectionView = (UICollectionView *)asset.scrollView;
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.asset.indexPath];
            if ( [collectionView.visibleCells containsObject:cell] ) {
                if ( YES == self.scrollIn ) return;
                /// 滑入时
                self.scrollIn = YES;
                self.view.alpha = 1;
                [self.view removeFromSuperview];
                UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.asset.indexPath];
                UIView *superview = [cell.contentView viewWithTag:self.asset.superviewTag];
                if ( superview && self.view.superview != superview ) {
                    [self.view removeFromSuperview];
                    [superview addSubview:self.view];
                    [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.edges.equalTo(self.view.superview);
                    }];
                }
            }
            else {
                if ( NO == self.scrollIn ) return;
                /// 滑出时
                self.scrollIn = NO;
                self.view.alpha = 0.001;
                [self pause];
                self.hideControl = NO;
            }
        }
    };
}

//static __weak UIView *tmpView = nil;
//- (UIView *)_getSuperviewWithContentView:(UIView *)contentView tag:(NSInteger)tag {
//    if ( contentView.tag == tag ) return contentView;
//    
//    [self _searchingWithView:contentView tag:tag];
//    UIView *target = tmpView;
//    tmpView = nil;
//    return target;
//}
//
//- (void)_searchingWithView:(UIView *)view tag:(NSInteger)tag {
//    if ( tmpView ) return;
//    [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ( obj.tag == tag ) {
//            *stop = YES;
//            tmpView = obj;
//        }
//        else {
//            [self _searchingWithView:obj tag:tag];
//        }
//    }];
//    return;
//}

- (SJVideoPlayerAssetCarrier *)asset {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)_clearAsset {
    if ( self.generatePreviewImages && !self.asset.hasBeenGeneratedPreviewImages ) [self.asset cancelPreviewImagesGeneration];
    objc_setAssociatedObject(self, @selector(asset), nil, OBJC_ASSOCIATION_ASSIGN);
}

- (void)setMoreSettings:(NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    objc_setAssociatedObject(self, @selector(moreSettings), moreSettings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSMutableSet<SJVideoPlayerMoreSetting *> *moreSettingsM = [NSMutableSet new];
    [moreSettings enumerateObjectsUsingBlock:^(SJVideoPlayerMoreSetting * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _addSetting:obj container:moreSettingsM];
    }];
    
    [moreSettingsM enumerateObjectsUsingBlock:^(SJVideoPlayerMoreSetting * _Nonnull obj, BOOL * _Nonnull stop) {
        [self _dressSetting:obj];
    }];
    self.moreSettingView.moreSettings = moreSettings;
}

- (void)_addSetting:(SJVideoPlayerMoreSetting *)setting container:(NSMutableSet<SJVideoPlayerMoreSetting *> *)moreSttingsM {
    [moreSttingsM addObject:setting];
    if ( !setting.showTowSetting ) return;
    [setting.twoSettingItems enumerateObjectsUsingBlock:^(SJVideoPlayerMoreSettingSecondary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _addSetting:(SJVideoPlayerMoreSetting *)obj container:moreSttingsM];
    }];
}

- (void)_dressSetting:(SJVideoPlayerMoreSetting *)setting {
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

- (void)settingPlayer:(void (^)(SJVideoPlayerSettings * _Nonnull))block {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if ( block ) block([self settings]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SJSettingsPlayerNotification object:[self settings]];
        });
    });
}

- (SJVideoPlayerSettings *)settings {
    SJVideoPlayerSettings *setting = objc_getAssociatedObject(self, _cmd);
    if ( setting ) return setting;
    setting = [SJVideoPlayerSettings new];
    objc_setAssociatedObject(self, _cmd, setting, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return setting;
}

- (void)resetSetting {
    SJVideoPlayerSettings *setting = self.settings;
    setting.backBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_back"];
    setting.moreBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_more"];
    setting.previewBtnImage = [SJVideoPlayerResources imageNamed:@""];
    setting.playBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_play"];
    setting.pauseBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_pause"];
    setting.fullBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_fullscreen"];
    setting.lockBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_lock"];
    setting.unlockBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_unlock"];
    setting.replayBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_replay"];
    setting.replayBtnTitle = @"重播";
    setting.progress_traceColor = [UIColor orangeColor];
    setting.progress_bufferColor = [UIColor colorWithWhite:0 alpha:0.2];
    setting.progress_trackColor =  [UIColor whiteColor];
    setting.progress_traceHeight = 3;
    setting.more_traceColor = [UIColor greenColor];
    setting.more_trackColor = [UIColor whiteColor];
    setting.more_traceHeight = 5;
    setting.loadingLineColor = [UIColor whiteColor];
}

- (void)setPlaceholder:(UIImage *)placeholder {
    self.presentView.placeholderImageView.image = placeholder;
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
    objc_setAssociatedObject(self, @selector(clickedBackEvent), clickedBackEvent, OBJC_ASSOCIATION_COPY_NONATOMIC);
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

- (void)setRotatedScreen:(void (^)(SJVideoPlayer * _Nonnull, BOOL))rotatedScreen {
    objc_setAssociatedObject(self, @selector(rotatedScreen), rotatedScreen, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(SJVideoPlayer * _Nonnull, BOOL))rotatedScreen {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    objc_setAssociatedObject(self, @selector(videoGravity), videoGravity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _presentView.videoGravity = videoGravity;
}

- (AVLayerVideoGravity)videoGravity {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRate:(float)rate {
    if ( self.rate == rate ) return;
    objc_setAssociatedObject(self, @selector(rate), @(rate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.asset.player.rate = rate;
    self.userClickedPause = NO;
    _sjAnima(^{
        [self _playState];
    });
    if ( self.moreSettingFooterViewModel.playerRateChanged )
        self.moreSettingFooterViewModel.playerRateChanged(rate);
    if ( self.rateChanged ) self.rateChanged(self);
}

- (float)rate {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setRateChanged:(void (^)(SJVideoPlayer * _Nonnull))rateChanged {
    objc_setAssociatedObject(self, @selector(rateChanged), rateChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(SJVideoPlayer * _Nonnull))rateChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setInternallyChangedRate:(void (^)(SJVideoPlayer * _Nonnull, float))internallyChangedRate {
    objc_setAssociatedObject(self, @selector(internallyChangedRate), internallyChangedRate, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(SJVideoPlayer * _Nonnull, float))internallyChangedRate {
    return objc_getAssociatedObject(self, _cmd);
}

@end





#pragma mark -

@implementation SJVideoPlayer (Control)

- (BOOL)userPaused {
    return self.userClickedPause;
}

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
    _sjAnima(^{
        [self _pauseState];
    });
    [self _pause];
    if ( !self.playOnCell || self.orentation.fullScreen ) [self showTitle:@"已暂停"];
    return YES;
}

- (void)stop {
    _sjAnima(^{
        [self _unknownState];
    });
    if ( !self.asset ) return;
    [self _pause];
    [self _clearAsset];
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

- (NSTimeInterval)currentTime {
    return self.asset.currentTime;
}

- (void)stopRotation {
    self.disableRotation = YES;
}

- (void)enableRotation {
    self.disableRotation = NO;
}

@end


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
