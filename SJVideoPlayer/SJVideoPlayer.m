//
//  SJVideoPlayer.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJVideoPlayer.h"
#import "UIView+SJVideoPlayerSetting.h"
#import "SJFilmEditingControlLayer.h"
#import "UIView+SJAnimationAdded.h"
#import <objc/message.h>

#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer+PlayStatus.h>
#else
#import "SJBaseVideoPlayer+PlayStatus.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface _SJEdgeControlButtonItemDelegate : NSObject<SJEdgeControlButtonItemDelegate>
@property (nonatomic, strong, readonly) SJEdgeControlButtonItem *item;
- (instancetype)initWithItem:(SJEdgeControlButtonItem *)item;

@property (nonatomic, copy, nullable) void(^updatePropertiesIfNeeded)(SJEdgeControlButtonItem *item, __kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^clickedItemExeBlock)(SJEdgeControlButtonItem *item);
@end

@implementation _SJEdgeControlButtonItemDelegate
- (instancetype)initWithItem:(SJEdgeControlButtonItem *)item {
    self = [super init];
    if ( !self ) return nil;
    _item = item;
    _item.delegate = self;
    [_item addTarget:self action:@selector(clickedItem:)];
    return self;
}
- (void)updatePropertiesIfNeeded:(SJEdgeControlButtonItem *)item videoPlayer:(__kindof SJBaseVideoPlayer *)player {
    if ( _updatePropertiesIfNeeded)  _updatePropertiesIfNeeded(item, player);
}
- (void)clickedItem:(SJEdgeControlButtonItem *)item {
    if ( _clickedItemExeBlock ) _clickedItemExeBlock(item);
}
@end





@interface SJVideoPlayer ()
@property (nonatomic, strong, readonly) SJVideoPlayerControlSettingRecorder *recorder;
@property (nonatomic, strong, readonly) id<SJPlayStatusObserver> playStatusObserver;
@property (nonatomic, strong, nullable) id<SJFloatSmallViewControllerObserverProtocol> fscObs;
@end

@implementation SJVideoPlayer {
    id<SJControlLayerSwitcherObsrever> _switcherObserver;
    
    /// common
    void(^_Nullable _clickedBackEvent)(SJVideoPlayer *player);
    BOOL _hideBackButtonWhenOrientationIsPortrait;
    
    /// default control layer
    BOOL _showMoreItemForTopControlLayer;
    NSArray<SJVideoPlayerMoreSetting *> *_Nullable _moreSettings;
    _SJEdgeControlButtonItemDelegate *_Nullable _moreItemDelegate;
    
    /// film editing control layer
    BOOL _enableFilmEditing;
    SJVideoPlayerFilmEditingConfig *_Nullable _filmEditingConfig;
    _SJEdgeControlButtonItemDelegate *_Nullable _filmEditingItemDelegate;
    SJFilmEditingControlLayer *_Nullable _defaultFilmEditingControlLayer;
}

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%d - %s", (int)__LINE__, __func__);
}
#endif

+ (NSString *)version {
    return @"v2.5.8";
}

+ (instancetype)player {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [self _init];
    if ( !self ) return nil;
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge]; // 切换到添加的控制层
    self.showNetworkSpeedToLoadingView = YES; // 显示加载网速
    self.showMoreItemForTopControlLayer = YES; // 显示更多按钮
    self.defaultEdgeControlLayer.hideBottomProgressSlider = NO; // 显示底部进度条
    return self;
}

