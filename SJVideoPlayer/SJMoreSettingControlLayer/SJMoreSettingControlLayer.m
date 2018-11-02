
//
//  SJMoreSettingControlLayer.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/26.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJMoreSettingControlLayer.h"
#import "SJVideoPlayerMoreSettingsView.h"
#import "SJVideoPlayerMoreSettingSecondaryView.h"
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#else
#import "SJBaseVideoPlayer.h"
#endif
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#import "UIView+SJAnimationAdded.h"
#import "SJVideoPlayerAnimationHeader.h"
#import "SJMoreSettingsSlidersViewModel.h"
#import "SJVideoPlayerMoreSetting.h"
#import "SJVideoPlayerMoreSetting+Exe.h"
#import "SJEdgeControlLayerSettings.h"
#import "UIView+SJVideoPlayerSetting.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJMoreSettingControlLayer ()
@property (nonatomic, strong, readonly) SJMoreSettingsSlidersViewModel *footerViewModel;
@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingsView *moreSettingsView;
@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingSecondaryView *moreSecondarySettingView;
@property (nonatomic, weak, nullable) SJBaseVideoPlayer *videoPlayer;
@end

@implementation SJMoreSettingControlLayer
@synthesize moreSettingsView = _moreSettingsView;
@synthesize moreSecondarySettingView = _moreSecondarySettingView;
@synthesize footerViewModel = _footerViewModel;
@synthesize restarted = _restarted;

- (void)restartControlLayer {
    _restarted = YES;
    [_videoPlayer controlLayerNeedAppear];
    [self _show:self.controlView animated:YES];
}

- (void)exitControlLayer {
    _restarted= NO;
    /// clean
    _videoPlayer.controlLayerDataSource = nil;
    _videoPlayer.controlLayerDelegate = nil;
    _videoPlayer = nil;
    
    [self _hidden:_moreSettingsView animated:YES];
    [self _hidden:_moreSecondarySettingView animated:YES];
    [self _hidden:self.controlView animated:YES completionHandler:^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    }];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)setMoreSettings:(NSArray<SJVideoPlayerMoreSetting *> *_Nullable)moreSettings {
    _moreSettingsView.moreSettings = moreSettings;
    
    NSMutableSet<SJVideoPlayerMoreSetting *> *moreSettingsM = [NSMutableSet new];
    [moreSettings enumerateObjectsUsingBlock:^(SJVideoPlayerMoreSetting * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _addSetting:obj container:moreSettingsM];
    }];
    [moreSettingsM enumerateObjectsUsingBlock:^(SJVideoPlayerMoreSetting * _Nonnull obj, BOOL * _Nonnull stop) {
        [self _dressSetting:obj];
    }];
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
    __weak typeof(self) _self = self;
    if ( setting.isShowTowSetting ) {
        setting._exeBlock = ^(SJVideoPlayerMoreSetting * _Nonnull setting) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _hidden:self.moreSettingsView animated:YES];
            [self _show:self.moreSecondarySettingView animated:YES];
            self.moreSecondarySettingView.twoLevelSettings = setting;
            setting.clickedExeBlock(setting);
        };
    }
    else {
        setting._exeBlock = ^(SJVideoPlayerMoreSetting * _Nonnull setting) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            setting.clickedExeBlock(setting);
            if ( self.disappearExeBlock ) self.disappearExeBlock(self);
        };
    }
}

- (NSArray<SJVideoPlayerMoreSetting *> *_Nullable)moreSettings {
    return _moreSettingsView.moreSettings;
}

- (void)_setupView {
    [self.controlView addSubview:self.moreSettingsView];
    [_moreSettingsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.offset(0);
    }];
}

- (SJVideoPlayerMoreSettingsView *)moreSettingsView {
    if ( _moreSettingsView ) return _moreSettingsView;
    _moreSettingsView = [SJVideoPlayerMoreSettingsView new];
    _moreSettingsView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
    _moreSettingsView.sjv_doNotSetAlpha = YES;
    _moreSettingsView.footerViewModel = self.footerViewModel;
    
    __weak typeof(self) _self = self;
    _moreSettingsView.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.moreSettingsView.backgroundColor = setting.moreBackgroundColor;
    }];
    self.moreSettingsView.backgroundColor = SJEdgeControlLayerSettings.commonSettings.moreBackgroundColor;
    return _moreSettingsView;
}

