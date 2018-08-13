//
//  SJLightweightDraggingProgressView.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJLightweightDraggingProgressView.h"
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
#import "SJProgressSlider.h"
#import "UIView+SJVideoPlayerSetting.h"


@interface SJLightweightDraggingProgressView ()

@property (nonatomic, strong, readonly) SJProgressSlider *progressSlider;
@property (nonatomic, strong, readonly) UIImageView *directionImageView;
@property (nonatomic, strong, readonly) UIImageView *previewImageView;

@property (nonatomic, strong, readonly) UILabel *shiftTimeLabel;
@property (nonatomic, strong, readonly) UILabel *spritTimeLabel;    // `/`
@property (nonatomic, strong, readonly) UILabel *durationTimeLabel;

@property (nonatomic, strong) UIImage *fastImage;
@property (nonatomic, strong) UIImage *forwardImage;

@end

@implementation SJLightweightDraggingProgressView

@synthesize directionImageView = _directionImageView;
@synthesize previewImageView = _previewImageView;
@synthesize progressSlider = _progressSlider;

@synthesize shiftTimeLabel = _shiftTimeLabel;
@synthesize spritTimeLabel = _spritTimeLabel;
@synthesize durationTimeLabel = _durationTimeLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _draggingProgressSetupView];
    [self _draggingViewSetting];
    [SJUIFactory boundaryProtectedWithView:self];
    return self;
}

- (CGSize)intrinsicContentSize {
    switch ( _style ) {
        case SJLightweightDraggingProgressViewStyleArrowProgress: {
            CGFloat width = SJScreen_W() * (150.0 / 375);
            CGFloat height = width * 8 / 15;
            return CGSizeMake(ceil(width), ceil(height));
        }
            break;
        case SJLightweightDraggingProgressViewStylePreviewProgress: {
            CGFloat width = SJScreen_W() * ( 120.0 / 375);
            CGFloat height = width * 3 / 4;
            return CGSizeMake(ceil(width), ceil(height));
        }
            break;
    }
    return CGSizeZero;
}

- (void)setStyle:(SJLightweightDraggingProgressViewStyle)style {
    
    switch ( _style = style ) {
        case SJLightweightDraggingProgressViewStyleArrowProgress: {
            _previewImageView.hidden = YES;
            _progressSlider.trackHeight = 3;
            [_directionImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.offset(0);
                make.bottom.equalTo(self.mas_centerY);
                make.centerX.offset(0);
            }];
            
            [_progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.offset(8);
                make.trailing.offset(-8);
                make.top.equalTo(self.mas_centerY).offset(8);
                make.height.offset(3);
            }];
            
            [_spritTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.offset(0);
                make.top.equalTo(self->_progressSlider.mas_bottom);
                make.bottom.offset(0);
            }];
        }
            break;
        case SJLightweightDraggingProgressViewStylePreviewProgress: {
            _previewImageView.hidden = NO;
            _progressSlider.trackHeight = 2;
            [_directionImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.offset(10.0 / 375 * SJScreen_W());
                make.centerY.equalTo(self->_spritTimeLabel);
                make.centerX.equalTo(self).multipliedBy(0.25);
            }];
            
            [_spritTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.offset(0);
                make.top.offset(0);
                make.bottom.equalTo(self->_previewImageView.mas_top);
            }];
            
            [_previewImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.offset(8);
                make.bottom.trailing.offset(-8);
                make.height.equalTo(self->_previewImageView.mas_width).multipliedBy(9.0 / 16);
            }];
            
            [_progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(self->_durationTimeLabel).multipliedBy(2);
                make.top.equalTo(self->_shiftTimeLabel.mas_bottom).offset(4);
                make.centerX.equalTo(self->_spritTimeLabel);
                make.height.offset(3);
            }];
        }
            break;
    }
    
    [self invalidateIntrinsicContentSize];
}

