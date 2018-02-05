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
#import "SJVideoPlayerPreviewInfo.h"

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

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

@end


#pragma mark - 控制

@interface SJVideoPlayer (Control)

/// 锁定播放器. 所有交互事件将不会触发.
@property (nonatomic, readwrite, getter=isLocked) BOOL locked;

@property (nonatomic, readwrite, getter=isAutoPlay) BOOL autoPlay; // default is YES.

- (BOOL)play;

- (BOOL)pause;

- (void)stop;

- (void)replay;

@property (nonatomic, readwrite) float volume;
@property (nonatomic, readwrite) float brightness;
@property (nonatomic, readwrite) float rate;
- (void)resetRate;

@end


#pragma mark - 屏幕旋转

@interface SJVideoPlayer (Rotation)

/// 旋转
- (void)rotation;

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

@end


#pragma mark - 截图

@interface SJVideoPlayer (Screenshot)

@property (nonatomic, copy, readwrite, nullable) void(^presentationSize)(SJVideoPlayer *videoPlayer, CGSize size);

- (UIImage * __nullable)screenshot;

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(SJVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block;

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(SJVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block;

- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(SJVideoPlayer *player, NSArray<id<SJVideoPlayerPreviewInfo>> *__nullable images, NSError *__nullable error))block;

@end


#pragma mark - DataSource

@protocol SJVideoPlayerControlDataSource <NSObject>

@required

@property (nonatomic, assign) BOOL controlLayerAppearedState; // 控制层的显示状态, `YES`表示已经显示.

- (UIView *)controlView;

- (BOOL)controlLayerAppearCondition; // 控制层将要显示之前会调用这个方法, 如果返回NO, 将不调用`controlLayerNeedAppear:`

- (BOOL)controlLayerDisappearCondition; // 控制层将要隐藏之前会调用这个方法, 如果返回NO, 将不调用`controlLayerNeedDisappear:`

- (BOOL)triggerGesturesCondition:(CGPoint)location; // 触发手势之前会调用这个方法, 如果返回NO, 将不调用手势相关的代理方法.

@optional

@end


#pragma mark - Delegate

@protocol SJVideoPlayerControlDelegate <NSObject>

@optional

- (void)controlLayerNeedAppear:(SJVideoPlayer *)videoPlayer;        // 控制层需要显示

- (void)controlLayerNeedDisappear:(SJVideoPlayer *)videoPlayer;     // 控制层需要隐藏

- (void)lockedVideoPlayer:(SJVideoPlayer *)videoPlayer;             // 播放器被锁屏, 此时将会不旋转, 不会触发手势相关事件

- (void)unlockedVideoPlayer:(SJVideoPlayer *)videoPlayer;           // 播放器被解锁

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer
        currentTime:(NSTimeInterval)currentTime currentTimeStr:(NSString *)currentTimeStr
          totalTime:(NSTimeInterval)totalTime totalTimeStr:(NSString *)totalTimeStr;

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer loadedTimeProgress:(float)progress; // 缓冲的进度

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull;   // 播放器将要旋转屏幕, `isFull`如果为`YES`, 则全屏

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer volumeChanged:(float)volume;   // 声音被改变

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer brightnessChanged:(float)brightness;   // 亮度被改变

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer rateChanged:(float)rate;   // 播放速度被改变

- (void)horizontalDirectionWillBeginDragging:(SJVideoPlayer *)videoPlayer;    // 水平方向开始拖动

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer horizontalDirectionDidDrag:(CGFloat)translation; // 水平方向拖动中

- (void)horizontalDirectionDidEndDragging:(SJVideoPlayer *)videoPlayer;   // 水平方向拖动结束

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer presentationSize:(CGSize)size;

@end


NS_ASSUME_NONNULL_END
