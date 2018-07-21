//
//  SJVideoPlayer.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJVideoPlayer.h"
#import <objc/message.h>
#import "SJEdgeControlLayer.h"
#import "SJFilmEditingControlLayer.h"
#import "SJEdgeLightweightControlLayer.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayer ()<SJEdgeControlLayerDelegate, SJFilmEditingControlLayerDelegate, SJEdgeLightweightControlLayerDelegate>

@property (nonatomic, strong, readonly) SJControlLayerCarrier *defaultEdgeCarrier;
@property (nonatomic, strong, readonly) SJControlLayerCarrier *defaultFilmEditingCarrier;
@property (nonatomic, strong, readonly) SJControlLayerCarrier *defaultEdgeLightweightCarrier;


- (nullable SJEdgeControlLayer *)defaultEdgeControlLayer;
- (nullable SJFilmEditingControlLayer *)defaultFilmEditingControlLayer;
- (nullable SJEdgeLightweightControlLayer *)defaultEdgeLightweightControlLayer;
@end

@implementation SJVideoPlayer

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
}

+ (NSString *)version {
    return @"v2.1.2";
}

+ (instancetype)player {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    /// 添加一个控制层
    [self.switcher addControlLayer:self.defaultEdgeCarrier];
    /// 切换到添加的控制层
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge toVideoPlayer:self];
    return self;
}

+ (instancetype)lightweightPlayer {
    SJVideoPlayer *videoPlayer = [[SJVideoPlayer alloc] _init];
    /// 添加一个控制层
    [videoPlayer.switcher addControlLayer:videoPlayer.defaultEdgeLightweightCarrier];
    /// 切换到添加的控制层
    [videoPlayer.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge toVideoPlayer:videoPlayer];
    return videoPlayer;
}

- (instancetype)_init {
    self = [super init];
    if ( self ) {}
    return self;
}

@synthesize switcher = _switcher;
- (SJControlLayerSwitcher *)switcher {
    if ( _switcher ) return _switcher;
    return _switcher = [[SJControlLayerSwitcher alloc] init];
}

@synthesize defaultEdgeCarrier = _defaultEdgeCarrier;
- (SJControlLayerCarrier *)defaultEdgeCarrier {
    if ( _defaultEdgeCarrier ) return _defaultEdgeCarrier;
    // 创建一个控制层
    SJEdgeControlLayer *edgeControlLayer = [SJEdgeControlLayer new];
    edgeControlLayer.delegate = self;
    // 创建载体
    SJControlLayerCarrier *defaultEdgeCarrier =
    [[SJControlLayerCarrier alloc] initWithIdentifier:SJControlLayer_Edge dataSource:edgeControlLayer delegate:edgeControlLayer exitExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [(SJEdgeControlLayer *)carrier.dataSource exitControlLayerCompeletionHandler:nil];
    } restartExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [(SJEdgeControlLayer *)carrier.dataSource restartControlLayerCompeletionHandler:nil];
    }];
    return _defaultEdgeCarrier = defaultEdgeCarrier;
}

- (nullable SJEdgeControlLayer *)defaultEdgeControlLayer {
    if ( [_defaultEdgeCarrier.dataSource isKindOfClass:[SJEdgeControlLayer class]] ) {
        return (id)_defaultEdgeCarrier.dataSource;
    }
    return nil;
}
/// 返回按钮被点击
- (void)clickedBackBtnOnControlLayer:(SJEdgeControlLayer *)controlLayer {
    if ( self.clickedBackEvent ) self.clickedBackEvent(self);
}
/// 右侧按钮被点击
- (void)clickedFilmEditingBtnOnControlLayer:(SJEdgeControlLayer *)controlLayer {
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_FilmEditing toVideoPlayer:self];
}

