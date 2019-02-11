//
//  SJEdgeControlLayer.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/24.
//  Copyright © 2018 畅三江. All rights reserved.
//

#if __has_include(<SJAttributesFactory/SJAttributeWorker.h>)
#import <SJAttributesFactory/SJAttributeWorker.h>
#else
#import "SJAttributeWorker.h"
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
#import "SJVideoPlayerPreviewView.h"
#import "UIView+SJVideoPlayerSetting.h"
#import "UIView+SJAnimationAdded.h"
#import "SJProgressSlider.h"
#import "SJLoadingView.h"

#pragma mark - Top
SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_Back = 10000;
SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_Title = 10001;
SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_Preview = 10002;
static SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_PlaceholderBack = 10003;

#pragma mark - Left
SJEdgeControlButtonItemTag const SJEdgeControlLayerLeftItem_Lock = 10000;

#pragma mark - bottom
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Play = 10000;
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_CurrentTime = 10001;
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_DurationTime = 10002;
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Separator = 10003;
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Progress = 10004;
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_FullBtn = 10005;

#pragma mark - center
SJEdgeControlButtonItemTag const SJEdgeControlLayerCenterItem_Replay = 10000;

@interface SJEdgeControlLayer ()<SJProgressSliderDelegate, SJVideoPlayerPreviewViewDelegate>
@property (nonatomic, weak, nullable) SJBaseVideoPlayer *videoPlayer;

@property (nonatomic, strong, readonly) SJTimerControl *lockStateTappedTimerControl;
@property (nonatomic, strong, readonly) SJVideoPlayerDraggingProgressView *draggingProgressView;
@property (nonatomic, strong, readonly) SJLoadingView *loadingView;
@property (nonatomic, strong, readonly) SJVideoPlayerPreviewView *previewView;
@property (nonatomic) BOOL hasBeenGeneratedPreviewImages;
@property (nonatomic, strong, readonly) SJProgressSlider *bottomProgressSlider;

// back
@property (nonatomic, strong, readonly) UIButton *residentBackButton;
@property (nonatomic, strong, readonly) SJEdgeControlButtonItem *backItem;
@end

@implementation SJEdgeControlLayer
@synthesize restarted = _restarted;

/// 切换器(player.switcher)重启该控制层
- (void)restartControlLayer {
    _restarted = YES;
    if ( _videoPlayer.URLAsset ) {
        [_videoPlayer controlLayerNeedAppear];
        sj_view_makeAppear(self.controlView, YES);
    }
    else {
        [_videoPlayer controlLayerNeedDisappear];
    }
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
    sj_view_makeDisappear(_previewView, YES);
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
    sj_view_makeDisappear(_draggingProgressView, NO);
    sj_view_makeDisappear(_bottomProgressSlider, NO);
    self.autoAdjustTopSpacing = YES;
    self.generatePreviewImages = YES;
    self.hideBottomProgressSlider = YES;
    SJEdgeControlLayerSettings.update(^(SJEdgeControlLayerSettings * _Nonnull settings) {});
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
    
    __weak typeof(self) _self = self;
    void(^executedTargetActionExeBlock)(SJEdgeControlLayerItemAdapter *adapter) = ^(SJEdgeControlLayerItemAdapter * _Nonnull adapter) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.videoPlayer.controlLayerAppearManager resume];
    };
    
    self.topAdapter.executedTargetActionExeBlock = executedTargetActionExeBlock;
    self.leftAdapter.executedTargetActionExeBlock = executedTargetActionExeBlock;
    self.bottomAdapter.executedTargetActionExeBlock = executedTargetActionExeBlock;
    self.rightAdapter.executedTargetActionExeBlock = executedTargetActionExeBlock;
    self.centerAdapter.executedTargetActionExeBlock = executedTargetActionExeBlock;
}