- (void)setShiftProgress:(float)shiftProgress {
    if      ( shiftProgress > 1 ) shiftProgress = 1;
    else if ( shiftProgress < 0 ) shiftProgress = 0;
    else if ( isnan(shiftProgress) ) return;
    
    float beforeShiftProgress = _shiftProgress;
    
    _shiftProgress = shiftProgress;
    
    if ( beforeShiftProgress > _shiftProgress ) {
        _directionImageView.image = _forwardImage;
    }
    else if ( beforeShiftProgress < _shiftProgress ) {
        _directionImageView.image = _fastImage;
    }
    
    _progressSlider.value = shiftProgress;
}

- (void)setPlayProgress:(float)playProgress {
    _progressSlider.bufferProgress = playProgress;
}

- (float)playProgress {
    return _progressSlider.bufferProgress;
}

- (void)setTimeShiftStr:(NSString *)shiftTimeStr {
    _shiftTimeLabel.text = shiftTimeStr;
}

- (void)setTimeShiftStr:(NSString *)shiftTimeStr totalTimeStr:(NSString *)totalTimeStr {
    _shiftTimeLabel.text = shiftTimeStr;
    _durationTimeLabel.text = totalTimeStr;
}

- (void)setPreviewImage:(UIImage *)image {
    _previewImageView.image = image;
}
#pragma mark -

- (void)_draggingProgressSetupView {
    
    [self addSubview:self.progressSlider];
    [self addSubview:self.directionImageView];
    [self addSubview:self.shiftTimeLabel];
    [self addSubview:self.spritTimeLabel];
    [self addSubview:self.durationTimeLabel];
    [self addSubview:self.previewImageView];
    
    [SJUIFactory regulate:self cornerRadius:8];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    self.style = SJLightweightDraggingProgressViewStyleArrowProgress;

    [_shiftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self->_spritTimeLabel.mas_left);
        make.centerY.equalTo(self->_spritTimeLabel);
    }];
    
    [_durationTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_spritTimeLabel.mas_right);
        make.centerY.equalTo(self->_spritTimeLabel);
    }];
}

- (SJProgressSlider *)progressSlider {
    if ( _progressSlider ) return _progressSlider;
    _progressSlider = [SJProgressSlider new];
    _progressSlider.trackHeight = 3;
    _progressSlider.enableBufferProgress = YES;
    _progressSlider.pan.enabled = NO; 
    return _progressSlider;
}

- (UIImageView *)directionImageView {
    if ( _directionImageView ) return _directionImageView;
    _directionImageView = [SJUIImageViewFactory imageViewWithViewMode:UIViewContentModeScaleAspectFit];
    return _directionImageView;
}

- (UIImageView *)previewImageView {
    if ( _previewImageView ) return _previewImageView;
    _previewImageView = [SJUIImageViewFactory imageViewWithViewMode:UIViewContentModeScaleAspectFit];
    [SJUIFactory regulate:_previewImageView cornerRadius:8];
    return _previewImageView;
}

- (UILabel *)shiftTimeLabel {
    if ( _shiftTimeLabel ) return _shiftTimeLabel;
    _shiftTimeLabel = [SJUILabelFactory labelWithFont:[UIFont systemFontOfSize:13]];
    return _shiftTimeLabel;
}

- (UILabel *)spritTimeLabel {
    if ( _spritTimeLabel ) return _spritTimeLabel;
    _spritTimeLabel = [SJUILabelFactory labelWithText:@"/" textColor:[UIColor whiteColor] font:self.shiftTimeLabel.font];
    return _spritTimeLabel;
}

- (UILabel *)durationTimeLabel {
    if ( _durationTimeLabel ) return _durationTimeLabel;
    _durationTimeLabel = [SJUILabelFactory labelWithFont:self.shiftTimeLabel.font textColor:[UIColor whiteColor]];
    return _durationTimeLabel;
}

#pragma mark -
- (void)_draggingViewSetting {
    __weak typeof(self) _self = self;
    self.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.fastImage = setting.fastImage;
        self.forwardImage = setting.forwardImage;
        self.shiftTimeLabel.textColor = self.progressSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.progressSlider.trackImageView.backgroundColor = setting.progress_trackColor;
        self.progressSlider.bufferProgressColor = setting.progress_bufferColor;
    }];
}
@end
