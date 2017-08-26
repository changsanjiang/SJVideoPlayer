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

#import "UIView+Extension.h"

#import <AVFoundation/AVAssetImageGenerator.h>

#import <AVFoundation/AVPlayerItem.h>

// MARK: 通知处理

@interface SJVideoPlayerPresentView (DBNotifications)

- (void)_SJVideoPlayerPresentViewInstallNotifications;

- (void)_SJVideoPlayerPresentViewRemoveNotifications;

- (void)_addDeviceOrientationChangeObserver;

- (void)_removeDeviceOrientationChangeObserver;

@end






@interface SJVideoPlayerPresentView ()

@property (nonatomic, strong, readwrite) AVPlayer *player;

@property (nonatomic, strong, readwrite) AVAsset *asset;

@property (nonatomic, weak, readwrite) UIView *superv;

@property (nonatomic, assign, readwrite) UIDeviceOrientation lastOrientation;

@property (nonatomic, strong, readonly) UIImageView *placeholderImageView;

@end

@implementation SJVideoPlayerPresentView

@synthesize placeholderImageView = _placeholderImageView;

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    self.backgroundColor = [UIColor blackColor];
    self.lastOrientation = UIDeviceOrientationPortrait;
    [self addSubview:self.placeholderImageView];
    [_placeholderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    [self _SJVideoPlayerPresentViewInstallNotifications];
    return self;
}

- (void)dealloc {
    [self _SJVideoPlayerPresentViewRemoveNotifications];
}

- (void)setPlayer:(AVPlayer *)player asset:(AVAsset *)asset superv:(UIView *)superv {
    _player = player;
    _asset = asset;
    [(AVPlayerLayer *)self.layer setPlayer:player];
    [UIView animateWithDuration:0.25 animations:^{
        self.placeholderImageView.alpha = 1;
    }];
    self.superv = superv;
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImageView.image = placeholderImage;
}

- (UIImageView *)placeholderImageView {
    if ( _placeholderImageView ) return _placeholderImageView;
    _placeholderImageView = [UIImageView imageViewWithImageStr:@"" viewMode:UIViewContentModeScaleAspectFit];
    _placeholderImageView.alpha = 0.001;
    return _placeholderImageView;
}

- (void)sjReset {
    _player = nil;
    _asset = nil;
    _superv = nil;
    [self _removeDeviceOrientationChangeObserver];
}

- (UIImage *)screenShot {
    CMTime time = _player.currentItem.currentTime;
    return [UIImage imageWithCGImage:[[AVAssetImageGenerator assetImageGeneratorWithAsset:_asset] copyCGImageAtTime:time actualTime:&time error:nil]];
}

@end



// MARK: 通知处理
#define SJSCREEN_H  CGRectGetHeight([[UIScreen mainScreen] bounds])
#define SJSCREEN_W  CGRectGetWidth([[UIScreen mainScreen] bounds])

#define SJSCREEN_MIN MIN(SJSCREEN_H,SJSCREEN_W)
#define SJSCREEN_MAX MAX(SJSCREEN_H,SJSCREEN_W)


#import "SJVideoPlayerStringConstant.h"


@implementation SJVideoPlayerPresentView (DBNotifications)

// MARK: 通知安装

- (void)_SJVideoPlayerPresentViewInstallNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerBeginPlayingNotification) name:SJPlayerBeginPlayingNotification object:nil];
}

- (void)_SJVideoPlayerPresentViewRemoveNotifications {
    [self _removeDeviceOrientationChangeObserver];
}

- (void)playerBeginPlayingNotification {
    [UIView animateWithDuration:0.25 animations:^{
        self.placeholderImageView.alpha = 0.001;
    }];
    [self _addDeviceOrientationChangeObserver];
}

- (void)_addDeviceOrientationChangeObserver {
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
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
        case UIDeviceOrientationLandscapeLeft: {
            self.lastOrientation = orientation;
            /// 屏幕向左横置
            [self _deviceOrientationLandscapeLeft];
        }
            break;
            
        case UIDeviceOrientationLandscapeRight: {
            self.lastOrientation = orientation;
            /// 屏幕向右橫置
            [self _deviceOrientationLandscapeRight];
        }
            break;
            
        case UIDeviceOrientationPortrait: {
            self.lastOrientation = orientation;
            /// 屏幕直立
            [self _deviceOrientationPortrait];
        }
            break;
        default: {
            
        }
            break;
    }
}

- (void)_deviceOrientationLandscapeLeft {
    [self removeFromSuperview];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_offset(CGPointMake(0, 0));
        make.width.offset(SJSCREEN_MAX);
        make.height.offset(SJSCREEN_MIN);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerFullScreenNotitication object:nil];
}

- (void)_deviceOrientationLandscapeRight {
    [self removeFromSuperview];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_offset(CGPointMake(0, 0));
        make.width.offset(SJSCREEN_MAX);
        make.height.offset(SJSCREEN_MIN);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerFullScreenNotitication object:nil];
}

- (void)_deviceOrientationPortrait {
    [self removeFromSuperview];
    [self.superv addSubview:self];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerSmallScreenNotification object:nil];
}

@end



@implementation SJVideoPlayerPresentView (ControlDelegateMethods)

- (void)clickedFullScreenBtnEvent:(SJVideoPlayerControl *)control {
    if ( self.superview == self.superv ) {
        [self _deviceOrientationLandscapeLeft];
    }
    else {
        [self _deviceOrientationPortrait];
    }
}

- (void)clickedBackBtnEvent:(SJVideoPlayerControl *)control {
    // status : clicked back
    if ( self.superview == self.superv ) {
        if ( _back ) _back();
    }
    // status : full screen
    else {
        [self _deviceOrientationPortrait];
    }
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
