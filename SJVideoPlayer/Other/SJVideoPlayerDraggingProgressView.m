//
//  SJVideoPlayerDraggingProgressView.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerDraggingProgressView.h"
#import <SJUIFactory/SJUIFactory.h>
#import "SJVideoPlayerResources.h"
#import <Masonry/Masonry.h>
#import <SJSlider/SJSlider.h>
#import <SJOrentationObserver/SJOrentationObserver.h>
#import <SJVideoPlayerAssetCarrier/SJVideoPlayerAssetCarrier.h>

typedef NS_ENUM(NSUInteger, SJVideoPlayerDraggingProgressViewStyle) {
    SJVideoPlayerDraggingProgressViewStyleArrowProgress,
    SJVideoPlayerDraggingProgressViewStylePreviewProgress,
};

@interface SJVideoPlayerDraggingProgressView ()

@property (nonatomic) SJVideoPlayerDraggingProgressViewStyle style;

@property (nonatomic, weak, readonly) SJOrentationObserver *orentationObserver;

@property (nonatomic, strong, readonly) SJSlider *progressSlider;
@property (nonatomic, strong, readonly) UIImageView *directionImageView;
@property (nonatomic, strong, readonly) UIImageView *previewImageView;

@property (nonatomic, strong, readonly) UILabel *currentTimeLabel;
@property (nonatomic, strong, readonly) UILabel *spritTimeLabel;
@property (nonatomic, strong, readonly) UILabel *durationTimeLabel;

@property (nonatomic, strong) UIImage *fastImage;
@property (nonatomic, strong) UIImage *forwardImage;
@property (nonatomic, strong) UIImage *placeholder;

@end

@implementation SJVideoPlayerDraggingProgressView

@synthesize orentationObserver = _orentationObserver;
@synthesize directionImageView = _directionImageView;
@synthesize previewImageView = _previewImageView;
@synthesize progressSlider = _progressSlider;

@synthesize currentTimeLabel = _currentTimeLabel;
@synthesize spritTimeLabel = _spritTimeLabel;
@synthesize durationTimeLabel = _durationTimeLabel;

- (instancetype)initWithOrentationObserver:(SJOrentationObserver * _Nonnull __weak)orentationObserver {
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    _orentationObserver = orentationObserver;
    [self _draggingProgressSetupView];
    [self _draggingAddObserve];

    __weak typeof(self) _self = self;
    self.setting = ^(SJVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.fastImage = setting.fastImage;
        self.forwardImage = setting.forwardImage;
        self.placeholder = setting.placeholder;
        self.progressSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.progressSlider.trackImageView.backgroundColor = setting.progress_trackColor;
    };
    
    [SJUIFactory boundaryProtectedWithView:self];
    return self;
}

- (void)dealloc {
    [self _dragginRemoveObserve];
}

- (CGSize)intrinsicContentSize {
    switch ( _style ) {
        case SJVideoPlayerDraggingProgressViewStyleArrowProgress: {
            CGFloat width = SJScreen_W() * (150.0 / 375);
            CGFloat height = width * 8 / 15;
            return CGSizeMake(width, height);
        }
            break;
        case SJVideoPlayerDraggingProgressViewStylePreviewProgress: {
            CGFloat width = SJScreen_W() * ( 100.0 / 375);
            CGFloat height = width * 3 / 4;
            return CGSizeMake(width, height);
        }
            break;
    }
    return CGSizeZero;
}

- (void)setStyle:(SJVideoPlayerDraggingProgressViewStyle)style {
    
    switch ( _style = style ) {
        case SJVideoPlayerDraggingProgressViewStyleArrowProgress: {
            _previewImageView.hidden = YES;
            _progressSlider.hidden = NO;
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
                make.top.equalTo(_progressSlider.mas_bottom);
                make.bottom.offset(0);
            }];
        }
            break;
        case SJVideoPlayerDraggingProgressViewStylePreviewProgress: {
            _previewImageView.image = self.placeholder;
            _previewImageView.hidden = NO;
            _progressSlider.hidden = YES;
            [_directionImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.offset(20);
                make.centerY.equalTo(_spritTimeLabel);
                make.centerX.equalTo(self).multipliedBy(0.25);
            }];
            
            [_spritTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.offset(0);
                make.top.offset(0);
                make.bottom.equalTo(_previewImageView.mas_top);
            }];
            
            [_previewImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.offset(8);
                make.bottom.trailing.offset(-8);
                make.height.equalTo(_previewImageView.mas_width).multipliedBy(9.0 / 16);
            }];
        }
            break;
    }
    
    [self invalidateIntrinsicContentSize];
}

