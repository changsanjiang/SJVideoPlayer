//
//  SJVideoPlayerMoreSettingsFooterSlidersView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSettingsFooterSlidersView.h"
#import <SJSlider/SJSlider.h>
#import <Masonry/Masonry.h>
#import "UIView+SJExtension.h"
#import "SJVideoPlayerControlViewEnumHeader.h"





@interface SJVideoPlayerMoreSettingsFooterSlidersView ()
@property (nonatomic, strong, readonly) UILabel *volumeLabel;
@property (nonatomic, strong, readonly) UILabel *brightnessLabel;
@property (nonatomic, strong, readonly) UILabel *rateLabel;
@end

@interface SJVideoPlayerMoreSettingsFooterSlidersView (DBObservers)
- (void)_SJVideoPlayerMoreSettingsFooterSlidersViewObservers;
- (void)_SJVideoPlayerMoreSettingsFooterSlidersViewRemoveObservers;
@end

@implementation SJVideoPlayerMoreSettingsFooterSlidersView

@synthesize volumeSlider = _volumeSlider;
@synthesize brightnessSlider = _brightnessSlider;
@synthesize rateSlider = _rateSlider;

@synthesize volumeLabel = _volumeLabel;
@synthesize brightnessLabel = _brightnessLabel;
@synthesize rateLabel = _rateLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerMoreSettingsFooterSlidersViewSetupUI];
    [self _SJVideoPlayerMoreSettingsFooterSlidersViewObservers];
    return self;
}

- (void)dealloc {
    [self _SJVideoPlayerMoreSettingsFooterSlidersViewRemoveObservers];
}

- (void)_SJVideoPlayerMoreSettingsFooterSlidersViewSetupUI {
    
    UIView *volumeBackgroundView = [UIView new];
    UIView *brightnessBackgroundView = [UIView new];
    UIView *rateBackgroundView = [UIView new];
    
    [self addSubview:volumeBackgroundView];
    [self addSubview:brightnessBackgroundView];
    [self addSubview:rateBackgroundView];
    
    [rateBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(25);
        make.leading.trailing.offset(0);
        make.height.offset((self.csj_h - 25 * 2) / 3);
        
    }];
    
    [volumeBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rateBackgroundView.mas_bottom);
        make.leading.trailing.offset(0);
        make.height.equalTo(rateBackgroundView);
    }];
    
    [brightnessBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(volumeBackgroundView.mas_bottom);
        make.leading.trailing.offset(0);
        make.height.equalTo(volumeBackgroundView);
    }];
    
    
    [volumeBackgroundView addSubview:self.volumeLabel];
    [volumeBackgroundView addSubview:self.volumeSlider];
    
    [brightnessBackgroundView addSubview:self.brightnessLabel];
    [brightnessBackgroundView addSubview:self.brightnessSlider];
    
    [rateBackgroundView addSubview:self.rateLabel];
    [rateBackgroundView addSubview:self.rateSlider];
    
    [self _constraintsLabel:_volumeLabel slider:_volumeSlider];
    
    [self _constraintsLabel:_brightnessLabel slider:_brightnessSlider];
    
    [self _constraintsLabel:_rateLabel slider:_rateSlider];
    
}

- (void)_constraintsLabel:(UILabel *)label slider:(SJSlider *)slider {
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.leading.offset(25);
    }];
    
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.trailing.offset(-25);
        make.leading.offset(99);
    }];
}


- (SJSlider *)volumeSlider {
    if ( _volumeSlider ) return _volumeSlider;
    _volumeSlider = [self slider];
    _volumeSlider.tag = SJVideoPlaySliderTag_Volume;
    return _volumeSlider;
}

- (UILabel *)volumeLabel {
    if ( _volumeLabel ) return _volumeLabel;
    _volumeLabel = [self label];
    _volumeLabel.text = @"音量";
    return _volumeLabel;
}

- (SJSlider *)brightnessSlider {
    if ( _brightnessSlider ) return _brightnessSlider;
    _brightnessSlider = [self slider];
    _brightnessSlider.tag = SJVideoPlaySliderTag_Brightness;
    return _brightnessSlider;
}

- (UILabel *)brightnessLabel {
    if ( _brightnessLabel ) return _brightnessLabel;
    _brightnessLabel = [self label];
    _brightnessLabel.text = @"亮度";
    return _brightnessLabel;
}

- (SJSlider *)rateSlider {
    if ( _rateSlider ) return _rateSlider;
    _rateSlider = [self slider];
    _rateSlider.tag = SJVideoPlaySliderTag_Rate;
    _rateSlider.minValue = 0.5;
    _rateSlider.maxValue = 2;
    _rateSlider.value = 1.0;
    return _rateSlider;
}

- (UILabel *)rateLabel {
    if ( _rateLabel ) return _rateLabel;
    _rateLabel = [self label];
    _rateLabel.text = @"调速";
    return _rateLabel;
}

- (UILabel *)label {
    return [UILabel labelWithFontSize:12 textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
}

- (SJSlider *)slider {
    SJSlider *slider = [SJSlider new];
    return slider;
}

@end




@implementation SJVideoPlayerMoreSettingsFooterSlidersView (DBObservers)


- (void)_SJVideoPlayerMoreSettingsFooterSlidersViewObservers {
    [self.volumeSlider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    [self.rateSlider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    [self.brightnessSlider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)_SJVideoPlayerMoreSettingsFooterSlidersViewRemoveObservers {
    [self.volumeSlider removeObserver:self forKeyPath:@"value"];
    [self.rateSlider removeObserver:self forKeyPath:@"value"];
    [self.brightnessSlider removeObserver:self forKeyPath:@"value"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( object == _volumeSlider ) _volumeLabel.text = [NSString stringWithFormat:@"音量  %.01f", _volumeSlider.value];
    if ( object == _rateSlider ) _rateLabel.text = [NSString stringWithFormat:@"调速  %.01f", _rateSlider.value];
    if ( object == _brightnessSlider ) _brightnessLabel.text = [NSString stringWithFormat:@"亮度  %.01f", _brightnessSlider.value];
}

@end


