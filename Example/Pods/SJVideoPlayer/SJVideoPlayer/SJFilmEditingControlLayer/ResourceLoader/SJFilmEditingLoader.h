//
//  SJFilmEditingLoader.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/5/31.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
UIKIT_EXTERN NSString *const SJVideoPlayer_CancelBtnTitle;
UIKIT_EXTERN NSString *const SJVideoPlayer_WaitingForRecordingPromptText;
UIKIT_EXTERN NSString *const SJVideoPlayer_FinishRecordingPromptText;
UIKIT_EXTERN NSString *const SJVideoPlayer_VideoPlayDidToEndText;
UIKIT_EXTERN NSString *const SJVideoPlayer_UploadingPrompt;
UIKIT_EXTERN NSString *const SJVideoPlayer_UploadSuccessfullyPrompt;
UIKIT_EXTERN NSString *const SJVideoPlayer_ExportingPrompt;
UIKIT_EXTERN NSString *const SJVideoPlayer_ExportSuccessfullyPrompt;
UIKIT_EXTERN NSString *const SJVideoPlayer_OperationFailedPrompt;

@interface SJFilmEditingLoader : NSObject
+ (UIImage *)imageNamed:(NSString *)name;
+ (NSString *)localizedStringForKey:(NSString *)key;
@end