- (SJMoreSettingsSlidersViewModel *)footerViewModel {
    if ( _footerViewModel ) return _footerViewModel;
    _footerViewModel = [SJMoreSettingsSlidersViewModel new];
    
    __weak typeof(self) _self = self;
    _footerViewModel.initialBrightnessValue = ^float{
        __strong typeof(_self) self = _self;
        if ( !self ) return 0;
        return self.videoPlayer.brightness;
    };
    
    _footerViewModel.initialVolumeValue = ^float{
        __strong typeof(_self) self = _self;
        if ( !self ) return 0;
        return self.videoPlayer.volume;
    };
    
    _footerViewModel.initialPlayerRateValue = ^float{
        __strong typeof(_self) self = _self;
        if ( !self ) return 1;
        return self.videoPlayer.rate;
    };
    
    _footerViewModel.needChangeVolume = ^(float volume) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.videoPlayer.volume = volume;
    };
    
    _footerViewModel.needChangeBrightness = ^(float brightness) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.videoPlayer.brightness = brightness;
    };
    
    _footerViewModel.needChangePlayerRate = ^(float rate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.videoPlayer.rate = rate;
    };
    return _footerViewModel;
}

- (SJVideoPlayerMoreSettingSecondaryView *)moreSecondarySettingView {
    if ( _moreSecondarySettingView ) return _moreSecondarySettingView;
    _moreSecondarySettingView = [SJVideoPlayerMoreSettingSecondaryView new];
    _moreSecondarySettingView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
    [self addSubview:_moreSecondarySettingView];
    [_moreSecondarySettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.offset(0);
    }];
    __weak typeof(self) _self = self;
    _moreSecondarySettingView.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.moreSecondarySettingView.backgroundColor = setting.moreBackgroundColor;
    }];
    self.moreSecondarySettingView.backgroundColor = SJEdgeControlLayerSettings.commonSettings.moreBackgroundColor;
    [self.controlView layoutIfNeeded];
    [self _hidden:_moreSecondarySettingView animated:NO];
    return _moreSecondarySettingView;
}

#pragma mark - player delegate method
- (UIView *)controlView {
    return self;
}

- (BOOL)triggerGesturesCondition:(CGPoint)location {
    if ( CGRectContainsPoint( _moreSettingsView.frame, location) ||
         CGRectContainsPoint( _moreSecondarySettingView.frame, location) ) return NO;
    return YES;
}

/// 禁止自动隐藏
- (BOOL)controlLayerDisappearCondition {
    return NO;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _videoPlayer = videoPlayer;
    [self.controlView layoutIfNeeded];
    [self _hidden:_moreSettingsView animated:NO];
    [self _hidden:_moreSecondarySettingView animated:NO];
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _show:_moreSettingsView animated:YES];
    [UIView animateWithDuration:0.25 animations:^{
        [videoPlayer needHiddenStatusBar];
    }];
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( _disappearExeBlock ) _disappearExeBlock(self);
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull {
    if ( _disappearExeBlock ) _disappearExeBlock(self);
}

/// 声音被改变.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer volumeChanged:(float)volume {
    if ( _footerViewModel.volumeChanged ) _footerViewModel.volumeChanged(volume);
}

/// 亮度被改变.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer brightnessChanged:(float)brightness {
    if ( _footerViewModel.brightnessChanged ) _footerViewModel.brightnessChanged(brightness);
}

/// 播放速度被改变.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer rateChanged:(float)rate {
    [videoPlayer showTitle:[NSString stringWithFormat:@"%.0f %%", rate * 100]];
    if ( _footerViewModel.playerRateChanged ) _footerViewModel.playerRateChanged(rate);
}

#pragma mark -
- (BOOL)_isHiddenWithView:(UIView *)view {
    return view.sjv_disappeared;
}

- (void)_show:(UIView *)view animated:(BOOL)animated {
    [self _show:view animated:animated completionHandler:nil];
}

- (void)_hidden:(UIView *)view animated:(BOOL)animated {
    [self _hidden:view animated:animated completionHandler:nil];
}

- (void)_show:(UIView *)view animated:(BOOL)animated completionHandler:(void(^_Nullable)(void))completionHandler {
    if ( !view.sjv_disappeared ) return;
    if ( animated ) {
        UIView_Animations(CommonAnimaDuration, ^{
            [view sjv_appear];
        }, completionHandler);
    }
    else [view sjv_appear];
}

- (void)_hidden:(UIView *)view animated:(BOOL)animated completionHandler:(void(^_Nullable)(void))completionHandler {
    if ( view.sjv_disappeared ) return;
    if ( animated ) {
        UIView_Animations(CommonAnimaDuration, ^{
            [view sjv_disapear];
        }, completionHandler);
    }
    else [view sjv_disapear];
}
@end
NS_ASSUME_NONNULL_END
