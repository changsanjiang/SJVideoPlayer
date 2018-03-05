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

@protocol SJVideoPlayerControlLayerDataSource, SJVideoPlayerControlLayerDelegate;


@interface SJBaseVideoPlayer : NSObject

+ (instancetype)player;

- (instancetype)init;

@property (nonatomic, weak, readwrite, nullable) id <SJVideoPlayerControlLayerDataSource> controlLayerDataSource;

@property (nonatomic, weak, readwrite, nullable) id <SJVideoPlayerControlLayerDelegate> controlLayerDelegate;

@property (nonatomic, strong, readonly) UIView *view;                   // 播放器视图

@property (nonatomic, assign, readonly) SJVideoPlayerPlayState state;   // 播放状态

@property (nonatomic, strong, readonly, nullable) NSError *error;       // 播放报错的error

@property (nonatomic, strong, nullable) UIImage *placeholder;           // 占位图

@end


#pragma mark - 播放

@interface SJBaseVideoPlayer (Play)

@property (nonatomic, strong, readwrite, nullable) NSURL *assetURL;

@property (nonatomic, strong, readwrite, nullable) SJVideoPlayerURLAsset *URLAsset;

- (void)playWithURL:(NSURL *)playURL;

- (void)playWithURL:(NSURL *)playURL jumpedToTime:(NSTimeInterval)time;

- (void)refresh;

@property (nonatomic, copy, readwrite, nullable) void(^assetDeallocExeBlock)(__kindof SJBaseVideoPlayer *videoPlayer);

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

@property (nonatomic, readwrite) BOOL mute; // default is no. 静音.

@property (nonatomic, readwrite, getter=isLockedScreen) BOOL lockedScreen; // 锁定播放器. 所有交互事件将不会触发.

@property (nonatomic, readwrite, getter=isAutoPlay) BOOL autoPlay; // 自动播放. default is YES.

- (BOOL)play;

- (BOOL)pause;                                           // 调用此方法, 表示开发者暂停.
- (void)pauseForUser;                                    // 调用此方法, 表示用户暂停.
@property (nonatomic, assign, readonly) BOOL userPaused; // 区分是用户暂停的, 还是开发者暂停的

- (void)stop;

- (void)stopAndFadeOut; // 停止播放并淡出

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


#pragma mark - Gesture

@interface SJBaseVideoPlayer (GestureControl)

@property (nonatomic, readwrite) SJDisablePlayerGestureTypes disableGestureTypes;

@end


#pragma mark - 控制层

@interface SJBaseVideoPlayer (ControlLayer)

@property (nonatomic, readwrite) BOOL enableControlLayerDisplayController; // default is YES. 是否开启控制层[显示/隐藏]的管理器
@property (nonatomic, readonly) BOOL controlLayerAppeared; // 控制层是否显示
@property (nonatomic, copy, readwrite, nullable) void(^controlLayerAppearStateChanged)(__kindof SJBaseVideoPlayer *player, BOOL state);

- (void)controlLayerNeedAppear;
- (void)controlLayerNeedDisappear;

// 控制层是否显示
@property (nonatomic, readonly) BOOL controlViewDisplayed NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "use `controlLayerAppeared`");

/*!
 *  Call when the control view is appear or disappear.
 *
 *  控制视图隐藏或显示的时候调用.
 **/
@property (nonatomic, copy, readwrite, nullable) void(^controlViewDisplayStatus)(__kindof SJBaseVideoPlayer *player, BOOL displayed) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "use `controlLayerAppearStateChanged`");

@end


#pragma mark - 屏幕旋转

@interface SJBaseVideoPlayer (Rotation)

@property (nonatomic, readwrite) SJSupportedRotateViewOrientation supportedRotateViewOrientation; // 播放器旋转支持的方向, 默认为`SJSupportedRotateViewOrientation_All`

@property (nonatomic, readwrite) SJRotateViewOrientation rotateOrientation; // 直接旋转到指定方向, 可指定为`横屏播放`. 默认是`竖屏`.

- (void)rotation; // 旋转

@property (nonatomic, readwrite) BOOL disableRotation; // 禁止播放器旋转

@property (nonatomic, copy, readwrite, nullable) void(^willRotateScreen)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen); // 将要旋转的时候调用

@property (nonatomic, copy, readwrite, nullable) void(^rotatedScreen)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen);    // 已旋转

