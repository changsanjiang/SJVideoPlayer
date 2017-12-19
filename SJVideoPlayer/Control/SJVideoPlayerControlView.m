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
#import "SJVideoPlayerResources.h"

@interface SJVideoPlayerControlView()<SJVideoPlayerTopControlViewDelegate, SJVideoPlayerLeftControlViewDelegate, SJVideoPlayerCenterControlViewDelegate, SJVideoPlayerBottomControlViewDelegate, SJVideoPlayerPreviewViewDelegate>
@end

@implementation SJVideoPlayerControlView
@synthesize bottomProgressSlider = _bottomProgressSlider;
@synthesize previewView = _previewView;
@synthesize topControlView = _topControlView;
@synthesize leftControlView = _leftControlView;
@synthesize centerControlView = _centerControlView;
@synthesize bottomControlView = _bottomControlView;
@synthesize draggingProgressView = _draggingProgressView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _controlSetupView];
    _topControlView.delegate = self;
    _leftControlView.delegate = self;
    _centerControlView.delegate = self;
    _bottomControlView.delegate = self;
    _previewView.delegate = self;
    __weak typeof(self) _self = self;
    self.setting = ^(SJVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.bottomProgressSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.bottomProgressSlider.trackImageView.backgroundColor = setting.progress_trackColor;
    };
    return self;
}

#pragma mark

- (void)_controlSetupView {
    [self.containerView addSubview:self.draggingProgressView];
    [self.containerView addSubview:self.topControlView];
    [self.containerView addSubview:self.leftControlView];
    [self.containerView addSubview:self.centerControlView];
    [self.containerView addSubview:self.bottomControlView];
    [self.containerView addSubview:self.previewView];
    [self.containerView addSubview:self.bottomProgressSlider];
    
    [_topControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.leading.trailing.offset(0);
        make.height.offset(SJControlTopH);
    }];
    
    [_previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topControlView.previewBtn.mas_bottom).offset(12);
        make.leading.trailing.offset(0);
        make.height.offset([UIScreen mainScreen].bounds.size.width * 0.25);
    }];
    
    [_leftControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.offset(SJControlLeftH);
        make.leading.offset(0);
        make.centerY.offset(0);
    }];
    
    [_centerControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.width.equalTo(_centerControlView.superview).multipliedBy(0.382);
        make.height.equalTo(_centerControlView.mas_width);
    }];
    
    [_bottomControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.offset(0);
        make.height.offset(SJControlBottomH);
    }];
    
    [_bottomProgressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.offset(1);
    }];
    
    [_draggingProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_draggingProgressView.superview);
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

- (SJVideoPlayerDraggingProgressView *)draggingProgressView {
    if ( _draggingProgressView ) return _draggingProgressView;
    _draggingProgressView = [SJVideoPlayerDraggingProgressView new];
    return _draggingProgressView;
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

- (void)previewView:(SJVideoPlayerPreviewView *)view didSelectItem:(SJVideoPreviewModel *)item {
    if ( ![_delegate respondsToSelector:@selector(controlView:didSelectPreviewItem:)] ) return;
    [_delegate controlView:self didSelectPreviewItem:item];
}

- (SJVideoPlayerPreviewView *)previewView {
    if ( _previewView ) return _previewView;
    _previewView = [SJVideoPlayerPreviewView new];
    _previewView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    return _previewView;
}
- (SJSlider *)bottomProgressSlider {
    if ( _bottomProgressSlider ) return _bottomProgressSlider;
    _bottomProgressSlider = [SJSlider new];
    _bottomProgressSlider.trackHeight = 1;
    _bottomProgressSlider.pan.enabled = NO;
    return _bottomProgressSlider;
}

@end
