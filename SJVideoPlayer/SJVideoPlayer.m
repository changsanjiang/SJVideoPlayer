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


@interface SJVideoPlayer ()

@property (nonatomic, strong, readwrite) AVAsset *asset;
@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;
@property (nonatomic, strong, readwrite) AVPlayer *player;


@property (nonatomic, strong, readonly) SJVideoPlayerControl *control;
@property (nonatomic, strong, readonly) SJVideoPlayerPresentView *presentView;

@end


@implementation SJVideoPlayer

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
    [self.presentView addSubview:self.control.view];
    [_control.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    return self;
}


// MARK: Setter

- (void)setAssetURL:(NSURL *)assetURL {
    _assetURL = assetURL;
    [self _sjVideoPlayerPrepareToPlay];
}


// MARK: Public

- (UIView *)view {
    return self.presentView;
}


// MARK: Private

- (void)_sjVideoPlayerPrepareToPlay {
    
    [self _sjVideoPlayerResetPlayer];
    
    // initialize
    _asset = [AVAsset assetWithURL:_assetURL];
    
    // loaded keys
    NSArray <NSString *> *keys =
    @[@"tracks",
      @"duration",
      @"commonMetadata",
      @"availableMediaCharacteristicsWithMediaSelectionOptions"];
    _playerItem = [AVPlayerItem playerItemWithAsset:self.asset automaticallyLoadedAssetKeys:keys];
    _player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    // present
    _presentView.player = _player;
    
    // control
    [_control setPlayerItem:_playerItem player:_player];
}

- (void)_sjVideoPlayerResetPlayer {
    NSLog(@"Reset Player");
}

// MARK: Lazy

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
