//
//  SJFilmEditingLoader.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/5/31.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJFilmEditingLoader.h"
NSString *const SJVideoPlayer_CancelBtnTitle = @"SJVideoPlayer_CancelBtnTitle";
NSString *const SJVideoPlayer_WaitingForRecordingPromptText = @"SJVideoPlayer_WaitingForRecordingPromptText";
NSString *const SJVideoPlayer_FinishRecordingPromptText = @"SJVideoPlayer_FinishRecordingPromptText";
NSString *const SJVideoPlayer_VideoPlayDidToEndText = @"SJVideoPlayer_VideoPlayDidToEndText";
NSString *const SJVideoPlayer_UploadingPrompt = @"SJVideoPlayer_UploadingPrompt";
NSString *const SJVideoPlayer_UploadSuccessfullyPrompt = @"SJVideoPlayer_UploadSuccessfullyPrompt";
NSString *const SJVideoPlayer_ExportingPrompt = @"SJVideoPlayer_ExportingPrompt";
NSString *const SJVideoPlayer_ExportSuccessfullyPrompt = @"SJVideoPlayer_ExportSuccessfullyPrompt";
NSString *const SJVideoPlayer_OperationFailedPrompt = @"SJVideoPlayer_OperationFailedPrompt";

@implementation SJFilmEditingLoader

+ (NSBundle *)bundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SJFilmEditing" ofType:@"bundle"]];
    });
    return bundle;
}

+ (nullable UIImage *)imageNamed:(NSString *)name {
    if ( 0 == name.length )
        return nil;
    int scale = (int)UIScreen.mainScreen.scale;
    if ( scale < 2 ) scale = 2;
    else if ( scale > 3 ) scale = 3;
    NSString *n = [NSString stringWithFormat:@"%@@%dx.png", name, scale];
    return [UIImage imageWithContentsOfFile:[self.bundle pathForResource:n ofType:nil]];
}

+ (NSString *)localizedStringForKey:(NSString *)key {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ( [language hasPrefix:@"en"] ) {
            language = @"en";
        }
        else if ( [language hasPrefix:@"zh"] ) {
            if ( [language containsString:@"Hans"] ) {
                language = @"zh-Hans";
            }
            else {
                language = @"zh-Hant";
            }
        }
        else {
            language = @"en";
        }
        bundle = [NSBundle bundleWithPath:[[self bundle] pathForResource:language ofType:@"lproj"]];
    });
    NSString *value = [bundle localizedStringForKey:key value:nil table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

@end
