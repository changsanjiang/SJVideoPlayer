//
//  SJBaseVideoPlayer.h
//  SJBaseVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//
//  https://github.com/changsanjiang/SJBaseVideoPlayer  没有控制层的播放器(如果想自定义控制层, 可以使用它)
//  https://github.com/changsanjiang/SJVideoPlayer      有默认控制层的播放器
//  changsanjiang@gmail.com
//
/**
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
 */

#import <UIKit/UIKit.h>
#import "SJVideoPlayerURLAsset.h"
#import "SJVideoPlayerState.h"
#import "SJVideoPlayerPreviewInfo.h"
#import <SJPrompt/SJPrompt.h>
#import <SJOrentationObserver/SJOrentationObserver.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJDisablePlayerGestureTypes) {
    SJDisablePlayerGestureTypes_None,
    SJDisablePlayerGestureTypes_SingleTap = 1 << 0,
    SJDisablePlayerGestureTypes_DoubleTap = 1 << 1,
    SJDisablePlayerGestureTypes_Pan = 1 << 2,
    SJDisablePlayerGestureTypes_Pinch = 1 << 3,
    SJDisablePlayerGestureTypes_All = 1 << 4
};

typedef NS_ENUM(NSInteger, SJNetworkStatus) {
    SJNetworkStatus_NotReachable = 0,
    SJNetworkStatus_ReachableViaWWAN = 1,
    SJNetworkStatus_ReachableViaWiFi = 2
};


@protocol SJVideoPlayerControlLayerDataSource, SJVideoPlayerControlLayerDelegate;


@interface SJBaseVideoPlayer : NSObject

+ (instancetype)player;

- (instancetype)init;

@property (nonatomic, weak, readwrite, nullable) id <SJVideoPlayerControlLayerDataSource> controlLayerDataSource;

@property (nonatomic, weak, readwrite, nullable) id <SJVideoPlayerControlLayerDelegate> controlLayerDelegate;

@property (nonatomic, strong, readonly) UIView *view;

/**
 play state.
 
 If this value is changed, the delegate method will be called.  - (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer stateChanged:(SJVideoPlayerPlayState)state;
 
 readonly.
 */
@property (nonatomic, readonly) SJVideoPlayerPlayState state;

@property (nonatomic, strong, readonly, nullable) NSError *error;

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

/**
 Hidden Prompt.
 */
- (void)hiddenTitle;

@end





#pragma mark - 时间

@interface SJBaseVideoPlayer (Time)

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
 If Yes, player will be called pause method When Received `UIApplicationWillResignActiveNotification` notification.
 default is YES.
 
 readwrite.
 */
@property (nonatomic) BOOL pauseWhenAppResignActive;

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
 YES -> Appear.
 NO  -> Disappear.
 
 readonly.
 */
@property (nonatomic, readonly) BOOL controlLayerAppeared;

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
 Whether to disable rotation.
 
 readwrite.
 You can disable the player rotation when appropriate.
 For example when the controller is about to disappear.
 */
@property (nonatomic) BOOL disableRotation;

/**
 This is the player supports orientation when autorotation. default is `SJSupportedRotateViewOrientation_All`.
 
 readwrite.
 */
@property (nonatomic) SJSupportedRotateViewOrientation supportedRotateViewOrientation;

/**
 Rotate to the specified orientation, Animated.
 Any value of SJRotateViewOrientation.
 
 readwrite.
 */
@property (nonatomic) SJRotateViewOrientation rotateOrientation;

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
- (void)rotation;

/**
 Rotate to the specified orientation.
 
 @param orientation     Any value of SJRotateViewOrientation.
 @param animated        Whether or not animation.
 */
- (void)rotate:(SJRotateViewOrientation)orientation animated:(BOOL)animated;

/**
 Rotate to the specified orientation.
 
 @param orientation     Any value of SJRotateViewOrientation.
 @param animated        Whether or not animation.
 @param block           The block invoked when player rotated.
 */
- (void)rotate:(SJRotateViewOrientation)orientation animated:(BOOL)animated completion:(void (^ _Nullable)(__kindof SJBaseVideoPlayer *player))block;

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
 @param progress            progress
 @param completion 	        completion
 @param failure 	        failure
 */
- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    endTime:(NSTimeInterval)endTime
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, float progress))progress
                 completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, SJVideoPlayerURLAsset *asset, NSURL *fileURL, UIImage *thumbImage))completion
                    failure:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, NSError *error))failure;

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





#pragma mark - ControlLayerProtocol

@protocol SJVideoPlayerControlLayerDataSource <NSObject>

@required

- (UIView *)controlView;

/**
 This method is called before the control layer needs to be hidden, and `controlLayerNeedDisappear:` will not be called if NO is returned.
 控制层需要隐藏之前会调用这个方法, 如果返回NO, 将不调用`controlLayerNeedDisappear:`
 */
- (BOOL)controlLayerDisappearCondition;

/**
 This method is called before the gesture is triggered. If NO is returned, the proxy method associated with the horizontal gesture is not called.
 触发手势之前会调用这个方法, 如果返回NO, 将不调用水平手势相关的代理方法.
 */
- (BOOL)triggerGesturesCondition:(CGPoint)location;

@optional
/**
 Call it When installed control view to player view.
 */
- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;

@end


@protocol SJVideoPlayerControlLayerDelegate <NSObject>

@required
/**
 This method will be called when the control layer needs to be appear. You should do some appear work here.
 */
- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer;

/**
 This method will be called when the control layer needs to be disappear. You should do some disappear work here.
 */
- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer;


@optional
/**
 Call it when `tableView` or` collectionView` is about to appear. Because scrollview may be scrolled.
 */
- (void)videoPlayerWillAppearInScrollView:(__kindof SJBaseVideoPlayer *)videoPlayer;

/**
 Call it when `tableView` or` collectionView` is about to disappear. Because scrollview may be scrolled.
 */
- (void)videoPlayerWillDisappearInScrollView:(__kindof SJBaseVideoPlayer *)videoPlayer;


#pragma mark - 播放之前/状态

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset;

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer stateChanged:(SJVideoPlayerPlayState)state;

#pragma mark - 进度

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer
        currentTime:(NSTimeInterval)currentTime currentTimeStr:(NSString *)currentTimeStr
          totalTime:(NSTimeInterval)totalTime totalTimeStr:(NSString *)totalTimeStr;

/**
 Call it When buffer progress changed.
 缓冲进度改变的时候调用.
 */
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer loadedTimeProgress:(float)progress;

- (void)startLoading:(__kindof SJBaseVideoPlayer *)videoPlayer;

- (void)cancelLoading:(__kindof SJBaseVideoPlayer *)videoPlayer;

/**
 Call it when stop load.
 */
- (void)loadCompletion:(__kindof SJBaseVideoPlayer *)videoPlayer;

#pragma mark - 锁屏
/**
 Call it when set videoPlayer.lockedScreen == YES.
 */
- (void)lockedVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;

/**
 Call it when set videoPlayer.lockedScreen == NO.
 */
- (void)unlockedVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;

#pragma mark - 屏幕旋转
/**
 Call it when player will rotate the screen, `isFull` if YES, then full screen.
 */
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull;

/**
 Call it when player rotated screen.
 */
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer didEndRotation:(BOOL)isFull;

#pragma mark - 音量 / 亮度 / 播放速度

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer muteChanged:(BOOL)mute;

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer volumeChanged:(float)volume;

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer brightnessChanged:(float)brightness;

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer rateChanged:(float)rate;

#pragma mark - 水平手势
/// 水平方向开始拖动.
- (void)horizontalDirectionWillBeginDragging:(__kindof SJBaseVideoPlayer *)videoPlayer;

/**
 @param progress drag progress
 */
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer horizontalDirectionDidMove:(CGFloat)progress;

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer horizontalDirectionDidDrag:(CGFloat)translation NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "use `videoPlayer:horizontalDirectionDidMove:`");

/// 水平方向拖动结束.
- (void)horizontalDirectionDidEndDragging:(__kindof SJBaseVideoPlayer *)videoPlayer;

#pragma mark - size
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer presentationSize:(CGSize)size;

#pragma mark - Network
/// 网络状态变更
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer reachabilityChanged:(SJNetworkStatus)status;

@end

NS_ASSUME_NONNULL_END
