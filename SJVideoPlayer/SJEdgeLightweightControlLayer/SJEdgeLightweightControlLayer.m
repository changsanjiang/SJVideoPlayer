//
//  SJEdgeLightweightControlLayer.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJEdgeLightweightControlLayer.h"
#import "SJLightweightTopControlView.h"
#import "SJLightweightLeftControlView.h"
#import "SJLightweightBottomControlView.h"
#import "SJLightweightCenterControlView.h"
#import "SJLightweightRightControlView.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#if __has_include(<SJUIFactory/SJUIFactory.h>)
#import <SJUIFactory/SJUIFactory.h>
#else
#import "SJUIFactory.h"
#endif

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
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer+PlayStatus.h>
#else
#import "SJBaseVideoPlayer.h"
#import "SJBaseVideoPlayer+PlayStatus.h"
#endif

#import "UIView+SJControlAdd.h"
#import "SJVideoPlayerAnimationHeader.h"
#import "SJVideoPlayerControlMaskView.h"
#import "SJVideoPlayerDraggingProgressView.h"
#import "SJLoadingView.h"
#import "UIView+SJVideoPlayerSetting.h"
#import "SJProgressSlider.h"
#import "UIView+SJVideoPlayerSetting.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJEdgeLightweightControlLayer () <SJLightweightBottomControlViewDelegate, SJLightweightLeftControlViewDelegate, SJLightweightTopControlViewDelegate, SJLightweightCenterControlViewDelegate, SJLightweightRightControlViewDelegate, SJProgressSliderDelegate> {
    UIView *_controlView;
    SJVideoPlayerDraggingProgressView *_draggingProgressView;
    SJLoadingView *_loadingView;
    SJProgressSlider *_bottomSlider;
    UIView *_containerView;
    SJTimerControl *_lockStateTappedTimerControl;
    SJLightweightCenterControlView *_centerControlView;
}
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong, readonly) SJLightweightTopControlView *topControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerControlMaskView *topMaskView;
@property (nonatomic, strong, readonly) SJLightweightLeftControlView *leftControlView;
@property (nonatomic, strong, readonly) SJLightweightBottomControlView *bottomControlView;
@property (nonatomic, strong, readonly) SJLightweightCenterControlView *centerControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerControlMaskView *bottomMaskView;
@property (nonatomic, strong, readonly) SJVideoPlayerDraggingProgressView *draggingProgressView;
@property (nonatomic, strong, readonly) SJLightweightRightControlView *rightControlView;


@property (nonatomic, weak, nullable) SJBaseVideoPlayer *videoPlayer;   // need weak ref.
@property (nonatomic, strong, readonly) SJLoadingView *loadingView;
@property (nonatomic, strong, readonly) SJProgressSlider *bottomSlider;
@property (nonatomic, strong, nullable) SJEdgeControlLayerSettings *settings;
@property (nonatomic, strong, readonly) SJTimerControl *lockStateTappedTimerControl;
@property (nonatomic, strong, readonly) UIButton *backBtn;

@end

@implementation SJEdgeLightweightControlLayer
@synthesize topMaskView = _topMaskView;
@synthesize bottomMaskView = _bottomMaskView;
@synthesize topControlView = _topControlView;
@synthesize leftControlView = _leftControlView;
@synthesize bottomControlView = _bottomControlView;
@synthesize backBtn = _backBtn;
@synthesize rightControlView = _rightControlView;
@synthesize restarted = _restarted;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self setupViews];
    [self controlViewLoadSetting];
    return self;
}

#pragma mark - Player extension

- (void)Extension_pauseAndDeterAppear {
    BOOL old = self.videoPlayer.pausedToKeepAppearState;
    self.videoPlayer.pausedToKeepAppearState = NO;              // Deter Appear
    [self.videoPlayer pause];
    self.videoPlayer.pausedToKeepAppearState = old;             // resume
}

#pragma mark -

