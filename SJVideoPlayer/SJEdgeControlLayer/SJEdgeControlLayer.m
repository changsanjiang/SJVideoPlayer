//
//  SJEdgeControlLayer.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/24.
//  Copyright © 2018 畅三江. All rights reserved.
//

#if __has_include(<SJUIKit/SJAttributesFactory.h>)
#import <SJUIKit/SJAttributesFactory.h>
#else
#import "SJAttributesFactory.h"
#endif

#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <SJBaseVideoPlayer/SJTimerControl.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer+PlayStatus.h>
#else
#import "SJBaseVideoPlayer.h"
#import "SJTimerControl.h"
#import "SJBaseVideoPlayer+PlayStatus.h"
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
static SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_PlaceholderBack = 10003;

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


#define _SJFastPath(P)  __builtin_expect((P), 1)
#define _SJSlowPath(P)  __builtin_expect((P), 0)

@interface SJEdgeControlLayer ()<SJProgressSliderDelegate, SJEdgeControlButtonItemDelegate>
@property (nonatomic, weak, nullable) SJBaseVideoPlayer *videoPlayer;

@property (nonatomic, strong, readonly) SJTimerControl *lockStateTappedTimerControl;
@property (nonatomic, strong, readonly) SJVideoPlayerDraggingProgressView *draggingProgressView;
@property (nonatomic, strong, readonly) SJNetworkLoadingView *loadingView;
@property (nonatomic, strong, readonly) SJProgressSlider *bottomProgressSlider;

// back
@property (nonatomic, strong, readonly) UIButton *residentBackButton;
@property (nonatomic, strong, readonly) SJEdgeControlButtonItem *backItem;
@property (nonatomic, strong, nullable) id<SJReachabilityObserver> reachabilityObserver;

@property (nonatomic, strong, nullable) NSString *durationStr;
@end

@implementation SJEdgeControlLayer
@synthesize restarted = _restarted;

/// 切换器(player.switcher)重启该控制层
- (void)restartControlLayer {
    _restarted = YES;
    sj_view_makeAppear(self.controlView, YES);
    if ( _videoPlayer.URLAsset ) {
        [_videoPlayer controlLayerNeedAppear];
    }
    else {
        [_videoPlayer controlLayerNeedDisappear];
    }
    [self _startOrStopLoadingView];
}

/// 控制层退场
- (void)exitControlLayer {
    _restarted = NO;
    /// clean
    _videoPlayer.controlLayerDataSource = nil;
    _videoPlayer.controlLayerDelegate = nil;
    _videoPlayer = nil;
    
    sj_view_makeDisappear(_topContainerView, YES);
    sj_view_makeDisappear(_leftContainerView, YES);
    sj_view_makeDisappear(_bottomContainerView, YES);
    sj_view_makeDisappear(_rightContainerView, YES);
    sj_view_makeDisappear(_draggingProgressView, YES);
    sj_view_makeDisappear(_centerContainerView, YES);
    sj_view_makeDisappear(self.controlView, YES, ^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    self.autoAdjustTopSpacing = YES;
    self.hideBottomProgressSlider = YES;
    return self;
}

#pragma mark - setup view
- (void)_setupView {
    [self _addItemsToTopAdapter];
    [self _addItemsToLeftAdapter];
    [self _addItemsToBottomAdapter];
    [self _addItemsToRightAdapter];
    [self _addItemsToCenterAdapter];
    
    [self.controlView addSubview:self.loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    self.topContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Top;
    self.leftContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Left;
    self.bottomContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Bottom;
    self.rightContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
    self.centerContainerView.sjv_disappearDirection = SJViewDisappearAnimation_None;
    sj_view_initializes(@[self.topContainerView, self.leftContainerView, self.bottomContainerView, self.rightContainerView]);
    
    [self sj_observeWithNotification:SJEdgeControlButtonItemPerformedActionNotification target:nil usingBlock:^(SJEdgeControlLayer *self, NSNotification * _Nonnull note) {
        [self _buttonItemPerformedAction:note.object];
    }];
}

- (void)_buttonItemPerformedAction:(SJEdgeControlButtonItem *)item {
    if ( [_topAdapter containsItem:item] ||
         [_leftAdapter containsItem:item] ||
         [_bottomAdapter containsItem:item] ||
         [_rightAdapter containsItem:item] ||
         [_centerAdapter containsItem:item] ) {
        [_videoPlayer controlLayerNeedAppear]; // 此处为重置控制层的隐藏间隔.(如果点击到当前控制层上的item, 则重置控制层的隐藏间隔)
    }
}

#pragma mark - Top
- (void)_addItemsToTopAdapter {
    SJEdgeControlButtonItem *backItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerTopItem_Back];
    backItem.delegate = self;
    [backItem addTarget:self action:@selector(clickedBackItem)];
    [self.topAdapter addItem:backItem];
    _backItem = backItem;

    SJEdgeControlButtonItem *titleItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49xFill tag:SJEdgeControlLayerTopItem_Title];
    titleItem.delegate = self;
    [self.topAdapter addItem:titleItem];
}

/// 更新显示状态
- (void)_updateAppearStateFor_TopAdapterWithVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( 0 == _topAdapter.itemCount ) {
        sj_view_makeDisappear(_topContainerView, YES);
        return;
    }
    
    /// 锁屏状态下, 使隐藏
    if ( videoPlayer.isLockedScreen ) {
        sj_view_makeDisappear(_topContainerView, YES);
        return;
    }
    
    /// 是否显示
    if ( videoPlayer.controlLayerIsAppeared ) {
        sj_view_makeAppear(_topContainerView, YES);
    }
    else {
        sj_view_makeDisappear(_topContainerView, YES);
    }
}

