//
//  SJEdgeControlLayer.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/6.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJEdgeControlLayer.h"
#import "SJVideoPlayerBottomControlView.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#else
#import "SJBaseVideoPlayer.h"
#endif
#import "SJEdgeControlLayerSettings.h"
#import "SJVideoPlayerDraggingProgressView.h"
#import "UIView+SJVideoPlayerSetting.h"
#import "SJProgressSlider.h"
#import "SJVideoPlayerLeftControlView.h"
#import "SJVideoPlayerTopControlView.h"
#import "SJVideoPlayerPreviewView.h"
#import "SJVideoPlayerMoreSettingsView.h"
#import "SJVideoPlayerMoreSettingSecondaryView.h"
#import "SJMoreSettingsSlidersViewModel.h"
#import "SJVideoPlayerMoreSetting+Exe.h"
#import "SJVideoPlayerMoreSettingSecondary.h"
#import "SJVideoPlayerCenterControlView.h"
#import "SJLoadingView.h"
#import <objc/message.h>
#import "UIView+SJControlAdd.h"
#import "SJVideoPlayerRightControlView.h"
#import "SJVideoPlayerControlMaskView.h"
#if __has_include(<SJUIFactory/SJUIFactory.h>)
#import <SJUIFactory/SJUIFactory.h>
#else
#import "SJUIFactory.h"
#endif
#import "SJVideoPlayerAnimationHeader.h"
#if __has_include(<SJBaseVideoPlayer/SJTimerControl.h>)
#import <SJBaseVideoPlayer/SJTimerControl.h>
#else
#import "SJTimerControl.h"
#endif
#if __has_include(<SJBaseVideoPlayer/SJVideoPlayerRegistrar.h>)
#import <SJBaseVideoPlayer/SJVideoPlayerRegistrar.h>
#else
#import "SJVideoPlayerRegistrar.h"
#endif
#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer+PlayStatus.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer+PlayStatus.h>
#else
#import "SJBaseVideoPlayer+PlayStatus.h"
#endif

#pragma mark -

NS_ASSUME_NONNULL_BEGIN

#pragma mark -
@interface SJEdgeControlLayer ()<SJVideoPlayerLeftControlViewDelegate, SJVideoPlayerBottomControlViewDelegate, SJVideoPlayerTopControlViewDelegate, SJVideoPlayerPreviewViewDelegate, SJVideoPlayerCenterControlViewDelegate, SJVideoPlayerRightControlViewDelegate> {
    SJTimerControl *_lockStateTappedTimerControl;
}

@property (nonatomic, weak, nullable) SJBaseVideoPlayer *videoPlayer;    // need weak ref.

@property (nonatomic, assign) BOOL hasBeenGeneratedPreviewImages;
@property (nonatomic, strong, readonly) SJMoreSettingsSlidersViewModel *footerViewModel;

@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong, readonly) SJVideoPlayerPreviewView *previewView;
@property (nonatomic, strong, readonly) SJVideoPlayerDraggingProgressView *draggingProgressView;
@property (nonatomic, strong, readonly) SJVideoPlayerTopControlView *topControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerControlMaskView *topControlMaskView;
@property (nonatomic, strong, readonly) SJVideoPlayerLeftControlView *leftControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerCenterControlView *centerControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerBottomControlView *bottomControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerControlMaskView *bottomControlMaskView;
@property (nonatomic, strong, readonly) SJVideoPlayerRightControlView *rightControlView;
@property (nonatomic, strong, readonly) SJProgressSlider *bottomSlider;
@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingsView *moreSettingsView;
@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingSecondaryView *moreSecondarySettingView;
@property (nonatomic, strong, readonly) SJLoadingView *loadingView;
@property (nonatomic, strong, readonly) SJTimerControl *lockStateTappedTimerControl;
@property (nonatomic, strong, readwrite, nullable) SJEdgeControlLayerSettings *settings;

@end
NS_ASSUME_NONNULL_END

@implementation SJEdgeControlLayer

@synthesize previewView = _previewView;
@synthesize containerView = _containerView;
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
@synthesize topControlMaskView = _topControlMaskView;
@synthesize bottomControlMaskView = _bottomControlMaskView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _controlViewSetupView];
    [self _controlViewLoadSetting];
    // default values
    _generatePreviewImages = YES;
    return self;
}

#ifdef SJ_MAC
- (void)dealloc {
    NSLog(@"SJVideoPlayerLog: %d - %s", (int)__LINE__, __func__);
}
#endif

