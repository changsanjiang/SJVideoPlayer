//
//  SJBaseVideoPlayer.h
//  SJBaseVideoPlayerProject
//
//  Created by 畅三江 on 2018/2/2.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//
//  GitHub:     https://github.com/changsanjiang/SJBaseVideoPlayer
//  GitHub:     https://github.com/changsanjiang/SJVideoPlayer
//
//  Email:      changsanjiang@gmail.com
//  QQGroup:    930508201
//

#import <UIKit/UIKit.h>
#import "SJFitOnScreenManagerDefines.h"
#import "SJRotationManagerDefines.h"
#import "SJVideoPlayerControlLayerProtocol.h"
#import "SJControlLayerAppearManagerDefines.h"
#import "SJFlipTransitionManagerDefines.h"
#import "SJVideoPlayerPlaybackControllerDefines.h"
#import "SJVideoPlayerURLAsset+SJAVMediaPlaybackAdd.h"
#import "SJPlayerGestureControlDefines.h"
#import "SJDeviceVolumeAndBrightnessManagerDefines.h"
#import "SJFloatSmallViewControllerDefines.h"
#import "SJVideoDefinitionSwitchingInfo.h"
#import "SJPopPromptControllerDefines.h"
#import "SJPlaybackObservation.h"
#import "SJVideoPlayerPresentViewDefines.h"
#import "SJSubtitlesPromptControllerDefines.h"
#import "SJBarrageQueueControllerDefines.h"
#import "SJPromptDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJBaseVideoPlayer : NSObject
+ (NSString *)version;
+ (instancetype)player;
- (instancetype)init;

///
/// 视频画面填充模式
///
@property (nonatomic) SJVideoGravity videoGravity;

///
/// 播放器视图
///
/// \code
/// _player = SJBaseVideoPlayer.player;
/// _player.view.frame = ...;
/// [self.view addSubview:_player.view];
/// \endcode
///
@property (nonatomic, strong, readonly) __kindof UIView *view;
@property (nonatomic, weak, nullable) id <SJVideoPlayerControlLayerDataSource> controlLayerDataSource;
@property (nonatomic, weak, nullable) id <SJVideoPlayerControlLayerDelegate> controlLayerDelegate;
@end

#pragma mark - present view

@interface SJBaseVideoPlayer (Placeholder)
///
/// 播放画面显示层
///
/// \code
///     // 设置占位图
///     _player.presentView.placeholderImageView.image = [UIImage imageNamed:@"..."];
///     // [_player.presentView.placeholderImageView sd_setImageWithURL:URL];
/// \endcode
///
@property (nonatomic, strong, readonly) UIView<SJVideoPlayerPresentView> *presentView;

///
/// 准备好显示画面时, 是否隐藏占位图
///
///         default value is YES
///
@property (nonatomic) BOOL hiddenPlaceholderImageViewWhenPlayerIsReadyForDisplay;

///
/// 将要隐藏占位图时, 延迟多少秒才去隐藏
///
///         default value is 0.8s
///
@property (nonatomic) NSTimeInterval delayInSecondsForHiddenPlaceholderImageView;
@end

#pragma mark - 镜像翻转

@interface SJBaseVideoPlayer (VideoFlipTransition)

///
/// 镜像翻转
///
///         如果需要水平镜像翻转, 可以`player.flipTransitionManager.flipTransition = SJViewFlipTransition_Horizontally;`
///         了解更多请前往协议头文件查看
///
@property (nonatomic, strong, null_resettable) id<SJFlipTransitionManager> flipTransitionManager; ///< 镜像翻转

///
/// 观察者
///
///         可以如下设置block, 来监听某个状态的改变
///
///         player.flipTransitionObserver.flipTransitionDidStartExeBlock = ...;
///         player.flipTransitionObserver.flipTransitionDidStopExeBlock = ...;
///
@property (nonatomic, strong, readonly) id<SJFlipTransitionManagerObserver> flipTransitionObserver;
@end



#pragma mark - 播放控制

@interface SJBaseVideoPlayer (PlayControl)<SJVideoPlayerPlaybackControllerDelegate>

///
/// 播放控制
///
///         此模块将是对视频播放的控制, 例如播放, 暂停, 调速, 跳转等等...
///         了解更多请前往协议头文件查看
///
@property (nonatomic, strong, null_resettable) id<SJVideoPlayerPlaybackController> playbackController;

