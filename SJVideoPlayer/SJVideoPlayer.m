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
#define SJEdgeControlLayerShowsMoreItemNotification @"SJEdgeControlLayerShowsMoreItemNotification"
#define SJEdgeControlLayerIsEnabledClipsNotification @"SJEdgeControlLayerIsEnabledClipsNotification"

@implementation SJEdgeControlLayer (SJVideoPlayerExtended)
- (void)setShowsMoreItem:(BOOL)showsMoreItem {
    if ( showsMoreItem != self.showsMoreItem ) {
        objc_setAssociatedObject(self, @selector(showsMoreItem), @(showsMoreItem), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [NSNotificationCenter.defaultCenter postNotificationName:SJEdgeControlLayerShowsMoreItemNotification object:self];
    }
}

- (BOOL)showsMoreItem {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setEnabledClips:(BOOL)enabledClips {
    if ( enabledClips != self.isEnabledClips ) {
        objc_setAssociatedObject(self, @selector(isEnabledClips), @(enabledClips), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [NSNotificationCenter.defaultCenter postNotificationName:SJEdgeControlLayerIsEnabledClipsNotification object:self];
    }
}

- (BOOL)isEnabledClips {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setClipsConfig:(nullable SJVideoPlayerClipsConfig *)clipsConfig {
    objc_setAssociatedObject(self, @selector(clipsConfig), clipsConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJVideoPlayerClipsConfig *)clipsConfig {
    SJVideoPlayerClipsConfig *config = objc_getAssociatedObject(self, _cmd);
    if ( config == nil ) {
        config = SJVideoPlayerClipsConfig.alloc.init;
        objc_setAssociatedObject(self, _cmd, config, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return config;
}

@end

@interface SJVideoPlayer ()<SJSwitchVideoDefinitionControlLayerDelegate, SJMoreSettingControlLayerDelegate, SJNotReachableControlLayerDelegate, SJEdgeControlLayerDelegate>
@property (nonatomic, strong, nullable) id<SJFloatSmallViewControllerObserverProtocol> sj_floatSmallViewControllerObserver;
@property (nonatomic, strong, readonly) SJVideoDefinitionSwitchingInfoObserver *sj_switchingInfoObserver;
@property (nonatomic, strong, readonly) id<SJControlLayerAppearManagerObserver> sj_appearManagerObserver;
@property (nonatomic, strong, readonly) id<SJControlLayerSwitcherObserver> sj_switcherObserver;

@property (nonatomic, strong, nullable) SJEdgeControlButtonItem *moreItem;
@property (nonatomic, strong, nullable) SJEdgeControlButtonItem *clipsItem;
@property (nonatomic, strong, nullable) SJEdgeControlButtonItem *definitionItem;

/// 用于断网之后(当网络恢复后使播放器自动恢复播放)
@property (nonatomic, strong, nullable) id<SJReachabilityObserver> sj_reachabilityObserver;
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
    return @"v3.3.0";
}

+ (instancetype)player {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [self _init];
    if ( !self ) return nil;
    [self.switcher switchControlLayerForIdentifier:SJControlLayer_Edge];   // 切换到添加的控制层
    self.defaultEdgeControlLayer.showsMoreItem = YES;                      // 显示更多按钮
    self.defaultEdgeControlLayer.hiddenBottomProgressIndicator = NO;       // 显示底部进度条
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
    [videoPlayer.switcher switchControlLayerForIdentifier:SJControlLayer_Edge];
    return videoPlayer;
}

- (instancetype)_init {
    self = [super init];
    if ( !self ) return nil;
    [self _observeNotifies];
    [self _initializeSwitcher];
    [self _initializeSwitcherObserver];
    [self _initializeSettingsObserver];
    [self _initializeAppearManagerObserver];
    [self _initializeReachabilityObserver];
    [self _configurationsDidUpdate];
    return self;
}

///
/// 点击了控制层右上角的更多按钮(三个点)
///
- (void)_moreItemWasTapped:(SJEdgeControlButtonItem *)moreItem {
    [self.switcher switchControlLayerForIdentifier:SJControlLayer_More];
}

///
/// 点击了剪辑按钮
///
- (void)_clipsItemWasTapped:(SJEdgeControlButtonItem *)clipsItem {
    self.defaultClipsControlLayer.config = self.defaultEdgeControlLayer.clipsConfig;
    [self.switcher switchControlLayerForIdentifier:SJControlLayer_Clips];
}

///
/// 点击了切换清晰度按钮
///
- (void)_definitionItemWasTapped:(SJEdgeControlButtonItem *)definitionItem {
    self.defaultSwitchVideoDefinitionControlLayer.assets = self.definitionURLAssets;
    [self.switcher switchControlLayerForIdentifier:SJControlLayer_SwitchVideoDefinition];
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
    [self.switcher switchControlLayerForIdentifier:SJControlLayer_Edge];
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

@synthesize defaultClipsControlLayer = _defaultClipsControlLayer;
- (SJClipsControlLayer *)defaultClipsControlLayer {
    if ( !_defaultClipsControlLayer ) {
        _defaultClipsControlLayer = [SJClipsControlLayer new];
        __weak typeof(self) _self = self;
        _defaultClipsControlLayer.cancelledOperationExeBlock = ^(SJClipsControlLayer * _Nonnull control) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            [self.switcher switchToPreviousControlLayer];
        };
    }
    return _defaultClipsControlLayer;
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
            if ( self.isDisabledDefinitionSwitchingPrompt ) return;
            switch ( info.status ) {
                case SJDefinitionSwitchStatusUnknown:
                    break;
                case SJDefinitionSwitchStatusSwitching: {
                    [self.promptPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                        make.append([NSString stringWithFormat:@"%@ %@", SJVideoPlayerConfigurations.shared.localizedStrings.definitionSwitchingPrompt, info.switchingAsset.definition_fullName]);
                        make.textColor(UIColor.whiteColor);
                    }]];
                }
                    break;
                case SJDefinitionSwitchStatusFinished: {
                    [self.promptPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                        make.append([NSString stringWithFormat:@"%@ %@", SJVideoPlayerConfigurations.shared.localizedStrings.definitionSwitchSuccessfullyPrompt, info.currentPlayingAsset.definition_fullName]);
                        make.textColor(UIColor.whiteColor);
                    }]];
                }
                    break;
                case SJDefinitionSwitchStatusFailed: {
                    [self.promptPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                        make.append(SJVideoPlayerConfigurations.shared.localizedStrings.definitionSwitchFailedPrompt);
                        make.textColor(UIColor.whiteColor);
                    }]];
                }
                    break;
            }
            [self _updateContentForDefinitionItemIfNeeded];
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

- (void)_observeNotifies {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_switchControlLayerIfNeeded) name:SJVideoPlayerPlaybackTimeControlStatusDidChangeNotification object:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_resumeOrStopTimeoutTimer) name:SJVideoPlayerPlaybackTimeControlStatusDidChangeNotification object:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_switchControlLayerIfNeeded) name:SJVideoPlayerAssetStatusDidChangeNotification object:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_switchControlLayerIfNeeded) name:SJVideoPlayerPlaybackDidFinishNotification object:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_configurationsDidUpdate) name:SJVideoPlayerConfigurationsDidUpdateNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_showsMoreItemWithNote:) name:SJEdgeControlLayerShowsMoreItemNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_isEnabledClipsWithNote:) name:SJEdgeControlLayerIsEnabledClipsNotification object:nil];
}

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
        else if ( identifier == SJControlLayer_Clips )
            return self.defaultClipsControlLayer;
        else if ( identifier == SJControlLayer_More )
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