- (void)restartControlLayer {
    _restarted = YES;
    if ( _videoPlayer.URLAsset ) {
        [_videoPlayer controlLayerNeedAppear];
        return;
    }
    
    [_videoPlayer controlLayerNeedDisappear];
}
- (void)exitControlLayer {
    _restarted = NO;
    /// clean
    _videoPlayer.controlLayerDataSource = nil;
    _videoPlayer.controlLayerDelegate = nil;
    _videoPlayer = nil;
    
    UIView_Animations(CommonAnimaDuration, ^{
        [self->_topControlView disappear];
        [self->_bottomControlView disappear];
        [self->_rightControlView disappear];
        [self->_leftControlView disappear];
        [self->_bottomSlider disappear];
        [self->_centerControlView disappear];
    }, ^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    });
}

#pragma mark -
- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _videoPlayer = videoPlayer;
    
    [self videoPlayer:videoPlayer statusDidChanged:videoPlayer.playStatus];
    [self videoPlayer:videoPlayer prepareToPlay:videoPlayer.URLAsset];
}

- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset {
    // back btn
    if ( videoPlayer.isPlayOnScrollView ) {
        [_backBtn removeFromSuperview];
        _backBtn = nil;
    }
    else {
        if ( !_backBtn.superview ) {
            [self.containerView addSubview:self.backBtn];
            _backBtn.disappearType = SJDisappearType_Alpha;
            [_backBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self->_topControlView.backBtn);
            }];
        }
    }
    
    self.topControlView.config.isPlayOnScrollView = videoPlayer.isPlayOnScrollView;
    self.topControlView.config.isAlwaysShowTitle = asset.alwaysShowTitle;
    self.topControlView.config.title = asset.title;
    [self.topControlView needUpdateConfig];
    
    self.bottomSlider.value = videoPlayer.progress;
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

- (void)controlLayerNeedAppear:(nonnull __kindof SJBaseVideoPlayer *)videoPlayer {
    [self controlLayerNeedAppear:videoPlayer compeletionHandler:nil];
}

- (void)controlLayerNeedAppear:(nonnull __kindof SJBaseVideoPlayer *)videoPlayer
            compeletionHandler:(nullable void(^)(void))compeletionHandler {
    UIView_Animations(CommonAnimaDuration, ^{
        if ( videoPlayer.isFullScreen ) [self->_backBtn appear];
        
        if ( [videoPlayer playStatus_isInactivity_ReasonPlayFailed] ) {
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
            
            if ( ![videoPlayer playStatus_isInactivity_ReasonPlayEnd] && [self->_centerControlView appearState] ) [self->_centerControlView disappear];
        }
    }, compeletionHandler);
}

- (void)controlLayerNeedDisappear:(nonnull __kindof SJBaseVideoPlayer *)videoPlayer {
    UIView_Animations(CommonAnimaDuration, ^{
        if ( videoPlayer.isFullScreen ) [self->_backBtn disappear];
        
        if ( ![videoPlayer playStatus_isInactivity_ReasonPlayFailed] ) {
            [self->_topControlView disappear];
            [self->_bottomControlView disappear];
            if ( !videoPlayer.isLockedScreen ) [self->_leftControlView disappear];
            else [self->_leftControlView appear];
            [self->_bottomSlider appear];
            [self->_rightControlView disappear];
        }
        else {
            [self->_topControlView appear];
            [self->_leftControlView disappear];
            [self->_bottomControlView disappear];
            [self->_rightControlView disappear];
        }
    }, nil);
}

- (void)videoPlayerWillAppearInScrollView:(SJBaseVideoPlayer *)videoPlayer {
    videoPlayer.view.hidden = NO;
}