///
/// 观察者
///
///         可以如下设置block, 来监听某个状态的改变
///
///         player.playbackObserver.currentTimeDidChangeExeBlock = ...;
///         player.playbackObserver.durationDidChangeExeBlock = ...;
///         player.playbackObserver.timeControlStatusDidChangeExeBlock = ...;
///
@property (nonatomic, strong, readonly) SJPlaybackObservation *playbackObserver;

///
/// 设置资源进行播放
///
///         使用URL及相关的视图信息进行初始化
///
@property (nonatomic, strong, nullable) SJVideoPlayerURLAsset *URLAsset;

///
/// 播放出错
///
///         当播放发生错误时, 可以通过它来获取错误信息
///
@property (nonatomic, strong, readonly, nullable) NSError *error;

///
/// 暂停或播放的控制状态
///
///         当调用了暂停时, 此时 player.timeControlStatus = .paused
///
///         当调用了播放时, 此时 将可能处于以下两种状态中的任意一个:
///                         - player.timeControlStatus = .playing
///                             正在播放中.
///
///                         - player.timeControlStatus = .waitingToPlay
///                             等待播放, 等待的原因请查看 player.reasonForWaitingToPlay
///
@property (nonatomic, readonly) SJPlaybackTimeControlStatus timeControlStatus;

///
/// 当调用了播放, 播放器未能播放处于等待状态时的原因
///
///         等待原因有以下3种状态:
///             1.未设置资源, 此时设置资源后, 当`player.assetStatus = .readyToPlay`, 播放器将自动进行播放.
///             2.可能是由于缓冲不足, 播放器在等待缓存足够时自动恢复播放, 此时可以显示loading视图.
///             3.可能是正在评估缓冲中, 这个过程会进行的很快, 不需要显示loading视图.
///
@property (nonatomic, readonly, nullable) SJWaitingReason reasonForWaitingToPlay;

@property (nonatomic, readonly) BOOL isPaused;          ///< 调用了暂停, 暂停播放
@property (nonatomic, readonly) BOOL isPlaying;         ///< 调用了播放, 处于播放中
@property (nonatomic, readonly) BOOL isBuffering;       ///< 调用了播放, 处于缓冲中(等待缓存足够时自动恢复播放, 建议显示loading视图)
@property (nonatomic, readonly) BOOL isEvaluating;      ///< 调用了播放, 正在评估缓冲中(这个过程会进行的很快, 不需要显示loading视图)
@property (nonatomic, readonly) BOOL isNoAssetToPlay;   ///< 调用了播放, 但未设置播放资源(设置资源后将会自动播放 )

@property (nonatomic, readonly) BOOL isPlaybackFinished;                            ///< 播放结束
@property (nonatomic, readonly, nullable) SJFinishedReason finishedReason;          ///< 播放结束的reason

///
/// 资源准备(或初始化)的状态
///
///         当未设置资源时, 此时 player.assetStatus = .unknown
///         当设置新资源时, 此时 player.assetStatus = .preparing
///         当准备好播放时, 此时 player.assetStatus = .readyToPlay
///         当播放器出错时, 此时 player.assetStatus = .failed
///
@property (nonatomic, readonly) SJAssetStatus assetStatus;

///
/// 设置 进入后台时, 是否暂停播放. 默认为 YES.
///
/// 关于后台播放视频, 引用自: https://juejin.im/post/5a38e1a0f265da4327185a26
///
/// 当您想在后台播放视频时:
/// 1. 需要设置 videoPlayer.pauseWhenAppDidEnterBackground = NO; (该值默认为YES, 即App进入后台默认暂停).
/// 2. 前往 `TARGETS` -> `Capability` -> enable `Background Modes` -> select this mode `Audio, AirPlay, and Picture in Picture`
///
@property (nonatomic) BOOL pauseWhenAppDidEnterBackground;
@property (nonatomic) BOOL autoplayWhenSetNewAsset;                    ///< 设置新的资源后, 是否自动调用播放. 默认为 YES
@property (nonatomic) BOOL resumePlaybackWhenAppDidEnterForeground;    ///< 进入前台时, 是否恢复播放. 默认为 NO
@property (nonatomic) BOOL resumePlaybackWhenPlayerHasFinishedSeeking; ///< 当`seekToTime:`操作完成后, 是否恢复播放. 默认为 YES