- (void)_initializeSettingsObserver {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_configurationsDidUpdate) name:SJVideoPlayerConfigurationsDidUpdateNotification object:nil];
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
                    [self.switcher switchControlLayerForIdentifier:SJControlLayer_FloatSmallView];
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

- (void)_configurationsDidUpdate {
    if ( self.presentView.placeholderImageView.image == nil )
        self.presentView.placeholderImageView.image = SJVideoPlayerConfigurations.shared.resources.placeholder;
    
    if ( _moreItem != nil )
        _moreItem.image = SJVideoPlayerConfigurations.shared.resources.moreImage;
    
    if ( _clipsItem != nil )
        _clipsItem.image = SJVideoPlayerConfigurations.shared.resources.clipsImage;
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
        [self.switcher switchControlLayerForIdentifier:SJControlLayer_LoadFailed];
    }
    // 当处于缓冲状态时
    // - 当前如果没有网络, 则切换到无网空制层
    //
    else if ( self.sj_isTimeout ) {
        [self.switcher switchControlLayerForIdentifier:SJControlLayer_NotReachableAndPlaybackStalled];
    }
    else {
        if ( self.switcher.currentIdentifier == SJControlLayer_LoadFailed ||
             self.switcher.currentIdentifier == SJControlLayer_NotReachableAndPlaybackStalled ) {
            [self.switcher switchControlLayerForIdentifier:SJControlLayer_Edge];
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
            [self _updateAppearStateForMoteItemIfNeeded];
            [self _updateAppearStateForClipsItemIfNeeded];
            [self _updateContentForDefinitionItemIfNeeded];
        }
    };
}

