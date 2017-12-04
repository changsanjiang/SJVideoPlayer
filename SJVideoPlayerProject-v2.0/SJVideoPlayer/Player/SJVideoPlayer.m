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

@interface SJVideoPlayer ()<SJVideoPlayerControlViewDelegate, SJSliderDelegate>

@property (nonatomic, strong, readonly) SJVideoPlayerPresentView *presentView;
@property (nonatomic, strong, readonly) SJVideoPlayerControlView *controlView;

@property (nonatomic, assign, readwrite) SJVideoPlayerPlayState state;

@end





#pragma mark - Preview

@interface SJVideoPlayer (Preview)

- (void)_generatingPreviewImagesWithBounds:(CGRect)bounds
                                completion:(void(^)(NSArray<SJVideoPreviewModel *> *images, NSError *error))block;

- (void)_showOrHiddenPreview;

- (void)_showPreview;

- (void)_hiddenPreview;

@end

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
    if ( self.controlView.previewView.alpha != 1 )
        [self _showPreview];
    else [self _hiddenPreview];
}

- (void)_showPreview {
    self.controlView.previewView.alpha = 1;
    self.controlView.previewView.transform = CGAffineTransformIdentity;
    [self.controlView.previewView.collectionView reloadData];
}

- (void)_hiddenPreview {
    self.controlView.previewView.alpha = 0.001;
    self.controlView.previewView.transform = CGAffineTransformMakeScale(1, 0.001);
}

@end





#pragma mark - Orientation

@interface SJVideoPlayer (Orientation)

@property (nonatomic, assign, readwrite, getter=isFullScreen) BOOL fullScreen;

@property (nonatomic, copy, readwrite) void(^orientationChangedCallBlock)(void);

@property (nonatomic, copy, readwrite) BOOL(^rotationCondition)(BOOL demand);

- (void)_observerDeviceOrientation;

- (BOOL)_changeScreenOrientation;

@end

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
            [UIApplication sharedApplication].statusBarHidden = YES;
            transform = CGAffineTransformMakeRotation(M_PI_2);
            superview = [UIApplication sharedApplication].keyWindow;
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            transform = CGAffineTransformMakeRotation(-M_PI_2);
            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
            [UIApplication sharedApplication].statusBarHidden = YES;
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


#pragma mark - SeekToTime

@interface SJVideoPlayer (SeekToTime)

- (void)_seekToTime:(CMTime)time completion:(void (^)(BOOL r))block;

@end

@implementation SJVideoPlayer (SeekToTime)

- (void)_seekToTime:(CMTime)time completion:(void (^)(BOOL))block {
    [self.asset.player seekToTime:time completionHandler:^(BOOL finished) {
        if ( !finished ) return;
        if ( block ) block(finished);
    }];
}

@end





#pragma mark - State

@interface SJVideoPlayer (State)

/// default is NO.
@property (nonatomic, assign, readwrite, getter=isLockedScrren) BOOL lockScreen;

@property (nonatomic, assign, readwrite, getter=isHiddenControl) BOOL hideControl;

- (void)_prepareState;

- (void)_playState;

- (void)_pauseState;

- (void)_stopState;

- (void)_playEndState;

@end

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

