//
//  SJVideoPlayerDefaultControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/6.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerDefaultControlView.h"
#import "SJVideoPlayerBottomControlView.h"
#import <Masonry/Masonry.h>
#import "SJVideoPlayer.h"
#import <SJObserverHelper/NSObject+SJObserverHelper.h>
#import "SJVideoPlayerSettings.h"
#import "SJVideoPlayerDraggingProgressView.h"
#import "UIView+SJVideoPlayerSetting.h"
#import <SJSlider/SJSlider.h>
#import "SJVideoPlayerLeftControlView.h"
#import "SJVideoPlayerTopControlView.h"
#import "SJVideoPlayerPreviewView.h"
#import "SJVideoPlayerMoreSettingsView.h"
#import "SJVideoPlayerMoreSettingSecondaryView.h"
#import "SJMoreSettingsSlidersViewModel.h"
#import "SJVideoPlayerMoreSetting+Exe.h"
#import "SJVideoPlayerMoreSettingSecondary.h"
#import "SJVideoPlayerCenterControlView.h"
#import <SJLoadingView/SJLoadingView.h>
#import <objc/message.h>
#import "UIView+SJControlAdd.h"


#pragma mark -

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerDefaultControlView ()<SJVideoPlayerLeftControlViewDelegate, SJVideoPlayerBottomControlViewDelegate, SJVideoPlayerTopControlViewDelegate, SJVideoPlayerPreviewViewDelegate, SJVideoPlayerCenterControlViewDelegate>

@property (nonatomic, assign) BOOL hasBeenGeneratedPreviewImages;
@property (nonatomic, strong, readonly) SJMoreSettingsSlidersViewModel *footerViewModel;

@property (nonatomic, strong, readonly) SJVideoPlayerPreviewView *previewView;
@property (nonatomic, strong, readonly) SJVideoPlayerDraggingProgressView *draggingProgressView;
@property (nonatomic, strong, readonly) SJVideoPlayerTopControlView *topControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerLeftControlView *leftControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerCenterControlView *centerControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerBottomControlView *bottomControlView;
@property (nonatomic, strong, readonly) SJSlider *bottomSlider;
@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingsView *moreSettingsView;
@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingSecondaryView *moreSecondarySettingView;
@property (nonatomic, strong, readonly) SJLoadingView *loadingView;

@property (nonatomic, weak, readwrite, nullable) SJVideoPlayer *videoPlayer;

@end
NS_ASSUME_NONNULL_END

@implementation SJVideoPlayerDefaultControlView {
    BOOL _controlLayerAppearedState;
}

@synthesize previewView = _previewView;
@synthesize draggingProgressView = _draggingProgressView;
@synthesize topControlView = _topControlView;
@synthesize leftControlView = _leftControlView;
@synthesize centerControlView = _centerControlView;
@synthesize bottomControlView = _bottomControlView;
@synthesize bottomSlider = _bottomSlider;
@synthesize moreSettingsView = _moreSettingsView;
@synthesize moreSecondarySettingView = _moreSecondarySettingView;
@synthesize footerViewModel = _footerViewModel;
@synthesize loadingView = _loadingView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _controlViewSetupView];
    [self _controlViewLoadSetting];
    // default values
    _generatePreviewImages = YES;
    return self;
}

- (void)dealloc {
#ifndef DEBUG
    NSLog(@"%zd - %s", __LINE__, __func__);
#endif
}

#pragma mark - setup views
- (void)_controlViewSetupView {
    
    [self addSubview:self.topControlView];
    [self addSubview:self.leftControlView];
    [self addSubview:self.centerControlView];
    [self addSubview:self.bottomControlView];
    [self addSubview:self.draggingProgressView];
    [self addSubview:self.bottomSlider];
    [self addSubview:self.previewView];
    [self addSubview:self.moreSettingsView];
    [self addSubview:self.moreSecondarySettingView];
    [self addSubview:self.loadingView];
    
    [_topControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
    }];
    
    [_leftControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(0);
        make.centerY.offset(0);
    }];
    
    [_centerControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [_bottomControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
    }];
    
    [_draggingProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [_bottomSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.offset(1);
    }];
    
    [_previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topControlView.mas_bottom);
        make.leading.trailing.offset(0);
    }];
    
    [_moreSettingsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.offset(0);
        make.size.mas_offset(_moreSettingsView.intrinsicContentSize);
    }];
    
    [_moreSecondarySettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_moreSettingsView);
    }];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];

    [self _setControlViewsDisappearType];
    [self _setControlViewsDisappearValue];
    
    [_bottomSlider disappear];
    [_draggingProgressView disappear];
    [_topControlView disappear];
    [_leftControlView disappear];
    [_centerControlView disappear];
    [_bottomControlView disappear];
    [_previewView disappear];
    [_moreSettingsView disappear];
    [_moreSecondarySettingView disappear];
}

