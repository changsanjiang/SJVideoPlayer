//
//  SJVolBrigControl.m
//  SJVolBrigControl
//
//  Created by BlueDancer on 2017/12/10.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVolBrigControl.h"
#import "SJVideoPlayerTipsView.h"
#import "SJVideoPlayerResources.h"
#import <MediaPlayer/MPMusicPlayerController.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


@interface SJVolBrigControl ()

@property (nonatomic, strong, readwrite) SJVideoPlayerTipsView *brightnessView;

@end

@implementation SJVolBrigControl
@synthesize volume = _volume;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self brightnessView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeDidChange) name:MPMusicPlayerControllerVolumeDidChangeNotification object:nil];
    return self;
}

- (void)volumeDidChange {
    if ( _volumeChanged ) _volumeChanged([MPMusicPlayerController applicationMusicPlayer].volume);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerVolumeDidChangeNotification object:nil];
}

- (SJVideoPlayerTipsView *)brightnessView {
    if ( !_brightnessView ) {
        _brightnessView = [SJVideoPlayerTipsView new];
        _brightnessView.titleLabel.text = @"亮度";
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [SJVideoPlayerResources imageNamed:@"sj_video_player_brightness"];
            dispatch_async(dispatch_get_main_queue(), ^{
                _brightnessView.normalShowImage = image;
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
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:volume];
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
#pragma clang diagnostic pop
