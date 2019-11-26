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

#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayerConst.h>
#import <SJBaseVideoPlayer/SJReachability.h>
#else
#import "SJReachability.h"
#import "SJBaseVideoPlayer.h"
#import "SJBaseVideoPlayerConst.h"
#endif

#if __has_include(<SJUIKit/SJAttributesFactory.h>)
#import <SJUIKit/SJAttributesFactory.h>
#else
#import "SJAttributesFactory.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayer ()<SJSwitchVideoDefinitionControlLayerDelegate, SJMoreSettingControlLayerDelegate, SJNotReachableControlLayerDelegate, SJEdgeControlLayerDelegate>
@property (nonatomic, strong, readonly) SJVideoPlayerControlSettingRecorder *recorder;

@property (nonatomic, strong, nullable) id<SJFloatSmallViewControllerObserverProtocol> sj_floatSmallViewControllerObserver;
@property (nonatomic, strong, readonly) SJVideoDefinitionSwitchingInfoObserver *sj_switchingInfoObserver;
@property (nonatomic, strong, readonly) id<SJControlLayerAppearManagerObserver> sj_appearManagerObserver;
@property (nonatomic, strong, readonly) id<SJControlLayerSwitcherObsrever> sj_switcherObserver;

@property (nonatomic, strong, nullable) SJEdgeControlButtonItem *moreButtonItem;
@property (nonatomic, strong, nullable) SJEdgeControlButtonItem *filmEditingButtonItem;
@property (nonatomic, strong, nullable) SJEdgeControlButtonItem *definitionButtonItem;
@end

@implementation SJVideoPlayer
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
}

+ (NSString *)version {
    return @"v3.0.9";
}

+ (instancetype)player {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [self _init];
    if ( !self ) return nil;
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge]; // 切换到添加的控制层
    self.showMoreItemToTopControlLayer = YES; // 显示更多按钮
    self.defaultEdgeControlLayer.hiddenBottomProgressIndicator = NO; // 显示底部进度条
    self.defaultEdgeControlLayer.showNetworkSpeedToLoadingView = YES; // 显示网速
    return self;
}

// v2.4.0 之后删除了旧的lightweightPlayer控制层, 迁移至 defaultEdgeControlLayer
+ (instancetype)lightweightPlayer {
    SJVideoPlayer *videoPlayer = [[SJVideoPlayer alloc] _init];
    SJEdgeControlLayer *controlLayer = videoPlayer.defaultEdgeControlLayer;
    controlLayer.hiddenBottomProgressIndicator = NO;
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
        [self _initializeAssetStatusObserver];
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
        if ( [controlLayer respondsToSelector:@selector(setHiddenBackButtonWhenOrientationIsPortrait:)] ) {
            [(SJEdgeControlLayer *)controlLayer setHiddenBackButtonWhenOrientationIsPortrait:self.defaultEdgeControlLayer.isHiddenBackButtonWhenOrientationIsPortrait];
        }
    };
}

- (void)_initializeAssetStatusObserver {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_switchControlLayerIfNeeded) name:SJVideoPlayerPlaybackTimeControlStatusDidChangeNotification object:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_switchControlLayerIfNeeded) name:SJVideoPlayerAssetStatusDidChangeNotification object:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_switchControlLayerIfNeeded) name:SJVideoPlayerDidPlayToEndTimeNotification object:self];
}

- (void)_initializeSettingsRecorder {
    __weak typeof(self) _self = self;
    _recorder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _updateCommonProperties];
    }];
}

- (void)_initializeFloatSmallViewControllerObserverIfNeeded:(nullable id<SJFloatSmallViewController>)floatSmallViewController {
    if ( _sj_floatSmallViewControllerObserver.controller != floatSmallViewController ) {
        _sj_floatSmallViewControllerObserver = [floatSmallViewController getObserver];
        __weak typeof(self) _self = self;
        _sj_floatSmallViewControllerObserver.appearStateDidChangeExeBlock = ^(id<SJFloatSmallViewController>  _Nonnull controller) {
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
                SJVideoPlayerURLAsset *asset = self.URLAsset;
                if ( self.definitionSwitchingInfo.switchingAsset != nil &&
                     self.definitionSwitchingInfo.status != SJDefinitionSwitchStatusFailed ) {
                    asset = self.definitionSwitchingInfo.switchingAsset;
                }
                make.append(asset.definition_lastName);
                make.textColor(UIColor.whiteColor);
            }];
            
            [self.defaultEdgeControlLayer.rightAdapter reload];
        }
    };
}

