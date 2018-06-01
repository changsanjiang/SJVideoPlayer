//
//  SJFilmEditingSettings.m
//  SJVideoPlayerV3Project
//
//  Created by 畅三江 on 2018/5/31.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJFilmEditingSettings.h"
#import "SJFilmEditingResources.h"

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
    _cancelBtnTitle = [SJFilmEditingResources localizedStringForKey:SJVideoPlayer_CancelBtnTitle];
    _finishRecordingPromptText = [SJFilmEditingResources localizedStringForKey:SJVideoPlayer_FinishRecordingPromptText];
    _waitingForRecordingPromptText = [SJFilmEditingResources localizedStringForKey:SJVideoPlayer_WaitingForRecordingPromptText];
    _videoPlayDidToEndText = [SJFilmEditingResources localizedStringForKey:SJVideoPlayer_VideoPlayDidToEndText];
    _uploadingPrompt = [SJFilmEditingResources localizedStringForKey:SJVideoPlayer_UploadingPrompt];
    _exportingPrompt = [SJFilmEditingResources localizedStringForKey:SJVideoPlayer_ExportingPrompt];
    _operationFailedPrompt = [SJFilmEditingResources localizedStringForKey:SJVideoPlayer_OperationFailedPrompt];
    _uploadSuccessfullyPrompt = [SJFilmEditingResources localizedStringForKey:SJVideoPlayer_UploadSuccessfullyPrompt];
    _exportSuccessfullyPrompt = [SJFilmEditingResources localizedStringForKey:SJVideoPlayer_ExportSuccessfullyPrompt];
    
    _screenshotBtnImage = [SJFilmEditingResources imageNamed:@"sj_video_player_screenshot"];
    _exportBtnImage = [SJFilmEditingResources imageNamed:@"sj_video_player_export"];
    _gifBtnImage = [SJFilmEditingResources imageNamed:@"sj_video_player_gif"];
    _finishRecordingBtnImage = [SJFilmEditingResources imageNamed:@"sj_video_player_finish_recording"];
}

@end
