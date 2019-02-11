//
//  SJBaseVideoPlayer.h
//  SJBaseVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//
//  GitHub:     https://github.com/changsanjiang/SJBaseVideoPlayer
//
//  Contact:    changsanjiang@gmail.com
//
//  QQGroup:    719616775
//

/**
 ------------------------
 *  PlayControl
 *  Network
 *  Prompt
 *  Time
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
#import "SJVideoPlayerPreviewInfo.h"
#import "SJPrompt.h"
#import "SJFitOnScreenManagerProtocol.h"
#import "SJRotationManagerProtocol.h"
#import "SJVideoPlayerControlLayerProtocol.h"
#import "SJControlLayerAppearManagerProtocol.h"
#import "SJFlipTransitionManagerProtocol.h"
#import "SJMediaPlaybackProtocol.h"
#import "SJVideoPlayerURLAsset+SJAVMediaPlaybackAdd.h"
#import "SJPlayerGestureControlProtocol.h"
#import "SJDeviceVolumeAndBrightnessManagerProtocol.h"
#import "SJModalViewControlllerManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJBaseVideoPlayer : NSObject

+ (instancetype)player;

- (instancetype)init;

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
 The error when the video play failed, you can view the error details through this error.
 播放失败时的错误, 你可以通过这个error来查看报错详情.
 
 readonly.
 */
@property (nonatomic, strong, readonly, nullable) NSError *error;

/**
 default is `AVLayerVideoGravityResizeAspect`.
 
 readwrite.
 */
@property (nonatomic, strong, null_resettable) AVLayerVideoGravity videoGravity;


+ (NSString *)version;

- (nullable __kindof UIViewController *)atViewController;

@end


@interface SJBaseVideoPlayer (Placeholder)
/// 初始化资源时, 可能会短暂黑屏, 建议设置一下占位图
@property (nonatomic, strong, readonly) UIImageView *placeholderImageView;

/// 播放器准备好显示时, 是否隐藏占位图
/// - 默认为YES
@property (nonatomic) BOOL hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay;
@end


#pragma mark - 镜像翻转

@interface SJBaseVideoPlayer (VideoFlipTransition)
@property (nonatomic, strong, null_resettable) id<SJFlipTransitionManager> flipTransitionManager;

@property (nonatomic, readonly) BOOL isFlipTransitioning;
@property (nonatomic) SJViewFlipTransition flipTransition; // Animated.
- (void)setFlipTransition:(SJViewFlipTransition)t animated:(BOOL)animated;
- (void)setFlipTransition:(SJViewFlipTransition)t animated:(BOOL)animated completionHandler:(void(^_Nullable)(__kindof SJBaseVideoPlayer *player))completionHandler;

@property (nonatomic, copy, nullable) void(^flipTransitionDidStartExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^flipTransitionDidStopExeBlock)(__kindof SJBaseVideoPlayer *player);
@end


#pragma mark - 时间

@interface SJBaseVideoPlayer (Time)

/// 播放的进度
@property (nonatomic, readonly) float progress;
/// 缓冲的进度
@property (nonatomic, readonly) float bufferProgress;

/// 当前的时间
@property (nonatomic, strong, readonly) NSString *currentTimeStr;
@property (nonatomic, readonly) NSTimeInterval currentTime;

/// 全部的时间
@property (nonatomic, strong, readonly) NSString *totalTimeStr;
@property (nonatomic, readonly) NSTimeInterval totalTime;

/// 播放时间改变的回调
@property (nonatomic, copy, nullable) void(^playTimeDidChangeExeBlok)(__kindof SJBaseVideoPlayer *videoPlayer);
/// 播放完毕的回调
@property (nonatomic, copy, nullable) void(^playDidToEndExeBlock)(__kindof SJBaseVideoPlayer *player);

- (NSString *)timeStringWithSeconds:(NSInteger)secs; // format: 00:00:00
@end




#pragma mark - 播放控制

@interface SJBaseVideoPlayer (PlayControl)<SJMediaPlaybackControllerDelegate>

@property (nonatomic, strong, null_resettable) id<SJMediaPlaybackController> playbackController;

/// 资源
/// - 播放一个资源
/// - 使用URL及相关的视图信息进行初始化
@property (nonatomic, strong, nullable) SJVideoPlayerURLAsset *URLAsset;

