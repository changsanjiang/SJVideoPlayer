//
//  SJBaseVideoPlayer.h
//  SJBaseVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//
//  The base player, without the control layer, can be used if you need a custom control layer.
//  https://github.com/changsanjiang/SJBaseVideoPlayer
//
//  Player with default control layer.
//  https://github.com/changsanjiang/SJVideoPlayer
//
//  If you have suggestions or bugs, please contact me
//  如有建议或Bug, 还请联系我

//  Email:  changsanjiang@gmail.com
//  QQ:     1779609779
//

/**
 ------------------------
 *  Play
 *  Network
 *  Prompt
 *  Time
 *  Control
 *  GestureControl
 *  ControlLayer
 *  Rotation
 *  Screenshot
 *  Export
 *  ScrollView
 *  ControlLayerProtocol
 -------------------------
 */

#import <UIKit/UIKit.h>
#import "SJVideoPlayerURLAsset.h"
#import "SJVideoPlayerState.h"
#import "SJVideoPlayerPreviewInfo.h"
#import <SJPrompt/SJPrompt.h>
#import <SJOrentationObserver/SJOrentationObserver.h>
#import "SJVideoPlayerControlLayerProtocol.h"

NS_ASSUME_NONNULL_BEGIN
/**
 This enumeration lists some of the gesture types that the player has by default.
 When you don't want to use one of these gestures, you can set it like this:
 
 这个枚举列出了播放器默认拥有的一些手势类型, 当你不想使用其中某个手势时, 可以像下面这样设置:
 _videoPlayer.disableGestureTypes = SJDisablePlayerGestureTypes_SingleTap | SJDisablePlayerGestureTypes_DoubleTap | ...;
 */
typedef NS_ENUM(NSUInteger, SJDisablePlayerGestureTypes) {
    SJDisablePlayerGestureTypes_None,
    SJDisablePlayerGestureTypes_SingleTap = 1 << 0,
    SJDisablePlayerGestureTypes_DoubleTap = 1 << 1,
    SJDisablePlayerGestureTypes_Pan = 1 << 2,
    SJDisablePlayerGestureTypes_Pinch = 1 << 3,
    SJDisablePlayerGestureTypes_All = 1 << 4
};


@interface SJBaseVideoPlayer : NSObject

+ (instancetype)player;

- (instancetype)init;

/**
 This is the player view. you can use it to present video.
 这个是播放器视图, 你可以用它去呈现视频.
 
 readonly.
 */
@property (nonatomic, strong, readonly) UIView *view;

/**
 This is a data source object for the control layer.
 It must implement the methods defined in the SJVideoPlayerControlLayerDataSource protocol.
 The data source is not retained.
 
 这个是关于控制层的数据源对象, 它必须实现 SJVideoPlayerControlLayerDataSource 协议里面定义的方法.
 
 weak. readwrite.
 */
@property (nonatomic, weak, nullable) id <SJVideoPlayerControlLayerDataSource> controlLayerDataSource;

/**
 This is about the delegate object of the control layer.
 Some interactive events of the player will call the method defined in SJVideoPlayerControlLayerDelegate.
 The delegate is not retained.
 
 这个是关于控制层的代理对象, 播放器的一些交互事件会调用定义在 SJVideoPlayerControlLayerDelegate 中的方法.
 
 weak. readwrite.
 */
@property (nonatomic, weak, nullable) id <SJVideoPlayerControlLayerDelegate> controlLayerDelegate;

/**
 play state.
 
 If this value is changed, the delegate method will be called.
 - (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer stateChanged:(SJVideoPlayerPlayState)state;
 
 播放状态, 当状态发生改变时, 将会调用代理方法.
 
 readonly.
 */
@property (nonatomic, readonly) SJVideoPlayerPlayState state;

/**
 The error when the video play failed, you can view the error details through this error.
 播放失败时的错误, 你可以通过这个error来查看报错详情.
 
 readonly.
 */
@property (nonatomic, strong, readonly, nullable) NSError *error;


/**
 The placeholder image when loading video.
 加载视频时的占位图.
 
 readwrite.
 */
@property (nonatomic, strong, nullable) UIImage *placeholder;

/**
 default is `AVLayerVideoGravityResizeAspect`.
 
 readwrite.
 */
@property (nonatomic, strong) AVLayerVideoGravity videoGravity;

@end





