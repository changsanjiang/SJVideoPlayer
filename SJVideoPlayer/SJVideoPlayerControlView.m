//
//  SJVideoPlayerControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerControlView.h"

#import <SJSlider/SJSlider.h>

#import <UIKit/UIKit.h>

#import "UIView+Extension.h"

#import <Masonry/Masonry.h>

#import "NSAttributedString+ZFBAdditon.h"

#import <objc/message.h>

@interface SJMaskView : UIView
@end



@interface SJVideoPlayerControlView ()

@property (nonatomic, strong, readonly) UIButton *backBtn;
@property (nonatomic, strong, readonly) UIButton *playBtn;
@property (nonatomic, strong, readonly) UIButton *pauseBtn;
@property (nonatomic, strong, readonly) UIButton *fullBtn;
@property (nonatomic, strong, readonly) UIButton *replayBtn;
@property (nonatomic, strong, readonly) UILabel *currentTimeLabel;
@property (nonatomic, strong, readonly) UILabel *separateLabel;
@property (nonatomic, strong, readonly) UILabel *durationTimeLabel;

@property (nonatomic, strong, readonly) SJMaskView *controlMaskView;

@end

@implementation SJVideoPlayerControlView

@synthesize backBtn = _backBtn;
@synthesize playBtn = _playBtn;
@synthesize pauseBtn = _pauseBtn;
@synthesize fullBtn = _fullBtn;
@synthesize replayBtn = _replayBtn;
@synthesize currentTimeLabel = _currentTimeLabel;
@synthesize separateLabel = _separateLabel;
@synthesize durationTimeLabel = _durationTimeLabel;
@synthesize sliderControl = _sliderControl;
@synthesize controlMaskView = _controlMaskView;


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerControlViewSetupUI];
    return self;
}

// MARK: Actions

- (void)clickedBtn:(UIButton *)btn {
    if ( ![self.delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [self.delegate controlView:self clickedBtnTag:btn.tag];
}

// MARK: UI

- (void)_SJVideoPlayerControlViewSetupUI {
    [self addSubview:self.backBtn];
    [self addSubview:self.replayBtn];
    [self addSubview:self.controlMaskView];
    [_controlMaskView addSubview:self.fullBtn];
    [_controlMaskView addSubview:self.playBtn];
    [_controlMaskView addSubview:self.pauseBtn];
    [_controlMaskView addSubview:self.currentTimeLabel];
    [_controlMaskView addSubview:self.separateLabel];
    [_controlMaskView addSubview:self.durationTimeLabel];
    [_controlMaskView addSubview:self.sliderControl];
    
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_playBtn);
        make.top.offset(12);
        make.leading.offset(0);
    }];
    
    [_replayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [_controlMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.offset(49);
    }];
    
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.offset(0);
        make.width.equalTo(_playBtn.mas_height);
    }];
    
    [_pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_playBtn);
    }];
    
    [_fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.offset(0);
        make.width.equalTo(_fullBtn.mas_height);
    }];
    
    [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_playBtn.mas_trailing);
        make.centerY.equalTo(_separateLabel);
    }];
    
    [_separateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_currentTimeLabel.mas_trailing);
        make.centerY.equalTo(_separateLabel.superview);
    }];
    
    [_durationTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_separateLabel.mas_trailing);
        make.centerY.equalTo(_separateLabel);
    }];
    
    [_sliderControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_durationTimeLabel.mas_trailing).offset(20);
        make.trailing.equalTo(_fullBtn.mas_leading).offset(-8);
        make.top.bottom.offset(0);
    }];
}

- (UIButton *)backBtn {
    if ( _backBtn ) return _backBtn;
    _backBtn = [UIButton buttonWithImageName:@"sj_video_player_back" tag:SJVideoPlayControlViewTag_Back target:self sel:@selector(clickedBtn:)];
    return _backBtn;
}

- (UIButton *)playBtn {
    if ( _playBtn ) return _playBtn;
    _playBtn = [UIButton buttonWithImageName:@"sj_video_player_play" tag:SJVideoPlayControlViewTag_Play target:self sel:@selector(clickedBtn:)];
    return _playBtn;
}

- (UIButton *)pauseBtn {
    if ( _pauseBtn ) return _pauseBtn;
    _pauseBtn = [UIButton buttonWithImageName:@"sj_video_player_pause" tag:SJVideoPlayControlViewTag_Pause target:self sel:@selector(clickedBtn:)];
    return _pauseBtn;
}

