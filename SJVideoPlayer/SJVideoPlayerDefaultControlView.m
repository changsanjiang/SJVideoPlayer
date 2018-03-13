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
#import "SJVideoPlayerRightControlView.h"
#import "SJVideoPlayerFilmEditingControlView.h"

#pragma mark -

NS_ASSUME_NONNULL_BEGIN

typedef void(^Block)(void);

static NSTimeInterval CommonAnimaDuration = 0.25;

inline static void UIView_Animations(NSTimeInterval duration, Block __nullable animations, Block __nullable completion);

@interface _SJAnimationContext : NSObject
@property (nonatomic, copy, nullable) Block completion;
- (instancetype)initWithCompletion:(nullable Block)completion;
@end


#pragma mark -
@interface SJVideoPlayerDefaultControlView ()<SJVideoPlayerLeftControlViewDelegate, SJVideoPlayerBottomControlViewDelegate, SJVideoPlayerTopControlViewDelegate, SJVideoPlayerPreviewViewDelegate, SJVideoPlayerCenterControlViewDelegate, SJVideoPlayerRightControlViewDelegate>

@property (nonatomic, assign) BOOL hasBeenGeneratedPreviewImages;
@property (nonatomic, strong, readonly) SJMoreSettingsSlidersViewModel *footerViewModel;

@property (nonatomic, strong, readonly) SJVideoPlayerPreviewView *previewView;
@property (nonatomic, strong, readonly) SJVideoPlayerDraggingProgressView *draggingProgressView;
@property (nonatomic, strong, readonly) SJVideoPlayerTopControlView *topControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerLeftControlView *leftControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerCenterControlView *centerControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerBottomControlView *bottomControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerRightControlView *rightControlView;
@property (nonatomic, strong, readonly) SJSlider *bottomSlider;
@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingsView *moreSettingsView;
@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingSecondaryView *moreSecondarySettingView;
@property (nonatomic, strong, readonly) SJLoadingView *loadingView;
@property (nonatomic, strong, readwrite, nullable) SJVideoPlayerFilmEditingControlView *filmEditingControlView;

@property (nonatomic, weak, readwrite, nullable) SJVideoPlayer *videoPlayer;
@property (nonatomic, strong, readwrite, nullable) SJVideoPlayerSettings *settings;

@end
NS_ASSUME_NONNULL_END

@implementation SJVideoPlayerDefaultControlView

@synthesize previewView = _previewView;
@synthesize draggingProgressView = _draggingProgressView;
@synthesize topControlView = _topControlView;
@synthesize leftControlView = _leftControlView;
@synthesize centerControlView = _centerControlView;
@synthesize bottomControlView = _bottomControlView;
@synthesize rightControlView = _rightControlView;
@synthesize bottomSlider = _bottomSlider;
@synthesize moreSettingsView = _moreSettingsView;
@synthesize moreSecondarySettingView = _moreSecondarySettingView;
@synthesize footerViewModel = _footerViewModel;
@synthesize loadingView = _loadingView;
@synthesize filmEditingControlView = _filmEditingControlView;

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
#ifdef DEBUG
    NSLog(@"SJVideoPlayerLog: %zd - %s", __LINE__, __func__);
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
    [self addSubview:self.filmEditingControlView];
    
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

- (void)_setControlViewsDisappearValue {
    
    _topControlView.disappearType = SJDisappearType_Transform;
    _topControlView.disappearTransform = CGAffineTransformMakeTranslation(0, -_topControlView.intrinsicContentSize.height);

    _leftControlView.disappearType = SJDisappearType_Transform;
    _leftControlView.disappearTransform = CGAffineTransformMakeTranslation(-_leftControlView.intrinsicContentSize.width, 0);

    _centerControlView.disappearType = SJDisappearType_Alpha;

    _bottomControlView.disappearType = SJDisappearType_Transform;
    _bottomControlView.disappearTransform = CGAffineTransformMakeTranslation(0, _bottomControlView.intrinsicContentSize.height);

    _rightControlView.disappearType = SJDisappearType_Transform;
    _rightControlView.disappearTransform = CGAffineTransformMakeTranslation(_rightControlView.intrinsicContentSize.width, 0);
    
    _bottomSlider.disappearType = SJDisappearType_Alpha;
    
    _previewView.disappearType = SJDisappearType_All;
    _previewView.disappearTransform = CGAffineTransformMakeScale(1, 0.001);

    _moreSettingsView.disappearType = SJDisappearType_Transform;
    _moreSettingsView.disappearTransform = CGAffineTransformMakeTranslation(_moreSettingsView.intrinsicContentSize.width, 0);

    _moreSecondarySettingView.disappearType = SJDisappearType_Transform;
    _moreSecondarySettingView.disappearTransform = CGAffineTransformMakeTranslation(_moreSecondarySettingView.intrinsicContentSize.width, 0);

    _draggingProgressView.disappearType = SJDisappearType_Alpha;
}