#pragma mark - Top
- (void)_addItemsToTopAdapter {
    SJEdgeControlButtonItem *backItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerTopItem_Back];
    [backItem addTarget:self action:@selector(clickedBackItem)];
    [self.topAdapter addItem:backItem];
    _backItem = backItem;

    SJEdgeControlButtonItem *titleItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49xFill tag:SJEdgeControlLayerTopItem_Title];
    [self.topAdapter addItem:titleItem];
    
    SJEdgeControlButtonItem *previewItem = [SJEdgeControlButtonItem placeholderWithSize:58 tag:SJEdgeControlLayerTopItem_Preview];
    [previewItem addTarget:self action:@selector(clickedPreviewItem:)];
    [self.topAdapter addItem:previewItem];
    
    // top resources
    __weak typeof(self) _self = self;
    self.topAdapter.view.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        backItem.image = setting.backBtnImage;
        if ( titleItem.title ) {
            titleItem.title = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
                make.insertAttrStr(titleItem.title, 0);
                make.add(NSFontAttributeName, SJEdgeControlLayerSettings.commonSettings.titleFont, make.range);
                make.add(NSForegroundColorAttributeName, SJEdgeControlLayerSettings.commonSettings.titleColor, make.range);
            });
        }
        previewItem.title = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
            make.append(setting.previewBtnTitle).alignment(NSTextAlignmentCenter)
            .font(setting.previewBtnFont).textColor([UIColor whiteColor]);
        });
        previewItem.image = setting.previewBtnImage;
        [self.topAdapter reload];
    }];
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
        sj_view_makeDisappear(_previewView, YES);
        return;
    }
    
    /// 是否显示
    if ( videoPlayer.controlLayerIsAppeared ) {
        sj_view_makeAppear(_topContainerView, YES);
        if ( !videoPlayer.isFullScreen && !videoPlayer.isFitOnScreen ) {
            sj_view_makeDisappear(_previewView, YES);
        }
    }
    else {
        sj_view_makeDisappear(_topContainerView, YES);
        sj_view_makeDisappear(_previewView, YES);
    }
    
}

/// - 更新容器中的Items
/// - 是否应该显示
- (void)_updateItemsFor_TopAdapterIfNeeded:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( sj_view_isDisappeared(_topContainerView) )
        return;

    if ( 0 == _topAdapter.itemCount )
        return;
    
    /// 更新item显示状态, 是否需要隐藏
    SJEdgeControlButtonItem *backItem = _backItem;
    SJEdgeControlButtonItem *previewItem = [self.topAdapter itemForTag:SJEdgeControlLayerTopItem_Preview];
    SJEdgeControlButtonItem *titleItem = [self.topAdapter itemForTag:SJEdgeControlLayerTopItem_Title];

    BOOL isFitOnScreen = videoPlayer.isFitOnScreen;
    BOOL isFull = videoPlayer.isFullScreen;
    
    if ( backItem ) {
        if ( isFull || isFitOnScreen || videoPlayer.modalViewControllerManager.isPresentedModalViewControlller )
            backItem.hidden = NO;
        else {
            if ( _hideBackButtonWhenOrientationIsPortrait )
                backItem.hidden = YES;
            else
                backItem.hidden = videoPlayer.isPlayOnScrollView;
        }
    }
    
    if ( previewItem ) {
        previewItem.hidden = !_hasBeenGeneratedPreviewImages || !isFull || !_generatePreviewImages;
    }
    
    if ( titleItem ) {
        /// title item
        if ( videoPlayer.URLAsset.alwaysShowTitle )
            titleItem.hidden = NO;
        else
            titleItem.hidden = (!isFull && !isFitOnScreen);
        
        
        if ( !titleItem.hidden ) {
            // margin
            CGFloat left =
            [_topAdapter itemsIsHiddenWithRange:NSMakeRange(0, [_topAdapter indexOfItemForTag:SJEdgeControlLayerTopItem_Title])]?16:0;
            
            CGFloat right =
            [_topAdapter itemsIsHiddenWithRange:NSMakeRange([_topAdapter indexOfItemForTag:SJEdgeControlLayerTopItem_Title], _topAdapter.itemCount)]?16:0;
            
            titleItem.insets = SJEdgeInsetsMake(left, right);
            titleItem.title = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
                make.append(videoPlayer.URLAsset.title?:@"", 0)
                .font(SJEdgeControlLayerSettings.commonSettings.titleFont)
                .textColor(SJEdgeControlLayerSettings.commonSettings.titleColor)
                .shadow(CGSizeMake(0.5, 0.5), 1, [UIColor blackColor])
                .lineBreakMode(NSLineBreakByTruncatingTail);
            });
        }
    }
    
    [self _callDelegateMethodOfItemsForAdapter:_topAdapter videoPlayer:videoPlayer];
    [self.topAdapter reload];
}

- (BOOL)_canDisappearFor_TopAdapter {
    if ( _previewView && !sj_view_isDisappeared(_previewView) ) return NO;
    return YES;
}