- (void)_initializeReachabilityObserver {
    _sj_reachabilityObserver = [self.reachability getObserver];
    __weak typeof(self) _self = self;
    _sj_reachabilityObserver.networkStatusDidChangeExeBlock = ^(id<SJReachability>  _Nonnull r) {
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
 
- (void)_updateContentForDefinitionItemIfNeeded {
    if ( self.definitionURLAssets.count != 0 ) {
        // definition item
        self.definitionItem.title = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
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

- (void)_updateAppearStateForMoteItemIfNeeded {
    if ( _moreItem != nil ) {
        BOOL isHidden = !self.isFullScreen;
        if ( isHidden != self.moreItem.isHidden ) {
            self.moreItem.hidden = !self.isFullScreen;
            [self.defaultEdgeControlLayer.topAdapter reload];
        }
    }
}

- (void)_showsMoreItemWithNote:(NSNotification *)note {
    if ( self.defaultEdgeControlLayer == note.object ) {
        if ( self.defaultEdgeControlLayer.showsMoreItem ) {
            if ( _moreItem == nil ) {
                _moreItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerTopItem_More];
                _moreItem.image = SJVideoPlayerConfigurations.shared.resources.moreImage;
                [_moreItem addTarget:self action:@selector(_moreItemWasTapped:)];
                [_defaultEdgeControlLayer.topAdapter addItem:_moreItem];
            }
            [self _updateAppearStateForMoteItemIfNeeded];
        }
        else {
            _defaultMoreSettingControlLayer = nil;
            _moreItem = nil;
            [_defaultEdgeControlLayer.topAdapter removeItemForTag:SJEdgeControlLayerTopItem_More];
            [_defaultEdgeControlLayer.topAdapter reload];
            [self.switcher deleteControlLayerForIdentifier:SJControlLayer_More];
        }
    }
}

- (void)_updateAppearStateForClipsItemIfNeeded {
    if ( _clipsItem != nil ) {
        // clips item
        // M3u8 暂时无法剪辑
        // 小屏或者 M3U8的时候 自动隐藏
        BOOL isUnsupportedFormat = self.URLAsset.isM3u8;
        BOOL isPictureInPictureEnabled = NO;
        if (@available(iOS 14.0, *)) {
            isPictureInPictureEnabled = self.playbackController.pictureInPictureStatus != SJPictureInPictureStatusUnknown;
        }
        BOOL isHidden = (self.URLAsset == nil) || !self.isFullScreen || isUnsupportedFormat || isPictureInPictureEnabled;
        if ( isHidden != _clipsItem.isHidden ) {
            _clipsItem.hidden = isHidden;
            [_defaultEdgeControlLayer.rightAdapter reload];
        }
    }
}

- (void)_isEnabledClipsWithNote:(NSNotification *)note {
    if ( self.defaultEdgeControlLayer == note.object ) {
        if ( self.defaultEdgeControlLayer.isEnabledClips ) {
            if ( _clipsItem == nil ) {
                _clipsItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerRightItem_Clips];
                _clipsItem.image = SJVideoPlayerConfigurations.shared.resources.clipsImage;
                [_clipsItem addTarget:self action:@selector(_clipsItemWasTapped:)];
                [_defaultEdgeControlLayer.rightAdapter addItem:_clipsItem];
            }
            [self _updateAppearStateForClipsItemIfNeeded];
        }
        else {
            _defaultClipsControlLayer = nil;
            _clipsItem = nil;
            [_defaultClipsControlLayer.rightAdapter removeItemForTag:SJEdgeControlLayerRightItem_Clips];
            [_defaultClipsControlLayer.rightAdapter reload];
            [self.switcher deleteControlLayerForIdentifier:SJControlLayer_Clips];
        }
    }
}
@end


@implementation SJVideoPlayer (CommonSettings)
+ (void (^)(void (^ _Nonnull)(SJVideoPlayerConfigurations * _Nonnull)))update {
    return SJVideoPlayerConfigurations.update;
}

+ (void (^)(NSBundle * _Nonnull))setLocalizedStrings {
    return ^(NSBundle *bundle) {
        SJVideoPlayerConfigurations.update(^(SJVideoPlayerConfigurations * _Nonnull configs) {
            [configs.localizedStrings setFromBundle:bundle];
        });
    };
}

+ (void (^)(void (^ _Nonnull)(id<SJVideoPlayerLocalizedStrings> _Nonnull)))updateLocalizedStrings {
    return ^(void(^block)(id<SJVideoPlayerLocalizedStrings> strings)) {
        SJVideoPlayerConfigurations.update(^(SJVideoPlayerConfigurations * _Nonnull configs) {
            block(configs.localizedStrings);
        });
    };
}

+ (void (^)(void (^ _Nonnull)(id<SJVideoPlayerControlLayerResources> _Nonnull)))updateResources {
    return ^(void(^block)(id<SJVideoPlayerControlLayerResources> resources)) {
        SJVideoPlayerConfigurations.update(^(SJVideoPlayerConfigurations * _Nonnull configs) {
            block(configs.resources);
        });
    };
}
@end



#pragma mark -
@implementation SJVideoPlayer (SJExtendedSwitchVideoDefinitionControlLayer)

- (void)setDefinitionURLAssets:(nullable NSArray<SJVideoPlayerURLAsset *> *)definitionURLAssets {
    objc_setAssociatedObject(self, @selector(definitionURLAssets), definitionURLAssets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    SJEdgeControlButtonItemAdapter *adapter = self.defaultEdgeControlLayer.bottomAdapter;
    if ( definitionURLAssets != nil ) {
        if ( self.definitionItem == nil ) {
            self.definitionItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49xAutoresizing tag:SJEdgeControlLayerBottomItem_Definition];
            [self.definitionItem addTarget:self action:@selector(_definitionItemWasTapped:)];
            [adapter insertItem:self.definitionItem rearItem:SJEdgeControlLayerBottomItem_Full];
        }
        [self _updateContentForDefinitionItemIfNeeded];
    }
    else {
        self->_defaultSwitchVideoDefinitionControlLayer = nil;
        self.definitionItem = nil;
        [adapter removeItemForTag:SJEdgeControlLayerBottomItem_Definition];
        [self.switcher deleteControlLayerForIdentifier:SJControlLayer_SwitchVideoDefinition];
        [self.defaultEdgeControlLayer.bottomAdapter reload];
    }
}

- (nullable NSArray<SJVideoPlayerURLAsset *> *)definitionURLAssets {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDisabledDefinitionSwitchingPrompt:(BOOL)disabledDefinitionSwitchingPrompt {
    objc_setAssociatedObject(self, @selector(isDisabledDefinitionSwitchingPrompt), @(disabledDefinitionSwitchingPrompt), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isDisabledDefinitionSwitchingPrompt {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end

@implementation SJVideoPlayer (SJExtendedControlLayerSwitcher)
- (void)switchControlLayerForIdentifier:(SJControlLayerIdentifier)identifier {
    [self.switcher switchControlLayerForIdentifier:identifier];
}
@end

NS_ASSUME_NONNULL_END