- (void)restartControlLayerCompeletionHandler:(nullable void(^)(void))compeletionHandler {
    if ( _videoPlayer.URLAsset ) {
        /// 手动纠正控制层状态, 并显示
        /// 播放器可能会受到外界切换的干扰, 所有这里手动纠正控制层的显示状态
        [_videoPlayer setControlLayerAppeared:YES];
        [self controlLayerNeedAppear:_videoPlayer compeletionHandler:compeletionHandler];
        return;
    }
    
    [_videoPlayer controlLayerNeedDisappear];
}

- (void)exitControlLayerCompeletionHandler:(nullable void(^)(void))compeletionHandler {
    /// clean
    _videoPlayer.controlLayerDataSource = nil;
    _videoPlayer.controlLayerDelegate = nil;
    _videoPlayer = nil;
    
    UIView_Animations(CommonAnimaDuration, ^{
        [self->_topControlView disappear];
        [self->_bottomControlView disappear];
        [self->_rightControlView disappear];
        [self->_leftControlView disappear];
        [self->_previewView disappear];
        [self->_bottomSlider disappear];
        [self->_centerControlView disappear];
    }, ^{
        [self.controlView removeFromSuperview];
        if ( compeletionHandler ) compeletionHandler();
    });
}

#pragma mark - Player extension

- (void)Extension_pauseAndDeterAppear {
    BOOL old = self.videoPlayer.pausedToKeepAppearState;
    self.videoPlayer.pausedToKeepAppearState = NO;              // Deter Appear
    [self.videoPlayer pause];
    self.videoPlayer.pausedToKeepAppearState = old;             // resume
}

#pragma mark - Player dataSrouce

/// 播放器安装完控制层的回调.
- (void)installedControlViewToVideoPlayer:(SJBaseVideoPlayer *)videoPlayer {
    self.videoPlayer = videoPlayer;
    [self videoPlayer:videoPlayer statusDidChanged:videoPlayer.playStatus];
    [self videoPlayer:videoPlayer prepareToPlay:videoPlayer.URLAsset];
}

- (UIView *)controlView {
    return self;
}

/// 控制层需要隐藏之前会调用这个方法, 如果返回NO, 将不调用`controlLayerNeedDisappear:`.
- (BOOL)controlLayerDisappearCondition {
    if ( self.previewView.appearState ) return NO;          // 如果预览视图显示, 则不隐藏控制层
    if ( [self.videoPlayer playStatus_isInactivity_ReasonPlayFailed] ) return NO;
    return YES;
}

/// 触发手势之前会调用这个方法, 如果返回NO, 将不调用水平手势相关的代理方法.
- (BOOL)triggerGesturesCondition:(CGPoint)location {
    if ( CGRectContainsPoint(self.moreSettingsView.frame, location) ||
        CGRectContainsPoint(self.moreSecondarySettingView.frame, location) ||
        CGRectContainsPoint(self.previewView.frame, location) ) return NO;
    return YES;
}

#pragma mark - Player prepareToPlay

/// 当设置播放资源时调用.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset {
    // reset
    self.topControlView.config.isAlwaysShowTitle = asset.alwaysShowTitle;
    self.topControlView.config.title = asset.title;
    self.topControlView.config.isPlayOnScrollView = videoPlayer.isPlayOnScrollView;
    self.topControlView.config.isFullscreen = videoPlayer.isFullScreen;
    [self.topControlView needUpdateConfig];
    
    
    self.bottomSlider.value = videoPlayer.progress;
    self.bottomControlView.progress = videoPlayer.progress;
    self.bottomControlView.bufferProgress = videoPlayer.bufferProgress;
    [self.bottomControlView setCurrentTimeStr:videoPlayer.currentTimeStr totalTimeStr:videoPlayer.totalTimeStr];
    
    [self _promptWithNetworkStatus:videoPlayer.networkStatus];

    _rightControlView.hidden = asset.isM3u8;

    
    SJAutoRotateSupportedOrientation supportedOrientation = _videoPlayer.supportedOrientation;
    
    // 如果不支持竖屏
    if ( SJAutoRotateSupportedOrientation_Portrait != (SJAutoRotateSupportedOrientation_Portrait & supportedOrientation) ) {
        _bottomControlView.hiddenFullscreenBtn = YES;
    }
    // 如果只支持竖屏
    else if ( (SJAutoRotateSupportedOrientation_LandscapeLeft != (SJAutoRotateSupportedOrientation_LandscapeLeft & supportedOrientation)) && (SJAutoRotateSupportedOrientation_LandscapeRight != (SJAutoRotateSupportedOrientation_LandscapeRight & supportedOrientation)) ) {
        _bottomControlView.hiddenFullscreenBtn = YES;
    }
    else {
        _bottomControlView.hiddenFullscreenBtn = NO;
    }
}