#pragma mark - 播放

@interface SJBaseVideoPlayer (Play)

/**
 Create an asset to play. (Any of the following initialization)

 1.  video player -> UIView
 2.  video player -> cell            -> table Or collection view
 3.  video player -> table header    -> table view
 4.  video player -> cell            -> collection view -> table header -> table view
 5.  video player -> collection cell -> collection view -> table cell   -> table view
 
 If this value is changed, the delegate method will be called. - (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset
 
 For example:
 [_containerView addSubView:_videoPlayer.view];
 _videoPlayer.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[NSURL URLWithString:@"http://....."]];
 
 readwrite.
 */
@property (nonatomic, strong, nullable) SJVideoPlayerURLAsset *URLAsset;

/**
 The current asset URL. nullable.
 
 readwrite.
 */
@property (nonatomic, strong, readwrite, nullable) NSURL *assetURL;

- (void)playWithURL:(NSURL *)playURL;

- (void)playWithURL:(NSURL *)playURL jumpedToTime:(NSTimeInterval)time; // unit is sec.

/**
 Refresh current asset.
 */
- (void)refresh;

/**
 The block invoked When an asset is dealloc.
 For example, you can record its playback progress(videoPlayer.progress).
 
 readwrite.
 */
@property (nonatomic, copy, nullable) void(^assetDeallocExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer);

@end





#pragma mark - Network

@interface SJBaseVideoPlayer (Network)

@property (nonatomic, readonly) SJNetworkStatus networkStatus;

@end





#pragma mark - 提示

@interface SJBaseVideoPlayer (Prompt)

/**
 prompt.update(^(SJPromptConfig * _Nonnull config) {
    config.cornerRadius = 4;                    // default cornerRadius.
    config.font = [UIFont systemFontOfSize:12]; // default font.
 });
 
 readonly.
 */
@property (nonatomic, strong, readonly) SJPrompt *prompt;

/**
 The middle of the player view shows the specified title. duration default is 1.0.

 @param title       prompt.
 */
- (void)showTitle:(NSString *)title;

/**
 The middle of the view shows the specified title.

 @param title       prompt.
 @param duration    prompt duration. duration if value set -1, prompt will always show.
 */
- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration;

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration hiddenExeBlock:(void(^__nullable)(__kindof SJBaseVideoPlayer *player))hiddenExeBlock;

- (void)showAttributedString:(NSAttributedString *)attributedString duration:(NSTimeInterval)duration;

- (void)showAttributedString:(NSAttributedString *)attributedString duration:(NSTimeInterval)duration hiddenExeBlock:(void(^__nullable)(__kindof SJBaseVideoPlayer *player))hiddenExeBlock;

/**
 Hidden Prompt.
 */
- (void)hiddenTitle;

@end





#pragma mark - 时间

@interface SJBaseVideoPlayer (Time)

- (NSString *)timeStringWithSeconds:(NSInteger)secs; // format: 00:00:00

@property (nonatomic, readonly) float progress;
@property (nonatomic, readonly) float bufferProgress;

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval totalTime;

@property (nonatomic, strong, readonly) NSString *currentTimeStr;
@property (nonatomic, strong, readonly) NSString *totalTimeStr;

@property (nonatomic, copy, nullable) void(^playTimeDidChangeExeBlok)(__kindof SJBaseVideoPlayer *videoPlayer);

- (void)jumpedToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler; // unit is sec. 单位是秒.

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

@end





#pragma mark - 控制

@interface SJBaseVideoPlayer (Control)

/**
 Whether to mute, if set to yes, the sound service will not work. default is NO.
 If this value is changed, the delegate method will be called. - (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer muteChanged:(BOOL)mute;

 readwrite.
 */
@property (nonatomic) BOOL mute;

/**
 Lock the player. Gesture Interaction will not trigger. default is NO.
 If this value is changed, the delegate method will be called. - (void)lockedVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;
 
 readwrite.
 */
@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;

/**
 When set an asset, whether to start playing immediately. default is YES.
 
 readwrite.
 */
@property (nonatomic, getter=isAutoPlay) BOOL autoPlay;

