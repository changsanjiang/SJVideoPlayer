//
//  SJVideoPlayerPresentView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerPresentView.h"

#import <AVFoundation/AVPlayerLayer.h>

#import <AVFoundation/AVPlayer.h>

#import <Masonry/Masonry.h>

#import "SJVideoPlayerStringConstant.h"

#import "UIView+SJExtension.h"

#import <AVFoundation/AVAssetImageGenerator.h>

#import <AVFoundation/AVPlayerItem.h>

#pragma mark -

// MARK: 通知处理

@interface SJVideoPlayerPresentView (DBNotifications)

- (void)_installNotifications;

- (void)_removeNotifications;

- (void)_addDeviceOrientationChangeObserver;

- (void)_removeDeviceOrientationChangeObserver;

@end



#pragma mark -

// MARK: 观察处理

@interface SJVideoPlayerPresentView (DBObservers)

- (void)_installObservers;

- (void)_removeObservers;

@end




#pragma mark -

@interface SJVideoPlayerPresentView ()

@property (nonatomic, weak, readwrite) AVPlayer *player;

@property (nonatomic, weak, readwrite) AVAsset *asset;

@property (nonatomic, assign, readwrite) UIDeviceOrientation lastOrientation;

@property (nonatomic, strong, readonly) UIImageView *placeholderImageView;

@end




#pragma mark -

@implementation SJVideoPlayerPresentView

@synthesize placeholderImageView = _placeholderImageView;

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    [self _installNotifications];
    [self _installObservers];
    [self sjReset];
    return self;
}

- (void)dealloc {
    [self _removeObservers];
    [self _removeNotifications];
}

// MARK: Getter

- (UIImageView *)placeholderImageView {
    if ( _placeholderImageView ) return _placeholderImageView;
    _placeholderImageView = [UIImageView imageViewWithImageStr:@"" viewMode:UIViewContentModeScaleAspectFill];
    _placeholderImageView.alpha = 0.001;
    return _placeholderImageView;
}

// MARK: Public

- (void)sjReset {
    self.enabledRotation = NO;
    [self _removeDeviceOrientationChangeObserver];
}

- (UIImage *)screenshot {
    CMTime time = _player.currentItem.currentTime;
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_asset];
    generator.appliesPreferredTrackTransform = YES;
    return [UIImage imageWithCGImage:[generator copyCGImageAtTime:time actualTime:&time error:nil]];
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImageView.image = placeholderImage;
}

- (BOOL)isLandscapeVideo {
    CGSize size = [self _sjVideoRect].size;
    return size.width > size.height;
}

// MARK: Private

- (void)_setupView {
    self.backgroundColor = [UIColor blackColor];
    self.lastOrientation = UIDeviceOrientationPortrait;
    [self addSubview:self.placeholderImageView];
    [_placeholderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (CGRect)_sjVideoRect {
    return [(AVPlayerLayer *)self.layer videoRect];
}

// MARK: Anima

- (void)_showPlaceholderImage {
    self.placeholderImageView.alpha = 1;
}

- (void)_hiddenPlaceholderImage {
    [UIView animateWithDuration:0.25 animations:^{
        self.placeholderImageView.alpha = 0.001;
    }];
}

@end



// MARK: 通知处理

#define SJSCREEN_H  CGRectGetHeight([[UIScreen mainScreen] bounds])
#define SJSCREEN_W  CGRectGetWidth([[UIScreen mainScreen] bounds])

#define SJSCREEN_MIN MIN(SJSCREEN_H,SJSCREEN_W)
#define SJSCREEN_MAX MAX(SJSCREEN_H,SJSCREEN_W)


#import "SJVideoPlayerStringConstant.h"

#pragma mark -

@implementation SJVideoPlayerPresentView (DBNotifications)

// MARK: 通知安装

- (void)_installNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerBeginPlayingNotification) name:SJPlayerBeginPlayingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayToEndTimeNotification) name:SJPlayerDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerScrollInNotification) name:SJPlayerScrollInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerScrollOutNotification) name:SJPlayerScrollOutNotification object:nil];
}

- (void)_removeNotifications {
    [self _removeDeviceOrientationChangeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playerBeginPlayingNotification {
    [self _hiddenPlaceholderImage];
    [self _addDeviceOrientationChangeObserver];
}

- (void)playerDidPlayToEndTimeNotification {
    [self _showPlaceholderImage];
}

- (void)_addDeviceOrientationChangeObserver {
    if ( ![UIDevice currentDevice].generatesDeviceOrientationNotifications ) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)_removeDeviceOrientationChangeObserver {
    if ( [UIDevice currentDevice].generatesDeviceOrientationNotifications ) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)handleDeviceOrientationChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if ( self.lastOrientation == orientation ) return;
    
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            self.lastOrientation = orientation; /// 屏幕向左横置
            break;
            
        case UIDeviceOrientationLandscapeRight:
            self.lastOrientation = orientation; /// 屏幕向右橫置
            break;
            
        case UIDeviceOrientationPortrait:
            self.lastOrientation = orientation; /// 屏幕直立
            break;
        default: {}
            break;
    }
}

- (void)playerScrollInNotification {
    [self _addDeviceOrientationChangeObserver];
}

- (void)playerScrollOutNotification {
    [self _removeDeviceOrientationChangeObserver];
}

@end


#pragma mark -

@implementation SJVideoPlayerPresentView (ControlDelegateMethods)

- (void)clickedFullScreenBtnEvent:(SJVideoPlayerControl *)control {
    if ( self.superview == self.assetCarrier.presentViewSuperView )
        self.lastOrientation = UIDeviceOrientationLandscapeLeft;
    else
        self.lastOrientation = UIDeviceOrientationPortrait;
}