/// URLAsset资源dealloc时的回调
/// - 可以在这里做一些记录的工作. 如播放记录.
@property (nonatomic, copy, nullable) void(^assetDeallocExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer);

/// v1.6.5 新增
/// 切换 清晰度
/// - 切换当前播放的视频清晰度
- (void)switchVideoDefinitionByURL:(NSURL *)URL;

/// 播放状态
@property (nonatomic, readonly) SJVideoPlayerPlayStatus playStatus;

/// 播放状态观察者
- (id<SJPlayStatusObserver>)getPlayStatusObserver; // 需要对它强引用, 否则观察者会被释放

/// 暂停原因
@property (nonatomic, readonly) SJVideoPlayerPausedReason pausedReason;

/// 不活跃原因
@property (nonatomic, readonly) SJVideoPlayerInactivityReason inactivityReason;

/// 资源刷新
- (void)refresh;

/// 是否静音🔇
@property (nonatomic, getter=isMute) BOOL mute;
@property (nonatomic) float playerVolume;

/// 是否锁屏
@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;

/// 初始化完成后, 是否自动播放
@property (nonatomic) BOOL autoPlayWhenPlayStatusIsReadyToPlay;

/// 播放器是否可以执行`play`
///
/// - 当调用`play`时, 会回调该block, 如果返回YES, 则执行`play`方法, 否之.
/// - 如果该block == nil, 则调用`play`时, 默认为执行.
@property (nonatomic, copy, nullable) BOOL(^canPlayAnAsset)(__kindof SJBaseVideoPlayer *player);
/// 使播放
- (void)play;

/// 是否恢复播放, 进入前台时.
///
/// 正常情况下, 进入后台时, 播放器将会暂停. 此属性表示App进入前台后, 播放器是否恢复播放. 默认为NO.
@property (nonatomic) BOOL resumePlaybackWhenAppDidEnterForeground;

/// 使暂停
- (void)pause;

/// 关于后台播放视频, 引用自: https://juejin.im/post/5a38e1a0f265da4327185a26
///
/// 当您想在后台播放视频时:
/// 1. 需要设置 videoPlayer.pauseWhenAppDidEnterBackground = NO; (该值默认为YES, 即App进入后台默认暂停).
/// 2. 前往 `TARGETS` -> `Capability` -> enable `Background Modes` -> select this mode `Audio, AirPlay, and Picture in Picture`
@property (nonatomic) BOOL pauseWhenAppDidEnterBackground;

/// 使停止
- (void)stop;

/// 停止播放, 并淡出
- (void)stopAndFadeOut;

/// 重头开始播放
- (void)replay;

/// 跳转到指定位置
- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

/// 调速
@property (nonatomic) float rate;
/// 速率改变的回调
@property (nonatomic, copy, nullable) void(^rateDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);

@property (nonatomic, strong, nullable) NSURL *assetURL;
- (void)playWithURL:(NSURL *)URL; // 不再建议使用, 请使用`URLAsset`进行初始化
@end


#pragma mark -

@interface SJBaseVideoPlayer (DeviceVolumeAndBrightness)
@property (nonatomic, strong, null_resettable) id<SJDeviceVolumeAndBrightnessManager> deviceVolumeAndBrightnessManager;

@property (nonatomic) float deviceVolume;
@property (nonatomic) float deviceBrightness;

@property (nonatomic) BOOL disableBrightnessSetting;
@property (nonatomic) BOOL disableVolumeSetting;
@end


#pragma mark - 关于视图控制器

/// v1.3.0 新增
/// 请在适当的时候调用这些方法
@interface SJBaseVideoPlayer (ViewController)

/// You should call it when view did appear
- (void)vc_viewDidAppear; 
/// You should call it when view will disappear
- (void)vc_viewWillDisappear;
- (void)vc_viewDidDisappear;
- (BOOL)vc_prefersStatusBarHidden;
- (UIStatusBarStyle)vc_preferredStatusBarStyle;

