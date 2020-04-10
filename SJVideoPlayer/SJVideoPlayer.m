//
//  SJVideoPlayer.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJVideoPlayer.h"
#import "UIView+SJAnimationAdded.h"
#import <objc/message.h>

#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayerConst.h>
#import <SJBaseVideoPlayer/SJReachability.h>
#import <SJBaseVideoPlayer/UIView+SJBaseVideoPlayerExtended.h>
#import <SJBaseVideoPlayer/NSTimer+SJAssetAdd.h>
#else
#import "SJReachability.h"
#import "SJBaseVideoPlayer.h"
#import "SJBaseVideoPlayerConst.h"
#import "UIView+SJBaseVideoPlayerExtended.h"
#import "NSTimer+SJAssetAdd.h"
#endif

#if __has_include(<SJUIKit/SJAttributesFactory.h>)
#import <SJUIKit/SJAttributesFactory.h>
#else
#import "SJAttributesFactory.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayer ()<SJSwitchVideoDefinitionControlLayerDelegate, SJMoreSettingControlLayerDelegate, SJNotReachableControlLayerDelegate, SJEdgeControlLayerDelegate>
@property (nonatomic, strong, nullable) id<SJFloatSmallViewControllerObserverProtocol> sj_floatSmallViewControllerObserver;
@property (nonatomic, strong, readonly) SJVideoDefinitionSwitchingInfoObserver *sj_switchingInfoObserver;
@property (nonatomic, strong, readonly) id<SJControlLayerAppearManagerObserver> sj_appearManagerObserver;
@property (nonatomic, strong, readonly) id<SJControlLayerSwitcherObsrever> sj_switcherObserver;

@property (nonatomic, strong, nullable) SJEdgeControlButtonItem *moreButtonItem;
@property (nonatomic, strong, nullable) SJEdgeControlButtonItem *filmEditingButtonItem;
@property (nonatomic, strong, nullable) SJEdgeControlButtonItem *definitionButtonItem;

/// 用于断网之后(当网络恢复后使播放器自动恢复播放)
@property (nonatomic, strong, nullable) id<SJReachabilityObserver> sj_reachbilityObserver;
@property (nonatomic, strong, nullable) NSTimer *sj_timeoutTimer;
@property (nonatomic) BOOL sj_isTimeout;
@end

@implementation SJVideoPlayer
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
}

+ (NSString *)version {
    return @"v3.2.4";
}

+ (instancetype)player {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [self _init];
    if ( !self ) return nil;
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];   // 切换到添加的控制层
    self.showMoreItemToTopControlLayer = YES;                               // 显示更多按钮
    self.defaultEdgeControlLayer.hiddenBottomProgressIndicator = NO;        // 显示底部进度条
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
        [self _initializeSettingsObserver];
        [self _initializeAssetStatusObserver];
        [self _initializeAppearManagerObserver];
        [self _initializeReachbilityObserver];
    });
    [self _updateCommonProperties];
    return self;
}

///
/// 点击了控制层右上角的更多按钮(三个点)
///
- (void)_moreItemWasTapped:(SJEdgeControlButtonItem *)moreButtonItem {
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_MoreSettting];
}

///
/// 点击了剪辑按钮
///
- (void)_filmEditingItemWasTapped:(SJEdgeControlButtonItem *)filmEditingItem {
    self.defaultFilmEditingControlLayer.config = self.filmEditingConfig;
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_FilmEditing];
}

///
/// 点击了切换清晰度按钮
///
- (void)_definitionItemWasTapped:(SJEdgeControlButtonItem *)definitionButtonItem {
    self.defaultSwitchVideoDefinitionControlLayer.assets = self.definitionURLAssets;
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_SwitchVideoDefinition];
}