- (void)clickedBackBtnEvent:(SJVideoPlayerControl *)control {
    // status : clicked back
    if ( self.superview == self.assetCarrier.presentViewSuperView ) {
        if ( _back ) _back();
    }
    // status : full screen
    else
        self.lastOrientation = UIDeviceOrientationPortrait;
}

- (void)clickedUnlockBtnEvent:(SJVideoPlayerControl *)control {
    // 锁屏
    [self _removeDeviceOrientationChangeObserver];
    [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerLockedScreenNotification object:nil];
}

- (void)clickedLockBtnEvent:(SJVideoPlayerControl *)control {
    // 解锁
    [self _addDeviceOrientationChangeObserver];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerUnlockedScreenNotification object:nil];
}

@end

#import <objc/message.h>

#pragma mark -

@implementation SJVideoPlayerPresentView  (PresentViewRotation)

- (void)setOrientation:(SJVideoPlayerPresentOrientation)orientation {
    objc_setAssociatedObject(self, @selector(orientation), @(orientation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJVideoPlayerPresentOrientation)orientation {
    return (SJVideoPlayerPresentOrientation)[objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setEnabledRotation:(BOOL)enabledRotation {
    if ( self.enabledRotation == enabledRotation ) return;
    objc_setAssociatedObject(self, @selector(isEnabledRotation), @(enabledRotation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isEnabledRotation {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end









// MARK: Observers

#pragma mark -

typedef NSString * SJPlayerObserverKey;

@implementation SJVideoPlayerPresentView (DBObservers)


static const SJPlayerObserverKey enabledRotationKey = @"enabledRotation";
static const SJPlayerObserverKey lastOrientationKey = @"lastOrientation";
static const SJPlayerObserverKey assetCarrierKey = @"assetCarrier";


//static NSString *

- (void)_installObservers {
//    [self addObserver:self forKeyPath:@"" options:NSKeyValueObservingOptionNew context:nil];
    
    [self addObserver:self forKeyPath:enabledRotationKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:lastOrientationKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:assetCarrierKey options:NSKeyValueObservingOptionNew context:nil];
}

- (void)_removeObservers {
//    [self removeObserver:self forKeyPath:@""];
    
    [self removeObserver:self forKeyPath:enabledRotationKey];
    [self removeObserver:self forKeyPath:lastOrientationKey];
    [self removeObserver:self forKeyPath:assetCarrierKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//   else if      ( [keyPath isEqualToString:@""] ) {}
    
    if      ( [keyPath isEqualToString:enabledRotationKey] ) {
        [self _enabledRotationChanged];
    }
    else if ( [keyPath isEqualToString:lastOrientationKey] ) {
        [self _lastOrientationChanged];
    }
    else if ( [keyPath isEqualToString:assetCarrierKey] ) {
        [self _assetCarrierChanged];
    }
}

- (void)_enabledRotationChanged {
    if ( !self.enabledRotation )
        [self _removeDeviceOrientationChangeObserver];
    else
        [self _addDeviceOrientationChangeObserver];
}

- (void)_lastOrientationChanged {
    switch (self.lastOrientation) {
        case UIDeviceOrientationLandscapeLeft: {
            self.orientation = SJVideoPlayerPresentOrientationLandscapeLeft;
            [self _deviceOrientationLandscape];
        }
            break;
            
        case UIDeviceOrientationLandscapeRight: {
            self.orientation = SJVideoPlayerPresentOrientationLandscapeRight;
            [self _deviceOrientationLandscape];
        }
            break;
            
        case UIDeviceOrientationPortrait: {
            self.orientation = SJVideoPlayerPresentOrientationPortrait;
            [self _deviceOrientationPortrait];
        }
            break;
        default: {}
            break;
    }
}


- (void)_deviceOrientationLandscape {
    if ( !self.assetCarrier.presentViewSuperView ) return;
    [self removeFromSuperview];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    BOOL isLandscapeView = [self isLandscapeVideo];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        if ( isLandscapeView ) {
            make.center.mas_offset(CGPointMake(0, 0));
            make.width.offset(SJSCREEN_MAX);
            make.height.offset(SJSCREEN_MIN);
        }
        else make.edges.offset(0);
    }];
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
    if ( self.lastOrientation == UIDeviceOrientationLandscapeRight ) transform = CGAffineTransformMakeRotation(-M_PI_2);
    [UIView animateWithDuration:0.25 animations:^{
        if ( isLandscapeView ) self.transform = transform;
        else [window layoutIfNeeded];
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerFullScreenNotitication object:nil];
}

- (void)_deviceOrientationPortrait {
    if ( !self.assetCarrier.presentViewSuperView ) return;
    [self removeFromSuperview];
    [self.assetCarrier.presentViewSuperView addSubview:self];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    BOOL isLandscapeView = [self isLandscapeVideo];
    [UIView animateWithDuration:0.25 animations:^{
        if ( isLandscapeView ) self.transform = CGAffineTransformIdentity;
        else [self.assetCarrier.presentViewSuperView layoutIfNeeded];
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerSmallScreenNotification object:nil];
}

- (void)_assetCarrierChanged {
    self.asset = self.assetCarrier.asset;
    self.player = self.assetCarrier.player;
    [(AVPlayerLayer *)self.layer setPlayer:self.player];
    [self _showPlaceholderImage];
}

@end



#pragma mark -

@implementation SJVideoPlayerAssetCarrier (PresentViewExtention)

- (void)setPresentViewSuperView:(UIView *)presentViewSuperView {
    objc_setAssociatedObject(self, @selector(presentViewSuperView), presentViewSuperView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)presentViewSuperView {
    return objc_getAssociatedObject(self, _cmd);
}

@end
