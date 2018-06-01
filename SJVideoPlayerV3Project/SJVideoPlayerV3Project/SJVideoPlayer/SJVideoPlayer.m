//
//  SJVideoPlayer.m
//  SJVideoPlayerV3Project
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJVideoPlayer.h"
#import <objc/message.h>
#import "SJVideoPlayerDefaultControlView.h"
#import <SJFilmEditingControlLayer/SJFilmEditingControlLayer.h>

@interface SJControlLayerCarrier ()
@property (nonatomic) SJControlLayerIdentifier identifier;
@property (nonatomic, strong) id <SJVideoPlayerControlLayerDataSource> dataSource;
@property (nonatomic, strong) id <SJVideoPlayerControlLayerDelegate> delegate;
@end

@implementation SJControlLayerCarrier
- (instancetype)initWithIdentifier:(SJControlLayerIdentifier)identifier
                        dataSource:(__strong id <SJVideoPlayerControlLayerDataSource>)dataSource
                          delegate:(__strong id<SJVideoPlayerControlLayerDelegate>)delegate
                      exitExeBlock:(nonnull void (^)(SJControlLayerCarrier * _Nonnull))exitExeBlock
                   restartExeBlock:(nonnull void (^)(SJControlLayerCarrier * _Nonnull))restartExeBlock{
    self = [super init];
    if ( !self ) return nil;
    _identifier = identifier;
    _dataSource = dataSource;
    _delegate = delegate;
    _exitExeBlock = exitExeBlock;
    _restartExeBlock = restartExeBlock;
    return self;
}
@end


@interface SJVideoPlayer ()<SJFilmEditingControlLayerDelegate>
@property (nonatomic, strong, readonly) NSMutableDictionary *map;
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
    _map = [NSMutableDictionary dictionary];
    
    /// edge
    SJVideoPlayerDefaultControlView *defaultEdge = [SJVideoPlayerDefaultControlView new];
    SJControlLayerCarrier *defaultEdge_carrier =
    [[SJControlLayerCarrier alloc] initWithIdentifier:SJControlLayer_Edge dataSource:defaultEdge delegate:defaultEdge exitExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [(SJVideoPlayerDefaultControlView *)carrier.dataSource exitControlLayer];
    } restartExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [(SJVideoPlayerDefaultControlView *)carrier.dataSource restartControlLayer];
    }];
    
    [self appendControlLayer:defaultEdge_carrier];
    self.controlLayerDataSource = defaultEdge;
    self.controlLayerDelegate = defaultEdge;
    _currentControlLayerIdentifier = defaultEdge_carrier.identifier;
    
    /// film editing
    SJFilmEditingControlLayer *filmEditing = [SJFilmEditingControlLayer new];
    filmEditing.delegate = self;
    SJControlLayerCarrier *filmEditing_carrier =
    [[SJControlLayerCarrier alloc] initWithIdentifier:SJControlLayer_FilmEditing dataSource:filmEditing delegate:filmEditing exitExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [(SJFilmEditingControlLayer *)carrier.dataSource exitControlLayer];
    } restartExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [(SJFilmEditingControlLayer *)carrier.dataSource restartControlLayer];
    }];
    [self appendControlLayer:filmEditing_carrier];
    
    __weak typeof(self) _self = self;
    defaultEdge.clickedFilmEditingBtnExeBlock = ^(SJVideoPlayerDefaultControlView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self switchControlLayerForIdentitfier:SJControlLayer_FilmEditing];
    };
    return self;
}

- (void)appendControlLayer:(SJControlLayerCarrier *)carrier {
    [self.map setObject:carrier forKey:@(carrier.identifier)];
}

- (void)deleteControlLayerForIdentifier:(SJControlLayerIdentifier)identifier {
    [self.map removeObjectForKey:@(identifier)];
}

- (SJControlLayerCarrier *)controlLayerForIdentifier:(SJControlLayerIdentifier)identifier {
    return self.map[@(identifier)];
}

- (void)switchControlLayerForIdentitfier:(SJControlLayerIdentifier)identifier {
    SJControlLayerCarrier *carrier_new = self.map[@(identifier)];
    NSParameterAssert(carrier_new);

    SJControlLayerCarrier *carrier_old = self.map[@(self.currentControlLayerIdentifier)];
    if ( carrier_old.exitExeBlock ) carrier_old.exitExeBlock(carrier_old);
    
    self.controlLayerDataSource = carrier_new.dataSource;
    self.controlLayerDelegate = carrier_new.delegate;
    if ( carrier_new.restartExeBlock ) carrier_new.restartExeBlock(carrier_new);

    _currentControlLayerIdentifier = carrier_new.identifier;
}
/// 用户点击空白区域
- (void)userTappedBlankAreaOnControlLayer:(SJFilmEditingControlLayer *)controlLayer {
    [controlLayer cancel];
}

/// 用户取消操作
- (void)filmEditingControlLayer:(SJFilmEditingControlLayer *)controlLayer
                  statusChanged:(SJFilmEditingStatus)status {
    switch ( status ) {
        case SJFilmEditingStatus_Unknown:
            break;
        case SJFilmEditingStatus_Recording:
            break;
        case SJFilmEditingStatus_Paused:
            break;
        case SJFilmEditingStatus_Finished:
            break;
        case SJFilmEditingStatus_Cancelled: {
            [self switchControlLayerForIdentitfier:SJControlLayer_Edge];
        }
            break;
    }
}


- (instancetype)initWithControlLayerDataSource:(nullable __weak id<SJVideoPlayerControlLayerDataSource> )controlLayerDataSource
                          controlLayerDelegate:(nullable __weak id<SJVideoPlayerControlLayerDelegate>)controlLayerDelegate     // 指定控制层
{
    return nil;
}

@end


@implementation SJVideoPlayer (SettingLightweightControlLayer)

- (void)setTopControlItems:(NSArray<SJLightweightTopItem *> *)topControlItems {
    objc_setAssociatedObject(self, @selector(topControlItems), topControlItems, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSArray<SJLightweightTopItem *> *)topControlItems {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setClickedTopControlItemExeBlock:(void (^)(SJVideoPlayer * _Nonnull, SJLightweightTopItem * _Nonnull))clickedTopControlItemExeBlock {
    objc_setAssociatedObject(self, @selector(clickedTopControlItemExeBlock), clickedTopControlItemExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(SJVideoPlayer * _Nonnull, SJLightweightTopItem * _Nonnull))clickedTopControlItemExeBlock {
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

- (void)setMoreSettings:(NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    
}

- (NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
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
    [(SJVideoPlayerDefaultControlView *)self.controlLayerDataSource dismissFilmEditingViewCompletion:^(SJVideoPlayerDefaultControlView * _Nonnull view) {
        if ( completion ) completion(self);
    }];
}

- (void)exitFilmEditingCompletion:(void(^__nullable)(SJVideoPlayer *player))completion {
    [self dismissFilmEditingViewCompletion:completion];
}
@end



SJControlLayerIdentifier SJControlLayer_Edge = LONG_MAX;
SJControlLayerIdentifier SJControlLayer_FilmEditing = LONG_MAX - 1;
