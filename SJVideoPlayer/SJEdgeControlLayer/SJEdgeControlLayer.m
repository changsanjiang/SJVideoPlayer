//
//  SJEdgeControlLayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/24.
//  Copyright © 2018 畅三江. All rights reserved.
//

#if __has_include(<SJUIKit/SJAttributesFactory.h>)
#import <SJUIKit/SJAttributesFactory.h>
#else
#import "SJAttributesFactory.h"
#endif

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <SJBaseVideoPlayer/SJTimerControl.h>
#else
#import "SJBaseVideoPlayer.h"
#import "SJTimerControl.h"
#endif

#import "SJEdgeControlLayer.h"
#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import "SJVideoPlayerDraggingProgressView.h"
#import "SJVideoPlayerAnimationHeader.h"
#import "UIView+SJVideoPlayerSetting.h"
#import "UIView+SJAnimationAdded.h"
#import "SJProgressSlider.h"
#import "SJNetworkLoadingView.h"

#pragma mark - Top
SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_Back = 10000;
SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_Title = 10001;
static SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_PlaceholderBack = 10002;

#pragma mark - Left
SJEdgeControlButtonItemTag const SJEdgeControlLayerLeftItem_Lock = 20000;

#pragma mark - bottom
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Play = 30000;
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_CurrentTime = 30001;
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_DurationTime = 30002;
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Separator = 30003;
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Progress = 30004;
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_FullBtn = 30005;
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_LIVEText = 30006;

#pragma mark - center
SJEdgeControlButtonItemTag const SJEdgeControlLayerCenterItem_Replay = 40000;


@interface SJEdgeControlLayer ()<SJProgressSliderDelegate>
@property (nonatomic, weak, nullable) SJBaseVideoPlayer *videoPlayer;

@property (nonatomic, strong, readonly) SJTimerControl *lockStateTappedTimerControl;
@property (nonatomic, strong, readonly) SJVideoPlayerDraggingProgressView *draggingProgressView;
@property (nonatomic, strong, readonly) SJProgressSlider *bottomProgressIndicator;

// back
@property (nonatomic, strong, readonly) UIButton *residentBackButton;
@property (nonatomic, strong, readonly) SJEdgeControlButtonItem *backItem;
@property (nonatomic, strong, nullable) id<SJReachabilityObserver> reachabilityObserver;

@property (nonatomic, strong, nullable) NSString *durationStr;
@end

@implementation SJEdgeControlLayer
@synthesize restarted = _restarted;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    _bottomProgressIndicatorHeight = 1;
    [self _setupView];
    self.autoAdjustTopSpacing = YES;
    self.hiddenBottomProgressIndicator = YES;
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark -

///
/// 切换器(player.switcher)重启该控制层
///
- (void)restartControlLayer {
    _restarted = YES;
    sj_view_makeAppear(self.controlView, YES);
    [self _showOrHiddenLoadingView];
    _videoPlayer.URLAsset != nil ? [_videoPlayer controlLayerNeedAppear] : [_videoPlayer controlLayerNeedDisappear];
}

///
/// 控制层退场
///
- (void)exitControlLayer {
    _restarted = NO;
    
    sj_view_makeDisappear(self.controlView, YES, ^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    });
    
    sj_view_makeDisappear(_topContainerView, YES);
    sj_view_makeDisappear(_leftContainerView, YES);
    sj_view_makeDisappear(_bottomContainerView, YES);
    sj_view_makeDisappear(_rightContainerView, YES);
    sj_view_makeDisappear(_draggingProgressView, YES);
    sj_view_makeDisappear(_centerContainerView, YES);
}

#pragma mark - item actions

- (void)_tappedResidentBackButton {
    SJEdgeControlButtonItem *backItem = [self.topAdapter itemForTag:SJEdgeControlLayerTopItem_Back];
    [backItem performAction];
}

- (void)_tappedBackItem {
    if ( [self.delegate respondsToSelector:@selector(backItemWasTappedForControlLayer:)] ) {
        [self.delegate backItemWasTappedForControlLayer:self];
    }
}

- (void)_tappedLockItem {
    self.videoPlayer.lockedScreen = !self.videoPlayer.isLockedScreen;
}

- (void)_tappedPlayItem {
    self.videoPlayer.timeControlStatus == SJPlaybackTimeControlStatusPaused ? [self.videoPlayer play] : [self.videoPlayer pause];
}

- (void)_tappedFullItem {
    _videoPlayer.useFitOnScreenAndDisableRotation ? _videoPlayer.fitOnScreen = !_videoPlayer.fitOnScreen : [self.videoPlayer rotate];
}

- (void)_tappedReplayItem {
    [_videoPlayer replay];
}

#pragma mark - setup view

- (void)_setupView {
    [self _addItemsToTopAdapter];
    [self _addItemsToLeftAdapter];
    [self _addItemsToBottomAdapter];
    [self _addItemsToRightAdapter];
    [self _addItemsToCenterAdapter];
    
    self.topContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Top;
    self.leftContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Left;
    self.bottomContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Bottom;
    self.rightContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
    self.centerContainerView.sjv_disappearDirection = SJViewDisappearAnimation_None;
    
    sj_view_initializes(@[self.topContainerView, self.leftContainerView,
                          self.bottomContainerView, self.rightContainerView]);
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_resetControlLayerAppearIntervalForItemIfNeeded:) name:SJEdgeControlButtonItemPerformedActionNotification object:nil];
}

