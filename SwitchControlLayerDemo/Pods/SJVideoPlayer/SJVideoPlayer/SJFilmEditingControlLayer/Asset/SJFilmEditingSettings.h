//
//  SJFilmEditingSettings.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/5/31.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;

extern NSNotificationName const SJFilmEditingSettingsUpdateNotification;

@interface SJFilmEditingSettings : NSObject
/// shared
+ (instancetype)commonSettings;

- (void)reset;

@property (nonatomic, strong, readonly) NSString *cancelBtnTitle;
@property (nonatomic, strong, readonly) NSString *waitingForRecordingPromptText;
@property (nonatomic, strong, readonly) NSString *finishRecordingPromptText;
@property (nonatomic, strong, readonly) NSString *videoPlayDidToEndText;
@property (nonatomic, strong, readonly) NSString *uploadingPrompt;
@property (nonatomic, strong, readonly) NSString *uploadSuccessfullyPrompt;
@property (nonatomic, strong, readonly) NSString *exportingPrompt;
@property (nonatomic, strong, readonly) NSString *exportSuccessfullyPrompt;
@property (nonatomic, strong, readonly) NSString *operationFailedPrompt;

@property (nonatomic, strong, readwrite) UIImage *screenshotBtnImage;
@property (nonatomic, strong, readwrite) UIImage *exportBtnImage;
@property (nonatomic, strong, readwrite) UIImage *gifBtnImage;
@property (nonatomic, strong, readwrite) UIImage *finishRecordingBtnImage;

@end