/// The code is fixed, you can copy it directly to the view controller
/// 以下的代码都是固定的, 可以直接copy到视图控制器中
//
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self.player vc_viewDidAppear];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [self.player vc_viewWillDisappear];
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    [self.player vc_viewDidDisappear];
//}
//
//- (BOOL)prefersStatusBarHidden {
//    return [self.player vc_prefersStatusBarHidden];
//}
//
//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return [self.player vc_preferredStatusBarStyle];
//}
//
//- (BOOL)prefersHomeIndicatorAutoHidden {
//    return YES;
//}

/// 当调用`vc_viewWillDisappear`时, 将设置为YES
/// 当调用`vc_viewDidAppear`时, 将设置为NO
@property (nonatomic) BOOL vc_isDisappeared;


/// v1.6.0 新增
/// 临时显示状态栏
/// Animatable. 可动画的
- (void)needShowStatusBar;

/// 临时隐藏状态栏
/// Animatable. 可动画的
- (void)needHiddenStatusBar;
@end




#pragma mark - Network

@interface SJBaseVideoPlayer (Network)
@property (nonatomic, strong, null_resettable) id<SJReachability> reachability;

@property (nonatomic, readonly) SJNetworkStatus networkStatus;
@property (nonatomic, copy, nullable) void(^networkStatusDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
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

@property (nonatomic, strong, null_resettable) id<SJPlayerGestureControl> gestureControl;

@property (nonatomic) SJPlayerDisabledGestures disabledGestures;

@end





#pragma mark - 播放器控制层 显示/隐藏 控制

@interface SJBaseVideoPlayer (ControlLayer)

@property (nonatomic, strong, null_resettable) id<SJControlLayerAppearManager> controlLayerAppearManager;

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

@property (nonatomic) BOOL disabledControlLayerAppearManager; // default value is NO.
@property (nonatomic) BOOL controlLayerIsAppeared;
@property (nonatomic) BOOL pausedToKeepAppearState;
@property (nonatomic) BOOL controlLayerAutoAppearWhenAssetInitialized; // default value is NO.
@property (nonatomic, copy, nullable) void(^controlLayerAppearStateDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player, BOOL state);
@end


@interface SJBaseVideoPlayer (ModalViewControlller)
@property (nonatomic, strong, null_resettable) id<SJModalViewControlllerManagerProtocol> modalViewControllerManager;
@property (nonatomic) BOOL needPresentModalViewControlller;

- (void)presentModalViewControlller;
- (void)dismissModalViewControlller;
@end


/// 全屏或小屏, 但不触发旋转
/// v1.3.1 新增
@interface SJBaseVideoPlayer (FitOnScreen)
@property (nonatomic, strong, null_resettable) id<SJFitOnScreenManager> fitOnScreenManager;

/// Whether fullscreen or smallscreen, this method does not trigger rotation.
/// 全屏或小屏, 此方法不触发旋转
/// Animated
@property (nonatomic, getter=isFitOnScreen) BOOL fitOnScreen;

/// Whether fullscreen or smallscreen, this method does not trigger rotation.
/// 全屏或小屏, 此方法不触发旋转
/// - animated : 是否动画
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated;

/// Whether fullscreen or smallscreen, this method does not trigger rotation.
/// 全屏或小屏, 此方法不触发旋转
/// - animated : 是否动画
/// - completionHandler : 操作完成的回调
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated completionHandler:(nullable void(^)(__kindof SJBaseVideoPlayer *player))completionHandler;

@property (nonatomic) BOOL useFitOnScreenAndDisableRotation;
@property (nonatomic, copy, nullable) void(^fitOnScreenWillBeginExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^fitOnScreenDidEndExeBlock)(__kindof SJBaseVideoPlayer *player);;
@end




#pragma mark - 屏幕旋转

@interface SJBaseVideoPlayer (Rotation)
/// Default is SJRotationManager. It only rotates the player view.
/// When you want to rotate the view controller, You can use the SJVCRotationManager.
/// 默认情况下, 播放器将只旋转播放界面, ViewController并不会旋转.
/// 当您想要旋转ViewController时, 可以采用此管理类进行旋转.
/// - 使用示例请看`SJVCRotationManager`第36行注释。
@property (nonatomic, strong, null_resettable) id<SJRotationManagerProtocol> rotationManager;

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

@property (nonatomic, readonly) BOOL isFullScreen;
@property (nonatomic, readonly) BOOL isTransitioning;

@property (nonatomic) BOOL disableAutoRotation;
@property (nonatomic) NSTimeInterval rotationTime;
@property (nonatomic) SJOrientation orientation;
@property (nonatomic) SJAutoRotateSupportedOrientation supportedOrientation;
@property (nonatomic, copy, nullable) void(^viewWillRotateExeBlock)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen);
@property (nonatomic, copy, nullable) void(^viewDidRotateExeBlock)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen);
@property (nonatomic, readonly) UIInterfaceOrientation currentOrientation;
@end





