//
//  SJVideoPlayerSettings.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/9/25.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage, UIColor, UIFont;

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerSettings : NSObject
/// shared
+ (instancetype)commonSettings;

@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(SJVideoPlayerSettings *commonSettings));
- (void)reset;
@end

@interface SJVideoPlayerSettings (SJEdgeControlLayer)
// - Loading -
@property (nonatomic, strong, nullable) UIImage *placeholder;
@property (nonatomic, strong) UIColor *loadingLineColor; // default is white.
@property (nonatomic, strong) UIColor *loadingNetworkSpeedTextColor;
@property (nonatomic, strong) UIFont *loadingNetworkSpeedTextFont;

// - Dragging view -
@property (nonatomic, strong) UIImage *fastImage;
@property (nonatomic, strong) UIImage *forwardImage;

// - Network -
@property (nonatomic, strong, readonly) NSString *notReachablePrompt;
@property (nonatomic, strong, readonly) NSString *reachableViaWWANPrompt;

// - Top Adapter Item -
@property (nonatomic, strong) UIImage *backBtnImage;
@property (nonatomic, strong) UIImage *moreBtnImage;
@property (nonatomic, strong) UIFont *titleFont;   // video title font, default is [UIFont boldSystemFontOfSize:14]
@property (nonatomic, strong) UIColor *titleColor; // video title color, default is [UIColor whiteColor]

// - Left Adapter Item -
@property (nonatomic, strong) UIImage *lockBtnImage;
@property (nonatomic, strong) UIImage *unlockBtnImage;


// - Bootom Adapter Item -
@property (nonatomic, strong) UIImage *playBtnImage;
@property (nonatomic, strong) UIImage *pauseBtnImage;
@property (nonatomic, assign) float progress_traceHeight;               // 轨道高度
@property (nonatomic, strong) UIColor *progress_traceColor;             // 轨迹, 走过的痕迹
@property (nonatomic, strong) UIColor *progress_trackColor;             // 轨道
@property (nonatomic, strong) UIColor *progress_bufferColor;            // 缓冲颜色
@property (nonatomic, strong) UIColor *progress_loadingColor;           // 缓冲为空, 加载时的颜色
@property (nonatomic, strong, nullable) UIImage *progress_thumbImage;
@property (nonatomic, assign) float progress_thumbSize;                 // default is 0.
@property (nonatomic, strong, nullable) UIColor *progress_thumbColor;
@property (nonatomic, strong) UIImage *fullBtnImage;
@property (nonatomic, strong, nullable) UIImage *shrinkscreenImage;
@property (nonatomic, strong) NSString *liveText;                       // 实时直播

@property (nonatomic, strong, nullable) UIColor *bottomIndicator_traceColor;
@property (nonatomic, strong, nullable) UIColor *bottomIndicator_trackColor;

// - Right Adapter Item -
@property (nonatomic, strong) UIImage *filmEditingBtnImage;


// - Center Adapter Item -
@property (nonatomic, strong, readonly) NSString *replayBtnTitle;
@property (nonatomic, strong) UIImage *replayBtnImage;       // default is `sj_video_player_replay`.
@property (nonatomic, strong) UIFont *replayBtnFont;         // default is [UIFont boldSystemFontOfSize:12].
@property (nonatomic, strong) UIColor *replayBtnTitleColor;  // default is white.


// - SJMoreSettingControlLayer -
@property (nonatomic, strong) UIColor *moreBackgroundColor; // more view background color
@property (nonatomic, strong) UIColor *more_traceColor;     // sider trace color of more view
@property (nonatomic, strong) UIColor *more_trackColor;     // sider track color of more view
@property (nonatomic, assign) float more_trackHeight;       // sider track height of more view
@property (nonatomic, strong, nullable) UIImage *more_thumbImage;  // sider thumb image of more view
@property (nonatomic, assign) float more_thumbSize; // default is 0. // sider thumb size of more view
@property (nonatomic, strong) UIImage *more_minRateImage;
@property (nonatomic, strong) UIImage *more_maxRateImage;
@property (nonatomic, strong) UIImage *more_minVolumeImage;
@property (nonatomic, strong) UIImage *more_maxVolumeImage;
@property (nonatomic, strong) UIImage *more_minBrightnessImage;
@property (nonatomic, strong) UIImage *more_maxBrightnessImage;


// - SJLoadFailedControlLayer -
@property (nonatomic, strong) NSString *playFailedText;
@property (nonatomic, strong) NSString *playFailedButtonText;
@property (nonatomic, strong) UIColor *playFailedButtonBackgroundColor;


// - SJNotReachableControlLayer -
@property (nonatomic, strong) NSString *notReachableAndPlaybackStalledText;
@property (nonatomic, strong) NSString *notReachableAndPlaybackStalledButtonText;
@property (nonatomic, strong) UIColor *notReachableAndPlaybackStalledButtonBackgroundColor;


// SJFloatSmallViewControlLayer
@property (nonatomic, strong) UIImage *floatSmallViewCloseImage;
@end


@interface SJVideoPlayerSettings (SJFilmEditingControlLayer)
@property (nonatomic, strong) UIImage *screenshotBtnImage;
@property (nonatomic, strong) UIImage *exportBtnImage;
@property (nonatomic, strong) UIImage *gifBtnImage;

/**
 top btn
 左上角按钮
 - 取消
 - 完成
 */
@property (nonatomic, strong) NSString *cancelText;
@property (nonatomic, strong) NSString *doneText;

/**
 录制时右侧按钮
 - 等待中
 - 可完成
 */
@property (nonatomic, strong) UIImage *waitingImage;
@property (nonatomic, strong) UIImage *finishImage;
@property (nonatomic, strong) NSString *waitingText;
@property (nonatomic, strong) NSString *finishText;

/**
 export
 导出
 - 导出中
 - 导出失败
 - 导出成功
 - 录制成功
 - 截屏成功
 */
@property (nonatomic, strong) NSString *exportingText;
@property (nonatomic, strong) NSString *exportFailedText;
@property (nonatomic, strong) NSString *exportSuccessText;
@property (nonatomic, strong) NSString *screenshotSuccessText;

/**
 album
 保存至相册
 - 已保存至相册
 - 保存失败, 相册访问权限未开启
 */
@property (nonatomic, strong) NSString *albumAuthDeniedText;
@property (nonatomic, strong) NSString *savingToAlbumText;
@property (nonatomic, strong) NSString *saveToAlbumSuccessText;

/**
 upload
 上传
 - 上传中
 - 上传成功
 - 上传失败
 */
@property (nonatomic, strong) NSString *uploadingText;
@property (nonatomic, strong) NSString *uploadFailedText;
@property (nonatomic, strong) NSString *uploadSuccessText;
@end
NS_ASSUME_NONNULL_END
