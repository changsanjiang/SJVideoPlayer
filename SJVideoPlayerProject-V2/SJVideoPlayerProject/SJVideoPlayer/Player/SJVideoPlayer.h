//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//
//  https://github.com/changsanjiang/SJVideoPlayer
//  changsanjiang@gmail.com
//

#import <UIKit/UIKit.h>
#import "SJVideoPlayerState.h"
#import "SJVideoPlayerPreviewInfo.h"
#import <SJPrompt/SJPrompt.h>
#import "SJVideoPlayerSettings.h"
#import "SJVideoPlayerMoreSetting.h"
#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import "SJVideoPlayerControlDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SJVideoPlayerControlDelegate, SJVideoPlayerControlDataSource;

@interface SJVideoPlayer : NSObject

+ (instancetype)sharedPlayer;   // 使用默认的控制层

+ (instancetype)player; // 使用默认的控制层

- (instancetype)init;   // 使用默认的控制层

- (instancetype)initWithControlViewDataSource:(id<SJVideoPlayerControlDataSource>)controlViewDataSource
                          controlViewDelegate:(id<SJVideoPlayerControlDelegate>)controlViewDelegate;    // 指定控制层

@property (nonatomic, weak, nullable) id <SJVideoPlayerControlDataSource> controlViewDataSource;

@property (nonatomic, weak, nullable) id <SJVideoPlayerControlDelegate> controlViewDelegate;

@property (nonatomic, strong, readonly) UIView *view;   // 播放器视图

@property (nonatomic, assign, readonly) SJVideoPlayerPlayState state;   // 播放状态

@property (nonatomic, strong, readonly, nullable) NSError *error;   // 播放报错的error

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

- (NSString *)timeStringWithSeconds:(NSInteger)secs; // format: 00:00:00

@property (nonatomic, readonly) float progress;

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval totalTime;

@property (nonatomic, strong, readonly) NSString *currentTimeStr;
@property (nonatomic, strong, readonly) NSString *totalTimeStr;

- (void)jumpedToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler; // unit is sec. 单位是秒.

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

@end


#pragma mark - 控制

@interface SJVideoPlayer (Control)

/*!
 *  The user clicked paused.
 *
 *  当调用`pause`, 会设置为`NO`. 调用`pauseForUser`, 会设置为`YES`.
 *  可以用来判断暂停状态是开发者暂停的, 还是用户暂停的.
 **/
@property (nonatomic, assign, readonly) BOOL userPaused;

- (void)pauseForUser; // 调用这个方法, 表示用户暂停.

@property (nonatomic, readwrite, getter=isLockedScreen) BOOL lockedScreen; // 锁定播放器. 所有交互事件将不会触发.

@property (nonatomic, readwrite, getter=isAutoPlay) BOOL autoPlay; // default is YES.

- (BOOL)play;

- (BOOL)pause; // 调用这个方法, 表示开发者暂停.

- (void)stop;

- (void)stopAndFadeOut; // 停止播放并淡出

- (void)replay;

@property (nonatomic, readwrite) float volume;
@property (nonatomic, readwrite) float brightness;
@property (nonatomic, readwrite) float rate; // 0.5...2
- (void)resetRate;
@property (nonatomic, copy, readwrite, nullable) void(^rateChanged)(SJVideoPlayer *player);

@property (nonatomic, copy, readwrite, nullable) void(^playDidToEnd)(SJVideoPlayer *player); // 播放完毕

@end


#pragma mark - 屏幕旋转

@interface SJVideoPlayer (Rotation)

- (void)rotation; // 旋转

@property (nonatomic, assign, readwrite) BOOL disableRotation; // 禁止播放器旋转

@property (nonatomic, copy, readwrite, nullable) void(^willRotateScreen)(SJVideoPlayer *player, BOOL isFullScreen); // 将要旋转的时候调用

@property (nonatomic, copy, readwrite, nullable) void(^rotatedScreen)(SJVideoPlayer *player, BOOL isFullScreen);    // 已旋转

@property (nonatomic, assign, readonly) BOOL isFullScreen;  // 是否全屏

@end


#pragma mark - 控制视图

@interface SJVideoPlayer (ControlView)

/*!
 *  Call when the control view is hidden or displayed.
 *
 *  控制视图隐藏或显示的时候调用.
 **/
@property (nonatomic, copy, readwrite, nullable) void(^controlViewDisplayStatus)(SJVideoPlayer *player, BOOL displayed);

@property (nonatomic, assign, readonly) BOOL controlViewDisplayed; // 控制视图是否显示

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


#pragma mark - 配置

@interface SJVideoPlayer (Setting)

/*!
 *  clicked back btn exe block.
 *
 *  点击`返回`按钮的回调.
 */
@property (nonatomic, copy, readwrite) void(^clickedBackEvent)(SJVideoPlayer *player);

/*!
 *  Configure the player, Note: This `block` is run on the child thread.
 *
 *  配置播放器, 注意: 这个`block`在子线程运行.
 *
 *  SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {
        ..... setting player ......
        commonSettings.placeholder = [UIImage imageNamed:@"placeholder"];
        commonSettings.more_trackColor = [UIColor whiteColor];
        commonSettings.progress_trackColor = [UIColor colorWithWhite:0.4 alpha:1];
        commonSettings.progress_bufferColor = [UIColor whiteColor];
    });
 **/
@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(SJVideoPlayerSettings *commonSettings));
+ (void)resetSetting; // 重置配置, 恢复默认设置

/*!
 *  clicked More button to display items.
 *
 *  点击`更多(右上角的三个点)`按钮, 弹出来的选项.
 **/
@property (nonatomic, strong, readwrite, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

/*!
 *  default is YES.
 *
 *  是否自动生成预览视图, 默认是 YES. 如果为NO, 则预览按钮将不会显示.
 */
@property (nonatomic, assign, readwrite) BOOL generatePreviewImages;

@end


#pragma mark - 在`tableView`或`collectionView`上播放

@interface SJVideoPlayer (ScrollView)

@property (nonatomic, assign, readonly)  BOOL playOnCell;

@end

#pragma mark - 提示

@interface SJVideoPlayer (Prompt)

/*!
 *  prompt.update(^(SJPromptConfig * _Nonnull config) {
        config.cornerRadius = 4;                    // default cornerRadius.
        config.font = [UIFont systemFontOfSize:12]; // default font.
    });
 *
 **/
@property (nonatomic, strong, readonly) SJPrompt *prompt;

- (void)showTitle:(NSString *)title; // duration default is 1.0

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration; // duration if value set -1, promptView will always show.

- (void)hiddenTitle;

@end

NS_ASSUME_NONNULL_END