@property (nonatomic, readonly) BOOL isFullScreen;  // 是否全屏

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


#pragma mark - 在`tableView`或`collectionView`上播放

@interface SJBaseVideoPlayer (ScrollView)

@property (nonatomic, assign, readonly) BOOL playOnScrollView;      // 是否在scrollView上播放
@property (nonatomic, assign, readonly) BOOL isScrollAppeared;      // 播放器滚动到显示的状态.

@property (nonatomic, assign, readonly) BOOL playOnCell NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "use `playOnScrollView`");            // 是在cell上播放
@property (nonatomic, assign, readonly) BOOL scrollIntoTheCell NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "use `isScrollAppeared`");     // 播放器滚进了单元格中

@end


#pragma mark - 提示

@interface SJBaseVideoPlayer (Prompt)

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



#pragma mark - Protocol

@protocol SJVideoPlayerControlLayerDataSource <NSObject>

@required

- (UIView *)controlView;

/// 控制层需要隐藏之前会调用这个方法, 如果返回NO, 将不调用`controlLayerNeedDisappear:`.
- (BOOL)controlLayerDisappearCondition;

/// 触发手势之前会调用这个方法, 如果返回NO, 将不调用水平手势相关的代理方法.
- (BOOL)triggerGesturesCondition:(CGPoint)location;

@optional
/// 安装完控制层的回调.
- (void)installedControlViewToVideoPlayer:(SJBaseVideoPlayer *)videoPlayer;

@end


@protocol SJVideoPlayerControlLayerDelegate <NSObject>

@optional

#pragma mark - 播放之前/状态
/// 当设置播放资源时调用.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset;

/// 播放状态改变.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer stateChanged:(SJVideoPlayerPlayState)state;  

/// 播放报错
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer playFailed:(NSError *)error;

#pragma mark - 进度
/// 播放进度回调.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer
        currentTime:(NSTimeInterval)currentTime currentTimeStr:(NSString *)currentTimeStr
          totalTime:(NSTimeInterval)totalTime totalTimeStr:(NSString *)totalTimeStr;

/// 缓冲的进度.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer loadedTimeProgress:(float)progress;

/// 开始缓冲.
- (void)startLoading:(SJBaseVideoPlayer *)videoPlayer;

/// 缓冲完成.
- (void)loadCompletion:(SJBaseVideoPlayer *)videoPlayer;

#pragma mark - 显示/消失
/// 控制层需要显示.
- (void)controlLayerNeedAppear:(SJBaseVideoPlayer *)videoPlayer;

/// 控制层需要隐藏.
- (void)controlLayerNeedDisappear:(SJBaseVideoPlayer *)videoPlayer;

///  在`tableView`或`collectionView`上将要显示的时候调用.
- (void)videoPlayerWillAppearInScrollView:(SJBaseVideoPlayer *)videoPlayer;

///  在`tableView`或`collectionView`上将要消失的时候调用.
- (void)videoPlayerWillDisappearInScrollView:(SJBaseVideoPlayer *)videoPlayer;

#pragma mark - 锁屏
/// 播放器被锁屏, 此时将不旋转, 不触发手势相关事件.
- (void)lockedVideoPlayer:(SJBaseVideoPlayer *)videoPlayer;

/// 播放器解除锁屏.
- (void)unlockedVideoPlayer:(SJBaseVideoPlayer *)videoPlayer;

#pragma mark - 屏幕旋转
/// 播放器将要旋转屏幕, `isFull`如果为`YES`, 则全屏.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull;

/// 旋转完毕.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer didEndRotation:(BOOL)isFull;

#pragma mark - 音量 / 亮度 / 播放速度
/// 静音开关变更
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer muteChanged:(BOOL)mute;

/// 声音被改变.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer volumeChanged:(float)volume;

/// 亮度被改变.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer brightnessChanged:(float)brightness;

/// 播放速度被改变.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer rateChanged:(float)rate;

#pragma mark - 水平手势
/// 水平方向开始拖动.
- (void)horizontalDirectionWillBeginDragging:(SJBaseVideoPlayer *)videoPlayer;

/// 水平方向拖动中. `translation`为此次增加的值.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer horizontalDirectionDidDrag:(CGFloat)translation;

/// 水平方向拖动结束.
- (void)horizontalDirectionDidEndDragging:(SJBaseVideoPlayer *)videoPlayer;

#pragma mark - size
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer presentationSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