// v2.4.0 之后删除了旧的lightweightPlayer控制层, 迁移至 defaultEdgeControlLayer
+ (instancetype)lightweightPlayer {
    SJVideoPlayer *videoPlayer = [[SJVideoPlayer alloc] _init];
    SJEdgeControlLayer *controlLayer = videoPlayer.defaultEdgeControlLayer;
    controlLayer.hideBottomProgressSlider = NO;
    controlLayer.topContainerView.sjv_disappearDirection =
    controlLayer.leftContainerView.sjv_disappearDirection =
    controlLayer.bottomContainerView.sjv_disappearDirection =
    controlLayer.rightContainerView.sjv_disappearDirection = SJViewDisappearAnimation_None;
    [controlLayer.topAdapter reload];
    [videoPlayer.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
    return videoPlayer;
}

- (instancetype)_init {
    self = [super init];
    if ( !self ) return nil;
    _switcher = [[SJControlLayerSwitcher alloc] initWithPlayer:self];
    __weak typeof(self) _self = self;
    _switcher.resolveControlLayer = ^id<SJControlLayer> _Nullable(SJControlLayerIdentifier identifier) {
        __strong typeof(_self) self = _self;
        if ( !self ) return nil;
        if ( identifier == SJControlLayer_Edge )
            return self.defaultEdgeControlLayer;
        else if ( identifier == SJControlLayer_NotReachableAndPlaybackStalled )
            return self.defaultNotReachableControlLayer;
        else if ( identifier == SJControlLayer_FilmEditing )
            return self.defaultFilmEditingControlLayer;
        else if ( identifier == SJControlLayer_MoreSettting )
            return self.defaultMoreSettingControlLayer;
        else if ( identifier == SJControlLayer_LoadFailed )
            return self.defaultLoadFailedControlLayer;
        else if ( identifier == SJControlLayer_FloatSmallView )
            return self.defaultFloatSmallViewControlLayer;
        return nil;
    };
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self _initializeSwitcherObserver];
        [self _initializeSettingsRecorder];
        [self _initializePlayStatusObserver];
    });
    [self _updateCommonProperties];
    return self;
}

// - observers -

- (void)_initializeSwitcherObserver {
    _switcherObserver = [_switcher getObserver];
    __weak typeof(self) _self = self;
    _switcherObserver.playerWillBeginSwitchControlLayer = ^(id<SJControlLayerSwitcher>  _Nonnull switcher, id<SJControlLayer>  _Nonnull controlLayer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [controlLayer respondsToSelector:@selector(setHideBackButtonWhenOrientationIsPortrait:)] ) {
            [(SJEdgeControlLayer *)controlLayer setHideBackButtonWhenOrientationIsPortrait:self.hideBackButtonWhenOrientationIsPortrait];
        }
    };
}

- (void)_initializePlayStatusObserver {
    __weak typeof(self) _self = self;
    _playStatusObserver = [self getPlayStatusObserver];
    _playStatusObserver.playStatusDidChangeExeBlock = ^(SJBaseVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        // 加载失败
        if ( [player playStatus_isInactivity_ReasonPlayFailed] ) {
            [self.switcher switchControlLayerForIdentitfier:SJControlLayer_LoadFailed];
        }
        // 无网, 无缓冲
        else if ( [player playStatus_isInactivity_ReasonNotReachableAndPlaybackStalled] ) {
            [self.switcher switchControlLayerForIdentitfier:SJControlLayer_NotReachableAndPlaybackStalled];
        }
        else if ( self.switcher.currentIdentifier == SJControlLayer_NotReachableAndPlaybackStalled ||
                  self.switcher.currentIdentifier == SJControlLayer_LoadFailed ) {
            if ( ![player playStatus_isInactivity_ReasonPlayFailed] &&
                 ![player playStatus_isInactivity_ReasonNotReachableAndPlaybackStalled] ) {
                [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
            }
        }
    };
}

- (void)_initializeSettingsRecorder {
    __weak typeof(self) _self = self;
    _recorder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _updateCommonProperties];
    }];
}

