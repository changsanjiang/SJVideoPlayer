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
@end

@implementation SJEdgeControlLayer
@synthesize restarted = _restarted;

- (void)restartControlLayer {
    _restarted = YES;
    if ( _videoPlayer.URLAsset ) {
        [_videoPlayer controlLayerNeedAppear];
        [self _show:self.controlView animated:YES];
    }
    else {
        [_videoPlayer controlLayerNeedDisappear];
    }
}

- (void)exitControlLayer {
    _restarted = NO;
    /// clean
    _videoPlayer.controlLayerDataSource = nil;
    _videoPlayer.controlLayerDelegate = nil;
    _videoPlayer = nil;
    
    [self _hidden:_topContainerView animated:YES];
    [self _hidden:_leftContainerView animated:YES];
    [self _hidden:_bottomContainerView animated:YES];
    [self _hidden:_rightContainerView animated:YES];
    [self _hidden:_previewView animated:YES];
    [self _hidden:_draggingProgressView animated:YES];
    
    [self _hidden:self.controlView animated:YES completionHandler:^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    }];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    self.topContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Top;
    self.leftContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Left;
    self.bottomContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Bottom;
    self.rightContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
    self.centerContainerView.sjv_disappearDirection = SJViewDisappearAnimation_None;
    [self _hidden:_draggingProgressView animated:NO];
    [self _hidden:_bottomProgressSlider animated:NO];
    self.autoAdjustTopSpacing = YES;
    _generatePreviewImages = YES;
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

    [self.controlView addSubview:self.bottomProgressSlider];
    [_bottomProgressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.offset(0);
        make.height.offset(1);
    }];
}

#pragma mark - Top
- (void)_addItemsToTopAdapter {
    SJEdgeControlButtonItem *backItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerTopItem_Back];
    [backItem addTarget:self action:@selector(clickedBackItem:)];
    [self.topAdapter addItem:backItem];

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
    /// 锁屏状态下, 使隐藏
    if ( videoPlayer.isLockedScreen ) {
        [self _hidden:_topContainerView animated:YES];
        [self _hidden:_previewView animated:YES];
        return;
    }
    
    /// 是否显示
    if ( videoPlayer.controlLayerAppeared ) {
        [self _show:_topContainerView animated:YES];
        if ( !videoPlayer.isFullScreen && !videoPlayer.isFitOnScreen ) {
            [self _hidden:_previewView animated:YES];
        }
    }
    else {
        [self _hidden:_topContainerView animated:YES];
        [self _hidden:_previewView animated:YES];
    }
    
}

/// - 更新容器中的Items
/// - 是否应该显示
- (void)_updateItemsFor_TopAdapterIfNeeded:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( !_topAdapter ) return;
    if ( [self _isHiddenWithView:_topContainerView] ) return;
    
    /// 更新item显示状态, 是否需要隐藏
    SJEdgeControlButtonItem *backItem = [self.topAdapter itemForTag:SJEdgeControlLayerTopItem_Back];
    SJEdgeControlButtonItem *previewItem = [self.topAdapter itemForTag:SJEdgeControlLayerTopItem_Preview];
    SJEdgeControlButtonItem *titleItem = [self.topAdapter itemForTag:SJEdgeControlLayerTopItem_Title];

    BOOL isFitOnScreen = videoPlayer.isFitOnScreen;
    BOOL isFull = videoPlayer.isFullScreen;
    /// back item
    if ( isFull || isFitOnScreen )
        backItem.hidden = NO;
    else {
        if ( _hideBackButtonWhenOrientationIsPortrait )
            backItem.hidden = YES;
        else
            backItem.hidden = videoPlayer.isPlayOnScrollView;
    }
    
    /// title item
    if ( videoPlayer.URLAsset.alwaysShowTitle )
        titleItem.hidden = NO;
    else
        titleItem.hidden = (!isFull && !isFitOnScreen);
    

    if ( !titleItem.hidden ) {
        // margin
        CGFloat left =
        [_topAdapter itemsIsHiddenWithRange:NSMakeRange(0, [_topAdapter indexOfItemForTag:SJEdgeControlLayerTopItem_Title])]?12:0;
        
        CGFloat right =
        [_topAdapter itemsIsHiddenWithRange:NSMakeRange([_topAdapter indexOfItemForTag:SJEdgeControlLayerTopItem_Title], _topAdapter.itemCount)]?12:0;
        
        titleItem.insets = SJEdgeInsetsMake(left, right);
        titleItem.title = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
            make.append(videoPlayer.URLAsset.title?:@"", 0)
            .font(SJEdgeControlLayerSettings.commonSettings.titleFont)
            .textColor(SJEdgeControlLayerSettings.commonSettings.titleColor)
            .shadow(CGSizeMake(0.5, 0.5), 1, [UIColor blackColor])
            .lineBreakMode(NSLineBreakByTruncatingTail);
        });
    }
    
    /// preview item
    previewItem.hidden = !_hasBeenGeneratedPreviewImages || !isFull || !_generatePreviewImages;
    
    [self _callDelegateMethodOfItemsForAdapter:_topAdapter videoPlayer:videoPlayer];
    [self.topAdapter reload];
}