- (void)setEnableFilmEditing:(BOOL)enableFilmEditing {
    _enableFilmEditing = enableFilmEditing;
    if ( enableFilmEditing ) {
        [self insertSubview:self.rightControlView aboveSubview:self.bottomControlView];
        [_rightControlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.offset(0);
            make.centerY.offset(0);
        }];
        _rightControlView.disappearType = SJDisappearType_Transform;
        _rightControlView.disappearTransform = CGAffineTransformMakeTranslation(_rightControlView.intrinsicContentSize.width, 0);
        
        if ( !self.videoPlayer.controlLayerAppeared ) [_rightControlView disappear];
    }
    else {
        [_rightControlView removeFromSuperview];
    }
}

- (void)exitFilmEditingCompletion:(void(^ __nullable)(SJVideoPlayerDefaultControlView *))completion {
    if ( _filmEditingControlView ) {
        UIView_Animations(0.5, ^{
            [_filmEditingControlView disappear];
        }, ^{
            self.videoPlayer.disableRotation = NO;
            self.videoPlayer.disableGestureTypes = SJDisablePlayerGestureTypes_None;
            [self.videoPlayer play];
            [_filmEditingControlView removeFromSuperview];
            _filmEditingControlView = nil;  // clear
            if ( completion ) completion(self);
        });
    }
    else {
        if ( completion ) completion(self);
    }
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
            if ( _videoPlayer.isFullScreen ) {
                SJSupportedRotateViewOrientation supported = _videoPlayer.supportedRotateViewOrientation;
                if ( supported == SJSupportedRotateViewOrientation_All ) {
                    supported  = SJSupportedRotateViewOrientation_Portrait | SJSupportedRotateViewOrientation_LandscapeLeft | SJSupportedRotateViewOrientation_LandscapeRight;
                }
                if ( SJSupportedRotateViewOrientation_Portrait == (supported & SJSupportedRotateViewOrientation_Portrait) ) {
                    [_videoPlayer rotation];
                    return;
                }
            }
            
            if ( [self.delegate respondsToSelector:@selector(clickedBackBtnOnControlView:)] ) {
                [self.delegate clickedBackBtnOnControlView:self];
            }
        }
            break;
        case SJVideoPlayerTopViewTag_More: {
            [_videoPlayer controlLayerNeedDisappear];
            UIView_Animations(CommonAnimaDuration, ^{
                [self.moreSettingsView appear];
            }, nil);
        }
            break;
        case SJVideoPlayerTopViewTag_Preview: {
            if ( self.previewView.appearState )  [self.videoPlayer controlLayerNeedAppear];
            UIView_Animations(CommonAnimaDuration, ^{
                if ( !self.previewView.appearState ) [self.previewView appear];
                else [self.previewView disappear];
            }, nil);
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
    UIView_Animations(CommonAnimaDuration, ^{
        [self.draggingProgressView appear];
    }, nil);
    
    [self.draggingProgressView setCurrentTimeStr:self.videoPlayer.currentTimeStr totalTimeStr:self.videoPlayer.totalTimeStr];
    [_videoPlayer controlLayerNeedDisappear];
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
    UIView_Animations(CommonAnimaDuration, ^{
        [self.draggingProgressView disappear];
    }, nil);

    __weak typeof(self) _self = self;
    [self.videoPlayer jumpedToTime:self.draggingProgressView.progress * self.videoPlayer.totalTime completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.videoPlayer play];
    }];
}

#pragma mark - 右侧视图

- (SJVideoPlayerRightControlView *)rightControlView {
    if ( _rightControlView ) return _rightControlView;
    _rightControlView = [SJVideoPlayerRightControlView new];
    _rightControlView.delegate = self;
    return _rightControlView;
}

