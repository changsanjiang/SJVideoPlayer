//
//  SJVideoPlayerResources.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const SJVideoPlayer_ReplayText;
UIKIT_EXTERN NSString *const SJVideoPlayer_PreviewText;
UIKIT_EXTERN NSString *const SJVideoPlayer_PlayFailedText;
UIKIT_EXTERN NSString *const SJVideoPlayer_NotReachablePrompt;
UIKIT_EXTERN NSString *const SJVideoPlayer_ReachableViaWWANPrompt;
UIKIT_EXTERN NSString *const SJVideoPlayer_CancelBtnTitle;
UIKIT_EXTERN NSString *const SJVideoPlayer_WaitingForRecordingPromptText;
UIKIT_EXTERN NSString *const SJVideoPlayer_RecordPromptText;
UIKIT_EXTERN NSString *const SJVideoPlayer_VideoPlayDidToEndText;
UIKIT_EXTERN NSString *const SJVideoPlayer_UploadingPrompt;
UIKIT_EXTERN NSString *const SJVideoPlayer_UploadSuccessfullyPrompt;
UIKIT_EXTERN NSString *const SJVideoPlayer_ExportingPrompt;
UIKIT_EXTERN NSString *const SJVideoPlayer_ExportSuccessfullyPrompt;
UIKIT_EXTERN NSString *const SJVideoPlayer_OperationFailedPrompt;

@interface SJVideoPlayerResources : NSObject

+ (UIImage *)imageNamed:(NSString *)name;

+ (NSString *)localizedStringForKey:(NSString *)key;

@end