/// 播放器是否只支持一个方向
- (BOOL)_whetherToSupportOnlyOneOrientation {
    if ( _videoPlayer.supportedOrientation == SJAutoRotateSupportedOrientation_Portrait ) return YES;
    if ( _videoPlayer.supportedOrientation == SJAutoRotateSupportedOrientation_LandscapeLeft ) return YES;
    if ( _videoPlayer.supportedOrientation == SJAutoRotateSupportedOrientation_LandscapeRight ) return YES;
    return NO;
}

- (BOOL)_canDisappearFor_TopAdapter {
    if ( _previewView && ![self _isHiddenWithView:_previewView] ) return NO;
    return YES;
}

- (BOOL)_canTriggerGesturesFor_TopAdapter:(CGPoint)location {
    CGPoint point = [self.controlView convertPoint:location toView:_topAdapter.view];
    if ( CGRectContainsPoint(_topAdapter.view.frame, point) &&
         [_topAdapter itemContainsPoint:point] )
        return NO;
    
    return YES;
}

- (void)clickedBackItem:(SJEdgeControlButtonItem *)item {
    if ( _videoPlayer.useFitOnScreenAndDisableRotation ) {
        if ( _videoPlayer.isFitOnScreen ) {
            _videoPlayer.fitOnScreen = NO;
        }
        else {
            if ( _clickedBackItemExeBlock ) _clickedBackItemExeBlock(self);
        }
    }
    else {
        // 竖屏状态
        // 只支持一个反向
        // 调用 back
        if ( self.videoPlayer.orientation == SJOrientation_Portrait ||
             [self _whetherToSupportOnlyOneOrientation] ) {
            if ( _clickedBackItemExeBlock ) _clickedBackItemExeBlock(self);
        }
        else {
            [_videoPlayer rotate];
        }
    }
}

- (void)clickedPreviewItem:(SJEdgeControlButtonItem *)item {
    if ( [self _isHiddenWithView:self.previewView] ) {
        [self _show:_previewView animated:YES];
        [_videoPlayer controlLayerNeedAppear];
    }
    else [self _hidden:_previewView animated:YES];
}

@synthesize previewView = _previewView;
- (SJVideoPlayerPreviewView *)previewView {
    if ( _previewView ) return _previewView;
    _previewView = [SJVideoPlayerPreviewView new];
    _previewView.delegate = self;
    _previewView.sjv_disappearDirection = SJViewDisappearAnimation_VerticalScaling;
    _previewView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self.controlView addSubview:_previewView];
    [self _hidden:_previewView animated:NO];

    [_previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topContainerView.mas_bottom);
        make.left.equalTo(self.leftContainerView.mas_left);
        make.right.equalTo(self.rightContainerView.mas_right);
    }];
    
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

