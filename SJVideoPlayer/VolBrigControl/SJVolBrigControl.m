//
//  SJVolBrigControl.m
//  SJVolBrigControl
//
//  Created by BlueDancer on 2017/12/10.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVolBrigControl.h"
#import <MediaPlayer/MPVolumeView.h>
#import "SJVideoPlayerTipsView.h"
#import "SJVideoPlayerResources.h"
#import <AVFoundation/AVFoundation.h>

@interface SJVolBrigControl ()

@property (nonatomic, strong, readwrite) SJVideoPlayerTipsView *brightnessView;
@property (nonatomic, strong, readonly) UISlider *systemVolume;

@end

@implementation SJVolBrigControl
@synthesize systemVolume = _systemVolume;
@synthesize volume = _volume;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    
    [self systemVolume];
    [self brightnessView];
    
    [[AVAudioSession sharedInstance] addObserver:self forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(void *)[AVAudioSession sharedInstance]];

    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if( context == (__bridge void *)[AVAudioSession sharedInstance] ){
        float newValue = [[change objectForKey:@"new"] floatValue];
        if ( _volumeChanged ) _volumeChanged(newValue);
    }
}

- (void)dealloc {
    [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume"];
}

- (SJVideoPlayerTipsView *)brightnessView {
    if ( !_brightnessView ) {
        _brightnessView = [SJVideoPlayerTipsView new];
        _brightnessView.titleLabel.text = @"亮度";
        _brightnessView.normalShowImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_brightness"];
    }
    _brightnessView.value = self.brightness;
    return _brightnessView;
}

- (UISlider *)systemVolume {
    if ( _systemVolume ) return _systemVolume;
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    for (UIView *view in [volumeView subviews]){
//    [[UIApplication sharedApplication].keyWindow addSubview:volumeView]; // 隐藏系统volume
//    volumeView.frame = CGRectMake(-1000, -100, 100, 100);
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _systemVolume = (UISlider *)view;
            break;
        }
    }
    return _systemVolume;
}

- (void)setVolume:(float)volume {
    _volume = volume;
    _systemVolume.value = volume;
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
