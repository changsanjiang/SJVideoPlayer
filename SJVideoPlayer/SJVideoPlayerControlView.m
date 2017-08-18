//
//  SJVideoPlayerControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerControlView.h"

#import <AVFoundation/AVPlayer.h>

@interface SJVideoPlayerControlView ()

@end

@implementation SJVideoPlayerControlView

- (void)setPlayer:(AVPlayer *)player {
    _player = player;
    [_player play];
}

@end
