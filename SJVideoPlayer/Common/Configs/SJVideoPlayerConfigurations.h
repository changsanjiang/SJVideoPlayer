//
//  SJVideoPlayerConfigurations.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/9/25.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerLocalizedStringKeys.h"
@class UIImage, UIColor, UIFont, SJVideoPlayerConfigurations;
@protocol SJVideoPlayerControlLayerResources, SJVideoPlayerLocalizedStrings;

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN NSNotificationName const SJVideoPlayerConfigurationsDidUpdateNotification;

@interface SJVideoPlayerConfigurations : NSObject
+ (instancetype)shared;
///
/// 更新
///
/// \code
///
///     SJVideoPlayerConfigurations.update(^(SJVideoPlayerConfigurations * _Nonnull configs) {
///         // 注意, 该block将在子线程执行
///         configs.resources.backImage = [UIImage imageNamed:@"icon_back"];
///     });
///
/// \endcode
///
@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(SJVideoPlayerConfigurations *configs));
 
@property (nonatomic, strong, null_resettable) id<SJVideoPlayerLocalizedStrings> localizedStrings;

@property (nonatomic, strong, null_resettable) id<SJVideoPlayerControlLayerResources> resources;
 
@property (nonatomic) NSTimeInterval animationDuration; // default value is 0.4

@end
  

@protocol SJVideoPlayerControlLayerResources <NSObject>

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


@protocol SJVideoPlayerLocalizedStrings <NSObject>

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
NS_ASSUME_NONNULL_END
