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


// MARK: 通知处理

@interface SJVideoPlayerPresentView (DBNotifications)

- (void)_SJVideoPlayerPresentViewInstallNotifications;

- (void)_SJVideoPlayerPresentViewRemoveNotifications;

@end






@interface SJVideoPlayerPresentView ()

@property (nonatomic, strong, readwrite) AVPlayer *player;

@property (nonatomic, weak, readwrite) UIView *superv;

@end

@implementation SJVideoPlayerPresentView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerPresentViewInstallNotifications];
    return self;
}

- (void)dealloc {
    [self _SJVideoPlayerPresentViewRemoveNotifications];
}

- (void)setPlayer:(AVPlayer *)player superv:(UIView *)superv {
    _player = player;
    [(AVPlayerLayer *)self.layer setPlayer:player];
    
    self.superv = superv;
}

@end



// MARK: 通知处理
#define SJSCREEN_H  CGRectGetHeight([[UIScreen mainScreen] bounds])
#define SJSCREEN_W  CGRectGetWidth([[UIScreen mainScreen] bounds])

#define SJSCREEN_MIN MIN(SJSCREEN_H,SJSCREEN_W)
#define SJSCREEN_MAX MAX(SJSCREEN_H,SJSCREEN_W)


@implementation SJVideoPlayerPresentView (DBNotifications)

// MARK: 通知安装

- (void)_SJVideoPlayerPresentViewInstallNotifications {
    [self _addDeviceOrientationChangeObserver];
}

- (void)_SJVideoPlayerPresentViewRemoveNotifications {
    [self _removeDeviceOrientationChangeObserver];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleDeviceOrientationChange:(NSNotification *)notification {
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft: {
            /// 屏幕向左横置
            [self _deviceOrientationLandscapeLeft];
        }
            break;
            
        case UIDeviceOrientationLandscapeRight: {
            /// 屏幕向右橫置
            [self _deviceOrientationLandscapeRight];
        }
            break;
            
        case UIDeviceOrientationPortrait: {
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
        NSLog(@"back");
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
