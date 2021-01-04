//
//  SJVideoPlayerConfigurations.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/9/25.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "SJVideoPlayerConfigurations.h"
#import <UIKit/UIKit.h>
#import <AVKit/AVPictureInPictureController.h>
#import "SJVideoPlayerResourceLoader.h"

NS_ASSUME_NONNULL_BEGIN
NSNotificationName const SJVideoPlayerConfigurationsDidUpdateNotification = @"SJVideoPlayerConfigurationsDidUpdateNotification";

@interface SJVideoPlayerControlLayerResources : NSObject<SJVideoPlayerControlLayerResources>
@property (nonatomic, strong, nullable) UIImage *placeholder;

#pragma mark - SJEdgeControlLayer Resources

// picture in picture
@property (nonatomic, strong, nullable) UIImage *pictureInPictureItemStartImage API_AVAILABLE(ios(14.0));
@property (nonatomic, strong, nullable) UIImage *pictureInPictureItemStopImage API_AVAILABLE(ios(14.0));

// speedup playback popup view(长按快进时显示的视图)
@property (nonatomic, strong, nullable) UIColor *speedupPlaybackTriangleColor;
@property (nonatomic, strong, nullable) UIColor *speedupPlaybackRateTextColor;
@property (nonatomic, strong, nullable) UIFont  *speedupPlaybackRateTextFont;
@property (nonatomic, strong, nullable) UIColor *speedupPlaybackTextColor;
@property (nonatomic, strong, nullable) UIFont  *speedupPlaybackTextFont;

// loading view
@property (nonatomic, strong, nullable) UIColor *loadingNetworkSpeedTextColor;
@property (nonatomic, strong, nullable) UIFont  *loadingNetworkSpeedTextFont;
@property (nonatomic, strong, nullable) UIColor *loadingLineColor;

// dragging view
@property (nonatomic, strong, nullable) UIImage *fastImage;
@property (nonatomic, strong, nullable) UIImage *forwardImage;

// custom status bar
@property (nonatomic, strong, nullable) UIImage *batteryBorderImage;
@property (nonatomic, strong, nullable) UIImage *batteryNubImage;
@property (nonatomic, strong, nullable) UIImage *batteryLightningImage;

// top adapter items
@property (nonatomic, strong, nullable) UIImage *backImage;
@property (nonatomic, strong, nullable) UIImage *moreImage;
@property (nonatomic, strong, nullable) UIFont  *titleLabelFont;
@property (nonatomic, strong, nullable) UIColor *titleLabelColor;

// left adapter items
@property (nonatomic, strong, nullable) UIImage *lockImage;
@property (nonatomic, strong, nullable) UIImage *unlockImage;

// bottom adapter items
@property (nonatomic, strong, nullable) UIImage *pauseImage;
@property (nonatomic, strong, nullable) UIImage *playImage;

@property (nonatomic, strong, nullable) UIFont  *timeLabelFont;
@property (nonatomic, strong, nullable) UIColor *timeLabelColor;

@property (nonatomic, strong, nullable) UIImage *smallScreenImage;                  // 缩回小屏的图片
@property (nonatomic, strong, nullable) UIImage *fullscreenImage;                   // 全屏的图片

@property (nonatomic, strong, nullable) UIColor *progressTrackColor;                // 轨道颜色
@property (nonatomic)                   float    progressTrackHeight;               // 轨道高度
@property (nonatomic, strong, nullable) UIColor *progressTraceColor;                // 轨迹颜色, 走过的痕迹
@property (nonatomic, strong, nullable) UIColor *progressBufferColor;               // 缓冲颜色
@property (nonatomic, strong, nullable) UIColor *progressThumbColor;                // 滑块颜色, 请设置滑块大小
@property (nonatomic, strong, nullable) UIImage *progressThumbImage;                // 滑块图片, 优先使用, 为nil时将会使用滑块颜色
@property (nonatomic)                   float    progressThumbSize;                 // 滑块大小