- (void)_addItemsToTopAdapter {
    SJEdgeControlButtonItem *backItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerTopItem_Back];
    [backItem addTarget:self action:@selector(_tappedBackItem)];
    [self.topAdapter addItem:backItem];
    _backItem = backItem;

    SJEdgeControlButtonItem *titleItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49xFill tag:SJEdgeControlLayerTopItem_Title];
    [self.topAdapter addItem:titleItem];
    
    [self.topAdapter reload];
}

- (void)_addItemsToLeftAdapter {
    SJEdgeControlButtonItem *lockItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerLeftItem_Lock];
    [lockItem addTarget:self action:@selector(_tappedLockItem)];
    [self.leftAdapter addItem:lockItem];
    
    [self.leftAdapter reload];
}

- (void)_addItemsToBottomAdapter {
    // 播放按钮
    SJEdgeControlButtonItem *playItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerBottomItem_Play];
    [playItem addTarget:self action:@selector(_tappedPlayItem)];
    [self.bottomAdapter addItem:playItem];
    
    SJEdgeControlButtonItem *liveItem = [[SJEdgeControlButtonItem alloc] initWithTag:SJEdgeControlLayerBottomItem_LIVEText];
    liveItem.hidden = YES;
    [self.bottomAdapter addItem:liveItem];
    
    // 当前时间
    SJEdgeControlButtonItem *currentTimeItem = [SJEdgeControlButtonItem placeholderWithSize:8 tag:SJEdgeControlLayerBottomItem_CurrentTime];
    [self.bottomAdapter addItem:currentTimeItem];
    
    // 时间分隔符
    SJEdgeControlButtonItem *separatorItem = [[SJEdgeControlButtonItem alloc] initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"/ ").font([UIFont systemFontOfSize:11]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
    }] target:nil action:NULL tag:SJEdgeControlLayerBottomItem_Separator];
    [self.bottomAdapter addItem:separatorItem];
    
    // 全部时长
    SJEdgeControlButtonItem *durationTimeItem = [SJEdgeControlButtonItem placeholderWithSize:8 tag:SJEdgeControlLayerBottomItem_DurationTime];
    [self.bottomAdapter addItem:durationTimeItem];
    
    // 播放进度条
    SJProgressSlider *slider = [SJProgressSlider new];
    slider.trackHeight = 3;
    slider.delegate = self;
    slider.tap.enabled = YES;
    slider.enableBufferProgress = YES;
    __weak typeof(self) _self = self;
    slider.tappedExeBlock = ^(SJProgressSlider * _Nonnull slider, CGFloat location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.videoPlayer.canSeekToTime && self.videoPlayer.canSeekToTime(self.videoPlayer) == NO ) {
            return;
        }
        
        if ( self.videoPlayer.assetStatus != SJAssetStatusReadyToPlay ) {
            return;
        }
    
        [self.videoPlayer seekToTime:location completionHandler:nil];
    };
    SJEdgeControlButtonItem *progressItem = [[SJEdgeControlButtonItem alloc] initWithCustomView:slider tag:SJEdgeControlLayerBottomItem_Progress];
    progressItem.insets = SJEdgeInsetsMake(8, 8);
    progressItem.fill = YES;
    [self.bottomAdapter addItem:progressItem];

    // 全屏按钮
    SJEdgeControlButtonItem *fullItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerBottomItem_FullBtn];
    [fullItem addTarget:self action:@selector(_tappedFullItem)];
    [self.bottomAdapter addItem:fullItem];

    [self.bottomAdapter reload];
}

- (void)_addItemsToRightAdapter {
    
}

- (void)_addItemsToCenterAdapter {
    UILabel *replayLabel = [UILabel new];
    replayLabel.numberOfLines = 0;
    SJEdgeControlButtonItem *replayItem = [SJEdgeControlButtonItem frameLayoutWithCustomView:replayLabel tag:SJEdgeControlLayerCenterItem_Replay];
    [replayItem addTarget:self action:@selector(_tappedReplayItem)];
    [self.centerAdapter addItem:replayItem];
    [self.centerAdapter reload];
}

#pragma mark - resident Back Button

@synthesize residentBackButton = _residentBackButton;
- (UIButton *)residentBackButton {
    if ( _residentBackButton ) return _residentBackButton;
    _residentBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_residentBackButton setImage:SJEdgeControlLayerSettings.commonSettings.backBtnImage forState:UIControlStateNormal];
    [_residentBackButton addTarget:self action:@selector(_tappedResidentBackButton) forControlEvents:UIControlEventTouchUpInside];
    return _residentBackButton;
}

- (void)setShowResidentBackButton:(BOOL)showResidentBackButton {
    if ( showResidentBackButton == _showResidentBackButton )
        return;
    _showResidentBackButton = showResidentBackButton;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( self->_showResidentBackButton ) {
            [self.controlView addSubview:self.residentBackButton];
            [self->_residentBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.bottom.equalTo(self.topAdapter.view);
                make.width.equalTo(self.topAdapter.view.mas_height);
            }];
            
            // placeholder item
            SJEdgeControlButtonItem *placeholderItem = [self.topAdapter itemForTag:SJEdgeControlLayerTopItem_PlaceholderBack];
            if ( !placeholderItem ) {
                placeholderItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerTopItem_PlaceholderBack];
            }
            [self.topAdapter removeItemForTag:SJEdgeControlLayerTopItem_Back];
            [self.topAdapter insertItem:placeholderItem atIndex:0];
            [self _updateResidentBackButtonAppearStateIfNeeded];
            [self.topAdapter reload];
        }
        else {
            if ( self->_residentBackButton ) {
                [self->_residentBackButton removeFromSuperview];
                self->_residentBackButton = nil;
                
                // back item
                [self.topAdapter removeItemForTag:SJEdgeControlLayerTopItem_PlaceholderBack];
                [self.topAdapter insertItem:self.backItem atIndex:0];
                [self.topAdapter reload];
            }
        }
    });
}

