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


@interface SJVideoPlayerControl (SJVideoPlayerControlViewDelegateMethods)<SJVideoPlayerControlViewDelegate>

@end


@interface SJVideoPlayerControl ()

@property (nonatomic, strong) SJVideoPlayerControlView *controlView;

@end

@implementation SJVideoPlayerControl

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    self.controlView.delegate = self;
    return self;
}


// MARK: Setter

- (void)setPlayer:(AVPlayer *)player {
    _player = player;
    
    [_player play];
}


// MARK: Getter

- (UIView *)view {
    return self.controlView;
}

- (SJVideoPlayerControlView *)controlView {
    if ( _controlView ) return _controlView;
    _controlView = [SJVideoPlayerControlView new];
    return _controlView;
}

@end



@implementation SJVideoPlayerControl (SJVideoPlayerControlViewDelegateMethods)

- (void)clickedBackBtnAtControlView:(SJVideoPlayerControlView *)controlView {
    
}

@end