@property (nonatomic, strong, nullable) UIColor *bottomIndicatorTrackColor;         // 底部指示条轨道颜色
@property (nonatomic, strong, nullable) UIColor *bottomIndicatorTraceColor;         // 底部指示条轨迹颜色
@property (nonatomic)                   float    bottomIndicatorHeight;             // 底部指示条高度
    
// right adapter items
@property (nonatomic, strong, nullable) UIImage *clipsImage;

// center adapter items
@property (nonatomic, strong, nullable) UIColor *replayTitleColor;
@property (nonatomic, strong, nullable) UIFont  *replayTitleFont;
@property (nonatomic, strong, nullable) UIImage *replayImage;


#pragma mark - SJMoreSettingControlLayer Resources

@property (nonatomic, strong, nullable) UIColor *moreControlLayerBackgroundColor;
@property (nonatomic, strong, nullable) UIColor *moreSliderTraceColor;              // sider trace color of more view
@property (nonatomic, strong, nullable) UIColor *moreSliderTrackColor;              // sider track color of more view
@property (nonatomic)                   float    moreSliderTrackHeight;             // sider track height of more view
@property (nonatomic, strong, nullable) UIImage *moreSliderThumbImage;              // sider thumb image of more view
@property (nonatomic)                   float    moreSliderThumbSize;               // sider thumb size of more view
@property (nonatomic)                   float    moreSliderMinRateValue;            // 最小播放倍速值
@property (nonatomic)                   float    moreSliderMaxRateValue;            // 最大播放倍速值
@property (nonatomic, strong, nullable) UIImage *moreSliderMinRateImage;            // 最小播放倍速图标
@property (nonatomic, strong, nullable) UIImage *moreSliderMaxRateImage;            // 最大播放倍速图标
@property (nonatomic, strong, nullable) UIImage *moreSliderMinVolumeImage;
@property (nonatomic, strong, nullable) UIImage *moreSliderMaxVolumeImage;
@property (nonatomic, strong, nullable) UIImage *moreSliderMinBrightnessImage;
@property (nonatomic, strong, nullable) UIImage *moreSliderMaxBrightnessImage;


#pragma mark - SJLoadFailedControlLayer Resources

@property (nonatomic, strong, nullable) UIColor  *playFailedButtonBackgroundColor;

#pragma mark - SJNotReachableControlLayer Resources

@property (nonatomic, strong, nullable) UIColor *noNetworkButtonBackgroundColor;

#pragma mark - SJFloatSmallViewControlLayer Resources

@property (nonatomic, strong, nullable) UIImage *floatSmallViewCloseImage;

#pragma mark - SJClipsControlLayer Resources

@property (nonatomic, strong, nullable) UIImage *screenshotImage;
@property (nonatomic, strong, nullable) UIImage *videoClipImage;
@property (nonatomic, strong, nullable) UIImage *GIFClipImage;

@property (nonatomic, strong, nullable) UIImage *recordsPreparingImage;
@property (nonatomic, strong, nullable) UIImage *recordsToFinishRecordingImage;
@end

