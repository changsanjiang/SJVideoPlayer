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
#import "SJVideoPlayerURLAsset.h"
#import "SJVideoPlayerState.h"
#import "SJVideoPlayerPreviewInfo.h"
#import "SJPrompt.h"
#import "SJRotationManager.h"
#import "SJVideoPlayerControlLayerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

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
@property (nonatomic, readonly) SJVideoPlayerPlayState state __deprecated_msg("已弃用, 请使用`player.playStatus`");

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


+ (NSString *)version;

- (nullable __kindof UIViewController *)atViewController;

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

@interface SJBaseVideoPlayer (PlayControl)

/// 资源
/// - 使用资源URL及相关的视图信息进行初始化
@property (nonatomic, strong, nullable) SJVideoPlayerURLAsset *URLAsset;

/// 播放状态
@property (nonatomic, readonly) SJVideoPlayerPlayStatus playStatus;

/// 暂停原因
@property (nonatomic, readonly) SJVideoPlayerPausedReason pausedReason;

/// 不活跃原因
@property (nonatomic, readonly) SJVideoPlayerInactivityReason inactivityReason;

/// URLAsset资源dealloc时的回调
/// - 可以在这里做一些记录的工作. 如播放记录.
@property (nonatomic, copy, nullable) void(^assetDeallocExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer);

/// 资源刷新
- (void)refresh;

/// 是否静音🔇
@property (nonatomic) BOOL mute;

/// 是否锁屏
@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;

/// 初始化完成后, 是否自动播放
@property (nonatomic, getter=isAutoPlay) BOOL autoPlay;

/// 播放器是否可以执行`play`
/// - 当调用`play`时, 会回调该block, 如果返回YES, 则执行`play`方法, 否之.
/// - 如果该block == nil, 则调用`play`时, 默认为执行.
@property (nonatomic, copy, nullable) BOOL(^canPlayAnAsset)(__kindof SJBaseVideoPlayer *player);
/// 使播放
- (void)play;

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

/// 调声音
@property (nonatomic, readwrite) float volume;
/// 禁止设置声音
@property (nonatomic, readwrite) BOOL disableVolumeSetting;

/// 调亮度
@property (nonatomic, readwrite) float brightness;
/// 禁止设置亮度
@property (nonatomic, readwrite) BOOL disableBrightnessSetting;

/// 调速
@property (nonatomic, readwrite) float rate;
/// 速率改变的回调
@property (nonatomic, copy, readwrite, nullable) void(^rateChanged)(__kindof SJBaseVideoPlayer *player);

@property (nonatomic, strong, nullable) NSURL *assetURL;
- (void)playWithURL:(NSURL *)URL; // 不再建议使用, 请使用`URLAsset`进行初始化
@end



#pragma mark - 关于视图控制器

/// v1.3.0 新增
/// 请在适当的时候调用这些方法
@interface SJBaseVideoPlayer (UIViewController)

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





#pragma mark - 手势
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

@end



/// 全屏或小屏, 但不触发旋转
/// v1.3.1 新增
@interface SJBaseVideoPlayer (FitOnScreen)

/// Disable rotation, only full screen(`fitOnScreen==YES`) or small screen(`fitOnScreen==NO`) operation.
/// 禁止旋转, 只进行全屏或小屏的操作.
/// default is NO.
@property (nonatomic) BOOL useFitOnScreenAndDisableRotation;

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

/// 全屏或小屏过程中的回调
@property (nonatomic, copy, nullable) void(^fitOnScreenWillChangeExeBlock)(__kindof SJBaseVideoPlayer *player);

/// 全屏或小屏过程中的回调
@property (nonatomic, copy, nullable) void(^fitOnScreenDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);;

@end




#pragma mark - 屏幕旋转

@interface SJBaseVideoPlayer (Rotation)

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

/// 视图将要旋转的回调
@property (nonatomic, copy, nullable) void(^viewWillRotateExeBlock)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen);

/// 视图旋转完后的回调
@property (nonatomic, copy, nullable) void(^viewDidRotateExeBlock)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen);;

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

/// 旋转的时间
/// - 默认是0.4
@property (nonatomic) NSTimeInterval rotationTime;

/// 是否正在旋转
@property (nonatomic, readonly) BOOL isTransitioning;

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


@end





@interface SJBaseVideoPlayer (Deprecated)
@property (nonatomic, copy, nullable) void(^playDidToEnd)(__kindof SJBaseVideoPlayer *player) __deprecated_msg("use `playDidToEndExeBlock`");
@property (nonatomic, assign, readonly) BOOL playOnCell __deprecated_msg("use `isPlayOnScrollView`");
@property (nonatomic, assign, readonly) BOOL scrollIntoTheCell __deprecated_msg("use `isScrollAppeared`");
- (void)jumpedToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler __deprecated_msg("use `seekToTime:completionHandler:`"); // unit is sec. 单位是秒.
@property (nonatomic, readonly) BOOL controlViewDisplayed __deprecated_msg("use `controlLayerAppeared`");
@property (nonatomic, copy, readwrite, nullable) void(^controlViewDisplayStatus)(__kindof SJBaseVideoPlayer *player, BOOL displayed) __deprecated_msg("use `controlLayerAppearStateChanged`");
@property (nonatomic, copy, nullable) void(^willRotateScreen)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen) __deprecated_msg("use `viewWillRotateExeBlock`");
@property (nonatomic, copy, nullable) void(^rotatedScreen)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen) __deprecated_msg("use `viewDidRotateExeBlock`");
@end


NS_ASSUME_NONNULL_END