- (void)_initializeFloatSmallViewControllerObserverIfNeeded:(nullable id<SJFloatSmallViewControllerProtocol>)floatSmallViewController {
    if ( _fscObs.controller != floatSmallViewController ) {
        _fscObs = [floatSmallViewController getObserver];
        __weak typeof(self) _self = self;
        _fscObs.appearStateDidChangeExeBlock = ^(id<SJFloatSmallViewControllerProtocol>  _Nonnull controller) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( controller.isAppeared ) {
                if ( self.switcher.currentIdentifier != SJControlLayer_FloatSmallView ) {
                    [self.controlLayerDataSource.controlView removeFromSuperview];
                    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_FloatSmallView];
                }
            }
            else {
                if ( self.switcher.currentIdentifier == SJControlLayer_FloatSmallView ) {
                    [self.controlLayerDataSource.controlView removeFromSuperview];
                    [self.switcher switchToPreviousControlLayer];
                }
            }
        };
    }
}

- (void)_updateCommonProperties {
    if ( !self.placeholderImageView.image )
        self.placeholderImageView.image = SJVideoPlayerSettings.commonSettings.placeholder;
}

// - default control layers -

@synthesize defaultEdgeControlLayer = _defaultEdgeControlLayer;
- (SJEdgeControlLayer *)defaultEdgeControlLayer {
    if ( !_defaultEdgeControlLayer ) {
        _defaultEdgeControlLayer = [SJEdgeControlLayer new];
        __weak typeof(self) _self = self;
        _defaultEdgeControlLayer.clickedBackItemExeBlock = ^(SJEdgeControlLayer * _Nonnull control) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            [self _handleClickedBackButtonEvent];
        };
    }
    return _defaultEdgeControlLayer;
}

- (SJFilmEditingControlLayer *)defaultFilmEditingControlLayer {
    if ( !_defaultFilmEditingControlLayer ) {
        _defaultFilmEditingControlLayer = [SJFilmEditingControlLayer new];
        __weak typeof(self) _self = self;
        _defaultFilmEditingControlLayer.cancelledOperationExeBlock = ^(SJFilmEditingControlLayer * _Nonnull control) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            [self.switcher switchToPreviousControlLayer];
        };
    }
    return _defaultFilmEditingControlLayer;
}

@synthesize defaultMoreSettingControlLayer = _defaultMoreSettingControlLayer;
- (SJMoreSettingControlLayer *)defaultMoreSettingControlLayer {
    if ( !_defaultMoreSettingControlLayer ) {
        _defaultMoreSettingControlLayer = [SJMoreSettingControlLayer new];
        __weak typeof(self) _self = self;
        _defaultMoreSettingControlLayer.disappearExeBlock = ^(SJMoreSettingControlLayer * _Nonnull control) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            [self.switcher switchToPreviousControlLayer];
        };
    }
    return _defaultMoreSettingControlLayer;
}

@synthesize defaultLoadFailedControlLayer = _defaultLoadFailedControlLayer;
- (SJLoadFailedControlLayer *)defaultLoadFailedControlLayer {
    if ( !_defaultLoadFailedControlLayer ) {
        _defaultLoadFailedControlLayer = [SJLoadFailedControlLayer new];
        __weak typeof(self) _self = self;
        _defaultLoadFailedControlLayer.clickedBackButtonExeBlock = ^(SJLoadFailedControlLayer * _Nonnull controlLayer) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _handleClickedBackButtonEvent];
        };
        _defaultLoadFailedControlLayer.clickedReloadButtonExeBlock = ^(SJLoadFailedControlLayer * _Nonnull controlLayer) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self refresh];
            [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
        };
        _defaultLoadFailedControlLayer.prepareToPlayNewAssetExeBlock = ^(SJLoadFailedControlLayer * _Nonnull control) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
        };
    }
    return _defaultLoadFailedControlLayer;
}

