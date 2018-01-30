//
//  SJVideoPlayerMoreSettingsFooterSlidersView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSettingsFooterSlidersView.h"
#import <SJSlider/SJButtonSlider.h>
#import <Masonry/Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import "SJVideoPlayerControlViewEnumHeader.h"
#import "SJVideoPlayerSettings.h"

@interface SJVideoPlayerMoreSettingsFooterSlidersView ()<SJSliderDelegate>

@property (nonatomic, strong, readonly) SJButtonSlider *rateSlider;
@property (nonatomic, strong, readonly) SJButtonSlider *volumeSlider;
@property (nonatomic, strong, readonly) SJButtonSlider *brightnessSlider;

@end

@interface SJVideoPlayerMoreSettingsFooterSlidersView (DBObservers)
- (void)_moreObservers;
- (void)_moreRemoveObservser;
@end

@implementation SJVideoPlayerMoreSettingsFooterSlidersView

@synthesize volumeSlider = _volumeSlider;
@synthesize brightnessSlider = _brightnessSlider;
@synthesize rateSlider = _rateSlider;

+ (CGFloat)height {
    return [self itemHeight] * 3;
}

+ (CGFloat)itemHeight {
    return 60;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _moreSetupViews];
    [self _moreObservers];
    [self _moreInstallNotifications];
    return self;
}

- (void)_moreInstallNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsPlayerNotification:) name:SJSettingsPlayerNotification object:nil];
}

- (void)_moreRemoveNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)settingsPlayerNotification:(NSNotification *)notif {
    SJVideoPlayerSettings *settings = notif.object;
    _volumeSlider.slider.trackHeight = _brightnessSlider.slider.trackHeight = _rateSlider.slider.trackHeight = settings.more_trackHeight;
    _volumeSlider.slider.trackImageView.backgroundColor = _brightnessSlider.slider.trackImageView.backgroundColor = _rateSlider.slider.trackImageView.backgroundColor = settings.more_trackColor;
    _volumeSlider.slider.traceImageView.backgroundColor = _brightnessSlider.slider.traceImageView.backgroundColor = _rateSlider.slider.traceImageView.backgroundColor = settings.more_traceColor;

    [_rateSlider.leftBtn setBackgroundImage:settings.more_minRateImage forState:UIControlStateNormal];
    [_rateSlider.rightBtn setBackgroundImage:settings.more_maxRateImage forState:UIControlStateNormal];
    [_volumeSlider.leftBtn setBackgroundImage:settings.more_minVolumeImage forState:UIControlStateNormal];
    [_volumeSlider.rightBtn setBackgroundImage:settings.more_maxVolumeImage forState:UIControlStateNormal];
    [_brightnessSlider.leftBtn setBackgroundImage:settings.more_minBrightnessImage forState:UIControlStateNormal];
    [_brightnessSlider.rightBtn setBackgroundImage:settings.more_maxBrightnessImage forState:UIControlStateNormal];
}

- (void)dealloc {
    [self _moreRemoveNotifications];
    [self _moreRemoveObservser];
    
}

- (void)setModel:(SJMoreSettingsFooterViewModel *)model {
    _model = model;
    __weak typeof(self) _self = self;
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
    
    if ( model.initialVolumeValue ) self.volumeSlider.slider.value = model.initialVolumeValue();
    if ( model.initialBrightnessValue ) self.brightnessSlider.slider.value = model.initialBrightnessValue();
    if ( model.initialPlayerRateValue )self.rateSlider.slider.value = model.initialPlayerRateValue();
}

- (void)_moreSetupViews {

    [self addSubview:self.volumeSlider];
    [self addSubview:self.brightnessSlider];
    [self addSubview:self.rateSlider];
    
    
    [_volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_brightnessSlider.mas_top);
        make.size.equalTo(_brightnessSlider);
        make.centerX.equalTo(_brightnessSlider);
    }];
    
    [_brightnessSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.width.equalTo(self);
        make.height.offset([[self class] itemHeight]);
    }];
    
    [_rateSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_brightnessSlider);
        make.top.equalTo(_brightnessSlider.mas_bottom);
        make.centerX.equalTo(_brightnessSlider);
    }];
    
    _volumeSlider.slider.delegate = self;
    _brightnessSlider.slider.delegate = self;
    _rateSlider.slider.delegate = self;
}

- (SJButtonSlider *)volumeSlider {
    if ( _volumeSlider ) return _volumeSlider;
    _volumeSlider = [self slider];
    _volumeSlider.tag = SJVideoPlaySliderTag_Volume;
    return _volumeSlider;
}

- (SJButtonSlider *)brightnessSlider {
    if ( _brightnessSlider ) return _brightnessSlider;
    _brightnessSlider = [self slider];
    _brightnessSlider.tag = SJVideoPlaySliderTag_Brightness;
    _brightnessSlider.slider.minValue = 0.1;
    return _brightnessSlider;
}

- (SJButtonSlider *)rateSlider {
    if ( _rateSlider ) return _rateSlider;
    _rateSlider = [self slider];
    _rateSlider.tag = SJVideoPlaySliderTag_Rate;
    _rateSlider.slider.minValue = 0.5;
    _rateSlider.slider.maxValue = 1.5;
    _rateSlider.slider.value = 1.0;
    return _rateSlider;
}

- (SJButtonSlider *)slider {
    SJButtonSlider *slider = [SJButtonSlider new];
    slider.spacing = 4;
    return slider;
}

#pragma mark

- (void)sliderWillBeginDragging:(SJSlider *)slider {
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

- (void)sliderDidDrag:(SJSlider *)slider {
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

- (void)sliderDidEndDragging:(SJSlider *)slider {
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

@end




@implementation SJVideoPlayerMoreSettingsFooterSlidersView (DBObservers)


- (void)_moreObservers {
    [self.volumeSlider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    [self.rateSlider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    [self.brightnessSlider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)_moreRemoveObservser {
    [self.volumeSlider removeObserver:self forKeyPath:@"value"];
    [self.rateSlider removeObserver:self forKeyPath:@"value"];
    [self.brightnessSlider removeObserver:self forKeyPath:@"value"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    if ( object == _volumeSlider ) _volumeLabel.text = [NSString stringWithFormat:@"音量  %.01f", _volumeSlider.slider.value];
//    if ( object == _rateSlider ) _rateLabel.text = [NSString stringWithFormat:@"调速  %.01f", _rateSlider.slider.value];
//    if ( object == _brightnessSlider ) _brightnessLabel.text = [NSString stringWithFormat:@"亮度  %.01f", _brightnessSlider.slider.value];
}

@end