/// - 更新容器中的Items
/// - 是否应该显示
- (void)_updateItemsFor_TopAdapterIfNeeded:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( sj_view_isDisappeared(_topContainerView) )
        return;
    
    [self _callUpdatePropertiesMethodOfItemsForAdapter:_topAdapter videoPlayer:videoPlayer];
    [self.topAdapter reload];
}

- (BOOL)_canDisappearFor_TopAdapter {
    return YES;
}

- (void)clickedBackItem {
    if ( _clickedBackItemExeBlock ) _clickedBackItemExeBlock(self);
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
            [self _updateAppearStateForResidentBackButton];
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

@synthesize residentBackButton = _residentBackButton;
- (UIButton *)residentBackButton {
    if ( _residentBackButton ) return _residentBackButton;
    _residentBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_residentBackButton setImage:SJEdgeControlLayerSettings.commonSettings.backBtnImage forState:UIControlStateNormal];
    [_residentBackButton addTarget:self action:@selector(clickedBackItem) forControlEvents:UIControlEventTouchUpInside];
    return _residentBackButton;
}

- (void)_updateAppearStateForResidentBackButton {
    if ( !_showResidentBackButton )
        return;
    SJEdgeControlButtonItem *placeholderItem = [self.topAdapter itemForTag:SJEdgeControlLayerTopItem_PlaceholderBack];
    BOOL isFitOnScreen = _videoPlayer.isFitOnScreen;
    BOOL isFull = _videoPlayer.isFullScreen;
    BOOL isLockedScreen = _videoPlayer.isLockedScreen;
    if ( _SJSlowPath(isLockedScreen) ) {
        _residentBackButton.hidden = YES;
    }
    else {
        BOOL isPlayOnScrollView = _videoPlayer.isPlayOnScrollView;
        _residentBackButton.hidden = placeholderItem.hidden = isPlayOnScrollView && !isFitOnScreen && !isFull;
    }
}

#pragma mark - left
- (void)_addItemsToLeftAdapter {
    SJEdgeControlButtonItem *lockItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerLeftItem_Lock];
    lockItem.delegate = self;
    [lockItem addTarget:self action:@selector(clickedLockItem:)];
    [self.leftAdapter addItem:lockItem];
}

/// 更新显示状态
- (void)_updateAppearStateFor_LeftAdapterWithVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( 0 == _leftAdapter.itemCount ) {
        sj_view_makeDisappear(_leftContainerView, YES);
        return;
    }
    
    /// 锁屏状态下显示
    if ( videoPlayer.isLockedScreen ) {
        sj_view_makeAppear(_leftContainerView, YES);
        return;
    }
    
    /// 是否显示
    if ( videoPlayer.controlLayerIsAppeared ) {
        sj_view_makeAppear(_leftContainerView, YES);
    }
    else {
        sj_view_makeDisappear(_leftContainerView, YES);
    }
}

/// 更新容器中的Items
- (void)_updateItemsFor_LeftAdapterIfNeeded:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( sj_view_isDisappeared(_leftContainerView) )
        return;
    
    [self _callUpdatePropertiesMethodOfItemsForAdapter:_leftAdapter videoPlayer:videoPlayer];
    [_leftAdapter reload];
}

- (BOOL)_canDisappearFor_LeftAdapter {
    return YES;
}

/// item actions
- (void)clickedLockItem:(SJEdgeControlButtonItem *)item {
    self.videoPlayer.lockedScreen = !self.videoPlayer.isLockedScreen;
}


#pragma mark - bottom
- (void)_addItemsToBottomAdapter {
    
    // 播放按钮
    SJEdgeControlButtonItem *playItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerBottomItem_Play];
    playItem.delegate = self;
    [playItem addTarget:self action:@selector(clickedPlayItem:)];
    [self.bottomAdapter addItem:playItem];
    
    SJEdgeControlButtonItem *liveItem = [[SJEdgeControlButtonItem alloc] initWithTag:SJEdgeControlLayerBottomItem_LIVEText];
    liveItem.delegate = self;
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
        if ( self.videoPlayer.canSeekToTime ) {
            if ( !self.videoPlayer.canSeekToTime(self.videoPlayer) )
                return;
        }
        
        if ( [self.videoPlayer playStatus_isUnknown] ||
             [self.videoPlayer playStatus_isPrepare] ) {
            return;
        }
        
        [self.videoPlayer seekToTime:location completionHandler:^(BOOL finished) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( finished ) [self.videoPlayer play];
        }];
    };
    SJEdgeControlButtonItem *progressItem = [[SJEdgeControlButtonItem alloc] initWithCustomView:slider tag:SJEdgeControlLayerBottomItem_Progress];
    progressItem.delegate = self;
    progressItem.fill = YES;
    [self.bottomAdapter addItem:progressItem];

    // 全屏按钮
    SJEdgeControlButtonItem *fullItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerBottomItem_FullBtn];
    fullItem.delegate = self;
    [fullItem addTarget:self action:@selector(clickedFullItem:)];
    [self.bottomAdapter addItem:fullItem];
    
    self.bottomAdapter.view.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateItemsFor_BottomAdapterIfNeeded:self.videoPlayer];
    }];
}