///
/// 点击了返回按钮
///
- (void)_backButtonWasTapped {
    if ( self.isFullScreen && ![self _whetherToSupportOnlyOneOrientation] ) {
        [self rotate];
    }
    else if ( self.isFitOnScreen ) {
        self.fitOnScreen = NO;
    }
    else {
        UIViewController *vc = [self.view lookupResponderForClass:UIViewController.class];
        [vc.view endEditing:YES];
        vc.presentingViewController ? [vc dismissViewControllerAnimated:YES completion:nil] :
                                      [vc.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -

///
/// 选择了一个清晰度
///
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

///
/// 点击了控制层空白区域
///
- (void)tappedBlankAreaOnTheControlLayer:(id<SJControlLayer>)controlLayer {
    [self.switcher switchToPreviousControlLayer];
}

///
/// 点击了控制层上的返回按钮
///
- (void)backItemWasTappedForControlLayer:(id<SJControlLayer>)controlLayer {
    [self _backButtonWasTapped];
}

///
/// 点击了控制层上的刷新按钮
///
- (void)reloadItemWasTappedForControlLayer:(id<SJControlLayer>)controlLayer {
    [self refresh];
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
}

#pragma mark -

- (void)setFloatSmallViewController:(nullable id<SJFloatSmallViewController>)floatSmallViewController {
    [super setFloatSmallViewController:floatSmallViewController];
    [self _initializeFloatSmallViewControllerObserverIfNeeded:floatSmallViewController];
}

#pragma mark -

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

- (id<SJFloatSmallViewController>)floatSmallViewController {
    id<SJFloatSmallViewController> floatSmallViewController = [super floatSmallViewController];
    [self _initializeFloatSmallViewControllerObserverIfNeeded:floatSmallViewController];
    return floatSmallViewController;
}

#pragma mark -

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
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_resumeOrStopTimeoutTimer) name:SJVideoPlayerPlaybackTimeControlStatusDidChangeNotification object:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_switchControlLayerIfNeeded) name:SJVideoPlayerAssetStatusDidChangeNotification object:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_switchControlLayerIfNeeded) name:SJVideoPlayerPlaybackDidFinishNotification object:self];
}

- (void)_initializeSettingsObserver {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_updateCommonProperties) name:SJVideoPlayerSettingsUpdatedNotification object:nil];
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

- (void)_updateCommonProperties {
    if ( !self.presentView.placeholderImageView.image )
        self.presentView.placeholderImageView.image = SJVideoPlayerSettings.commonSettings.placeholder;
}

// 播放器当前是否只支持一个方向
- (BOOL)_whetherToSupportOnlyOneOrientation {
    if ( self.rotationManager.autorotationSupportedOrientations == SJOrientationMaskPortrait ) return YES;
    if ( self.rotationManager.autorotationSupportedOrientations == SJOrientationMaskLandscapeLeft ) return YES;
    if ( self.rotationManager.autorotationSupportedOrientations == SJOrientationMaskLandscapeRight ) return YES;
    return NO;
}

- (void)_resumeOrStopTimeoutTimer {
    if ( self.isBuffering || self.isEvaluating ) {
        if ( SJReachability.shared.networkStatus == SJNetworkStatus_NotReachable && _sj_timeoutTimer == nil ) {
            __weak typeof(self) _self = self;
            _sj_timeoutTimer = [NSTimer sj_timerWithTimeInterval:3 repeats:YES usingBlock:^(NSTimer * _Nonnull timer) {
                [timer invalidate];
                __strong typeof(_self) self = _self;
                if ( !self ) return;
#ifdef DEBUG
                NSLog(@"%d \t %s \t 网络超时, 切换到无网控制层!", (int)__LINE__, __func__);
#endif
                self.sj_isTimeout = YES;
                [self _switchControlLayerIfNeeded];
            }];
            [_sj_timeoutTimer sj_fire];
            [NSRunLoop.mainRunLoop addTimer:_sj_timeoutTimer forMode:NSRunLoopCommonModes];
        }
    }
    else if ( _sj_timeoutTimer != nil ) {
        [_sj_timeoutTimer invalidate];
        _sj_timeoutTimer = nil;
        self.sj_isTimeout = NO;
    }

}

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
    else if ( self.sj_isTimeout ) {
        [self.switcher switchControlLayerForIdentitfier:SJControlLayer_NotReachableAndPlaybackStalled];
    }
    else {
        if ( self.switcher.currentIdentifier == SJControlLayer_LoadFailed ||
             self.switcher.currentIdentifier == SJControlLayer_NotReachableAndPlaybackStalled ) {
            [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
        }
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
            [self _updateContentForMoreButtonItemIfNeeded];
            [self _updateContentForFilmEditingButtonItemIfNeeded];
            [self _updateContentForDefinitionButtonItemIfNeeded];
        }
    };
}

