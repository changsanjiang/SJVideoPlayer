//
//  SJVideoPlayerBottomControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerBottomControlView.h"
#import <SJUIFactory/SJUIFactory.h>
#import "SJVideoPlayerResources.h"
#import <Masonry/Masonry.h>
#import "SJVideoPlayerControlMaskView.h"

@interface SJVideoPlayerBottomControlView ()

@property (nonatomic, strong, readonly) SJVideoPlayerControlMaskView *controlMaskView;

@end

@implementation SJVideoPlayerBottomControlView
@synthesize controlMaskView = _controlMaskView;
@synthesize separateLabel = _separateLabel;
@synthesize durationTimeLabel = _durationTimeLabel;
@synthesize playBtn = _playBtn;
@synthesize pauseBtn = _pauseBtn;
@synthesize currentTimeLabel = _currentTimeLabel;
@synthesize progressSlider = _progressSlider;
@synthesize fullBtn = _fullBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _bottomSetupView];
    __weak typeof(self) _self = self;
    self.setting = ^(SJVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.playBtn setImage:setting.playBtnImage forState:UIControlStateNormal];
        [self.pauseBtn setImage:setting.pauseBtnImage forState:UIControlStateNormal];
        [self.fullBtn setImage:setting.fullBtnImage forState:UIControlStateNormal];
        self.progressSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.progressSlider.trackImageView.backgroundColor = setting.progress_trackColor;
        self.progressSlider.thumbImageView.image = setting.progress_thumbImage;
        self.progressSlider.bufferProgressColor = setting.progress_bufferColor;
        self.progressSlider.trackHeight = setting.progress_traceHeight;
    };
    return self;
}

- (void)clickedBtn:(UIButton *)btn {
    if ( ![_delegate respondsToSelector:@selector(bottomControlView:clickedBtnTag:)] ) return;
    [_delegate bottomControlView:self clickedBtnTag:btn.tag];
}

- (void)_bottomSetupView {
    [self.containerView addSubview:self.controlMaskView];
    [self.containerView addSubview:self.playBtn];
    [self.containerView addSubview:self.pauseBtn];
    [self.containerView addSubview:self.currentTimeLabel];
    [self.containerView addSubview:self.separateLabel];
    [self.containerView addSubview:self.durationTimeLabel];
    [self.containerView addSubview:self.progressSlider];
    [self.containerView addSubview:self.fullBtn];
    
    [_controlMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_controlMaskView.superview);
    }];

    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(0);
        make.size.offset(49);
        make.bottom.offset(-8);
    }];
    
    [_pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_playBtn);
    }];
    
    [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_separateLabel);
        make.leading.equalTo(_playBtn.mas_trailing).offset(0);
    }];
    
    [_separateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_playBtn);
        make.leading.equalTo(_currentTimeLabel.mas_trailing);
    }];

    [_durationTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_separateLabel.mas_trailing);
        make.centerY.equalTo(_separateLabel);
    }];
    
    [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_playBtn.mas_trailing).offset(86 + 8);
        make.height.centerY.equalTo(_playBtn);
        make.trailing.equalTo(_fullBtn.mas_leading).offset(-8);
    }];
    
    [_fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_playBtn);
        make.centerY.equalTo(_playBtn);
        make.trailing.offset(0);
    }];
    
    
    [SJUIFactory boundaryProtectedWithView:_currentTimeLabel];
    [SJUIFactory boundaryProtectedWithView:_separateLabel];
    [SJUIFactory boundaryProtectedWithView:_durationTimeLabel];
    [SJUIFactory boundaryProtectedWithView:_progressSlider];
}

- (UIButton *)playBtn {
    if ( _playBtn ) return _playBtn;
    _playBtn = [SJUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:SJVideoPlayControlViewTag_Play];
    return _playBtn;
}

- (UIButton *)pauseBtn {
    if ( _pauseBtn ) return _pauseBtn;
    _pauseBtn = [SJUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:SJVideoPlayControlViewTag_Pause];
    return _pauseBtn;
}

- (SJSlider *)progressSlider {
    if ( _progressSlider ) return _progressSlider;
    _progressSlider = [SJSlider new];
    _progressSlider.tag = SJVideoPlaySliderTag_Progress;
    _progressSlider.enableBufferProgress = YES;
    return _progressSlider;
}

- (UIButton *)fullBtn {
    if ( _fullBtn ) return _fullBtn;
    _fullBtn = [SJUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:SJVideoPlayControlViewTag_Full];
    return _fullBtn;
}

- (UILabel *)separateLabel {
    if ( _separateLabel ) return _separateLabel;
    _separateLabel = [SJUILabelFactory labelWithText:@"/" textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:13]];
    return _separateLabel;
}

- (UILabel *)durationTimeLabel {
    if ( _durationTimeLabel ) return _durationTimeLabel;
    _durationTimeLabel = [SJUILabelFactory labelWithText:@"00:00" textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:13]];
    return _durationTimeLabel;
}

- (UILabel *)currentTimeLabel {
    if ( _currentTimeLabel ) return _currentTimeLabel;
    _currentTimeLabel = [SJUILabelFactory labelWithText:@"00:00" textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:13]];
    return _currentTimeLabel;
}

- (SJVideoPlayerControlMaskView *)controlMaskView {
    if ( _controlMaskView ) return _controlMaskView;
    _controlMaskView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_bottom];
    return _controlMaskView;
}

@end