/// 更新显示状态
- (void)_updateAppearStateFor_BottomAdapterWithVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( 0 == _bottomAdapter.itemCount ) {
        sj_view_makeDisappear(_bottomContainerView, YES);
        return;
    }
    
    /// 锁屏状态下, 使隐藏
    if ( videoPlayer.isLockedScreen ) {
        sj_view_makeDisappear(_bottomContainerView, YES);
        sj_view_makeAppear(_bottomProgressSlider, YES);
        return;
    }
    
    /// 是否显示
    if ( videoPlayer.controlLayerIsAppeared ) {
        sj_view_makeAppear(_bottomContainerView, YES);
        sj_view_makeDisappear(_bottomProgressSlider, YES);
    }
    else {
        sj_view_makeDisappear(_bottomContainerView, YES);
        sj_view_makeAppear(_bottomProgressSlider, YES);
    }
}

/// 更新容器中的Items
- (void)_updateItemsFor_BottomAdapterIfNeeded:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( sj_view_isDisappeared(_bottomContainerView) )
        return;
    
    [self _updateTimeLabelFor_BottomAdapterWithCurrentTimeStr:videoPlayer.currentTimeStr durationStr:videoPlayer.totalTimeStr];
    [self _callUpdatePropertiesMethodOfItemsForAdapter:_bottomAdapter videoPlayer:videoPlayer];
    [_bottomAdapter reload];
}

/// 更新时间标签
- (void)_updateTimeLabelFor_BottomAdapterWithCurrentTimeStr:(NSString *)currentTimeStr durationStr:(NSString *)durationStr {
    if ( !_bottomAdapter ) return;
    if ( sj_view_isDisappeared(_bottomContainerView) ) return;
    SJEdgeControlButtonItem *currentTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_CurrentTime];
    SJEdgeControlButtonItem *durationTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    
    if ( !durationTimeItem && !currentTimeItem ) return;
    
    currentTimeItem.title = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(currentTimeStr).font([UIFont systemFontOfSize:11]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
    }];
    
    if ( [durationStr isEqualToString:_durationStr?:@""] ) {
        [_bottomAdapter updateContentForItemWithTag:SJEdgeControlLayerBottomItem_CurrentTime];
    }
    else {
        _durationStr = durationStr;
        durationTimeItem.title = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(durationStr).font([UIFont systemFontOfSize:11]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
        }];
        
        // 00:00
        // 00:00:00
        NSString *ms = @"00:00";
        NSString *hms = @"00:00:00";
        NSString *format = (durationStr.length == ms.length)?ms:hms;
        CGSize formatSize = [[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(format).font([UIFont systemFontOfSize:11]).textColor([UIColor whiteColor]);
        }] sj_textSize];
        
        currentTimeItem.size = formatSize.width;
        durationTimeItem.size = formatSize.width;
        [_bottomAdapter reload];
    }
}

/// 更新播放进度
- (void)_updatePlaybackProgressFor_BottomAdapterWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    NSTimeInterval c = currentTime;
    NSTimeInterval d = duration?:1;
    
    if ( !sj_view_isDisappeared(_bottomContainerView) ) {
        SJEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
        SJProgressSlider *slider = progressItem.customView;
        slider.maxValue = d;
        if ( !slider.isDragging ) slider.value = c;
    }
    
    if ( _bottomProgressSlider && !sj_view_isDisappeared(_bottomProgressSlider) ) {
        _bottomProgressSlider.value = c;
        _bottomProgressSlider.maxValue = d;
    }
}

/// 更新缓冲进度
- (void)_updateBufferProgressFor_BottomAdapter:(NSTimeInterval)bufferProgress {
    SJEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
    SJProgressSlider *slider = progressItem.customView;
    slider.bufferProgress = bufferProgress;
}

// controlLayerDisappearCondition
- (BOOL)_canDisappearFor_BottomAdapter {
    SJEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
    SJProgressSlider *slider = progressItem.customView;
    return !slider.isDragging;
}

- (void)clickedPlayItem:(SJEdgeControlButtonItem *)item {
    if ( [self.videoPlayer playStatus_isPlaying] ) [self.videoPlayer pause];
    else [self.videoPlayer play];
}

- (void)clickedFullItem:(SJEdgeControlButtonItem *)item {
    if ( _videoPlayer.needPresentModalViewControlller ) {
        if ( !_videoPlayer.modalViewControllerManager.isPresentedModalViewControlller )
            [_videoPlayer presentModalViewControlller];
        else
            [_videoPlayer dismissModalViewControlller];
    }
    else if ( _videoPlayer.useFitOnScreenAndDisableRotation ) {
        _videoPlayer.fitOnScreen = !_videoPlayer.fitOnScreen;
    }
    else {
        [self.videoPlayer rotate];
    }
}

- (void)sliderWillBeginDragging:(SJProgressSlider *)slider {
    if ( _videoPlayer.canSeekToTime ) {
        if ( !_videoPlayer.canSeekToTime(_videoPlayer) ) {
            [slider cancelDragging];
            return;
        }
    }
    
    if ( [_videoPlayer playStatus_isUnknown] ||
         [_videoPlayer playStatus_isPrepare] ) {
        [slider cancelDragging];
        return;
    }
    
    [self _draggingDidStart:_videoPlayer];
}

- (void)sliderDidDrag:(SJProgressSlider *)slider {
    [self _draggingForVideoPlayer:_videoPlayer progressTime:slider.value];
}