/// 重置是否生成了预览视图的状态
- (void)_resetGeneratePreviewImagesState {
    _hasBeenGeneratedPreviewImages = NO;
}

/// 生成预览图片
- (void)_generatePreviewImagesIfNeededForVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer videoSize:(CGSize)size {
    if ( _videoPlayer.useFitOnScreenAndDisableRotation ) return;
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
    /// 锁屏状态下显示
    if ( videoPlayer.isLockedScreen ) {
        [self _show:_leftContainerView animated:YES];
        
        return;
    }
    
    /// 是否显示
    if ( videoPlayer.controlLayerAppeared ) {
        [self _show:_leftContainerView animated:YES];
    }
    else {
        [self _hidden:_leftContainerView animated:YES];
    }
}

/// 更新容器中的Items
- (void)_updateItemsFor_LeftAdapterIfNeeded:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( !_leftAdapter ) return;
    if ( [self _isHiddenWithView:_leftContainerView] ) return;
    
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
    /// 锁屏状态下, 使隐藏
    if ( videoPlayer.isLockedScreen ) {
        [self _hidden:_bottomContainerView animated:YES];
        [self _show:_bottomProgressSlider animated:YES];
        return;
    }
    
    /// 是否显示
    if ( videoPlayer.controlLayerAppeared ) {
        [self _show:_bottomContainerView animated:YES];
        [self _hidden:_bottomProgressSlider animated:YES];
    }
    else {
        [self _hidden:_bottomContainerView animated:YES];
        [self _show:_bottomProgressSlider animated:YES];
    }
}

/// 更新容器中的Items
- (void)_updateItemsFor_BottomAdapterIfNeeded:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( !_bottomAdapter ) return;
    if ( [self _isHiddenWithView:_bottomContainerView] ) return;
    SJEdgeControlButtonItem *playItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Play];
    SJEdgeControlButtonItem *sliderItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
    SJEdgeControlButtonItem *fullItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_FullBtn];
    
    SJEdgeControlLayerSettings *settings = [SJEdgeControlLayerSettings commonSettings];
    
    playItem.image = [videoPlayer playStatus_isPlaying]?settings.pauseBtnImage:settings.playBtnImage;
    [self _updateTimeLabelFor_BottomAdapterWithCurrentTimeStr:videoPlayer.currentTimeStr durationStr:videoPlayer.totalTimeStr];
    
    sliderItem.insets = SJEdgeInsetsMake(8, 8);
    SJProgressSlider *slider = sliderItem.customView;
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
    
    fullItem.image = (videoPlayer.isFullScreen || videoPlayer.isFitOnScreen)?settings.shrinkscreenImage:settings.fullBtnImage;
    
    [self _callDelegateMethodOfItemsForAdapter:_bottomAdapter videoPlayer:videoPlayer];
    [_bottomAdapter reload];
}

/// 更新时间标签
- (void)_updateTimeLabelFor_BottomAdapterWithCurrentTimeStr:(NSString *)currentTimeStr durationStr:(NSString *)durationStr {
    if ( !_bottomAdapter ) return;
    if ( [self _isHiddenWithView:_bottomAdapter.view] ) return;
    SJEdgeControlButtonItem *currentTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_CurrentTime];
    SJEdgeControlButtonItem *durationTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    
    currentTimeItem.title = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
        make.append(currentTimeStr).font([UIFont systemFontOfSize:11]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
    });
    
    if ( ![durationStr isEqualToString:durationTimeItem.title.string] ) {
        durationTimeItem.title = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
            make.append(durationStr).font([UIFont systemFontOfSize:11]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
            currentTimeItem.size = durationTimeItem.size = [self _timeLabelMaxWidthByDurationStr:durationStr];
        });
        [_bottomAdapter reload];
    }
    else {
        [_bottomAdapter updateContentForItemWithTag:SJEdgeControlLayerBottomItem_CurrentTime];
        [_bottomAdapter updateContentForItemWithTag:SJEdgeControlLayerBottomItem_DurationTime];
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
    SJEdgeControlButtonItem *sliderItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
    SJProgressSlider *slider = sliderItem.customView;
    slider.maxValue = duration?:1;
    if ( !slider.isDragging ) slider.value = currentTime;
    
    if ( ![self _isHiddenWithView:_bottomProgressSlider] ) {
        _bottomProgressSlider.value = slider.value;
        _bottomProgressSlider.maxValue = slider.maxValue;
    }
}