- (void)play;       ///< 使播放
- (void)pause;      ///< 使暂停
- (void)refresh;    ///< 刷新当前资源, 将重新初始化当前的资源, 适合播放失败时调用
- (void)replay;     ///< 重播, 适合播放完毕后调用进行重播
- (void)stop;       ///< 使停止, 请注意: 当前资源将会被清空, 如需重播, 请重新设置新资源

@property (nonatomic, getter=isMuted) BOOL muted;                                   ///< 禁音
@property (nonatomic) float playerVolume;                                           ///< 设置播放声音
@property (nonatomic) float rate;                                                   ///< 设置播放速率

@property (nonatomic, readonly) NSTimeInterval currentTime;                         ///< 当前播放到的时间
@property (nonatomic, readonly) NSTimeInterval duration;                            ///< 总时长
@property (nonatomic, readonly) NSTimeInterval playableDuration;                    ///< 缓冲到的时间
@property (nonatomic, readonly) NSTimeInterval durationWatched;                     ///< 当前资源已观看的时长

@property (nonatomic, readonly) BOOL isPlayed;                                      ///< 当前的资源是否调用过`play`
@property (nonatomic, readonly) BOOL isReplayed;                                    ///< 当前的资源是否调用过`replay`
@property (nonatomic, readonly) SJPlaybackType playbackType;                        ///< 播放类型
- (NSString *)stringForSeconds:(NSInteger)secs;                                     ///< 转换时间为字符串, format: 00:00:00

///
/// 设置 能否调用`play`.
///
/// - 当调用`play`时, 会回调该`block`, 如果返回 YES, 则执行.
/// - 当`block == nil`时, 默认为执行.
///
@property (nonatomic, copy, nullable) BOOL(^canPlayAnAsset)(__kindof SJBaseVideoPlayer *player);

///
/// 是否可以执行跳转`seekToTime:`.
///
/// - 当调用任意`seekToTime:`时, 会回调该`block`, 如果返回 YES, 则执行.
/// - 当`block == nil`时, 默认为执行.
///
@property (nonatomic, copy, nullable) BOOL(^canSeekToTime)(__kindof SJBaseVideoPlayer *player);

///
/// 是否精确跳转, default value is NO.
///
@property (nonatomic) BOOL accurateSeeking;

///
/// 跳转到指定位置播放
///
- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;
- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

///
/// 切换清晰度
///
- (void)switchVideoDefinition:(SJVideoPlayerURLAsset *)URLAsset;

///
/// 当前清晰度切换的信息
///
@property (nonatomic, strong, readonly) SJVideoDefinitionSwitchingInfo *definitionSwitchingInfo;
@end


#pragma mark - 设置 设备的音量和亮度

@interface SJBaseVideoPlayer (DeviceVolumeAndBrightness)

///
/// 设备 音量和亮度调整管理类
///
@property (nonatomic, strong, null_resettable) id<SJDeviceVolumeAndBrightnessManager> deviceVolumeAndBrightnessManager;

///
/// 观察者
///
@property (nonatomic, strong, readonly) id<SJDeviceVolumeAndBrightnessManagerObserver> deviceVolumeAndBrightnessObserver;

///
/// 禁止设置亮度
///
@property (nonatomic) BOOL disableBrightnessSetting;

///
/// 禁止设置音量
///
@property (nonatomic) BOOL disableVolumeSetting;
@end


#pragma mark - 关于视图控制器

/// v1.3.0 新增
/// 请在适当的时候调用这些方法
@interface SJBaseVideoPlayer (Life)

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




#pragma mark - 网络状态

@interface SJBaseVideoPlayer (Network)

///
/// 网络状态监测
///
///         了解更多请前往协议头文件查看
///
@property (nonatomic, strong, null_resettable) id<SJReachability> reachability;

///
/// 观察者
///
@property (nonatomic, strong, readonly) id<SJReachabilityObserver> reachabilityObserver;
@end





#pragma mark - 弹出提示文本

@interface SJBaseVideoPlayer (PromptControl)

///
/// 中心弹出文本提示
///
///         了解更多请前往协议头文件查看
///
@property (nonatomic, strong, null_resettable) id<SJPromptProtocol> prompt;

///
/// 左下角弹出提示
///
///         了解更多请前往协议头文件查看
///
@property (nonatomic, strong, null_resettable) id<SJPopPromptController> popPromptController;
@end