- (void)sliderDidEndDragging:(SJProgressSlider *)slider {
    [self _draggingDidEnd:_videoPlayer];
}

@synthesize bottomProgressSlider = _bottomProgressSlider;
- (SJProgressSlider *)bottomProgressSlider {
    if ( _bottomProgressSlider ) return _bottomProgressSlider;
    _bottomProgressSlider = [SJProgressSlider new];
    _bottomProgressSlider.pan.enabled = NO;
    _bottomProgressSlider.trackHeight = 1;
    __weak typeof(self) _self = self;
    _bottomProgressSlider.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _updateBottomProgressSlider];
    }];
    [self _updateBottomProgressSlider];
    return _bottomProgressSlider;
}

- (void)_updateBottomProgressSlider {
    if ( !_bottomProgressSlider )
        return;
    SJEdgeControlLayerSettings *setting = SJEdgeControlLayerSettings.commonSettings;
    _bottomProgressSlider.traceImageView.backgroundColor = setting.progress_traceColor;
    _bottomProgressSlider.trackImageView.backgroundColor = setting.progress_trackColor;
}

- (void)setHideBottomProgressSlider:(BOOL)hideBottomProgressSlider {
    if ( hideBottomProgressSlider == _hideBottomProgressSlider )
        return;
    
    _hideBottomProgressSlider = hideBottomProgressSlider;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _showOrRemoveBottomProgressSlider];
    });
}

- (void)_showOrRemoveBottomProgressSlider {
    if ( _hideBottomProgressSlider || _videoPlayer.playbackType == SJMediaPlaybackTypeLIVE ) {
        if ( _bottomProgressSlider ) {
            [_bottomProgressSlider removeFromSuperview];
            _bottomProgressSlider = nil;
        }
    }
    else {
        if ( !_bottomProgressSlider ) {
            [self.controlView addSubview:self.bottomProgressSlider];
            [_bottomProgressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.offset(0);
                make.height.offset(1);
            }];
        }
    }
}

#pragma mark - right
- (void)_addItemsToRightAdapter {
    
}

/// 更新显示状态
- (void)_updateAppearStateFor_RightAdapterWithVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( 0 == _rightAdapter.itemCount ) {
        sj_view_makeDisappear(_rightContainerView, YES);
        return;
    }
    
    /// 锁屏状态下, 使隐藏
    if ( videoPlayer.isLockedScreen ) {
        sj_view_makeDisappear(_rightContainerView, YES);
        return;
    }
    
    /// 是否显示
    if ( videoPlayer.controlLayerIsAppeared ) {
        sj_view_makeAppear(_rightContainerView, YES);
    }
    else {
        sj_view_makeDisappear(_rightContainerView, YES);
    }
}

/// 更新容器中的Items
- (void)_updateItemsFor_RightAdapterIfNeeded:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( sj_view_isDisappeared(_rightContainerView) ) return;

    [self _callUpdatePropertiesMethodOfItemsForAdapter:_rightAdapter videoPlayer:videoPlayer];
    [_rightAdapter reload];
}

- (BOOL)_canDisapearFor_RightAdapter {
    return YES;
}

#pragma mark - center
- (void)_addItemsToCenterAdapter {
    UILabel *replayLabel = [UILabel new];
    replayLabel.numberOfLines = 0;
    SJEdgeControlButtonItem *replayItem = [SJEdgeControlButtonItem frameLayoutWithCustomView:replayLabel tag:SJEdgeControlLayerCenterItem_Replay];
    replayItem.delegate = self;
    replayItem.hidden = YES;
    [replayItem addTarget:self action:@selector(clickedReplayButton:)];
    [self.centerAdapter addItem:replayItem];
    
    __weak typeof(self) _self = self;
    replayLabel.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _center_updateReplayItem:[self.centerAdapter itemForTag:SJEdgeControlLayerCenterItem_Replay]];
    }];
    
    [self _center_updateReplayItem:[self.centerAdapter itemForTag:SJEdgeControlLayerCenterItem_Replay]];
}

- (void)_updateAppearStateFor_CenterAdapterWithVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( 0 == _centerAdapter.itemCount ) {
        sj_view_makeDisappear(_centerContainerView, YES);
        return;
    }
    
    sj_view_makeAppear(_centerContainerView, YES);
}

- (void)_updateItemsFor_CenterAdapterIfNeeded:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( 0 == _centerAdapter.itemCount )
        return;
    
    [self _updateAppearStateFor_ReplayItemWithVideoPlayerIfNeeded:videoPlayer];
    [self _callUpdatePropertiesMethodOfItemsForAdapter:_centerAdapter videoPlayer:videoPlayer];
    [_centerAdapter reload];
}

- (void)_updateReplayItemFor_CenterAdapter {
    
}

- (void)_updateAppearStateFor_ReplayItemWithVideoPlayerIfNeeded:(__kindof SJBaseVideoPlayer *)videoPlayer {
    SJEdgeControlButtonItem *replayItem = [_centerAdapter itemForTag:SJEdgeControlLayerCenterItem_Replay];
    BOOL needHidden = ![videoPlayer playStatus_isInactivity_ReasonPlayEnd];
    if ( needHidden != replayItem.hidden ) {
        replayItem.hidden = needHidden;
        [_centerAdapter reload];
    }
}

- (void)clickedReplayButton:(UIButton *)button {
    [_videoPlayer replay];
}