#pragma mark - Control layer appear / disappear
/// 显示边缘控制视图
- (void)controlLayerNeedAppear:(SJBaseVideoPlayer *)videoPlayer {
    [self controlLayerNeedAppear:videoPlayer compeletionHandler:nil];
}

- (void)controlLayerNeedAppear:(SJBaseVideoPlayer *)videoPlayer compeletionHandler:(void(^)(void))compeletionHandler {

    UIView_Animations(CommonAnimaDuration, ^{
        if ( [videoPlayer playStatus_isInactivity_ReasonPlayFailed] ) {
            [self->_centerControlView failedState];
            [self->_centerControlView appear];
            [self->_topControlView appear];
            [self->_leftControlView disappear];
            [self->_bottomControlView disappear];
            [self->_rightControlView disappear];
        }
        else {
            // top
            if ( videoPlayer.isPlayOnScrollView && !videoPlayer.isFullScreen ) {
                if ( videoPlayer.URLAsset.alwaysShowTitle ) [self->_topControlView appear];
                else [self->_topControlView disappear];
            }
            else [self->_topControlView appear];
            
            [self->_bottomControlView appear];
            
            if ( videoPlayer.isFullScreen ) {
                [self->_leftControlView appear];
                [self->_rightControlView appear];
            }
            else {
                [self->_leftControlView disappear];  // 如果是小屏, 则不显示锁屏按钮
                [self->_rightControlView disappear];
            }
            [self->_bottomSlider disappear];
            
            if ( [videoPlayer playStatus_isInactivity_ReasonPlayEnd] ) [self->_centerControlView appear];
            else [self->_centerControlView disappear];
        }
        
        if ( self->_moreSettingsView.appearState ) [self->_moreSettingsView disappear];
        if ( self->_moreSecondarySettingView.appearState ) [self->_moreSecondarySettingView disappear];
    }, compeletionHandler);
}

/// 隐藏边缘控制视图
- (void)controlLayerNeedDisappear:(SJBaseVideoPlayer *)videoPlayer {
    UIView_Animations(CommonAnimaDuration, ^{
        if ( ![videoPlayer playStatus_isInactivity_ReasonPlayFailed] ) {
            [self->_topControlView disappear];
            [self->_bottomControlView disappear];
            [self->_rightControlView disappear];
            if ( !videoPlayer.isLockedScreen ) [self->_leftControlView disappear];
            else [self->_leftControlView appear];
            [self->_previewView disappear];
            [self->_bottomSlider appear];
        }
        else {
            [self->_topControlView appear];
            [self->_leftControlView disappear];
            [self->_bottomControlView disappear];
            [self->_rightControlView disappear];
        }
    }, nil);
}

///  在`tableView`或`collectionView`上将要显示的时候调用.
- (void)videoPlayerWillAppearInScrollView:(SJBaseVideoPlayer *)videoPlayer {
    videoPlayer.view.hidden = NO;
}

