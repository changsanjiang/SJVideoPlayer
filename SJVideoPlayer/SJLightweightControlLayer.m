//
//  SJLightweightControlLayer.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJLightweightControlLayer.h"
#import "SJLightweightTopControlView.h"
#import "SJLightweightLeftControlView.h"
#import "SJLightweightBottomControlView.h"
#import "SJLightweightCenterControlView.h"
#import <Masonry/Masonry.h>
#import "UIView+SJControlAdd.h"
#import "SJVideoPlayerAnimationHeader.h"
#import "SJVideoPlayerControlMaskView.h"
#import "SJVideoPlayer.h"
#import "SJVideoPlayerDraggingProgressView.h"
#import <SJLoadingView/SJLoadingView.h>
#import "UIView+SJVideoPlayerSetting.h"
#import <SJSlider/SJSlider.h>
#import "UIView+SJVideoPlayerSetting.h"
#import <SJUIFactory/SJUIFactory.h>
#import <SJBaseVideoPlayer/SJTimerControl.h>

NS_ASSUME_NONNULL_BEGIN


@interface SJLightweightControlLayer () <SJLightweightBottomControlViewDelegate, SJLightweightLeftControlViewDelegate, SJLightweightTopControlViewDelegate, SJLightweightCenterControlViewDelegate> {
    UIView *_controlView;
    SJVideoPlayerDraggingProgressView *_draggingProgressView;
    SJLoadingView *_loadingView;
    SJSlider *_bottomSlider;
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

@property (nonatomic, weak, nullable) SJVideoPlayer *videoPlayer;   // need weak ref.
@property (nonatomic, strong, readonly) SJLoadingView *loadingView;
@property (nonatomic, strong, readonly) SJSlider *bottomSlider;
@property (nonatomic, strong, nullable) SJVideoPlayerSettings *settings;
@property (nonatomic, strong, readonly) SJTimerControl *lockStateTappedTimerControl;
@property (nonatomic, strong, readonly) UIButton *backBtn;

@end

@implementation SJLightweightControlLayer
@synthesize topMaskView = _topMaskView;
@synthesize bottomMaskView = _bottomMaskView;
@synthesize topControlView = _topControlView;
@synthesize leftControlView = _leftControlView;
@synthesize bottomControlView = _bottomControlView;
@synthesize backBtn = _backBtn;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self setupViews];
    [self controlViewLoadSetting];
    return self;
}