#pragma mark
@synthesize defaultFilmEditingCarrier = _defaultFilmEditingCarrier;
- (SJControlLayerCarrier *)defaultFilmEditingCarrier {
    if ( _defaultFilmEditingCarrier ) return _defaultFilmEditingCarrier;
    SJFilmEditingControlLayer *filmEditingControlLayer = [SJFilmEditingControlLayer new];
    filmEditingControlLayer.delegate = self;
    SJControlLayerCarrier *defaultFilmEditingCarrier = [[SJControlLayerCarrier alloc] initWithIdentifier:SJControlLayer_FilmEditing dataSource:filmEditingControlLayer delegate:filmEditingControlLayer exitExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [(SJFilmEditingControlLayer *)carrier.dataSource exitControlLayerCompeletionHandler:nil];
    } restartExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [(SJFilmEditingControlLayer *)carrier.dataSource restartControlLayerCompeletionHandler:nil];
    }];
    return _defaultFilmEditingCarrier = defaultFilmEditingCarrier;
}

- (nullable SJFilmEditingControlLayer *)defaultFilmEditingControlLayer {
    if ( [_defaultFilmEditingCarrier.dataSource isKindOfClass:[SJFilmEditingControlLayer class]] ) {
        return (id)_defaultFilmEditingCarrier.dataSource;
    }
    return nil;
}

/// 用户点击空白区域
- (void)userTappedBlankAreaOnControlLayer:(SJFilmEditingControlLayer *)controlLayer {
    [self.switcher switchControlLayerForIdentitfier:self.switcher.previousIdentifier toVideoPlayer:self];
}

/// 用户点击了取消按钮
- (void)userClickedCancelBtnOnControlLayer:(SJFilmEditingControlLayer *)controlLayer {
    [self.switcher switchControlLayerForIdentitfier:self.switcher.previousIdentifier toVideoPlayer:self];
}

/// 状态改变的回调
- (void)filmEditingControlLayer:(SJFilmEditingControlLayer *)controlLayer
                  statusChanged:(SJFilmEditingStatus)status { /*...*/ }

#pragma mark
@synthesize defaultEdgeLightweightCarrier = _defaultEdgeLightweightCarrier;
- (SJControlLayerCarrier *)defaultEdgeLightweightCarrier {
    if ( _defaultEdgeLightweightCarrier ) return _defaultEdgeLightweightCarrier;
    SJEdgeLightweightControlLayer *edgeControlLayer = [SJEdgeLightweightControlLayer new];
    edgeControlLayer.delegate = self;
    _defaultEdgeLightweightCarrier = [[SJControlLayerCarrier alloc] initWithIdentifier:SJControlLayer_Edge dataSource:edgeControlLayer delegate:edgeControlLayer exitExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [(SJEdgeLightweightControlLayer *)carrier.dataSource exitControlLayerCompeletionHandler:nil];
    } restartExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [(SJEdgeLightweightControlLayer *)carrier.dataSource restartControlLayerCompeletionHandler:nil];
    }];
    return _defaultEdgeLightweightCarrier;
}

- (nullable SJEdgeLightweightControlLayer *)defaultEdgeLightweightControlLayer {
    if ( [_defaultEdgeLightweightCarrier.dataSource isKindOfClass:[SJEdgeLightweightControlLayer class]] ) {
        return (id)_defaultEdgeLightweightCarrier.dataSource;
    }
    return nil;
}
/// 返回按钮被点击
- (void)clickedBackBtnOnLightweightControlLayer:(SJEdgeLightweightControlLayer *)controlLayer {
    if ( self.clickedBackEvent ) self.clickedBackEvent(self);
}
/// 点击顶部控制层上的item
- (void)lightwieghtControlLayer:(SJEdgeLightweightControlLayer *)controlLayer clickedTopControlItem:(SJLightweightTopItem *)item {
    if ( self.clickedTopControlItemExeBlock ) self.clickedTopControlItemExeBlock(self, item);
}
/// 右侧按钮被点击
- (void)clickedFilmEditingBtnOnLightweightControlLayer:(SJEdgeLightweightControlLayer *)controlLayer {
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_FilmEditing toVideoPlayer:self];
}