@synthesize defaultNotReachableControlLayer = _defaultNotReachableControlLayer;
- (SJNotReachableControlLayer *)defaultNotReachableControlLayer {
    if ( !_defaultNotReachableControlLayer ) {
        _defaultNotReachableControlLayer = [[SJNotReachableControlLayer alloc] initWithFrame:self.view.bounds];
        __weak typeof(self) _self = self;
        _defaultNotReachableControlLayer.clickedBackButtonExeBlock = ^(SJNotReachableControlLayer * _Nonnull controlLayer) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _handleClickedBackButtonEvent];
        };
        _defaultNotReachableControlLayer.clickedReloadButtonExeBlock = ^(SJNotReachableControlLayer * _Nonnull controlLayer) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self refresh];
            [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
        };
        _defaultNotReachableControlLayer.prepareToPlayNewAssetExeBlock = ^(SJNotReachableControlLayer * _Nonnull control) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
        };
        _defaultNotReachableControlLayer.playStatusDidChangeExeBlock = ^(__kindof SJNotReachableControlLayer * _Nonnull control) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( ![self playStatus_isInactivity_ReasonNotReachableAndPlaybackStalled] ) {
                [self.switcher switchToPreviousControlLayer];
            }
        };
    }
    return _defaultNotReachableControlLayer;
}

@synthesize defaultFloatSmallViewControlLayer = _defaultFloatSmallViewControlLayer;
- (SJFloatSmallViewControlLayer *)defaultFloatSmallViewControlLayer {
    if ( _defaultFloatSmallViewControlLayer == nil ) {
        _defaultFloatSmallViewControlLayer = [[SJFloatSmallViewControlLayer alloc] initWithFrame:self.view.bounds];
    }
    return _defaultFloatSmallViewControlLayer;
}

// - actions -

- (void)_handleClickedBackButtonEvent {
    if ( self.needPresentModalViewControlller &&
         self.modalViewControllerManager.isPresentedModalViewControlller ) {
        [self dismissModalViewControlller];
    }
    else if ( self.isFullScreen &&
        ![self _whetherToSupportOnlyOneOrientation] ) {
        [self rotate];
    }
    else if ( self.isFitOnScreen ) {
        self.fitOnScreen = NO;
    }
    else {
        self.clickedBackEvent(self);
    }
}

// 播放器是否只支持一个方向
- (BOOL)_whetherToSupportOnlyOneOrientation {
    if ( self.supportedOrientation == SJAutoRotateSupportedOrientation_Portrait ) return YES;
    if ( self.supportedOrientation == SJAutoRotateSupportedOrientation_LandscapeLeft ) return YES;
    if ( self.supportedOrientation == SJAutoRotateSupportedOrientation_LandscapeRight ) return YES;
    return NO;
}

// - float small view -

- (void)setFloatSmallViewController:(nullable id<SJFloatSmallViewControllerProtocol>)floatSmallViewController {
    [super setFloatSmallViewController:floatSmallViewController];
    [self _initializeFloatSmallViewControllerObserverIfNeeded:floatSmallViewController];
}
- (id<SJFloatSmallViewControllerProtocol>)floatSmallViewController {
    id<SJFloatSmallViewControllerProtocol> floatSmallViewController = [super floatSmallViewController];
    [self _initializeFloatSmallViewControllerObserverIfNeeded:floatSmallViewController];
    return floatSmallViewController;
}

@end


@implementation SJVideoPlayer (CommonSettings)
+ (void (^)(void (^ _Nonnull)(SJVideoPlayerSettings * _Nonnull)))update {
    return SJVideoPlayerSettings.update;
}

+ (void)resetSetting {
    SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {
        [commonSettings reset];
    });
}

- (void)setClickedBackEvent:(nullable void (^)(SJVideoPlayer * _Nonnull))clickedBackEvent {
    _clickedBackEvent = clickedBackEvent;
}

