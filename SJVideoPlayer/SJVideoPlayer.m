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

#if __has_include(<SJUIKit/SJAttributesFactory.h>)
#import <SJUIKit/SJAttributesFactory.h>
#else
#import "SJAttributesFactory.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayer ()<SJSwitchVideoDefinitionControlLayerDelegate, SJMoreSettingControlLayerDelegate, SJNotReachableControlLayerDelegate>
@property (nonatomic, strong, readonly) SJVideoPlayerControlSettingRecorder *recorder;

@property (nonatomic, strong, nullable) id<SJFloatSmallViewControllerObserverProtocol> sj_floatSmallViewControllerObserver;
@property (nonatomic, strong, readonly) SJVideoDefinitionSwitchingInfoObserver *sj_switchingInfoObserver;
@property (nonatomic, strong, readonly) id<SJControlLayerAppearManagerObserver> sj_appearManagerObserver;
@property (nonatomic, strong, readonly) id<SJControlLayerSwitcherObsrever> sj_switcherObserver;
@property (nonatomic, strong, readonly) id<SJPlayStatusObserver> sj_playStatusObserver;

@property (nonatomic, strong, nullable) SJEdgeControlButtonItem *moreButtonItem;
@property (nonatomic, strong, nullable) SJEdgeControlButtonItem *filmEditingButtonItem;
@property (nonatomic, strong, nullable) SJEdgeControlButtonItem *definitionButtonItem;
@end

@implementation SJVideoPlayer
#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%d - %s", (int)__LINE__, __func__);
}
#endif

+ (NSString *)version {
    return @"v2.6.4";
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
    [self _initializeSwitcher];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self _initializeSwitcherObserver];
        [self _initializeSettingsRecorder];
        [self _initializePlayStatusObserver];
        [self _initializeAppearManagerObserver];
    });
    [self _updateCommonProperties];
    return self;
}

// - initialize -

- (void)_initializeSwitcher {
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
        else if ( identifier == SJControlLayer_SwitchVideoDefinition )
            return self.defaultSwitchVideoDefinitionControlLayer;
        return nil;
    };
}

- (void)_initializeSwitcherObserver {
    _sj_switcherObserver = [_switcher getObserver];
    __weak typeof(self) _self = self;
    _sj_switcherObserver.playerWillBeginSwitchControlLayer = ^(id<SJControlLayerSwitcher>  _Nonnull switcher, id<SJControlLayer>  _Nonnull controlLayer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [controlLayer respondsToSelector:@selector(setHideBackButtonWhenOrientationIsPortrait:)] ) {
            [(SJEdgeControlLayer *)controlLayer setHideBackButtonWhenOrientationIsPortrait:self.hideBackButtonWhenOrientationIsPortrait];
        }
    };
}