///  在`tableView`或`collectionView`上将要消失的时候调用.
- (void)videoPlayerWillDisappearInScrollView:(SJBaseVideoPlayer *)videoPlayer {
    [videoPlayer pause];
    videoPlayer.view.hidden = YES;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer statusDidChanged:(SJVideoPlayerPlayStatus)status {
    switch (status) {
        case SJVideoPlayerPlayStatusUnknown: {
            self.topControlView.config.title = nil;
            [self.topControlView needUpdateConfig];
        }
            break;
        case SJVideoPlayerPlayStatusPrepare: { 
            [videoPlayer controlLayerNeedDisappear];
            self.bottomSlider.value = 0;
            self.bottomControlView.progress = 0;
            self.bottomControlView.bufferProgress = 0;
            [self.bottomControlView setCurrentTimeStr:@"00:00" totalTimeStr:@"00:00"];
            self.bottomControlView.playState = NO;
        }
            break;
        case SJVideoPlayerPlayStatusReadyToPlay: break;
        case SJVideoPlayerPlayStatusPlaying: {
            self.bottomControlView.playState = YES;
            if ( [self.centerControlView appearState] ) {
                UIView_Animations(CommonAnimaDuration, ^{
                    [self.centerControlView disappear];
                }, nil);
            }
        }
            break;
        case SJVideoPlayerPlayStatusPaused:
            if ( [videoPlayer playStatus_isPaused_ReasonBuffering] ) {
                if ( self.centerControlView.appearState ) {
                    UIView_Animations(CommonAnimaDuration, ^{
                        [self.centerControlView disappear];
                    }, nil);
                }
            }
            self.bottomControlView.playState = NO;
            break;
        case SJVideoPlayerPlayStatusInactivity: {
            self.bottomControlView.playState = NO;
            UIView_Animations(CommonAnimaDuration, ^{
                [self.centerControlView appear];
                if ( [videoPlayer playStatus_isInactivity_ReasonPlayEnd] ) [self.centerControlView replayState];
                else [self.centerControlView failedState];
            }, nil);
        }
            break;
    }
}

#pragma mark Play progress
/// 播放进度回调.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer
        currentTime:(NSTimeInterval)currentTime currentTimeStr:(NSString *)currentTimeStr
          totalTime:(NSTimeInterval)totalTime totalTimeStr:(NSString *)totalTimeStr {
    [self.bottomControlView setCurrentTimeStr:currentTimeStr totalTimeStr:totalTimeStr];
    float progress = videoPlayer.progress;
    self.bottomControlView.progress = progress;
    self.bottomSlider.value = progress;
    if ( self.draggingProgressView.appearState ) self.draggingProgressView.playProgress = progress;
}

/// 缓冲的进度.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer loadedTimeProgress:(float)progress {
    self.bottomControlView.bufferProgress = progress;
}

/// 开始缓冲.
- (void)startLoading:(SJBaseVideoPlayer *)videoPlayer {
#ifdef SJ_MAC
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif

    [self.loadingView start];
    self.bottomControlView.isLoading = YES;
}

- (void)cancelLoading:(__kindof SJBaseVideoPlayer *)videoPlayer {
#ifdef SJ_MAC
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif

    [self.loadingView stop];
    self.bottomControlView.isLoading = NO;
}

/// 缓冲完成.
- (void)loadCompletion:(SJBaseVideoPlayer *)videoPlayer {
#ifdef SJ_MAC
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif

    [self.loadingView stop];
    self.bottomControlView.isLoading = NO;
}
#pragma mark Player lock / unlock / tapped
/// 播放器被锁屏, 此时将不旋转, 不触发手势相关事件.
- (void)lockedVideoPlayer:(SJBaseVideoPlayer *)videoPlayer {
    _leftControlView.lockState = YES;
    [self.lockStateTappedTimerControl start];
    [videoPlayer controlLayerNeedDisappear];
}

/// 播放器解除锁屏.
- (void)unlockedVideoPlayer:(SJBaseVideoPlayer *)videoPlayer {
    _leftControlView.lockState = NO;
    [self.lockStateTappedTimerControl clear];
    [videoPlayer controlLayerNeedAppear];
}

/// 如果播放器锁屏, 当用户点击的时候, 这个方法会触发
- (void)tappedPlayerOnTheLockedState:(__kindof SJBaseVideoPlayer *)videoPlayer {
    UIView_Animations(CommonAnimaDuration, ^{
        if ( self->_leftControlView.appearState ) [self->_leftControlView disappear];
        else [self->_leftControlView appear];
    }, nil);
    if ( _leftControlView.appearState ) [_lockStateTappedTimerControl start];
    else [_lockStateTappedTimerControl clear];
}

#pragma mark Player Rotation
/// 播放器将要旋转屏幕, `isFull`如果为`YES`, 则全屏.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull {
    if ( isFull && !videoPlayer.URLAsset.isM3u8 ) {
        self.draggingProgressView.style = SJVideoPlayerDraggingProgressViewStylePreviewProgress;
    }
    else {
        self.draggingProgressView.style = SJVideoPlayerDraggingProgressViewStyleArrowProgress;
    }
    
    // update layout
    self.bottomControlView.isFullscreen = isFull;
    self.topControlView.config.isFullscreen = isFull;
    [self.topControlView needUpdateConfig];
    
    [self _setControlViewsDisappearValue]; // update. `reset`.
    
    if ( _previewView.appearState ) [_previewView disappear];
    if ( _moreSettingsView.appearState ) [_moreSettingsView disappear];
    if ( _moreSecondarySettingView.appearState ) [_moreSecondarySettingView disappear];
    [self.bottomSlider disappear];
    
    // `iPhone_X` remake constraints.
    if ( SJ_is_iPhoneX() ) {
        if ( isFull ) {
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.offset(0);
                make.height.equalTo(self.containerView.superview);
                make.width.equalTo(self.containerView.mas_height).multipliedBy(16 / 9.0f);
            }];
        }
        else {
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.offset(0);
            }];
        }
    }
    
    if ( videoPlayer.controlLayerAppeared ) [videoPlayer controlLayerNeedAppear]; // update
}