- (void (^)(SJVideoPlayer * _Nonnull))clickedBackEvent {
    if ( _clickedBackEvent )
        return _clickedBackEvent;
    return ^ (SJVideoPlayer *player) {
        UIViewController *vc = [player atViewController];
        [vc.view endEditing:YES];
        if ( vc.presentingViewController ) {
            [vc dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [vc.navigationController popViewControllerAnimated:YES];
        }
    };
}
@end



@implementation SJVideoPlayer (SettingLightweightControlLayer)

@end


#pragma mark -
@implementation SJVideoPlayer (SettingDefaultControlLayer)

- (void)setShowNetworkSpeedToLoadingView:(BOOL)showNetworkSpeedToLoadingView {
    [self defaultEdgeControlLayer].showNetworkSpeedToLoadingView = showNetworkSpeedToLoadingView;
}
- (BOOL)showNetworkSpeedToLoadingView {
    return [self defaultEdgeControlLayer].showNetworkSpeedToLoadingView;
}

- (void)setDisablePromptWhenNetworkStatusChanges:(BOOL)disablePromptWhenNetworkStatusChanges {
    [self defaultEdgeControlLayer].disablePromptWhenNetworkStatusChanges = disablePromptWhenNetworkStatusChanges;
}
- (BOOL)disablePromptWhenNetworkStatusChanges {
    return [self defaultEdgeControlLayer].disablePromptWhenNetworkStatusChanges;
}

- (void)setHideBottomProgressSlider:(BOOL)hideBottomProgressSlider {
    self.defaultEdgeControlLayer.hideBottomProgressSlider = hideBottomProgressSlider;
}
- (BOOL)hideBottomProgressSlider {
    return self.defaultEdgeControlLayer.hideBottomProgressSlider;
}

- (void)setShowResidentBackButton:(BOOL)showResidentBackButton {
    self.defaultEdgeControlLayer.showResidentBackButton = showResidentBackButton;
}
- (BOOL)showResidentBackButton {
    return self.defaultEdgeControlLayer.showResidentBackButton;
}

- (void)setHideBackButtonWhenOrientationIsPortrait:(BOOL)hideBackButtonWhenOrientationIsPortrait {
    _hideBackButtonWhenOrientationIsPortrait = hideBackButtonWhenOrientationIsPortrait;

    id<SJControlLayer> controlLayer = [self.switcher controlLayerForIdentifier:self.switcher.currentIdentifier];
    if ( [controlLayer respondsToSelector:@selector(setHideBackButtonWhenOrientationIsPortrait:)] ) {
        [(SJEdgeControlLayer *)controlLayer setHideBackButtonWhenOrientationIsPortrait:self.hideBackButtonWhenOrientationIsPortrait];
    }
}
- (BOOL)hideBackButtonWhenOrientationIsPortrait {
    return _hideBackButtonWhenOrientationIsPortrait;
}

- (void)setMoreSettings:(nullable NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    [self defaultMoreSettingControlLayer].moreSettings = moreSettings;
}

- (nullable NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    return [self defaultMoreSettingControlLayer].moreSettings;
}

- (void)setShowMoreItemForTopControlLayer:(BOOL)showMoreItemForTopControlLayer {
    if ( showMoreItemForTopControlLayer == _showMoreItemForTopControlLayer )
        return;
    _showMoreItemForTopControlLayer = showMoreItemForTopControlLayer;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( showMoreItemForTopControlLayer ) {
            [self.defaultEdgeControlLayer.topAdapter addItem:[self moreItemDelegate].item];
        }
        else {
            [self.defaultEdgeControlLayer.topAdapter removeItemForTag:SJEdgeControlLayerTopItem_More];
            [self.switcher deleteControlLayerForIdentifier:SJControlLayer_MoreSettting];
        }
        
        [self.defaultEdgeControlLayer.topAdapter reload];
    });
    
}
- (BOOL)showMoreItemForTopControlLayer {
    return _showMoreItemForTopControlLayer;
}

