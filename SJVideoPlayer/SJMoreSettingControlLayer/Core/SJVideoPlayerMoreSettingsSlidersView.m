//
//  SJVideoPlayerMoreSettingsSlidersView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/5.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSettingsSlidersView.h"
#import "SJButtonProgressSlider.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#import "UIView+SJVideoPlayerSetting.h"

@interface SJVideoPlayerMoreSettingsSlidersView ()<SJProgressSliderDelegate>

@property (nonatomic, strong, readonly) SJButtonProgressSlider *rateSlider;
@property (nonatomic, strong, readonly) SJButtonProgressSlider *volumeSlider;
@property (nonatomic, strong, readonly) SJButtonProgressSlider *brightnessSlider;

@end

@implementation SJVideoPlayerMoreSettingsSlidersView

@synthesize volumeSlider = _volumeSlider;
@synthesize brightnessSlider = _brightnessSlider;
@synthesize rateSlider = _rateSlider;

+ (CGFloat)itemHeight {
    return 60;
}

- (CGSize)intrinsicContentSize {
    CGFloat max = MAX(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    return CGSizeMake(ceil(max * 0.4), [[self class] itemHeight] * 3);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _footerSetupViews];
    [self _footerSettings];
    return self;
}

- (void)setModel:(SJMoreSettingsSlidersViewModel *)model {
    _model = model;
    __weak typeof(self) _self = self;
    
    if ( model.initialBrightnessValue ) self.brightnessSlider.slider.value = model.initialBrightnessValue();
    if ( model.initialVolumeValue ) self.volumeSlider.slider.value = model.initialVolumeValue();
    if ( model.initialPlayerRateValue ) self.rateSlider.slider.value = model.initialPlayerRateValue();
    
    model.volumeChanged = ^(float volume) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.volumeSlider.slider.isDragging ) return;
        self.volumeSlider.slider.value = volume;
    };
    
    model.brightnessChanged = ^(float brightness) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.brightnessSlider.slider.isDragging ) return;
        self.brightnessSlider.slider.value = brightness;
    };
    
    model.playerRateChanged = ^(float rate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.rateSlider.slider.isDragging ) return;
        self.rateSlider.slider.value = rate;
    };
}

- (void)_footerSetupViews {
    
    [self addSubview:self.volumeSlider];
    [self addSubview:self.brightnessSlider];
    [self addSubview:self.rateSlider];
    
    
    [self.volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.brightnessSlider.mas_top);
        make.size.equalTo(self.brightnessSlider);
        make.centerX.equalTo(self.brightnessSlider);
    }];
    
    [self.brightnessSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.width.equalTo(self);
        make.height.offset([[self class] itemHeight]);
    }];
    
    [self.rateSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.brightnessSlider);
        make.top.equalTo(self.brightnessSlider.mas_bottom);
        make.centerX.equalTo(self.brightnessSlider);
    }];
    
    self.volumeSlider.slider.delegate = self;
    self.brightnessSlider.slider.delegate = self;
    self.rateSlider.slider.delegate = self;
}

- (SJButtonProgressSlider *)volumeSlider {
    if ( _volumeSlider ) return _volumeSlider;
    _volumeSlider = [self slider];
    return _volumeSlider;
}

- (SJButtonProgressSlider *)brightnessSlider {
    if ( _brightnessSlider ) return _brightnessSlider;
    _brightnessSlider = [self slider];
    _brightnessSlider.slider.minValue = 0.1;
    return _brightnessSlider;
}

- (SJButtonProgressSlider *)rateSlider {
    if ( _rateSlider ) return _rateSlider;
    _rateSlider = [self slider];
    _rateSlider.slider.minValue = 0.5;
    _rateSlider.slider.maxValue = 1.5;
    _rateSlider.slider.value = 1.0;
    return _rateSlider;
}

- (SJButtonProgressSlider *)slider {
    SJButtonProgressSlider *slider = [SJButtonProgressSlider new];
    slider.spacing = -6;
    return slider;
}