- (void)_setControlViewsDisappearType {
    _topControlView.disappearType = SJDisappearType_Transform;
    _leftControlView.disappearType = SJDisappearType_Transform;
    _centerControlView.disappearType = SJDisappearType_Alpha;
    _bottomControlView.disappearType = SJDisappearType_Transform;
    _bottomSlider.disappearType = SJDisappearType_Alpha;
    _previewView.disappearType = SJDisappearType_All;
    _moreSettingsView.disappearType = SJDisappearType_Transform;
    _moreSecondarySettingView.disappearType = SJDisappearType_Transform;
    _draggingProgressView.disappearType = SJDisappearType_Alpha;
}

- (void)_setControlViewsDisappearValue {
    _topControlView.disappearTransform = CGAffineTransformMakeTranslation(0, -_topControlView.intrinsicContentSize.height);
    _leftControlView.disappearTransform = CGAffineTransformMakeTranslation(-_leftControlView.intrinsicContentSize.width, 0);
    _bottomControlView.disappearTransform = CGAffineTransformMakeTranslation(0, _bottomControlView.intrinsicContentSize.height);
    _previewView.disappearTransform = CGAffineTransformMakeScale(1, 0.001);
    _moreSettingsView.disappearTransform = CGAffineTransformMakeTranslation(_moreSettingsView.intrinsicContentSize.width, 0);
    _moreSecondarySettingView.disappearTransform = CGAffineTransformMakeTranslation(_moreSecondarySettingView.intrinsicContentSize.width, 0);
}

#pragma mark - 预览视图
- (SJVideoPlayerPreviewView *)previewView {
    if ( _previewView ) return _previewView;
    _previewView = [SJVideoPlayerPreviewView new];
    _previewView.delegate = self;
    _previewView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    return _previewView;
}

- (void)previewView:(SJVideoPlayerPreviewView *)view didSelectItem:(id<SJVideoPlayerPreviewInfo>)item {
    __weak typeof(self) _self = self;
    [_videoPlayer seekToTime:item.localTime completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.videoPlayer play];
    }];
}

#pragma mark - 拖拽视图
- (SJVideoPlayerDraggingProgressView *)draggingProgressView {
    if ( _draggingProgressView ) return _draggingProgressView;
    _draggingProgressView = [SJVideoPlayerDraggingProgressView new];
    [_draggingProgressView setPreviewImage:[UIImage imageNamed:@"placeholder"]];
    return _draggingProgressView;
}

#pragma mark - 顶部视图
- (SJVideoPlayerTopControlView *)topControlView {
    if ( _topControlView ) return _topControlView;
    _topControlView = [SJVideoPlayerTopControlView new];
    _topControlView.delegate = self;
    return _topControlView;
}

- (BOOL)hasBeenGeneratedPreviewImages {
    return _hasBeenGeneratedPreviewImages;
}

- (void)topControlView:(SJVideoPlayerTopControlView *)view clickedBtnTag:(SJVideoPlayerTopViewTag)tag {
    switch ( tag ) {
        case SJVideoPlayerTopViewTag_Back: {
            if ( _videoPlayer.isFullScreen ) [_videoPlayer rotation];
            else {
                if ( [self.delegate respondsToSelector:@selector(clickedBackBtnOnControlView:)] ) {
                    [self.delegate clickedBackBtnOnControlView:self];
                }
            }
        }
            break;
        case SJVideoPlayerTopViewTag_More: {
            [self controlLayerNeedDisappear:_videoPlayer];
            [UIView animateWithDuration:0.3 animations:^{
                [self.moreSettingsView appear];
            }];
        }
            break;
        case SJVideoPlayerTopViewTag_Preview: {
            [UIView animateWithDuration:0.3 animations:^{
                if ( !self.previewView.appearState ) [self.previewView appear];
                else [self.previewView disappear];
            }];
        }
            break;
    }
}