/// 更新缓冲进度
- (void)_updateBufferProgressFor_BottomAdapter:(NSTimeInterval)bufferProgress {
    SJEdgeControlButtonItem *sliderItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
    SJProgressSlider *slider = sliderItem.customView;
    slider.bufferProgress = bufferProgress;
}

// controlLayerDisappearCondition
- (BOOL)_canDisappearFor_BottomAdapter {
    SJEdgeControlButtonItem *sliderItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
    SJProgressSlider *slider = sliderItem.customView;
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
    if ( _videoPlayer.useFitOnScreenAndDisableRotation ) _videoPlayer.fitOnScreen = !_videoPlayer.fitOnScreen;
    else [self.videoPlayer rotate];
}

- (void)sliderWillBeginDragging:(SJProgressSlider *)slider {
    [self _draggingWillTriggerForVideoPlayer:_videoPlayer];
}

- (void)sliderDidDrag:(SJProgressSlider *)slider {
    [self _draggingForVideoPlayer:_videoPlayer shiftProgress:slider.value/slider.maxValue];
}

- (void)sliderDidEndDragging:(SJProgressSlider *)slider {
    [self _draggingDidEndForVideoPlayer:_videoPlayer];
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
        self.bottomProgressSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.bottomProgressSlider.trackImageView.backgroundColor = setting.progress_trackColor;
    }];
    return _bottomProgressSlider;
}

#pragma mark - right
- (void)_addItemsToRightAdapter {
    
}

/// 更新显示状态
- (void)_updateAppearStateFor_RightAdapterWithVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    /// 锁屏状态下, 使隐藏
    if ( videoPlayer.isLockedScreen ) {
        [self _hidden:_rightContainerView animated:YES];
        return;
    }
    
    /// 是否显示
    if ( videoPlayer.controlLayerAppeared ) {
        [self _show:_rightContainerView animated:YES];
    }
    else {
        [self _hidden:_rightContainerView animated:YES];
    }
}

/// 更新容器中的Items
- (void)_updateItemsFor_RightAdapterIfNeeded:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( !_bottomAdapter ) return;
    if ( [self _isHiddenWithView:_rightContainerView] ) return;

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
    /// nothing
}

- (void)_updateItemsFor_CenterAdapterIfNeeded:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( !_centerAdapter ) return;
    [self _updateAppearStateFor_ReplayItemWithVideoPlayerIfNeeded:videoPlayer];
    [self _callDelegateMethodOfItemsForAdapter:_centerAdapter videoPlayer:videoPlayer];
    [_centerAdapter reload];
}

- (void)_updateReplayItemFor_CenterAdapter {
    if ( !_centerAdapter ) return;
    SJEdgeControlLayerSettings *settings = SJEdgeControlLayerSettings.commonSettings;
    SJEdgeControlButtonItem *replayItem = [_centerAdapter itemForTag:SJEdgeControlLayerCenterItem_Replay];
    
    UILabel *replayLabel = replayItem.customView;
    replayLabel.attributedText = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
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
        replayLabel.bounds = (CGRect){CGPointZero, make.size()};
    });
    
    [self.centerAdapter reload];
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
    [self.controlView addSubview:_draggingProgressView];
    [self _hidden:_draggingProgressView animated:NO];
    [_draggingProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    return _draggingProgressView;
}

- (void)_updatePlaybackProgressForDraggingProgressViewIfNeeded:(NSTimeInterval)playbackProgress {
    _draggingProgressView.playProgress = playbackProgress;
}

