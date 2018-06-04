//
//  SJFilmEditingSettings.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/5/31.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJFilmEditingSettings.h"
#import "SJFilmEditingLoader.h"

NSNotificationName const SJFilmEditingSettingsUpdateNotification = @"SJFilmEditingSettingsUpdateNotification";

@implementation SJFilmEditingSettings

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
    _cancelBtnTitle = [SJFilmEditingLoader localizedStringForKey:SJVideoPlayer_CancelBtnTitle];
    _finishRecordingPromptText = [SJFilmEditingLoader localizedStringForKey:SJVideoPlayer_FinishRecordingPromptText];
    _waitingForRecordingPromptText = [SJFilmEditingLoader localizedStringForKey:SJVideoPlayer_WaitingForRecordingPromptText];
    _videoPlayDidToEndText = [SJFilmEditingLoader localizedStringForKey:SJVideoPlayer_VideoPlayDidToEndText];
    _uploadingPrompt = [SJFilmEditingLoader localizedStringForKey:SJVideoPlayer_UploadingPrompt];
    _exportingPrompt = [SJFilmEditingLoader localizedStringForKey:SJVideoPlayer_ExportingPrompt];
    _operationFailedPrompt = [SJFilmEditingLoader localizedStringForKey:SJVideoPlayer_OperationFailedPrompt];
    _uploadSuccessfullyPrompt = [SJFilmEditingLoader localizedStringForKey:SJVideoPlayer_UploadSuccessfullyPrompt];
    _exportSuccessfullyPrompt = [SJFilmEditingLoader localizedStringForKey:SJVideoPlayer_ExportSuccessfullyPrompt];
    
    _screenshotBtnImage = [SJFilmEditingLoader imageNamed:@"sj_video_player_screenshot"];
    _exportBtnImage = [SJFilmEditingLoader imageNamed:@"sj_video_player_export"];
    _gifBtnImage = [SJFilmEditingLoader imageNamed:@"sj_video_player_gif"];
    _finishRecordingBtnImage = [SJFilmEditingLoader imageNamed:@"sj_video_player_finish_recording"];
}

@end