/// 播放器完成旋转.
//- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer didEndRotation:(BOOL)isFull {
//    
//}

#pragma mark - Fit On Screen

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willFitOnScreen:(BOOL)isFitOnScreen {
    // update layout
    self.bottomControlView.isFitOnScreen = isFitOnScreen;
    self.topControlView.config.isFitOnScreen = isFitOnScreen;
    [self.topControlView needUpdateConfig];
    
    [self _setControlViewsDisappearValue]; // update. `reset`.
    
    if ( _previewView.appearState ) [_previewView disappear];
    if ( _moreSettingsView.appearState ) [_moreSettingsView disappear];
    if ( _moreSecondarySettingView.appearState ) [_moreSecondarySettingView disappear];
    [self.bottomSlider disappear];
    
    if ( videoPlayer.controlLayerAppeared ) [videoPlayer controlLayerNeedAppear]; // update
}

//- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer didCompleteFitOnScreen:(BOOL)isFitOnScreen {
//
//}

#pragma mark Player Volume / Brightness / Rate
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

#pragma mark Player Horizontal Gesture
/// 水平方向开始拖动.
- (void)horizontalDirectionWillBeginDragging:(SJBaseVideoPlayer *)videoPlayer {
    [self sliderWillBeginDraggingForBottomView:self.bottomControlView];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer horizontalDirectionDidMove:(CGFloat)progress {
    [self bottomView:self.bottomControlView sliderDidDrag:progress];
}

/// 水平方向拖动结束.
- (void)horizontalDirectionDidEndDragging:(SJBaseVideoPlayer *)videoPlayer {
    [self sliderDidEndDraggingForBottomView:self.bottomControlView];
}

#pragma mark Player Size
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer presentationSize:(CGSize)size {
    if ( !self.generatePreviewImages ) return;
    CGFloat scale = size.width / size.height;
    CGSize previewItemSize = CGSizeMake(scale * self.previewView.intrinsicContentSize.height * 2, self.previewView.intrinsicContentSize.height * 2);
    __weak typeof(self) _self = self;
    [videoPlayer generatedPreviewImagesWithMaxItemSize:previewItemSize completion:^(SJBaseVideoPlayer * _Nonnull player, NSArray<id<SJVideoPlayerPreviewInfo>> * _Nullable images, NSError * _Nullable error) {
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
            self.topControlView.config.isFullscreen = player.isFullScreen;
            [self.topControlView needUpdateConfig];
        }
    }];
}

#pragma mark - Player Network
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer reachabilityChanged:(SJNetworkStatus)status {
    [self _promptWithNetworkStatus:status];
}

