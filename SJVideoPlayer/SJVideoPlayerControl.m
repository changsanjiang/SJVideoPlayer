//
//  SJVideoPlayerControl.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerControl.h"

#import <AVFoundation/AVPlayer.h>

#import "SJVideoPlayerControlView.h"

#import <AVFoundation/AVPlayerItem.h>



/*!
 *  AVPlayerItem's status property
 */
#define STATUS_KEYPATH @"status"

/*!
 *  Refresh interval for timed observations of AVPlayer
 */
#define REFRESH_INTERVAL (0.5)


static const NSString *SJPlayerItemStatusContext;



@interface SJVideoPlayerControl (SJVideoPlayerControlViewDelegateMethods)<SJVideoPlayerControlViewDelegate>

@end


@interface SJVideoPlayerControl ()

@property (nonatomic, strong, readonly) SJVideoPlayerControlView *controlView;

@property (nonatomic, strong, readwrite) AVPlayer *player;

@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;

@property (nonatomic, strong, readwrite) id timeObserver;

@end

@implementation SJVideoPlayerControl

@synthesize controlView = _controlView;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self controlView];
    return self;
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem player:(AVPlayer *)player {
    _player = player;
    _playerItem = playerItem;
    [_playerItem addObserver:self forKeyPath:STATUS_KEYPATH options:0 context:&SJPlayerItemStatusContext];
}

// MARK: Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( context == &SJPlayerItemStatusContext ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playerItem removeObserver:self forKeyPath:STATUS_KEYPATH];
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                [self.player play];
                [self addPlayerItemTimeObserver];
            } else {
                NSLog(@"Failed to load Video: %@", self.playerItem.error);
                NSLog(@"Failed to load Video: %@", self.playerItem.error);
                NSLog(@"Failed to load Video: %@", self.playerItem.error);
            }
        });
    }
}

- (void)addPlayerItemTimeObserver {
    CMTime interval = CMTimeMakeWithSeconds(REFRESH_INTERVAL, NSEC_PER_SEC);
    dispatch_queue_t queue = dispatch_get_main_queue();
    // Create callback block for time observer
    
    __weak typeof(self) _self = self;
    void (^callback)(CMTime time) = ^(CMTime time) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(self.playerItem.duration);
        
    };
    
    // Add observer and store pointer for future use
    self.timeObserver =
    [self.player addPeriodicTimeObserverForInterval:interval
                                              queue:queue
                                         usingBlock:callback];
}

// MARK: Getter

- (UIView *)view {
    return self.controlView;
}

- (SJVideoPlayerControlView *)controlView {
    if ( _controlView ) return _controlView;
    _controlView = [SJVideoPlayerControlView new];
    _controlView.delegate = self;
    _controlView.hiddenPlayBtn = YES;
    _controlView.hiddenReplayBtn = YES;
    return _controlView;
}

@end



@implementation SJVideoPlayerControl (SJVideoPlayerControlViewDelegateMethods)

- (void)controlView:(SJVideoPlayerControlView *)controlView clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    switch (tag) {
        case SJVideoPlayControlViewTag_Play:
            [self play];
            break;
        case SJVideoPlayControlViewTag_Pause:
            [self pause];
            break;
        case SJVideoPlayControlViewTag_Replay:
            [self replay];
            break;
        case SJVideoPlayControlViewTag_Back:
            [self back];
            break;
        case SJVideoPlayControlViewTag_Full:
            [self full];
            break;
            
        default:
            break;
    }
}

- (void)play {
    NSLog(@"%zd - %s", __LINE__, __func__);
    
}

- (void)pause {
    NSLog(@"%zd - %s", __LINE__, __func__);
}

- (void)replay {
    NSLog(@"%zd - %s", __LINE__, __func__);
}

- (void)back {
    NSLog(@"%zd - %s", __LINE__, __func__);
}

- (void)full {
    NSLog(@"%zd - %s", __LINE__, __func__);
}

@end
