//
//  SJVideoPlayer.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayer.h"

#import <UIKit/UIView.h>

#import <AVFoundation/AVAsset.h>

#import <AVFoundation/AVPlayerItem.h>

#import <AVFoundation/AVPlayer.h>

#import "SJVideoPlayerPresentView.h"

#import "SJVideoPlayerControl.h"

#import <Masonry/Masonry.h>

#import <AVFoundation/AVMetadataItem.h>



// MARK: 通知处理

@interface SJVideoPlayer (DBNotifications)

- (void)_SJVideoPlayerInstallNotifications;

- (void)_SJVideoPlayerRemoveNotifications;

@end




@interface SJVideoPlayer ()

@property (nonatomic, strong, readwrite) AVAsset *asset;
@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;
@property (nonatomic, strong, readwrite) AVPlayer *player;


@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong, readonly) SJVideoPlayerControl *control;
@property (nonatomic, strong, readonly) SJVideoPlayerPresentView *presentView;

@end


@implementation SJVideoPlayer

@synthesize containerView = _containerView;
@synthesize control = _control;
@synthesize presentView = _presentView;



+ (instancetype)sharedPlayer {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self setupView];
    [self _SJVideoPlayerInstallNotifications];
    return self;
}

- (void)dealloc {
    [self _SJVideoPlayerRemoveNotifications];
}

- (void)setupView {
    [self.containerView addSubview:self.presentView];
    [self.presentView addSubview:self.control.view];
    
    [_presentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    [_control.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}


// MARK: Setter

- (void)setAssetURL:(NSURL *)assetURL {
    _assetURL = assetURL;
    [self _sjVideoPlayerPrepareToPlay];
}


// MARK: Public

- (UIView *)view {
    return self.containerView;
}


// MARK: Private

- (void)_sjVideoPlayerPrepareToPlay {
    
    // initialize
    _asset = [AVAsset assetWithURL:_assetURL];
    
    // loaded keys
    NSArray <NSString *> *keys =
    @[@"tracks",
      @"duration",];
    _playerItem = [AVPlayerItem playerItemWithAsset:self.asset automaticallyLoadedAssetKeys:keys];
    _player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    // control
    [_control setAsset:_asset playerItem:_playerItem player:_player];

    // present
    _presentView.player = _player;

}

// MARK: Lazy

- (UIView *)containerView {
    if ( _containerView ) return _containerView;
    _containerView = [UIView new];
    _containerView.backgroundColor = [UIColor blackColor];
    return _containerView;
}

- (SJVideoPlayerPresentView *)presentView {
    if ( _presentView ) return _presentView;
    _presentView = [SJVideoPlayerPresentView new];
    return _presentView;
}

- (SJVideoPlayerControl *)control {
    if ( _control ) return _control;
    _control = [SJVideoPlayerControl new];
    return _control;
}

@end




// MARK: 通知处理

#define SCREEN_HEIGHT CGRectGetHeight([[UIScreen mainScreen] bounds])
#define SCREEN_WIDTH  CGRectGetWidth([[UIScreen mainScreen] bounds])

#define SCREEN_MIN MIN(SCREEN_HEIGHT,SCREEN_WIDTH)
#define SCREEN_MAX MAX(SCREEN_HEIGHT,SCREEN_WIDTH)

@implementation SJVideoPlayer (DBNotifications)

// MARK: 通知安装

- (void)_SJVideoPlayerInstallNotifications {
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)_SJVideoPlayerRemoveNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleDeviceOrientationChange:(NSNotification *)notification {
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft: {
//                        NSLog(@"屏幕向左横置");
            [self.presentView removeFromSuperview];
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [window addSubview:self.presentView];
            [self.presentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.mas_offset(CGPointMake(0, 0));
                make.width.offset(SCREEN_MAX);
                make.height.offset(SCREEN_MIN);
            }];
            
            [UIView animateWithDuration:0.25 animations:^{
                self.presentView.transform = CGAffineTransformMakeRotation(M_PI_2);
            }];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
            break;
            
        case UIDeviceOrientationLandscapeRight: {
//                        NSLog(@"屏幕向右橫置");
            [self.presentView removeFromSuperview];
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [window addSubview:self.presentView];
            [self.presentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.mas_offset(CGPointMake(0, 0));
                make.width.offset(SCREEN_MAX);
                make.height.offset(SCREEN_MIN);
            }];
            [UIView animateWithDuration:0.25 animations:^{
                self.presentView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            }];
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            
        }
            break;
            
        case UIDeviceOrientationPortrait: {
//                        NSLog(@"屏幕直立");
            [self.presentView removeFromSuperview];
            [self.containerView addSubview:self.presentView];
            [self.presentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.offset(0);
            }];
            
            [UIView animateWithDuration:0.25 animations:^{
                self.presentView.transform = CGAffineTransformIdentity;
            }];
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
            break;
        default: {
            
        }
            break;
    }
}

@end