- (void)_promptWithNetworkStatus:(SJNetworkStatus)status {
    if ( self.disableNetworkStatusChangePrompt ) return;
    if ( [self.videoPlayer.assetURL isFileURL] ) return; // return when is local video.
    if ( !self.settings ) return;
 
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






#pragma mark - setup views
- (void)_controlViewSetupView {
    
    [self addSubview:self.topControlMaskView];
    [self addSubview:self.bottomControlMaskView];
    [self addSubview:self.containerView];
    
    [self.containerView addSubview:self.topControlView];
    [self.containerView addSubview:self.leftControlView];
    [self.containerView addSubview:self.centerControlView];
    [self.containerView addSubview:self.bottomControlView];
    [self.containerView addSubview:self.draggingProgressView];
    [self.containerView addSubview:self.bottomSlider];
    [self.containerView addSubview:self.previewView];
    [self.containerView addSubview:self.loadingView];
    
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_topControlMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
        make.height.equalTo(self->_topControlView);
    }];
    
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
    
    [_bottomControlMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.equalTo(self->_bottomControlView);
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
        make.top.equalTo(self->_topControlView.mas_bottom);
        make.leading.trailing.offset(0);
    }];
    
    [_moreSettingsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.offset(0);
        make.size.mas_offset(self->_moreSettingsView.intrinsicContentSize);
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
    
    __weak typeof(self) _self = self;
    _topControlView.appearExeBlock = ^(__kindof UIView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.topControlMaskView appear];
    };
    
    _topControlView.disappearExeBlock = ^(__kindof UIView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.topControlMaskView disappear];
    };
    
    _bottomControlView.appearExeBlock = ^(__kindof UIView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.bottomControlMaskView appear];
    };
    
    _bottomControlView.disappearExeBlock = ^(__kindof UIView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.bottomControlMaskView disappear];
    };
    
    _topControlMaskView.disappearType = _topControlView.disappearType = SJDisappearType_All;
    _topControlMaskView.disappearTransform = _topControlView.disappearTransform = CGAffineTransformMakeTranslation(0, -_topControlView.intrinsicContentSize.height);

    _leftControlView.disappearType = SJDisappearType_All;
    _leftControlView.disappearTransform = CGAffineTransformMakeTranslation(-_leftControlView.intrinsicContentSize.width, 0);

    _centerControlView.disappearType = SJDisappearType_Alpha;

    _bottomControlMaskView.disappearType = _bottomControlView.disappearType = SJDisappearType_All;
    _bottomControlMaskView.disappearTransform = _bottomControlView.disappearTransform = CGAffineTransformMakeTranslation(0, _bottomControlView.intrinsicContentSize.height);

    _rightControlView.disappearType = SJDisappearType_All;
    _rightControlView.disappearTransform = CGAffineTransformMakeTranslation(_rightControlView.intrinsicContentSize.width, 0);
    
    _bottomSlider.disappearType = SJDisappearType_Alpha;
    
    _previewView.disappearType = SJDisappearType_All;
    _previewView.disappearTransform = CGAffineTransformMakeScale(1, 0.001);

    self.moreSettingsView.disappearType = SJDisappearType_Transform;
    _moreSettingsView.disappearTransform = CGAffineTransformMakeTranslation(_moreSettingsView.intrinsicContentSize.width, 0);

    self.moreSecondarySettingView.disappearType = SJDisappearType_Transform;
    _moreSecondarySettingView.disappearTransform = CGAffineTransformMakeTranslation(_moreSecondarySettingView.intrinsicContentSize.width, 0);

    _draggingProgressView.disappearType = SJDisappearType_Alpha;
}

- (UIView *)containerView {
    if ( _containerView ) return _containerView;
    _containerView = [UIView new];
    _containerView.clipsToBounds = YES;
    return _containerView;
}

#pragma mark - Preview view
- (SJVideoPlayerPreviewView *)previewView {
    if ( _previewView ) return _previewView;
    _previewView = [SJVideoPlayerPreviewView new];
    _previewView.delegate = self;
    _previewView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    return _previewView;
}

- (void)previewView:(SJVideoPlayerPreviewView *)view didSelectItem:(id<SJVideoPlayerPreviewInfo>)item {
    __weak typeof(self) _self = self;
    [_videoPlayer seekToTime:CMTimeGetSeconds(item.localTime) completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.videoPlayer play];
    }];
}

#pragma mark - Top control view
- (SJVideoPlayerTopControlView *)topControlView {
    if ( _topControlView ) return _topControlView;
    _topControlView = [SJVideoPlayerTopControlView new];
    _topControlView.delegate = self;
    return _topControlView;
}

- (SJVideoPlayerControlMaskView *)topControlMaskView {
    if ( _topControlMaskView ) return _topControlMaskView;
    _topControlMaskView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_top];
    return _topControlMaskView;
}

- (BOOL)hasBeenGeneratedPreviewImages {
    return _hasBeenGeneratedPreviewImages;
}

