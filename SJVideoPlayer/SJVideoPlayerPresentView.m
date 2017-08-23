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

@interface SJVideoPlayerPresentView ()

@end

@implementation SJVideoPlayerPresentView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    return self;
}

- (void)setPlayer:(AVPlayer *)player {
    _player = player;
    [(AVPlayerLayer *)self.layer setPlayer:player];
}

@end