#pragma mark - 左侧视图
- (SJVideoPlayerLeftControlView *)leftControlView {
    if ( _leftControlView ) return _leftControlView;
    _leftControlView = [SJVideoPlayerLeftControlView new];
    _leftControlView.delegate = self;
    return _leftControlView;
}

- (void)leftControlView:(SJVideoPlayerLeftControlView *)view clickedBtnTag:(SJVideoPlayerLeftViewTag)tag {
    switch ( tag ) {
        case SJVideoPlayerLeftViewTag_Lock: {
            _videoPlayer.lockedScreen = NO;  // 点击锁定按钮, 解锁
        }
            break;
        case SJVideoPlayerLeftViewTag_Unlock: {
            _videoPlayer.lockedScreen = YES; // 点击解锁按钮, 锁定
        }
            break;
    }
    view.lockState = _videoPlayer.lockedScreen;
}


#pragma mark - 中间视图
- (SJVideoPlayerCenterControlView *)centerControlView {
    if ( _centerControlView ) return _centerControlView;
    _centerControlView = [SJVideoPlayerCenterControlView new];
    _centerControlView.delegate = self;
    return _centerControlView;
}

- (void)centerControlView:(SJVideoPlayerCenterControlView *)view clickedBtnTag:(SJVideoPlayerCenterViewTag)tag {
    switch ( tag ) {
        case SJVideoPlayerCenterViewTag_Replay: {
            [_videoPlayer replay];
        }
            break;
        case SJVideoPlayerCenterViewTag_Failed: {
            [_videoPlayer refresh];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 底部视图
- (SJVideoPlayerBottomControlView *)bottomControlView {
    if ( _bottomControlView ) return _bottomControlView;
    _bottomControlView = [SJVideoPlayerBottomControlView new];
    _bottomControlView.delegate = self;
    return _bottomControlView;
}

- (void)bottomView:(SJVideoPlayerBottomControlView *)view clickedBtnTag:(SJVideoPlayerBottomViewTag)tag {
    switch ( tag ) {
        case SJVideoPlayerBottomViewTag_Play: {
            if ( self.videoPlayer.state == SJVideoPlayerPlayState_PlayEnd ) [self.videoPlayer replay];
            else [self.videoPlayer play];
        }
            break;
        case SJVideoPlayerBottomViewTag_Pause: {
            [self.videoPlayer pauseForUser];
        }
            break;
        case SJVideoPlayerBottomViewTag_Full: {
            [self.videoPlayer rotation];
        }
            break;
    }
}

- (void)sliderWillBeginDraggingForBottomView:(SJVideoPlayerBottomControlView *)view {
    [UIView animateWithDuration:0.25 animations:^{
        [self.draggingProgressView appear];
    }];
    
    [self.draggingProgressView setCurrentTimeStr:self.videoPlayer.currentTimeStr totalTimeStr:self.videoPlayer.totalTimeStr];
    [self controlLayerNeedDisappear:self.videoPlayer];
    self.draggingProgressView.progress = self.videoPlayer.progress;
}

- (void)bottomView:(SJVideoPlayerBottomControlView *)view sliderDidDrag:(CGFloat)progress {
    self.draggingProgressView.progress = progress;
    [self.draggingProgressView setCurrentTimeStr:[self.videoPlayer timeStringWithSeconds:self.draggingProgressView.progress * self.videoPlayer.totalTime]];
    if ( self.videoPlayer.isFullScreen && !self.videoPlayer.URLAsset.isM3u8 ) {
        NSTimeInterval secs = self.draggingProgressView.progress * self.videoPlayer.totalTime;
        __weak typeof(self) _self = self;
        [self.videoPlayer screenshotWithTime:secs size:CGSizeMake(self.draggingProgressView.frame.size.width * 2, self.draggingProgressView.frame.size.height * 2) completion:^(SJVideoPlayer * _Nonnull videoPlayer, UIImage * _Nullable image, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.draggingProgressView setPreviewImage:image];
        }];
    }
}

- (void)sliderDidEndDraggingForBottomView:(SJVideoPlayerBottomControlView *)view {
    [UIView animateWithDuration:0.25 animations:^{
        [self.draggingProgressView disappear];
    }];
    
    __weak typeof(self) _self = self;
    [self.videoPlayer jumpedToTime:self.draggingProgressView.progress * self.videoPlayer.totalTime completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.videoPlayer play];
    }];
}

