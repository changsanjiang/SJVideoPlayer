//
//  SJVideoPlayerControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerControlView.h"
#import "SJVideoPlayerBottomControlView.h"
#import <Masonry/Masonry.h>
#import "SJVideoPlayer.h"

@interface SJVideoPlayerControlView ()<SJVideoPlayerControlViewDelegate>

@property (nonatomic, strong, readonly) SJVideoPlayerBottomControlView *bottomControlView;

@end

@implementation SJVideoPlayerControlView

@synthesize bottomControlView = _bottomControlView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _controlViewSetupView];
    return self;
}

- (void)setVideoPlayer:(SJVideoPlayer *)videoPlayer {
    _videoPlayer = videoPlayer;
    _videoPlayer.controlViewDelegate = self;
}

- (void)_controlViewSetupView {
    [self addSubview:self.bottomControlView];
    [_bottomControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.offset(49);
    }];
}

- (SJVideoPlayerBottomControlView *)bottomControlView {
    if ( _bottomControlView ) return _bottomControlView;
    _bottomControlView = [SJVideoPlayerBottomControlView new];
    return _bottomControlView;
}

#pragma mark -

- (UIView *)controlView {
    return self;
}

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer controlLayerNeedChangeDisplayState:(BOOL)displayState {
    [UIView animateWithDuration:0.3 animations:^{
        if ( displayState ) {
            _bottomControlView.transform = CGAffineTransformIdentity;
        }
        else {
            _bottomControlView.transform = CGAffineTransformMakeTranslation(0, 49);
        }
    }];
}

@end
