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
#import "SJDraggingProgressPopView.h"
#import "UIView+SJAnimationAdded.h"
#import "SJVideoPlayerSettings.h"
#import "SJProgressSlider.h"
#import "SJLoadingView.h"
#import "SJDraggingObservation.h"
#import "SJScrollingTextMarqueeView.h"
#import "SJFullscreenCustomStatusBar.h"
#import "SJFastForwardView.h"
#import <objc/message.h>

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
@property (nonatomic, strong, readonly) SJProgressSlider *bottomProgressIndicator;

// back
@property (nonatomic, strong, readonly) UIButton *residentBackButton;
@property (nonatomic, strong, readonly) SJEdgeControlButtonItem *backItem;

@property (nonatomic, strong, nullable) id<SJReachabilityObserver> reachabilityObserver;
@property (nonatomic, strong, readonly) SJTimerControl *dateTimerControl NS_AVAILABLE_IOS(11.0); // refresh date for custom status bar
@end

@implementation SJEdgeControlLayer
@synthesize restarted = _restarted;
@synthesize draggingProgressPopView = _draggingProgressPopView;
@synthesize draggingObserver = _draggingObserver;

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
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
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
    sj_view_makeDisappear(_draggingProgressPopView, YES);
    sj_view_makeDisappear(_centerContainerView, YES);
}

#pragma mark - item actions

- (void)_residentBackButtonWasTapped {
    [self.backItem performAction];
}

- (void)_backItemWasTapped {
    if ( [self.delegate respondsToSelector:@selector(backItemWasTappedForControlLayer:)] ) {
        [self.delegate backItemWasTappedForControlLayer:self];
    }
}

- (void)_lockItemWasTapped {
    self.videoPlayer.lockedScreen = !self.videoPlayer.isLockedScreen;
}

- (void)_playItemWasTapped {
    _videoPlayer.isPaused ? [self.videoPlayer play] : [self.videoPlayer pause];
}

- (void)_fullItemWasTapped {
    _videoPlayer.useFitOnScreenAndDisableRotation ? _videoPlayer.fitOnScreen = !_videoPlayer.fitOnScreen : [self.videoPlayer rotate];
}

- (void)_replayItemWasTapped {
    [_videoPlayer replay];
}

#pragma mark - slider delegate methods

- (void)sliderWillBeginDragging:(SJProgressSlider *)slider {
    if ( _videoPlayer.assetStatus != SJAssetStatusReadyToPlay ) {
        [slider cancelDragging];
        return;
    }
    else if ( _videoPlayer.canSeekToTime && !_videoPlayer.canSeekToTime(_videoPlayer) ) {
        [slider cancelDragging];
        return;
    }
    
    [self _willBeginDragging];
}

- (void)slider:(SJProgressSlider *)slider valueDidChange:(CGFloat)value {
    if ( slider.isDragging ) [self _didMove:value];
}