- (void)_initializePlayStatusObserver {
    __weak typeof(self) _self = self;
    _sj_playStatusObserver = [self getPlayStatusObserver];
    _sj_playStatusObserver.playStatusDidChangeExeBlock = ^(SJBaseVideoPlayer * _Nonnull player) {
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
    if ( _sj_floatSmallViewControllerObserver.controller != floatSmallViewController ) {
        _sj_floatSmallViewControllerObserver = [floatSmallViewController getObserver];
        __weak typeof(self) _self = self;
        _sj_floatSmallViewControllerObserver.appearStateDidChangeExeBlock = ^(id<SJFloatSmallViewControllerProtocol>  _Nonnull controller) {
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

- (void)_initializeAppearManagerObserver {
    _sj_appearManagerObserver = [self.controlLayerAppearManager getObserver];
    
    __weak typeof(self) _self = self;
    _sj_appearManagerObserver.appearStateDidChangeExeBlock = ^(id<SJControlLayerAppearManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        
        // refresh edge button items
        
        if ( self.switcher.currentIdentifier == SJControlLayer_Edge ) {
            // more item
            self.moreButtonItem.hidden = !self.isFullScreen;
            self.moreButtonItem.image = SJVideoPlayerSettings.commonSettings.moreBtnImage;
            
            // film editing item
            // 小屏或者 M3U8的时候 自动隐藏
            // M3u8 暂时无法剪辑
            self.filmEditingButtonItem.hidden = (!self.isFullScreen || self.URLAsset.isM3u8) || !self.URLAsset;
            self.filmEditingButtonItem.image = SJVideoPlayerSettings.commonSettings.filmEditingBtnImage;
            
            // definition item
            self.definitionButtonItem.title = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                SJVideoPlayerURLAsset *asset = self.definitionSwitchingInfo.switchingAsset?:self.URLAsset;
                make.append(asset.definition_lastName);
                make.textColor(UIColor.whiteColor);
            }];
        }
    };
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

@synthesize defaultFilmEditingControlLayer = _defaultFilmEditingControlLayer;
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
        _defaultMoreSettingControlLayer.delegate = self;
    }
    return _defaultMoreSettingControlLayer;
}

@synthesize defaultLoadFailedControlLayer = _defaultLoadFailedControlLayer;
- (SJLoadFailedControlLayer *)defaultLoadFailedControlLayer {
    if ( !_defaultLoadFailedControlLayer ) {
        _defaultLoadFailedControlLayer = [SJLoadFailedControlLayer new];
        _defaultLoadFailedControlLayer.delegate = self;
    }
    return _defaultLoadFailedControlLayer;
}

@synthesize defaultNotReachableControlLayer = _defaultNotReachableControlLayer;
- (SJNotReachableControlLayer *)defaultNotReachableControlLayer {
    if ( !_defaultNotReachableControlLayer ) {
        _defaultNotReachableControlLayer = [[SJNotReachableControlLayer alloc] initWithFrame:self.view.bounds];
        _defaultNotReachableControlLayer.delegate = self;
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

@synthesize defaultSwitchVideoDefinitionControlLayer = _defaultSwitchVideoDefinitionControlLayer;
- (SJSwitchVideoDefinitionControlLayer *)defaultSwitchVideoDefinitionControlLayer {
    if ( _defaultSwitchVideoDefinitionControlLayer == nil ) {
        _defaultSwitchVideoDefinitionControlLayer = [[SJSwitchVideoDefinitionControlLayer alloc] initWithFrame:self.view.bounds];
        _defaultSwitchVideoDefinitionControlLayer.delegate = self;
    }
    return _defaultSwitchVideoDefinitionControlLayer;
}

@synthesize sj_switchingInfoObserver = _sj_switchingInfoObserver;
- (SJVideoDefinitionSwitchingInfoObserver *)sj_switchingInfoObserver {
    if ( _sj_switchingInfoObserver == nil ) {
        _sj_switchingInfoObserver = [self.definitionSwitchingInfo getObserver];
        __weak typeof(self) _self = self;
        _sj_switchingInfoObserver.statusDidChangeExeBlock = ^(SJVideoDefinitionSwitchingInfo * _Nonnull info) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            switch ( info.status ) {
                case SJMediaPlaybackSwitchDefinitionStatusUnknown:
                    break;
                case SJMediaPlaybackSwitchDefinitionStatusSwitching: {
                    [self.popPromptController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                        make.append(@"切换中, 请稍等");
                        make.textColor(UIColor.whiteColor);
                    }]];
                }
                    break;
                case SJMediaPlaybackSwitchDefinitionStatusFinished: {
                    [self.popPromptController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                        make.append([NSString stringWithFormat:@"已成功切换至 %@", self.URLAsset.definition_lastName]);
                        make.textColor(UIColor.whiteColor);
                    }]];
                }
                    break;
                case SJMediaPlaybackSwitchDefinitionStatusFailed: {
                    [self.popPromptController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                        make.append(@"切换失败");
                        make.textColor(UIColor.whiteColor);
                    }]];
                }
                    break;
            }
        };
    }
    return _sj_switchingInfoObserver;
}

// - actions -

- (void)clickedMoreButtonItem:(SJEdgeControlButtonItem *)moreButtonItem {
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_MoreSettting];
}

- (void)clickedFilmEditingItem:(SJEdgeControlButtonItem *)filmEditingItem {
    self.defaultFilmEditingControlLayer.config = self.filmEditingConfig;
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_FilmEditing];
}

- (void)clickedDefinitionButtonItem:(SJEdgeControlButtonItem *)definitionButtonItem {
    self.defaultSwitchVideoDefinitionControlLayer.assets = self.definitionURLAssets;
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_SwitchVideoDefinition];
}

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

// - switch video definition -