#pragma mark - bottom progress slider delegate

- (void)sliderWillBeginDragging:(SJProgressSlider *)slider {
    if ( _videoPlayer.assetStatus != SJAssetStatusReadyToPlay ) {
        [slider cancelDragging];
        return;
    }
    else if ( _videoPlayer.canSeekToTime && !_videoPlayer.canSeekToTime(_videoPlayer) ) {
        [slider cancelDragging];
        return;
    }
    
    [self _onDragStart];
}

- (void)slider:(SJProgressSlider *)slider valueDidChange:(CGFloat)value {
    if ( slider.isDragging ) [self _onDragMoving:value];
}

- (void)sliderDidEndDragging:(SJProgressSlider *)slider {
    [self _onDragMoveEnd];
}

#pragma mark - bottom progress indicator

@synthesize bottomProgressIndicator = _bottomProgressIndicator;
- (SJProgressSlider *)bottomProgressIndicator {
    if ( _bottomProgressIndicator ) return _bottomProgressIndicator;
    _bottomProgressIndicator = [SJProgressSlider new];
    _bottomProgressIndicator.pan.enabled = NO;
    _bottomProgressIndicator.trackHeight = _bottomProgressIndicatorHeight;
    SJEdgeControlLayerSettings *setting = SJEdgeControlLayerSettings.commonSettings;
    UIColor *traceColor = setting.bottomIndicator_traceColor ?: setting.progress_traceColor;
    UIColor *trackColor = setting.bottomIndicator_trackColor ?: setting.progress_trackColor;
    _bottomProgressIndicator.traceImageView.backgroundColor = traceColor;
    _bottomProgressIndicator.trackImageView.backgroundColor = trackColor;
    return _bottomProgressIndicator;
}

- (void)setHiddenBottomProgressIndicator:(BOOL)hiddenBottomProgressIndicator {
    if ( hiddenBottomProgressIndicator != _hiddenBottomProgressIndicator ) {
        _hiddenBottomProgressIndicator = hiddenBottomProgressIndicator;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _showOrRemoveBottomProgressIndicator];
        });
    }
}

- (void)setBottomProgressIndicatorHeight:(CGFloat)bottomProgressIndicatorHeight {
    if ( bottomProgressIndicatorHeight != _bottomProgressIndicatorHeight ) {
        
        _bottomProgressIndicatorHeight = bottomProgressIndicatorHeight;
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_bottomProgressIndicator.trackHeight = bottomProgressIndicatorHeight;
            [self->_bottomProgressIndicator mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.offset(bottomProgressIndicatorHeight);
            }];
        });
    }
}

#pragma mark - loading view

- (void)setLoadingView:(nullable id<SJEdgeControlLayerLoadingViewProtocol>)loadingView {
    if ( loadingView != _loadingView ) {
        [(UIView *)_loadingView removeFromSuperview];
        _loadingView = loadingView;
        
        if ( loadingView ) {
            [self.controlView addSubview:(UIView *)loadingView];
            [(UIView *)loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.offset(0);
            }];
        }
    }
}

@synthesize loadingView = _loadingView;
- (id<SJEdgeControlLayerLoadingViewProtocol>)loadingView {
    if ( _loadingView ) return _loadingView;
    _loadingView = [SJNetworkLoadingView new];
    _loadingView.lineColor = SJEdgeControlLayerSettings.commonSettings.loadingLineColor;
    [self.controlView addSubview:(UIView *)_loadingView];
    [(UIView *)_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    return _loadingView;
}

- (void)setShowNetworkSpeedToLoadingView:(BOOL)showNetworkSpeedToLoadingView {
    _showNetworkSpeedToLoadingView = showNetworkSpeedToLoadingView;
    if ( !showNetworkSpeedToLoadingView )
        self.loadingView.networkSpeedStr = nil;
}

#pragma mark - dragging progress view

@synthesize draggingProgressView = _draggingProgressView;
- (SJVideoPlayerDraggingProgressView *)draggingProgressView {
    if ( _draggingProgressView ) return _draggingProgressView;
    _draggingProgressView = [SJVideoPlayerDraggingProgressView new];
    [_draggingProgressView setPreviewImage:_videoPlayer.presentView.placeholderImageView.image];
    sj_view_makeDisappear(_draggingProgressView, NO);
    return _draggingProgressView;
}

#pragma mark - player delegate methods

- (UIView *)controlView {
    return self;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _videoPlayer = videoPlayer;
    sj_view_makeDisappear(_topContainerView, NO);
    sj_view_makeDisappear(_leftContainerView, NO);
    sj_view_makeDisappear(_bottomContainerView, NO);
    sj_view_makeDisappear(_rightContainerView, NO);
    sj_view_makeDisappear(_centerContainerView, NO);
    
    [self _updateBottomTimeLabelSize];
    [self _updateBottomCurrentTimeItemIfNeeded];
    [self _updateBottomDurationItemIfNeeded];
    
    _reachabilityObserver = [videoPlayer.reachability getObserver];
    __weak typeof(self) _self = self;
    _reachabilityObserver.networkSpeedDidChangeExeBlock = ^(id<SJReachability> r) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateNetworkSpeedStrForLoadingView];
    };
}

