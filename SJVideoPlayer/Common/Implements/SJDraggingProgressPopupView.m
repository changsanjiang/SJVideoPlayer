//
//  SJDraggingProgressPopupView.m
//  Pods
//
//  Created by 畅三江 on 2019/11/27.
//

#import "SJDraggingProgressPopupView.h"
#import "SJVideoPlayerConfigurations.h"
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
@interface SJDraggingProgressPopupView ()
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) SJProgressSlider *progressSlider;
@property (nonatomic, strong, readonly) UIImageView *directionImageView;
@property (nonatomic, strong, readonly) UIImageView *previewImageView;

@property (nonatomic, strong, readonly) UILabel *dragTimeLabel;
@property (nonatomic, strong, readonly) UILabel *separatorLabel;    // `/`
@property (nonatomic, strong, readonly) UILabel *durationLabel;
@end

@implementation SJDraggingProgressPopupView
@synthesize contentView = _contentView;
@synthesize directionImageView = _directionImageView;
@synthesize previewImageView = _previewImageView;
@synthesize progressSlider = _progressSlider;
@synthesize dragTimeLabel = _dragTimeLabel;
@synthesize separatorLabel = _separatorLabel;
@synthesize durationLabel = _durationLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        [self _setupViews];
        [self _updateSettings];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_updateSettings) name:SJVideoPlayerConfigurationsDidUpdateNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setStyle:(SJDraggingProgressPopupViewStyle)style {
    if ( style != _style ) {
        _style = style;
        [self _resetLayout];
    }
}

- (void)setDragTime:(NSTimeInterval)dragTime {
    id<SJVideoPlayerControlLayerResources> sources = SJVideoPlayerConfigurations.shared.resources;
    if ( dragTime > _dragTime ) {
        _directionImageView.image = sources.fastImage;
    }
    else if ( dragTime < _dragTime ) {
        _directionImageView.image = sources.forwardImage;
    }
    _progressSlider.value = dragTime;
    _dragTimeLabel.text = [NSString stringWithCurrentTime:dragTime duration:_duration];
    _dragTime = dragTime;
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
    return _style != SJDraggingProgressPopupViewStyleFullscreen;
}
#pragma mark -

- (void)_setupViews {
    [self addSubview:self.contentView];
    [_contentView addSubview:self.progressSlider];
    [_contentView addSubview:self.directionImageView];
    [_contentView addSubview:self.dragTimeLabel];
    [_contentView addSubview:self.separatorLabel];
    [_contentView addSubview:self.durationLabel];
    [_contentView addSubview:self.previewImageView];
    
    [self _resetLayout];

    [_dragTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
        _progressSlider.showsBufferProgress = YES;
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

- (UILabel *)dragTimeLabel {
    if ( _dragTimeLabel == nil ) {
        _dragTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dragTimeLabel.font = [UIFont systemFontOfSize:13];
        _dragTimeLabel.textColor = [UIColor whiteColor];
        _dragTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _dragTimeLabel;
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
        case SJDraggingProgressPopupViewStyleNormal:
        case SJDraggingProgressPopupViewStyleFitOnScreen:
            [self _resetLayout_normalStyle];
            break;
        case SJDraggingProgressPopupViewStyleFullscreen:
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
    id<SJVideoPlayerControlLayerResources> resources = SJVideoPlayerConfigurations.shared.resources;
    _dragTimeLabel.textColor = resources.progressTraceColor;
    _progressSlider.traceImageView.backgroundColor = resources.progressTraceColor;
    _progressSlider.trackImageView.backgroundColor = resources.progressTrackColor;
    _progressSlider.bufferProgressColor = resources.progressBufferColor;
    _previewImageView.image = resources.placeholder;
}
@end
NS_ASSUME_NONNULL_END