@synthesize loadingView = _loadingView;
- (SJNetworkLoadingView *)loadingView {
    if ( _loadingView ) return _loadingView;
    _loadingView = [SJNetworkLoadingView new];
    __weak typeof(self) _self = self;
    _loadingView.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.loadingView.lineColor = setting.loadingLineColor;
    }];
    self.loadingView.lineColor = SJEdgeControlLayerSettings.commonSettings.loadingLineColor;
    return _loadingView;
}

- (void)_updateNetworkSpeedStrForLoadingView {
    if ( !_videoPlayer || !_loadingView.isAnimating )
        return;
    
    if ( _showNetworkSpeedToLoadingView && !_videoPlayer.assetURL.isFileURL ) {
        _loadingView.networkSpeedStr = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            SJEdgeControlLayerSettings *settings = [SJEdgeControlLayerSettings commonSettings];
            make.font(settings.loadingNetworkSpeedTextFont);
            make.textColor(settings.loadingNetworkSpeedTextColor);
            make.alignment(NSTextAlignmentCenter);
            make.append(self.videoPlayer.networkSpeedStr);
        }];
    }
    else {
        _loadingView.networkSpeedStr = nil;
    }
}

- (void)setShowNetworkSpeedToLoadingView:(BOOL)showNetworkSpeedToLoadingView {
    _showNetworkSpeedToLoadingView = showNetworkSpeedToLoadingView;
    if ( !showNetworkSpeedToLoadingView )
        _loadingView.networkSpeedStr = nil;
}

@synthesize draggingProgressView = _draggingProgressView;
- (SJVideoPlayerDraggingProgressView *)draggingProgressView {
    if ( _draggingProgressView ) return _draggingProgressView;
    _draggingProgressView = [SJVideoPlayerDraggingProgressView new];
    [_draggingProgressView setPreviewImage:_videoPlayer.placeholderImageView.image];
    sj_view_makeDisappear(_draggingProgressView, NO);
    return _draggingProgressView;
}

- (void)_updateCurrentTimeForDraggingProgressViewIfNeeded:(NSTimeInterval)currentTime {
    if ( !sj_view_isDisappeared(_draggingProgressView) )
        _draggingProgressView.currentTime = currentTime;
}

/// 拖拽将要开始
- (void)_draggingDidStart:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( !_videoPlayer.isFullScreen ||
         !_videoPlayer.playbackController.isReadyForDisplay ||
         videoPlayer.URLAsset.isM3u8 ||
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
    
    _draggingProgressView.maxValue = videoPlayer.totalTime?:1;
    [_draggingProgressView setProgressTimeStr:videoPlayer.currentTimeStr
                                 totalTimeStr:videoPlayer.totalTimeStr];
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
    __weak typeof(self) _self = self;
    [videoPlayer seekToTime:_draggingProgressView.progressTime completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.videoPlayer play];
    }];
    sj_view_makeDisappear(_draggingProgressView, YES, ^{
        if ( sj_view_isDisappeared(self->_draggingProgressView) ) {
            [self->_draggingProgressView removeFromSuperview];
        }
    });
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
    
    _reachabilityObserver = [videoPlayer.reachability getObserver];
    __weak typeof(self) _self = self;
    _reachabilityObserver.networkSpeedDidChangeExeBlock = ^(id<SJReachability> r, NSString *speedStr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateNetworkSpeedStrForLoadingView];
    };
}