/**
 If Yes, player will be called pause method When Received `UIApplicationDidEnterBackgroundNotification` notification.
 default is YES.
 
 NO if you set, You need to set up `TARGETS` -> `Capability` -> enable `Background Modes` -> select this mode `Audio, AirPlay, and Picture in Picture`
 
 
 关于后台播放视频, 引用自: https://juejin.im/post/5a38e1a0f265da4327185a26
 
 当您想在后台播放视频时:
 1. 需要设置 videoPlayer.pauseWhenAppDidEnterBackground = NO; (该值默认为YES, 即App进入后台默认暂停).
 2. 前往 `TARGETS` -> `Capability` -> enable `Background Modes` -> select this mode `Audio, AirPlay, and Picture in Picture`
 
 readwrite.
 */
@property (nonatomic) BOOL pauseWhenAppDidEnterBackground;

- (BOOL)play;

- (BOOL)pause;                                           // 调用此方法, 表示开发者暂停.
- (void)pauseForUser;                                    // 调用此方法, 表示用户暂停.
@property (nonatomic, assign, readonly) BOOL userPaused; // 区分是用户暂停的, 还是开发者暂停的

- (void)stop;

- (void)stopAndFadeOut;

- (void)replay; 

@property (nonatomic, readwrite) float volume;
@property (nonatomic, readwrite) BOOL disableVolumeSetting;

@property (nonatomic, readwrite) float brightness;
@property (nonatomic, readwrite) BOOL disableBrightnessSetting;

@property (nonatomic, readwrite) float rate; // 0.5...2
@property (nonatomic, copy, readwrite, nullable) void(^rateChanged)(__kindof SJBaseVideoPlayer *player);
- (void)resetRate;

@property (nonatomic, copy, readwrite, nullable) void(^playDidToEnd)(__kindof SJBaseVideoPlayer *player); // 播放完毕

@end





#pragma mark - 手势

/**
 播放器的手势介绍:
 base video player 默认会存在四种手势, Single Tap, double Tap, Pan, Pinch.
 
 SingleTap
 单击手势
 当用户单击播放器时, 播放器会调用显示或隐藏控制层的相关代理方法. 见 `controlLayerDelegate`
 
 DoubleTap
 双击手势
 双击会触发暂停或播放的操作
 
 Pan
 移动手势
 当用户水平滑动时, 会触发控制层相应的代理方法. 见 `controlLayerDelegate`
 当用户垂直滑动时, 如果在屏幕左边, 则会触发调整亮度的操作, 并显示亮度提示视图. 如果在屏幕右边, 则会触发调整声音的操作, 并显示系统音量提示视图
 
 Pinch
 捏合手势
 当用户做放大或收缩触发该手势时, 会设置播放器显示模式`Aspect`或`AspectFill`.
 */
@interface SJBaseVideoPlayer (GestureControl)

@property (nonatomic, readwrite) SJDisablePlayerGestureTypes disableGestureTypes;

@end





#pragma mark - 控制层

@interface SJBaseVideoPlayer (ControlLayer)

/**
 Whether to open the control layer [Appear / Disappear] Manager. default is YES.
 
 readwrite.
 */
@property (nonatomic) BOOL enableControlLayerDisplayController;

/**
 When the player paused, Whether to keep the appear state.
 default is NO.
 
 readwrite.
 */
@property (nonatomic) BOOL pausedToKeepAppearState;

/**
 When play failed, Whether to kepp the appear state.
 default is YES.
 
 readwrite.
 */
@property (nonatomic) BOOL playFailedToKeepAppearState;

/**
 YES -> Appear.
 NO  -> Disappear.
 
 readonly.
 */
@property (nonatomic, readonly) BOOL controlLayerAppeared;
- (void)setControlLayerAppeared:(BOOL)controlLayerAppeared;

/**
 The block invoked When Control layer state changed.
 
 readwrite.
 */
@property (nonatomic, copy, nullable) void(^controlLayerAppearStateChanged)(__kindof SJBaseVideoPlayer *player, BOOL state);

/**
 When you want to appear the control layer, you should call this method to appear.
 This method will call the control layer delegate method.
 
 - (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer;
 */
- (void)controlLayerNeedAppear;

/**
 When you want to disappear the control layer, you should call this method to disappear.
 This method will call the control layer delegate method.
 
 - (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer;
 */
- (void)controlLayerNeedDisappear;


@property (nonatomic, readonly) BOOL controlViewDisplayed NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "use `controlLayerAppeared`");
@property (nonatomic, copy, readwrite, nullable) void(^controlViewDisplayStatus)(__kindof SJBaseVideoPlayer *player, BOOL displayed) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "use `controlLayerAppearStateChanged`");

