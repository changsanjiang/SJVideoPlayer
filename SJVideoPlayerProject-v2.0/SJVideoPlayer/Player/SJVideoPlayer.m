//
//  SJVideoPlayer.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayer.h"
#import "SJVideoPlayerAssetCarrier.h"
#import <Masonry/Masonry.h>
#import "SJVideoPlayerPresentView.h"
#import "SJVideoPlayerControlView.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/message.h>


inline static void _sjErrorLog(NSString *msg) {
    NSLog(@"__error__: %@", msg);
}

inline static void _sjHiddenViews(NSArray<UIView *> *views) {
    [views enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.alpha = 0.001;
    }];
}

inline static void _sjShowViews(NSArray<UIView *> *views) {
    [views enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.alpha = 1;
    }];
}

inline static void _sjAnima(void(^block)(void)) {
    if ( block ) {
        [UIView animateWithDuration:0.3 animations:^{
            block();
        }];
    }
}

#pragma mark -

@interface SJVideoPlayer ()<SJVideoPlayerControlViewDelegate>

@property (nonatomic, strong, readonly) SJVideoPlayerPresentView *presentView;
@property (nonatomic, strong, readonly) SJVideoPlayerControlView *controlView;

@property (nonatomic, assign, readwrite) SJVideoPlayerPlayState state;

@end


#pragma mark -

@interface SJVideoPlayer (State)

/// default is NO.
@property (nonatomic, assign, readwrite, getter=isLockedScrren) BOOL lockScreen;

- (void)_prepareState;

- (void)_playState;

- (void)_pauseState;

- (void)_stopState;

- (void)_playEndState;

@end


#pragma mark -

@interface SJVideoPlayer (Preview)

- (void)_generatingPreviewImagesWithBounds:(CGRect)bounds
                                completion:(void(^)(NSArray<SJVideoPreviewModel *> *images, NSError *error))block;

- (void)_showOrHiddenPreview;

- (void)_showPreview;

- (void)_hiddenPreview;

@end


#pragma mark -

@interface SJVideoPlayer (Orientation)

@property (nonatomic, assign, readwrite, getter=isFullScreen) BOOL fullScreen;

@property (nonatomic, copy, readwrite) void(^orientationChangedCallBlock)(void);

@property (nonatomic, copy, readwrite) BOOL(^rotationCondition)(BOOL demand);

- (void)_observerDeviceOrientation;

- (BOOL)_changeScreenOrientation;

@end


#pragma mark -

@interface SJVideoPlayer (SeekToTime)

- (void)_seekToTime:(CMTime)time completion:(void (^)(BOOL))block;

@end

#pragma mark -

@implementation SJVideoPlayer

@synthesize presentView = _presentView;
@synthesize controlView = _controlView;
@synthesize view = _view;

+ (instancetype)sharedPlayer {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark

- (instancetype)init {
    self = [super init];
    if ( !self )  return nil;
    [self.view addSubview:self.presentView];
    [_presentView addSubview:self.controlView];
    _controlView.delegate = self;
    
    [_presentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    self.isAutoplay = YES;
    self.generatePreviewImages = YES;

    __weak typeof(self) _self = self;
    self.orientationChangedCallBlock = ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _hiddenPreview];
    };
    
    self.rotationCondition = ^BOOL(BOOL demand) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        if ( self.state == SJVideoPlayerPlayState_Unknown ) return NO;
        if ( self.disableRotation ) return NO;
        if ( self.isLockedScrren ) return NO;
        if ( self.isFullScreen == demand ) return NO;
        return YES;
    };
    
    [self _observerDeviceOrientation];
    
    return self;
}

- (SJVideoPlayerPresentView *)presentView {
    if ( _presentView ) return _presentView;
    _presentView = [SJVideoPlayerPresentView new];
    _presentView.clipsToBounds = YES;
    return _presentView;
}

- (SJVideoPlayerControlView *)controlView {
    if ( _controlView ) return _controlView;
    _controlView = [SJVideoPlayerControlView new];
    return _controlView;
}

- (UIView *)view {
    if ( _view ) return _view;
    _view = [UIView new];
    _view.backgroundColor = [UIColor blackColor];
    return _view;
}

#pragma mark

- (void)_itemPrepareToPlay {
    [self _prepareState];
}

- (void)_itemPlayFailed {
    
}

- (void)_itemReadyToPlay {
    if ( self.autoplay ) [self play];
}