- (void)sliderDidEndDragging:(SJProgressSlider *)slider {
    [self _endDragging];
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
    
    [self _reloadSizeForBottomTimeLabel];
    [self _updateContentForBottomCurrentTimeItemIfNeeded];
    [self _updateContentForBottomDurationItemIfNeeded];
    
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
    
    [self _updateAppearStateForResidentBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
    [self _updateContentForBottomCurrentTimeItemIfNeeded];
    [self _updateContentForBottomProgressSliderItemIfNeeded];
    if (@available(iOS 11.0, *)) {
        [self _reloadCustomStatusBarIfNeeded];
    }
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( videoPlayer.isLockedScreen )
        return;
    
    [self _updateAppearStateForResidentBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset {
    [self _reloadSizeForBottomTimeLabel];
    [self _updateContentForBottomDurationItemIfNeeded];
    [self _updateContentForBottomCurrentTimeItemIfNeeded];
    [self _updateContentForBottomProgressSliderItemIfNeeded];
    [self _updateContentForBottomProgressIndicatorIfNeeded];
    [self _updateAppearStateForResidentBackButtonIfNeeded];
    [self _reloadAdaptersIfNeeded];
    [self _showOrHiddenLoadingView];
}

- (void)videoPlayerPlaybackStatusDidChange:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _reloadAdaptersIfNeeded];
    [self _showOrHiddenLoadingView];
    
    if ( videoPlayer.isPlaybackFinished ) {
        [self _updateContentForBottomCurrentTimeItemIfNeeded];
    }
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer currentTimeDidChange:(NSTimeInterval)currentTime {
    [self _updateContentForBottomCurrentTimeItemIfNeeded];
    [self _updateContentForBottomProgressIndicatorIfNeeded];
    [self _updateContentForBottomProgressSliderItemIfNeeded];
    [self _updateCurrentTimeForDraggingProgressPopViewIfNeeded];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer durationDidChange:(NSTimeInterval)duration {
    [self _reloadSizeForBottomTimeLabel];
    [self _updateContentForBottomDurationItemIfNeeded];
    [self _updateContentForBottomProgressIndicatorIfNeeded];
    [self _updateContentForBottomProgressSliderItemIfNeeded];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer playableDurationDidChange:(NSTimeInterval)duration {
    [self _updateContentForBottomProgressSliderItemIfNeeded];
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
    [self _updateAppearStateForResidentBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
    
    if ( !sj_view_isDisappeared(_bottomProgressIndicator) ) {
        sj_view_makeDisappear(_bottomProgressIndicator, NO);
    }
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer didEndRotation:(BOOL)isFull {
    if ( !videoPlayer.isControlLayerAppeared )
        sj_view_makeAppear(_bottomProgressIndicator, YES);
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willFitOnScreen:(BOOL)isFitOnScreen {
    [self _updateAppearStateForResidentBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
    
    if ( !sj_view_isDisappeared(_bottomProgressIndicator) ) {
        sj_view_makeDisappear(_bottomProgressIndicator, NO);
    }
}

/// 是否可以触发播放器的手势
- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    SJEdgeControlButtonItemAdapter *adapter = nil;
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
    return item != nil ? ![item.target respondsToSelector:item.action] : YES;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer panGestureTriggeredInTheHorizontalDirection:(SJPanGestureRecognizerState)state progressTime:(NSTimeInterval)progressTime {
    switch ( state ) {
        case SJPanGestureRecognizerStateBegan:
            [self _willBeginDragging];
            break;
        case SJPanGestureRecognizerStateChanged:
            [self _didMove:progressTime];
            break;
        case SJPanGestureRecognizerStateEnded:
            [self _endDragging];
            break;
    }
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer longPressGestureStateDidChange:(SJLongPressGestureRecognizerState)state {
    switch ( state ) {
        case SJLongPressGestureRecognizerStateChanged: break;
        case SJLongPressGestureRecognizerStateBegan: {
            if ( self.fastForwardView.superview != self ) {
                [self insertSubview:self.fastForwardView atIndex:0];
                [self.fastForwardView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.equalTo(self.topAdapter);
                }];
            }
            self.fastForwardView.rate = videoPlayer.rateWhenLongPressGestureTriggered;
            [self.fastForwardView show];
        }
            break;
        case SJLongPressGestureRecognizerStateEnded: {
            [self.fastForwardView hidden];
        }
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
    [self _updateAppearStateForResidentBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
    [self.lockStateTappedTimerControl start];
}

- (void)unlockedVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self.lockStateTappedTimerControl clear];
    [videoPlayer controlLayerNeedAppear];
}

- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer reachabilityChanged:(SJNetworkStatus)status {
    if (@available(iOS 11.0, *)) {
        [self _reloadCustomStatusBarIfNeeded];
    }
    if ( _disabledPromptWhenNetworkStatusChanges ) return;
    if ( [self.videoPlayer.assetURL isFileURL] ) return; // return when is local video.
    
    switch ( status ) {
        case SJNetworkStatus_NotReachable: {
            [_videoPlayer.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(SJVideoPlayerSettings.commonSettings.unstableNetworkPrompt);
                make.textColor(UIColor.whiteColor);
            }] duration:3];
        }
            break;
        case SJNetworkStatus_ReachableViaWWAN: {
            [_videoPlayer.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(SJVideoPlayerSettings.commonSettings.cellularNetworkPrompt);
                make.textColor(UIColor.whiteColor);
            }] duration:3];
        }
            break;
        case SJNetworkStatus_ReachableViaWiFi: {}
            break;
    }
}

#pragma mark -

- (NSString *)stringForSeconds:(NSInteger)secs {
    return _videoPlayer ? [_videoPlayer stringForSeconds:secs] : @"";
}

#pragma mark -

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
            [self _updateAppearStateForResidentBackButtonIfNeeded];
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

- (void)setLoadingView:(nullable UIView<SJLoadingView> *)loadingView {
    if ( loadingView != _loadingView ) {
        [_loadingView removeFromSuperview];
        _loadingView = loadingView;
        if ( loadingView != nil ) {
            [self.controlView addSubview:loadingView];
            [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.offset(0);
            }];
        }
    }
}

- (void)setDraggingProgressPopView:(nullable __kindof UIView<SJDraggingProgressPopView> *)draggingProgressPopView {
    _draggingProgressPopView = draggingProgressPopView;
    [self _updateForDraggingProgressPopView];
}

- (void)setTitleView:(nullable __kindof UIView<SJScrollingTextMarqueeView> *)titleView {
    _titleView = titleView;
    [self _reloadTopAdapterIfNeeded];
}

- (void)setCustomStatusBar:(UIView<SJFullscreenCustomStatusBar> *)customStatusBar NS_AVAILABLE_IOS(11.0) {
    if ( customStatusBar != _customStatusBar ) {
        [_customStatusBar removeFromSuperview];
        _customStatusBar = customStatusBar;
        [self _reloadCustomStatusBarIfNeeded];
    }
}

- (void)setShouldShowCustomStatusBar:(BOOL (^)(SJEdgeControlLayer * _Nonnull))shouldShowCustomStatusBar NS_AVAILABLE_IOS(11.0) {
    _shouldShowCustomStatusBar = shouldShowCustomStatusBar;
    [self _updateAppearStateForCustomStatusBar];
}

- (void)setFastForwardView:(UIView<SJFastForwardView> *)fastForwardView {
    if ( _fastForwardView != fastForwardView ) {
        [_fastForwardView removeFromSuperview];
        _fastForwardView = fastForwardView;
    }
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

@synthesize residentBackButton = _residentBackButton;
- (UIButton *)residentBackButton {
    if ( _residentBackButton ) return _residentBackButton;
    _residentBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_residentBackButton setImage:SJVideoPlayerSettings.commonSettings.backBtnImage forState:UIControlStateNormal];
    [_residentBackButton addTarget:self action:@selector(_residentBackButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    return _residentBackButton;
}

@synthesize bottomProgressIndicator = _bottomProgressIndicator;
- (SJProgressSlider *)bottomProgressIndicator {
    if ( _bottomProgressIndicator ) return _bottomProgressIndicator;
    _bottomProgressIndicator = [SJProgressSlider new];
    _bottomProgressIndicator.pan.enabled = NO;
    _bottomProgressIndicator.trackHeight = _bottomProgressIndicatorHeight;
    SJVideoPlayerSettings *sources = SJVideoPlayerSettings.commonSettings;
    UIColor *traceColor = sources.bottomIndicator_traceColor ?: sources.progress_traceColor;
    UIColor *trackColor = sources.bottomIndicator_trackColor ?: sources.progress_trackColor;
    _bottomProgressIndicator.traceImageView.backgroundColor = traceColor;
    _bottomProgressIndicator.trackImageView.backgroundColor = trackColor;
    return _bottomProgressIndicator;
}

@synthesize loadingView = _loadingView;
- (UIView<SJLoadingView> *)loadingView {
    if ( _loadingView == nil ) {
        [self setLoadingView:[SJLoadingView.alloc initWithFrame:CGRectZero]];
    }
    return _loadingView;
}

- (__kindof UIView<SJDraggingProgressPopView> *)draggingProgressPopView {
    if ( _draggingProgressPopView == nil ) {
        [self setDraggingProgressPopView:[SJDraggingProgressPopView.alloc initWithFrame:CGRectZero]];
    }
    return _draggingProgressPopView;
}

- (id<SJDraggingObservation>)draggingObserver {
    if ( _draggingObserver == nil ) {
        _draggingObserver = [SJDraggingObservation new];
    }
    return _draggingObserver;
}

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

@synthesize titleView = _titleView;
- (UIView<SJScrollingTextMarqueeView> *)titleView {
    if ( _titleView == nil ) {
        [self setTitleView:[SJScrollingTextMarqueeView.alloc initWithFrame:CGRectZero]];
    }
    return _titleView;
}

@synthesize fastForwardView = _fastForwardView;
- (UIView<SJFastForwardView> *)fastForwardView {
    if ( _fastForwardView == nil ) {
        _fastForwardView = [SJFastForwardView.alloc initWithFrame:CGRectZero];
    }
    return _fastForwardView;
}

@synthesize customStatusBar = _customStatusBar;
- (UIView<SJFullscreenCustomStatusBar> *)customStatusBar {
    if ( _customStatusBar == nil ) {
        [self setCustomStatusBar:[SJFullscreenCustomStatusBar.alloc initWithFrame:CGRectZero]];
    }
    return _customStatusBar;
}

@synthesize shouldShowCustomStatusBar = _shouldShowCustomStatusBar;
- (BOOL (^)(SJEdgeControlLayer * _Nonnull))shouldShowCustomStatusBar {
    if ( _shouldShowCustomStatusBar == nil ) {
        BOOL is_iPhoneX = _screen.is_iPhoneX;
        [self setShouldShowCustomStatusBar:^BOOL(SJEdgeControlLayer * _Nonnull controlLayer) {
            if ( controlLayer.videoPlayer.isFitOnScreen ) return NO;
            
            BOOL isFullscreen = controlLayer.videoPlayer.isFullScreen;
            if ( isFullscreen == NO ) {
                CGRect bounds = UIScreen.mainScreen.bounds;
                if ( bounds.size.width > bounds.size.height )
                    isFullscreen = CGRectEqualToRect(controlLayer.bounds, bounds);
            }
            
            BOOL shouldShow = NO;
            if ( isFullscreen ) {
                ///
                /// 13 以后, 全屏后显示自定义状态栏
                ///
                if ( @available(iOS 13.0, *) ) {
                    shouldShow = YES;
                }
                ///
                /// 11 仅 iPhone X 显示自定义状态栏
                ///
                else if ( @available(iOS 11.0, *) ) {
                    shouldShow = is_iPhoneX;
                }
            }
            return shouldShow;
        }];
    }
    return _shouldShowCustomStatusBar;
}

@synthesize dateTimerControl = _dateTimerControl;
- (SJTimerControl *)dateTimerControl {
    if ( _dateTimerControl == nil ) {
        _dateTimerControl = SJTimerControl.alloc.init;
        _dateTimerControl.interval = 1;
        __weak typeof(self) _self = self;
        _dateTimerControl.exeBlock = ^(SJTimerControl * _Nonnull control) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.customStatusBar.isHidden ? [control clear] : [self _reloadCustomStatusBarIfNeeded];
        };
    }
    return _dateTimerControl;
}

- (void)_addItemsToTopAdapter {
    SJEdgeControlButtonItem *backItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerTopItem_Back];
    backItem.resetAppearIntervalWhenPerformingItemAction = NO;
    [backItem addTarget:self action:@selector(_backItemWasTapped)];
    [self.topAdapter addItem:backItem];
    _backItem = backItem;

    SJEdgeControlButtonItem *titleItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49xFill tag:SJEdgeControlLayerTopItem_Title];
    [self.topAdapter addItem:titleItem];
    
    [self.topAdapter reload];
}

- (void)_addItemsToLeftAdapter {
    SJEdgeControlButtonItem *lockItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerLeftItem_Lock];
    [lockItem addTarget:self action:@selector(_lockItemWasTapped)];
    [self.leftAdapter addItem:lockItem];
    
    [self.leftAdapter reload];
}

- (void)_addItemsToBottomAdapter {
    // 播放按钮
    SJEdgeControlButtonItem *playItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerBottomItem_Play];
    [playItem addTarget:self action:@selector(_playItemWasTapped)];
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
    fullItem.resetAppearIntervalWhenPerformingItemAction = NO;
    [fullItem addTarget:self action:@selector(_fullItemWasTapped)];
    [self.bottomAdapter addItem:fullItem];

    [self.bottomAdapter reload];
}