@end





#pragma mark - 屏幕旋转

@interface SJBaseVideoPlayer (Rotation)

/**
 When Orientation is LandscapeLeft or LandscapeRight, this value is YES.
 
 readonly.
 */
@property (nonatomic, readonly) BOOL isFullScreen;

/**
 Whether to disable auto rotation
 
 readwrite.
 You can disable the player rotation when appropriate.
 For example when the controller is about to disappear.
 
 是否禁止播放器自动旋转
 例如:
 在viewWillDisappear的时候, 可以禁止自动旋转
 在viewDidAppear的时候, 开启自动旋转
 
 v1.0.11:
 `disableRotation` 更名为 `disableAutoRotation`
 */
@property (nonatomic) BOOL disableAutoRotation;

/**
 This is the player supports orientation when autorotation. default is `SJAutoRotateSupportedOrientation_All`.
 
 readwrite.
 */
@property (nonatomic) SJAutoRotateSupportedOrientation supportedOrientation;

/**
 Rotate to the specified orientation, Animated.
 Any value of SJOrientation.
 
 readwrite.
 */
@property (nonatomic) SJOrientation orientation;

/**
 The current orientation of the player.
 Default is UIInterfaceOrientationPortrait.
 
 readonly.
 */
@property (nonatomic, readonly) UIInterfaceOrientation currentOrientation;

/**
 The block invoked When player will rotate.
 
 readwrite.
 */
@property (nonatomic, copy, nullable) void(^willRotateScreen)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen);

/**
 The block invoked when player rotated.
 
 readwrite.
 */
@property (nonatomic, copy, nullable) void(^rotatedScreen)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen);

/**
 Autorotation. Animated.
 */
- (void)rotate;

/**
 Rotate to the specified orientation.
 
 @param orientation     Any value of SJOrientation.
 @param animated        Whether or not animation.
 */
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated;

/**
 Rotate to the specified orientation.
 
 @param orientation     Any value of SJOrientation.
 @param animated        Whether or not animation.
 @param block           The block invoked when player rotated.
 */
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completion:(void (^ _Nullable)(__kindof SJBaseVideoPlayer *player))block;

@end





#pragma mark - 截图

@interface SJBaseVideoPlayer (Screenshot)

@property (nonatomic, copy, readwrite, nullable) void(^presentationSize)(__kindof SJBaseVideoPlayer *videoPlayer, CGSize size);

- (UIImage * __nullable)screenshot;

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block;

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block;

- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(__kindof SJBaseVideoPlayer *player, NSArray<id<SJVideoPlayerPreviewInfo>> *__nullable images, NSError *__nullable error))block;

@end





#pragma mark - 输出

@interface SJBaseVideoPlayer (Export)

/**
 export session.
 
 @param beginTime           unit is sec.
 @param endTime             unit is sec.
 @param presetName 	        default is `AVAssetExportPresetMediumQuality`.
 @param progressBlock       progressBlock
 @param completion 	        completion
 @param failure 	        failure
 */
- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    endTime:(NSTimeInterval)endTime
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, float progress))progressBlock
                 completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, NSURL *fileURL, UIImage *thumbnailImage))completion
                    failure:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, NSError *error))failure;

- (void)cancelExportOperation;

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                        progress:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, float progress))progressBlock
                      completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage *imageGIF, UIImage *thumbnailImage, NSURL *filePath))completion
                         failure:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, NSError *error))failure;

- (void)cancelGenerateGIFOperation;

@end



#pragma mark - 在`tableView`或`collectionView`上播放

@interface SJBaseVideoPlayer (ScrollView)

/**
 Whether to play on scrollView.
 
 readonly.
 */
@property (nonatomic, readonly) BOOL isPlayOnScrollView;

/**
 Whether the player is appeared when playing on scrollView. Because scrollview may be scrolled.
 
 readonly.
 */
@property (nonatomic, readonly) BOOL isScrollAppeared;


@property (nonatomic, assign, readonly) BOOL playOnCell NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "use `isPlayOnScrollView`");            // 是在cell上播放
@property (nonatomic, assign, readonly) BOOL scrollIntoTheCell NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "use `isScrollAppeared`");     // 播放器滚进了单元格中
@end

NS_ASSUME_NONNULL_END