- (UIButton *)replayBtn {
    if ( _replayBtn ) return _replayBtn;
    _replayBtn = [UIButton buttonWithTitle:@"" backgroundColor:[UIColor clearColor] tag:SJVideoPlayControlViewTag_Replay target:self sel:@selector(clickedBtn:) fontSize:16];
    _replayBtn.titleLabel.numberOfLines = 3;
    _replayBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSAttributedString *attr = [NSAttributedString mh_imageTextWithImage:[UIImage imageNamed:@"sj_video_player_replay"] imageW:35 imageH:35 title:@"重播" fontSize:16 titleColor:[UIColor whiteColor] spacing:6];
    [_replayBtn setAttributedTitle:attr forState:UIControlStateNormal];
    return _replayBtn;
}

- (UIButton *)fullBtn {
    if ( _fullBtn ) return _fullBtn;
    _fullBtn = [UIButton buttonWithImageName:@"sj_video_player_fullscreen" tag:SJVideoPlayControlViewTag_Full target:self sel:@selector(clickedBtn:)]; 
    return _fullBtn;
}

- (UILabel *)currentTimeLabel {
    if ( _currentTimeLabel ) return _currentTimeLabel;
    _currentTimeLabel = [UILabel labelWithFontSize:12 textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
    _currentTimeLabel.text = @"00:00";
    return _currentTimeLabel;
}

- (UILabel *)separateLabel {
    if ( _separateLabel ) return _separateLabel;
    _separateLabel = [UILabel labelWithFontSize:12 textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
    _separateLabel.text = @"/";
    return _separateLabel;
}

- (UILabel *)durationTimeLabel {
    if ( _durationTimeLabel ) return _durationTimeLabel;
    _durationTimeLabel = [UILabel labelWithFontSize:12 textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
    _durationTimeLabel.text = @"00:00";
    return _durationTimeLabel;
}

- (SJSlider *)sliderControl {
    if ( _sliderControl ) return _sliderControl;
    _sliderControl = [SJSlider new];
    _sliderControl.trackHeight = 2;
    _sliderControl.borderColor = [UIColor clearColor];
    return _sliderControl;
}

- (SJMaskView *)controlMaskView {
    if ( _controlMaskView ) return _controlMaskView;
    _controlMaskView = [SJMaskView new];
    return _controlMaskView;
}

@end





@implementation SJVideoPlayerControlView (HiddenOrShow)

/*!
 *  default is NO
 */
- (void)setHiddenPlayBtn:(BOOL)hiddenPlayBtn {
    if ( hiddenPlayBtn == self.hiddenPlayBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenPlayBtn), @(hiddenPlayBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.playBtn bol:hiddenPlayBtn];
}

- (BOOL)hiddenPlayBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenPauseBtn:(BOOL)hiddenPauseBtn {
    if ( hiddenPauseBtn == self.hiddenPauseBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenPauseBtn), @(hiddenPauseBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.pauseBtn bol:hiddenPauseBtn];
}

- (BOOL)hiddenPauseBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenReplayBtn:(BOOL)hiddenReplayBtn {
    if ( hiddenReplayBtn == self.hiddenReplayBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenReplayBtn), @(hiddenReplayBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.replayBtn bol:hiddenReplayBtn];
}

- (BOOL)hiddenReplayBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}


- (void)hiddenOrShowView:(UIView *)view bol:(BOOL)hidden {
    CGFloat alpha = 1.;
    if ( hidden ) alpha = 0.001;
    [UIView animateWithDuration:0.25 animations:^{
        view.alpha = alpha;
    }];
}

@end




@implementation SJVideoPlayerControlView (TimeOperation)

- (NSString *)formatSeconds:(NSInteger)value {
    NSInteger seconds = value % 60;
    NSInteger minutes = value / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long) minutes, (long) seconds];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    _currentTimeLabel.text = [self formatSeconds:currentTime];
    _durationTimeLabel.text = [self formatSeconds:duration];
    if ( 0 == duration ) return;
    _sliderControl.value = currentTime / duration;
}

@end



@implementation SJMaskView {
    CAGradientLayer *_maskGradientLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self initializeGL];
    return self;
}

- (void)initializeGL {
    _maskGradientLayer = [CAGradientLayer layer];
    _maskGradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                  (__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor];
    [self.layer addSublayer:_maskGradientLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _maskGradientLayer.frame = self.bounds;
}

@end