- (void)_addItemsToRightAdapter {
    
}

- (void)_addItemsToCenterAdapter {
    UILabel *replayLabel = [UILabel new];
    replayLabel.numberOfLines = 0;
    SJEdgeControlButtonItem *replayItem = [SJEdgeControlButtonItem frameLayoutWithCustomView:replayLabel tag:SJEdgeControlLayerCenterItem_Replay];
    [replayItem addTarget:self action:@selector(_replayItemWasTapped)];
    [self.centerAdapter addItem:replayItem];
    [self.centerAdapter reload];
}


#pragma mark - appear state

- (void)_updateAppearStateForContainerViews {
    [self _updateAppearStateForTopContainerView];
    [self _updateAppearStateForLeftContainerView];
    [self _updateAppearStateForBottomContainerView];
    [self _updateAppearStateForRightContainerView];
    [self _updateAppearStateForCenterContainerView];
    if (@available(iOS 11.0, *)) {
        [self _updateAppearStateForCustomStatusBar];
    }
}

- (void)_updateAppearStateForTopContainerView {
    if ( 0 == _topAdapter.numberOfItems ) {
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

- (void)_updateAppearStateForLeftContainerView {
    if ( 0 == _leftAdapter.numberOfItems ) {
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
- (void)_updateAppearStateForBottomContainerView {
    if ( 0 == _bottomAdapter.numberOfItems ) {
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
- (void)_updateAppearStateForRightContainerView {
    if ( 0 == _rightAdapter.numberOfItems ) {
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

- (void)_updateAppearStateForCenterContainerView {
    if ( 0 == _centerAdapter.numberOfItems ) {
        sj_view_makeDisappear(_centerContainerView, YES);
        return;
    }
    
    sj_view_makeAppear(_centerContainerView, YES);
}

- (void)_updateAppearStateForCustomStatusBar NS_AVAILABLE_IOS(11.0) {
    BOOL shouldShow = self.shouldShowCustomStatusBar(self);
    if ( shouldShow ) {
        if ( self.customStatusBar.superview == nil ) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                UIDevice.currentDevice.batteryMonitoringEnabled = YES;
            });
            
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_reloadCustomStatusBarIfNeeded) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_reloadCustomStatusBarIfNeeded) name:UIDeviceBatteryStateDidChangeNotification object:nil];
            
            [self.topContainerView addSubview:self.customStatusBar];
            [self.customStatusBar mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.offset(0);
                make.left.right.equalTo(self.topAdapter);
                make.height.offset(20);
            }];
        }
    }
    
    _customStatusBar.hidden = !shouldShow;
    _customStatusBar.isHidden ? [self.dateTimerControl clear] : [self.dateTimerControl start];
}

#pragma mark - update items

- (void)_reloadAdaptersIfNeeded {
    [self _reloadTopAdapterIfNeeded];
    [self _reloadLeftAdapterIfNeeded];
    [self _reloadBottomAdapterIfNeeded];
    [self _reloadRightAdapterIfNeeded];
    [self _reloadCenterAdapterIfNeeded];
}

- (void)_reloadTopAdapterIfNeeded {
    if ( sj_view_isDisappeared(_topContainerView) ) return;
    SJVideoPlayerSettings *sources = SJVideoPlayerSettings.commonSettings;
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
            if ( self.isHiddenTitleItemWhenOrientationIsPortrait && !isFullscreen && !isFitOnScreen ) {
                titleItem.hidden = YES;
            }
            else {
                if ( titleItem.customView != self.titleView )
                    titleItem.customView = self.titleView;
                SJVideoPlayerURLAsset *asset = _videoPlayer.URLAsset.original ?: _videoPlayer.URLAsset;
                NSAttributedString *_Nullable attributedTitle = asset.attributedTitle;
                self.titleView.attributedText = attributedTitle;
                titleItem.hidden = (attributedTitle.length == 0);
            }

            if ( titleItem.hidden == NO ) {
                // margin
                NSInteger atIndex = [_topAdapter indexOfItemForTag:SJEdgeControlLayerTopItem_Title];
                CGFloat left  = [_topAdapter isHiddenWithRange:NSMakeRange(0, atIndex)] ? 16 : 0;
                CGFloat right = [_topAdapter isHiddenWithRange:NSMakeRange(atIndex, _topAdapter.numberOfItems)] ? 16 : 0;
                titleItem.insets = SJEdgeInsetsMake(left, right);
            }
        }
    }
    
    [_topAdapter reload];
}

