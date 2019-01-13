//
//  SJVideoPlayerDraggingProgressView.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerDraggingProgressView.h"
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


@interface SJVideoPlayerDraggingProgressView ()

@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, strong, readonly) SJProgressSlider *progressSlider;
@property (nonatomic, strong, readonly) UIImageView *directionImageView;
@property (nonatomic, strong, readonly) UIImageView *previewImageView;

@property (nonatomic, strong, readonly) UILabel *shiftTimeLabel;
@property (nonatomic, strong, readonly) UILabel *separatorLabel;    // `/`
@property (nonatomic, strong, readonly) UILabel *durationTimeLabel;

@property (nonatomic, strong) UIImage *fastImage;
@property (nonatomic, strong) UIImage *forwardImage;

@end

@implementation SJVideoPlayerDraggingProgressView

@synthesize contentView = _contentView;
@synthesize directionImageView = _directionImageView;
@synthesize previewImageView = _previewImageView;
@synthesize progressSlider = _progressSlider;

@synthesize shiftTimeLabel = _shiftTimeLabel;
@synthesize separatorLabel = _separatorLabel;
@synthesize durationTimeLabel = _durationTimeLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupViews];
    [self _loadSettings];
    return self;
}

- (void)setStyle:(SJVideoPlayerDraggingProgressViewStyle)style {
    if ( style == _style ) return;
    _style = style;
    [self _needUpdateToStyle:style];
}

- (void)_needUpdateToStyle:(SJVideoPlayerDraggingProgressViewStyle)style {
    switch (  style ) {
        case SJVideoPlayerDraggingProgressViewStyleArrowProgress: {
            [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.offset(0);
                CGFloat width = 150;
                CGFloat height = width * 8 / 15;
                make.size.mas_offset(CGSizeMake(ceil(width), ceil(height)));
            }];
            
            _previewImageView.hidden = YES;
            _progressSlider.trackHeight = 3;
            
            [_previewImageView mas_remakeConstraints:^(MASConstraintMaker *make) {}];
            
            [_directionImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.offset(0);
                make.bottom.equalTo(self.mas_centerY);
                make.centerX.offset(0);
            }];
            
            [_progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.offset(8);
                make.right.offset(-8);
                make.top.equalTo(self.mas_centerY).offset(8);
                make.height.offset(3);
            }];
            
            [_separatorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.offset(0);
                make.top.equalTo(self->_progressSlider.mas_bottom);
                make.bottom.offset(0);
                make.width.offset(5);
            }];
            
        }
            break;
        case SJVideoPlayerDraggingProgressViewStylePreviewProgress: {
            [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.offset(0);
            }];
            
            _previewImageView.hidden = NO;
            _progressSlider.trackHeight = 2;
            [_directionImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.offset(8);
                make.bottom.equalTo(self.previewImageView.mas_top).offset(-8);
                make.height.offset(20);
                make.centerX.equalTo(self).multipliedBy(0.25);
            }];
            
            [_separatorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.offset(0);
                make.centerY.equalTo(self.directionImageView);
                make.width.offset(4);
            }];
            
            [_previewImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.offset(8);
                make.bottom.right.offset(-8);
                make.width.offset(180);
                make.height.equalTo(self->_previewImageView.mas_width).multipliedBy(9.0 / 16);
            }];
            
            [_progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.offset(0);
                make.top.equalTo(self.separatorLabel.mas_bottom);
                make.bottom.equalTo(self.previewImageView.mas_top);
                make.width.offset(68);
            }];
        }
            break;
    }
}

- (void)setMaxValue:(NSTimeInterval)maxValue {
    _progressSlider.maxValue = maxValue;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    _progressSlider.bufferProgress = currentTime / _progressSlider.maxValue;
}

- (void)setProgressTimeStr:(NSString *)shiftTimeStr {
    _shiftTimeLabel.text = shiftTimeStr;
}

- (void)setProgressTime:(NSTimeInterval)progressTime {
    float beforeProgressTime = _progressTime;
    
    _progressTime = progressTime;

    if ( beforeProgressTime > _progressTime ) {
        _directionImageView.image = _forwardImage;
    }
    else if ( beforeProgressTime < _progressTime ) {
        _directionImageView.image = _fastImage;
    }
    
    _progressSlider.value = progressTime;
}

- (void)setProgressTimeStr:(NSString *)shiftTimeStr totalTimeStr:(NSString *)totalTimeStr {
    _shiftTimeLabel.text = shiftTimeStr;
    _durationTimeLabel.text = totalTimeStr;
}

- (void)setPreviewImage:(UIImage *)image {
    _previewImageView.image = image;
}

#pragma mark -

