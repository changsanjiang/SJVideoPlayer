//
//  SJVideoPlayerControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerControlView.h"
#import "SJVideoPlayerAssetCarrier.h"
#import "SJVideoPreviewModel.h"
#import <Masonry/Masonry.h>

@interface SJVideoPlayerControlView()<SJVideoPlayerTopControlViewDelegate, SJVideoPlayerLeftControlViewDelegate, SJVideoPlayerCenterControlViewDelegate, SJVideoPlayerBottomControlViewDelegate>
@end

@implementation SJVideoPlayerControlView
@synthesize previewView = _previewView;

@synthesize topControlView = _topControlView;
@synthesize leftControlView = _leftControlView;
@synthesize centerControlView = _centerControlView;
@synthesize bottomControlView = _bottomControlView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _controlSetupView];
    _topControlView.delegate = self;
    _leftControlView.delegate = self;
    _centerControlView.delegate = self;
    _bottomControlView.delegate = self;
    return self;
}

#pragma mark

- (void)_controlSetupView {
    [self.containerView addSubview:self.topControlView];
    [self.containerView addSubview:self.leftControlView];
    [self.containerView addSubview:self.centerControlView];
    [self.containerView addSubview:self.bottomControlView];
    [self.containerView addSubview:self.previewView];
    
    [_topControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
        make.height.offset(49);
    }];
    
    [_previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topControlView.mas_bottom);
        make.leading.trailing.offset(0);
        make.height.equalTo(_previewView.superview).multipliedBy(0.32);
    }];
    
    [_leftControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.offset(49);
        make.leading.offset(0);
        make.centerY.offset(0);
    }];
    
    [_centerControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsMake(49, 49, 49, 49));
    }];
    
    [_bottomControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.offset(0);
        make.height.offset(49);
    }];
}

- (SJVideoPlayerTopControlView *)topControlView {
    if ( _topControlView ) return _topControlView;
    _topControlView = [SJVideoPlayerTopControlView new];
    return _topControlView;
}

- (SJVideoPlayerLeftControlView *)leftControlView {
    if ( _leftControlView ) return _leftControlView;
    _leftControlView = [SJVideoPlayerLeftControlView new];
    return _leftControlView;
}

- (SJVideoPlayerCenterControlView *)centerControlView {
    if ( _centerControlView ) return _centerControlView;
    _centerControlView = [SJVideoPlayerCenterControlView new];
    return _centerControlView;
}

- (SJVideoPlayerBottomControlView *)bottomControlView {
    if ( _bottomControlView ) return _bottomControlView;
    _bottomControlView = [SJVideoPlayerBottomControlView new];
    return _bottomControlView;
}

#pragma mark
- (void)topControlView:(SJVideoPlayerTopControlView *)view clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    if ( ![_delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [_delegate controlView:self clickedBtnTag:tag];
}

- (void)leftControlView:(SJVideoPlayerLeftControlView *)view clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    if ( ![_delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [_delegate controlView:self clickedBtnTag:tag];
}

- (void)centerControlView:(SJVideoPlayerCenterControlView *)view clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    if ( ![_delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [_delegate controlView:self clickedBtnTag:tag];
}

- (void)bottomControlView:(SJVideoPlayerBottomControlView *)view clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    if ( ![_delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [_delegate controlView:self clickedBtnTag:tag];
}

- (SJVideoPlayerPreviewView *)previewView {
    if ( _previewView ) return _previewView;
    _previewView = [SJVideoPlayerPreviewView new];
    _previewView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    return _previewView;
}
@end