- (void)videoPlayerWillDisappearInScrollView:(SJBaseVideoPlayer *)videoPlayer {
    [videoPlayer pause];
    videoPlayer.view.hidden = YES;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer statusDidChanged:(SJVideoPlayerPlayStatus)status {
    switch (status) {
        case SJVideoPlayerPlayStatusUnknown:  {
            self.topControlView.config.title = nil;
            [self.topControlView needUpdateConfig];
        }
            break;
        case SJVideoPlayerPlayStatusPrepare: {
            [videoPlayer controlLayerNeedDisappear];
            self.bottomSlider.value = 0;
            [self.bottomControlView setCurrentTimeStr:@"00:00" totalTimeStr:@"00:00"];
            self.bottomControlView.stopped = YES;
        }
            break;
        case SJVideoPlayerPlayStatusReadyToPlay: break;
        case SJVideoPlayerPlayStatusPlaying: {
            self.bottomControlView.stopped = NO;
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
            self.bottomControlView.stopped = YES;
            break;
        case SJVideoPlayerPlayStatusInactivity: {
            self.bottomControlView.stopped = YES;
            UIView_Animations(CommonAnimaDuration, ^{
                [self.centerControlView appear];
                if ( [videoPlayer playStatus_isInactivity_ReasonPlayEnd] ) [self.centerControlView replayState];
            }, nil);
        }
            break;
    }
    
    [self _startOrStopLoadingView];
}

- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer
        currentTime:(NSTimeInterval)currentTime currentTimeStr:(NSString *)currentTimeStr
          totalTime:(NSTimeInterval)totalTime totalTimeStr:(NSString *)totalTimeStr {
    _bottomSlider.maxValue = totalTime?:1;
    _bottomSlider.value = currentTime;
    
    [_bottomControlView setCurrentTimeStr:currentTimeStr totalTimeStr:totalTimeStr];
    
    if ( !_bottomControlView.progressSlider.isDragging ) {
        _bottomControlView.progressSlider.maxValue = totalTime?:1;
        _bottomControlView.progressSlider.value = currentTime;
    }
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull {
    if ( _backBtn ) {
        if ( videoPlayer.isFullScreen ) [_backBtn disappear];
        else {
            if ( _hideBackButtonWhenOrientationIsPortrait ) [_backBtn disappear];
            else if ( !videoPlayer.isPlayOnScrollView ) [_backBtn appear];
            else [_backBtn disappear];
        }
    }
    
    _topControlView.config.isFullscreen = isFull;
    [_topControlView needUpdateConfig];

    _bottomControlView.isFullscreen = isFull;
    
    if ( SJ_is_iPhoneX() ) {
        if ( isFull ) {
            // `iPhone_X` remake constraints.
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.offset(0);
                make.height.equalTo(self.containerView.superview);
                make.width.equalTo(self.containerView.mas_height).multipliedBy(16 / 9.0f);
            }];
        }
        else {
            // `iPhone_X` remake constraints.
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.offset(0);
            }];
        }
    }
    
    if ( videoPlayer.controlLayerIsAppeared ) [videoPlayer controlLayerNeedAppear]; // update
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willFitOnScreen:(BOOL)isFitOnScreen {
    // update layout
    self.topControlView.config.isFitOnScreen = isFitOnScreen;
    [self.topControlView needUpdateConfig];
    self.bottomControlView.isFitOnScreen = isFitOnScreen;
    [self _setControlViewsDisappearValue]; // update. `reset`.
    [self.bottomSlider disappear];
    if ( videoPlayer.controlLayerIsAppeared ) [videoPlayer controlLayerNeedAppear]; // update
    _backBtn.hidden = _hideBackButtonWhenOrientationIsPortrait && !isFitOnScreen;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer panGestureTriggeredInTheHorizontalDirection:(SJPanGestureRecognizerState)state progressTime:(NSTimeInterval)progressTime {
    switch ( state ) {
        case SJPanGestureRecognizerStateBegan: {
            [self _draggingDidStart:_videoPlayer];
        }
            break;
        case SJPanGestureRecognizerStateChanged: {
            [self _draggingForVideoPlayer:_videoPlayer progressTime:progressTime];
        }
            break;
        case SJPanGestureRecognizerStateEnded: {
            [self _draggingDidEnd:_videoPlayer];
        }
            break;
    }
}

#pragma mark -

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer bufferTimeDidChange:(NSTimeInterval)bufferTime {
    self.bottomControlView.progressSlider.bufferProgress = bufferTime / videoPlayer.totalTime;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus {
    [self _startOrStopLoadingView];
}

- (void)_startOrStopLoadingView {
    SJPlayerBufferStatus bufferStatus = self.videoPlayer.playbackController.bufferStatus;
    if ( [_videoPlayer playStatus_isPaused_ReasonSeeking] ||
        [_videoPlayer playStatus_isPrepare] ) {
        [_loadingView start];
    }
    else if ( _videoPlayer.playbackController.bufferStatus == SJPlayerBufferStatusPlayable ||
             [_videoPlayer playStatus_isInactivity] ) {
        [_loadingView stop];
    }
    else {
        switch ( bufferStatus ) {
            case SJPlayerBufferStatusUnknown:
            case SJPlayerBufferStatusPlayable: {
                [_loadingView stop];
            }
                break;
            case SJPlayerBufferStatusUnplayable: {
                [_loadingView start];
            }
                break;
        }
    }
}

- (void)lockedVideoPlayer:(SJBaseVideoPlayer *)videoPlayer {
    _leftControlView.lockState = YES;
    [self.lockStateTappedTimerControl start];
    [videoPlayer controlLayerNeedDisappear];
}

- (void)unlockedVideoPlayer:(SJBaseVideoPlayer *)videoPlayer {
    _leftControlView.lockState = NO;
    [self.lockStateTappedTimerControl clear];
    [videoPlayer controlLayerNeedAppear];
}

- (void)tappedPlayerOnTheLockedState:(__kindof SJBaseVideoPlayer *)videoPlayer {
    UIView_Animations(CommonAnimaDuration, ^{
        if ( self->_leftControlView.appearState ) [self->_leftControlView disappear];
        else [self->_leftControlView appear];
    }, nil);
    if ( _leftControlView.appearState ) [_lockStateTappedTimerControl start];
    else [_lockStateTappedTimerControl clear];
}
#pragma mark - Network
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer reachabilityChanged:(SJNetworkStatus)status {
    [self _promptWithNetworkStatus:status];
}

- (void)_promptWithNetworkStatus:(SJNetworkStatus)status {
    if ( _disablePromptWhenNetworkStatusChanges ) return;
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

#pragma mark -
- (void)setTopItems:(nullable NSArray<SJLightweightTopItem *> *)topItems {
    _topItems = topItems;
    _topControlView.topItems = topItems;
}

#pragma mark -
- (void)setupViews { 
    [self.controlView addSubview:self.topMaskView];
    [self.controlView addSubview:self.bottomMaskView];
    [self.controlView addSubview:self.containerView];

    [self.containerView addSubview:self.topControlView];
    [self.containerView addSubview:self.leftControlView];
    [self.containerView addSubview:self.bottomControlView];
    [self.containerView addSubview:self.draggingProgressView];
    [self.containerView addSubview:self.loadingView];
    [self.containerView addSubview:self.bottomSlider];
    [self.containerView addSubview:self.centerControlView];
    
    [_topMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self->_topControlView);
        make.top.leading.trailing.offset(0);
    }];
    
    [_bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self->_bottomControlView);
        make.leading.bottom.trailing.offset(0);
    }];
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_topControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
    }];
    
    [_leftControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(0);
        make.centerY.offset(0);
    }];
    
    [_bottomControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
    }];
    
    [_draggingProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [_bottomSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.offset(1);
    }];

    [_centerControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [self _setControlViewsDisappearValue];
    [_topControlView disappear];
    [_leftControlView disappear];
    [_bottomControlView disappear];
    [_draggingProgressView disappear];
    [_centerControlView disappear];
}

