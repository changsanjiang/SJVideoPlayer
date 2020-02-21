//
//  SJVideoPlayerSettings.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/9/25.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "SJVideoPlayerSettings.h"
#import <UIKit/UIKit.h>
#import "SJVideoPlayerResourceLoader.h"

NS_ASSUME_NONNULL_BEGIN
NSNotificationName const SJVideoPlayerSettingsUpdatedNotification = @"SJVideoPlayerSettingsUpdatedNotification";

@interface SJVideoPlayerSettings ()
//@interface SJVideoPlayerSettings (SJEdgeControlLayer)
@property (nonatomic, strong, nullable) UIImage *placeholder;

// fast forward view(长按快进时显示的视图)
@property (nonatomic, strong, nullable) UIColor  *fastForwardTriangleColor;
@property (nonatomic, strong, nullable) UIColor  *fastForwardRateTextColor;
@property (nonatomic, strong, nullable) UIFont   *fastForwardRateTextFont;
@property (nonatomic, strong, nullable) UIColor  *fastForwardFFTextColor;
@property (nonatomic, strong, nullable) UIFont   *fastForwardFFTextFont;
@property (nonatomic, strong, nullable) NSString *fastForwardFFText;

// loading view
@property (nonatomic, strong, nullable) UIColor *loadingNetworkSpeedTextColor;
@property (nonatomic, strong, nullable) UIFont  *loadingNetworkSpeedTextFont;
@property (nonatomic, strong, nullable) UIColor *loadingLineColor;

// dragging view
@property (nonatomic, strong, nullable) UIImage *fastImage;
@property (nonatomic, strong, nullable) UIImage *forwardImage;

// prompt text
@property (nonatomic, strong, nullable) NSString *unstableNetworkPrompt;
@property (nonatomic, strong, nullable) NSString *cellularNetworkPrompt;

// custom status bar
@property (nonatomic, strong, nullable) NSString *statusBarNoNetworkText;
@property (nonatomic, strong, nullable) NSString *statusBarWiFiText;
@property (nonatomic, strong, nullable) NSString *statusBarCellularNetworkText;
@property (nonatomic, strong, nullable) UIImage *batteryBorderImage;
@property (nonatomic, strong, nullable) UIImage *batteryNubImage;
@property (nonatomic, strong, nullable) UIImage *batteryLightningImage;

// top adapter items
@property (nonatomic, strong, nullable) UIImage *backBtnImage;
@property (nonatomic, strong, nullable) UIImage *moreBtnImage;
@property (nonatomic, strong, nullable) UIFont *titleFont;
@property (nonatomic, strong, nullable) UIColor *titleColor;

// left adapter items
@property (nonatomic, strong, nullable) UIImage *lockBtnImage;
@property (nonatomic, strong, nullable) UIImage *unlockBtnImage;

// bottom adapter items
@property (nonatomic, strong, nullable) UIImage *pauseBtnImage;
@property (nonatomic, strong, nullable) UIImage *playBtnImage;
@property (nonatomic, strong, nullable) UIFont *timeFont;
@property (nonatomic, strong, nullable) UIImage *shrinkscreenImage;               // 缩回小屏的图片
@property (nonatomic, strong, nullable) UIImage *fullBtnImage;                    // 全屏的图片
@property (nonatomic, strong, nullable) UIColor *progress_trackColor;             // 轨道颜色
@property (nonatomic) float progress_traceHeight;                                 // 轨道高度
@property (nonatomic, strong, nullable) UIColor *progress_traceColor;             // 轨迹颜色, 走过的痕迹
@property (nonatomic, strong, nullable) UIColor *progress_bufferColor;            // 缓冲颜色
@property (nonatomic, strong, nullable) UIImage *progress_thumbImage;             // 滑块图片, 无需设置滑块大小
@property (nonatomic, strong, nullable) UIColor *progress_thumbColor;             // 滑块颜色, 请设置滑块大小
@property (nonatomic) float progress_thumbSize;                                   // 滑块大小
@property (nonatomic, strong, nullable) NSString *liveText;                       // 实时直播
@property (nonatomic, strong, nullable) UIColor *bottomIndicator_trackColor;      // 底部指示条轨道颜色
@property (nonatomic, strong, nullable) UIColor *bottomIndicator_traceColor;      // 底部指示条轨迹颜色
@property (nonatomic) float bottomIndicator_height;                               // 底部指示条高度
    