- (void)controlLayer:(SJSwitchVideoDefinitionControlLayer *)controlLayer didSelectAsset:(SJVideoPlayerURLAsset *)asset {
    if ( asset != self.URLAsset ) {
        [self sj_switchingInfoObserver];
        [self switchVideoDefinition:asset];
    }
    [self.switcher switchToPreviousControlLayer];
}

- (void)tappedBlankAreaOnTheControlLayer:(id<SJControlLayer>)controlLayer {
    [self.switcher switchToPreviousControlLayer];
}

- (void)tappedBackButtonOnTheControlLayer:(id<SJControlLayer>)controlLayer {
    [self _handleClickedBackButtonEvent];
}

- (void)tappedReloadButtonOnTheControlLayer:(id<SJControlLayer>)controlLayer {
    [self refresh];
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
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
    objc_setAssociatedObject(self, @selector(clickedBackEvent), clickedBackEvent, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(SJVideoPlayer * _Nonnull))clickedBackEvent {
    id _Nullable value = objc_getAssociatedObject(self, _cmd);
    if ( value != nil ) {
        return value;
    }
    
    return ^ (SJVideoPlayer *player) {
        UIViewController *vc = _atViewController(player.view);
        [vc.view endEditing:YES];
        if ( vc.presentingViewController ) {
            [vc dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [vc.navigationController popViewControllerAnimated:YES];
        }
    };
}

static inline __kindof UIViewController *_Nullable
_atViewController(UIView *view) {
    UIResponder *_Nullable responder = view;
    if ( responder != nil ) {
        while ( ![responder isKindOfClass:[UIViewController class]] ) {
            responder = responder.nextResponder;
            if ( [responder isMemberOfClass:[UIResponder class]] || !responder ) return nil;
        }
    }
    return (__kindof UIViewController *)responder;
}
@end



#pragma mark -
@implementation SJVideoPlayer (SettingSwitchVideoDefinitionControlLayer)

- (void)setDefinitionURLAssets:(nullable NSArray<SJVideoPlayerURLAsset *> *)definitionURLAssets {
    objc_setAssociatedObject(self, @selector(definitionURLAssets), definitionURLAssets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( definitionURLAssets != nil ) {
            self.definitionButtonItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49xAutoresizing tag:SJEdgeControlLayerBottomItem_Definition];
            [self.definitionButtonItem addTarget:self action:@selector(clickedDefinitionButtonItem:)];
            [self.defaultEdgeControlLayer.bottomAdapter insertItem:self.definitionButtonItem rearItem:SJEdgeControlLayerBottomItem_FullBtn];
        }
        else {
            self.definitionButtonItem = nil;
            [self.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_Definition];
            [self.switcher deleteControlLayerForIdentifier:SJControlLayer_SwitchVideoDefinition];
        }
        
        [self.defaultEdgeControlLayer.bottomAdapter reload];
    });
}

- (nullable NSArray<SJVideoPlayerURLAsset *> *)definitionURLAssets {
    return objc_getAssociatedObject(self, _cmd);
}

@end


#pragma mark -
@implementation SJVideoPlayer (SettingDefaultControlLayer)

- (void)setShowNetworkSpeedToLoadingView:(BOOL)showNetworkSpeedToLoadingView {
    self.defaultEdgeControlLayer.showNetworkSpeedToLoadingView = showNetworkSpeedToLoadingView;
}
- (BOOL)showNetworkSpeedToLoadingView {
    return self.defaultEdgeControlLayer.showNetworkSpeedToLoadingView;
}