- (void)setHideControl:(BOOL)hideControl {
    if ( self.isHiddenControl == hideControl ) return;
    objc_setAssociatedObject(self, @selector(isHiddenControl), @(hideControl), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( hideControl ) [self _hideControlState];
    else [self _showControlState];
}

- (BOOL)isHiddenControl {
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
    self.hideControl = YES;
    
}

- (void)_unlockScreenState {
    
    // show
    _sjShowViews(@[self.controlView.leftControlView.unlockBtn]);
    self.hideControl = NO;
    
    // hidden
    _sjHiddenViews(@[self.controlView.leftControlView.lockBtn]);
    
}

- (void)_hideControlState {

    // show
    _sjShowViews(@[self.controlView.bottomProgressSlider]);
    
    // hidden
    [self _hiddenPreview];
    
    // transform hidden
    self.controlView.topControlView.transform = CGAffineTransformMakeTranslation(0, - self.controlView.topControlView.frame.size.height);
    self.controlView.bottomControlView.transform = CGAffineTransformMakeTranslation(0, self.controlView.bottomControlView.frame.size.height);
    self.controlView.leftControlView.transform = CGAffineTransformMakeTranslation(-self.controlView.leftControlView.frame.size.width, 0);;
}

- (void)_showControlState {
    
    // show
    _sjShowViews(@[self.controlView.leftControlView]);
    
    // hidden
    [self _hiddenPreview];
    
    // transform show
    self.controlView.leftControlView.transform = self.controlView.topControlView.transform = self.controlView.bottomControlView.transform = CGAffineTransformIdentity;
}

@end





#pragma mark - Gesture

@interface SJVideoPlayer (GestureRecognizer)
@end

typedef NS_ENUM(NSUInteger, SJPanDirection) {
    SJPanDirection_Unknown,
    SJPanDirection_V,
    SJPanDirection_H,
};


typedef NS_ENUM(NSUInteger, SJVerticalPanLocation) {
    SJVerticalPanLocation_Unknown,
    SJVerticalPanLocation_Left,
    SJVerticalPanLocation_Right,
};

@implementation SJVideoPlayer (GestureRecognizer)

- (void)setPanDirection:(SJPanDirection)panDirection {
    objc_setAssociatedObject(self, @selector(panDirection), @(panDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJPanDirection)panDirection {
    return (SJPanDirection)[objc_getAssociatedObject(self , _cmd) integerValue];
}

- (void)setPanLocation:(SJVerticalPanLocation)panLocation {
    objc_setAssociatedObject(self, @selector(panLocation), @(panLocation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJVerticalPanLocation)panLocation {
    return (SJVerticalPanLocation)[objc_getAssociatedObject(self , _cmd) integerValue];
}

- (void)controlView:(SJVideoPlayerControlView *)controlView handleSingleTap:(UITapGestureRecognizer *)tap {
    if ( self.isLockedScrren ) return;
    _sjAnima(^{
        self.hideControl = !self.isHiddenControl;
    });
}

- (void)controlView:(SJVideoPlayerControlView *)controlView handleDoubleTap:(UITapGestureRecognizer *)tap {
    if ( self.isLockedScrren ) return;
    switch (self.state) {
        case SJVideoPlayerPlayState_Unknown:
        case SJVideoPlayerPlayState_Prepare:
            break;
        case SJVideoPlayerPlayState_Buffing:
        case SJVideoPlayerPlayState_Playing: {
            [self pause];
        }
            break;
        case SJVideoPlayerPlayState_Pause:
        case SJVideoPlayerPlayState_PlayEnd: {
            [self play];
        }
            break;
        case SJVideoPlayerPlayState_PlayFailed:
            break;
    }
}

static UIView *target = nil;
- (void)controlView:(SJVideoPlayerControlView *)controlView handlePan:(UIPanGestureRecognizer *)pan {
//    // 我们要响应水平移动和垂直移动
//    // 根据上次和本次移动的位置，算出一个速率的point
//    CGPoint velocityPoint = [pan velocityInView:pan.view];
//    
//    CGPoint offset = [pan translationInView:pan.view];
//    
//    // 判断是垂直移动还是水平移动
//    switch (pan.state) {
//        case UIGestureRecognizerStateBegan:{ // 开始移动
//            // 使用绝对值来判断移动的方向
//            CGFloat x = fabs(velocityPoint.x);
//            CGFloat y = fabs(velocityPoint.y);
//            if (x > y) {
//                /// 水平移动
//                self.panDirection = SJPanDirection_H;
//                self.controlView.hiddenControl = YES;
//                [self sliderWillBeginDragging:self.controlView.sliderControl];
//            }
//            else if (x < y) {
//                /// 垂直移动
//                self.panDirection = SJPanDirection_V;
//                
//                CGPoint locationPoint = [pan locationInView:pan.view];
//                if (locationPoint.x > self.controlView.bounds.size.width / 2) {
//                    self.panLocation = SJVerticalPanLocation_Right;
//                    self.volumeView.value = self.systemVolume.value;
//                    target = self.volumeView;
//                }
//                else {
//                    self.panLocation = SJVerticalPanLocation_Left;
//                    self.brightnessView.value = [UIScreen mainScreen].brightness;
//                    target = self.brightnessView;
//                }
//                [[UIApplication sharedApplication].keyWindow addSubview:target];
//                [target mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.size.mas_offset(CGSizeMake(155, 155));
//                    make.center.equalTo([UIApplication sharedApplication].keyWindow);
//                }];
//                target.transform = self.controlView.superview.transform;
//                [UIView animateWithDuration:0.25 animations:^{
//                    target.alpha = 1;
//                }];
//                
//            }
//            break;
//        }
//        case UIGestureRecognizerStateChanged:{ // 正在移动
//            switch (self.panDirection) {
//                case SJPanDirection_H:{
//                    self.controlView.sliderControl.value += offset.x * 0.003;
//                    [self sliderDidDrag:self.controlView.sliderControl];
//                }
//                    break;
//                case SJPanDirection_V:{
//                    switch (self.panLocation) {
//                        case SJVerticalPanLocation_Left: {
//                            CGFloat value = [UIScreen mainScreen].brightness - offset.y * 0.006;
//                            if ( value < 1.0 / 16 ) value = 1.0 / 16;
//                            [UIScreen mainScreen].brightness = value;
//                            self.brightnessView.value = value;
//                            self.controlView.brightnessSlider.value = self.brightnessView.value;
//                        }
//                            break;
//                        case SJVerticalPanLocation_Right: {
//                            self.systemVolume.value -= offset.y * 0.006;
//                            self.controlView.volumeSlider.value = self.systemVolume.value;
//                        }
//                            break;
//                            
//                        default:
//                            break;
//                    }
//                }
//                    break;
//                default:
//                    break;
//            }
//            break;
//        }
//        case UIGestureRecognizerStateEnded:{ // 移动停止
//            switch (self.panDirection) {
//                case SJPanDirection_H:{
//                    [self sliderDidEndDragging:self.controlView.sliderControl];
//                    break;
//                }
//                case SJPanDirection_V:{
//                    [UIView animateWithDuration:0.5 animations:^{
//                        target.alpha = 0.001;
//                    }];
//                    break;
//                }
//                default:
//                    break;
//            }
//            break;
//        }
//        default:
//            break;
//    }
//    
//    
//    [pan setTranslation:CGPointZero inView:pan.view];
}


@end




#pragma mark - SJVideoPlayer

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
    
    _controlView.bottomControlView.progressSlider.delegate = self;
    
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


#pragma mark ======================================================

- (void)sliderWillBeginDragging:(SJSlider *)slider {
    switch (slider.tag) {
        case SJVideoPlaySliderTag_Progress: {
            [self pause];
            NSInteger currentTime = slider.value * self.asset.duration;
            [self _refreshingTimeLabelWithCurrentTime:currentTime duration:self.asset.duration];
        }
            break;
            
        default:
            break;
    }
}

- (void)sliderDidDrag:(SJSlider *)slider {
    switch (slider.tag) {
        case SJVideoPlaySliderTag_Progress: {
            NSInteger currentTime = slider.value * self.asset.duration;
            [self _refreshingTimeLabelWithCurrentTime:currentTime duration:self.asset.duration];
        }
            break;
            
        default:
            break;
    }
}

- (void)sliderDidEndDragging:(SJSlider *)slider {
    switch (slider.tag) {
        case SJVideoPlaySliderTag_Progress: {
            NSInteger currentTime = slider.value * self.asset.duration;
            __weak typeof(self) _self = self;
            [self jumpedToTime:currentTime completionHandler:^(BOOL finished) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                [self play];
            }];
        }
            break;
            
        default:
            break;
    }
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

- (void)_refreshingTimeLabelWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    self.controlView.bottomControlView.currentTimeLabel.text = [self _formatSeconds:currentTime];
    self.controlView.bottomControlView.durationTimeLabel.text = [self _formatSeconds:duration];
}

- (void)_refreshingTimeProgressSliderWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    self.controlView.bottomProgressSlider.value = self.controlView.bottomControlView.progressSlider.value = currentTime / duration;
}

- (void)_itemPlayEnd {
    [self jumpedToTime:0 completionHandler:nil];
    [self _playEndState];
}

#pragma mark ======================================================

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
            _sjAnima(^{
                self.hideControl = NO;
            });
            [self play];
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

- (void)controlView:(SJVideoPlayerControlView *)controlView didSelectPreviewItem:(SJVideoPreviewModel *)item {
    [self pause];
    __weak typeof(self) _self = self;
    [self _seekToTime:item.localTime completion:^(BOOL r) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self play];
    }];
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
        [self _refreshingTimeProgressSliderWithCurrentTime:currentTime duration:duration];
        [self _refreshingTimeLabelWithCurrentTime:currentTime duration:duration];
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

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
//    if ( self.state == SJVideoPlayerPlayState_Unknown ) return;
    CMTime seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    [self _seekToTime:seekTime completion:completionHandler];
}

- (UIImage *)screenshot {
    return [self.asset screenshot];
}
@end