- (_SJEdgeControlButtonItemDelegate *)moreItemDelegate {
    if ( _moreItemDelegate )
        return _moreItemDelegate;
    _moreItemDelegate = [[_SJEdgeControlButtonItemDelegate alloc] initWithItem:[SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerTopItem_More]];
    _moreItemDelegate.item.image = SJVideoPlayerSettings.commonSettings.moreBtnImage;
    _moreItemDelegate.updatePropertiesIfNeeded = ^(SJEdgeControlButtonItem * _Nonnull item, __kindof SJBaseVideoPlayer * _Nonnull player) {
        item.hidden = !player.isFullScreen;
        item.image = SJVideoPlayerSettings.commonSettings.moreBtnImage;
    };
    
    __weak typeof(self) _self = self;
    _moreItemDelegate.clickedItemExeBlock = ^(SJEdgeControlButtonItem * _Nonnull item) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.switcher switchControlLayerForIdentitfier:SJControlLayer_MoreSettting];
    };
    return _moreItemDelegate;
}
@end


@implementation SJVideoPlayer (FilmEditing)
- (void)setEnableFilmEditing:(BOOL)enableFilmEditing {
    if ( enableFilmEditing == _enableFilmEditing ) return;
    _enableFilmEditing = enableFilmEditing;
    
    /// 默认的边缘控制层
    if ( enableFilmEditing ) {
        // 将item加入到边缘控制层中
        [[self defaultEdgeControlLayer].rightAdapter addItem:[self filmEditingItemDelegate].item];
    }
    else {
        // 移除
        [[self defaultEdgeControlLayer].rightAdapter removeItemForTag:SJEdgeControlLayerBottomItem_FilmEditing];
        [self.switcher deleteControlLayerForIdentifier:SJControlLayer_FilmEditing];
        _defaultFilmEditingControlLayer = nil;
    }
    
    [[self defaultEdgeControlLayer].rightAdapter reload];
}
- (BOOL)enableFilmEditing {
    return _enableFilmEditing;
}

- (SJVideoPlayerFilmEditingConfig *)filmEditingConfig {
    if ( _filmEditingConfig ) return _filmEditingConfig;
    return _filmEditingConfig = [SJVideoPlayerFilmEditingConfig new];
}

- (void)dismissFilmEditingViewCompletion:(void(^__nullable)(SJVideoPlayer *player))completion {
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
    if ( completion ) completion(self);
}

- (_SJEdgeControlButtonItemDelegate *)filmEditingItemDelegate {
    if ( _filmEditingItemDelegate )
        return _filmEditingItemDelegate;
    
    _filmEditingItemDelegate = [[_SJEdgeControlButtonItemDelegate alloc] initWithItem:[SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerBottomItem_FilmEditing]];
    _filmEditingItemDelegate.item.image = SJVideoPlayerSettings.commonSettings.filmEditingBtnImage;
    _filmEditingItemDelegate.updatePropertiesIfNeeded = ^(SJEdgeControlButtonItem * _Nonnull item, __kindof SJBaseVideoPlayer * _Nonnull player) {
        // 小屏或者 M3U8的时候 自动隐藏
        // M3u8 暂时无法剪辑
        item.hidden = (!player.isFullScreen || player.URLAsset.isM3u8) || !player.URLAsset;
        item.image = SJVideoPlayerSettings.commonSettings.filmEditingBtnImage;
    };
    
    __weak typeof(self) _self = self;
    _filmEditingItemDelegate.clickedItemExeBlock = ^(SJEdgeControlButtonItem * _Nonnull item) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self defaultFilmEditingControlLayer].config = self.filmEditingConfig;
        [self switchControlLayerForIdentitfier:SJControlLayer_FilmEditing];
    };
    return _filmEditingItemDelegate;
}
@end


@implementation SJVideoPlayer (SwitcherExtension)
- (void)switchControlLayerForIdentitfier:(SJControlLayerIdentifier)identifier {
    [self.switcher switchControlLayerForIdentitfier:identifier];
}
@end