- (BOOL)_canTriggerGesturesFor_TopAdapter:(CGPoint)location {
    CGPoint point = [self.controlView convertPoint:location toView:_topAdapter.view];
    if ( CGRectContainsPoint(_topAdapter.view.frame, point) &&
         [_topAdapter itemContainsPoint:point] )
        return NO;
    
    return YES;
}

- (void)clickedBackItem {
    if ( _clickedBackItemExeBlock ) _clickedBackItemExeBlock(self);
}

- (void)clickedPreviewItem:(SJEdgeControlButtonItem *)item {
    if ( sj_view_isDisappeared(_previewView) ) {
        sj_view_makeAppear(_previewView, YES);
        [_videoPlayer.controlLayerAppearManager keepAppearState];
    }
    else {
        sj_view_makeDisappear(_previewView, YES);
        [_videoPlayer.controlLayerAppearManager resume];
    }
}

@synthesize previewView = _previewView;
- (SJVideoPlayerPreviewView *)previewView {
    if ( _previewView ) return _previewView;
    _previewView = [SJVideoPlayerPreviewView new];
    _previewView.delegate = self;
    _previewView.sjv_disappearDirection = SJViewDisappearAnimation_VerticalScaling;
    _previewView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    return _previewView;
}

- (void)setGeneratePreviewImages:(BOOL)generatePreviewImages {
    if ( generatePreviewImages == _generatePreviewImages )
        return;
    _generatePreviewImages = generatePreviewImages;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( generatePreviewImages ) {
            [self.controlView addSubview:self.previewView];
            [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.topContainerView.mas_bottom);
                make.left.equalTo(self.leftContainerView.mas_left);
                make.right.equalTo(self.rightContainerView.mas_right);
            }];
            sj_view_initializes(self.previewView);
            sj_view_makeDisappear(self.previewView, NO);
        }
        else {
            [self->_previewView removeFromSuperview];
        }
    });
}

- (void)previewView:(SJVideoPlayerPreviewView *)view didSelectItem:(id<SJVideoPlayerPreviewInfo>)item {
    __weak typeof(self) _self = self;
    [_videoPlayer seekToTime:CMTimeGetSeconds(item.localTime) completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.videoPlayer play];
    }];
}

/// 重置是否生成了预览视图的状态
- (void)_resetGeneratePreviewState {
    _hasBeenGeneratedPreviewImages = NO;
    sj_view_makeDisappear(_previewView, YES);
}

/// 生成预览图片
- (void)_generatePreviewImagesIfNeededForVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer videoSize:(CGSize)size {
    if ( _videoPlayer.useFitOnScreenAndDisableRotation ) return;
    if ( videoPlayer.URLAsset.isM3u8 ) return;
    if ( !_generatePreviewImages ) return;
    if ( _hasBeenGeneratedPreviewImages ) return;
    CGSize previewItemSize = CGSizeMake(150, 150);
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
            [self _updateItemsFor_TopAdapterIfNeeded:self.videoPlayer];
            self.previewView.previewImages = images;
        }
    }];
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
    if ( __builtin_expect(_videoPlayer.isLockedScreen, 0) ) {
        _residentBackButton.hidden = YES;
    }
    else {
        _residentBackButton.hidden = placeholderItem.hidden = _videoPlayer.isPlayOnScrollView && !isFitOnScreen && !isFull;
    }
}

#pragma mark - left
- (void)_addItemsToLeftAdapter {
    SJEdgeControlButtonItem *lockItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerLeftItem_Lock];
    [self.leftAdapter addItem:lockItem];
    
    __weak typeof(self) _self = self;
    self.leftAdapter.view.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateItemsFor_LeftAdapterIfNeeded:self.videoPlayer];
    }];
    
    [lockItem addTarget:self action:@selector(clickedLockItem:)];
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
    if ( 0 == _leftAdapter.itemCount )
        return;
    
    if ( sj_view_isDisappeared(_leftContainerView) )
        return;
    
    SJEdgeControlButtonItem *lockItem = [self.leftAdapter itemForTag:SJEdgeControlLayerLeftItem_Lock];
    lockItem.hidden = !videoPlayer.isFullScreen;
    lockItem.image = videoPlayer.isLockedScreen?SJEdgeControlLayerSettings.commonSettings.lockBtnImage:SJEdgeControlLayerSettings.commonSettings.unlockBtnImage;
    
    [self _callDelegateMethodOfItemsForAdapter:_leftAdapter videoPlayer:videoPlayer];
    [_leftAdapter reload];
}

