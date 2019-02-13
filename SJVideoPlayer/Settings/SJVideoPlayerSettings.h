//
//  SJVideoPlayerSettings.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIImage, UIColor, UIFont;

@interface SJVideoPlayerSettings : NSObject

/// shared
+ (instancetype)commonSettings;

@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(SJVideoPlayerSettings *commonSettings));

- (void)reset;

@end


@interface SJVideoPlayerSettings (EdgeControlLayer)

@property (class, nonatomic, copy, readonly) void(^updateEdgeControlLayer)(void(^block)(SJVideoPlayerSettings *settings));
- (void)resetEdgeControlLayer;

#pragma mark loading
@property (nonatomic, strong, nullable) UIImage *placeholder;
@property (nonatomic, strong) UIColor *loadingLineColor; // default is white.
@property (nonatomic, strong) UIImage *fastImage;
@property (nonatomic, strong) UIImage *forwardImage;


#pragma mark network
@property (nonatomic, strong, readonly) NSString *notReachablePrompt;
@property (nonatomic, strong, readonly) NSString *reachableViaWWANPrompt;


#pragma mark top
@property (nonatomic, strong) UIImage *backBtnImage;
@property (nonatomic, strong, nullable) UIImage *previewBtnImage;
@property (nonatomic, strong) UIFont *previewBtnFont;        // default is [UIFont boldSystemFontOfSize:12].
@property (nonatomic, strong, readonly) NSString *previewBtnTitle;
@property (nonatomic, strong) UIImage *moreBtnImage;
@property (nonatomic, strong) UIFont *titleFont;   // video title font, default is [UIFont boldSystemFontOfSize:14]
@property (nonatomic, strong) UIColor *titleColor; // video title color, default is [UIColor whiteColor]


#pragma mark left
@property (nonatomic, strong) UIImage *lockBtnImage;
@property (nonatomic, strong) UIImage *unlockBtnImage;


#pragma mark bottom
@property (nonatomic, strong) UIImage *playBtnImage;
@property (nonatomic, strong) UIImage *pauseBtnImage;
@property (nonatomic, assign) float progress_traceHeight;               // 轨道高度
@property (nonatomic, strong) UIColor *progress_traceColor;             // 轨迹, 走过的痕迹
@property (nonatomic, strong) UIColor *progress_trackColor;             // 轨道
@property (nonatomic, strong) UIColor *progress_bufferColor;            // 缓冲颜色
@property (nonatomic, strong, nullable) UIImage *progress_thumbImage;
@property (nonatomic, assign) float progress_thumbSize;                 // default is 0.
@property (nonatomic, strong, nullable) UIColor *progress_thumbColor;
@property (nonatomic, strong) UIImage *fullBtnImage;
@property (nonatomic, strong, nullable) UIImage *shrinkscreenImage;


#pragma mark right
@property (nonatomic, strong) UIImage *filmEditingBtnImage;


#pragma mark center
@property (nonatomic, strong, readonly) NSString *replayBtnTitle;
@property (nonatomic, strong) UIImage *replayBtnImage;       // default is `sj_video_player_replay`.
@property (nonatomic, strong) UIFont *replayBtnFont;         // default is [UIFont boldSystemFontOfSize:12].
@property (nonatomic, strong) UIColor *replayBtnTitleColor;  // default is white.

#pragma mark more
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


// - deprecated properties

@property (nonatomic, strong, readonly) NSString *playFailedBtnTitle __deprecated;
@property (nonatomic, strong, nullable) UIImage *playFailedBtnImage __deprecated;
@property (nonatomic, strong) UIFont *playFailedBtnFont __deprecated;
@property (nonatomic, strong) UIColor *playFailedBtnTitleColor __deprecated;
@end
NS_ASSUME_NONNULL_END