- (void)_setControlViewsDisappearValue {
    _topMaskView.disappearType = SJDisappearType_Alpha;
    _topControlView.disappearType = SJDisappearType_Alpha;
    _leftControlView.disappearType = SJDisappearType_Alpha;
    _bottomMaskView.disappearType = SJDisappearType_Alpha;
    _bottomControlView.disappearType = SJDisappearType_Alpha;
    _draggingProgressView.disappearType = SJDisappearType_Alpha;
    _bottomSlider.disappearType = SJDisappearType_Alpha;
    _centerControlView.disappearType = SJDisappearType_Alpha;
    _rightControlView.disappearType = SJDisappearType_Alpha;

    __weak typeof(self) _self = self;
    void(^block)(__kindof UIView *view) = ^(__kindof UIView *view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( view == self.topControlView ) {
            if ( view.appearState ) [self.topMaskView appear];
            else [self.topMaskView disappear];
        }
        else if ( view == self.bottomControlView ) {
            if ( view.appearState ) [self.bottomMaskView appear];
            else [self.bottomMaskView disappear];
        }
    };
    
    _topControlView.appearExeBlock = block;
    _topControlView.disappearExeBlock = block;
    _bottomControlView.appearExeBlock = block;
    _bottomControlView.disappearExeBlock = block;
}

