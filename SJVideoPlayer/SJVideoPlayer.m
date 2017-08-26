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

#import "SJVideoPlayerMoreSetting.h"

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

- (void)setClickedBackEvent:(void (^)())clickedBackEvent {
    _presentView.back = clickedBackEvent;
}

- (void)setAssetURL:(NSURL *)assetURL {
    _assetURL = assetURL;
    [self _sjVideoPlayerPrepareToPlay];
}

- (void)setPlaceholder:(UIImage *)placeholder {
    _placeholder = placeholder;
    _presentView.placeholderImage = placeholder;
}

- (void)setMoreSettings:(NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    _moreSettings = moreSettings;
    _control.moreSettings = moreSettings;
}

// MARK: Public

- (UIView *)view {
    return self.containerView;
}


// MARK: Private

- (void)_sjVideoPlayerPrepareToPlay {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerPrepareToPlayNotification object:nil];
    
    _error = nil;
    
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
    
    _control.delegate = _presentView;
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

@implementation SJVideoPlayer (DBNotifications)

// MARK: 通知安装

- (void)_SJVideoPlayerInstallNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlayFailedErrorNotification:) name:SJPlayerPlayFailedErrorNotification object:nil];
}

- (void)_SJVideoPlayerRemoveNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playerPlayFailedErrorNotification:(NSNotification *)notifi {
    _error = notifi.object;
}

@end






@implementation SJVideoPlayer (Operation)

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL finished))completionHandler {
    [_control jumpedToTime:time completionHandler:completionHandler];
}

- (void)stop {
    [_presentView sjReset];
    [_control sjReset];
}

@end