///
/// 当播放器尝试自动隐藏控制层之前 将会调用这个方法
///
- (BOOL)controlLayerOfVideoPlayerCanAutomaticallyDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    SJEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
    SJProgressSlider *slider = progressItem.customView;
    return !slider.isDragging;
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( videoPlayer.isLockedScreen )
        return;
    
    [self _updateResidentBackButtonAppearStateIfNeeded];
    [self _updateContainerViewsAppearState];
    [self _updateAdaptersIfNeeded];
    [self _updateBottomCurrentTimeItemIfNeeded];
    [self _updateBottomProgressSliderItemIfNeeded];
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( videoPlayer.isLockedScreen )
        return;
    
    [self _updateResidentBackButtonAppearStateIfNeeded];
    [self _updateContainerViewsAppearState];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset {
    [self _updateBottomTimeLabelSize];
    [self _updateBottomDurationItemIfNeeded];
    [self _updateBottomCurrentTimeItemIfNeeded];
    [self _updateBottomProgressIndicatorIfNeeded];
    [self _updateResidentBackButtonAppearStateIfNeeded];
    [self _updateAdaptersIfNeeded];
    [self _showOrHiddenLoadingView];
}

- (void)videoPlayerPlaybackStatusDidChange:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _updateAdaptersIfNeeded];
    [self _showOrHiddenLoadingView];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer currentTimeDidChange:(NSTimeInterval)currentTime {
    [self _updateBottomCurrentTimeItemIfNeeded];
    [self _updateBottomProgressIndicatorIfNeeded];
    [self _updateBottomProgressSliderItemIfNeeded];
    [self _updateDraggingProgressViewCurrentTimeIfNeeded];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer durationDidChange:(NSTimeInterval)duration {
    [self _updateBottomTimeLabelSize];
    [self _updateBottomDurationItemIfNeeded];
    [self _updateBottomProgressIndicatorIfNeeded];
    [self _updateBottomProgressSliderItemIfNeeded];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer playableDurationDidChange:(NSTimeInterval)duration {
    [self _updateBottomProgressSliderItemIfNeeded];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer playbackTypeDidChange:(SJPlaybackType)playbackType {
    SJEdgeControlButtonItem *currentTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_CurrentTime];
    SJEdgeControlButtonItem *separatorItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Separator];
    SJEdgeControlButtonItem *durationTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    SJEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
    SJEdgeControlButtonItem *liveItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_LIVEText];
    switch ( playbackType ) {
        case SJPlaybackTypeLIVE: {
            currentTimeItem.hidden = YES;
            separatorItem.hidden = YES;
            durationTimeItem.hidden = YES;
            progressItem.hidden = YES;
            liveItem.hidden = NO;
        }
            break;
        case SJPlaybackTypeUnknown:
        case SJPlaybackTypeVOD:
        case SJPlaybackTypeFILE: {
            currentTimeItem.hidden = NO;
            separatorItem.hidden = NO;
            durationTimeItem.hidden = NO;
            progressItem.hidden = NO;
            liveItem.hidden = YES;
            [_bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_LIVEText];
        }
            break;
    }
    [self.bottomAdapter reload];
    [self _showOrRemoveBottomProgressIndicator];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull {
    [self _updateResidentBackButtonAppearStateIfNeeded];
    [self _updateContainerViewsAppearState];
    [self _updateAdaptersIfNeeded];
    
    if ( !sj_view_isDisappeared(_bottomProgressIndicator) ) {
        sj_view_makeDisappear(_bottomProgressIndicator, NO);
    }
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer didEndRotation:(BOOL)isFull {
    if ( !videoPlayer.isControlLayerAppeared )
        sj_view_makeAppear(_bottomProgressIndicator, YES);
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willFitOnScreen:(BOOL)isFitOnScreen {
    [self _updateResidentBackButtonAppearStateIfNeeded];
    [self _updateContainerViewsAppearState];
    [self _updateAdaptersIfNeeded];
    
    if ( !sj_view_isDisappeared(_bottomProgressIndicator) ) {
        sj_view_makeDisappear(_bottomProgressIndicator, NO);
    }
}

/// 是否可以触发播放器的手势
- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    SJEdgeControlLayerItemAdapter *adapter = nil;
    BOOL(^_locationInTheView)(UIView *) = ^BOOL(UIView *container) {
        return CGRectContainsPoint(container.frame, location) && !sj_view_isDisappeared(container);
    };
    
    if ( _locationInTheView(_topContainerView) ) {
        adapter = _topAdapter;
    }
    else if ( _locationInTheView(_bottomContainerView) ) {
        adapter = _bottomAdapter;
    }
    else if ( _locationInTheView(_leftContainerView) ) {
        adapter = _leftAdapter;
    }
    else if ( _locationInTheView(_rightContainerView) ) {
        adapter = _rightAdapter;
    }
    else if ( _locationInTheView(_centerContainerView) ) {
        adapter = _centerAdapter;
    }
    if ( !adapter ) return YES;
    
    CGPoint point = [self.controlView convertPoint:location toView:adapter.view];
    if ( !CGRectContainsPoint(adapter.view.frame, point) ) return YES;
    
    SJEdgeControlButtonItem *_Nullable item = [adapter itemAtPoint:point];
    return [item.target respondsToSelector:item.action];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer panGestureTriggeredInTheHorizontalDirection:(SJPanGestureRecognizerState)state progressTime:(NSTimeInterval)progressTime {
    switch ( state ) {
        case SJPanGestureRecognizerStateBegan:
            [self _onDragStart];
            break;
        case SJPanGestureRecognizerStateChanged:
            [self _onDragMoving:progressTime];
            break;
        case SJPanGestureRecognizerStateEnded:
            [self _onDragMoveEnd];
            break;
    }
}

/// 这是一个只有在播放器锁屏状态下, 才会回调的方法
/// 当播放器锁屏后, 用户每次点击都会回调这个方法
- (void)tappedPlayerOnTheLockedState:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( sj_view_isDisappeared(_leftContainerView) ) {
        sj_view_makeAppear(_leftContainerView, YES);
        [self.lockStateTappedTimerControl start];
    }
    else {
        sj_view_makeDisappear(_leftContainerView, YES);
        [self.lockStateTappedTimerControl clear];
    }
}

- (void)lockedVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _updateResidentBackButtonAppearStateIfNeeded];
    [self _updateContainerViewsAppearState];
    [self _updateAdaptersIfNeeded];
    [self.lockStateTappedTimerControl start];
}