- (SJSlider *)bottomSlider {
    if ( _bottomSlider ) return _bottomSlider;
    _bottomSlider = [SJSlider new];
    _bottomSlider.pan.enabled = NO;
    _bottomSlider.trackHeight = 1;
    return _bottomSlider;
}


#pragma mark - 一级`更多`视图
- (SJVideoPlayerMoreSettingsView *)moreSettingsView {
    if ( _moreSettingsView ) return _moreSettingsView;
    _moreSettingsView = [SJVideoPlayerMoreSettingsView new];
    _moreSettingsView.footerViewModel = self.footerViewModel;
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

- (void)setMoreSettings:(NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    if ( moreSettings == _moreSettings ) return;
    _moreSettings = moreSettings;
    NSMutableSet<SJVideoPlayerMoreSetting *> *moreSettingsM = [NSMutableSet new];
    [moreSettings enumerateObjectsUsingBlock:^(SJVideoPlayerMoreSetting * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _addSetting:obj container:moreSettingsM];
    }];
    [moreSettingsM enumerateObjectsUsingBlock:^(SJVideoPlayerMoreSetting * _Nonnull obj, BOOL * _Nonnull stop) {
        [self _dressSetting:obj];
    }];
    
    self.moreSettingsView.moreSettings = moreSettings;
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
            [UIView animateWithDuration:0.3 animations:^{
                [self.moreSettingsView disappear];
                [self.moreSecondarySettingView appear];
            }];
            self.moreSecondarySettingView.twoLevelSettings = setting;
            setting.clickedExeBlock(setting);
        };
    }
    else {
        setting._exeBlock = ^(SJVideoPlayerMoreSetting * _Nonnull setting) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [UIView animateWithDuration:0.3 animations:^{
                [self.moreSettingsView disappear];
                [self.moreSecondarySettingView disappear];
            }];
            setting.clickedExeBlock(setting);
        };
    }
}


#pragma mark - 二级`更多`视图
- (SJVideoPlayerMoreSettingSecondaryView *)moreSecondarySettingView {
    if ( _moreSecondarySettingView ) return _moreSecondarySettingView;
    _moreSecondarySettingView = [SJVideoPlayerMoreSettingSecondaryView new];
    return _moreSecondarySettingView;
}


#pragma mark - loading 视图
- (SJLoadingView *)loadingView {
    if ( _loadingView ) return _loadingView;
    _loadingView = [SJLoadingView new];
    __weak typeof(self) _self = self;
    _loadingView.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.loadingView.lineColor = setting.loadingLineColor;
    }];
    return _loadingView;
}


#pragma mark - 加载配置

- (void)_controlViewLoadSetting {
    
    // load default setting
    __weak typeof(self) _self = self;
    
    SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {
        // update common settings
        commonSettings.more_trackColor = [UIColor whiteColor];
        commonSettings.progress_trackColor = [UIColor colorWithWhite:0.4 alpha:1];
        commonSettings.progress_bufferColor = [UIColor whiteColor];
        // .... other settings ....
        // .... .... .... .... ....
    });
    
    self.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.bottomSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.bottomSlider.trackImageView.backgroundColor = setting.progress_bufferColor;
        self.videoPlayer.placeholder = setting.placeholder;
    }];
}


#pragma mark - Video Player Control Data Source

- (void)installedControlViewToVideoPlayer:(SJVideoPlayer *)videoPlayer {
    self.videoPlayer = videoPlayer;
}

- (UIView *)controlView {
    return self;
}

- (void)setControlLayerAppearedState:(BOOL)controlLayerAppearedState {
    _controlLayerAppearedState = controlLayerAppearedState;
}

- (BOOL)controlLayerAppearedState {
    return _controlLayerAppearedState;
}

- (BOOL)controlLayerAppearCondition {
    return YES;
}

- (BOOL)controlLayerDisappearCondition {
    if ( self.previewView.appearState ) return NO;          // 如果预览视图显示, 则不隐藏控制层
    return YES;
}

