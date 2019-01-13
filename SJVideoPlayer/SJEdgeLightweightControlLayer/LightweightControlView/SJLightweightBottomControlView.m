//
//  SJLightweightBottomControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJLightweightBottomControlView.h"
#import "SJProgressSlider.h"
#if __has_include(<SJUIFactory/SJUIFactory.h>)
#import <SJUIFactory/SJUIFactory.h>
#else
#import "SJUIFactory.h"
#endif
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#import "UIView+SJControlAdd.h"
#import "SJVideoPlayerControlMaskView.h"
#import "UIView+SJVideoPlayerSetting.h"

@interface SJLightweightBottomControlView ()
@property (nonatomic, strong, readonly) UIButton *playBtn;
@property (nonatomic, strong, readonly) UIButton *pauseBtn;
@property (nonatomic, strong, readonly) UILabel *currentTimeLabel;
@property (nonatomic, strong, readonly) UILabel *separateLabel;
@property (nonatomic, strong, readonly) UILabel *durationTimeLabel;
@property (nonatomic, strong, readonly) UIButton *fullBtn;

@property (nonatomic, strong) UIImage *fullScreenImage;
@property (nonatomic, strong) UIImage *shrinkscreenImage;

@end

@implementation SJLightweightBottomControlView
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
    [self _initializeSettingRecorder];
    [self setStopped:YES];
    return self; 
}

- (CGSize)intrinsicContentSize {
    if ( _isFullscreen ) return CGSizeMake(SJScreen_Max(), 60);
    
    if ( _isFitOnScreen ) {
        if ( SJ_is_iPhoneX() ) return CGSizeMake(SJScreen_Max(), 100);
        return CGSizeMake(SJScreen_Max(), 60);
    }
    return CGSizeMake(SJScreen_Max(), 49);
}

- (void)setIsFullscreen:(BOOL)isFullscreen {
    _isFullscreen = isFullscreen;
    [self _updateFullBtnImage];
    [self invalidateIntrinsicContentSize];
}

- (void)setIsFitOnScreen:(BOOL)isFitOnScreen {
    _isFitOnScreen = isFitOnScreen;
    [self _updateFullBtnImage];
    [self invalidateIntrinsicContentSize];
}

- (void)setHiddenFullscreenBtn:(BOOL)hiddenFullscreenBtn {
    if ( hiddenFullscreenBtn == _hiddenFullscreenBtn ) return;
    _hiddenFullscreenBtn = hiddenFullscreenBtn;
    _fullBtn.hidden = hiddenFullscreenBtn;
    if ( hiddenFullscreenBtn ) {
        [_progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self->_durationTimeLabel.mas_trailing).offset(12);
            make.height.centerY.equalTo(self->_playBtn);
            make.trailing.offset(-16);
        }];
    }
    else {
        [_progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self->_durationTimeLabel.mas_trailing).offset(12);
            make.height.centerY.equalTo(self->_playBtn);
            make.trailing.equalTo(self->_fullBtn.mas_leading).offset(-8);
        }];
    }
}

- (void)setStopped:(BOOL)stopped {
    _stopped = stopped;
    [UIView animateWithDuration:0.3 animations:^{
        if ( stopped ) {
            self.playBtn.alpha = 1;
            self.pauseBtn.alpha = 0.001;
        }
        else {
            self.playBtn.alpha = 0.001;
            self.pauseBtn.alpha = 1;
        }
    }];
}

- (void)setCurrentTimeStr:(NSString *)currentTimeStr {
    self.currentTimeLabel.text = currentTimeStr;
}

- (void)setCurrentTimeStr:(NSString *)currentTimeStr totalTimeStr:(NSString *)totalTimeStr {
    self.currentTimeLabel.text = currentTimeStr;
    self.durationTimeLabel.text = totalTimeStr;
}

- (void)clickedBtn:(UIButton *)btn {
    if ( ![_delegate respondsToSelector:@selector(bottomControlView:clickedViewTag:)] ) return;
    [_delegate bottomControlView:self clickedViewTag:btn.tag];
}

#pragma mark -