- (void)_itemPlayTimeChangedWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    self.controlView.bottomControlView.currentTimeLabel.text = [self _formatSeconds:currentTime];
    self.controlView.bottomControlView.durationTimeLabel.text = [self _formatSeconds:duration];
}

- (void)_itemPlayEnd {
    
//    [self.player seekToTime:kCMTimeZero
//          completionHandler:^(BOOL finished) {
//              self.controlView.hiddenReplayBtn = NO;
//          }];
//    [self _clickedPause];
    [self _playEndState];
}

#pragma mark >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

- (void)controlView:(SJVideoPlayerControlView *)controlView clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    switch (tag) {
        case SJVideoPlayControlViewTag_Back: {
            if ( self.isFullScreen ) {
                if ( self.disableRotation ) return;
                else [self _changeScreenOrientation];
            }
            else {
                if ( self.clickedBackEvent ) self.clickedBackEvent(self);
            }
        }
            break;
        case SJVideoPlayControlViewTag_Full: {
            [self _changeScreenOrientation];
        }
            break;
            
        case SJVideoPlayControlViewTag_Play: {
            [self play];
        }
            break;
        case SJVideoPlayControlViewTag_Pause: {
            [self pause];
        }
            break;
        case SJVideoPlayControlViewTag_Replay: {
            
        }
            break;
        case SJVideoPlayControlViewTag_Preview: {
            _sjAnima(^{
                [self _showOrHiddenPreview];
            });
        }
            break;
        case SJVideoPlayControlViewTag_Lock: {
            // 解锁
            self.lockScreen = NO;
        }
            break;
        case SJVideoPlayControlViewTag_Unlock: {
            // 锁屏
            self.lockScreen = YES;
        }
            break;
        case SJVideoPlayControlViewTag_LoadFailed: {
            
        }
            break;
        case SJVideoPlayControlViewTag_More: {
            
        }
            break;
    }
}

#pragma mark

- (NSString *)_formatSeconds:(NSInteger)value {
    NSInteger seconds = value % 60;
    NSInteger minutes = value / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long) minutes, (long) seconds];
}

@end

#pragma mark -

@implementation SJVideoPlayer (Setting)

- (void)setAssetURL:(NSURL *)assetURL {
    self.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:assetURL];
}

- (NSURL *)assetURL {
    return self.asset.assetURL;
}

- (void)setAsset:(SJVideoPlayerAssetCarrier *)asset {
    objc_setAssociatedObject(self, @selector(asset), asset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _presentView.asset = asset;
    _controlView.asset = asset;
    
    [self _itemPrepareToPlay];
    
    __weak typeof(self) _self = self;
    _presentView.receivedVideoRect = ^(SJVideoPlayerPresentView * _Nonnull view, CGRect bounds) {
        [_self _generatingPreviewImagesWithBounds:bounds completion:^(NSArray<SJVideoPreviewModel *> *images, NSError *error) {
            if ( error ) {
                _sjErrorLog(@"Generate Preview Image Failed!");
            }
            else {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                _sjAnima(^{
                    _sjShowViews(@[self.controlView.topControlView.previewBtn]);
                });
                self.controlView.previewView.previewImages = images;
            }
        }];
    };
    
    asset.playerItemStateChanged = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, AVPlayerItemStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch (status) {
            case AVPlayerItemStatusUnknown: break;
            case AVPlayerItemStatusFailed: {
                [self _itemPlayFailed];
            }
                break;
            case AVPlayerItemStatusReadyToPlay: {
                [self _itemReadyToPlay];
            }
                break;
        }
    };
    
    asset.playTimeChanged = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _itemPlayTimeChangedWithCurrentTime:currentTime duration:duration];
    };
    
    asset.playDidToEnd = ^(SJVideoPlayerAssetCarrier * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _itemPlayEnd];
    };
}