- (void)unlockedVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self.lockStateTappedTimerControl clear];
    [videoPlayer controlLayerNeedAppear];
}

- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer reachabilityChanged:(SJNetworkStatus)status {
    if ( _disabledPromptWhenNetworkStatusChanges ) return;
    if ( [self.videoPlayer.assetURL isFileURL] ) return; // return when is local video.
    
    switch ( status ) {
        case SJNetworkStatus_NotReachable: {
            [_videoPlayer.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(SJEdgeControlLayerSettings.commonSettings.notReachablePrompt);
                make.textColor(UIColor.whiteColor);
            }] duration:3];
        }
            break;
        case SJNetworkStatus_ReachableViaWWAN: {
            [_videoPlayer.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(SJEdgeControlLayerSettings.commonSettings.reachableViaWWANPrompt);
                make.textColor(UIColor.whiteColor);
            }] duration:3];
        }
            break;
        case SJNetworkStatus_ReachableViaWiFi: {}
            break;
    }
}

#pragma mark - lock screen

@synthesize lockStateTappedTimerControl = _lockStateTappedTimerControl;
- (SJTimerControl *)lockStateTappedTimerControl {
    if ( _lockStateTappedTimerControl ) return _lockStateTappedTimerControl;
    _lockStateTappedTimerControl = [[SJTimerControl alloc] init];
    __weak typeof(self) _self = self;
    _lockStateTappedTimerControl.exeBlock = ^(SJTimerControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        sj_view_makeDisappear(self.leftContainerView, YES);
        [control clear];
    };
    return _lockStateTappedTimerControl;
}


#pragma mark - appear state

- (void)_updateContainerViewsAppearState {
    [self _updateTopContainerViewAppearState];
    [self _updateLeftContainerViewAppearState];
    [self _updateBottomContainerViewAppearState];
    [self _updateRightContainerViewAppearState];
    [self _updateCenterContainerViewAppearState];
}

- (void)_updateTopContainerViewAppearState {
    if ( 0 == _topAdapter.itemCount ) {
        sj_view_makeDisappear(_topContainerView, YES);
        return;
    }
    
    /// 锁屏状态下, 使隐藏
    if ( _videoPlayer.isLockedScreen ) {
        sj_view_makeDisappear(_topContainerView, YES);
        return;
    }
    
    /// 是否显示
    if ( _videoPlayer.isControlLayerAppeared ) {
        sj_view_makeAppear(_topContainerView, YES);
    }
    else {
        sj_view_makeDisappear(_topContainerView, YES);
    }
}

- (void)_updateLeftContainerViewAppearState {
    if ( 0 == _leftAdapter.itemCount ) {
        sj_view_makeDisappear(_leftContainerView, YES);
        return;
    }
    
    /// 锁屏状态下显示
    if ( _videoPlayer.isLockedScreen ) {
        sj_view_makeAppear(_leftContainerView, YES);
        return;
    }
    
    /// 是否显示
    if ( _videoPlayer.isControlLayerAppeared ) {
        sj_view_makeAppear(_leftContainerView, YES);
    }
    else {
        sj_view_makeDisappear(_leftContainerView, YES);
    }
}

/// 更新显示状态
- (void)_updateBottomContainerViewAppearState {
    if ( 0 == _bottomAdapter.itemCount ) {
        sj_view_makeDisappear(_bottomContainerView, YES);
        return;
    }
    
    /// 锁屏状态下, 使隐藏
    if ( _videoPlayer.isLockedScreen ) {
        sj_view_makeDisappear(_bottomContainerView, YES);
        sj_view_makeAppear(_bottomProgressIndicator, YES);
        return;
    }
    
    /// 是否显示
    if ( _videoPlayer.isControlLayerAppeared ) {
        sj_view_makeAppear(_bottomContainerView, YES);
        sj_view_makeDisappear(_bottomProgressIndicator, YES);
    }
    else {
        sj_view_makeDisappear(_bottomContainerView, YES);
        sj_view_makeAppear(_bottomProgressIndicator, YES);
    }
}

/// 更新显示状态
- (void)_updateRightContainerViewAppearState {
    if ( 0 == _rightAdapter.itemCount ) {
        sj_view_makeDisappear(_rightContainerView, YES);
        return;
    }
    
    /// 锁屏状态下, 使隐藏
    if ( _videoPlayer.isLockedScreen ) {
        sj_view_makeDisappear(_rightContainerView, YES);
        return;
    }
    
    /// 是否显示
    if ( _videoPlayer.isControlLayerAppeared ) {
        sj_view_makeAppear(_rightContainerView, YES);
    }
    else {
        sj_view_makeDisappear(_rightContainerView, YES);
    }
}

- (void)_updateCenterContainerViewAppearState {
    if ( 0 == _centerAdapter.itemCount ) {
        sj_view_makeDisappear(_centerContainerView, YES);
        return;
    }
    
    sj_view_makeAppear(_centerContainerView, YES);
}


#pragma mark - update items

