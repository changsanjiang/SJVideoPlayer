//
//  SJEdgeControlLayerSettings.m
//  SJEdgeControlLayer_Example
//
//  Created by 畅三江 on 2018/6/2.
//  Copyright © 2018年 changsanjiang@gmail.com. All rights reserved.
//

#import "SJEdgeControlLayerSettings.h"
#import <UIKit/UIKit.h>
#import "SJEdgeControlLayerLoader.h"

NSNotificationName const SJSettingsPlayerNotification = @"SJSettingsPlayerNotification";

@implementation SJEdgeControlLayerSettings

+ (instancetype)commonSettings {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
        [_instance reset];
    });
    return _instance;
}

+ (void (^)(void (^ _Nonnull)(SJEdgeControlLayerSettings * _Nonnull)))update {
    return ^(void(^block)(SJEdgeControlLayerSettings *settings)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block([SJEdgeControlLayerSettings commonSettings]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SJSettingsPlayerNotification object:[SJEdgeControlLayerSettings commonSettings]];
            });
        });
    };
}

- (void)reset {
    _notReachablePrompt = [SJEdgeControlLayerLoader localizedStringForKey:SJVideoPlayer_NotReachablePrompt];
    _reachableViaWWANPrompt = [SJEdgeControlLayerLoader localizedStringForKey:SJVideoPlayer_ReachableViaWWANPrompt];
    self.loadingLineColor = [UIColor whiteColor];
    self.titleFont = [UIFont boldSystemFontOfSize:14];
    self.titleColor = [UIColor whiteColor];
    self.fastImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_fast"];
    self.forwardImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_forward"];
    self.backBtnImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_back"];
    self.moreBtnImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_more"];
    self.previewBtnImage = [SJEdgeControlLayerLoader imageNamed:@""];
    self.playBtnImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_play"];
    self.pauseBtnImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_pause"];
    self.fullBtnImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_fullscreen"];
    self.shrinkscreenImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_shrinkscreen"];
    self.lockBtnImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_lock"];
    self.unlockBtnImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_unlock"];
    self.replayBtnImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_replay"];
    self.progress_traceColor = [UIColor colorWithRed:2 / 256.0 green:141 / 256.0 blue:140 / 256.0 alpha:1];
    self.progress_bufferColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.progress_trackColor =  [UIColor whiteColor];
    self.progress_thumbColor = self.progress_traceColor;
    self.progress_loadingColor = [UIColor whiteColor];
    self.moreBackgroundColor = [UIColor colorWithWhite:0 alpha:0.62];
    self.progress_traceHeight = 3;
    self.more_trackHeight = 4;
    self.more_traceColor = self.progress_traceColor;
    self.more_trackColor = [UIColor whiteColor];
    self.more_minRateImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_minRate"];
    self.more_maxRateImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_maxRate"];
    self.more_minVolumeImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_minVolume"];
    self.more_maxVolumeImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_maxVolume"];
    self.more_minBrightnessImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_minBrightness"];
    self.more_maxBrightnessImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_maxBrightness"];
    _replayBtnTitle = [SJEdgeControlLayerLoader localizedStringForKey:SJVideoPlayer_ReplayText];
    self.replayBtnFont = [UIFont boldSystemFontOfSize:12];
    self.replayBtnTitleColor = [UIColor whiteColor];
    _previewBtnTitle = [SJEdgeControlLayerLoader localizedStringForKey:SJVideoPlayer_PreviewText];
    self.previewBtnFont = [UIFont boldSystemFontOfSize:12];
    _playFailedBtnTitle = [SJEdgeControlLayerLoader localizedStringForKey:SJVideoPlayer_PlayFailedText];
    self.playFailedBtnFont = [UIFont boldSystemFontOfSize:12];
    self.playFailedBtnTitleColor = [UIColor whiteColor];
    self.filmEditingBtnImage = [SJEdgeControlLayerLoader imageNamed:@"sj_video_player_film_editing"];
}

@end