- (void)_setupViews {
    [self addSubview:self.contentView];
    [_contentView addSubview:self.progressSlider];
    [_contentView addSubview:self.directionImageView];
    [_contentView addSubview:self.shiftTimeLabel];
    [_contentView addSubview:self.separatorLabel];
    [_contentView addSubview:self.durationTimeLabel];
    [_contentView addSubview:self.previewImageView];
    
    [SJUIFactory regulate:_contentView cornerRadius:8];
    _contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [self _needUpdateToStyle:SJVideoPlayerDraggingProgressViewStyleArrowProgress];
    
    [_shiftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self->_separatorLabel.mas_left);
        make.centerY.equalTo(self->_separatorLabel);
        make.left.offset(0);
    }];
    
    [_durationTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_separatorLabel.mas_right);
        make.centerY.equalTo(self->_separatorLabel);
        make.right.offset(0);
    }];
    
    
// <SJProgressSlider: 0x15ba0ebb0; frame = (0 0; 0 0); gestureRecognizers = <NSArray: 0x2809ccff0>; layer = <CALayer: 0x2807d8ca0>>
// <UIImageView: 0x15ba0f9c0; frame = (0 0; 0 0); clipsToBounds = YES; userInteractionEnabled = NO; layer = <CALayer: 0x2807d9b00>>
// <UILabel: 0x15ba0fde0; frame = (0 0; 0 0); userInteractionEnabled = NO; layer = <_UILabelLayer: 0x28249e800>>
// <UILabel: 0x15ba100d0; frame = (0 0; 4.33333 15.6667); text = '/'; userInteractionEnabled = NO; layer = <_UILabelLayer: 0x28249e530>>
// <UILabel: 0x15ba10510; frame = (0 0; 0 0); userInteractionEnabled = NO; layer = <_UILabelLayer: 0x28249e6c0>>
// <UIImageView: 0x15ba10800; frame = (0 0; 0 0); clipsToBounds = YES; hidden = YES; userInteractionEnabled = NO; layer = <CALayer: 0x2807d9e40>>

//    "<MASLayoutConstraint:0x2823fba80 UIImageView:0x15ba10800.height == UIImageView:0x15ba10800.width * 0.5625>",
//    "<MASLayoutConstraint:0x2823a75a0 UIImageView:0x15ba0f9c0.top == UIView:0x15ba0e9d0.top + 8>",
//    "<MASLayoutConstraint:0x2823a7600 UIImageView:0x15ba0f9c0.bottom == UIImageView:0x15ba10800.top - 8>",
//    "<MASLayoutConstraint:0x282398a20 UIImageView:0x15ba10800.left == UIView:0x15ba0e9d0.left + 8>",
//    "<MASLayoutConstraint:0x28239b420 UIImageView:0x15ba10800.bottom == UIView:0x15ba0e9d0.bottom - 8>",
//    "<MASLayoutConstraint:0x2823fba20 UIImageView:0x15ba10800.right == UIView:0x15ba0e9d0.right - 8>",
//    "<MASLayoutConstraint:0x2823b68e0 UIView:0x15ba0e9d0.width == 150>",
//    "<MASLayoutConstraint:0x2823b6520 UIView:0x15ba0e9d0.height == 80>"

}

- (UIView *)contentView {
    if ( _contentView ) return _contentView;
    _contentView = [UIView new];
    return _contentView;
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
    _shiftTimeLabel.textAlignment = NSTextAlignmentRight;
    return _shiftTimeLabel;
}

- (UILabel *)separatorLabel {
    if ( _separatorLabel ) return _separatorLabel;
    _separatorLabel = [SJUILabelFactory labelWithText:@"/" textColor:[UIColor whiteColor] font:self.shiftTimeLabel.font];
    return _separatorLabel;
}

- (UILabel *)durationTimeLabel {
    if ( _durationTimeLabel ) return _durationTimeLabel;
    _durationTimeLabel = [SJUILabelFactory labelWithFont:self.shiftTimeLabel.font textColor:[UIColor whiteColor]];
    _durationTimeLabel.textAlignment = NSTextAlignmentLeft;
    return _durationTimeLabel;
}

#pragma mark -
- (void)_loadSettings {
    __weak typeof(self) _self = self;
    void(^inner_setting)(SJEdgeControlLayerSettings *setting) = ^(SJEdgeControlLayerSettings *setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.fastImage = setting.fastImage;
        self.forwardImage = setting.forwardImage;
        self.shiftTimeLabel.textColor = self.progressSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.progressSlider.trackImageView.backgroundColor = setting.progress_trackColor;
        self.progressSlider.bufferProgressColor = setting.progress_bufferColor;
    };
    
    self.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:inner_setting];
    inner_setting(SJEdgeControlLayerSettings.commonSettings);
}
@end