#pragma mark -
/// 当播放器尝试自动隐藏控制层时, 将会调用这个方法
- (BOOL)controlLayerOfVideoPlayerCanAutomaticallyDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( [self _canDisappearFor_BottomAdapter] &&
         [self _canDisappearFor_LeftAdapter] &&
         [self _canDisappearFor_TopAdapter] &&
         [self _canDisapearFor_RightAdapter] ) return YES;
    return NO;
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _updateAppearStateForResidentBackButton];
    [self _updateAppearStateForAdapters:videoPlayer];
    [self _updateItemsForAdaptersIfNeeded:videoPlayer];
    [self videoPlayer:videoPlayer currentTime:videoPlayer.currentTime currentTimeStr:videoPlayer.currentTimeStr totalTime:videoPlayer.totalTime totalTimeStr:videoPlayer.totalTimeStr];
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _updateAppearStateForAdapters:videoPlayer];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset {
    [self _updateAppearStateForResidentBackButton];
    [self _updateItemsForAdaptersIfNeeded:videoPlayer];
    [self _updateTimeLabelFor_BottomAdapterWithCurrentTimeStr:videoPlayer.currentTimeStr durationStr:videoPlayer.totalTimeStr];
    [self _updatePlaybackProgressFor_BottomAdapterWithCurrentTime:videoPlayer.currentTime duration:videoPlayer.totalTime];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer playbackTypeLoaded:(SJMediaPlaybackType)playbackType {
    SJEdgeControlButtonItem *currentTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_CurrentTime];
    SJEdgeControlButtonItem *separatorItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Separator];
    SJEdgeControlButtonItem *durationTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    SJEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
    SJEdgeControlButtonItem *liveItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_LIVEText];
    switch ( playbackType ) {
        case SJMediaPlaybackTypeLIVE: {
            currentTimeItem.hidden = YES;
            separatorItem.hidden = YES;
            durationTimeItem.hidden = YES;
            progressItem.hidden = YES;
            liveItem.hidden = NO;
        }
            break;
        case SJMediaPlaybackTypeUnknown:
        case SJMediaPlaybackTypeVOD:
        case SJMediaPlaybackTypeFILE: {
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
    [self _showOrRemoveBottomProgressSlider];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer statusDidChanged:(SJVideoPlayerPlayStatus)status {
    [self _updateItemsForAdaptersIfNeeded:videoPlayer];
    
    [self _startOrStopLoadingView];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer currentTime:(NSTimeInterval)currentTime currentTimeStr:(NSString *)currentTimeStr totalTime:(NSTimeInterval)totalTime totalTimeStr:(NSString *)totalTimeStr {
    [self _updateTimeLabelFor_BottomAdapterWithCurrentTimeStr:currentTimeStr durationStr:totalTimeStr];
    [self _updatePlaybackProgressFor_BottomAdapterWithCurrentTime:currentTime duration:totalTime];
    [self _updateCurrentTimeForDraggingProgressViewIfNeeded:videoPlayer.currentTime];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer bufferTimeDidChange:(NSTimeInterval)bufferTime {
    [self _updateBufferProgressFor_BottomAdapter:bufferTime/videoPlayer.totalTime];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus {
    [self _startOrStopLoadingView];
}

- (void)_startOrStopLoadingView {
    if ( !_videoPlayer ) {
        [_loadingView stop];
        return;
    }
    
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
                [self _updateNetworkSpeedStrForLoadingView];
            }
                break;
        }
    }
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull {
    [self _updateAppearStateForResidentBackButton];
    [self _updateAppearStateForAdapters:videoPlayer];
    [self _updateItemsForAdaptersIfNeeded:videoPlayer];
    if ( !sj_view_isDisappeared(_bottomProgressSlider) ) {
        sj_view_makeDisappear(_bottomProgressSlider, NO);
    }
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willFitOnScreen:(BOOL)isFitOnScreen {
    [self _updateAppearStateForResidentBackButton];
    [self _updateAppearStateForAdapters:videoPlayer];
    [self _updateItemsForAdaptersIfNeeded:videoPlayer];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer didEndRotation:(BOOL)isFull {
    if ( !videoPlayer.controlLayerIsAppeared ) sj_view_makeAppear(_bottomProgressSlider, YES);
}

#pragma mark Player Horizontal Gesture
/// 是否可以触发播放器的手势
- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    if ( ![self _gestureRecognizerShouldTrigger:type location:location] )
        return NO;
    
    return YES;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer panGestureTriggeredInTheHorizontalDirection:(SJPanGestureRecognizerState)state progressTime:(NSTimeInterval)progressTime {
    switch ( state ) {
        case SJPanGestureRecognizerStateBegan: {
            [self _draggingDidStart:videoPlayer];
        }
            break;
        case SJPanGestureRecognizerStateChanged: {
            [self _draggingForVideoPlayer:videoPlayer progressTime:progressTime];
        }
            break;
        case SJPanGestureRecognizerStateEnded: {
            [self _draggingDidEnd:videoPlayer];
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
    [videoPlayer controlLayerNeedDisappear];
    [self _updateAppearStateForResidentBackButton];
    [self _updateAppearStateForAdapters:videoPlayer];
    [self _updateItemsForAdaptersIfNeeded:videoPlayer];
    [self.lockStateTappedTimerControl start];
}

- (void)unlockedVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [videoPlayer controlLayerNeedAppear];
    [self _updateAppearStateForResidentBackButton];
    [self _updateAppearStateForAdapters:videoPlayer];
    [self _updateItemsForAdaptersIfNeeded:videoPlayer];
    [self.lockStateTappedTimerControl clear];
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

- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer reachabilityChanged:(SJNetworkStatus)status {
    [self _promptWithNetworkStatus:status];
}

- (void)_promptWithNetworkStatus:(SJNetworkStatus)status {
    if ( _disablePromptWhenNetworkStatusChanges ) return;
    if ( [self.videoPlayer.assetURL isFileURL] ) return; // return when is local video.
   
    switch ( status ) {
        case SJNetworkStatus_NotReachable: {
            [_videoPlayer showTitle:SJEdgeControlLayerSettings.commonSettings.notReachablePrompt duration:3];
        }
            break;
        case SJNetworkStatus_ReachableViaWWAN: {
            [_videoPlayer showTitle:SJEdgeControlLayerSettings.commonSettings.reachableViaWWANPrompt duration:3];
        }
            break;
        case SJNetworkStatus_ReachableViaWiFi: {}
            break;
    }
}

#pragma mark -
/// 更新 adapters
/// - 布局
/// - 显示或隐藏
- (void)_updateAppearStateForAdapters:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _updateAppearStateFor_TopAdapterWithVideoPlayer:videoPlayer];
    [self _updateAppearStateFor_LeftAdapterWithVideoPlayer:videoPlayer];
    [self _updateAppearStateFor_BottomAdapterWithVideoPlayer:videoPlayer];
    [self _updateAppearStateFor_RightAdapterWithVideoPlayer:videoPlayer];
    [self _updateAppearStateFor_CenterAdapterWithVideoPlayer:videoPlayer];
}

/// 更新 items
- (void)_updateItemsForAdaptersIfNeeded:(__kindof SJBaseVideoPlayer *)videoPlayer {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _updateItemsFor_TopAdapterIfNeeded:videoPlayer];
        [self _updateItemsFor_LeftAdapterIfNeeded:videoPlayer];
        [self _updateItemsFor_BottomAdapterIfNeeded:videoPlayer];
        [self _updateItemsFor_RightAdapterIfNeeded:videoPlayer];
        [self _updateItemsFor_CenterAdapterIfNeeded:videoPlayer];
    });
}

- (BOOL)_gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
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
    return [self _edgeControlButtonItem:item gestureRecognizerShouldTrigger:type atPoint:point];
}
- (BOOL)_edgeControlButtonItem:(SJEdgeControlButtonItem *)item gestureRecognizerShouldTrigger:(SJPlayerGestureType)type atPoint:(CGPoint)point {
    if ( [item.target respondsToSelector:item.action] ) {
        return YES;
    }
    
    if ( [item.delegate respondsToSelector:@selector(edgeControlButtonItem:gestureRecognizerShouldTrigger:atPoint:)] ) {
        return [item.delegate edgeControlButtonItem:item gestureRecognizerShouldTrigger:type atPoint:point];
    }
    return YES;
}

- (void)_callUpdatePropertiesMethodOfItemsForAdapter:(SJEdgeControlLayerItemAdapter *)adapter videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( !adapter ) return;
    NSArray<SJEdgeControlButtonItem *> *items = [adapter itemsWithRange:NSMakeRange(0, adapter.itemCount)];
    for ( SJEdgeControlButtonItem *item in items ) {
        if ( [item.delegate respondsToSelector:@selector(updatePropertiesIfNeeded:videoPlayer:)] ) {
            [item.delegate updatePropertiesIfNeeded:item videoPlayer:videoPlayer];
        }
    }
}