@implementation SJVideoPlayerControlLayerResources
- (void)_loadSJEdgeControlLayerResources {
    if (@available(iOS 14.0, *)) {
        _pictureInPictureItemStartImage = [AVPictureInPictureController.pictureInPictureButtonStartImage imageWithTintColor:UIColor.whiteColor];
        _pictureInPictureItemStopImage = [AVPictureInPictureController.pictureInPictureButtonStopImage imageWithTintColor:UIColor.whiteColor];
    }

    _speedupPlaybackTriangleColor = UIColor.whiteColor;
    _speedupPlaybackRateTextColor = UIColor.whiteColor;
    _speedupPlaybackRateTextFont = [UIFont boldSystemFontOfSize:12];
    _speedupPlaybackTextColor = UIColor.whiteColor;
    _speedupPlaybackTextFont = [UIFont boldSystemFontOfSize:12];
  
    _loadingNetworkSpeedTextColor = UIColor.whiteColor;
    _loadingNetworkSpeedTextFont = [UIFont systemFontOfSize:11];
    _loadingLineColor = UIColor.whiteColor;
 
    _fastImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_fast"];
    _forwardImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_forward"];

    _batteryBorderImage = [SJVideoPlayerResourceLoader imageNamed:@"battery_border"];
    _batteryNubImage = [SJVideoPlayerResourceLoader imageNamed:@"battery_nub"];
    _batteryLightningImage = [SJVideoPlayerResourceLoader imageNamed:@"battery_lightning"];
 
    _backImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_back"];
    _moreImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_more"];
    _titleLabelFont = [UIFont boldSystemFontOfSize:14];
    _titleLabelColor = [UIColor whiteColor];

    _lockImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_lock"];
    _unlockImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_unlock"];

    _pauseImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_pause"];
    _playImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_play"];
    _timeLabelFont = [UIFont systemFontOfSize:11];
    _timeLabelColor = UIColor.whiteColor;
    
    _smallScreenImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_shrinkscreen"];
    _fullscreenImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_fullscreen"];

    _progressTrackColor =  [UIColor whiteColor];
    _progressTrackHeight = 3;
    _progressTraceColor = [UIColor colorWithRed:2 / 256.0 green:141 / 256.0 blue:140 / 256.0 alpha:1];
    _progressBufferColor = [UIColor colorWithWhite:0 alpha:0.2];
    _progressThumbColor = _progressTraceColor;
    
    _bottomIndicatorTrackColor = _progressTrackColor;
    _bottomIndicatorTraceColor = _progressTraceColor;
    _bottomIndicatorHeight = 1;

    _clipsImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_clips"];

    _replayTitleColor = [UIColor whiteColor];
    _replayTitleFont = [UIFont boldSystemFontOfSize:12];
    _replayImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_replay"];
}

- (void)_loadSJMoreSettingControlLayerResources {
    _moreControlLayerBackgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    _moreSliderTraceColor = [UIColor colorWithRed:2 / 256.0 green:141 / 256.0 blue:140 / 256.0 alpha:1];
    _moreSliderTrackColor = [UIColor whiteColor];
    _moreSliderTrackHeight = 4;
    _moreSliderMinRateValue = 0.5;
    _moreSliderMaxRateValue = 1.5;
    _moreSliderMinRateImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_minRate"];
    _moreSliderMaxRateImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_maxRate"];
    _moreSliderMinVolumeImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_minVolume"];
    _moreSliderMaxVolumeImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_maxVolume"];
    _moreSliderMinBrightnessImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_minBrightness"];
    _moreSliderMaxBrightnessImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_maxBrightness"];
}

- (void)_loadSJLoadFailedControlLayerResources {
    _playFailedButtonBackgroundColor = [UIColor colorWithRed:36/255.0 green:171/255.0 blue:1 alpha:1];
}

- (void)_loadSJNotReachableControlLayerResources {
    _noNetworkButtonBackgroundColor = [UIColor colorWithRed:36/255.0 green:171/255.0 blue:1 alpha:1];
}

- (void)_loadSJFloatSmallViewControlLayerResources {
    _floatSmallViewCloseImage = [SJVideoPlayerResourceLoader imageNamed:@"close"];
}

- (void)_loadSJClipsControlLayerResources {
    _screenshotImage = [SJVideoPlayerResourceLoader imageNamed:@"screenshot"];
    _videoClipImage = [SJVideoPlayerResourceLoader imageNamed:@"video_clip"];
    _GIFClipImage = [SJVideoPlayerResourceLoader imageNamed:@"gif_clip"];

    _recordsPreparingImage = [SJVideoPlayerResourceLoader imageNamed:@"records_preparing"];
    _recordsToFinishRecordingImage = [SJVideoPlayerResourceLoader imageNamed:@"records_finish"];
}
@end


@interface SJVideoPlayerLocalizedStrings : NSObject<SJVideoPlayerLocalizedStrings>
- (void)setFromBundle:(NSBundle *)bundle;

