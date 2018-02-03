//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerURLAsset.h"
#import "SJVideoPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SJVideoPlayerControlDelegate, SJVideoPlayerControlDataSource;

@interface SJVideoPlayer : NSObject

+ (instancetype)player;

- (instancetype)init;

@property (nonatomic, weak, nullable) id <SJVideoPlayerControlDataSource> controlViewDataSource;

@property (nonatomic, weak, nullable) id <SJVideoPlayerControlDelegate> controlViewDelegate;

@property (nonatomic, strong, readonly) UIView *view;

@property (nonatomic, assign, readonly) SJVideoPlayerPlayState state;

@property (nonatomic, strong, readonly, nullable) NSError *error;

@property (nonatomic, strong, nullable) UIImage *placeholder;       // 占位图

@end


#pragma mark - DataSource

@protocol SJVideoPlayerControlDataSource <NSObject>

@required
- (UIView *)controlView;

- (BOOL)controlLayerDisplayCondition;

@optional

@end


#pragma mark - Delegate

@protocol SJVideoPlayerControlDelegate <NSObject>

@optional

/**
 control layer want to display.

 @param videoPlayer `video player`.
 @param displayState `display or hidden`.
 */
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer controlLayerNeedChangeDisplayState:(BOOL)displayState;

/**
 play time did change.

 @param videoPlayer `video player`
 @param currentTimeStr `current time string.  formatter: 00:00 or 00:00:00`
 @param totalTimeStr `duration time string. formatter: 00:00 or 00:00:00`
 */
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer currentTimeStr:(NSString *)currentTimeStr totalTimeStr:(NSString *)totalTimeStr;

/**
 player view will rotate.

 @param videoPlayer `video player`
 @param isFull `small or full`
 */
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull;

/**
 view is locked. The player view will lose its response.

 @param videoPlayer `video player`
 @param isLocked `yes or no`
 */
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer lockStateDidChange:(BOOL)isLocked;

- (void)horizontalGestureWillBeginDragging:(SJVideoPlayer *)videoPlayer;
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer horizontalGestureDidDrag:(CGFloat)translation;
- (void)horizontalGestureDidEndDragging:(SJVideoPlayer *)videoPlayer;

@end


#pragma mark - 播放

@interface SJVideoPlayer (Play)

@property (nonatomic, strong, readwrite, nullable) NSURL *assetURL;

@property (nonatomic, strong, readwrite, nullable) SJVideoPlayerURLAsset *URLAsset;

- (void)playWithURL:(NSURL *)playURL;

- (void)playWithURL:(NSURL *)playURL jumpedToTime:(NSTimeInterval)time;

@end


#pragma mark - 时间

@interface SJVideoPlayer (Time)

- (NSString *)timeStringWithSeconds:(NSInteger)secs;

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval totalTime;

@property (nonatomic, strong, readonly) NSString *currentTimeStr;
@property (nonatomic, strong, readonly) NSString *totalTimeStr;

- (void)jumpedToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler; // unit is sec. 单位是秒.

@end


#pragma mark - 播放控制

@interface SJVideoPlayer (Control)

/// 锁定播放器. 所有交互事件将不会触发.
@property (nonatomic, assign, readwrite, getter=isLocked) BOOL locked;

@property (nonatomic, assign, readwrite, getter=isAutoPlay) BOOL autoPlay; // default is YES.

- (BOOL)play;

- (BOOL)pause;

- (void)stop;

- (void)replay;

@end


#pragma mark - 屏幕旋转

@interface SJVideoPlayer (Rotation)

/*!
 *  Whether screen rotation is disabled. default is NO.
 *
 *  是否禁用屏幕旋转, 默认是NO.
 */
@property (nonatomic, assign, readwrite) BOOL disableRotation;

/*!
 *  Call when the screen is rotated.
 *
 *  屏幕旋转的时候调用.
 **/
@property (nonatomic, copy, readwrite, nullable) void(^willRotateScreen)(SJVideoPlayer *player, BOOL isFullScreen); // 将要旋转

@property (nonatomic, copy, readwrite, nullable) void(^rotatedScreen)(SJVideoPlayer *player, BOOL isFullScreen); // 已旋转

@property (nonatomic, assign, readonly) BOOL isFullScreen;

/// 旋转
- (void)rotation;

@end


#pragma mark - 截图

@interface SJVideoPlayer (Screenshot)

- (UIImage * __nullable)screenshot;

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(SJVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block;

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(SJVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block;

@end


NS_ASSUME_NONNULL_END
