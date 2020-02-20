//
//  SJDraggingProgressPopView.m
//  Pods
//
//  Created by 畅三江 on 2019/11/27.
//

#import "SJDraggingProgressPopView.h"
#import "SJVideoPlayerSettings.h"
#import "SJProgressSlider.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#if __has_include(<SJBaseVideoPlayer/NSString+SJBaseVideoPlayerExtended.h>)
#import <SJBaseVideoPlayer/NSString+SJBaseVideoPlayerExtended.h>
#else
#import "NSString+SJBaseVideoPlayerExtended.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJDraggingProgressPopView ()
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) SJProgressSlider *progressSlider;
@property (nonatomic, strong, readonly) UIImageView *directionImageView;
@property (nonatomic, strong, readonly) UIImageView *previewImageView;

@property (nonatomic, strong, readonly) UILabel *dragProgressTimeLabel;
@property (nonatomic, strong, readonly) UILabel *separatorLabel;    // `/`
@property (nonatomic, strong, readonly) UILabel *durationLabel;
@end

@implementation SJDraggingProgressPopView
@synthesize contentView = _contentView;
@synthesize directionImageView = _directionImageView;
@synthesize previewImageView = _previewImageView;
@synthesize progressSlider = _progressSlider;
@synthesize dragProgressTimeLabel = _dragProgressTimeLabel;
@synthesize separatorLabel = _separatorLabel;
@synthesize durationLabel = _durationLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        [self _setupViews];
        [self _updateSettings];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_updateSettings) name:SJVideoPlayerSettingsUpdatedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setStyle:(SJDraggingProgressPopViewStyle)style {
    if ( style != _style ) {
        _style = style;
        [self _resetLayout];
    }
}

- (void)setDragProgressTime:(NSTimeInterval)dragProgressTime {
    SJVideoPlayerSettings *sources = SJVideoPlayerSettings.commonSettings;
    if ( dragProgressTime > _dragProgressTime ) {
        _directionImageView.image = sources.fastImage;
    }
    else if ( dragProgressTime < _dragProgressTime ) {
        _directionImageView.image = sources.forwardImage;
    }
    _progressSlider.value = dragProgressTime;
    _dragProgressTimeLabel.text = [NSString stringWithCurrentTime:dragProgressTime duration:_duration];
    _dragProgressTime = dragProgressTime;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    if ( _currentTime != currentTime ) {
        _currentTime = currentTime;
        _progressSlider.bufferProgress = currentTime / _progressSlider.maxValue;
    }
}

- (void)setDuration:(NSTimeInterval)duration {
    if ( _duration != duration ) {
        _duration = duration;
        _progressSlider.maxValue = duration ?: 1;
        _durationLabel.text = [NSString stringWithCurrentTime:duration duration:duration];
    }
}

- (void)setPreviewImage:(nullable UIImage *)previewImage {
    _previewImageView.image = previewImage;
}
- (nullable UIImage *)previewImage {
    return _previewImageView.image;
}

- (BOOL)isPreviewImageHidden {
    return _style != SJDraggingProgressPopViewStyleFullscreen;
}
#pragma mark -

- (void)_setupViews {
    [self addSubview:self.contentView];
    [_contentView addSubview:self.progressSlider];
    [_contentView addSubview:self.directionImageView];
    [_contentView addSubview:self.dragProgressTimeLabel];
    [_contentView addSubview:self.separatorLabel];
    [_contentView addSubview:self.durationLabel];
    [_contentView addSubview:self.previewImageView];
    
    [self _resetLayout];

    [_dragProgressTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self->_separatorLabel.mas_left);
        make.centerY.equalTo(self->_separatorLabel);
        make.left.offset(0);
    }];

    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_separatorLabel.mas_right);
        make.centerY.equalTo(self->_separatorLabel);
        make.right.offset(0);
    }];
}

- (UIView *)contentView {
    if ( _contentView == nil ) {
        _contentView = [UIView new];
        _contentView.layer.cornerRadius = 8;
        _contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    }
    return _contentView;
}

- (SJProgressSlider *)progressSlider {
    if ( _progressSlider == nil ) {
        _progressSlider = [SJProgressSlider new];
        _progressSlider.trackHeight = 3;
        _progressSlider.enableBufferProgress = YES;
        _progressSlider.pan.enabled = NO;
    }
    return _progressSlider;
}

- (UIImageView *)directionImageView {
    if ( _directionImageView == nil ) {
        _directionImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _directionImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _directionImageView;
}

- (UIImageView *)previewImageView {
    if ( _previewImageView == nil ) {
        _previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFit;
        _previewImageView.layer.cornerRadius = 8;
        _previewImageView.layer.masksToBounds = YES;
    }
    return _previewImageView;
}

- (UILabel *)dragProgressTimeLabel {
    if ( _dragProgressTimeLabel == nil ) {
        _dragProgressTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dragProgressTimeLabel.font = [UIFont systemFontOfSize:13];
        _dragProgressTimeLabel.textColor = [UIColor whiteColor];
        _dragProgressTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _dragProgressTimeLabel;
}

- (UILabel *)separatorLabel {
    if ( _separatorLabel == nil ) {
        _separatorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _separatorLabel.font = [UIFont systemFontOfSize:13];
        _separatorLabel.textColor = [UIColor whiteColor];
        _separatorLabel.text = @"/";
    }
    return _separatorLabel;
}

- (UILabel *)durationLabel {
    if ( _durationLabel == nil ) {
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _durationLabel.font = [UIFont systemFontOfSize:13];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _durationLabel;
}

#pragma mark -

- (void)_resetLayout {
    switch ( _style ) {
        case SJDraggingProgressPopViewStyleNormal:
        case SJDraggingProgressPopViewStyleFitOnScreen:
            [self _resetLayout_normalStyle];
            break;
        case SJDraggingProgressPopViewStyleFullscreen:
            [self _resetLayout_fullscreenStyle];
            break;
    }
}

- (void)_resetLayout_normalStyle {
    _previewImageView.hidden = YES;
    _progressSlider.trackHeight = 3;

    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
        CGFloat width = 150;
        CGFloat height = width * 8 / 15;
        make.size.mas_offset(CGSizeMake(width, ceil(height)));
    }];
    
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

- (void)_resetLayout_fullscreenStyle {
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

- (void)_updateSettings {
    SJVideoPlayerSettings *settings = SJVideoPlayerSettings.commonSettings;
    _dragProgressTimeLabel.textColor = settings.progress_traceColor;
    _progressSlider.traceImageView.backgroundColor = settings.progress_traceColor;
    _progressSlider.trackImageView.backgroundColor = settings.progress_trackColor;
    _progressSlider.bufferProgressColor = settings.progress_bufferColor;
    _previewImageView.image = settings.placeholder;
}
@end
NS_ASSUME_NONNULL_END