- (BOOL)triggerGesturesCondition:(CGPoint)location {
    if ( CGRectContainsPoint(self.moreSettingsView.frame, location) ||
         CGRectContainsPoint(self.moreSecondarySettingView.frame, location) ||
         CGRectContainsPoint(self.previewView.frame, location) ) return NO;
    return YES;
}


#pragma mark - Video Player Control Delegate

#pragma mark 播放之前/状态
/// 当设置播放资源时调用.
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset {
    // reset
    self.topControlView.model.alwaysShowTitle = asset.alwaysShowTitle;
    self.topControlView.model.title = asset.title;
    self.topControlView.model.playOnCell = videoPlayer.playOnCell;
    self.topControlView.model.fullscreen = videoPlayer.isFullScreen;
    [self.topControlView update];
    
    self.bottomSlider.value = 0;
    self.bottomControlView.progress = 0;
    self.bottomControlView.bufferProgress = 0;
    [self.bottomControlView setCurrentTimeStr:@"00:00" totalTimeStr:@"00:00"];
}

/// 播放状态改变.
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer stateChanged:(SJVideoPlayerPlayState)state {
    switch ( state ) {
        case SJVideoPlayerPlayState_Prepare: {
            
        }
            break;
        case SJVideoPlayerPlayState_Paused:
        case SJVideoPlayerPlayState_PlayFailed:
        case SJVideoPlayerPlayState_PlayEnd: {
            self.bottomControlView.playState = NO;
        }
            break;
        case SJVideoPlayerPlayState_Playing: {
            self.bottomControlView.playState = YES;
        }
            break;
        default:
            break;
    }
    
    if ( SJVideoPlayerPlayState_PlayFailed == state || SJVideoPlayerPlayState_PlayEnd == state ) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.centerControlView appear];
        }];
        if ( SJVideoPlayerPlayState_PlayFailed == state ) [self.centerControlView failedState];
        else [self.centerControlView replayState];
    }
    else if ( self.centerControlView.appearState ) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.centerControlView disappear];
        }];
    }
}

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer playFailed:(NSError *)error {
#ifndef DEBUG
    NSLog(@"%@", error);
#endif
    [self.loadingView stop];
}
#pragma mark 进度
/// 播放进度回调.
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer
        currentTime:(NSTimeInterval)currentTime currentTimeStr:(NSString *)currentTimeStr
          totalTime:(NSTimeInterval)totalTime totalTimeStr:(NSString *)totalTimeStr {
    [self.bottomControlView setCurrentTimeStr:currentTimeStr totalTimeStr:totalTimeStr];
    self.bottomControlView.progress = currentTime / totalTime;
    self.bottomSlider.value = self.bottomControlView.progress;
}

/// 缓冲的进度.
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer loadedTimeProgress:(float)progress {
    self.bottomControlView.bufferProgress = progress;
}

/// 开始缓冲.
- (void)startLoading:(SJVideoPlayer *)videoPlayer {
    [self.loadingView start];
}

/// 缓冲完成.
- (void)loadCompletion:(SJVideoPlayer *)videoPlayer {
    [self.loadingView stop];
}

#pragma mark 显示/消失
/// 控制层需要显示.
- (void)controlLayerNeedAppear:(SJVideoPlayer *)videoPlayer {
    [UIView animateWithDuration:0.3 animations:^{
        if      ( videoPlayer.isFullScreen ) [_topControlView appear];
        else if ( videoPlayer.playOnCell ) {
            if ( videoPlayer.URLAsset.alwaysShowTitle ) [_topControlView appear];
            else [_topControlView disappear];
        }
        else [_topControlView appear];
        
        [_bottomControlView appear];
        if ( videoPlayer.isFullScreen ) [_leftControlView appear];
        else [_leftControlView disappear];  // 如果是小屏, 则不显示锁屏按钮
        [_bottomSlider disappear];
        
        if ( _moreSettingsView.appearState ) [_moreSettingsView disappear];
        if ( _moreSecondarySettingView.appearState ) [_moreSecondarySettingView disappear];
    }];
    
    self.controlLayerAppearedState = YES;   // update state
}

/// 控制层需要隐藏.
- (void)controlLayerNeedDisappear:(SJVideoPlayer *)videoPlayer {
    [UIView animateWithDuration:0.3 animations:^{
        [_topControlView disappear];
        [_bottomControlView disappear];
        [_leftControlView disappear];
        [_previewView disappear];
        [_bottomSlider appear];
    }];
    
    self.controlLayerAppearedState = NO;    // update state
}