#pragma mark - 截图

@interface SJBaseVideoPlayer (Screenshot)

@property (nonatomic, copy, nullable) void(^presentationSize)(__kindof SJBaseVideoPlayer *videoPlayer, CGSize size);

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

@property (nonatomic, copy, nullable) void(^playerViewWillAppearExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer);
@property (nonatomic, copy, nullable) void(^playerViewWillDisappearExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer);
@end


#pragma mark - 已弃用

@interface SJBaseVideoPlayer (Deprecated)
@property (nonatomic, copy, nullable) void(^playDidToEnd)(__kindof SJBaseVideoPlayer *player) __deprecated_msg("use `playDidToEndExeBlock`");
@property (nonatomic, readonly) BOOL playOnCell __deprecated_msg("use `isPlayOnScrollView`");
@property (nonatomic, readonly) BOOL scrollIntoTheCell __deprecated_msg("use `isScrollAppeared`");
- (void)jumpedToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler __deprecated_msg("use `seekToTime:completionHandler:`"); // unit is sec. 单位是秒.
@property (nonatomic, readonly) BOOL controlViewDisplayed __deprecated_msg("use `controlLayerIsAppeared`");
@property (nonatomic, copy, nullable) void(^controlViewDisplayStatus)(__kindof SJBaseVideoPlayer *player, BOOL displayed) __deprecated_msg("use `controlLayerAppearStateChanged`");
@property (nonatomic, copy, nullable) void(^willRotateScreen)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen) __deprecated_msg("use `viewWillRotateExeBlock`");
@property (nonatomic, copy, nullable) void(^rotatedScreen)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen) __deprecated_msg("use `viewDidRotateExeBlock`");
@property (nonatomic, strong, nullable) UIImage *placeholder __deprecated_msg("use `player.placeholderImageView`");
@property (nonatomic, readonly) SJVideoPlayerPlayState state __deprecated_msg("use `player.playStatus`");
@property (nonatomic) BOOL playFailedToKeepAppearState __deprecated;
@property (nonatomic, copy, nullable) void(^controlLayerAppearStateChanged)(__kindof SJBaseVideoPlayer *player, BOOL state) __deprecated_msg("use `controlLayerAppearStateDidChangeExeBlock`");
@property (nonatomic) BOOL controlLayerAppeared __deprecated_msg("use `controlLayerIsAppeared`");
@property (nonatomic) BOOL enableControlLayerDisplayController __deprecated_msg("use `disabledControlLayerAppearManager`");
@property (nonatomic, copy, nullable) void(^fitOnScreenWillChangeExeBlock)(__kindof SJBaseVideoPlayer *player) __deprecated_msg("use `fitOnScreenWillBeginExeBlock`");
@property (nonatomic, copy, nullable) void(^fitOnScreenDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player) __deprecated_msg("use `fitOnScreenDidEndExeBlock`");
@property (nonatomic, getter=isAutoPlay) BOOL autoPlay __deprecated_msg("use `autoPlayWhenPlayStatusIsReadyToPlay`");
@property (nonatomic, copy, nullable) void(^rateChanged)(__kindof SJBaseVideoPlayer *player) __deprecated_msg("use `rateDidChangeExeBlock`");
@property (nonatomic) SJDisablePlayerGestureTypes disableGestureTypes __deprecated_msg("use `disabledGestures`");
@property (nonatomic) float volume __deprecated_msg("use `deviceVolume`");
@property (nonatomic) float brightness __deprecated_msg("use `deviceBrightness`");
@property (nonatomic, copy, nullable) void(^playStatusDidChangeExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer) __deprecated_msg("use `_playStatusObserver = [_player getPlayStatusObserver]`");
@end

NS_ASSUME_NONNULL_END
