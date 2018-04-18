//
//  SJVideoPlayerHelper.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/25.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerHelper.h"
#import <SJFullscreenPopGesture/UIViewController+SJVideoPlayerAdd.h>
#import "SJVideoPlayer.h"
#import <Masonry/Masonry.h>
#import "SJFilmEditingResultShareItem.h"
#import <objc/message.h>
#import "SJMediaDownloader.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerHelper ()

@property (nonatomic, strong, readwrite, nullable) SJVideoPlayer *videoPlayer;
@property (nonatomic, assign) SJVideoPlayerType playerType;

@end

NS_ASSUME_NONNULL_END

@implementation SJVideoPlayerHelper

- (instancetype)initWithViewController:(__weak UIViewController<SJVideoPlayerHelperUseProtocol> *)viewController {
    return [self initWithViewController:viewController playerType:0];
}

- (instancetype)initWithViewController:(__weak UIViewController<SJVideoPlayerHelperUseProtocol> *)viewController playerType:(SJVideoPlayerType)playerType {
    self = [super init];
    if ( !self ) return nil;
    self.playerType = playerType;
    self.viewController = viewController;
    return self;
}

- (void)setViewController:(UIViewController<SJVideoPlayerHelperUseProtocol> *)viewController {
    if ( viewController == _viewController ) return;
    _viewController = viewController;
    
    // pop gesture
    __weak typeof(self) _self = self;
    viewController.sj_viewWillBeginDragging = ^(UIViewController *vc) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        // video player disable roatation
        self.videoPlayer.disableRotation = YES;   // 触发全屏手势时, 禁止播放器旋转
    };
    
    viewController.sj_viewDidEndDragging = ^(UIViewController *vc) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        // video player enable roatation
        self.videoPlayer.disableRotation = NO;    // 恢复旋转
    };
}

@end