- (UIView *)controlView {
    if ( _controlView ) return _controlView;
    _controlView = [UIView new];
    return _controlView;
}
#pragma mark - top control view
- (SJLightweightTopControlView *)topControlView {
    if ( _topControlView ) return _topControlView;
    _topControlView = [SJLightweightTopControlView new];
    _topControlView.delegate = self;
    return _topControlView;
}
- (void)topControlView:(SJLightweightTopControlView *)view clickedItem:(SJLightweightTopItem *)item {
    if ( [self.delegate respondsToSelector:@selector(lightwieghtControlLayer:clickedTopControlItem:)] ) {
        [self.delegate lightwieghtControlLayer:self clickedTopControlItem:item];
    }
}
- (void)clickedBackBtnOnTopControlView:(SJLightweightTopControlView *)view {
    if ( [self.delegate respondsToSelector:@selector(clickedBackBtnOnLightweightControlLayer:)] ) {
        [self.delegate clickedBackBtnOnLightweightControlLayer:self];
    }
}

- (SJLightweightLeftControlView *)leftControlView {
    if ( _leftControlView ) return _leftControlView;
    _leftControlView = [SJLightweightLeftControlView new];
    _leftControlView.delegate = self;
    return _leftControlView;
}
- (void)leftControlView:(SJLightweightLeftControlView *)view clickedBtnTag:(SJLightweightLeftControlViewTag)tag {
    switch ( tag ) {
        case SJLightweightLeftControlViewTag_Lock: {
            _videoPlayer.lockedScreen = NO;  // 点击锁定按钮, 解锁
        }
            break;
        case SJLightweightLeftControlViewTag_Unlock: {
            _videoPlayer.lockedScreen = YES; // 点击解锁按钮, 锁定
        }
            break;
    }
}
#pragma mark - center view
- (SJLightweightCenterControlView *)centerControlView {
    if ( _centerControlView ) return _centerControlView;
    _centerControlView = [SJLightweightCenterControlView new];
    _centerControlView.delegate = self;
    return _centerControlView;
}