#pragma mark
- (void)setDisableNetworkStatusChangePrompt:(BOOL)disableNetworkStatusChangePrompt {
    _disableNetworkStatusChangePrompt = disableNetworkStatusChangePrompt;
    [self defaultEdgeControlLayer].disableNetworkStatusChangePrompt = disableNetworkStatusChangePrompt;
    [self defaultEdgeLightweightControlLayer].disableNetworkStatusChangePrompt = disableNetworkStatusChangePrompt;
}

- (void (^)(SJVideoPlayer * _Nonnull))clickedBackEvent {
    if ( _clickedBackEvent ) return _clickedBackEvent;
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



@implementation SJVideoPlayer (SettingLightweightControlLayer)

- (void)setTopControlItems:(nullable NSArray<SJLightweightTopItem *> *)topControlItems {
    objc_setAssociatedObject(self, @selector(topControlItems), topControlItems, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self defaultEdgeLightweightControlLayer].topItems = topControlItems;
}

- (nullable NSArray<SJLightweightTopItem *> *)topControlItems {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setClickedTopControlItemExeBlock:(nullable void (^)(SJVideoPlayer * _Nonnull, SJLightweightTopItem * _Nonnull))clickedTopControlItemExeBlock {
    objc_setAssociatedObject(self, @selector(clickedTopControlItemExeBlock), clickedTopControlItemExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable void (^)(SJVideoPlayer * _Nonnull, SJLightweightTopItem * _Nonnull))clickedTopControlItemExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}
@end


#pragma mark -

@implementation SJVideoPlayer (SettingDefaultControlLayer)

- (void)setMoreSettings:(nullable NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    [self defaultEdgeControlLayer].moreSettings = moreSettings;
}

- (nullable NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    return [self defaultEdgeControlLayer].moreSettings;
}

- (void)setGeneratePreviewImages:(BOOL)generatePreviewImages {
    [self defaultEdgeControlLayer].generatePreviewImages = generatePreviewImages;
}

- (BOOL)generatePreviewImages {
    return [self defaultEdgeControlLayer].generatePreviewImages;
}

@end


@implementation SJVideoPlayer (FilmEditing)

- (void)setEnableFilmEditing:(BOOL)enableFilmEditing {
    objc_setAssociatedObject(self, @selector(enableFilmEditing), @(enableFilmEditing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self defaultEdgeControlLayer].enableFilmEditing = enableFilmEditing;
    [self defaultEdgeLightweightControlLayer].enableFilmEditing = enableFilmEditing;
    if ( enableFilmEditing ) {
        [self.switcher addControlLayer:self.defaultFilmEditingCarrier];
        [self defaultFilmEditingControlLayer].config = self.filmEditingConfig;
    }
    else {
        [self.switcher deleteControlLayerForIdentifier:SJControlLayer_FilmEditing];
        _defaultFilmEditingCarrier = nil;
    }
}

- (BOOL)enableFilmEditing {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

// 历史遗留问题, 此处不应该readonly. 应该由外界配置...
- (SJVideoPlayerFilmEditingConfig *)filmEditingConfig {
    SJVideoPlayerFilmEditingConfig *filmEditingConfig = objc_getAssociatedObject(self, _cmd);
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self defaultFilmEditingControlLayer].config = filmEditingConfig;
    });
    if ( filmEditingConfig ) return filmEditingConfig;
    filmEditingConfig = [SJVideoPlayerFilmEditingConfig new];
    objc_setAssociatedObject(self, _cmd, filmEditingConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return filmEditingConfig;
}

- (void)dismissFilmEditingViewCompletion:(void(^__nullable)(SJVideoPlayer *player))completion {
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge toVideoPlayer:self];
    if ( completion ) completion(self);
}
@end

SJControlLayerIdentifier SJControlLayer_Edge = LONG_MAX - 1;
SJControlLayerIdentifier SJControlLayer_FilmEditing = LONG_MAX - 2;

NS_ASSUME_NONNULL_END