// right adapter items
@property (nonatomic, strong, nullable) UIImage *filmEditingBtnImage;

// center adapter items
@property (nonatomic, strong, nullable) UIColor *replayBtnTitleColor;
@property (nonatomic, strong, nullable) NSString *replayBtnTitle;
@property (nonatomic, strong, nullable) UIImage *replayBtnImage;
@property (nonatomic, strong, nullable) UIFont *replayBtnFont;
//@end
//
//@interface SJVideoPlayerSettings (SJMoreSettingControlLayer)
@property (nonatomic, strong, nullable) UIColor *moreBackgroundColor; // more view background color
@property (nonatomic, strong, nullable) UIColor *more_traceColor;     // sider trace color of more view
@property (nonatomic, strong, nullable) UIColor *more_trackColor;     // sider track color of more view
@property (nonatomic) float more_trackHeight;                         // sider track height of more view
@property (nonatomic, strong, nullable) UIImage *more_thumbImage;     // sider thumb image of more view
@property (nonatomic) float more_thumbSize;                           // sider thumb size of more view
@property (nonatomic, strong, nullable) UIImage *more_minRateImage;
@property (nonatomic, strong, nullable) UIImage *more_maxRateImage;
@property (nonatomic, strong, nullable) UIImage *more_minVolumeImage;
@property (nonatomic, strong, nullable) UIImage *more_maxVolumeImage;
@property (nonatomic, strong, nullable) UIImage *more_minBrightnessImage;
@property (nonatomic, strong, nullable) UIImage *more_maxBrightnessImage;
//@end
//
//@interface SJVideoPlayerSettings (SJLoadFailedControlLayer)
@property (nonatomic, strong, nullable) NSString *playFailedText;
@property (nonatomic, strong, nullable) NSString *playFailedButtonText;
@property (nonatomic, strong, nullable) UIColor *playFailedButtonBackgroundColor;
//@end
//
//@interface SJVideoPlayerSettings (SJNotReachableControlLayer)
@property (nonatomic, strong, nullable) NSString *noNetworkPromptText;
@property (nonatomic, strong, nullable) NSString *noNetworkReloadButtonTitle;
@property (nonatomic, strong, nullable) UIColor *noNetworkButtonBackgroundColor;
//@end
//
//@interface SJVideoPlayerSettings (SJFloatSmallViewControlLayer)
@property (nonatomic, strong, nullable) UIImage *floatSmallViewCloseImage;
//@end
//
//@interface SJVideoPlayerSettings (SJFilmEditingControlLayer)
@property (nonatomic, strong, nullable) UIImage *screenshotBtnImage;
@property (nonatomic, strong, nullable) UIImage *exportBtnImage;
@property (nonatomic, strong, nullable) UIImage *gifBtnImage;
///
/// 左上角
///     - 取消按钮
///     - 完成按钮
@property (nonatomic, strong, nullable) NSString *cancelText;
@property (nonatomic, strong, nullable) NSString *doneText;
///
/// 录制时右侧按钮
///     - 等待中
///     - 可完成
@property (nonatomic, strong, nullable) NSString *waitingText;
@property (nonatomic, strong, nullable) UIImage *waitingImage;
@property (nonatomic, strong, nullable) NSString *finishText;
@property (nonatomic, strong, nullable) UIImage *finishImage;
///
/// 导出时
///     - 导出中
///     - 导出失败
///     - 导出成功
///     - 截屏成功
@property (nonatomic, strong, nullable) NSString *exportingText;
@property (nonatomic, strong, nullable) NSString *exportFailedText;
@property (nonatomic, strong, nullable) NSString *exportSucceededText;
@property (nonatomic, strong, nullable) NSString *screenshotSucceededText;
///
/// 保存至相册
///     - 保存失败, 相册访问权限未开启
///     - 正在保存
///     - 已保存至相册
@property (nonatomic, strong, nullable) NSString *albumAuthDeniedText;
@property (nonatomic, strong, nullable) NSString *savingToAlbumText;
@property (nonatomic, strong, nullable) NSString *savedToAlbumText;
///
/// 上传
///     - 上传中
///     - 上传成功
///     - 上传失败
@property (nonatomic, strong, nullable) NSString *uploadingText;
@property (nonatomic, strong, nullable) NSString *uploadFailedText;
@property (nonatomic, strong, nullable) NSString *uploadSucceededText;