- (void)topControlView:(SJVideoPlayerTopControlView *)view clickedBtnTag:(SJVideoPlayerTopViewTag)tag {
    switch ( tag ) {
        case SJVideoPlayerTopViewTag_Back: {
            [self _hanleBackButtonEvent];
        }
            break;
        case SJVideoPlayerTopViewTag_More: {
            if ( !_moreSettingsView.superview ) {
                [self addSubview:_moreSettingsView];
                [_moreSettingsView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.trailing.offset(0);
                    make.size.mas_offset(self->_moreSettingsView.intrinsicContentSize);
                }];
            }
            [_videoPlayer controlLayerNeedDisappear];
            UIView_Animations(CommonAnimaDuration, ^{
                [self->_moreSettingsView appear];
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

- (void)_hanleBackButtonEvent {
    if ( self.videoPlayer.useFitOnScreenAndDisableRotation ) {
        if ( _videoPlayer.isFitOnScreen ) {
            _videoPlayer.fitOnScreen = NO;
        }
        else {
            if ( [self.delegate respondsToSelector:@selector(clickedBackBtnOnControlLayer:)] ) {
                [self.delegate clickedBackBtnOnControlLayer:self];
            }
        }
        
        return;
    }
    
    if ( _videoPlayer.isFullScreen ) {
        if ( SJAutoRotateSupportedOrientation_Portrait == (_videoPlayer.supportedOrientation & SJAutoRotateSupportedOrientation_Portrait) ) {
            [_videoPlayer rotate];
            return;
        }
    }
    
    if ( [self.delegate respondsToSelector:@selector(clickedBackBtnOnControlLayer:)] ) {
        [self.delegate clickedBackBtnOnControlLayer:self];
    }
}

#pragma mark - Left control view
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
}


#pragma mark - Center control view
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

#pragma mark - Bottom control view
- (SJVideoPlayerBottomControlView *)bottomControlView {
    if ( _bottomControlView ) return _bottomControlView;
    _bottomControlView = [SJVideoPlayerBottomControlView new];
    _bottomControlView.delegate = self;
    return _bottomControlView;
}

- (SJVideoPlayerControlMaskView *)bottomControlMaskView {
    if ( _bottomControlMaskView ) return _bottomControlMaskView;
    _bottomControlMaskView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_bottom];
    return _bottomControlMaskView;
}

- (void)bottomView:(SJVideoPlayerBottomControlView *)view clickedBtnTag:(SJVideoPlayerBottomViewTag)tag {
    switch ( tag ) {
        case SJVideoPlayerBottomViewTag_Play: {
            [self.videoPlayer play];
        }
            break;
        case SJVideoPlayerBottomViewTag_Pause: {
            [self.videoPlayer pause];
        }
            break;
        case SJVideoPlayerBottomViewTag_Full: {
            [self _handleFullButtonEvent];
        }
            break;
    }
}

- (void)_handleFullButtonEvent {
    if ( !self.videoPlayer.useFitOnScreenAndDisableRotation ) {
        [self.videoPlayer rotate];
        
        return;
    }
    
    self.videoPlayer.fitOnScreen = !self.videoPlayer.isFitOnScreen;
}

- (SJVideoPlayerDraggingProgressView *)draggingProgressView {
    if ( _draggingProgressView ) return _draggingProgressView;
    _draggingProgressView = [SJVideoPlayerDraggingProgressView new];
    return _draggingProgressView;
}

- (void)sliderWillBeginDraggingForBottomView:(SJVideoPlayerBottomControlView *)view {
    UIView_Animations(CommonAnimaDuration, ^{
        [self.draggingProgressView appear];
    }, nil);
    [self.draggingProgressView setTimeShiftStr:self.videoPlayer.currentTimeStr totalTimeStr:self.videoPlayer.totalTimeStr];
    [_videoPlayer controlLayerNeedDisappear];
    self.draggingProgressView.playProgress = self.videoPlayer.progress;
    self.draggingProgressView.shiftProgress = self.videoPlayer.progress;
}

- (void)bottomView:(SJVideoPlayerBottomControlView *)view sliderDidDrag:(CGFloat)progress {
    self.draggingProgressView.shiftProgress = progress;
    [self.draggingProgressView setTimeShiftStr:[self.videoPlayer timeStringWithSeconds:self.draggingProgressView.shiftProgress * self.videoPlayer.totalTime]];
    if ( (self.videoPlayer.isFullScreen || self.videoPlayer.fitOnScreen ) && !self.videoPlayer.URLAsset.isM3u8 ) {
        NSTimeInterval secs = self.draggingProgressView.shiftProgress * self.videoPlayer.totalTime;
        __weak typeof(self) _self = self;
        [self.videoPlayer screenshotWithTime:secs size:CGSizeMake(self.draggingProgressView.frame.size.width * 2, self.draggingProgressView.frame.size.height * 2) completion:^(SJBaseVideoPlayer * _Nonnull videoPlayer, UIImage * _Nullable image, NSError * _Nullable error) {
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
    [self.videoPlayer seekToTime:self.draggingProgressView.shiftProgress * self.videoPlayer.totalTime completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.videoPlayer play];
    }];
}

#pragma mark - Right control view

- (SJVideoPlayerRightControlView *)rightControlView {
    if ( _rightControlView ) return _rightControlView;
    _rightControlView = [SJVideoPlayerRightControlView new];
    _rightControlView.delegate = self;
    _rightControlView.filmEditingBtnImage = self.settings.filmEditingBtnImage;
    return _rightControlView;
}

- (void)rightControlView:(SJVideoPlayerRightControlView *)view clickedBtnTag:(SJVideoPlayerRightViewTag)tag {
    if ( tag == SJVideoPlayerRightViewTag_FilmEditing ) {
        if ( [self.delegate respondsToSelector:@selector(clickedFilmEditingBtnOnControlLayer:)] ) {
            [self.delegate clickedFilmEditingBtnOnControlLayer:self];
        }
    }
}

#pragma mark - Right Film Editing

- (void)setEnableFilmEditing:(BOOL)enableFilmEditing {
    if ( enableFilmEditing == _enableFilmEditing ) return;
    _enableFilmEditing = enableFilmEditing;
    
    if ( enableFilmEditing ) {
        [self.containerView insertSubview:self.rightControlView aboveSubview:self.bottomControlView];
        _rightControlView.hidden = self.videoPlayer.URLAsset.isM3u8;
        [_rightControlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.offset(0);
            make.trailing.offset(0);
        }];
        _rightControlView.disappearType = SJDisappearType_Transform;
        _rightControlView.disappearTransform = CGAffineTransformMakeTranslation(_rightControlView.intrinsicContentSize.width, 0);
        
        if ( self.videoPlayer.controlLayerAppeared && self.videoPlayer.isFullScreen ) {
            [_rightControlView appear];
        }
        else {
            [_rightControlView disappear];
        }
    }
    else {
        [_rightControlView removeFromSuperview];
        _rightControlView = nil;
    }
}

- (void)setHideBackButtonWhenOrientationIsPortrait:(BOOL)hideBackButtonWhenOrientationIsPortrait {
    if ( hideBackButtonWhenOrientationIsPortrait == _hideBackButtonWhenOrientationIsPortrait ) return;
    _hideBackButtonWhenOrientationIsPortrait = hideBackButtonWhenOrientationIsPortrait;
    _topControlView.config.hideBackButtonWhenOrientationIsPortrait = hideBackButtonWhenOrientationIsPortrait;
    [_topControlView needUpdateConfig];
}

#pragma mark - Bottom slider

- (SJProgressSlider *)bottomSlider {
    if ( _bottomSlider ) return _bottomSlider;
    _bottomSlider = [SJProgressSlider new];
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
            if ( !self.moreSecondarySettingView.superview ) {
                [self addSubview:self.moreSecondarySettingView];
                [self.moreSecondarySettingView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.moreSettingsView);
                }];
            }
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


#pragma mark - Loading view
- (SJLoadingView *)loadingView {
    if ( _loadingView ) return _loadingView;
    _loadingView = [SJLoadingView new];
    __weak typeof(self) _self = self;
    _loadingView.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.loadingView.lineColor = setting.loadingLineColor;
    }];
    return _loadingView;
}