#pragma mark - SJEdgeControlButtonItem Delegate Methods
/// 手势是否可以触发
- (BOOL)edgeControlButtonItem:(SJEdgeControlButtonItem *)item gestureRecognizerShouldTrigger:(SJPlayerGestureType)type atPoint:(CGPoint)point {
    if ( item.tag == SJEdgeControlLayerTopItem_Title ||
         item.tag == SJEdgeControlLayerBottomItem_CurrentTime ||
         item.tag == SJEdgeControlLayerBottomItem_DurationTime ||
         item.tag == SJEdgeControlLayerBottomItem_Separator ) {
        return YES;
    }
    return NO;
}

- (void)updatePropertiesIfNeeded:(SJEdgeControlButtonItem *)item videoPlayer:(__kindof SJBaseVideoPlayer *)player {
    // top
    if ( item.tag == SJEdgeControlLayerTopItem_Back ) {
        [self _top_updateBackItem:item];
    }
    else if ( item.tag == SJEdgeControlLayerTopItem_Title ) {
        [self _top_updateTitleItem:item];
    }
    // left
    else if ( item.tag == SJEdgeControlLayerLeftItem_Lock ) {
        [self _left_updateLockItem:item];
    }
    // bottom
    else if ( item.tag == SJEdgeControlLayerBottomItem_Play ) {
        [self _bottom_updatePlayItem:item];
    }
    else if ( item.tag == SJEdgeControlLayerBottomItem_Progress ) {
        [self _bottom_updateProgressItem:item];
    }
    else if ( item.tag == SJEdgeControlLayerBottomItem_FullBtn ) {
        [self _bottom_updateFullItem:item];
    }
    else if ( item.tag == SJEdgeControlLayerBottomItem_LIVEText ) {
        [self _bottom_updateLiveItem:item];
    }
    // center
    else if ( item.tag == SJEdgeControlLayerCenterItem_Replay ) {
        [self _center_updateReplayItem:item];
    }
}

#pragma mark - update items -- TOP
- (void)_top_updateBackItem:(SJEdgeControlButtonItem *)backItem {
    if ( _SJSlowPath(!backItem) ) return;

    BOOL isFullscreen = _videoPlayer.isFullScreen;
    BOOL isFitOnScreen = _videoPlayer.isFitOnScreen;
    BOOL isPresentedModalViewControlller = _videoPlayer.modalViewControllerManager.isPresentedModalViewControlller;
    BOOL isPlayOnScrollView = _videoPlayer.isPlayOnScrollView;
    
    if ( isFullscreen || isFitOnScreen || isPresentedModalViewControlller )
        backItem.hidden = NO;
    else {
        if ( _hideBackButtonWhenOrientationIsPortrait )
            backItem.hidden = YES;
        else
            backItem.hidden = isPlayOnScrollView;
    }
    
    if ( backItem.hidden ) return;

    SJEdgeControlLayerSettings *setting = SJEdgeControlLayerSettings.commonSettings;
    backItem.image = setting.backBtnImage;
}

- (void)_top_updateTitleItem:(SJEdgeControlButtonItem *)titleItem {
    if ( _SJSlowPath(!titleItem) ) return;
    SJVideoPlayerURLAsset *asset = _videoPlayer.URLAsset.originAsset?:_videoPlayer.URLAsset;
    BOOL alwaysShowTitle = asset.alwaysShowTitle;
    BOOL isFullscreen = _videoPlayer.isFullScreen;
    BOOL isFitOnScreen = _videoPlayer.isFitOnScreen;

    if ( alwaysShowTitle )
        titleItem.hidden = NO;
    else
        titleItem.hidden = (!isFullscreen && !isFitOnScreen);
    
    if ( titleItem.hidden ) return;
    
    NSString *title = asset.title?:@" ";
    // margin
    CGFloat left =
    [_topAdapter itemsIsHiddenWithRange:NSMakeRange(0, [_topAdapter indexOfItemForTag:SJEdgeControlLayerTopItem_Title])]?16:0;
    
    CGFloat right =
    [_topAdapter itemsIsHiddenWithRange:NSMakeRange([_topAdapter indexOfItemForTag:SJEdgeControlLayerTopItem_Title], _topAdapter.itemCount)]?16:0;
    titleItem.numberOfLines = 1;
    titleItem.insets = SJEdgeInsetsMake(left, right);
    titleItem.title = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make
        .font(SJEdgeControlLayerSettings.commonSettings.titleFont)
        .textColor(SJEdgeControlLayerSettings.commonSettings.titleColor)
        .lineBreakMode(NSLineBreakByTruncatingTail);
        
        make.shadow(^(NSShadow * _Nonnull make) {
            make.shadowOffset = CGSizeMake(0, 0.5);
            make.shadowColor = UIColor.blackColor;
        });
        
        make.append(title);
    }];
}

