//
//  SJVideoPlayer.m
//  SJVideoPlayerV3Project
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJVideoPlayer.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayer ()<SJEdgeControlLayerDelegate, SJFilmEditingControlLayerDelegate>

@property (nonatomic, strong, readonly) SJControlLayerCarrier *defaultEdgeCarrier;
@property (nonatomic, strong, readonly) SJControlLayerCarrier *defaultFilmEditingCarrier;

- (nullable SJEdgeControlLayer *)defaultEdgeControlLayer;
- (nullable SJFilmEditingControlLayer *)defaultFilmEditingControlLayer;
@end

@implementation SJVideoPlayer

+ (instancetype)sharedPlayer {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self player];
    });
    return _instance;
}

+ (instancetype)player {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self.switcher addControlLayer:self.defaultEdgeCarrier];
    [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge toVideoPlayer:self];
    return self;
}



- (instancetype)initWithControlLayerDataSource:(nullable __weak id<SJVideoPlayerControlLayerDataSource> )controlLayerDataSource
                          controlLayerDelegate:(nullable __weak id<SJVideoPlayerControlLayerDelegate>)controlLayerDelegate     // 指定控制层
{
    return nil;
}

@synthesize switcher = _switcher;
- (SJControlLayerSwitcher *)switcher {
    if ( _switcher ) return _switcher;
    return _switcher = [[SJControlLayerSwitcher alloc] init];
}

@synthesize defaultEdgeCarrier = _defaultEdgeCarrier;
- (SJControlLayerCarrier *)defaultEdgeCarrier {
    if ( _defaultEdgeCarrier ) return _defaultEdgeCarrier;
    SJEdgeControlLayer *edgeControlLayer = [SJEdgeControlLayer new];
    edgeControlLayer.delegate = self;
    SJControlLayerCarrier *defaultEdgeCarrier =
    [[SJControlLayerCarrier alloc] initWithIdentifier:SJControlLayer_Edge dataSource:edgeControlLayer delegate:edgeControlLayer exitExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [(SJEdgeControlLayer *)carrier.dataSource exitControlLayerCompeletionHandler:nil];
    } restartExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [(SJEdgeControlLayer *)carrier.dataSource restartControlLayerCompeletionHandler:nil];
    }];
    return _defaultEdgeCarrier = defaultEdgeCarrier;
}

- (nullable SJEdgeControlLayer *)defaultEdgeControlLayer {
    if ( [self.defaultEdgeCarrier.dataSource isKindOfClass:[SJEdgeControlLayer class]] ) {
        return (id)self.defaultEdgeCarrier.dataSource;
    }
    return nil;
}

- (void)clickedBackBtnOnControlLayer:(SJEdgeControlLayer *)controlLayer {
    if ( self.clickedBackEvent ) self.clickedBackEvent(self);
}

- (void)clickedRightBtnOnControlLayer:(SJEdgeControlLayer *)controlLayer {
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
    if ( [self.defaultFilmEditingCarrier.dataSource isKindOfClass:[SJEdgeControlLayer class]] ) {
        return (id)self.defaultFilmEditingCarrier.dataSource;
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
                  statusChanged:(SJFilmEditingStatus)status {
    
}

@end



@implementation SJVideoPlayer (SettingLightweightControlLayer)

- (void)setTopControlItems:(nullable NSArray<SJLightweightTopItem *> *)topControlItems {
    objc_setAssociatedObject(self, @selector(topControlItems), topControlItems, OBJC_ASSOCIATION_COPY_NONATOMIC);
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

static dispatch_queue_t videoPlayerWorkQueue;
+ (dispatch_queue_t)workQueue {
    if ( videoPlayerWorkQueue ) return videoPlayerWorkQueue;
    videoPlayerWorkQueue = dispatch_queue_create("com.SJVideoPlayer.workQueue", DISPATCH_QUEUE_SERIAL);
    return videoPlayerWorkQueue;
}

+ (void)_addOperation:(void(^)(void))block {
    dispatch_async([self workQueue], ^{
        if ( block ) block();
    });
}

+ (void (^)(void (^ _Nonnull)(SJVideoPlayerSettings * _Nonnull)))update {
    return ^ (void(^block)(SJVideoPlayerSettings *settings)) {
        if ( !block ) return;
        [self _addOperation:^ {
            block([SJVideoPlayerSettings commonSettings]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SJSettingsPlayerNotification
                                                                    object:[SJVideoPlayerSettings commonSettings]];
            });
        }];
    };
}

+ (void)resetSetting {
    SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {
        [commonSettings reset];
    });
}

- (void)setMoreSettings:(nullable NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    
}

- (nullable NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    return nil;
}

- (void)setGeneratePreviewImages:(BOOL)generatePreviewImages {
    
}

- (BOOL)generatePreviewImages {
    return NO;
}

@end


@implementation SJVideoPlayer (FilmEditing)

- (void)setEnableFilmEditing:(BOOL)enableFilmEditing {
    objc_setAssociatedObject(self, @selector(enableFilmEditing), @(enableFilmEditing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self defaultEdgeControlLayer].enableFilmEditing = enableFilmEditing;
    if ( enableFilmEditing ) {
        [self.switcher addControlLayer:self.defaultFilmEditingCarrier];
    }
}

- (BOOL)enableFilmEditing {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (SJVideoPlayerFilmEditingConfig *)filmEditingConfig {
    SJVideoPlayerFilmEditingConfig *filmEditingConfig = objc_getAssociatedObject(self, _cmd);
    if ( filmEditingConfig ) return filmEditingConfig;
    filmEditingConfig = [SJVideoPlayerFilmEditingConfig new];
    objc_setAssociatedObject(self, _cmd, filmEditingConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return filmEditingConfig;
}

- (void)dismissFilmEditingViewCompletion:(void(^__nullable)(SJVideoPlayer *player))completion {
    [self.switcher switchControlLayerForIdentitfier:self.switcher.previousIdentifier toVideoPlayer:self];
}
@end
NS_ASSUME_NONNULL_END
