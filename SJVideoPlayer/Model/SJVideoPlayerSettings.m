//
//  SJVideoPlayerSettings.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerSettings.h"
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
    self.progress_traceColor = [UIColor orangeColor];
    self.progress_bufferColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.progress_trackColor =  [UIColor whiteColor];
    self.progress_traceHeight = 3;
    self.progress_thumbColor = self.progress_traceColor;
    self.more_traceColor = [UIColor greenColor];
    self.more_trackColor = [UIColor whiteColor];
    self.more_trackHeight = 5;
    self.loadingLineColor = [UIColor whiteColor];
}

@end