/// 拖拽将要触发
- (void)_draggingWillTriggerForVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if (  _videoPlayer.isFullScreen &&
         !_videoPlayer.URLAsset.isM3u8 ) {
        self.draggingProgressView.style = SJVideoPlayerDraggingProgressViewStylePreviewProgress;
    }
    else self.draggingProgressView.style = SJVideoPlayerDraggingProgressViewStyleArrowProgress;
    
    [self _show:_draggingProgressView animated:YES];
    [_draggingProgressView setTimeShiftStr:videoPlayer.currentTimeStr totalTimeStr:videoPlayer.totalTimeStr];
}

/// 拖拽中
- (void)_draggingForVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer shiftProgress:(float)shiftProgress {
    _draggingProgressView.shiftProgress = shiftProgress;
    NSString *shiftTimeStr = [videoPlayer timeStringWithSeconds:_draggingProgressView.shiftProgress * _videoPlayer.totalTime];
    [_draggingProgressView setTimeShiftStr:shiftTimeStr];
    
    // 生成预览图
    if ( _draggingProgressView.style == SJVideoPlayerDraggingProgressViewStylePreviewProgress ) {
        NSTimeInterval secs = _draggingProgressView.shiftProgress * _videoPlayer.totalTime;
        __weak typeof(self) _self = self;
        [self.videoPlayer screenshotWithTime:secs size:CGSizeMake(_draggingProgressView.frame.size.width * 2, _draggingProgressView.frame.size.height * 2) completion:^(SJBaseVideoPlayer * _Nonnull videoPlayer, UIImage * _Nullable image, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.draggingProgressView setPreviewImage:image];
        }];
    }
}

/// 拖拽结束
- (void)_draggingDidEndForVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    __weak typeof(self) _self = self;
    [videoPlayer seekToTime:_draggingProgressView.shiftProgress * videoPlayer.totalTime completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.videoPlayer play];
    }];
    [self _hidden:_draggingProgressView animated:YES];
}




#pragma mark - player delegate methods
- (UIView *)controlView {
    return self;
}

/// 是否可以触发播放器的手势
- (BOOL)triggerGesturesCondition:(CGPoint)location {
    if ( ![self _canTriggerGesturesFor_TopAdapter:location] ||
         ![self _canTriggerGesturesFor_LeftAdapter:location] ||
         ![self _canTriggerGesturesFor_BottomAdapter:location] ||
         ![self _canTriggerGesturesFor_RightAdapter:location] ||
         ![self _canTriggerGesturesFor_CenterAdapter:location] ) return NO;
    
    if ( CGRectContainsPoint( _previewView.frame, location) )
        return NO;
    
    return YES;
}