- (void)rightControlView:(SJVideoPlayerRightControlView *)view clickedBtnTag:(SJVideoPlayerRightViewTag)tag {
    if ( tag == SJVideoPlayerRightViewTag_FilmEditing ) {
        __weak typeof(self) _self = self;
        _filmEditingControlView = [SJVideoPlayerFilmEditingControlView new];
        _filmEditingControlView.getVideoScreenshot = ^UIImage *(SJVideoPlayerFilmEditingControlView *view) {
            __strong typeof(_self) self = _self;
            if ( !self ) return nil;
            [self.videoPlayer pause];
            return [self.videoPlayer screenshot];
        };
        
        _filmEditingControlView.exit = ^(SJVideoPlayerFilmEditingControlView * _Nonnull view) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self exitFilmEditingCompletion:nil];
        };
        
        _filmEditingControlView.recordCompleteExeBlock = ^void (SJVideoPlayerFilmEditingControlView * _Nonnull filmEditingView, short duration) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            NSTimeInterval beginTime = self.videoPlayer.currentTime - duration;
            NSTimeInterval endTime = self.videoPlayer.currentTime;
            [self.videoPlayer exportWithBeginTime:beginTime endTime:endTime presetName:nil progress:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, float progress) {
                filmEditingView.recordedVideoExportProgress = progress;
            } completion:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, SJVideoPlayerURLAsset * _Nonnull asset, NSURL * _Nonnull fileURL, UIImage * _Nonnull thumbImage) {
                filmEditingView.recordedVideoExportProgress = 1;
                filmEditingView.exportedVideoURL = fileURL;
            } failure:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, NSError * _Nonnull error) {
                filmEditingView.exportFailed = YES;
            }];
        };
        
        _filmEditingControlView.startRecordingExeBlock = ^(SJVideoPlayerFilmEditingControlView * _Nonnull view) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.videoPlayer.videoGravity = AVLayerVideoGravityResizeAspect;
            if ( self.videoPlayer.state == SJVideoPlayerPlayState_PlayEnd ) {
                [self.videoPlayer replay];
            }
            else if ( self.videoPlayer.state == SJVideoPlayerPlayState_Paused ) {
                [self.videoPlayer play];
            }
        };
        
        _filmEditingControlView.disappearType = SJDisappearType_Alpha;
        _filmEditingControlView.resultShare = self.filmEditingResultShare;
        _filmEditingControlView.exportBtnImage = self.settings.exportBtnImage;
        _filmEditingControlView.screenshotBtnImage = self.settings.screenshotBtnImage;
        _filmEditingControlView.cancelBtnTitle = self.settings.cancelBtnTitle;
        _filmEditingControlView.waitingForRecordingTipsText = self.settings.waitingForRecordingTipsText;
        _filmEditingControlView.recordTipsText = self.settings.recordTipsText;
        _filmEditingControlView.recordEndBtnImage = self.settings.recordEndBtnImage;
        _filmEditingControlView.uploadingPrompt = self.settings.uploadingPrompt;
        _filmEditingControlView.exportingPrompt = self.settings.exportingPrompt;
        _filmEditingControlView.operationFailedPrompt = self.settings.operationFailedPrompt;
        
        [self addSubview:_filmEditingControlView];
        [_filmEditingControlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        
        [self.videoPlayer controlLayerNeedDisappear];
        [self.bottomSlider disappear];
        if ( self.videoPlayer.state == SJVideoPlayerPlayState_PlayEnd ) [self.centerControlView disappear];
        self.videoPlayer.disableRotation = YES;
        self.videoPlayer.disableGestureTypes = SJDisablePlayerGestureTypes_All;
    }
}

#pragma mark -

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
            UIView_Animations(CommonAnimaDuration, ^{
                [self.moreSettingsView disappear];
                [self.moreSecondarySettingView appear];
            }, nil);
            self.moreSecondarySettingView.twoLevelSettings = setting;
            setting.clickedExeBlock(setting);
        };
    }
    else {
        setting._exeBlock = ^(SJVideoPlayerMoreSetting * _Nonnull setting) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            UIView_Animations(CommonAnimaDuration, ^{
                [self.moreSettingsView disappear];
                [self.moreSecondarySettingView disappear];
            }, nil);
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
        [self.draggingProgressView setPreviewImage:setting.placeholder];
        self.settings = setting;
    }];
}


