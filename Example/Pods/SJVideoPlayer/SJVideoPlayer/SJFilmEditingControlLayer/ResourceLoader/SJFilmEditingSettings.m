//
//  SJFilmEditingSettings.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/5/31.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJFilmEditingSettings.h"
#import "SJFilmEditingLoader.h"

NS_ASSUME_NONNULL_BEGIN
NSNotificationName const SJFilmEditingSettingsUpdatedNotification = @"SJFilmEditingSettingsUpdatedNotification";
NSString *const SJFilmEditing_cancelText = @"SJFilmEditing_cancelText";
NSString *const SJFilmEditing_doneText = @"SJFilmEditing_doneText";
NSString *const SJFilmEditing_waitingText = @"SJFilmEditing_waitingText";
NSString *const SJFilmEditing_finishText = @"SJFilmEditing_finishText";
NSString *const SJFilmEditing_exportingText = @"SJFilmEditing_exportingText";
NSString *const SJFilmEditing_exportFailedText = @"SJFilmEditing_exportFailedText";
NSString *const SJFilmEditing_exportSuccessText = @"SJFilmEditing_exportSuccessText";
NSString *const SJFilmEditing_screenshotSuccessText = @"SJFilmEditing_screenshotSuccessText";
NSString *const SJFilmEditing_albumAuthDeniedText = @"SJFilmEditing_albumAuthDeniedText";
NSString *const SJFilmEditing_savingToAlbumText = @"SJFilmEditing_savingToAlbumText";
NSString *const SJFilmEditing_saveToAlbumSuccessText = @"SJFilmEditing_saveToAlbumSuccessText";
NSString *const SJFilmEditing_uploadingText = @"SJFilmEditing_uploadingText";
NSString *const SJFilmEditing_uploadFailedText = @"SJFilmEditing_uploadFailedText";
NSString *const SJFilmEditing_uploadSuccessText = @"SJFilmEditing_uploadSuccessText";

@implementation SJFilmEditingSettings
+ (instancetype)commonSettings {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self reset];
    return self;
}

+ (void (^)(void (^ _Nonnull)(SJFilmEditingSettings * _Nonnull)))update {
    return ^(void(^block)(SJFilmEditingSettings *settings)) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            block(SJFilmEditingSettings.commonSettings);
            [SJFilmEditingSettings.commonSettings postUpdateNotify];
        });
    };
}

- (void)postUpdateNotify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SJFilmEditingSettingsUpdatedNotification object:self];
    });
}

- (void)reset {
    _screenshotBtnImage = [SJFilmEditingLoader imageNamed:@"sj_video_player_screenshot"];
    _exportBtnImage = [SJFilmEditingLoader imageNamed:@"sj_video_player_export"];
    _gifBtnImage = [SJFilmEditingLoader imageNamed:@"sj_video_player_gif"];

    _cancelText = [SJFilmEditingLoader localizedStringForKey:SJFilmEditing_cancelText];
    _doneText = [SJFilmEditingLoader localizedStringForKey:SJFilmEditing_doneText];
    
    _waitingImage = [SJFilmEditingLoader imageNamed:@"sj_export_waiting"];
    _finishImage = [SJFilmEditingLoader imageNamed:@"sj_export_finish"];

    _waitingText = [SJFilmEditingLoader localizedStringForKey:SJFilmEditing_waitingText];
    _finishText = [SJFilmEditingLoader localizedStringForKey:SJFilmEditing_finishText];

    _exportingText = [SJFilmEditingLoader localizedStringForKey:SJFilmEditing_exportingText];
    _exportFailedText = [SJFilmEditingLoader localizedStringForKey:SJFilmEditing_exportFailedText];
    _exportSuccessText = [SJFilmEditingLoader localizedStringForKey:SJFilmEditing_exportSuccessText];
    _screenshotSuccessText = [SJFilmEditingLoader localizedStringForKey:SJFilmEditing_screenshotSuccessText];

    _albumAuthDeniedText = [SJFilmEditingLoader localizedStringForKey:SJFilmEditing_albumAuthDeniedText];
    _savingToAlbumText = [SJFilmEditingLoader localizedStringForKey:SJFilmEditing_savingToAlbumText];
    _saveToAlbumSuccessText = [SJFilmEditingLoader localizedStringForKey:SJFilmEditing_saveToAlbumSuccessText];

    _uploadingText = [SJFilmEditingLoader localizedStringForKey:SJFilmEditing_uploadingText];
    _uploadFailedText = [SJFilmEditingLoader localizedStringForKey:SJFilmEditing_uploadFailedText];
    _uploadSuccessText = [SJFilmEditingLoader localizedStringForKey:SJFilmEditing_uploadSuccessText];
}
@end


@implementation SJFilmEditingSettingsUpdatedObserver {
    id _updatedToken;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        __weak typeof(self) _self = self;
        _updatedToken = [NSNotificationCenter.defaultCenter addObserverForName:SJFilmEditingSettingsUpdatedNotification object:SJFilmEditingSettings.commonSettings queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( self.updatedExeBlock ) self.updatedExeBlock(note.object);
        }];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:_updatedToken];
}
@end
NS_ASSUME_NONNULL_END