- (void)_reloadLeftAdapterIfNeeded {
    if ( sj_view_isDisappeared(_leftContainerView) ) return;
    
    BOOL isFullscreen = _videoPlayer.isFullScreen;
    BOOL isLockedScreen = _videoPlayer.isLockedScreen;

    SJEdgeControlButtonItem *lockItem = [self.leftAdapter itemForTag:SJEdgeControlLayerLeftItem_Lock];
    if ( lockItem != nil ) {
        lockItem.hidden = !isFullscreen;
        if ( lockItem.hidden == NO ) {
            SJVideoPlayerSettings *sources = SJVideoPlayerSettings.commonSettings;
            lockItem.image = isLockedScreen ? sources.lockBtnImage : sources.unlockBtnImage;
        }
    }
    
    [_leftAdapter reload];
}

- (void)_reloadBottomAdapterIfNeeded {
    if ( sj_view_isDisappeared(_bottomContainerView) ) return;
    
    SJVideoPlayerSettings *sources = SJVideoPlayerSettings.commonSettings;
    
    // play item
    {
        SJEdgeControlButtonItem *playItem = [self.bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Play];
        if ( playItem != nil && playItem.hidden == NO ) {
            playItem.image = _videoPlayer.isPaused ? sources.playBtnImage : sources.pauseBtnImage;
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

- (void)_reloadRightAdapterIfNeeded {
//    if ( sj_view_isDisappeared(_rightContainerView) ) return;
    
}

- (void)_reloadCenterAdapterIfNeeded {
    if ( sj_view_isDisappeared(_centerContainerView) ) return;
    
    SJEdgeControlButtonItem *replayItem = [self.centerAdapter itemForTag:SJEdgeControlLayerCenterItem_Replay];
    if ( replayItem != nil ) {
        replayItem.hidden = !_videoPlayer.isPlaybackFinished;
        if ( replayItem.hidden == NO && replayItem.title == nil ) {
            SJVideoPlayerSettings *sources = SJVideoPlayerSettings.commonSettings;
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

- (void)_updateContentForBottomCurrentTimeItemIfNeeded {
    if ( sj_view_isDisappeared(_bottomContainerView) )
        return;
    NSString *currentTimeStr = [_videoPlayer stringForSeconds:_videoPlayer.currentTime];
    SJEdgeControlButtonItem *currentTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_CurrentTime];
    if ( currentTimeItem != nil && currentTimeItem.isHidden == NO ) {
        currentTimeItem.title = [self _textForTimeString:currentTimeStr];
        [_bottomAdapter updateContentForItemWithTag:SJEdgeControlLayerBottomItem_CurrentTime];
    }
}

- (void)_updateContentForBottomDurationItemIfNeeded {
    SJEdgeControlButtonItem *durationTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    if ( durationTimeItem != nil && durationTimeItem.isHidden == NO ) {
        durationTimeItem.title = [self _textForTimeString:[_videoPlayer stringForSeconds:_videoPlayer.duration]];
        [_bottomAdapter updateContentForItemWithTag:SJEdgeControlLayerBottomItem_DurationTime];
    }
}

- (void)_reloadSizeForBottomTimeLabel {
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

- (void)_updateContentForBottomProgressSliderItemIfNeeded {
    if ( !sj_view_isDisappeared(_bottomContainerView) ) {
        SJEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
        SJProgressSlider *slider = progressItem.customView;
        slider.maxValue = _videoPlayer.duration ? : 1;
        if ( !slider.isDragging ) slider.value = _videoPlayer.currentTime;
        slider.bufferProgress = _videoPlayer.playableDuration / slider.maxValue;
    }
}

- (void)_updateContentForBottomProgressIndicatorIfNeeded {
    if ( _bottomProgressIndicator != nil && !sj_view_isDisappeared(_bottomProgressIndicator) ) {
        _bottomProgressIndicator.value = _videoPlayer.currentTime;
        _bottomProgressIndicator.maxValue = _videoPlayer.duration ? : 1;
    }
}

- (void)_updateCurrentTimeForDraggingProgressPopViewIfNeeded {
    if ( !sj_view_isDisappeared(_draggingProgressPopView) )
        _draggingProgressPopView.currentTime = _videoPlayer.currentTime;
}

- (void)_updateAppearStateForResidentBackButtonIfNeeded {
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
    
    if ( self.loadingView.showNetworkSpeed && !_videoPlayer.assetURL.isFileURL ) {
        self.loadingView.networkSpeedStr = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            SJVideoPlayerSettings *settings = [SJVideoPlayerSettings commonSettings];
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

- (void)_reloadCustomStatusBarIfNeeded NS_AVAILABLE_IOS(11.0) {
    if ( sj_view_isDisappeared(_customStatusBar) )
        return;
    _customStatusBar.networkStatus = _videoPlayer.reachability.networkStatus;
    _customStatusBar.date = NSDate.date;
    _customStatusBar.batteryState = UIDevice.currentDevice.batteryState;
    _customStatusBar.batteryLevel = UIDevice.currentDevice.batteryLevel;
}

#pragma mark -

- (void)_updateForDraggingProgressPopView {
    SJDraggingProgressPopViewStyle style = SJDraggingProgressPopViewStyleNormal;
    if ( !_videoPlayer.URLAsset.isM3u8 &&
         [_videoPlayer.playbackController respondsToSelector:@selector(screenshotWithTime:size:completion:)] ) {
        if ( _videoPlayer.isFullScreen ) {
            style = SJDraggingProgressPopViewStyleFullscreen;
        }
        else if ( _videoPlayer.isFitOnScreen ) {
            style = SJDraggingProgressPopViewStyleFitOnScreen;
        }
    }
    _draggingProgressPopView.style = style;
    _draggingProgressPopView.duration = _videoPlayer.duration ?: 1;
    _draggingProgressPopView.currentTime = _videoPlayer.currentTime;
    _draggingProgressPopView.dragProgressTime = _videoPlayer.currentTime;
}

- (nullable NSAttributedString *)_textForTimeString:(NSString *)timeStr {
    SJVideoPlayerSettings *source = SJVideoPlayerSettings.commonSettings;
    return [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(timeStr).font(source.timeFont).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
    }];
}

/// 此处为重置控制层的隐藏间隔.(如果点击到当前控制层上的item, 则重置控制层的隐藏间隔)
- (void)_resetControlLayerAppearIntervalForItemIfNeeded:(NSNotification *)note {
    SJEdgeControlButtonItem *item = note.object;
    if ( item.resetAppearIntervalWhenPerformingItemAction ) {
        if ( [_topAdapter containsItem:item] ||
             [_leftAdapter containsItem:item] ||
             [_bottomAdapter containsItem:item] ||
             [_rightAdapter containsItem:item] )
            [_videoPlayer controlLayerNeedAppear];
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
    
    if ( _videoPlayer.isPaused ) {
        [self.loadingView stop];
    }
    else if ( _videoPlayer.assetStatus == SJAssetStatusPreparing ) {
        [self.loadingView start];
    }
    else if ( _videoPlayer.assetStatus == SJAssetStatusFailed ) {
        [self.loadingView stop];
    }
    else if ( _videoPlayer.assetStatus == SJAssetStatusReadyToPlay ) {
        self.videoPlayer.reasonForWaitingToPlay == SJWaitingToMinimizeStallsReason ? [self.loadingView start] : [self.loadingView stop];
    }
}

- (void)_willBeginDragging {
    [self.controlView addSubview:self.draggingProgressPopView];
    [self _updateForDraggingProgressPopView];
    [_draggingProgressPopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    sj_view_initializes(_draggingProgressPopView);
    sj_view_makeAppear(_draggingProgressPopView, NO);
    
    if ( _draggingObserver.willBeginDraggingExeBlock )
        _draggingObserver.willBeginDraggingExeBlock(_draggingProgressPopView.dragProgressTime);
}

- (void)_didMove:(NSTimeInterval)progressTime {
    _draggingProgressPopView.dragProgressTime = progressTime;
    // 是否生成预览图
    if ( _draggingProgressPopView.isPreviewImageHidden == NO ) {
        __weak typeof(self) _self = self;
        [_videoPlayer screenshotWithTime:progressTime size:CGSizeMake(_draggingProgressPopView.frame.size.width, _draggingProgressPopView.frame.size.height) completion:^(SJBaseVideoPlayer * _Nonnull videoPlayer, UIImage * _Nullable image, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.draggingProgressPopView setPreviewImage:image];
        }];
    }
    
    if ( _draggingObserver.didMoveExeBlock )
        _draggingObserver.didMoveExeBlock(_draggingProgressPopView.dragProgressTime);
}

- (void)_endDragging {
    NSTimeInterval time = _draggingProgressPopView.dragProgressTime;
    if ( _draggingObserver.willEndDraggingExeBlock )
        _draggingObserver.willEndDraggingExeBlock(time);
    
    [_videoPlayer seekToTime:time completionHandler:nil];

    sj_view_makeDisappear(_draggingProgressPopView, YES, ^{
        if ( sj_view_isDisappeared(self->_draggingProgressPopView) ) {
            [self->_draggingProgressPopView removeFromSuperview];
        }
    });
    
    if ( _draggingObserver.didEndDraggingExeBlock )
        _draggingObserver.didEndDraggingExeBlock(time);
}
@end


@implementation SJEdgeControlButtonItem (SJControlLayerExtended)
- (void)setResetAppearIntervalWhenPerformingItemAction:(BOOL)resetAppearIntervalWhenPerformingItemAction {
    objc_setAssociatedObject(self, @selector(resetAppearIntervalWhenPerformingItemAction), @(resetAppearIntervalWhenPerformingItemAction), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)resetAppearIntervalWhenPerformingItemAction {
    id result = objc_getAssociatedObject(self, _cmd);
    return result == nil ? YES : [result boolValue];
}
@end