- (void)_initializeReachbilityObserver {
    _sj_reachbilityObserver = [self.reachability getObserver];
    __weak typeof(self) _self = self;
    _sj_reachbilityObserver.networkStatusDidChangeExeBlock = ^(id<SJReachability>  _Nonnull r) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( r.networkStatus == SJNetworkStatus_NotReachable ) {
            [self _resumeOrStopTimeoutTimer];
        }
        else if ( self.switcher.currentIdentifier == SJControlLayer_NotReachableAndPlaybackStalled ) {
#ifdef DEBUG
            NSLog(@"%d \t %s \t 网络恢复, 将刷新资源, 使播放器恢复播放!", (int)__LINE__, __func__);
#endif
            [self refresh];
        }
    };
}

- (void)_updateContentForFilmEditingButtonItemIfNeeded {
    if ( self.isEnabledFilmEditing ) {
        // film editing item
        // 小屏或者 M3U8的时候 自动隐藏
        // M3u8 暂时无法剪辑
        self.filmEditingButtonItem.hidden = (!self.isFullScreen || self.URLAsset.isM3u8) || !self.URLAsset;
        self.filmEditingButtonItem.image = SJVideoPlayerSettings.commonSettings.filmEditingBtnImage;
        [self.defaultEdgeControlLayer.rightAdapter reload];
    }
}

- (void)_updateContentForMoreButtonItemIfNeeded {
    if ( self.showMoreItemToTopControlLayer ) {
        self.moreButtonItem.hidden = !self.isFullScreen;
        self.moreButtonItem.image = SJVideoPlayerSettings.commonSettings.moreBtnImage;
        [self.defaultEdgeControlLayer.topAdapter reload];
    }
}

- (void)_updateContentForDefinitionButtonItemIfNeeded {
    if ( self.definitionURLAssets.count != 0 ) {
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
        [self.defaultEdgeControlLayer.bottomAdapter reload];
    }
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
    
    SJEdgeControlButtonItemAdapter *adapter = self.defaultEdgeControlLayer.bottomAdapter;
    if ( definitionURLAssets != nil ) {
        if ( self.definitionButtonItem == nil ) {
            self.definitionButtonItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49xAutoresizing tag:SJEdgeControlLayerBottomItem_Definition];
            [self.definitionButtonItem addTarget:self action:@selector(_definitionItemWasTapped:)];
            [adapter insertItem:self.definitionButtonItem rearItem:SJEdgeControlLayerBottomItem_FullBtn];
        }
        [self _updateContentForDefinitionButtonItemIfNeeded];
    }
    else {
        self->_defaultSwitchVideoDefinitionControlLayer = nil;
        self.definitionButtonItem = nil;
        [adapter removeItemForTag:SJEdgeControlLayerBottomItem_Definition];
        [self.switcher deleteControlLayerForIdentifier:SJControlLayer_SwitchVideoDefinition];
        [self.defaultEdgeControlLayer.bottomAdapter reload];
    }
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
        
        if ( showMoreItemToTopControlLayer ) {
            if ( self.moreButtonItem == nil ) {
                self.moreButtonItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerTopItem_More];
                [self.moreButtonItem addTarget:self action:@selector(_moreItemWasTapped:)];
                [self.defaultEdgeControlLayer.topAdapter addItem:self.moreButtonItem];
            }
            [self _updateContentForMoreButtonItemIfNeeded];
        }
        else {
            self->_defaultMoreSettingControlLayer = nil;
            self.moreButtonItem = nil;
            [self.defaultEdgeControlLayer.topAdapter removeItemForTag:SJEdgeControlLayerTopItem_More];
            [self.switcher deleteControlLayerForIdentifier:SJControlLayer_MoreSettting];
            [self.defaultEdgeControlLayer.topAdapter reload];
        }
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

        if ( enabledFilmEditing ) {
            if ( self.filmEditingButtonItem == nil ) {
                self.filmEditingButtonItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerBottomItem_FilmEditing];
                [self.filmEditingButtonItem addTarget:self action:@selector(_filmEditingItemWasTapped:)];
                [self.defaultEdgeControlLayer.rightAdapter addItem:self.filmEditingButtonItem];
            }
            [self _updateContentForFilmEditingButtonItemIfNeeded];
        }
        else {
            self->_defaultFilmEditingControlLayer = nil;
            self.filmEditingButtonItem = nil;
            [self.defaultEdgeControlLayer.rightAdapter removeItemForTag:SJEdgeControlLayerBottomItem_FilmEditing];
            [self.switcher deleteControlLayerForIdentifier:SJControlLayer_FilmEditing];
            [self.defaultEdgeControlLayer.rightAdapter reload];
        }
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