#pragma mark - update items -- LEFT
- (void)_left_updateLockItem:(SJEdgeControlButtonItem *)lockItem {
    if ( _SJSlowPath(!lockItem) ) return;
    
    BOOL isFullscreen = _videoPlayer.isFullScreen;
    BOOL isLockedScreen = _videoPlayer.isLockedScreen;

    lockItem.hidden = !isFullscreen;
    
    if ( lockItem.hidden ) return;
    
    SJEdgeControlLayerSettings *setting = SJEdgeControlLayerSettings.commonSettings;
    lockItem.image = isLockedScreen?setting.lockBtnImage:setting.unlockBtnImage;
}

#pragma mark - update items -- BOTTOM
- (void)_bottom_updatePlayItem:(SJEdgeControlButtonItem *)playItem {
    if ( _SJSlowPath(!playItem) ) return;
    
    BOOL isPlaying = [_videoPlayer playStatus_isPlaying];
    SJEdgeControlLayerSettings *setting = SJEdgeControlLayerSettings.commonSettings;
    playItem.image = isPlaying?setting.pauseBtnImage:setting.playBtnImage;
}

- (void)_bottom_updateProgressItem:(SJEdgeControlButtonItem *)progressItem {
    if ( _SJSlowPath(!progressItem) ) return;
    
    SJEdgeControlLayerSettings *setting = SJEdgeControlLayerSettings.commonSettings;
    progressItem.insets = SJEdgeInsetsMake(8, 8);
    SJProgressSlider *slider = progressItem.customView;
    slider.traceImageView.backgroundColor = setting.progress_traceColor;
    slider.trackImageView.backgroundColor = setting.progress_trackColor;
    slider.bufferProgressColor = setting.progress_bufferColor;
    slider.trackHeight = setting.progress_traceHeight;
    slider.loadingColor = setting.loadingLineColor;
    
    if ( setting.progress_thumbImage ) {
        slider.thumbImageView.image = setting.progress_thumbImage;
    }
    else if ( setting.progress_thumbSize ) {
        [slider setThumbCornerRadius:setting.progress_thumbSize * 0.5 size:CGSizeMake(setting.progress_thumbSize, setting.progress_thumbSize) thumbBackgroundColor:setting.progress_thumbColor];
    }
}

- (void)_bottom_updateFullItem:(SJEdgeControlButtonItem *)fullItem {
    if ( _SJSlowPath(!fullItem) ) return;
 
    BOOL isFullscreen = _videoPlayer.isFullScreen;
    BOOL isFitOnScreen = _videoPlayer.isFitOnScreen;
    BOOL isPresentedModalViewControlller = _videoPlayer.modalViewControllerManager.isPresentedModalViewControlller;

    SJEdgeControlLayerSettings *setting = SJEdgeControlLayerSettings.commonSettings;
    fullItem.image = (isFullscreen || isFitOnScreen || isPresentedModalViewControlller) ?setting.shrinkscreenImage:setting.fullBtnImage;
}

- (void)_bottom_updateLiveItem:(SJEdgeControlButtonItem *)liveItem {
    if ( liveItem.hidden )
        return;
    liveItem.title = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make
        .font(SJEdgeControlLayerSettings.commonSettings.titleFont)
        .textColor(SJEdgeControlLayerSettings.commonSettings.titleColor);
        make.append(SJEdgeControlLayerSettings.commonSettings.liveText);
        
        make.shadow(^(NSShadow * _Nonnull make) {
            make.shadowOffset = CGSizeMake(0, 0.5);
            make.shadowColor = UIColor.blackColor;
        });
    }];
}

#pragma mark - update items CENTER
- (void)_center_updateReplayItem:(SJEdgeControlButtonItem *)replayItem {
    if ( _SJSlowPath(!replayItem) ) return;
    
    SJEdgeControlLayerSettings *setting = SJEdgeControlLayerSettings.commonSettings;
    UILabel *replayLabel = replayItem.customView;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSAttributedString *attr = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.alignment(NSTextAlignmentCenter).lineSpacing(6);
            
            if ( setting.replayBtnImage ) {
                make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
                    make.image = setting.replayBtnImage;
                });
            }
            
            if ( setting.replayBtnImage && 0 != setting.replayBtnTitle.length ) {
                make.append(@"\n");
            }
            
            if ( 0 != setting.replayBtnTitle.length ) {
                make.append(setting.replayBtnTitle).font(setting.replayBtnFont)
                .textColor(setting.replayBtnTitleColor);
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            replayLabel.attributedText = attr;
            replayLabel.bounds = (CGRect){CGPointZero, [attr sj_textSize]};
            [self.centerAdapter reload];
        });
    });
}
@end


SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_Preview = 10002;