- (BOOL)_canDisappearFor_LeftAdapter {
    return YES;
}

- (BOOL)_canTriggerGesturesFor_LeftAdapter:(CGPoint)location {
    CGPoint point = [self.controlView convertPoint:location toView:_leftAdapter.view];
    if ( CGRectContainsPoint(_leftAdapter.view.frame, point) &&
        [_leftAdapter itemContainsPoint:point] )
        return NO;
    
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
    [playItem addTarget:self action:@selector(clickedPlayItem:)];
    [self.bottomAdapter addItem:playItem];
    
    // 当前时间
    SJEdgeControlButtonItem *currentTimeItem = [SJEdgeControlButtonItem placeholderWithSize:8 tag:SJEdgeControlLayerBottomItem_CurrentTime];
    [self.bottomAdapter addItem:currentTimeItem];
    
    // 时间分隔符
    SJEdgeControlButtonItem *separatorItem = [[SJEdgeControlButtonItem alloc] initWithTitle:sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
        make.append(@"/ ").font([UIFont systemFontOfSize:11]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
    }) target:nil action:NULL tag:SJEdgeControlLayerBottomItem_Separator];
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
        [self.videoPlayer seekToTime:location completionHandler:^(BOOL finished) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( finished ) [self.videoPlayer play];
        }];
    };
    SJEdgeControlButtonItem *sliderItem = [[SJEdgeControlButtonItem alloc] initWithCustomView:slider tag:SJEdgeControlLayerBottomItem_Progress];
    sliderItem.fill = YES;
    [self.bottomAdapter addItem:sliderItem];
    
    
    // 全屏按钮
    SJEdgeControlButtonItem *fullItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerBottomItem_FullBtn];
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
    if ( 0 == _bottomAdapter.itemCount )
        return;
    
    if ( sj_view_isDisappeared(_bottomContainerView) )
        return;
    
    SJEdgeControlButtonItem *playItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Play];
    SJEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
    SJEdgeControlButtonItem *fullItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_FullBtn];
    
    SJEdgeControlLayerSettings *settings = [SJEdgeControlLayerSettings commonSettings];

    playItem.image = [videoPlayer playStatus_isPlaying]?settings.pauseBtnImage:settings.playBtnImage;
    [self _updateTimeLabelFor_BottomAdapterWithCurrentTimeStr:videoPlayer.currentTimeStr durationStr:videoPlayer.totalTimeStr];
    
    progressItem.insets = SJEdgeInsetsMake(8, 8);
    SJProgressSlider *slider = progressItem.customView;
    slider.traceImageView.backgroundColor = settings.progress_traceColor;
    slider.trackImageView.backgroundColor = settings.progress_trackColor;
    slider.bufferProgressColor = settings.progress_bufferColor;
    slider.trackHeight = settings.progress_traceHeight;
    slider.loadingColor = settings.loadingLineColor;
    if ( settings.progress_thumbImage ) {
        slider.thumbImageView.image = settings.progress_thumbImage;
    }
    else if ( settings.progress_thumbSize ) {
        [slider setThumbCornerRadius:settings.progress_thumbSize * 0.5 size:CGSizeMake(settings.progress_thumbSize, settings.progress_thumbSize) thumbBackgroundColor:settings.progress_thumbColor];
    }
    
    fullItem.image = (videoPlayer.isFullScreen || videoPlayer.isFitOnScreen || videoPlayer.modalViewControllerManager.isPresentedModalViewControlller ) ?settings.shrinkscreenImage:settings.fullBtnImage;
    
    [self _callDelegateMethodOfItemsForAdapter:_bottomAdapter videoPlayer:videoPlayer];
    [_bottomAdapter reload];
}

/// 更新时间标签
- (void)_updateTimeLabelFor_BottomAdapterWithCurrentTimeStr:(NSString *)currentTimeStr durationStr:(NSString *)durationStr {
    if ( !_bottomAdapter ) return;
    if ( sj_view_isDisappeared(_bottomContainerView) ) return;
    SJEdgeControlButtonItem *currentTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_CurrentTime];
    SJEdgeControlButtonItem *durationTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    
    if ( !durationTimeItem && !currentTimeItem ) return;
    
    currentTimeItem.title = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
        make.append(currentTimeStr).font([UIFont systemFontOfSize:11]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
    });
    [_bottomAdapter updateContentForItemWithTag:SJEdgeControlLayerBottomItem_CurrentTime];
    
    if ( ![durationStr isEqualToString:durationTimeItem.title.string] ) {
        durationTimeItem.title = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
            make.append(durationStr).font([UIFont systemFontOfSize:11]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
            currentTimeItem.size = durationTimeItem.size = [self _timeLabelMaxWidthByDurationStr:durationStr];
        });
        [_bottomAdapter reload];
    }
}