- (void)setDisablePromptWhenNetworkStatusChanges:(BOOL)disablePromptWhenNetworkStatusChanges {
    self.defaultEdgeControlLayer.disablePromptWhenNetworkStatusChanges = disablePromptWhenNetworkStatusChanges;
}
- (BOOL)disablePromptWhenNetworkStatusChanges {
    return self.defaultEdgeControlLayer.disablePromptWhenNetworkStatusChanges;
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
    if ( hideBackButtonWhenOrientationIsPortrait != self.hideBackButtonWhenOrientationIsPortrait ) {
        objc_setAssociatedObject(self, @selector(hideBackButtonWhenOrientationIsPortrait), @(hideBackButtonWhenOrientationIsPortrait), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        id<SJControlLayer> controlLayer = [self.switcher controlLayerForIdentifier:self.switcher.currentIdentifier];
        if ( [controlLayer respondsToSelector:@selector(setHideBackButtonWhenOrientationIsPortrait:)] ) {
            [(SJEdgeControlLayer *)controlLayer setHideBackButtonWhenOrientationIsPortrait:hideBackButtonWhenOrientationIsPortrait];
        }
    }
}
- (BOOL)hideBackButtonWhenOrientationIsPortrait {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setShowMoreItemForTopControlLayer:(BOOL)showMoreItemForTopControlLayer {
    if ( showMoreItemForTopControlLayer != self.showMoreItemForTopControlLayer ) {
        objc_setAssociatedObject(self, @selector(showMoreItemForTopControlLayer), @(showMoreItemForTopControlLayer), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( showMoreItemForTopControlLayer ) {
                self.moreButtonItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerTopItem_More];
                [self.moreButtonItem addTarget:self action:@selector(clickedMoreButtonItem:)];
                [self.defaultEdgeControlLayer.topAdapter addItem:self.moreButtonItem];
            }
            else {
                self.moreButtonItem = nil;
                [self.defaultEdgeControlLayer.topAdapter removeItemForTag:SJEdgeControlLayerTopItem_More];
                [self.switcher deleteControlLayerForIdentifier:SJControlLayer_MoreSettting];
            }
            
            [self.defaultEdgeControlLayer.topAdapter reload];
        });
    }
}
- (BOOL)showMoreItemForTopControlLayer {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end


@implementation SJVideoPlayer (SettingFilmEditingControlLayer)
- (void)setEnableFilmEditing:(BOOL)enableFilmEditing {
    if ( enableFilmEditing != self.enableFilmEditing ) {
        objc_setAssociatedObject(self, @selector(enableFilmEditing), @(enableFilmEditing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        dispatch_async(dispatch_get_main_queue(), ^{
            if ( enableFilmEditing ) {
                self.filmEditingButtonItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerBottomItem_FilmEditing];
                [self.filmEditingButtonItem addTarget:self action:@selector(clickedFilmEditingItem:)];
                [self.defaultEdgeControlLayer.rightAdapter addItem:self.filmEditingButtonItem];
            }
            else {
                self->_defaultFilmEditingControlLayer = nil;
                self.filmEditingButtonItem = nil;
                [self.defaultEdgeControlLayer.rightAdapter removeItemForTag:SJEdgeControlLayerBottomItem_FilmEditing];
                [self.switcher deleteControlLayerForIdentifier:SJControlLayer_FilmEditing];
            }
            
            [self.defaultEdgeControlLayer.rightAdapter reload];
        });
    }
}
- (BOOL)enableFilmEditing {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (SJVideoPlayerFilmEditingConfig *)filmEditingConfig {
    SJVideoPlayerFilmEditingConfig *_Nullable filmEditingConfig = objc_getAssociatedObject(self, _cmd);
    if ( filmEditingConfig == nil ) {
        filmEditingConfig = [SJVideoPlayerFilmEditingConfig new];
        objc_setAssociatedObject(self, _cmd, filmEditingConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return filmEditingConfig;
}
@end


@implementation SJVideoPlayer (SwitcherExtension)
- (void)switchControlLayerForIdentitfier:(SJControlLayerIdentifier)identifier {
    [self.switcher switchControlLayerForIdentitfier:identifier];
}
@end

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

- (void)dismissFilmEditingViewCompletion:(void(^__nullable)(SJVideoPlayer *player))completion {
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
    if ( completion ) completion(self);
}
@end

SJControlLayerIdentifier const SJControlLayer_Edge = LONG_MAX - 1;
SJControlLayerIdentifier const SJControlLayer_FilmEditing = LONG_MAX - 2;
SJControlLayerIdentifier const SJControlLayer_MoreSettting = LONG_MAX - 3;
SJControlLayerIdentifier const SJControlLayer_LoadFailed = LONG_MAX - 4;
SJControlLayerIdentifier const SJControlLayer_NotReachableAndPlaybackStalled = LONG_MAX - 5;
SJControlLayerIdentifier const SJControlLayer_FloatSmallView = LONG_MAX - 6;
SJControlLayerIdentifier const SJControlLayer_SwitchVideoDefinition = LONG_MAX - 7;

SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_FilmEditing = LONG_MAX - 1;   // GIF/导出/截屏
SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_More = LONG_MAX - 2;             // More
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Definition = LONG_MAX - 3;
NS_ASSUME_NONNULL_END