#pragma mark - 手势控制相关操作
/**
 播放器的手势介绍:
 base video player 默认会存在 Single Tap, double Tap, Pan, Pinch, LongPress 这些手势.
 
 SingleTapGesture
 单击手势
 当用户单击播放器时, 播放器会调用显示或隐藏控制层的相关代理方法. 见 `controlLayerDelegate`
 
 DoubleTapGesture
 双击手势
 双击会触发暂停或播放的操作
 
 PanGesture
 移动手势
 当用户水平滑动时, 会触发控制层相应的代理方法. 见 `controlLayerDelegate`
 当用户垂直滑动时, 如果在屏幕左边, 则会触发调整亮度的操作, 并显示亮度提示视图. 如果在屏幕右边, 则会触发调整声音的操作, 并显示系统音量提示视图
 
 PinchGesture
 捏合手势
 当用户做放大或收缩触发该手势时, 会设置播放器显示模式`Aspect`或`AspectFill`.
 
 LongPressGesture
 长按手势
 当用户长按播放器时, 将加速播放
 */
@interface SJBaseVideoPlayer (GestureControl)

///
/// 手势控制
///
///         如果想自己设置支持的手势类型, 可以`player.gestureControl.supportedGestureTypes = SJPlayerGestureTypeMask_SingleTap | ....;`
///         了解更多请前往头文件查看
///
@property (nonatomic, strong, readonly) id<SJPlayerGestureControl> gestureControl;

///
/// 是否可以触发某个手势
///
///         这个block的返回值将会作为触发手势的一个条件, 当`return NO`时, 相应的手势将不会触发
///
@property (nonatomic, copy, nullable) BOOL(^gestureRecognizerShouldTrigger)(__kindof SJBaseVideoPlayer *player, SJPlayerGestureType type, CGPoint location);

///
/// 在cell中播放时, 是否允许水平方向触发Pan手势.
///
///         default value is NO
///
@property (nonatomic) BOOL allowHorizontalTriggeringOfPanGesturesInCells;

///
/// 长按手势触发时的播放速度
///
///         default value is 2.0
///
@property (nonatomic) CGFloat rateWhenLongPressGestureTriggered;

@end





#pragma mark - 播放器控制层 显示/隐藏 控制

@interface SJBaseVideoPlayer (ControlLayer)
///
/// 对控制层显示/隐藏的控制
///
///         仅仅对控制层的显示和隐藏做控制(如控制层显示后, 一段时间该管理类将尝试隐藏控制层)
///         其他操作由开发者自己处理, 当不需要该管理类时, 可以禁用`player.controlLayerAppearManager.disabled = YES;`
///
@property (nonatomic, strong, null_resettable) id<SJControlLayerAppearManager> controlLayerAppearManager;

///
/// 观察者
///
///         当需要监听控制层的显示和隐藏时, 可以设置`player.controlLayerAppearObserver.appearStateDidChangeExeBlock = ...;`
///
@property (nonatomic, strong, readonly) id<SJControlLayerAppearManagerObserver> controlLayerAppearObserver;

///
/// 控制层的显示状态(是否已显示)
///
@property (nonatomic, getter=isControlLayerAppeared) BOOL controlLayerAppeared;

///
/// 控制层是否可以隐藏
///
///         这个block的返回值将会作为触发隐藏控制层的一个条件, 当`return NO`时, 将不会触发隐藏控制层
///
@property (nonatomic, copy, nullable) BOOL(^canAutomaticallyDisappear)(__kindof SJBaseVideoPlayer *player);

/**
 显示控制层
 
 When you want to appear the control layer, you should call this method to appear.
 This method will call the control layer delegate method.
 
 - (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer;
 */
- (void)controlLayerNeedAppear;

/**
 隐藏控制层
 
 When you want to disappear the control layer, you should call this method to disappear.
 This method will call the control layer delegate method.
 
 - (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer;
 */
- (void)controlLayerNeedDisappear;

///
/// 暂停的时候是否保持控制层显示
///
///         default value is NO
///
@property (nonatomic) BOOL pausedToKeepAppearState;
@end



#pragma mark - 自动管理 旋转和充满全屏

@interface SJBaseVideoPlayer (AutoManageViewToFitOnScreenOrRotation)