- (SJVideoPlayerAssetCarrier *)asset {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlaceholder:(UIImage *)placeholder {
    self.presentView.placeholderImageView.image = placeholder;
}

- (void)setAutoplay:(BOOL)autoplay {
    objc_setAssociatedObject(self, @selector(isAutoplay), @(autoplay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIsAutoplay:(BOOL)isAutoplay {
    self.autoplay = isAutoplay;
}

- (BOOL)isAutoplay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setGeneratePreviewImages:(BOOL)generatePreviewImages {
    objc_setAssociatedObject(self, @selector(generatePreviewImages), @(generatePreviewImages), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)generatePreviewImages {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setClickedBackEvent:(void (^)(SJVideoPlayer *player))clickedBackEvent {
    objc_setAssociatedObject(self, @selector(clickedBackEvent), clickedBackEvent, OBJC_ASSOCIATION_COPY);
}

- (void (^)(SJVideoPlayer * _Nonnull))clickedBackEvent {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDisableRotation:(BOOL)disableRotation {
    objc_setAssociatedObject(self, @selector(disableRotation), @(disableRotation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableRotation {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setScrollView:(UIScrollView *)scrollView indexPath:(NSIndexPath *)indexPath onViewTag:(NSInteger)tag {
    
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    objc_setAssociatedObject(self, @selector(videoGravity), videoGravity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _presentView.videoGravity = videoGravity;
}

- (AVLayerVideoGravity)videoGravity {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)_cleanSetting {
    [self.asset cancelPreviewImagesGeneration];
    self.asset = nil;
}

@end


#pragma mark -

@implementation SJVideoPlayer (Control)

- (BOOL)play {
    if ( !self.asset ) return NO;
    else {
        [self.asset.player play];
        _sjAnima(^{
            [self _playState];
        });
        return YES;
    }
}

- (BOOL)pause {
    if ( !self.asset ) return NO;
    else {
        [self.asset.player pause];
        _sjAnima(^{
            [self _pauseState];
        });
        return YES;
    }
}

- (void)stop {
    [self pause];
    [self _cleanSetting];
    
    _sjAnima(^{
        [self _stopState];
    });
}

@end


#pragma mark -

@implementation SJVideoPlayer (State)

- (void)setLockScreen:(BOOL)lockScreen {
    if ( self.isLockedScrren == lockScreen ) return;
    objc_setAssociatedObject(self, @selector(isLockedScrren), @(lockScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _sjAnima(^{
        if ( lockScreen ) [self _lockScreenState];
        else [self _unlockScreenState];
    });
}

- (BOOL)isLockedScrren {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)_prepareState {
    
    // show
    _sjShowViews(@[self.presentView.placeholderImageView]);
    
    // hidden
    [self _hiddenPreview];
    _sjHiddenViews(@[self.controlView.topControlView.previewBtn,
                     self.controlView.leftControlView.lockBtn,
                     self.controlView.centerControlView.failedBtn,
                     self.controlView.centerControlView.replayBtn,
                     self.controlView.bottomControlView.playBtn,
                     ]);
    
    self.state = SJVideoPlayerPlayState_Prepare;
}

- (void)_playState {
    
    // show
    _sjShowViews(@[self.controlView.bottomControlView.pauseBtn]);
    
    // hidden
    _sjHiddenViews(@[self.presentView.placeholderImageView,
                     self.controlView.bottomControlView.playBtn,
                     self.controlView.centerControlView.replayBtn,]);
    
    self.state = SJVideoPlayerPlayState_Playing;
}

- (void)_pauseState {
    
    // show
    _sjShowViews(@[self.controlView.bottomControlView.playBtn]);
    
    // hidden
    _sjHiddenViews(@[self.controlView.bottomControlView.pauseBtn]);
    
    self.state = SJVideoPlayerPlayState_Pause;
}

- (void)_stopState {
    
    // show
    [self _pauseState];
    _sjShowViews(@[self.presentView.placeholderImageView,]);

    
    self.state = SJVideoPlayerPlayState_Unknown;
}

- (void)_playEndState {

    // show
    _sjShowViews(@[self.controlView.centerControlView.replayBtn]);
    
    self.state = SJVideoPlayerPlayState_PlayEnd;
}

- (void)_lockScreenState {
    
    // show
    _sjShowViews(@[self.controlView.leftControlView.lockBtn]);
    
    // hidden
    _sjHiddenViews(@[self.controlView.leftControlView.unlockBtn]);
    
    // transform
    _controlView.topControlView.transform = CGAffineTransformMakeTranslation(0, - _controlView.topControlView.frame.size.height);
    _controlView.bottomControlView.transform = CGAffineTransformMakeTranslation(0, _controlView.bottomControlView.frame.size.height);
}

- (void)_unlockScreenState {
    
    // show
    _sjShowViews(@[self.controlView.leftControlView.unlockBtn]);
    
    // hidden
    _sjHiddenViews(@[self.controlView.leftControlView.lockBtn]);

    // transform
    _controlView.topControlView.transform = _controlView.bottomControlView.transform = CGAffineTransformIdentity;
}

@end

#pragma mark -

@implementation SJVideoPlayer (Preview)

- (void)_generatingPreviewImagesWithBounds:(CGRect)bounds completion:(void(^)(NSArray<SJVideoPreviewModel *> *images, NSError *error))block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ( self.asset.hasBeenGeneratedPreviewImages ) {
            if ( block ) block(self.asset.generatedPreviewImages, nil);
            return ;
        }
        if ( !self.generatePreviewImages ) return;
        CGFloat width = [UIScreen mainScreen].bounds.size.width * 0.4;
        CGFloat height = width * bounds.size.height / bounds.size.width;
        CGSize size = CGSizeMake(width, height);
        [self.asset generatedPreviewImagesWithMaxItemSize:size completion:^(SJVideoPlayerAssetCarrier * _Nonnull asset, NSArray<SJVideoPreviewModel *> * _Nullable images, NSError * _Nullable error) {
            if ( block ) block(images, error);
        }];
    });
}

- (void)_showOrHiddenPreview {
    if ( _controlView.previewView.alpha != 1 )
         [self _showPreview];
    else [self _hiddenPreview];
}

- (void)_showPreview {
    _controlView.previewView.alpha = 1;
    _controlView.previewView.transform = CGAffineTransformIdentity;
    [_controlView.previewView.collectionView reloadData];
}

- (void)_hiddenPreview {
    _controlView.previewView.alpha = 0.001;
    _controlView.previewView.transform = CGAffineTransformMakeScale(1, 0.001);
}

@end


#pragma mark -

@implementation SJVideoPlayer (Orientation)

- (void)_observerDeviceOrientation {
    if ( ![UIDevice currentDevice].generatesDeviceOrientationNotifications ) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (void)_handleDeviceOrientationChange:(NSNotification *)notification {
    switch ( [UIDevice currentDevice].orientation ) {
        case UIDeviceOrientationPortrait: {
            self.fullScreen = NO;
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            self.fullScreen = YES;
        }
            break;
        default: break;
    }
}

- (BOOL)isFullScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFullScreen:(BOOL)fullScreen {
    if ( self.rotationCondition ) {
        if ( !self.rotationCondition(fullScreen) ) return;
    }
    objc_setAssociatedObject(self, @selector(isFullScreen), @(fullScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIView *superview = nil;
    switch ( [UIDevice currentDevice].orientation ) {
        case UIDeviceOrientationPortrait: {
            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
            transform = CGAffineTransformIdentity;
            superview = self.view;
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
            transform = CGAffineTransformMakeRotation(M_PI_2);
            superview = [UIApplication sharedApplication].keyWindow;
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            transform = CGAffineTransformMakeRotation(-M_PI_2);
            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
            superview = [UIApplication sharedApplication].keyWindow;
        }
            break;
        default: break;
    }
    
    _sjAnima(^{
        [superview addSubview:self.presentView];
        [self.presentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if ( UIDeviceOrientationPortrait == [UIDevice currentDevice].orientation ) {
                make.edges.offset(0);
            }
            else {
                CGFloat width = [UIScreen mainScreen].bounds.size.width;
                CGFloat height = [UIScreen mainScreen].bounds.size.height;
                make.size.mas_offset(CGSizeMake(MAX(width, height), MIN(width, height)));
                make.center.offset(0);
            }
        }];
        
        self.presentView.transform = transform;
        [superview layoutIfNeeded];
    });
    
    if ( self.orientationChangedCallBlock ) self.orientationChangedCallBlock();
}

- (void)setOrientationChangedCallBlock:(void (^)(void))orientationChangedCallBlock {
    objc_setAssociatedObject(self, @selector(orientationChangedCallBlock), orientationChangedCallBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(void))orientationChangedCallBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRotationCondition:(BOOL (^)(BOOL))rotationCondition {
    objc_setAssociatedObject(self, @selector(rotationCondition), rotationCondition, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(BOOL))rotationCondition {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)_changeScreenOrientation {
    if ( [UIDevice currentDevice].orientation != UIInterfaceOrientationPortrait ) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }
    else {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    return YES;
}

@end


@implementation SJVideoPlayer (SeekToTime)

- (void)_seekToTime:(CMTime)time completion:(void (^)(BOOL))block {
    [self.asset.player seekToTime:time completionHandler:^(BOOL finished) {
        if ( !finished ) return;
        if ( block ) block(finished);
    }];
}

@end
