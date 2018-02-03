//
//  SJVideoPlayerSettings.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerSettings.h"
#import <UIKit/UIKit.h>
#import "SJVideoPlayerResources.h"

NSNotificationName const SJSettingsPlayerNotification = @"SJSettingsPlayerNotification";

@implementation SJVideoPlayerSettings

+ (instancetype)commonSettings {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
        [_instance reset];
    });
    return _instance;
}

- (void)reset {
    self.loadingLineColor = [UIColor whiteColor];
    self.titleFont = [UIFont boldSystemFontOfSize:14];
    self.titleColor = [UIColor whiteColor];
    self.fastImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_fast"];
    self.forwardImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_forward"];
    self.backBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_back"];
    self.moreBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_more"];
    self.previewBtnImage = [SJVideoPlayerResources imageNamed:@""];
    self.playBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_play"];
    self.pauseBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_pause"];
    self.fullBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_fullscreen"];
    self.lockBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_lock"];
    self.unlockBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_unlock"];
    self.replayBtnImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_replay"];
    self.replayBtnTitle = @"重播";
    self.replayBtnFont = [UIFont boldSystemFontOfSize:12];
    self.progress_traceColor = [UIColor colorWithRed:2 / 256.0 green:141 / 256.0 blue:140 / 256.0 alpha:1];
    self.progress_bufferColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.progress_trackColor =  [UIColor whiteColor];
    self.progress_traceHeight = 3;
    self.progress_thumbColor = self.progress_traceColor;
    self.moreBackgroundColor = [UIColor colorWithWhite:0 alpha:0.62];
    self.more_traceColor = self.progress_traceColor;
    self.more_trackColor = [UIColor whiteColor];
    self.more_trackHeight = 5;
    self.more_minRateImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_minRate"];
    self.more_maxRateImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_maxRate"];
    self.more_minVolumeImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_minVolume"];
    self.more_maxVolumeImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_maxVolume"];
    self.more_minBrightnessImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_minBrightness"];
    self.more_maxBrightnessImage = [SJVideoPlayerResources imageNamed:@"sj_video_player_maxBrightness"];
}

@end