@implementation SJVideoPlayerHelper (FilmEditing)
- (void)setFilmEditingConfig:(SJVideoPlayerFilmEditingConfig *)filmEditingConfig {
    objc_setAssociatedObject(self, @selector(filmEditingConfig), filmEditingConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (SJVideoPlayerFilmEditingConfig *)filmEditingConfig {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setUploader:(id<SJVideoPlayerFilmEditingResultUpload>)uploader {
    objc_setAssociatedObject(self, @selector(uploader), uploader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (id<SJVideoPlayerFilmEditingResultUpload>)uploader {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setEnableFilmEditing:(BOOL)enableFilmEditing {
    objc_setAssociatedObject(self, @selector(enableFilmEditing), @(enableFilmEditing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)enableFilmEditing {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end




#pragma mark -
@implementation SJVideoPlayerHelper (SJVideoPlayerOperation)

- (void)setDisableRotation:(BOOL)disableRotation {
    self.videoPlayer.disableRotation = disableRotation;
}

- (BOOL)disableRotation {
    return self.videoPlayer.disableRotation;
}

- (void)setLockScreen:(BOOL)lockScreen {
    self.videoPlayer.lockedScreen = lockScreen;
}

- (BOOL)lockScreen {
    return self.videoPlayer.isLockedScreen;
}

- (void)setRate:(CGFloat)rate {
    self.videoPlayer.rate = rate;
}

- (CGFloat)rate {
    return self.videoPlayer.rate;
}

- (void)playWithAsset:(SJVideoPlayerURLAsset *)asset playerParentView:(UIView *)playerParentView {
    __weak typeof(self) _self = self;
    
    // old player fade out
    [_videoPlayer stopAndFadeOut];
    
    // create new player
    switch ( _playerType ) {
        case SJVideoPlayerType_Default: {
            _videoPlayer = [SJVideoPlayer player];
            _videoPlayer.generatePreviewImages = NO;
        }
            break;
        case SJVideoPlayerType_Lightweight: {
            _videoPlayer = [SJVideoPlayer lightweightPlayer];
            _videoPlayer.topControlItems = self.topItemsOfLightweightControlLayer;
            _videoPlayer.clickedTopControlItemExeBlock = ^(SJVideoPlayer * _Nonnull player, SJLightweightTopItem * _Nonnull item) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( self.userClickedTopItemOfLightweightControlLayerExeBlock ) self.userClickedTopItemOfLightweightControlLayerExeBlock(self, item);
            };
        }
           break;
    }
    
    // play asset
    _videoPlayer.URLAsset = asset;
    _videoPlayer.pausedToKeepAppearState = YES;
    
    // add player view to parent view
    [playerParentView addSubview:_videoPlayer.view];
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    // player view fade in
    _videoPlayer.view.alpha = 0.001;
    [UIView animateWithDuration:0.5 animations:^{
        self->_videoPlayer.view.alpha = 1;
    }];
    
    // The block invoked when user clicked back btn
    _videoPlayer.clickedBackEvent = ^(SJVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.viewController.navigationController popViewControllerAnimated:YES];
    };
    
    // The block invoked when the player will rotate screen
    _videoPlayer.willRotateScreen = ^(SJVideoPlayer * _Nonnull player, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [UIView animateWithDuration:0.25 animations:^{
            [self.viewController setNeedsStatusBarAppearanceUpdate];
        }];
    };
    
    // The block invoked when the `control view` is `hidden` or `displayed`
    _videoPlayer.controlLayerAppearStateChanged = ^(SJVideoPlayer * _Nonnull player, BOOL displayed) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [UIView animateWithDuration:0.25 animations:^{
            [self.viewController setNeedsStatusBarAppearanceUpdate];
        }];
        if ( self.controlLayerAppearStateChangedExeBlock ) self.controlLayerAppearStateChangedExeBlock(self, displayed);
    };
    
    // The block invoked when player rate changed
    _videoPlayer.rateChanged = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.playerRateChangedExeBlock ) self.playerRateChangedExeBlock(self, player.rate);
    };
    
    // update prompt view background color
    _videoPlayer.prompt.update(^(SJPromptConfig * _Nonnull config) {
        config.backgroundColor = [UIColor colorWithWhite:0 alpha:0.76];
    });
    
    if ( self.enableFilmEditing ) {
        _videoPlayer.enableFilmEditing = YES;
        [_videoPlayer.filmEditingConfig config:self.filmEditingConfig];
    }
}

- (void)clearPlayer {
    [self.videoPlayer.view removeFromSuperview];
    _videoPlayer = nil;
}

- (void)clearAsset {
    _videoPlayer.URLAsset = nil;
}

- (void)pause {
    [_videoPlayer pause];
}

- (void)play {
    [_videoPlayer play];
}

@end


#pragma mark -
@implementation SJVideoPlayerHelper (SJVideoPlayerProperty)

- (void)setControlLayerAppearStateChangedExeBlock:(void (^)(SJVideoPlayerHelper * _Nonnull, BOOL))controlLayerAppearStateChangedExeBlock {
    objc_setAssociatedObject(self, @selector(controlLayerAppearStateChangedExeBlock), controlLayerAppearStateChangedExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(SJVideoPlayerHelper * _Nonnull, BOOL))controlLayerAppearStateChangedExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlayerRateChangedExeBlock:(void (^)(SJVideoPlayerHelper * _Nonnull, float))playerRateChangedExeBlock {
    objc_setAssociatedObject(self, @selector(playerRateChangedExeBlock), playerRateChangedExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(SJVideoPlayerHelper * _Nonnull, float))playerRateChangedExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTopItemsOfLightweightControlLayer:(NSArray<SJLightweightTopItem *> *)topItemsOfLightweightControlLayer {
    objc_setAssociatedObject(self, @selector(topItemsOfLightweightControlLayer), topItemsOfLightweightControlLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<SJLightweightTopItem *> *)topItemsOfLightweightControlLayer {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setUserClickedTopItemOfLightweightControlLayerExeBlock:(void (^)(SJVideoPlayerHelper * _Nonnull, SJLightweightTopItem * _Nonnull))userClickedTopItemOfLightweightControlLayerExeBlock {
    objc_setAssociatedObject(self, @selector(userClickedTopItemOfLightweightControlLayerExeBlock), userClickedTopItemOfLightweightControlLayerExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);

}

- (void (^)(SJVideoPlayerHelper * _Nonnull, SJLightweightTopItem * _Nonnull))userClickedTopItemOfLightweightControlLayerExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (SJVideoPlayerURLAsset *)asset {
    return self.videoPlayer.URLAsset;
}

- (SJPrompt *)prompt {
    return _videoPlayer.prompt;
}

- (NSURL *)currentPlayURL {
    return self.videoPlayer.assetURL;
}

- (NSTimeInterval)currentTime {
    return self.videoPlayer.currentTime;
}

- (NSTimeInterval)totalTime {
    return self.videoPlayer.totalTime;
}

@end




#pragma mark -

@implementation SJVideoPlayerHelper (UIViewControllerHelper)
- (void (^)(void))vc_viewDidAppearExeBlock {
    return ^ () {
        self.videoPlayer.disableRotation = NO;
        if ( !self.videoPlayer.isPlayOnScrollView || (self.videoPlayer.isPlayOnScrollView && self.videoPlayer.isScrollAppeared) ) {
            [self.videoPlayer play];
        }
    };
}

- (void (^)(void))vc_viewWillDisappearExeBlock {
    return ^ () {
        self.videoPlayer.disableRotation = YES;   // 界面将要消失的时候, 禁止旋转.
    };
}

- (void (^)(void))vc_viewDidDisappearExeBlock {
    return ^ () {
        if ( self.videoPlayer.state != SJVideoPlayerPlayState_Paused ) [self.videoPlayer pause];
    };
}

- (BOOL (^)(void))vc_prefersStatusBarHiddenExeBlock {
    return ^BOOL () {
        // 全屏播放时, 使状态栏根据控制层显示或隐藏
        if ( self.videoPlayer.isFullScreen ) return !self.videoPlayer.controlLayerAppeared;
        return NO;
    };
}

- (UIStatusBarStyle (^)(void))vc_preferredStatusBarStyleExeBlock {
    return ^UIStatusBarStyle () {
        // 全屏播放时, 使状态栏变成白色
        if ( self.videoPlayer.isFullScreen ) return UIStatusBarStyleLightContent;
        return UIStatusBarStyleDefault;
    };
}
@end

