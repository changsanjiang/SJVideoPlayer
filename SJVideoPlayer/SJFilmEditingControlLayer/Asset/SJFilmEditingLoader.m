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
    if ( nil == bundle ) {
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SJFilmEditing" ofType:@"bundle"]];
    }
    return bundle;
}

+ (UIImage *)imageNamed:(NSString *)name {
    return [UIImage imageNamed:name inBundle:[self bundle] compatibleWithTraitCollection:nil];
}

+ (NSString *)localizedStringForKey:(NSString *)key {
    static NSBundle *bundle = nil;
    if ( nil == bundle ) {
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
    }
    NSString *value = [bundle localizedStringForKey:key value:nil table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

@end
