//
//  SJVideoPlayerLeftControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerLeftControlView.h"
#import <SJUIFactory/SJUIFactoryHeader.h>
#import "SJVideoPlayerResources.h"
#import <Masonry/Masonry.h>

@interface SJVideoPlayerLeftControlView ()

@end

@implementation SJVideoPlayerLeftControlView
@synthesize lockBtn = _lockBtn;
@synthesize unlockBtn = _unlockBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _leftSetupView];
    return self;
}

- (void)clickedBtn:(UIButton *)btn {
    if ( ![_delegate respondsToSelector:@selector(leftControlView:clickedBtnTag:)] ) return;
    [_delegate leftControlView:self clickedBtnTag:btn.tag];
}

- (void)_leftSetupView {
    [self.containerView addSubview:self.lockBtn];
    [self.containerView addSubview:self.unlockBtn];
    
    [_lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_unlockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (UIButton *)lockBtn {
    if ( _lockBtn ) return _lockBtn;
    _lockBtn = [SJUIFactory buttonWithImageName:[SJVideoPlayerResources bundleComponentWithImageName:@"sj_video_player_lock"] target:self sel:@selector(clickedBtn:) tag:SJVideoPlayControlViewTag_Lock];
    return _lockBtn;
}

- (UIButton *)unlockBtn {
    if ( _unlockBtn ) return _unlockBtn;
    _unlockBtn = [SJUIFactory buttonWithImageName:[SJVideoPlayerResources bundleComponentWithImageName:@"sj_video_player_unlock"] target:self sel:@selector(clickedBtn:) tag:SJVideoPlayControlViewTag_Unlock];
    return _unlockBtn;
}

@end
