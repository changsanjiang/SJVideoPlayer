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
#import "SJVideoPlayerAssetCarrier.h"
#import <SJSlider/SJSlider.h>

inline static NSString *_formatWithSec(NSInteger sec) {
    NSInteger seconds = sec % 60;
    NSInteger minutes = sec / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

@interface SJVideoPlayerDraggingProgressView ()

@property (nonatomic, strong, readonly) UILabel *progressLabel;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) SJSlider *progressSlider;

@end

@implementation SJVideoPlayerDraggingProgressView

@synthesize progressLabel = _progressLabel;
@synthesize imageView = _imageView;
@synthesize progressSlider = _progressSlider;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _draggingProgressSetupView];
    __weak typeof(self) _self = self;
    self.setting = ^(SJVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.progressSlider.trackImageView.backgroundColor = setting.progress_trackColor;
        self.progressSlider.traceImageView.backgroundColor = setting.progress_traceColor;
    };
    
    _imageView.alpha = 0.001;
    return self;
}

- (void)_draggingProgressSetupView {
    [self addSubview:self.imageView];
    [self addSubview:self.progressLabel];
    [self addSubview:self.progressSlider];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_progressLabel.mas_top).offset(-12);
        make.centerX.offset(0);
        make.width.offset(120);
        make.height.equalTo(_imageView.mas_width).multipliedBy(9.f / 16);
    }];
    
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_progressLabel.superview.mas_centerY);
        make.centerX.offset(0);
    }];
    
    [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_progressLabel.mas_bottom).offset(8);
        make.centerX.offset(0);
        make.width.offset(54);
        make.height.offset(3);
    }];
}

- (void)setProgress:(float)progress {
    if ( isnan(progress) || progress < 0 ) progress = 0;
    else if ( progress > 1 ) progress = 1;
    _progress = progress;
    _progressSlider.value = progress;
    _progressLabel.text = _formatWithSec(_asset.duration * progress);
    [self changeDragging];
}

- (void)setHiddenProgressSlider:(BOOL)hiddenProgressSlider {
    _hiddenProgressSlider = hiddenProgressSlider;
    _progressSlider.hidden = hiddenProgressSlider;
}

- (void)changeDragging {
    NSTimeInterval time = _asset.duration * _progress;
    __weak typeof(self) _self = self;
    [_asset screenshotWithTime:time size:_size completion:^(SJVideoPlayerAssetCarrier * _Nonnull asset, SJVideoPreviewModel * _Nonnull images, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.alpha = 1;
            self.imageView.image = images.image;
        });
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

- (UILabel *)progressLabel {
    if ( _progressLabel ) return _progressLabel;
    _progressLabel = [SJUILabelFactory labelWithText:@"00:00" textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter font:[UIFont boldSystemFontOfSize:30]];
    return _progressLabel;
}

- (UIImageView *)imageView {
    if ( _imageView ) return _imageView;
    _imageView = [SJShapeImageViewFactory imageViewWithCornerRadius:4];
    _imageView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];
    _imageView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.4].CGColor;
    _imageView.layer.borderWidth = 0.6;
    return _imageView;
}
@end