- (CGFloat)_timeLabelMaxWidthByDurationStr:(NSString *)durationStr {
    // 00:00
    // 00:00:00
    NSString *ms = @"00:00";
    NSString *hms = @"00:00:00";
    NSString *format = (durationStr.length == ms.length)?ms:hms;
    __block CGSize size = CGSizeZero;
    sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
       make.append(format).font([UIFont systemFontOfSize:11]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
        size = make.size();
    });
    return size.width;
}

/// 更新播放进度
- (void)_updatePlaybackProgressFor_BottomAdapterWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    SJEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
    SJProgressSlider *slider = progressItem.customView;
    slider.maxValue = duration?:1;
    if ( !slider.isDragging ) slider.value = currentTime;
    
    if ( !sj_view_isDisappeared(_bottomProgressSlider) ) {
        _bottomProgressSlider.value = slider.value;
        _bottomProgressSlider.maxValue = slider.maxValue;
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

- (BOOL)_canTriggerGesturesFor_BottomAdapter:(CGPoint)location {
    CGPoint point = [self.controlView convertPoint:location toView:_bottomAdapter.view];
    if ( CGRectContainsPoint(_bottomAdapter.view.frame, point) &&
        [_bottomAdapter itemContainsPoint:point] )
        return NO;
    
    return YES;
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
    _hideBottomProgressSlider = hideBottomProgressSlider;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( self->_hideBottomProgressSlider ) {
            if ( self->_bottomProgressSlider ) {
                [self->_bottomProgressSlider removeFromSuperview];
                self->_bottomProgressSlider = nil;
            }
        }
        else {
            if ( !self->_bottomProgressSlider ) {
                [self.controlView addSubview:self.bottomProgressSlider];
                [self->_bottomProgressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.bottom.right.offset(0);
                    make.height.offset(1);
                }];
            }
        }
    });
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
    if ( 0 == _rightAdapter.itemCount )
        return;
    
    if ( sj_view_isDisappeared(_rightContainerView) ) return;

    [self _callDelegateMethodOfItemsForAdapter:_rightAdapter videoPlayer:videoPlayer];
    [_rightAdapter reload];
}

- (BOOL)_canDisapearFor_RightAdapter {
    return YES;
}

- (BOOL)_canTriggerGesturesFor_RightAdapter:(CGPoint)location {
    CGPoint point = [self.controlView convertPoint:location toView:_rightAdapter.view];
    if ( CGRectContainsPoint(_rightAdapter.view.frame, point) &&
        [_rightAdapter itemContainsPoint:point] )
        return NO;
    
    return YES;
}

#pragma mark - center
- (void)_addItemsToCenterAdapter {
    UILabel *replayLabel = [UILabel new];
    replayLabel.numberOfLines = 0;
    SJEdgeControlButtonItem *replayItem = [SJEdgeControlButtonItem frameLayoutWithCustomView:replayLabel tag:SJEdgeControlLayerCenterItem_Replay];
    replayItem.hidden = YES;
    [replayItem addTarget:self action:@selector(clickedReplayButton:)];
    [self.centerAdapter addItem:replayItem];
    
    
    __weak typeof(self) _self = self;
    self.centerAdapter.view.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateItemsFor_CenterAdapterIfNeeded:self.videoPlayer];
    }];
    
    replayLabel.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateReplayItemFor_CenterAdapter];
    }];
    
    [self _updateReplayItemFor_CenterAdapter];
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
    [self _callDelegateMethodOfItemsForAdapter:_centerAdapter videoPlayer:videoPlayer];
    [_centerAdapter reload];
}

