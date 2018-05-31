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

@interface SJControlLayerCarrier ()
@property (nonatomic) SJControlLayerIdentifier identifier;
@property (nonatomic, strong) id <SJVideoPlayerControlLayerDataSource> dataSource;
@property (nonatomic, strong) id <SJVideoPlayerControlLayerDelegate> delegate;
@end

@implementation SJControlLayerCarrier
- (instancetype)initWithIdentifier:(SJControlLayerIdentifier)identifier
                        dataSource:(__strong id <SJVideoPlayerControlLayerDataSource>)dataSource
                          delegate:(__strong id<SJVideoPlayerControlLayerDelegate>)delegate {
    self = [super init];
    if ( !self ) return nil;
    _identifier = identifier;
    _dataSource = dataSource;
    _delegate = delegate;
    return self;
}
@end


@interface SJVideoPlayer ()
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
    
    SJVideoPlayerDefaultControlView *controlView = [SJVideoPlayerDefaultControlView new];
    SJControlLayerCarrier *defaultEdge = [[SJControlLayerCarrier alloc] initWithIdentifier:SJDefaultControlLayer_edge
                                                                                dataSource:controlView
                                                                                  delegate:controlView];
    [self appendControlLayer:defaultEdge];
    [self switchControlLayerForIdentitfier:defaultEdge.identifier];
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
    [self controlLayerNeedDisappear];

    [UIView animateWithDuration:0.25 delay:0.25 options:kNilOptions animations:^{
        self.controlLayerDataSource = carrier_new.dataSource;
        self.controlLayerDelegate = carrier_new.delegate;
    } completion:nil];
    _currentControlLayerIdentifier = carrier_new.identifier;
}

- (instancetype)initWithControlLayerDataSource:(nullable __weak id<SJVideoPlayerControlLayerDataSource> )controlLayerDataSource
                          controlLayerDelegate:(nullable __weak id<SJVideoPlayerControlLayerDelegate>)controlLayerDelegate     // 指定控制层
{
    return nil;
}

@end

SJControlLayerIdentifier SJDefaultControlLayer_edge = LONG_MAX;
SJControlLayerIdentifier SJDefaultControlLayer_DraggingPreview = LONG_MAX - 1;


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