@property (nonatomic, strong, nullable) NSString *operationFailedText;
@end

@implementation SJVideoPlayerSettings {
    dispatch_group_t _group;
}
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
    _group = dispatch_group_create();
    [self _asyncLoad];
    return self;
}

+ (void (^)(void (^ _Nonnull)(SJVideoPlayerSettings * _Nonnull)))update {
    return ^(void(^block)(SJVideoPlayerSettings *settings)) {
        SJVideoPlayerSettings *sources = SJVideoPlayerSettings.commonSettings;
        dispatch_group_notify(sources->_group, dispatch_get_global_queue(0, 0), ^{
            block(sources);
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSNotificationCenter.defaultCenter postNotificationName:SJVideoPlayerSettingsUpdatedNotification object:self];
            });
        });
    };
}

- (void)reset {
    [self _resetSJEdgeControlLayer];
    [self _resetSJMoreSettingControlLayer];
    [self _resetSJLoadFailedControlLayer];
    [self _resetSJNotReachableControlLayer];
    [self _resetSJFloatSmallViewControlLayer];
    [self _resetSJFilmEditingControlLayer];
}

- (void)_asyncLoad {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_t group = _group;
    dispatch_group_async(group, queue, ^{
        [self _resetSJEdgeControlLayer];
    });
    dispatch_group_async(group, queue, ^{
        [self _resetSJMoreSettingControlLayer];
    });
    dispatch_group_async(group, queue, ^{
        [self _resetSJLoadFailedControlLayer];
    });
    dispatch_group_async(group, queue, ^{
        [self _resetSJNotReachableControlLayer];
    });
    dispatch_group_async(group, queue, ^{
        [self _resetSJFloatSmallViewControlLayer];
    });
    dispatch_group_async(group, queue, ^{
        [self _resetSJFilmEditingControlLayer];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
       [NSNotificationCenter.defaultCenter postNotificationName:SJVideoPlayerSettingsUpdatedNotification object:self];
    });
}

- (void)_resetSJEdgeControlLayer {
    _fastForwardTriangleColor = UIColor.whiteColor;
    _fastForwardRateTextColor = UIColor.whiteColor;
    _fastForwardRateTextFont = [UIFont boldSystemFontOfSize:12];
    _fastForwardFFTextColor = UIColor.whiteColor;
    _fastForwardFFTextFont = [UIFont boldSystemFontOfSize:12];
    _fastForwardFFText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_FastForwardFFText];;
    
    _loadingNetworkSpeedTextColor = UIColor.whiteColor;
    _loadingNetworkSpeedTextFont = [UIFont systemFontOfSize:11];
    _loadingLineColor = UIColor.whiteColor;
    
    _fastImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_fast"];
    _forwardImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_forward"];
    
    _unstableNetworkPrompt = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_UnstableNetworkPromptText];
    _cellularNetworkPrompt = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_CellularNetworkPromptText];
    
    _statusBarNoNetworkText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_StatusBarNoNetworkText];
    _statusBarWiFiText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_StatusBarWiFiText];
    _statusBarCellularNetworkText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_StatusBarCellularNetworkText];
    _batteryBorderImage = [SJVideoPlayerResourceLoader imageNamed:@"battery_border"];
    _batteryNubImage = [SJVideoPlayerResourceLoader imageNamed:@"battery_nub"];
    _batteryLightningImage = [SJVideoPlayerResourceLoader imageNamed:@"battery_lightning"];

    _backBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_back"];
    _moreBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_more"];
    _titleFont = [UIFont boldSystemFontOfSize:14];
    _titleColor = [UIColor whiteColor];

    _lockBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_lock"];
    _unlockBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_unlock"];

    _pauseBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_pause"];
    _playBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_play"];
    _timeFont = [UIFont systemFontOfSize:11];
    _shrinkscreenImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_shrinkscreen"];
    _fullBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_fullscreen"];
    _liveText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_LiveText];

    _progress_trackColor =  [UIColor whiteColor];
    _progress_traceHeight = 3;
    _progress_traceColor = [UIColor colorWithRed:2 / 256.0 green:141 / 256.0 blue:140 / 256.0 alpha:1];
    _progress_bufferColor = [UIColor colorWithWhite:0 alpha:0.2];
    _progress_thumbColor = _progress_traceColor;
    
    _bottomIndicator_trackColor = _progress_trackColor;
    _bottomIndicator_traceColor = _progress_traceColor;
    _bottomIndicator_height = 1;
    
    _filmEditingBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_film_editing"];
    
    _replayBtnTitleColor = [UIColor whiteColor];
    _replayBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_replay"];
    _replayBtnTitle = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_ReplayButtonTitle];
    _replayBtnFont = [UIFont boldSystemFontOfSize:12];
}