#pragma mark

- (void)sliderWillBeginDragging:(SJProgressSlider *)slider {
    if ( slider == _rateSlider.slider ) {
        if ( _model.needChangePlayerRate ) _model.needChangePlayerRate(slider.value);
    }
    else if ( slider == _volumeSlider.slider ) {
        if ( _model.needChangeVolume ) _model.needChangeVolume(slider.value);
    }
    else {
        if ( _model.needChangeBrightness ) _model.needChangeBrightness(slider.value);
    }
}

- (void)sliderDidDrag:(SJProgressSlider *)slider {
    if ( slider == _rateSlider.slider ) {
        if ( _model.needChangePlayerRate ) _model.needChangePlayerRate(slider.value);
    }
    else if ( slider == _volumeSlider.slider ) {
        if ( _model.needChangeVolume ) _model.needChangeVolume(slider.value);
    }
    else {
        if ( _model.needChangeBrightness ) _model.needChangeBrightness(slider.value);
    }
}

- (void)sliderDidEndDragging:(SJProgressSlider *)slider {
    if ( slider == _rateSlider.slider ) {
        if ( _model.needChangePlayerRate ) _model.needChangePlayerRate(slider.value);
    }
    else if ( slider == _volumeSlider.slider ) {
        if ( _model.needChangeVolume ) _model.needChangeVolume(slider.value);
    }
    else {
        if ( _model.needChangeBrightness ) _model.needChangeBrightness(slider.value);
    }
}

- (void)_footerSettings {
    __weak typeof(self) _self = self;
    self.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateSliders];
    }];
    [self _updateSliders];
}

- (void)_updateSliders {
    SJEdgeControlLayerSettings * setting = SJEdgeControlLayerSettings.commonSettings;
    self.volumeSlider.slider.trackHeight = self.brightnessSlider.slider.trackHeight = self.rateSlider.slider.trackHeight = setting.more_trackHeight;
    self.volumeSlider.slider.trackImageView.backgroundColor = self.brightnessSlider.slider.trackImageView.backgroundColor = self.rateSlider.slider.trackImageView.backgroundColor = setting.more_trackColor;
    self.volumeSlider.slider.traceImageView.backgroundColor = self.brightnessSlider.slider.traceImageView.backgroundColor = self.rateSlider.slider.traceImageView.backgroundColor = setting.more_traceColor;
    if ( setting.more_thumbImage ) {
        self.brightnessSlider.slider.thumbImageView.image = self.volumeSlider.slider.thumbImageView.image = self.rateSlider.slider.thumbImageView.image = setting.more_thumbImage;
    }
    else if ( 0 != setting.more_thumbSize ) {
        CGFloat radius = setting.more_thumbSize * 0.5;
        CGSize size = CGSizeMake(setting.more_thumbSize, setting.more_thumbSize);
        [self.rateSlider.slider setThumbCornerRadius:radius size:size thumbBackgroundColor:setting.progress_thumbColor];
        [self.volumeSlider.slider setThumbCornerRadius:radius size:size thumbBackgroundColor:setting.progress_thumbColor];
        [self.brightnessSlider.slider setThumbCornerRadius:radius size:size thumbBackgroundColor:setting.progress_thumbColor];
    }
    [self.rateSlider.leftBtn setBackgroundImage:setting.more_minRateImage forState:UIControlStateNormal];
    [self.rateSlider.rightBtn setBackgroundImage:setting.more_maxRateImage forState:UIControlStateNormal];
    [self.volumeSlider.leftBtn setBackgroundImage:setting.more_minVolumeImage forState:UIControlStateNormal];
    [self.volumeSlider.rightBtn setBackgroundImage:setting.more_maxVolumeImage forState:UIControlStateNormal];
    [self.brightnessSlider.leftBtn setBackgroundImage:setting.more_minBrightnessImage forState:UIControlStateNormal];
    [self.brightnessSlider.rightBtn setBackgroundImage:setting.more_maxBrightnessImage forState:UIControlStateNormal];

}
@end