/// 当播放器尝试自动隐藏控制层时, 将会调用这个方法
/// - 返回Yes, 将隐藏控制层
- (BOOL)controlLayerDisappearCondition {
    if ( [self _canDisappearFor_BottomAdapter] &&
         [self _canDisappearFor_LeftAdapter] &&
         [self _canDisappearFor_TopAdapter] &&
         [self _canDisapearFor_RightAdapter] ) return YES;
    return NO;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _videoPlayer = videoPlayer;
    [videoPlayer.view layoutIfNeeded];
    
    [self _hidden:_topContainerView animated:NO];
    [self _hidden:_leftContainerView animated:NO];
    [self _hidden:_bottomContainerView animated:NO];
    [self _hidden:_rightContainerView animated:NO];
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    self.isFitOnScreen = CGRectEqualToRect(videoPlayer.view.bounds, UIScreen.mainScreen.bounds);
    [self _updateAppearStateForAdapters:videoPlayer];
    [self _updateItemsForAdaptersIfNeeded:videoPlayer];
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _updateAppearStateForAdapters:videoPlayer];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset {
    [self _resetGeneratePreviewImagesState];
    [self _updateItemsForAdaptersIfNeeded:videoPlayer];
    [self _updateTimeLabelFor_BottomAdapterWithCurrentTimeStr:videoPlayer.currentTimeStr durationStr:videoPlayer.totalTimeStr];
    [self _updatePlaybackProgressFor_BottomAdapterWithCurrentTime:videoPlayer.currentTime duration:videoPlayer.totalTime];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer statusDidChanged:(SJVideoPlayerPlayStatus)status {
    [self _updateItemsForAdaptersIfNeeded:videoPlayer];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer currentTime:(NSTimeInterval)currentTime currentTimeStr:(NSString *)currentTimeStr totalTime:(NSTimeInterval)totalTime totalTimeStr:(NSString *)totalTimeStr {
    [self _updateTimeLabelFor_BottomAdapterWithCurrentTimeStr:currentTimeStr durationStr:totalTimeStr];
    [self _updatePlaybackProgressFor_BottomAdapterWithCurrentTime:currentTime duration:totalTime];
    [self _updatePlaybackProgressForDraggingProgressViewIfNeeded:videoPlayer.progress];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer loadedTimeProgress:(float)progress {
    [self _updateBufferProgressFor_BottomAdapter:progress];
}

- (void)startLoading:(SJBaseVideoPlayer *)videoPlayer {
    [self.loadingView start];
}

- (void)cancelLoading:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self.loadingView stop];
}

- (void)loadCompletion:(SJBaseVideoPlayer *)videoPlayer {
    [self.loadingView stop];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull {
    [self _updateAppearStateForAdapters:videoPlayer];
    [self _updateItemsForAdaptersIfNeeded:videoPlayer];
    if ( ![self _isHiddenWithView:_bottomProgressSlider] ) [self _hidden:_bottomProgressSlider animated:NO];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willFitOnScreen:(BOOL)isFitOnScreen {
    self.isFitOnScreen = isFitOnScreen;
    [self _updateAppearStateForAdapters:videoPlayer];
    [self _updateItemsForAdaptersIfNeeded:videoPlayer];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer didEndRotation:(BOOL)isFull {
    if ( !videoPlayer.controlLayerAppeared ) [self _show:_bottomProgressSlider animated:YES];
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
/// 水平方向开始拖动.
- (void)horizontalDirectionWillBeginDragging:(SJBaseVideoPlayer *)videoPlayer {
    [self _draggingWillTriggerForVideoPlayer:videoPlayer];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer horizontalDirectionDidMove:(CGFloat)progress {
    [self _draggingForVideoPlayer:videoPlayer shiftProgress:progress];
}

/// 水平方向拖动结束.
- (void)horizontalDirectionDidEndDragging:(SJBaseVideoPlayer *)videoPlayer {
    [self _draggingDidEndForVideoPlayer:videoPlayer];
}

/// 这是一个只有在播放器锁屏状态下, 才会回调的方法
/// 当播放器锁屏后, 用户每次点击都会回调这个方法
- (void)tappedPlayerOnTheLockedState:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( [self _isHiddenWithView:_leftContainerView] ) {
        [self _show:_leftContainerView animated:YES];
        [self.lockStateTappedTimerControl start];
    }
    else {
        [self _hidden:_leftContainerView animated:YES];
        [self.lockStateTappedTimerControl clear];
    }
}

- (void)lockedVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [videoPlayer controlLayerNeedDisappear];
    [self _updateAppearStateForAdapters:videoPlayer];
    [self _updateItemsForAdaptersIfNeeded:videoPlayer];
    [self.lockStateTappedTimerControl start];
}

- (void)unlockedVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [videoPlayer controlLayerNeedAppear];
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
        [self _hidden:self.leftContainerView animated:YES];
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
    [self _updateItemsFor_TopAdapterIfNeeded:videoPlayer];
    [self _updateItemsFor_LeftAdapterIfNeeded:videoPlayer];
    [self _updateItemsFor_BottomAdapterIfNeeded:videoPlayer];
    [self _updateItemsFor_RightAdapterIfNeeded:videoPlayer];
    [self _updateItemsFor_CenterAdapterIfNeeded:videoPlayer];
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