- (void)_updateCommonProperties {
    if ( !self.presentView.placeholderImageView.image )
        self.presentView.placeholderImageView.image = SJVideoPlayerSettings.commonSettings.placeholder;
}

// - default control layers -

@synthesize defaultEdgeControlLayer = _defaultEdgeControlLayer;
- (SJEdgeControlLayer *)defaultEdgeControlLayer {
    if ( !_defaultEdgeControlLayer ) {
        _defaultEdgeControlLayer = [SJEdgeControlLayer new];
        _defaultEdgeControlLayer.delegate = self;
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
                case SJDefinitionSwitchStatusUnknown:
                    break;
                case SJDefinitionSwitchStatusSwitching: {
                    [self.popPromptController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                        make.append(@"切换中, 请稍等");
                        make.textColor(UIColor.whiteColor);
                    }]];
                }
                    break;
                case SJDefinitionSwitchStatusFinished: {
                    [self.popPromptController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                        make.append([NSString stringWithFormat:@"已成功切换至 %@", self.URLAsset.definition_lastName]);
                        make.textColor(UIColor.whiteColor);
                    }]];
                }
                    break;
                case SJDefinitionSwitchStatusFailed: {
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

- (void)_switchControlLayerIfNeeded {
    // 资源出错时
    // - 发生错误时, 切换到加载失败控制层
    //
    if ( self.assetStatus == SJAssetStatusFailed ) {
        [self.switcher switchControlLayerForIdentitfier:SJControlLayer_LoadFailed];
    }
    // 当处于缓冲状态时
    // - 当前如果没有网络, 则切换到无网空制层
    //
    else if ( self.reasonForWaitingToPlay == SJWaitingToMinimizeStallsReason ) {
        if ( SJReachability.shared.networkStatus == SJNetworkStatus_NotReachable && !self.assetURL.isFileURL ) {
            // 切换
            [self.switcher switchControlLayerForIdentitfier:SJControlLayer_NotReachableAndPlaybackStalled];
        }
    }
    else {
        if ( self.switcher.currentIdentifier == SJControlLayer_LoadFailed ||
             self.switcher.currentIdentifier == SJControlLayer_NotReachableAndPlaybackStalled ) {
            [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
        }
    }
}

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
    if ( self.isFullScreen &&
        ![self _whetherToSupportOnlyOneOrientation] ) {
        [self rotate];
    }
    else if ( self.isFitOnScreen ) {
        self.fitOnScreen = NO;
    }
    else {
        UIViewController *vc = _atViewController(self.view);
        [vc.view endEditing:YES];
        if ( vc.presentingViewController ) {
            [vc dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [vc.navigationController popViewControllerAnimated:YES];
        }
    }
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

// 播放器是否只支持一个方向
- (BOOL)_whetherToSupportOnlyOneOrientation {
    if ( self.rotationManager.autorotationSupportedOrientations == SJOrientationMaskPortrait ) return YES;
    if ( self.rotationManager.autorotationSupportedOrientations == SJOrientationMaskLandscapeLeft ) return YES;
    if ( self.rotationManager.autorotationSupportedOrientations == SJOrientationMaskLandscapeRight ) return YES;
    return NO;
}

// - float small view -

- (void)setFloatSmallViewController:(nullable id<SJFloatSmallViewController>)floatSmallViewController {
    [super setFloatSmallViewController:floatSmallViewController];
    [self _initializeFloatSmallViewControllerObserverIfNeeded:floatSmallViewController];
}
- (id<SJFloatSmallViewController>)floatSmallViewController {
    id<SJFloatSmallViewController> floatSmallViewController = [super floatSmallViewController];
    [self _initializeFloatSmallViewControllerObserverIfNeeded:floatSmallViewController];
    return floatSmallViewController;
}

// - switch video definition -

- (void)controlLayer:(SJSwitchVideoDefinitionControlLayer *)controlLayer didSelectAsset:(SJVideoPlayerURLAsset *)asset {
    SJVideoPlayerURLAsset *selected = self.URLAsset;
    SJVideoDefinitionSwitchingInfo *info = self.definitionSwitchingInfo;
    if ( info.switchingAsset != nil && info.status != SJDefinitionSwitchStatusFailed ) {
        selected = info.switchingAsset;
    }
    
    if ( asset != selected ) {
        [self sj_switchingInfoObserver];
        [self switchVideoDefinition:asset];
    }
    [self.switcher switchToPreviousControlLayer];
}

- (void)tappedBlankAreaOnTheControlLayer:(id<SJControlLayer>)controlLayer {
    [self.switcher switchToPreviousControlLayer];
}

- (void)backItemWasTappedForControlLayer:(id<SJControlLayer>)controlLayer {
    [self _handleClickedBackButtonEvent];
}

- (void)reloadItemWasTappedForControlLayer:(id<SJControlLayer>)controlLayer {
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
@end



#pragma mark -
@implementation SJVideoPlayer (SJExtendedSwitchVideoDefinitionControlLayer)

- (void)setDefinitionURLAssets:(nullable NSArray<SJVideoPlayerURLAsset *> *)definitionURLAssets {
    objc_setAssociatedObject(self, @selector(definitionURLAssets), definitionURLAssets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        SJEdgeControlLayerItemAdapter *adapter = self.defaultEdgeControlLayer.bottomAdapter;
        if ( definitionURLAssets != nil ) {
            if ( self.definitionButtonItem != nil ) return;
            self.definitionButtonItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49xAutoresizing tag:SJEdgeControlLayerBottomItem_Definition];
            [self.definitionButtonItem addTarget:self action:@selector(clickedDefinitionButtonItem:)];
            [adapter insertItem:self.definitionButtonItem rearItem:SJEdgeControlLayerBottomItem_FullBtn];
            [self.defaultEdgeControlLayer.bottomAdapter reload];
        }
        else if ( [adapter containsItem:self.definitionButtonItem] ) {
            [adapter removeItemForTag:SJEdgeControlLayerBottomItem_Definition];
            [self.switcher deleteControlLayerForIdentifier:SJControlLayer_SwitchVideoDefinition];
            [self.defaultEdgeControlLayer.bottomAdapter reload];
        }
    });
}

- (nullable NSArray<SJVideoPlayerURLAsset *> *)definitionURLAssets {
    return objc_getAssociatedObject(self, _cmd);
}

@end


#pragma mark -
@implementation SJVideoPlayer (SJExtendedEdgeControlLayer)
- (void)setShowMoreItemToTopControlLayer:(BOOL)showMoreItemToTopControlLayer {
    if ( showMoreItemToTopControlLayer != self.showMoreItemToTopControlLayer ) {
        objc_setAssociatedObject(self, @selector(showMoreItemToTopControlLayer), @(showMoreItemToTopControlLayer), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( showMoreItemToTopControlLayer ) {
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
- (BOOL)showMoreItemToTopControlLayer {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end


@implementation SJVideoPlayer (SJExtendedFilmEditingControlLayer)
- (void)setEnabledFilmEditing:(BOOL)enabledFilmEditing {
    if ( enabledFilmEditing != self.isEnabledFilmEditing ) {
        objc_setAssociatedObject(self, @selector(isEnabledFilmEditing), @(enabledFilmEditing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        dispatch_async(dispatch_get_main_queue(), ^{
            if ( enabledFilmEditing ) {
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
- (BOOL)isEnabledFilmEditing {
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


@implementation SJVideoPlayer (SJExtendedControlLayerSwitcher)
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
SJControlLayerIdentifier const SJControlLayer_SwitchVideoDefinition = LONG_MAX - 7;

SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_FilmEditing = LONG_MAX - 1;   // GIF/导出/截屏
SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_More = LONG_MAX - 2;             // More
SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Definition = LONG_MAX - 3;
NS_ASSUME_NONNULL_END