- (void)videoPlayer:(SJVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset {
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
    self.topControlView.topItems = videoPlayer.topControlItems;
    self.topControlView.model.isPlayOnScrollView = videoPlayer.isPlayOnScrollView;
    self.topControlView.model.alwaysShowTitle = asset.alwaysShowTitle;
    self.topControlView.model.title = asset.title;
    [self.topControlView needUpdateLayout];
    
    self.bottomSlider.value = 0;
    self.bottomControlView.progress = 0;
    self.bottomControlView.bufferProgress = 0;
    [self.bottomControlView setCurrentTimeStr:videoPlayer.currentTimeStr totalTimeStr:videoPlayer.totalTimeStr];
}

- (BOOL)controlLayerDisappearCondition {
    return YES;
}

- (BOOL)triggerGesturesCondition:(CGPoint)location {
    return YES;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _videoPlayer = videoPlayer;
}

- (void)controlLayerNeedAppear:(nonnull __kindof SJBaseVideoPlayer *)videoPlayer {
    UIView_Animations(CommonAnimaDuration, ^{
        if ( videoPlayer.isFullScreen ) [_backBtn appear];
        
        if ( SJVideoPlayerPlayState_PlayFailed == videoPlayer.state ) {
            [_centerControlView failedState];
            [_centerControlView appear];
            [_topControlView appear];
            [_leftControlView disappear];
            [_bottomControlView disappear];
        }
        else {
            [_topControlView appear];
            if ( videoPlayer.isFullScreen ) [_leftControlView appear];
            else [_leftControlView disappear];
            [_bottomControlView appear];
            [_bottomSlider disappear];
            
            
            // top
            if ( videoPlayer.isPlayOnScrollView && !videoPlayer.isFullScreen ) {
                if ( videoPlayer.URLAsset.alwaysShowTitle ) [_topControlView appear];
                else [_topControlView disappear];
            }
            else [_topControlView appear];
            
            [_bottomControlView appear];
            
            if ( videoPlayer.isFullScreen ) [_leftControlView appear];
            else [_leftControlView disappear];  // 如果是小屏, 则不显示锁屏按钮
            
            [_bottomSlider disappear];
            
            if ( videoPlayer.state != SJVideoPlayerPlayState_PlayEnd ) [_centerControlView disappear];
        }
    }, nil);
}

- (void)controlLayerNeedDisappear:(nonnull __kindof SJBaseVideoPlayer *)videoPlayer {
    UIView_Animations(CommonAnimaDuration, ^{
        if ( videoPlayer.isFullScreen ) [_backBtn disappear];
        
        if ( SJVideoPlayerPlayState_PlayFailed != videoPlayer.state ) {
            [_topControlView disappear];
            [_bottomControlView disappear];
            if ( !videoPlayer.isLockedScreen ) [_leftControlView disappear];
            else [_leftControlView appear];
            [_bottomSlider appear];
        }
        else {
            [_topControlView appear];
            [_leftControlView disappear];
            [_bottomControlView disappear];
        }
    }, nil);
}

- (void)videoPlayerWillAppearInScrollView:(SJVideoPlayer *)videoPlayer {
    videoPlayer.view.hidden = NO;
}

- (void)videoPlayerWillDisappearInScrollView:(SJVideoPlayer *)videoPlayer {
    [videoPlayer pause];
    videoPlayer.view.hidden = YES;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer stateChanged:(SJVideoPlayerPlayState)state {
    switch ( state ) {
        case SJVideoPlayerPlayState_Unknown: {
            [videoPlayer controlLayerNeedDisappear];
            self.topControlView.model.title = nil;
            [self.topControlView needUpdateLayout];
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
            self.bottomControlView.stopped = YES;
        }
            break;
        case SJVideoPlayerPlayState_Playing: {
            self.bottomControlView.stopped = NO;
        }
            break;
        case SJVideoPlayerPlayState_Buffing: {
            if ( self.centerControlView.appearState ) {
                UIView_Animations(CommonAnimaDuration, ^{
                    [self.centerControlView disappear];
                }, nil);
            }
        }
            break;
    }

    if ( SJVideoPlayerPlayState_PlayEnd ==  state ) {
        UIView_Animations(CommonAnimaDuration, ^{
            [self.centerControlView appear];
            [self.centerControlView replayState];
        }, nil);
    }
}

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer
        currentTime:(NSTimeInterval)currentTime currentTimeStr:(NSString *)currentTimeStr
          totalTime:(NSTimeInterval)totalTime totalTimeStr:(NSString *)totalTimeStr {
    [self.bottomControlView setCurrentTimeStr:currentTimeStr totalTimeStr:totalTimeStr];
    float progress = videoPlayer.progress;
    self.bottomSlider.value = progress;
    self.bottomControlView.progress = progress;
    if ( self.draggingProgressView.appearState ) self.draggingProgressView.playProgress = progress;
}

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer loadedTimeProgress:(float)progress {
    self.bottomControlView.bufferProgress = progress;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull {
    if ( _backBtn ) {
        if ( videoPlayer.isFullScreen ) [_backBtn disappear];
        else if ( !videoPlayer.isPlayOnScrollView ) [_backBtn appear];
        else [_backBtn disappear];
    }
    
    
    if ( isFull && !videoPlayer.URLAsset.isM3u8 ) {
        _draggingProgressView.style = SJVideoPlayerDraggingProgressViewStylePreviewProgress;
    }
    else {
        _draggingProgressView.style = SJVideoPlayerDraggingProgressViewStyleArrowProgress;
    }
    
    _topControlView.isFullscreen = isFull;
    [_topControlView needUpdateLayout];
    
    UIView_Animations(CommonAnimaDuration, ^{
        [self.controlView layoutIfNeeded];
    }, nil);
    
    if ( videoPlayer.controlLayerAppeared ) [videoPlayer controlLayerNeedAppear]; // update
    
    if ( isFull ) {
        // `iPhone_X` remake constraints.
        if ( SJ_is_iPhoneX() ) {
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.offset(0);
                make.height.equalTo(self.containerView.superview);
                make.width.equalTo(self.containerView.mas_height).multipliedBy(16 / 9.0f);
            }];
        }
    }
    else {
        // `iPhone_X` remake constraints.
        if ( SJ_is_iPhoneX() ) {
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.offset(0);
            }];
        }
    }
}

- (void)horizontalDirectionWillBeginDragging:(SJVideoPlayer *)videoPlayer {
    [self sliderWillBeginDraggingForBottomView:self.bottomControlView];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer horizontalDirectionDidMove:(CGFloat)progress {
    [self bottomView:self.bottomControlView sliderDidDrag:progress];
}

- (void)horizontalDirectionDidEndDragging:(SJVideoPlayer *)videoPlayer {
    [self sliderDidEndDraggingForBottomView:self.bottomControlView];
}

- (void)startLoading:(SJVideoPlayer *)videoPlayer {
    [self.loadingView start];
}

- (void)cancelLoading:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self.loadingView stop];
}

- (void)loadCompletion:(SJVideoPlayer *)videoPlayer {
    [self.loadingView stop];
}

- (void)lockedVideoPlayer:(SJVideoPlayer *)videoPlayer {
    _leftControlView.lockState = YES;
    [self.lockStateTappedTimerControl start];
    [videoPlayer controlLayerNeedDisappear];
}