///  在`tableView`或`collectionView`上将要显示的时候调用.
- (void)videoPlayerWillAppearInScrollView:(SJVideoPlayer *)videoPlayer {
    videoPlayer.view.hidden = NO;
}

///  在`tableView`或`collectionView`上将要消失的时候调用.
- (void)videoPlayerWillDisappearInScrollView:(SJVideoPlayer *)videoPlayer {
    [videoPlayer pause];
    videoPlayer.view.hidden = YES;
}

#pragma mark 锁屏
/// 播放器被锁屏, 此时将不旋转, 不触发手势相关事件.
- (void)lockedVideoPlayer:(SJVideoPlayer *)videoPlayer {
    [self controlLayerNeedDisappear:videoPlayer];
    [UIView animateWithDuration:0.3 animations:^{
        [_leftControlView appear];
    }];
}

/// 播放器解除锁屏.
- (void)unlockedVideoPlayer:(SJVideoPlayer *)videoPlayer {
    [self controlLayerNeedAppear:videoPlayer];
}

#pragma mark 屏幕旋转
/// 播放器将要旋转屏幕, `isFull`如果为`YES`, 则全屏.
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull {
    if ( isFull && !videoPlayer.URLAsset.isM3u8 ) {
        self.draggingProgressView.style = SJVideoPlayerDraggingProgressViewStylePreviewProgress;
    }
    else {
        self.draggingProgressView.style = SJVideoPlayerDraggingProgressViewStyleArrowProgress;
    }
    
    // update layout
    self.bottomControlView.fullscreen = isFull;
    self.topControlView.model.fullscreen = isFull;
    [self.topControlView update];
    
    [self _setControlViewsDisappearValue]; // update. `reset`.
    
    [self controlLayerNeedDisappear:videoPlayer];
    
    if ( _moreSettingsView.appearState ) [_moreSettingsView disappear];
}

#pragma mark 音量 / 亮度 / 播放速度
/// 声音被改变.
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer volumeChanged:(float)volume {
    if ( _footerViewModel.volumeChanged ) _footerViewModel.volumeChanged(volume);
}

/// 亮度被改变.
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer brightnessChanged:(float)brightness {
    if ( _footerViewModel.brightnessChanged ) _footerViewModel.brightnessChanged(brightness);
}

/// 播放速度被改变.
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer rateChanged:(float)rate {
    [videoPlayer showTitle:[NSString stringWithFormat:@"%.0f %%", rate * 100]];
    if ( _footerViewModel.playerRateChanged ) _footerViewModel.playerRateChanged(rate);
}

#pragma mark 水平手势
/// 水平方向开始拖动.
- (void)horizontalDirectionWillBeginDragging:(SJVideoPlayer *)videoPlayer {
    [self sliderWillBeginDraggingForBottomView:self.bottomControlView];
}

/// 水平方向拖动中. `translation`为此次增加的值.
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer horizontalDirectionDidDrag:(CGFloat)translation {
    CGFloat progress = self.draggingProgressView.progress + translation;
    [self bottomView:self.bottomControlView sliderDidDrag:progress];
}

/// 水平方向拖动结束.
- (void)horizontalDirectionDidEndDragging:(SJVideoPlayer *)videoPlayer {
    [self sliderDidEndDraggingForBottomView:self.bottomControlView];
}

#pragma mark size
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer presentationSize:(CGSize)size {
    if ( !self.generatePreviewImages ) return;
    CGFloat scale = size.width / size.height;
    CGSize previewItemSize = CGSizeMake(scale * self.previewView.intrinsicContentSize.height * 2, self.previewView.intrinsicContentSize.height * 2);
    __weak typeof(self) _self = self;
    [videoPlayer generatedPreviewImagesWithMaxItemSize:previewItemSize completion:^(SJVideoPlayer * _Nonnull player, NSArray<id<SJVideoPlayerPreviewInfo>> * _Nullable images, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( error ) {
            NSLog(@"Generate Preview Image Failed! error: %@", error);
        }
        else {
            self.hasBeenGeneratedPreviewImages = YES;
            self.previewView.previewImages = images;
            self.topControlView.model.fullscreen = player.isFullScreen;
            [self.topControlView update];
        }
    }];
}
@end