- (void)_updateAdaptersIfNeeded {
    [self _updateTopAdapterIfNeeded];
    [self _updateLeftAdapterIfNeeded];
    [self _updateBottomAdapterIfNeeded];
    [self _updateRightAdapterIfNeeded];
    [self _updateCenterAdapterIfNeeded];
}

- (void)_updateTopAdapterIfNeeded {
    if ( sj_view_isDisappeared(_topContainerView) ) return;
    SJEdgeControlLayerSettings *sources = SJEdgeControlLayerSettings.commonSettings;
    BOOL isFullscreen = _videoPlayer.isFullScreen;
    BOOL isFitOnScreen = _videoPlayer.isFitOnScreen;
    BOOL isPlayOnScrollView = _videoPlayer.isPlayOnScrollView;

    // back item
    {
        SJEdgeControlButtonItem *backItem = [self.topAdapter itemForTag:SJEdgeControlLayerTopItem_Back];
        if ( backItem != nil ) {
            if ( isFullscreen || isFitOnScreen )
                backItem.hidden = NO;
            else if ( _hiddenBackButtonWhenOrientationIsPortrait )
                backItem.hidden = YES;
            else
                backItem.hidden = isPlayOnScrollView;
            
            if ( backItem.hidden == NO )
                backItem.image = sources.backBtnImage;
        }
    }
    
    // title item
    {
        SJEdgeControlButtonItem *titleItem = [self.topAdapter itemForTag:SJEdgeControlLayerTopItem_Title];
        if ( titleItem != nil ) {
            SJVideoPlayerURLAsset *asset = _videoPlayer.URLAsset.originAsset ? : _videoPlayer.URLAsset;
            NSAttributedString *_Nullable attributedTitle = asset.attributedTitle;
            NSString *_Nullable title = asset.title;
            if ( attributedTitle.length != 0 ) {
                titleItem.title = attributedTitle;
            }
            else if ( title.length != 0 && ![titleItem.title.string isEqualToString:title] ) {
                titleItem.title = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                    make.append(title);
                    make.font(sources.titleFont);
                    make.textColor(sources.titleColor);
                    make.lineBreakMode(NSLineBreakByTruncatingTail);
                    make.shadow(^(NSShadow * _Nonnull make) {
                        make.shadowOffset = CGSizeMake(0, 0.5);
                        make.shadowColor = UIColor.blackColor;
                    });
                }];
            }
            
            titleItem.hidden = (titleItem.title.length == 0);

            if ( titleItem.hidden == NO ) {
                // margin
                NSInteger atIndex = [_topAdapter indexOfItemForTag:SJEdgeControlLayerTopItem_Title];
                CGFloat left  = [_topAdapter itemsIsHiddenWithRange:NSMakeRange(0, atIndex)] ? 16 : 0;
                CGFloat right = [_topAdapter itemsIsHiddenWithRange:NSMakeRange(atIndex, _topAdapter.itemCount)] ? 16 : 0;
                titleItem.insets = SJEdgeInsetsMake(left, right);
            }
        }
    }
    
    [_topAdapter reload];
}

- (void)_updateLeftAdapterIfNeeded {
    if ( sj_view_isDisappeared(_leftContainerView) ) return;
    
    BOOL isFullscreen = _videoPlayer.isFullScreen;
    BOOL isLockedScreen = _videoPlayer.isLockedScreen;

    SJEdgeControlButtonItem *lockItem = [self.leftAdapter itemForTag:SJEdgeControlLayerLeftItem_Lock];
    if ( lockItem != nil ) {
        lockItem.hidden = !isFullscreen;
        if ( lockItem.hidden == NO ) {
            SJEdgeControlLayerSettings *setting = SJEdgeControlLayerSettings.commonSettings;
            lockItem.image = isLockedScreen ? setting.lockBtnImage : setting.unlockBtnImage;
        }
    }
    
    [_leftAdapter reload];
}

- (void)_updateBottomAdapterIfNeeded {
    if ( sj_view_isDisappeared(_bottomContainerView) ) return;
    
    SJEdgeControlLayerSettings *sources = SJEdgeControlLayerSettings.commonSettings;
    
    // play item
    {
        SJEdgeControlButtonItem *playItem = [self.bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Play];
        if ( playItem != nil && playItem.hidden == NO ) {
            BOOL isPaused = _videoPlayer.timeControlStatus == SJPlaybackTimeControlStatusPaused;
            playItem.image = isPaused ? sources.playBtnImage : sources.pauseBtnImage;
        }
    }
    
    // progress item
    {
        SJEdgeControlButtonItem *progressItem = [self.bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
        if ( progressItem != nil && progressItem.hidden == NO ) {
            SJProgressSlider *slider = progressItem.customView;
            slider.traceImageView.backgroundColor = sources.progress_traceColor;
            slider.trackImageView.backgroundColor = sources.progress_trackColor;
            slider.bufferProgressColor = sources.progress_bufferColor;
            slider.trackHeight = sources.progress_traceHeight;
            slider.loadingColor = sources.loadingLineColor;
            
            if ( sources.progress_thumbImage ) {
                slider.thumbImageView.image = sources.progress_thumbImage;
            }
            else if ( sources.progress_thumbSize ) {
                [slider setThumbCornerRadius:sources.progress_thumbSize * 0.5 size:CGSizeMake(sources.progress_thumbSize, sources.progress_thumbSize) thumbBackgroundColor:sources.progress_thumbColor];
            }
        }
    }
    
    // full item
    {
        SJEdgeControlButtonItem *fullItem = [self.bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_FullBtn];
        if ( fullItem != nil && fullItem.hidden == NO ) {
            BOOL isFullscreen = _videoPlayer.isFullScreen;
            BOOL isFitOnScreen = _videoPlayer.isFitOnScreen;
            fullItem.image = (isFullscreen || isFitOnScreen) ? sources.shrinkscreenImage : sources.fullBtnImage;
        }
    }
    
    // live text
    {
        SJEdgeControlButtonItem *liveItem = [self.bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_LIVEText];
        if ( liveItem != nil && liveItem.hidden == NO ) {
            liveItem.title = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(sources.liveText);
                make.font(sources.titleFont);
                make.textColor(sources.titleColor);
                make.shadow(^(NSShadow * _Nonnull make) {
                    make.shadowOffset = CGSizeMake(0, 0.5);
                    make.shadowColor = UIColor.blackColor;
                });
            }];
        }
    }
    
    [_bottomAdapter reload];
}