- (void)centerControlView:(SJLightweightCenterControlView *)view clickedBtnTag:(SJLightweightCenterControlViewTag)tag {
    switch ( tag ) {
        case SJLightweightCenterControlViewTag_Replay: {
            [_videoPlayer replay];
        }
            break;
        case SJLightweightCenterControlViewTag_Failed: {
            [_videoPlayer refresh];
        }
            break;
        default:
            break;
    }
}
#pragma mark - bottom control view
- (SJLightweightBottomControlView *)bottomControlView {
    if ( _bottomControlView ) return _bottomControlView;
    _bottomControlView = [SJLightweightBottomControlView new];
    _bottomControlView.delegate = self;
    _bottomControlView.progressSlider.delegate = self;
    return _bottomControlView;
}
- (void)bottomControlView:(SJLightweightBottomControlView *)bottomControlView clickedViewTag:(SJLightweightBottomControlViewTag)tag {
    switch ( tag ) {
        case SJLightweightBottomControlViewTag_Full: {
            [self _handleFullButtonEvent];
        }
            break;
        case SJLightweightBottomControlViewTag_Play: {
            [_videoPlayer play];
        }
            break;
        case SJLightweightBottomControlViewTag_Pause: {
            [_videoPlayer pause];
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

#pragma mark - slider
- (void)sliderWillBeginDragging:(SJProgressSlider *)slider {
    [self _draggingDidStart:_videoPlayer];
}

- (void)sliderDidDrag:(SJProgressSlider *)slider {
    [self _draggingForVideoPlayer:_videoPlayer progressTime:slider.value];
}

- (void)sliderDidEndDragging:(SJProgressSlider *)slider {
    [self _draggingDidEnd:_videoPlayer];
}

/// 拖拽将要开始
- (void)_draggingDidStart:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( !_videoPlayer.isFullScreen ||
         !_videoPlayer.playbackController.isReadyForDisplay ||
         videoPlayer.URLAsset.isM3u8 ) {
        self.draggingProgressView.style = SJVideoPlayerDraggingProgressViewStyleArrowProgress;
    }
    else {
        self.draggingProgressView.style = SJVideoPlayerDraggingProgressViewStylePreviewProgress;
    }
    
    UIView_Animations(CommonAnimaDuration, ^{
        [self.draggingProgressView appear];
    }, nil);
    
    _draggingProgressView.maxValue = _videoPlayer.totalTime?:1;
    _draggingProgressView.currentTime = _videoPlayer.progress;
    _draggingProgressView.progressTime = _videoPlayer.progress;
    [_draggingProgressView setProgressTimeStr:_videoPlayer.currentTimeStr totalTimeStr:_videoPlayer.totalTimeStr];
}

/// 拖拽中
- (void)_draggingForVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer progressTime:(NSTimeInterval)progressTime {
    _draggingProgressView.progressTime = progressTime;
    [_draggingProgressView setProgressTimeStr:[videoPlayer timeStringWithSeconds:progressTime]];
    
    // 生成预览图
    if ( _draggingProgressView.style == SJVideoPlayerDraggingProgressViewStylePreviewProgress ) {
        __weak typeof(self) _self = self;
        [self.videoPlayer screenshotWithTime:progressTime size:CGSizeMake(_draggingProgressView.frame.size.width * 2, _draggingProgressView.frame.size.height * 2) completion:^(SJBaseVideoPlayer * _Nonnull videoPlayer, UIImage * _Nullable image, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.draggingProgressView setPreviewImage:image];
        }];
    }
}

/// 拖拽结束
- (void)_draggingDidEnd:(__kindof SJBaseVideoPlayer *)videoPlayer {
    UIView_Animations(CommonAnimaDuration, ^{
        [self.draggingProgressView disappear];
    }, nil);
    
    __weak typeof(self) _self = self;
    [self.videoPlayer seekToTime:self.draggingProgressView.progressTime completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.videoPlayer play];
    }];
}

#pragma mark - dragging progress view
- (SJVideoPlayerDraggingProgressView *)draggingProgressView {
    if ( _draggingProgressView ) return _draggingProgressView;
    _draggingProgressView = [SJVideoPlayerDraggingProgressView new];
    return _draggingProgressView;
}

#pragma mark - loading view
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