- (void)_resetSJMoreSettingControlLayer {
    _moreBackgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    _more_traceColor = [UIColor colorWithRed:2 / 256.0 green:141 / 256.0 blue:140 / 256.0 alpha:1];
    _more_trackColor = [UIColor whiteColor];
    _more_trackHeight = 4;
    _more_minRateImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_minRate"];
    _more_maxRateImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_maxRate"];
    _more_minVolumeImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_minVolume"];
    _more_maxVolumeImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_maxVolume"];
    _more_minBrightnessImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_minBrightness"];
    _more_maxBrightnessImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_maxBrightness"];
}

- (void)_resetSJLoadFailedControlLayer {
    _playFailedText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_PlayFailedPromptText];
    _playFailedButtonText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_PlayFailedButtonTitle];
    _playFailedButtonBackgroundColor = [UIColor colorWithRed:36/255.0 green:171/255.0 blue:1 alpha:1];
}

- (void)_resetSJNotReachableControlLayer {
    _noNetworkPromptText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_NoNetworkPromptText];
    _noNetworkReloadButtonTitle = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_NoNetworkReloadButtonTitle];
    _noNetworkButtonBackgroundColor = [UIColor colorWithRed:36/255.0 green:171/255.0 blue:1 alpha:1];
}

- (void)_resetSJFloatSmallViewControlLayer {
    _floatSmallViewCloseImage = [SJVideoPlayerResourceLoader imageNamed:@"close"];
}

- (void)_resetSJFilmEditingControlLayer {
    _screenshotBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_screenshot"];
    _exportBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_export"];
    _gifBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_gif"];

    _cancelText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_CancelButtonTitle];
    _doneText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_DoneButtonTitle];
    
    _waitingImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_export_waiting"];
    _finishImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_export_finish"];

    _waitingText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_WaitingPromptText];
    _finishText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_FinishedPromptText];

    _exportingText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_ExportingPromptText];
    _exportFailedText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_ExportFailedPromptText];
    _exportSucceededText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_ExportSucceededPromptText];
    _screenshotSucceededText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_ScreenshotSucceededPromptText];

    _albumAuthDeniedText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_AlbumAuthDeniedPromptText];
    _savingToAlbumText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_SavingToAlbumPromptText];
    _savedToAlbumText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_SavedToAlbumPromptText];

    _uploadingText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_UplodingPromptText];
    _uploadFailedText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_UploadFailedPromptText];
    _uploadSucceededText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_UploadSucceededPromptText];

    _screenshotBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_screenshot"];
    _exportBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_export"];
    _gifBtnImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_video_player_gif"];

    _cancelText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_CancelButtonTitle];
    _doneText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_DoneButtonTitle];

    _waitingImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_export_waiting"];
    _waitingText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_WaitingPromptText];
    _finishImage = [SJVideoPlayerResourceLoader imageNamed:@"sj_export_finish"];
    _finishText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_FinishedPromptText];

    _exportingText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_ExportingPromptText];
    _exportFailedText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_ExportFailedPromptText];
    _exportSucceededText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_ExportSucceededPromptText];
    _screenshotSucceededText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_ScreenshotSucceededPromptText];
    
    _albumAuthDeniedText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_AlbumAuthDeniedPromptText];
    _savingToAlbumText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_SavingToAlbumPromptText];
    _savedToAlbumText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_SavedToAlbumPromptText];

    _uploadingText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_UplodingPromptText];
    _uploadFailedText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_UploadFailedPromptText];
    _uploadSucceededText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_UploadSucceededPromptText];
    
    _operationFailedText = [SJVideoPlayerResourceLoader localizedStringForKey:SJVideoPlayer_OperationFailedPromptText];
}
@end
NS_ASSUME_NONNULL_END