- (void)_bottomSetupView {
    [self addSubview:self.playBtn];
    [self addSubview:self.pauseBtn];
    [self addSubview:self.currentTimeLabel];
    [self addSubview:self.separateLabel];
    [self addSubview:self.durationTimeLabel];
    [self addSubview:self.progressSlider];
    [self addSubview:self.fullBtn];
    
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.offset(0);
        make.size.offset(49);
    }];
    
    [_pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_playBtn);
    }];
    
    [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self->_separateLabel);
        make.leading.equalTo(self->_playBtn.mas_trailing).offset(-8);
        make.width.equalTo(self->_durationTimeLabel).offset(8);
    }];
    
    [_separateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self->_playBtn);
        make.leading.equalTo(self->_currentTimeLabel.mas_trailing);
    }];
    
    [_durationTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self->_separateLabel.mas_trailing);
        make.centerY.equalTo(self->_separateLabel);
    }];
    
    [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self->_durationTimeLabel.mas_trailing).offset(12);
        make.height.centerY.equalTo(self->_playBtn);
        make.trailing.equalTo(self->_fullBtn.mas_leading).offset(-8);
    }];
    
    [_fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self->_playBtn);
        make.centerY.equalTo(self->_playBtn);
        make.trailing.offset(0);
    }];
    
    [SJUIFactory boundaryProtectedWithView:_fullBtn];
    [SJUIFactory boundaryProtectedWithView:_playBtn];
    [SJUIFactory boundaryProtectedWithView:_durationTimeLabel];
    [SJUIFactory boundaryProtectedWithView:_progressSlider];
}

- (UIButton *)playBtn {
    if ( _playBtn ) return _playBtn;
    _playBtn = [SJUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:SJLightweightBottomControlViewTag_Play];
    return _playBtn;
}

- (UIButton *)pauseBtn {
    if ( _pauseBtn ) return _pauseBtn;
    _pauseBtn = [SJUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:SJLightweightBottomControlViewTag_Pause];
    return _pauseBtn;
}

- (SJProgressSlider *)progressSlider {
    if ( _progressSlider ) return _progressSlider;
    _progressSlider = [SJProgressSlider new];
    return _progressSlider;
}

- (UIButton *)fullBtn {
    if ( _fullBtn ) return _fullBtn;
    _fullBtn = [SJUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:SJLightweightBottomControlViewTag_Full];
    return _fullBtn;
}

- (UILabel *)separateLabel {
    if ( _separateLabel ) return _separateLabel;
    _separateLabel = [SJUILabelFactory labelWithText:@"/" textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:10]];
    return _separateLabel;
}

- (UILabel *)durationTimeLabel {
    if ( _durationTimeLabel ) return _durationTimeLabel;
    _durationTimeLabel = [SJUILabelFactory labelWithText:@"00:00" textColor:[UIColor whiteColor] alignment:NSTextAlignmentLeft font:[UIFont systemFontOfSize:self.separateLabel.font.pointSize + 1]];
    return _durationTimeLabel;
}

- (UILabel *)currentTimeLabel {
    if ( _currentTimeLabel ) return _currentTimeLabel;
    _currentTimeLabel = [SJUILabelFactory labelWithText:@"00:00" textColor:[UIColor whiteColor] alignment:NSTextAlignmentRight font:[UIFont systemFontOfSize:self.separateLabel.font.pointSize + 1]];
    return _currentTimeLabel;
}

#pragma mark -
- (void)_initializeSettingRecorder {
    __weak typeof(self) _self = self;
    self.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.playBtn setImage:setting.playBtnImage forState:UIControlStateNormal];
        [self.pauseBtn setImage:setting.pauseBtnImage forState:UIControlStateNormal];
        self.fullScreenImage = setting.fullBtnImage;
        self.shrinkscreenImage = setting.shrinkscreenImage;
        [self _updateFullBtnImage];
        
        self.progressSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.progressSlider.trackImageView.backgroundColor = setting.progress_trackColor;
        if ( setting.progress_thumbImage ) {
            self.progressSlider.thumbImageView.image = setting.progress_thumbImage;
        }
        else if ( setting.progress_thumbSize ) {
            [self.progressSlider setThumbCornerRadius:setting.progress_thumbSize * 0.5 size:CGSizeMake(setting.progress_thumbSize, setting.progress_thumbSize) thumbBackgroundColor:setting.progress_thumbColor];
        }
        self.progressSlider.bufferProgressColor = setting.progress_bufferColor;
        self.progressSlider.trackHeight = setting.progress_traceHeight;
        self.progressSlider.loadingColor = setting.loadingLineColor;
    }];
}

- (void)_updateFullBtnImage {
    if ( self.isFullscreen ) [self.fullBtn setImage:self.shrinkscreenImage forState:UIControlStateNormal];
    else [self.fullBtn setImage:self.fullScreenImage forState:UIControlStateNormal];
}
@end
