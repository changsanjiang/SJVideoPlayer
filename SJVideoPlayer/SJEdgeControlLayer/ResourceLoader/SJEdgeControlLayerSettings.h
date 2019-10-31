//
//  SJEdgeControlLayerSettings.h
//  SJEdgeControlLayer_Example
//
//  Created by 畅三江 on 2018/6/2.
//  Copyright © 2018年 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
extern NSNotificationName const SJSettingsPlayerNotification;

@interface SJEdgeControlLayerSettings : NSObject
/// shared
+ (instancetype)commonSettings;

@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(SJEdgeControlLayerSettings *settings));

- (void)reset;
- (void)postUpdateNotify;

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


// - deprecated properties -
@property (nonatomic, strong, readonly) NSString *playFailedBtnTitle __deprecated;
@property (nonatomic, strong, nullable) UIImage *playFailedBtnImage __deprecated;
@property (nonatomic, strong) UIFont *playFailedBtnFont __deprecated;
@property (nonatomic, strong) UIColor *playFailedBtnTitleColor __deprecated;
@property (nonatomic, strong, nullable) UIImage *previewBtnImage __deprecated;
@property (nonatomic, strong) UIFont *previewBtnFont __deprecated;
@property (nonatomic, strong, readonly) NSString *previewBtnTitle __deprecated;
@end
NS_ASSUME_NONNULL_END
