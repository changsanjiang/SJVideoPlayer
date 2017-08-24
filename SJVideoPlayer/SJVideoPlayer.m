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

#import "SJVideoPlayerStringConstant.h"


@interface SJVideoPlayer (ControlDelegateMethods)<SJVideoPlayerControlDelegate>

@end


@interface SJVideoPlayer ()

@property (nonatomic, strong, readwrite) AVAsset *asset;
@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;
@property (nonatomic, strong, readwrite) AVPlayer *player;


@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong, readonly) SJVideoPlayerControl *control;
@property (nonatomic, strong, readonly) SJVideoPlayerPresentView *presentView;

@property (nonatomic, assign, readwrite) BOOL isLock;

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
    return self;
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

- (void)setIsLock:(BOOL)isLock {
    _isLock = isLock;
    NSNotificationName name = nil;
    if ( isLock ) name = SJPlayerLockedScreenNotification;
    else name = SJPlayerUnlockedScreenNotification;
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
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
    [_presentView setPlayer:_player superv:_containerView];
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
    _control.delegate = self;
    return _control;
}

@end





@implementation SJVideoPlayer (ControlDelegateMethods)

- (void)clickedBackBtnEvent:(SJVideoPlayerControl *)control {
//    // status : clicked back
//    if ( self.presentView.superview == self.containerView ) {
//        
//    }
//    // status : full screen
//    else {
//        [self _deviceOrientationPortrait];
//    }
}

- (void)clickedFullScreenBtnEvent:(SJVideoPlayerControl *)control {
//    if ( self.presentView.superview == self.containerView ) {
//        [self _deviceOrientationLandscapeLeft];
//    }
//    else {
//        [self _deviceOrientationPortrait];
//    }
}

- (void)clickedUnlockBtnEvent:(SJVideoPlayerControl *)control {
//    self.isLock = YES;
//    // 锁屏
//    [self _removeDeviceOrientationChangeObserver];
}

- (void)clickedLockBtnEvent:(SJVideoPlayerControl *)control {
//    self.isLock = NO;
//    // 解锁
//    [self _addDeviceOrientationChangeObserver];
}

@end