- (void)unlockedVideoPlayer:(SJVideoPlayer *)videoPlayer {
    _leftControlView.lockState = NO;
    [self.lockStateTappedTimerControl clear];
    [videoPlayer controlLayerNeedAppear];
}

- (void)tappedPlayerOnTheLockedState:(__kindof SJBaseVideoPlayer *)videoPlayer {
    UIView_Animations(CommonAnimaDuration, ^{
        if ( _leftControlView.appearState ) [_leftControlView disappear];
        else [_leftControlView appear];
    }, nil);
    if ( _leftControlView.appearState ) [_lockStateTappedTimerControl start];
    else [_lockStateTappedTimerControl clear];
}
#pragma mark - Network
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer reachabilityChanged:(SJNetworkStatus)status {
    [self _promptWithNetworkStatus:status];
}

- (void)_promptWithNetworkStatus:(SJNetworkStatus)status {
    if ( self.videoPlayer.disableNetworkStatusChangePrompt ) return;
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
    if ( _videoPlayer.clickedTopControlItemExeBlock ) _videoPlayer.clickedTopControlItemExeBlock(_videoPlayer, item);
}
- (void)clickedBackBtnOnTopControlView:(SJLightweightTopControlView *)view {
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
    if ( _videoPlayer.clickedBackEvent ) _videoPlayer.clickedBackEvent(_videoPlayer);
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
    return _bottomControlView;
}
- (void)bottomControlView:(SJLightweightBottomControlView *)bottomControlView clickedViewTag:(SJLightweightBottomControlViewTag)tag {
    switch ( tag ) {
        case SJLightweightBottomControlViewTag_Full: {
            [_videoPlayer rotation];
        }
            break;
        case SJLightweightBottomControlViewTag_Play: {
            if ( _videoPlayer.state == SJVideoPlayerPlayState_PlayEnd ) [_videoPlayer replay];
            else [_videoPlayer play];
        }
            break;
        case SJLightweightBottomControlViewTag_Pause: {
            [_videoPlayer pauseForUser];
        }
            break;
    }
}
- (void)sliderWillBeginDraggingForBottomView:(SJLightweightBottomControlView *)view {
    UIView_Animations(CommonAnimaDuration, ^{
        [self.draggingProgressView appear];
    }, nil);
    [self.draggingProgressView setTimeShiftStr:self.videoPlayer.currentTimeStr totalTimeStr:self.videoPlayer.totalTimeStr];
    [_videoPlayer controlLayerNeedDisappear];
    self.draggingProgressView.playProgress = self.videoPlayer.progress;
    self.draggingProgressView.shiftProgress = self.videoPlayer.progress;
}

- (void)bottomView:(SJLightweightBottomControlView *)view sliderDidDrag:(CGFloat)progress {
    self.draggingProgressView.shiftProgress = progress;
    [self.draggingProgressView setTimeShiftStr:[self.videoPlayer timeStringWithSeconds:self.draggingProgressView.shiftProgress * self.videoPlayer.totalTime]];
    if ( self.videoPlayer.isFullScreen && !self.videoPlayer.URLAsset.isM3u8 ) {
        NSTimeInterval secs = self.draggingProgressView.shiftProgress * self.videoPlayer.totalTime;
        __weak typeof(self) _self = self;
        [self.videoPlayer screenshotWithTime:secs size:CGSizeMake(self.draggingProgressView.frame.size.width * 2, self.draggingProgressView.frame.size.height * 2) completion:^(SJVideoPlayer * _Nonnull videoPlayer, UIImage * _Nullable image, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.draggingProgressView setPreviewImage:image];
        }];
    }
}

- (void)sliderDidEndDraggingForBottomView:(SJLightweightBottomControlView *)view {
    UIView_Animations(CommonAnimaDuration, ^{
        [self.draggingProgressView disappear];
    }, nil);

    __weak typeof(self) _self = self;
    [self.videoPlayer jumpedToTime:self.draggingProgressView.shiftProgress * self.videoPlayer.totalTime completionHandler:^(BOOL finished) {
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
    _loadingView.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJVideoPlayerSettings * _Nonnull setting) {
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
- (SJSlider *)bottomSlider {
    if ( _bottomSlider ) return _bottomSlider;
    _bottomSlider = [SJSlider new];
    _bottomSlider.pan.enabled = NO;
    _bottomSlider.trackHeight = 1;
    return _bottomSlider;
}
- (void)controlViewLoadSetting {
    // load setting
    SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {});
    
    __weak typeof(self) _self = self;
    self.controlView.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.backBtn setImage:setting.backBtnImage forState:UIControlStateNormal];
        self.bottomSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.bottomSlider.trackImageView.backgroundColor = setting.progress_bufferColor;
        self.videoPlayer.placeholder = setting.placeholder;
        [self.draggingProgressView setPreviewImage:setting.placeholder];
        self.settings = setting;
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
NS_ASSUME_NONNULL_END