///
/// 自动管理 旋转和充满全屏
///
///         自动管理: 当视频宽>高时, 将触发旋转. 当视频宽<高时, 将触发充满全屏
///
@property (nonatomic) BOOL autoManageViewToFitOnScreenOrRotation; // default value is YES.

@end


#pragma mark - 充满全屏, 禁止旋转

///
/// 全屏或小屏, 但不触发旋转
/// v1.3.1 新增
///
@interface SJBaseVideoPlayer (FitOnScreen)

///
/// 使用充满全屏并且禁止旋转
///
///         当调用[player.fitOnScreenManager setFitOnScreen:... animated:...]时, 将自动设置为YES
///
@property (nonatomic) BOOL useFitOnScreenAndDisableRotation;

///
/// 使播放器充满屏幕并且禁止旋转
///
///         充满屏幕后, 播放器将无法触发旋转
///         了解更多请前往头文件查看
///
@property (nonatomic, strong, null_resettable) id<SJFitOnScreenManager> fitOnScreenManager;

///
/// 观察者
///
@property (nonatomic, strong, readonly) id<SJFitOnScreenManagerObserver> fitOnScreenObserver;

///
/// Whether fullscreen or smallscreen, this method does not trigger rotation.
/// 全屏或小屏, 此方法不触发旋转
/// Animated
///
@property (nonatomic, getter=isFitOnScreen) BOOL fitOnScreen;

/// Whether fullscreen or smallscreen, this method does not trigger rotation.
/// 全屏或小屏, 此方法不触发旋转
/// - animated : 是否动画
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated;

///
/// Whether fullscreen or smallscreen, this method does not trigger rotation.
/// 全屏或小屏, 此方法不触发旋转
/// - animated : 是否动画
/// - completionHandler : 操作完成的回调
///
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated completionHandler:(nullable void(^)(__kindof SJBaseVideoPlayer *player))completionHandler;
@end

#pragma mark - 旋转

@interface SJBaseVideoPlayer (Rotation)

///
/// 旋转管理类
///
///         如果需要禁止自动旋转, 可以设置`player.rotationManager.disabledAutorotation = YES;`
///         了解更多请前往头文件查看
///
@property (nonatomic, strong, null_resettable) id<SJRotationManager> rotationManager;

///
/// 观察者
///
///         当需要监听旋转时, 可以设置`player.rotationObserver.rotationDidStartExeBlock = ...;`
///         了解更多请前往头文件查看
///
@property (nonatomic, strong, readonly) id<SJRotationManagerObserver> rotationObserver;

///
/// 是否可以触发旋转
///
///         这个block的返回值将会作为触发旋转的一个条件, 当`return NO`时, 将不会触发旋转
///
@property (nonatomic, copy, nullable) BOOL(^shouldTriggerRotation)(__kindof SJBaseVideoPlayer *player);

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

@property (nonatomic, readonly) BOOL isTransitioning;
@property (nonatomic, readonly) BOOL isFullScreen;                              ///< 是否已全屏
@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;                 ///< 是否锁屏
@property (nonatomic, readonly) UIInterfaceOrientation currentOrientation;      ///< 当前的方向
@end





#pragma mark - 截图

@interface SJBaseVideoPlayer (Screenshot)

// - Presentation Size -

@property (nonatomic, copy, nullable) void(^presentationSizeDidChangeExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer);

@property (nonatomic, readonly) CGSize videoPresentationSize;


// - Screenshot -

- (UIImage * __nullable)screenshot;

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block;

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block;
@end





#pragma mark - 输出

@interface SJBaseVideoPlayer (Export)
- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                   duration:(NSTimeInterval)duration
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

///
/// 小浮窗控制
///
/// 默认不启用, 当需要开启时, 请设置`player.floatSmallViewController.enabled = YES;`
///
/// \code
///
///     // 1. 开启小浮窗控制. 滑动列表当视图消失时, 将显示小浮窗视图
///     _player.floatSmallViewController.enabled = YES;
///     // 2. 设置单击小浮窗执行的block
///     _player.floatSmallViewController.singleTappedOnTheFloatViewExeBlock = ...;
///     // 3. 设置双击小浮窗执行的block
///     _player.floatSmallViewController.doubleTappedOnTheFloatViewExeBlock = ...;
///
/// \endcode
///
@property (nonatomic, strong, null_resettable) id<SJFloatSmallViewController> floatSmallViewController;