#pragma mark - Video Player Control Data Source

/// 播放器安装完控制层的回调.
- (void)installedControlViewToVideoPlayer:(SJVideoPlayer *)videoPlayer {
    self.videoPlayer = videoPlayer;
}

- (UIView *)controlView {
    return self;
}

/// 控制层需要隐藏之前会调用这个方法, 如果返回NO, 将不调用`controlLayerNeedDisappear:`.
- (BOOL)controlLayerDisappearCondition {
    if ( self.previewView.appearState ) return NO;          // 如果预览视图显示, 则不隐藏控制层
    if ( SJVideoPlayerPlayState_PlayFailed == self.videoPlayer.state ) return NO;
    return YES;
}

/// 触发手势之前会调用这个方法, 如果返回NO, 将不调用水平手势相关的代理方法.
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
    self.topControlView.model.isPlayOnScrollView = videoPlayer.isPlayOnScrollView;
    self.topControlView.model.fullscreen = videoPlayer.isFullScreen;
    [self.topControlView update];
    _rightControlView.hidden = asset.isM3u8;
    
    self.bottomSlider.value = 0;
    self.bottomControlView.progress = 0;
    self.bottomControlView.bufferProgress = 0;
    [self.bottomControlView setCurrentTimeStr:@"00:00" totalTimeStr:@"00:00"];
    
    [self _promptWithNetworkStatus:videoPlayer.networkStatus];
}

/// 播放状态改变.
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer stateChanged:(SJVideoPlayerPlayState)state {
    switch ( state ) {
        case SJVideoPlayerPlayState_Unknown: {
            [videoPlayer controlLayerNeedDisappear];
            self.topControlView.model.title = nil;
            [self.topControlView update];
            self.bottomSlider.value = 0;
            self.bottomControlView.progress = 0;
            self.bottomControlView.bufferProgress = 0;
            [self.bottomControlView setCurrentTimeStr:@"00:00" totalTimeStr:@"00:00"];
        }
            break;
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
        case SJVideoPlayerPlayState_Buffing: {
            
        }
            break;
    }
    
    if ( SJVideoPlayerPlayState_PlayFailed == state ) {
#ifdef DEBUG
        NSLog(@"SJVideoPlayerLog: %@", videoPlayer.error);
#endif
        [self.loadingView stop];
        
        [self.topControlView appear];
        [self.leftControlView disappear];
        [self.bottomControlView disappear];

    }
    
    if ( SJVideoPlayerPlayState_PlayFailed == state || SJVideoPlayerPlayState_PlayEnd == state ) {
        UIView_Animations(CommonAnimaDuration, ^{
            [self.centerControlView appear];
        }, nil);
        if ( SJVideoPlayerPlayState_PlayFailed == state ) [self.centerControlView failedState];
        else [self.centerControlView replayState];
    }
    else if ( self.centerControlView.appearState ) {
        UIView_Animations(CommonAnimaDuration, ^{
            [self.centerControlView disappear];
        }, nil);
    }
    
    if ( SJVideoPlayerPlayState_PlayEnd == state ) {
        if ( _filmEditingControlView && _filmEditingControlView.isRecording ) {
            [videoPlayer showTitle:self.settings.videoPlayDidToEndText duration:2];
            [_filmEditingControlView completeRecording];
        }
    }
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

- (void)cancelLoading:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self.loadingView stop];
}

/// 缓冲完成.
- (void)loadCompletion:(SJVideoPlayer *)videoPlayer {
    [self.loadingView stop];
}