- (void)_updateReplayItemFor_CenterAdapter {
    if ( !_centerAdapter ) return;
    SJEdgeControlLayerSettings *settings = SJEdgeControlLayerSettings.commonSettings;
    SJEdgeControlButtonItem *replayItem = [_centerAdapter itemForTag:SJEdgeControlLayerCenterItem_Replay];
    
    UILabel *replayLabel = replayItem.customView;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block CGRect bounds = CGRectZero;
        NSAttributedString *attr = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
            if ( settings.replayBtnImage ) {
                make.insert(settings.replayBtnImage, 0, CGPointZero, CGSizeZero).alignment(NSTextAlignmentCenter);
            }
            
            if ( settings.replayBtnImage && 0 != settings.replayBtnTitle.length ) {
                make.append(@"\n");
            }
            
            if ( 0 != settings.replayBtnTitle.length ) {
                make.append(settings.replayBtnTitle).font(settings.replayBtnFont)
                .textColor(settings.replayBtnTitleColor);
            }
            make.alignment(NSTextAlignmentCenter).lineSpacing(6);
            bounds = (CGRect){CGPointZero, make.size()};
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            replayLabel.attributedText = attr;
            replayLabel.bounds = bounds;
            [self.centerAdapter reload];
        });
    });
}

- (void)_updateAppearStateFor_ReplayItemWithVideoPlayerIfNeeded:(__kindof SJBaseVideoPlayer *)videoPlayer {
    SJEdgeControlButtonItem *replayItem = [_centerAdapter itemForTag:SJEdgeControlLayerCenterItem_Replay];
    BOOL needHidden = ![videoPlayer playStatus_isInactivity_ReasonPlayEnd];
    if ( needHidden != replayItem.hidden ) {
        replayItem.hidden = needHidden;
        [_centerAdapter reload];
    }
}

- (BOOL)_canTriggerGesturesFor_CenterAdapter:(CGPoint)location {
    CGPoint point = [self.controlView convertPoint:location toView:_centerAdapter.view];
    if ( CGRectContainsPoint(_centerAdapter.view.frame, point) &&
        [_centerAdapter itemContainsPoint:point] )
        return NO;
    
    return YES;
}

- (void)clickedReplayButton:(UIButton *)button {
    [_videoPlayer replay];
}

@synthesize loadingView = _loadingView;
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
    _draggingProgressView.maxValue = videoPlayer.totalTime?:1;
    sj_view_makeAppear(_draggingProgressView, YES);
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
        if ( ![self.videoPlayer playStatus_isPlaying] )[self.videoPlayer play];
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
    sj_view_makeDisappear(_previewView, NO);
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
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _updateAppearStateForAdapters:videoPlayer];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset {
    [self _updateAppearStateForResidentBackButton];
    [self _resetGeneratePreviewState];
    [self _updateItemsForAdaptersIfNeeded:videoPlayer];
    [self _updateTimeLabelFor_BottomAdapterWithCurrentTimeStr:videoPlayer.currentTimeStr durationStr:videoPlayer.totalTimeStr];
    [self _updatePlaybackProgressFor_BottomAdapterWithCurrentTime:videoPlayer.currentTime duration:videoPlayer.totalTime];
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

///  在`tableView`或`collectionView`上将要显示的时候调用.
- (void)videoPlayerWillAppearInScrollView:(SJBaseVideoPlayer *)videoPlayer {
    videoPlayer.view.hidden = NO;
}

///  在`tableView`或`collectionView`上将要消失的时候调用.
- (void)videoPlayerWillDisappearInScrollView:(SJBaseVideoPlayer *)videoPlayer {
    [videoPlayer pause];
    videoPlayer.view.hidden = YES;
}

#pragma mark Player Horizontal Gesture
/// 是否可以触发播放器的手势
- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    if ( ![self _canTriggerGesturesFor_TopAdapter:location] ||
        ![self _canTriggerGesturesFor_LeftAdapter:location] ||
        ![self _canTriggerGesturesFor_BottomAdapter:location] ||
        ![self _canTriggerGesturesFor_RightAdapter:location] ||
        ![self _canTriggerGesturesFor_CenterAdapter:location] ) return NO;
    
    if ( CGRectContainsPoint( _previewView.frame, location) )
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

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer presentationSize:(CGSize)size {
    [self _generatePreviewImagesIfNeededForVideoPlayer:videoPlayer videoSize:size];
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

- (void)_callDelegateMethodOfItemsForAdapter:(SJEdgeControlLayerItemAdapter *)adapter videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( !adapter ) return;
    NSArray<SJEdgeControlButtonItem *> *items = [adapter itemsWithRange:NSMakeRange(0, adapter.itemCount)];
    for ( SJEdgeControlButtonItem *item in items ) {
        if ( [item.delegate respondsToSelector:@selector(updatePropertiesIfNeeded:videoPlayer:)] ) {
            [item.delegate updatePropertiesIfNeeded:item videoPlayer:videoPlayer];
        }
    }
}
@end
