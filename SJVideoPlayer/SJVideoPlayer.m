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

#pragma mark -

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayer ()<SJVideoPlayerDefaultControlViewDelegate> {
    SJVideoPlayerDefaultControlView *_defaultControlView;
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
    _defaultControlView.delegate = self;
    return _defaultControlView;
}

- (void)clickedBackBtnOnControlView:(nonnull SJVideoPlayerDefaultControlView *)controlView {
    if ( self.clickedBackEvent ) self.clickedBackEvent(self);
}

@end


#pragma mark - 默认控制层

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
    _defaultControlView.generatePreviewImages = YES;
}

- (BOOL)generatePreviewImages {
    return _defaultControlView.generatePreviewImages;
}

- (void)setClickedBackEvent:(void (^)(SJVideoPlayer * _Nonnull))clickedBackEvent {
    objc_setAssociatedObject(self, @selector(clickedBackEvent), clickedBackEvent, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(SJVideoPlayer * _Nonnull))clickedBackEvent {
    return objc_getAssociatedObject(self, _cmd);
}

@end
