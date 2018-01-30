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
    __weak typeof(self) _self = self;
    self.setting = ^(SJVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.lockBtn setImage:setting.lockBtnImage forState:UIControlStateNormal];
        [self.unlockBtn setImage:setting.unlockBtnImage forState:UIControlStateNormal];
    };
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
        make.edges.equalTo(_lockBtn.superview);
    }];
    
    [_unlockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_unlockBtn.superview);
    }];
}

- (UIButton *)lockBtn {
    if ( _lockBtn ) return _lockBtn;
    _lockBtn = [SJUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:SJVideoPlayControlViewTag_Lock];
    return _lockBtn;
}

- (UIButton *)unlockBtn {
    if ( _unlockBtn ) return _unlockBtn;
    _unlockBtn = [SJUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:SJVideoPlayControlViewTag_Unlock];
    return _unlockBtn;
}

@end