@property (nonatomic, copy, nullable) NSString *longPressSpeedupPlayback;
 
@property (nonatomic, copy, nullable) NSString *noNetWork;
@property (nonatomic, copy, nullable) NSString *WiFiNetwork;
@property (nonatomic, copy, nullable) NSString *cellularNetwork;

@property (nonatomic, copy, nullable) NSString *replay;
@property (nonatomic, copy, nullable) NSString *retry;
@property (nonatomic, copy, nullable) NSString *reload;
@property (nonatomic, copy, nullable) NSString *liveBroadcast;
@property (nonatomic, copy, nullable) NSString *cancel;
@property (nonatomic, copy, nullable) NSString *done;

@property (nonatomic, copy, nullable) NSString *unstableNetworkPrompt;
@property (nonatomic, copy, nullable) NSString *cellularNetworkPrompt;
@property (nonatomic, copy, nullable) NSString *noNetworkPrompt;
@property (nonatomic, copy, nullable) NSString *playbackFailedPrompt;

@property (nonatomic, copy, nullable) NSString *recordsPreparingPrompt;
@property (nonatomic, copy, nullable) NSString *recordsToFinishRecordingPrompt;

@property (nonatomic, copy, nullable) NSString *exportsExportingPrompt;
@property (nonatomic, copy, nullable) NSString *exportsExportFailedPrompt;
@property (nonatomic, copy, nullable) NSString *exportsExportSuccessfullyPrompt;

@property (nonatomic, copy, nullable) NSString *uploadsUploadingPrompt;
@property (nonatomic, copy, nullable) NSString *uploadsUploadFailedPrompt;
@property (nonatomic, copy, nullable) NSString *uploadsUploadSuccessfullyPrompt;

@property (nonatomic, copy, nullable) NSString *screenshotSuccessfullyPrompt;

@property (nonatomic, copy, nullable) NSString *albumAuthDeniedPrompt;
@property (nonatomic, copy, nullable) NSString *albumSavingScreenshotToAlbumPrompt;
@property (nonatomic, copy, nullable) NSString *albumSavedToAlbumPrompt;

@property (nonatomic, copy, nullable) NSString *operationFailedPrompt;

@property (nonatomic, copy, nullable) NSString *definitionSwitchingPrompt;
@property (nonatomic, copy, nullable) NSString *definitionSwitchSuccessfullyPrompt;
@property (nonatomic, copy, nullable) NSString *definitionSwitchFailedPrompt;
@end

@implementation SJVideoPlayerLocalizedStrings {
    NSBundle *_bundle;
}
  
- (void)setFromBundle:(NSBundle *)bundle {
    _bundle = bundle;
    _longPressSpeedupPlayback = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyLongPressSpeedupPlayback];
    _noNetWork = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyNoNetwork];
    _WiFiNetwork = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyWiFiNetWork];
    _cellularNetwork = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyCellularNetwork];
    _replay = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyReplay];
    _retry = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyRetry];
    _reload = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyReload];
    _liveBroadcast = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyLiveBroadcast];
    _cancel = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyCancel];
    _done = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyDone];
    _unstableNetworkPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyUnstableNetworkPrompt];
    _cellularNetworkPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyCellularNetworkPrompt];
    _noNetworkPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyNoNetworkPrompt];
    _playbackFailedPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyPlaybackFailedPrompt];
    _recordsPreparingPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyRecordsPreparingPrompt];
    _recordsToFinishRecordingPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyRecordsToFinishRecordingPrompt];
    _exportsExportingPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyExportsExportingPrompt];
    _exportsExportFailedPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyExportsExportFailedPrompt];
    _exportsExportSuccessfullyPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyExportsExportSuccessfullyPrompt];
    _uploadsUploadingPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyUploadsUploadingPrompt];
    _uploadsUploadFailedPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyUploadsUploadFailedPrompt];
    _uploadsUploadSuccessfullyPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyUploadsUploadSuccessfullyPrompt];
    _screenshotSuccessfullyPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyScreenshotSuccessfullyPrompt];
    _albumAuthDeniedPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyAlbumAuthDeniedPrompt];
    _albumSavingScreenshotToAlbumPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyAlbumSavingScreenshotToAlbumPrompt];
    _albumSavedToAlbumPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyAlbumSavedToAlbumPrompt];
    _operationFailedPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyOperationFailedPrompt];
    _definitionSwitchingPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyDefinitionSwitchingPrompt];
    _definitionSwitchSuccessfullyPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyDefinitionSwitchSuccessfullyPrompt];
    _definitionSwitchFailedPrompt = [self localizedStringForKey:SJVideoPlayerLocalizedStringKeyDefinitionSwitchFailedPrompt];
}

