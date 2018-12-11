//
//  SJVolBrigControl.m
//  SJVolBrigControl
//
//  Created by BlueDancer on 2017/12/10.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVolBrigControl.h"
#import "SJVideoPlayerTipsView.h"
#import "SJVolBrigResource.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPVolumeView.h>

@interface SJVolBrigControl () {
    SJVideoPlayerTipsView *_brightnessView;
    UISlider *_volumeSlider;
}
@end

@implementation SJVolBrigControl {
    id _notifyToken;
}

@synthesize volume = _volume;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self brightnessView];
    
    __weak typeof(self) _self = self;
    _notifyToken = [NSNotificationCenter.defaultCenter addObserverForName:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self volumeDidChange];
    }];
    
    _volume = [AVAudioSession sharedInstance].outputVolume;
    for ( UIView *subview in [[MPVolumeView new] subviews] ) {
        if ( [subview.class.description isEqualToString:@"MPVolumeSlider"] ) {
            _volumeSlider = (UISlider *)subview;
            break;
        }
    }
    return self;
}

- (void)volumeDidChange {
    if ( _volumeChanged ) _volumeChanged([AVAudioSession sharedInstance].outputVolume);
}

- (void)dealloc {
    if ( _notifyToken ) [[NSNotificationCenter defaultCenter] removeObserver:_notifyToken];
}

- (SJVideoPlayerTipsView *)brightnessView {
    if ( !_brightnessView ) {
        _brightnessView = [SJVideoPlayerTipsView new];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [SJVolBrigResource imageNamed:@"sj_video_player_brightness"];
            NSString *brightnessText = [SJVolBrigResource localizedStringForKey:SJVolBrigControlBrightnessText];
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_brightnessView.image = image;
                self->_brightnessView.titleLabel.text = brightnessText;
            });
        });
    }
    _brightnessView.value = self.brightness;
    return _brightnessView;
}

- (void)setVolume:(float)volume {
    if ( isnan(volume) || volume < 0 ) volume = 0;
    else if ( volume > 1 ) volume = 1;
    _volume = volume;
    _volumeSlider.value = volume;
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