- (void)setProgress:(float)progress {
    if ( progress > 1 ) progress = 1;
    else if ( progress < 0 ) progress = 0;
    else if ( isnan(progress) ) return;
    
    float beforeProgress = _progress;
    
    _progress = progress;
    NSInteger secs = self.asset.duration * progress;
    _currentTimeLabel.text = [self.asset timeString:secs];
    _durationTimeLabel.text = [self.asset timeString:self.asset.duration];
    
    
    if ( beforeProgress > _progress ) {
        self.directionImageView.image = self.forwardImage;
    }
    else if ( beforeProgress < _progress ) {
        self.directionImageView.image = self.fastImage;
    }
    
    
    if ( _orentationObserver.isFullScreen ) {
        __weak typeof(self) _self = self;
        [_asset screenshotWithTime:secs size:CGSizeMake(self.previewImageView.bounds.size.width * 2, self.previewImageView.bounds.size.height * 2) completion:^(SJVideoPlayerAssetCarrier * _Nonnull asset, SJVideoPreviewModel * _Nullable images, NSError * _Nullable error) {
            if ( error ) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                self.previewImageView.image = images.image;
            });
        }];
    }
    else {
        _progressSlider.value = progress;
    }
}

- (void)_draggingAddObserve {
    [self.orentationObserver addObserver:self forKeyPath:@"fullScreen" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)_dragginRemoveObserve {
    [self.orentationObserver removeObserver:self forKeyPath:@"fullScreen"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( [keyPath isEqualToString:@"fullScreen"] ) {
        if ( self.orentationObserver.isFullScreen ) self.style = SJVideoPlayerDraggingProgressViewStylePreviewProgress;
        else self.style = SJVideoPlayerDraggingProgressViewStyleArrowProgress;
    }
}

#pragma mark -

- (void)_draggingProgressSetupView {
    
    [self addSubview:self.progressSlider];
    [self addSubview:self.directionImageView];
    [self addSubview:self.previewImageView];
    [self addSubview:self.currentTimeLabel];
    [self addSubview:self.spritTimeLabel];
    [self addSubview:self.durationTimeLabel];
    
    [SJUIFactory regulate:self cornerRadius:8];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    self.style = SJVideoPlayerDraggingProgressViewStyleArrowProgress;
    
    [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_spritTimeLabel.mas_left);
        make.centerY.equalTo(_spritTimeLabel);
    }];
    
    [_durationTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_spritTimeLabel.mas_right);
        make.centerY.equalTo(_spritTimeLabel);
    }];
    
}

- (SJSlider *)progressSlider {
    if ( _progressSlider ) return _progressSlider;
    _progressSlider = [SJSlider new];
    _progressSlider.trackHeight = 3;
    _progressSlider.pan.enabled = NO;
    _progressSlider.tag = SJVideoPlaySliderTag_Dragging;
    return _progressSlider;
}

- (UIImageView *)directionImageView {
    if ( _directionImageView ) return _directionImageView;
    _directionImageView = [SJUIImageViewFactory imageViewWithViewMode:UIViewContentModeScaleAspectFit];
    return _directionImageView;
}

- (UIImageView *)previewImageView {
    if ( _previewImageView ) return _previewImageView;
    _previewImageView = [SJShapeImageViewFactory imageViewWithCornerRadius:8];
    _previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    return _previewImageView;
}

- (UILabel *)currentTimeLabel {
    if ( _currentTimeLabel ) return _currentTimeLabel;
    _currentTimeLabel = [SJUILabelFactory labelWithFont:[UIFont systemFontOfSize:12]];
    return _currentTimeLabel;
}

- (UILabel *)spritTimeLabel {
    if ( _spritTimeLabel ) return _spritTimeLabel;
    _spritTimeLabel = [SJUILabelFactory labelWithText:@"/" textColor:[UIColor whiteColor] font:self.currentTimeLabel.font];
    return _spritTimeLabel;
}

- (UILabel *)durationTimeLabel {
    if ( _durationTimeLabel ) return _durationTimeLabel;
    _durationTimeLabel = [SJUILabelFactory labelWithFont:self.currentTimeLabel.font textColor:[UIColor whiteColor]];
    return _durationTimeLabel;
}

@end