#pragma mark 显示/消失
/// 显示边缘控制视图
- (void)controlLayerNeedAppear:(SJVideoPlayer *)videoPlayer {
    UIView_Animations(CommonAnimaDuration, ^{
        if ( SJVideoPlayerPlayState_PlayFailed != videoPlayer.state ) {
            if ( videoPlayer.isPlayOnScrollView && !videoPlayer.isFullScreen ) {
                if ( videoPlayer.URLAsset.alwaysShowTitle ) [_topControlView appear];
                else [_topControlView disappear];
            }
            else [_topControlView appear];
            
            [_bottomControlView appear];
            if ( videoPlayer.isFullScreen ) {
                [_leftControlView appear];
                [_rightControlView appear];
            }
            else {
                [_leftControlView disappear];  // 如果是小屏, 则不显示锁屏按钮
                [_rightControlView disappear];
            }
            [_bottomSlider disappear];
        }
        else {
            [_topControlView appear];
            [_leftControlView disappear];
            [_bottomControlView disappear];
            [_rightControlView disappear];
        }
        
        if ( _moreSettingsView.appearState ) [_moreSettingsView disappear];
        if ( _moreSecondarySettingView.appearState ) [_moreSecondarySettingView disappear];
    }, nil);
}

/// 隐藏边缘控制视图
- (void)controlLayerNeedDisappear:(SJVideoPlayer *)videoPlayer {
    UIView_Animations(CommonAnimaDuration, ^{
        if ( SJVideoPlayerPlayState_PlayFailed != videoPlayer.state ) {
            [_topControlView disappear];
            [_bottomControlView disappear];
            [_rightControlView disappear];
            [_leftControlView disappear];
            [_previewView disappear];
            [_bottomSlider appear];
        }
        else {
            [_topControlView appear];
            [_leftControlView disappear];
            [_bottomControlView disappear];
            [_rightControlView disappear];
        }
    }, nil);
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
    [videoPlayer controlLayerNeedDisappear];
    UIView_Animations(CommonAnimaDuration, ^{
        [_leftControlView appear];
    }, nil);
}

/// 播放器解除锁屏.
- (void)unlockedVideoPlayer:(SJVideoPlayer *)videoPlayer {
    [videoPlayer controlLayerNeedAppear];
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
    
    [videoPlayer controlLayerNeedDisappear];
    
    if ( _moreSettingsView.appearState ) [_moreSettingsView disappear];
    if ( _moreSecondarySettingView.appearState ) [_moreSecondarySettingView disappear];
    [self.bottomSlider disappear];
}

/// 播放器完成旋转.
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer didEndRotation:(BOOL)isFull {
    UIView_Animations(CommonAnimaDuration, ^{
        [self.bottomSlider appear];
    }, nil);
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

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer horizontalDirectionDidMove:(CGFloat)progress {
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
#ifdef DEBUG
            NSLog(@"SJVideoPlayerLog: Generate Preview Image Failed! error: %@", error);
#endif
        }
        else {
            self.hasBeenGeneratedPreviewImages = YES;
            self.previewView.previewImages = images;
            self.topControlView.model.fullscreen = player.isFullScreen;
            [self.topControlView update];
        }
    }];
}

#pragma mark - Network
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer reachabilityChanged:(SJNetworkStatus)status {
    [self _promptWithNetworkStatus:status];
}

- (void)_promptWithNetworkStatus:(SJNetworkStatus)status {
    if ( self.disableNetworkStatusChangePrompt ) return;
    if ( [self.videoPlayer.assetURL isFileURL] ) return; // return when is local video.
    
    switch ( status ) {
        case SJNetworkStatus_NotReachable: {
            [self.videoPlayer showTitle:self.settings.notReachablePrompt duration:3];
        }
            break;
        case SJNetworkStatus_ReachableViaWWAN: {
            [self.videoPlayer showTitle:self.settings.reachableViaWWANPrompt duration:3];
        }
            break;
        case SJNetworkStatus_ReachableViaWiFi: {
            
        }
            break;
    }
}
@end


#pragma mark - other

@implementation _SJAnimationContext
- (instancetype)initWithCompletion:(nullable Block)completion {
    self = [super init];
    if ( !self ) return nil;
    _completion = completion;
    return self;
}
- (void)dealloc {
    if ( _completion ) _completion();
}
@end

inline static void UIView_Animations(NSTimeInterval duration, Block __nullable animations, Block __nullable completion) {
    if ( completion ) {
        _SJAnimationContext *context = [[_SJAnimationContext alloc] initWithCompletion:completion];
        [UIView beginAnimations:nil context:(void *)context];
        [UIView setAnimationDelegate:context];
    }
    else {
        [UIView beginAnimations:nil context:NULL];
    }
    [UIView setAnimationDuration:duration];
    if ( animations ) animations();
        [UIView commitAnimations];
}