- (nullable NSString *)localizedStringForKey:(NSString *)key {
    NSBundle *mainBundle = NSBundle.mainBundle;
    NSString *value = _bundle != mainBundle ? [_bundle localizedStringForKey:key value:nil table:nil] : nil;
    return [mainBundle localizedStringForKey:key value:value table:nil];
}
@end


@interface SJVideoPlayerConfigurations () {
    dispatch_group_t _group;
}

@end

@implementation SJVideoPlayerConfigurations
  
+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _animationDuration = 0.4;
        _group = dispatch_group_create();
        [self localizedStrings];
        [self resources];
    }
    return self;
}

+ (void (^)(void (^ _Nonnull)(SJVideoPlayerConfigurations * _Nonnull)))update {
    return ^(void(^block)(SJVideoPlayerConfigurations *configs)) {
        SJVideoPlayerConfigurations *configs = SJVideoPlayerConfigurations.shared;
        dispatch_group_notify(configs->_group, dispatch_get_global_queue(0, 0), ^{
            block(SJVideoPlayerConfigurations.shared);
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSNotificationCenter.defaultCenter postNotificationName:SJVideoPlayerConfigurationsDidUpdateNotification object:configs];
            });
        });
    };
} 

- (id<SJVideoPlayerLocalizedStrings>)localizedStrings {
    if ( _localizedStrings == nil ) {
        SJVideoPlayerLocalizedStrings *strings = SJVideoPlayerLocalizedStrings.alloc.init;
        dispatch_group_async(_group, dispatch_get_global_queue(0, 0), ^{
            [strings setFromBundle:SJVideoPlayerResourceLoader.preferredLanguageBundle];
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSNotificationCenter.defaultCenter postNotificationName:SJVideoPlayerConfigurationsDidUpdateNotification object:self];
            });
        });
        _localizedStrings = strings;
    }
    return _localizedStrings;
}

- (id<SJVideoPlayerControlLayerResources>)resources {
    if ( _resources == nil ) {
        SJVideoPlayerControlLayerResources *resources = SJVideoPlayerControlLayerResources.alloc.init;
        dispatch_group_async(_group, dispatch_get_global_queue(0, 0), ^{
            [resources _loadSJEdgeControlLayerResources];
        });
        dispatch_group_async(_group, dispatch_get_global_queue(0, 0), ^{
            [resources _loadSJMoreSettingControlLayerResources];
        });
        dispatch_group_async(_group, dispatch_get_global_queue(0, 0), ^{
            [resources _loadSJLoadFailedControlLayerResources];
        });
        dispatch_group_async(_group, dispatch_get_global_queue(0, 0), ^{
            [resources _loadSJNotReachableControlLayerResources];
        });
        dispatch_group_async(_group, dispatch_get_global_queue(0, 0), ^{
            [resources _loadSJFloatSmallViewControlLayerResources];
        });
        dispatch_group_async(_group, dispatch_get_global_queue(0, 0), ^{
            [resources _loadSJClipsControlLayerResources];
        });
        dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
            [NSNotificationCenter.defaultCenter postNotificationName:SJVideoPlayerConfigurationsDidUpdateNotification object:self];
        });
        _resources = resources;
    }
    return _resources;
}
@end
NS_ASSUME_NONNULL_END