#pragma mark -
- (SJVideoPlayerControlMaskView *)topMaskView {
    if ( _topMaskView ) return _topMaskView;
    _topMaskView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_top];
    return _topMaskView;
}
- (SJVideoPlayerControlMaskView *)bottomMaskView {
    if ( _bottomMaskView ) return _bottomMaskView;
    _bottomMaskView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_bottom];
    return _bottomMaskView;
}
- (UIView *)containerView {
    if ( _containerView ) return _containerView;
    _containerView = [UIView new];
    _containerView.clipsToBounds = YES;
    return _containerView;
}
- (UIButton *)backBtn {
    if ( _backBtn ) return _backBtn;
    _backBtn = [SJUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:0];
    return _backBtn;
}
- (void)clickedBtn:(UIButton *)btn {
    [self clickedBackBtnOnTopControlView:self.topControlView];
}
- (SJProgressSlider *)bottomSlider {
    if ( _bottomSlider ) return _bottomSlider;
    _bottomSlider = [SJProgressSlider new];
    _bottomSlider.pan.enabled = NO;
    _bottomSlider.trackHeight = 1;
    return _bottomSlider;
}
- (void)controlViewLoadSetting {
    // load setting
    SJEdgeControlLayerSettings.update(^(SJEdgeControlLayerSettings * _Nonnull commonSettings) {});
    
    __weak typeof(self) _self = self;
    self.controlView.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.backBtn setImage:setting.backBtnImage forState:UIControlStateNormal];
        self.bottomSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.bottomSlider.trackImageView.backgroundColor = setting.progress_bufferColor;
        [self.draggingProgressView setPreviewImage:setting.placeholder];
        if ( self.enableFilmEditing ) self.rightControlView.filmEditingBtnImage = setting.filmEditingBtnImage;
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

#pragma mark - film editing

- (SJLightweightRightControlView *)rightControlView {
    if ( _rightControlView ) return _rightControlView;
    _rightControlView = [SJLightweightRightControlView new];
    _rightControlView.delegate = self;
    _rightControlView.filmEditingBtnImage = self.settings.filmEditingBtnImage;
    return _rightControlView;
}

- (void)rightControlView:(SJLightweightRightControlView *)view clickedBtnTag:(SJLightweightRightControlViewTag)tag {
    if ( tag == SJLightweightRightControlViewTag_FilmEditing ) {
        if ( [self.delegate respondsToSelector:@selector(clickedFilmEditingBtnOnLightweightControlLayer:)] ) {
            [self.delegate clickedFilmEditingBtnOnLightweightControlLayer:self];
        }
    }
}

- (void)setEnableFilmEditing:(BOOL)enableFilmEditing {
    if ( enableFilmEditing == _enableFilmEditing ) return;
    _enableFilmEditing = enableFilmEditing;
    if ( enableFilmEditing ) {
        [self.containerView insertSubview:self.rightControlView aboveSubview:self.bottomControlView];
        _rightControlView.hidden = self.videoPlayer.URLAsset.isM3u8;
        [_rightControlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.offset(0);
            make.centerY.offset(0);
        }];
        _rightControlView.disappearType = SJDisappearType_Alpha;
        
        if ( !self.videoPlayer.controlLayerIsAppeared ) [_rightControlView disappear];
    }
    else {
        [_rightControlView removeFromSuperview];
        _rightControlView = nil;
    }
}

- (void)setHideBackButtonWhenOrientationIsPortrait:(BOOL)hideBackButtonWhenOrientationIsPortrait {
    if ( hideBackButtonWhenOrientationIsPortrait == _hideBackButtonWhenOrientationIsPortrait ) return;
    _hideBackButtonWhenOrientationIsPortrait = hideBackButtonWhenOrientationIsPortrait;
    _backBtn.hidden = hideBackButtonWhenOrientationIsPortrait;
    _topControlView.config.hideBackButtonWhenOrientationIsPortrait = hideBackButtonWhenOrientationIsPortrait;
    [_topControlView needUpdateConfig];
}
@end
NS_ASSUME_NONNULL_END