- (void)_updateRightAdapterIfNeeded {
//    if ( sj_view_isDisappeared(_rightContainerView) ) return;
    
}

- (void)_updateCenterAdapterIfNeeded {
    if ( sj_view_isDisappeared(_centerContainerView) ) return;
    
    SJEdgeControlButtonItem *replayItem = [self.centerAdapter itemForTag:SJEdgeControlLayerCenterItem_Replay];
    if ( replayItem != nil ) {
        replayItem.hidden = !_videoPlayer.isPlayedToEndTime;
        if ( replayItem.hidden == NO && replayItem.title == nil ) {
            SJEdgeControlLayerSettings *sources = SJEdgeControlLayerSettings.commonSettings;
            UILabel *textLabel = replayItem.customView;
            textLabel.attributedText = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.alignment(NSTextAlignmentCenter).lineSpacing(6);
                make.font(sources.replayBtnFont);
                make.textColor(sources.replayBtnTitleColor);
                if ( sources.replayBtnImage != nil ) {
                    make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
                        make.image = sources.replayBtnImage;
                    });
                }
                if ( sources.replayBtnTitle.length != 0 ) {
                    if ( sources.replayBtnImage != nil ) make.append(@"\n");
                    make.append(sources.replayBtnTitle);
                }
            }];
            textLabel.bounds = (CGRect){CGPointZero, [textLabel.attributedText sj_textSize]};
        }
    }
    
    [_centerAdapter reload];
}

- (void)_updateBottomCurrentTimeItemIfNeeded {
    if ( sj_view_isDisappeared(_bottomContainerView) )
        return;
    NSString *currentTimeStr = [_videoPlayer stringForSeconds:_videoPlayer.currentTime];
    SJEdgeControlButtonItem *currentTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_CurrentTime];
    if ( currentTimeItem != nil && currentTimeItem.isHidden == NO ) {
        currentTimeItem.title = [self _textForTimeString:currentTimeStr];
        [_bottomAdapter updateContentForItemWithTag:SJEdgeControlLayerBottomItem_CurrentTime];
    }
}

- (void)_updateBottomDurationItemIfNeeded {
    SJEdgeControlButtonItem *durationTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    if ( durationTimeItem != nil && durationTimeItem.isHidden == NO ) {
        durationTimeItem.title = [self _textForTimeString:[_videoPlayer stringForSeconds:_videoPlayer.duration]];
        [_bottomAdapter updateContentForItemWithTag:SJEdgeControlLayerBottomItem_DurationTime];
    }
}

- (void)_updateBottomTimeLabelSize {
    // 00:00
    // 00:00:00
    NSString *ms = @"00:00";
    NSString *hms = @"00:00:00";
    NSString *durationTimeStr = [_videoPlayer stringForSeconds:_videoPlayer.duration];
    NSString *format = (durationTimeStr.length == ms.length)?ms:hms;
    CGSize formatSize = [[self _textForTimeString:format] sj_textSize];
    
    SJEdgeControlButtonItem *currentTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_CurrentTime];
    SJEdgeControlButtonItem *durationTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    
    if ( !durationTimeItem && !currentTimeItem ) return;
    currentTimeItem.size = formatSize.width;
    durationTimeItem.size = formatSize.width;
    [_bottomAdapter reload];
}

- (void)_updateBottomProgressSliderItemIfNeeded {
    if ( !sj_view_isDisappeared(_bottomContainerView) ) {
        SJEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
        SJProgressSlider *slider = progressItem.customView;
        slider.maxValue = _videoPlayer.duration ? : 1;
        if ( !slider.isDragging ) slider.value = _videoPlayer.currentTime;
        slider.bufferProgress = _videoPlayer.playableDuration / slider.maxValue;
    }
}

- (void)_updateBottomProgressIndicatorIfNeeded {
    if ( _bottomProgressIndicator != nil && !sj_view_isDisappeared(_bottomProgressIndicator) ) {
        _bottomProgressIndicator.value = _videoPlayer.currentTime;
        _bottomProgressIndicator.maxValue = _videoPlayer.duration ? : 1;
    }
}

- (void)_updateDraggingProgressViewCurrentTimeIfNeeded {
    if ( !sj_view_isDisappeared(_draggingProgressView) )
        _draggingProgressView.currentTime = _videoPlayer.currentTime;
}

- (void)_updateResidentBackButtonAppearStateIfNeeded {
    if ( !_showResidentBackButton )
        return;
    SJEdgeControlButtonItem *placeholderItem = [self.topAdapter itemForTag:SJEdgeControlLayerTopItem_PlaceholderBack];
    BOOL isFitOnScreen = _videoPlayer.isFitOnScreen;
    BOOL isFull = _videoPlayer.isFullScreen;
    BOOL isLockedScreen = _videoPlayer.isLockedScreen;
    if ( isLockedScreen ) {
        _residentBackButton.hidden = YES;
    }
    else {
        BOOL isPlayOnScrollView = _videoPlayer.isPlayOnScrollView;
        _residentBackButton.hidden = placeholderItem.hidden = isPlayOnScrollView && !isFitOnScreen && !isFull;
    }
}