///
/// 当开启小浮窗控制时, 播放结束后, 会默认隐藏小浮窗
///
/// - default value is YES.
///
@property (nonatomic) BOOL autoDisappearFloatSmallView;

///
/// 滚动出去后, 是否暂停. 默认为YES
///
/// - default value is YES.
///
@property (nonatomic) BOOL pauseWhenScrollDisappeared;

///
/// 滚动进入时, 是否恢复播放. 默认为YES
///
/// - default values is YES.
///
@property (nonatomic) BOOL resumePlaybackWhenScrollAppeared;

///
/// 滚动出去后, 是否隐藏播放器视图. 默认为YES
///
/// - default value is YES.
///
@property (nonatomic) BOOL hiddenViewWhenScrollDisappeared;

///
/// 是否在 scrollView 中播放
///
/// Whether to play on scrollView.
///
@property (nonatomic, readonly) BOOL isPlayOnScrollView;

///
/// 播放器视图是否显示
///
/// Whether the player is appeared when playing on scrollView. Because scrollview may be scrolled.
///
@property (nonatomic, readonly) BOOL isScrollAppeared;

@property (nonatomic, copy, nullable) void(^playerViewWillAppearExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer);
@property (nonatomic, copy, nullable) void(^playerViewWillDisappearExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer);
@end


#pragma mark - 字幕

@interface SJBaseVideoPlayer (Subtitles)
///
/// 字幕管理
///
/// \code
///
/// #import <SJBaseVideoPlayer/SJVideoPlayerURLAsset+SJSubtitlesAdd.h>
///
///     // 1. 创建资源
///     SJVideoPlayerURLAsset *asset = [SJVideoPlayerURLAsset.alloc initWithURL:URL];
///     // 2. 设置资源的字幕
///     asset.subtitles = @[[SJSubtitleItem.alloc initWithContent:@"我的故事" range:SJMakeTimeRange(start, duration)],
///                         [SJSubtitleItem.alloc initWithContent:@"从这里开始" range:SJMakeTimeRange(start, duration)]];
///     // 3. 进行播放, 字幕将在相应的时机自动显示
///     _player.URLAsset = asset;
///
///
///     // 以下是更多设置
///     _player.subtitleBottomMargin = 22.0;
///     _player.subtitleHorizontalMinMargin = 22.0;
///     _player.subtitlesPromptController.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
///     _player.subtitlesPromptController.view.layer.cornerRadius = 5;
///     _player.subtitlesPromptController.contentInsets = UIEdgeInsetsMake(12, 22, 12, 22);
///
/// \endcode
///
@property (nonatomic, strong, null_resettable) id<SJSubtitlesPromptController> subtitlesPromptController;

///
/// 字幕底部间距
///
///     default value is 22
///
@property (nonatomic) CGFloat subtitleBottomMargin;

///
/// 左右距离屏幕最小间距
///
///     default value is 22
///
@property (nonatomic) CGFloat subtitleHorizontalMinMargin;
@end


#pragma mark - 弹幕

@interface SJBaseVideoPlayer (Barrages)

///
/// 弹幕控制
///
/// \code
///
/// #import <SJBaseVideoPlayer/SJBarrageItem.h>
///
///     // 创建一条弹幕
///     SJBarrageItem *item = [SJBarrageItem.alloc initWithContent:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
///         make.append( @"我是一条弹幕消息" );
///         make.font([UIFont boldSystemFontOfSize:16]);
///         make.textColor(UIColor.whiteColor);
///         make.stroke(^(id<SJUTStroke>  _Nonnull make) {
///             make.color = UIColor.blackColor;
///             make.width = -1;
///         });
///     }]];
///
///     // 发送一条弹幕, 弹幕将自动显示
///     [self.player.barrageQueueController enqueue:item];
///
/// \endcode
///
@property (nonatomic, strong, null_resettable) id<SJBarrageQueueController> barrageQueueController;
@end

#pragma mark - 已弃用

@interface SJBaseVideoPlayer (Deprecated)
- (void)playWithURL:(NSURL *)URL; // 不再建议使用, 请使用`URLAsset`进行初始化
@property (nonatomic, strong, nullable) NSURL *assetURL;
@property (nonatomic, readonly) BOOL isPlayedToEndTime __deprecated_msg("use `isPlaybackFinished`;"); ///< 是否已播放结束(当前资源是否已播放结束)
@end
NS_ASSUME_NONNULL_END
