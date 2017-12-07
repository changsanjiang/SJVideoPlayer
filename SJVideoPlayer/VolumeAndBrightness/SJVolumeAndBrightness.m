//
//  SJVolumeAndBrightness.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/6.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVolumeAndBrightness.h"
#import <MediaPlayer/MPVolumeView.h>
#import <Masonry/Masonry.h>
#import "SJVideoPlayerResources.h"
#import "SJVideoPlayerTipsView.h"
#import <SJSlider/SJSlider.h>

@interface SJVolumeAndBrightness ()

@property (nonatomic, strong, readwrite) SJVideoPlayerTipsView *volumeView;
@property (nonatomic, strong, readwrite) SJVideoPlayerTipsView *brightnessView;
@property (nonatomic, strong, readonly) UISlider *systemVolume;

@end

@implementation SJVolumeAndBrightness
@synthesize systemVolume = _systemVolume;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self volumeView];
    [self brightnessView];
    return self;
}

- (SJVideoPlayerTipsView *)volumeView {
    if ( !_volumeView ) {
        _volumeView = [SJVideoPlayerTipsView new];
        _volumeView.titleLabel.text = @"音量";
        _volumeView.minShowTitleLabel.text = @"静音";
        __weak typeof(self) _self = self;
        _volumeView.setting = ^(SJVideoPlayerSettings * _Nonnull setting) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            ((SJVideoPlayerTipsView *)self.volumeView).minShowImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_un_volume"];
            ((SJVideoPlayerTipsView *)self.volumeView).normalShowImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_volume"];
        };
    }
    _volumeView.value = self.volume;
    return _volumeView;
}

- (SJVideoPlayerTipsView *)brightnessView {
    if ( !_brightnessView ) {
        _brightnessView = [SJVideoPlayerTipsView new];
        _brightnessView.titleLabel.text = @"亮度";
        __weak typeof(self) _self = self;
        _brightnessView.setting = ^(SJVideoPlayerSettings * _Nonnull setting) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            ((SJVideoPlayerTipsView *)self.brightnessView).normalShowImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_brightness"];
        };
    }
    _brightnessView.value = self.brightness;
    return _brightnessView;
}

- (UISlider *)systemVolume {
    if ( _systemVolume ) return _systemVolume;
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    [[UIApplication sharedApplication].keyWindow addSubview:volumeView]; // 隐藏系统volume
    volumeView.frame = CGRectMake(-1000, -100, 100, 100);
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _systemVolume = (UISlider *)view;
            break;
        }
    }
    return _systemVolume;
}

- (void)setVolume:(float)volume {
    if ( isnan(volume) ) volume = 0;
    if ( volume < 0 ) volume = 0;
    else if ( volume > 1 ) volume = 1;
    _systemVolume.value = volume;
    _volumeView.value = volume;
    if ( _volumeChanged ) _volumeChanged(volume);
}

- (float)volume {
    return self.systemVolume.value;
}

- (void)setBrightness:(float)brightness {
    if ( isnan(brightness) ) brightness = 0;
    if ( brightness < 0.1 ) brightness = 0.1;
    else if ( brightness > 1 ) brightness = 1;
    [UIScreen mainScreen].brightness = brightness;
    _brightnessView.value = brightness;
    if ( _brightnessChanged ) _brightnessChanged(brightness);
}

- (float)brightness {
    return [UIScreen mainScreen].brightness;
}

@end
