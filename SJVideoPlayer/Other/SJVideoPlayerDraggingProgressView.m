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

@interface SJVideoPlayerDraggingProgressView ()

@end

@implementation SJVideoPlayerDraggingProgressView

@synthesize progressLabel = _progressLabel;
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
    return self;
}

- (void)_draggingProgressSetupView {
    [self addSubview:self.progressLabel];
    [self addSubview:self.progressSlider];
    
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_progressLabel.superview);
        make.bottom.equalTo(_progressLabel.superview.mas_centerY).offset(-8);
    }];
    
    [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(130);
        make.height.offset(3);
        make.center.offset(0);
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
    _progressLabel = [SJUILabelFactory labelWithText:@"00:00" textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter font:[UIFont boldSystemFontOfSize:42]];
    return _progressLabel;
}

@end