SJControlLayerIdentifier const SJControlLayer_Edge = LONG_MAX - 1;
SJControlLayerIdentifier const SJControlLayer_FilmEditing = LONG_MAX - 2;
SJControlLayerIdentifier const SJControlLayer_MoreSettting = LONG_MAX - 3;
SJControlLayerIdentifier const SJControlLayer_LoadFailed = LONG_MAX - 4;
SJControlLayerIdentifier const SJControlLayer_NotReachableAndPlaybackStalled = LONG_MAX - 5;
SJControlLayerIdentifier const SJControlLayer_FloatSmallView = LONG_MAX - 6;

SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_FilmEditing = LONG_MAX - 1;   // GIF/导出/截屏
SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_More = LONG_MAX - 2;             // More


@implementation SJVideoPlayer (SJVideoPlayerDeprecated)

- (void)setDisableNetworkStatusChangePrompt:(BOOL)disableNetworkStatusChangePrompt __deprecated_msg("use `disablePromptWhenNetworkStatusChanges`") {
    [self setDisablePromptWhenNetworkStatusChanges:disableNetworkStatusChangePrompt];
}
- (BOOL)disableNetworkStatusChangePrompt __deprecated_msg("use `disablePromptWhenNetworkStatusChanges`") {
    return [self disablePromptWhenNetworkStatusChanges];
}


- (void)setGeneratePreviewImages:(BOOL)generatePreviewImages __deprecated_msg("use `此功能已移除, 设置将无效`") {
}
- (BOOL)generatePreviewImages __deprecated_msg("use `此功能已移除, 设置将无效`") {
    return NO;
}

- (nullable SJEdgeControlLayer *)defaultEdgeLightweightControlLayer __deprecated_msg("use `defaultEdgeControlLayer`") {
    return self.defaultEdgeControlLayer;
}
- (void)setTopControlItems:(nullable NSArray<SJLightweightTopItem *> *)topControlItems __deprecated_msg("use [player.defaultEdgeControlLayer.topAdapter addItem:item];") {
    objc_setAssociatedObject(self, @selector(topControlItems), topControlItems, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [topControlItems enumerateObjectsUsingBlock:^(SJLightweightTopItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SJEdgeControlButtonItem *item = [[SJEdgeControlButtonItem alloc] initWithImage:[UIImage imageNamed:obj.imageName] target:self action:@selector(_handleLightweightTopItemClickedEvent:) tag:obj.flag];
        [self.defaultEdgeControlLayer.topAdapter addItem:item];
    }];
    [self.defaultEdgeControlLayer.topAdapter reload];
}
- (nullable NSArray<SJLightweightTopItem *> *)topControlItems __deprecated_msg("use [player.defaultEdgeControlLayer.topAdapter addItem:item];") {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setClickedTopControlItemExeBlock:(nullable void (^)(SJVideoPlayer * _Nonnull, SJLightweightTopItem * _Nonnull))clickedTopControlItemExeBlock __deprecated {
    objc_setAssociatedObject(self, @selector(clickedTopControlItemExeBlock), clickedTopControlItemExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (nullable void (^)(SJVideoPlayer * _Nonnull, SJLightweightTopItem * _Nonnull))clickedTopControlItemExeBlock __deprecated {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)_handleLightweightTopItemClickedEvent:(SJEdgeControlButtonItem *)item __deprecated {
    SJLightweightTopItem *topItem = nil;
    for ( SJLightweightTopItem *i in self.topControlItems ) {
        if ( i.flag == item.tag ) {
            topItem = i;
            break;
        }
    }
    if ( self.clickedTopControlItemExeBlock ) self.clickedTopControlItemExeBlock(self, topItem);
}
- (void)setResumePlaybackWhenPlayerViewScrollAppears:(BOOL)resumePlaybackWhenPlayerViewScrollAppears {
    self.resumePlaybackWhenScrollAppeared = resumePlaybackWhenPlayerViewScrollAppears;
}
- (BOOL)resumePlaybackWhenPlayerViewScrollAppears {
    return self.resumePlaybackWhenScrollAppeared;
}
@end
NS_ASSUME_NONNULL_END
