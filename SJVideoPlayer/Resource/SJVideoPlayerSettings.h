//
//  SJVideoPlayerSettings.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const SJSettingsPlayerNotification;

@class UIImage, UIColor, UIFont;

@interface SJVideoPlayerSettings : NSObject

/// shared
+ (instancetype)commonSettings;

- (void)reset;

#pragma mark - film editing
@property (nonatomic, strong, readonly) NSString *videoPlayDidToEndText;
@property (nonatomic, strong, readonly) NSString *cancelBtnTitle;
@property (nonatomic, strong, readonly) NSString *waitingForRecordingPromptText;
@property (nonatomic, strong, readonly) NSString *recordPromptText;
@property (nonatomic, strong, readonly) NSString *uploadingPrompt;
@property (nonatomic, strong, readonly) NSString *uploadSuccessfullyPrompt;
@property (nonatomic, strong, readonly) NSString *exportingPrompt;
@property (nonatomic, strong, readonly) NSString *exportSuccessfullyPrompt;
@property (nonatomic, strong, readonly) NSString *operationFailedPrompt;

@property (nonatomic, strong, readwrite) UIImage *screenshotBtnImage;
@property (nonatomic, strong, readwrite) UIImage *exportBtnImage;
@property (nonatomic, strong, readwrite) UIImage *gifBtnImage;
@property (nonatomic, strong, readwrite) UIImage *recordEndBtnImage;



#pragma mark - network
@property (nonatomic, strong, readonly) NSString *notReachablePrompt;
@property (nonatomic, strong, readonly) NSString *reachableViaWWANPrompt;


@property (nonatomic, strong, readonly) NSString *previewBtnTitle;
@property (nonatomic, strong, readwrite, nullable) UIImage *previewBtnImage;
@property (nonatomic, strong, readwrite) UIFont *previewBtnFont;        // default is [UIFont boldSystemFontOfSize:12].

@property (nonatomic, strong, readonly) NSString *replayBtnTitle;
@property (nonatomic, strong, readwrite) UIImage *replayBtnImage;       // default is `sj_video_player_replay`.
@property (nonatomic, strong, readwrite) UIFont *replayBtnFont;         // default is [UIFont boldSystemFontOfSize:12].
@property (nonatomic, strong, readwrite) UIColor *replayBtnTitleColor;  // default is white.


@property (nonatomic, strong, readonly) NSString *playFailedBtnTitle;
@property (nonatomic, strong, readwrite, nullable) UIImage *playFailedBtnImage;     // default is nil.
@property (nonatomic, strong, readwrite) UIFont *playFailedBtnFont;                 // default is [UIFont boldSystemFontOfSize:12].
@property (nonatomic, strong, readwrite) UIColor *playFailedBtnTitleColor;          // default is white.

#pragma mark - title
@property (nonatomic, strong, readwrite) UIFont *titleFont;   // video title font, default is [UIFont boldSystemFontOfSize:14]
@property (nonatomic, strong, readwrite) UIColor *titleColor; // video title color, default is [UIColor whiteColor]


#pragma mark - placeholder
@property (nonatomic, strong, readwrite, nullable) UIImage *placeholder;

#pragma mark - loading
@property (nonatomic, strong, readwrite) UIColor *loadingLineColor; // default is white.


#pragma mark - fast/forward
@property (nonatomic, strong, readwrite) UIImage *fastImage;
@property (nonatomic, strong, readwrite) UIImage *forwardImage;


#pragma mark - btns
@property (nonatomic, strong, readwrite) UIImage *backBtnImage;
@property (nonatomic, strong, readwrite) UIImage *playBtnImage;
@property (nonatomic, strong, readwrite) UIImage *pauseBtnImage;
@property (nonatomic, strong, readwrite) UIImage *fullBtnImage;
@property (nonatomic, strong, readwrite) UIImage *shrinkscreenImage;
@property (nonatomic, strong, readwrite) UIImage *moreBtnImage;
@property (nonatomic, strong, readwrite) UIImage *lockBtnImage;
@property (nonatomic, strong, readwrite) UIImage *unlockBtnImage;
@property (nonatomic, strong, readwrite) UIImage *filmEditingBtnImage;


#pragma mark - progress slider
/// 轨迹, 走过的痕迹
@property (nonatomic, strong, readwrite) UIColor *progress_traceColor;
/// 轨道
@property (nonatomic, strong, readwrite) UIColor *progress_trackColor;
/**
 Thumb image, also can set `progress_thumbSize `. (image is preferred)
 拇指图片, 也可设置`progress_thumbSize`.(图片优先)
 */
@property (nonatomic, strong, readwrite, nullable) UIImage *progress_thumbImage;
/// 拇指大小, 也可设置`progress_thumbImage`.
@property (nonatomic, assign, readwrite) float progress_thumbSize; // default is 0.
@property (nonatomic, strong, readwrite, nullable) UIColor *progress_thumbColor;
/// 缓冲颜色
@property (nonatomic, strong, readwrite) UIColor *progress_bufferColor;
/// 轨道高度
@property (nonatomic, assign, readwrite) float progress_traceHeight;


#pragma mark - more view
@property (nonatomic, strong, readwrite) UIColor *moreBackgroundColor;
/// 轨迹
@property (nonatomic, strong, readwrite) UIColor *more_traceColor;
/// 轨道
@property (nonatomic, strong, readwrite) UIColor *more_trackColor;
/// 轨道高度
@property (nonatomic, assign, readwrite) float more_trackHeight;


/**
 Thumb image, also can set `more_thumbSize `. (image is preferred)
 拇指图片, 也可设置`more_thumbSize`.(图片优先).
 */
@property (nonatomic, strong, readwrite, nullable) UIImage *more_thumbImage;
@property (nonatomic, assign, readwrite) float more_thumbSize; // default is 0.
@property (nonatomic, strong, readwrite) UIImage *more_minRateImage;
@property (nonatomic, strong, readwrite) UIImage *more_maxRateImage;
@property (nonatomic, strong, readwrite) UIImage *more_minVolumeImage;
@property (nonatomic, strong, readwrite) UIImage *more_maxVolumeImage;
@property (nonatomic, strong, readwrite) UIImage *more_minBrightnessImage;
@property (nonatomic, strong, readwrite) UIImage *more_maxBrightnessImage;

@end
NS_ASSUME_NONNULL_END
