//
//  SJVideoPlayerDraggingProgressView.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/12/4.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "SJVideoPlayerDraggingProgressView.h"
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
}

- (UIView *)contentView {
    if ( _contentView ) return _contentView;
    _contentView = [UIView new];
    _contentView.layer.cornerRadius = 8;
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
    _directionImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _directionImageView.contentMode = UIViewContentModeScaleAspectFit;
    return _directionImageView;
}

- (UIImageView *)previewImageView {
    if ( _previewImageView ) return _previewImageView;
    _previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    _previewImageView.layer.cornerRadius = 8;
    _previewImageView.layer.masksToBounds = YES;
    return _previewImageView;
}

- (UILabel *)shiftTimeLabel {
    if ( _shiftTimeLabel ) return _shiftTimeLabel;
    _shiftTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _shiftTimeLabel.font = [UIFont systemFontOfSize:13];
    _shiftTimeLabel.textColor = [UIColor whiteColor];
    _shiftTimeLabel.textAlignment = NSTextAlignmentRight;
    return _shiftTimeLabel;
}

- (UILabel *)separatorLabel {
    if ( _separatorLabel ) return _separatorLabel;
    _separatorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _separatorLabel.font = [UIFont systemFontOfSize:13];
    _separatorLabel.textColor = [UIColor whiteColor];
    _separatorLabel.text = @"/";
    return _separatorLabel;
}

- (UILabel *)durationTimeLabel {
    if ( _durationTimeLabel ) return _durationTimeLabel;
    _durationTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _durationTimeLabel.font = [UIFont systemFontOfSize:13];
    _durationTimeLabel.textColor = [UIColor whiteColor];
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