- (void)_updateNetworkSpeedStrForLoadingView {
    if ( !_videoPlayer || !self.loadingView.isAnimating )
        return;
    
    if ( _showNetworkSpeedToLoadingView && !_videoPlayer.assetURL.isFileURL ) {
        self.loadingView.networkSpeedStr = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            SJEdgeControlLayerSettings *settings = [SJEdgeControlLayerSettings commonSettings];
            make.font(settings.loadingNetworkSpeedTextFont);
            make.textColor(settings.loadingNetworkSpeedTextColor);
            make.alignment(NSTextAlignmentCenter);
            make.append(self.videoPlayer.reachability.networkSpeedStr);
        }];
    }
    else {
        self.loadingView.networkSpeedStr = nil;
    }
}

#pragma mark -

- (nullable NSAttributedString *)_textForTimeString:(NSString *)timeStr {
    return [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(timeStr).font([UIFont systemFontOfSize:11]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
    }];
}

- (void)_resetControlLayerAppearIntervalForItemIfNeeded:(NSNotification *)note {
    SJEdgeControlButtonItem *item = note.object;
    if ( [_topAdapter containsItem:item] ) {
        if ( item.tag == SJEdgeControlLayerTopItem_Back )
            return;
    }
    
    if ( [_bottomAdapter containsItem:item] ) {
        if ( item.tag == SJEdgeControlLayerBottomItem_FullBtn )
            return;
    }
    
    if ( [_topAdapter containsItem:item] ||
         [_leftAdapter containsItem:item] ||
         [_bottomAdapter containsItem:item] ||
         [_rightAdapter containsItem:item] ||
         [_centerAdapter containsItem:item] ) {
        [_videoPlayer controlLayerNeedAppear]; // 此处为重置控制层的隐藏间隔.(如果点击到当前控制层上的item, 则重置控制层的隐藏间隔)
    }
}

- (void)_showOrRemoveBottomProgressIndicator {
    if ( _hiddenBottomProgressIndicator || _videoPlayer.playbackType == SJPlaybackTypeLIVE ) {
        if ( _bottomProgressIndicator ) {
            [_bottomProgressIndicator removeFromSuperview];
            _bottomProgressIndicator = nil;
        }
    }
    else {
        if ( !_bottomProgressIndicator ) {
            [self.controlView addSubview:self.bottomProgressIndicator];
            [_bottomProgressIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.offset(0);
                make.height.offset(_bottomProgressIndicatorHeight);
            }];
        }
    }
}

- (void)_showOrHiddenLoadingView {
    if ( _videoPlayer == nil || _videoPlayer.URLAsset == nil ) {
        [self.loadingView stop];
        return;
    }
    
    if ( _videoPlayer.assetStatus == SJAssetStatusPreparing ) {
        [self.loadingView start];
    }
    else if ( _videoPlayer.assetStatus == SJAssetStatusFailed ) {
        [self.loadingView stop];
    }
    else if ( _videoPlayer.assetStatus == SJAssetStatusReadyToPlay ) {
        self.videoPlayer.reasonForWaitingToPlay == SJWaitingToMinimizeStallsReason ? [self.loadingView start] : [self.loadingView stop];
    }
}

- (void)_onDragStart {
    if ( !_videoPlayer.isFullScreen ||
         !_videoPlayer.playbackController.isReadyForDisplay ||
          _videoPlayer.URLAsset.isM3u8 ||
        ![_videoPlayer.playbackController respondsToSelector:@selector(screenshotWithTime:size:completion:)] ) {
        self.draggingProgressView.style = SJVideoPlayerDraggingProgressViewStyleArrowProgress;
    }
    else {
        self.draggingProgressView.style = SJVideoPlayerDraggingProgressViewStylePreviewProgress;
    }
    
    [self.controlView addSubview:_draggingProgressView];
    [_draggingProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    sj_view_initializes(_draggingProgressView);
    sj_view_makeAppear(_draggingProgressView, NO);
    
    _draggingProgressView.maxValue = _videoPlayer.duration ? : 1;
    [_draggingProgressView setProgressTimeStr:[_videoPlayer stringForSeconds:_videoPlayer.currentTime]
                                 totalTimeStr:[_videoPlayer stringForSeconds:_videoPlayer.duration]];

}

- (void)_onDragMoving:(NSTimeInterval)progressTime {
    _draggingProgressView.progressTime = progressTime;
    [_draggingProgressView setProgressTimeStr:[_videoPlayer stringForSeconds:progressTime]];
    
    // 生成预览图
    if ( _draggingProgressView.style == SJVideoPlayerDraggingProgressViewStylePreviewProgress ) {
        __weak typeof(self) _self = self;
        [_videoPlayer screenshotWithTime:progressTime size:CGSizeMake(_draggingProgressView.frame.size.width * 2, _draggingProgressView.frame.size.height * 2) completion:^(SJBaseVideoPlayer * _Nonnull videoPlayer, UIImage * _Nullable image, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.draggingProgressView setPreviewImage:image];
        }];
    }
}

- (void)_onDragMoveEnd {
    [_videoPlayer seekToTime:_draggingProgressView.progressTime completionHandler:nil];

    sj_view_makeDisappear(_draggingProgressView, YES, ^{
        if ( sj_view_isDisappeared(self->_draggingProgressView) ) {
            [self->_draggingProgressView removeFromSuperview];
        }
    });
}
@end