#pragma mark - 加载配置

- (void)_controlViewLoadSetting {
    // load setting
    SJEdgeControlLayerSettings.update(^(SJEdgeControlLayerSettings * _Nonnull commonSettings) {});
    
    __weak typeof(self) _self = self;
    self.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.bottomSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.bottomSlider.trackImageView.backgroundColor = setting.progress_bufferColor;
        self.videoPlayer.placeholder = setting.placeholder;
        if ( self.enableFilmEditing ) self.rightControlView.filmEditingBtnImage = setting.filmEditingBtnImage;
        [self.draggingProgressView setPreviewImage:setting.placeholder];
        self.settings = setting;
        [self _promptWithNetworkStatus:self.videoPlayer.networkStatus];
    }];
}

#pragma mark -
- (SJTimerControl *)lockStateTappedTimerControl {
    if ( _lockStateTappedTimerControl ) return _lockStateTappedTimerControl;
    _lockStateTappedTimerControl = [[SJTimerControl alloc] init];
    __weak typeof(self) _self = self;
    _lockStateTappedTimerControl.exeBlock = ^(SJTimerControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [control clear];
        UIView_Animations(CommonAnimaDuration, ^{
            if ( self.leftControlView.appearState ) [self.leftControlView disappear];
        }, nil);
    };
    return _lockStateTappedTimerControl;
}
@end
