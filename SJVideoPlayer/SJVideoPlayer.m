//
//  SJVideoPlayer.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayer.h"
#import <objc/message.h>
#import "SJVideoPlayerDefaultControlView.h"
#import "SJLightweightControlLayer.h"

#pragma mark -

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayer () {
    SJVideoPlayerDefaultControlView *_defaultControlView;
    SJLightweightControlLayer *_lightweightControlLayer;
}

@property (nonatomic, strong, readonly) SJVideoPlayerDefaultControlView *defaultControlView;

@end
NS_ASSUME_NONNULL_END

@implementation SJVideoPlayer

+ (instancetype)sharedPlayer {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

+ (instancetype)player {
    return [[self alloc] init];
}

- (instancetype)init {
    return [self initWithControlLayerDataSource:nil controlLayerDelegate:nil];
}

- (instancetype)initWithControlLayerDataSource:(nullable id<SJVideoPlayerControlLayerDataSource> )controlLayerDataSource
                          controlLayerDelegate:(nullable id<SJVideoPlayerControlLayerDelegate>)controlLayerDelegate {
    self = [super init];
    if ( !self ) return nil;
    if ( nil == controlLayerDataSource ) controlLayerDataSource = self.defaultControlView;
    if ( nil == controlLayerDelegate ) controlLayerDelegate = self.defaultControlView;
    self.controlLayerDataSource = controlLayerDataSource;
    self.controlLayerDelegate = controlLayerDelegate;
    return self;
}

- (SJVideoPlayerDefaultControlView *)defaultControlView {
    if ( _defaultControlView ) return _defaultControlView;
    _defaultControlView = [SJVideoPlayerDefaultControlView new];
    return _defaultControlView;
}

- (void)clickedBackBtnOnControlView:(nonnull SJVideoPlayerDefaultControlView *)controlView {
    if ( self.clickedBackEvent ) self.clickedBackEvent(self);
}

+ (instancetype)lightweightPlayer {
    SJVideoPlayer *videoPlayer = [[self alloc] _init];
    videoPlayer.controlLayerDataSource = videoPlayer.lightweightControlLayer;
    videoPlayer.controlLayerDelegate = videoPlayer.lightweightControlLayer;
    return videoPlayer;
}

- (SJLightweightControlLayer *)lightweightControlLayer {
    if ( _lightweightControlLayer ) return _lightweightControlLayer;
    _lightweightControlLayer = [SJLightweightControlLayer new];
    return _lightweightControlLayer;
}

- (instancetype)_init {
    self = [super init];
    if ( self ) {}
    return self;
}

@end


#pragma mark -

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
    _defaultControlView.moreSettings = moreSettings;
}

- (NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    return _defaultControlView.moreSettings;
}

- (void)setGeneratePreviewImages:(BOOL)generatePreviewImages {
    _defaultControlView.generatePreviewImages = generatePreviewImages;
}

- (BOOL)generatePreviewImages {
    return _defaultControlView.generatePreviewImages;
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
