//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//
//  https://github.com/changsanjiang/SJVideoPlayer
//  changsanjiang@gmail.com
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SJVideoPlayerState.h"
#import <SJVideoPlayerAssetCarrier/SJVideoPlayerAssetCarrier.h>
#import "SJVideoPlayerMoreSettingSecondary.h"
#import "SJVideoPlayerSettings.h"
#import <SJPrompt/SJPrompt.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayer : NSObject

+ (instancetype)sharedPlayer;

+ (instancetype)player;

- (instancetype)init;

/*!
 *  present View. support autoLayout.
 *
 *  播放器视图
 */
@property (nonatomic, strong, readonly) UIView *view;

/*!
 *  error. support observe. default is nil.
 *
 *  播放报错, 如果需要, 可以使用观察者, 来观察他的改变.
 */
@property (nonatomic, strong, readonly, nullable) NSError *error;

/*!
 *  play status
 *
 *  播放状态
 **/
@property (nonatomic, assign, readonly) SJVideoPlayerPlayState state;

@end


#pragma mark - 播放

@interface SJVideoPlayer (Play)

/*!
 *  Create It By Video URL.
 *
 *  创建一个播放资源.
 *  如果在 `tableView` 或者 `collectionView` 中播放, 使用它来初始化播放资源.
 *  它也可以直接从某个时刻开始播放. 单位是秒.
 **/
@property (nonatomic, strong, readwrite, nullable) SJVideoPlayerAssetCarrier *asset;

/*!
 *  unit: sec.
 *
 *  单位是秒.
 **/
- (void)playWithURL:(NSURL *)playURL jumpedToTime:(NSTimeInterval)time;

/*!
 *  Video URL
 */
@property (nonatomic, strong, readwrite, nullable) NSURL *assetURL;

/*!
 *  Video URL
 **/
- (void)playWithURL:(NSURL *)playURL;

/*!
 *  获取当前截图
 **/
- (UIImage *__nullable)screenshot;

/*!
 *  unit sec.
 *
 *  当前播放时间.
 */
- (NSTimeInterval)currentTime;

/*!
 *  unit sec.
 *
 *  当前视频的全部播放时间.
 **/
- (NSTimeInterval)totalTime;

@end


#pragma mark - 控制

@interface SJVideoPlayer (Control)

/*!
 *  The user clicked paused.
 *
 *  这个状态用来判断是我们调用的pause, 还是用户主动pause的.
 *  用户点击暂停或者双击暂停时, 会设置它. 当我们(开发者)调用`pause`, 不会设置它.
 *  当返回播放界面时, 如果是我们自己调用`pause`, 则可以使用`play`, 使其继续播放.
 **/
@property (nonatomic, assign, readonly) BOOL userPaused;

/*!
 *  default is YES.
 *
 *  是否自动播放, 默认是 YES.
 */
@property (nonatomic, assign, readwrite, getter=isAutoplay) BOOL autoplay;

- (BOOL)play;

- (BOOL)pause;

- (void)stop;

/// 停止播放并淡出
- (void)stopAndFadeOut;

/*!
 *  播放完毕的时候调用.
 **/
@property (nonatomic, copy, readwrite, nullable) void(^playDidToEnd)(SJVideoPlayer *player);

/*!
 *  停止旋转.
 *
 *  相当于 `player.disableRotation = YES;` .
 **/
- (void)stopRotation;

/*!
 *  开启旋转.
 *
 *  相当于 `player.disableRotation = NO;` .
 **/
- (void)enableRotation;

/*!
 *  跳转到指定位置, 不建议使用
 *  如果要跳转到某个位置, 可以在初始化时, 设置`SJVideoPlayerAssetCarrier`的`beginTime`.
 **/
- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

@end


#pragma mark - 配置

@interface SJVideoPlayer (Setting)

/*!
 *  loading show this.
 *
 *  `占位图`. 初始化播放loading的时候显示.
 **/
- (void)setPlaceholder:(UIImage *)placeholder;

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
 *    SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {
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


#pragma mark - 调速

@interface SJVideoPlayer (Rate)

@property (nonatomic, assign, readwrite) float rate; /// 0.5 .. 1.5
- (void)resetRate;

/*!
 *  Call when the rate changes.
 *
 *  调速时调用.
 **/
@property (nonatomic, copy, readwrite, nullable) void(^rateChanged)(SJVideoPlayer *player);

/*!
 *  Call when the rate changes.
 *
 *  调速时调用.
 *  当滑动内部的`rate slider`时候调用. 外部改变`rate`不会调用.
 **/
@property (nonatomic, copy, readwrite, nullable) void(^internallyChangedRate)(SJVideoPlayer *player, float rate);

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
@property (nonatomic, copy, readwrite, nullable) void(^willRotateScreen)(SJVideoPlayer *player, BOOL isFullScreen);
@property (nonatomic, copy, readwrite, nullable) void(^rotatedScreen)(SJVideoPlayer *player, BOOL isFullScreen);
@property (nonatomic, assign, readonly) BOOL isFullScreen; //  是否全屏

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


#pragma mark - 提示

@interface SJVideoPlayer (Prompt)

@property (nonatomic, strong, readonly) SJPrompt *prompt;

/*!
 *  duration default is 1.0
 */
- (void)showTitle:(NSString *)title;

/*!
 *  duration if value set -1, promptView will always show.
 */
- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration;

- (void)hiddenTitle;

@end

NS_ASSUME_NONNULL_END
