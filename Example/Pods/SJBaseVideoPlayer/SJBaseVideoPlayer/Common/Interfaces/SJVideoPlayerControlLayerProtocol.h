//
//  SJVideoPlayerControlLayerProtocol.h
//  Project
//
//  Created by 畅三江 on 2018/6/1.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#ifndef SJVideoPlayerControlLayerProtocol_h
#define SJVideoPlayerControlLayerProtocol_h
#import <UIKit/UIKit.h>
#import "SJReachabilityDefines.h"
#import "SJVideoPlayerPlayStatusDefines.h"
#import "SJVideoPlayerPlaybackControllerDefines.h"
#import "SJPlayerGestureControlDefines.h"

@protocol SJPlaybackInfoDelegate,
SJNetworkStatusControlDelegate,
SJLockScreenStateControlDelegate,
SJAppActivityControlDelegate,
SJVolumeBrightnessRateControlDelegate,
SJGestureControlDelegate,
SJRotationControlDelegate,
SJFitOnScreenControlDelegate,
SJSwitchVideoDefinitionControlDelegate,
SJPlaybackControlDelegate;

@class SJBaseVideoPlayer, SJVideoPlayerURLAsset;



@protocol SJVideoPlayerControlLayerDataSource <NSObject>
@required
/// Please return to the control view of the control layer, which will be added to the player view.
/// 请返回控制层的根视图
/// 这个视图将会添加的播放器中
- (UIView *)controlView;

@optional
/// This method will be called When installed control view of control layer to the video player.
/// 当安装好控制层后, 会回调这个方法
- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;
@end


@protocol SJVideoPlayerControlLayerDelegate <
    SJPlaybackInfoDelegate, 
    SJRotationControlDelegate,
    SJGestureControlDelegate,
    SJNetworkStatusControlDelegate,
    SJVolumeBrightnessRateControlDelegate,
    SJLockScreenStateControlDelegate,
    SJAppActivityControlDelegate,
    SJFitOnScreenControlDelegate,
    SJSwitchVideoDefinitionControlDelegate,
    SJPlaybackControlDelegate
>
@optional
/// This method will be called when the control layer needs to be appear.
/// You should do some appear work here.
/// 控制层需要显示. 你应该在这里做一些显示的工作
- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer;

/// This method will be called when the control layer needs to be disappear.
/// You should do some disappear work here.
/// 控制层需要隐藏. 你应该在这个做一些隐藏的工作
- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer;

/// Asks the delegate if the control layer can automatically disappear.
/// 控制层是否可以自动隐藏
- (BOOL)controlLayerOfVideoPlayerCanAutomaticallyDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer;

/// Call it when `tableView` or` collectionView` is about to appear. Because scrollview may be scrolled.
/// 当滚动scrollView时, 播放器即将出现时会回调这个方法
- (void)videoPlayerWillAppearInScrollView:(__kindof SJBaseVideoPlayer *)videoPlayer;

/// Call it when `tableView` or` collectionView` is about to disappear. Because scrollview may be scrolled.
/// 当滚动scrollView时, 播放器即将消失时会回调这个方法
- (void)videoPlayerWillDisappearInScrollView:(__kindof SJBaseVideoPlayer *)videoPlayer;
@end


@protocol SJPlaybackControlDelegate <NSObject>
@optional
- (BOOL)canPerformPlayForVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;
- (BOOL)canPerformPauseForVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;
- (BOOL)canPerformStopForVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;
@end



@protocol SJPlaybackInfoDelegate <NSObject>
@optional

/// When the player is prepare to play a new asset, this method will be called.
/// 当播放器准备播放一个新的资源时, 会回调这个方法
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset;

///
/// 播放状态改变后的回调
///
///     以下状态发生变更时将会触发该回调
///     1.  timeControlStatus
///     2.  assetStatus
///     3.  播放完毕
///
- (void)videoPlayerPlaybackStatusDidChange:(__kindof SJBaseVideoPlayer *)videoPlayer;

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer pictureInPictureStatusDidChange:(SJPictureInPictureStatus)status API_AVAILABLE(ios(14.0));

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer currentTimeDidChange:(NSTimeInterval)currentTime;
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer durationDidChange:(NSTimeInterval)duration;
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer playableDurationDidChange:(NSTimeInterval)duration;

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer playbackTypeDidChange:(SJPlaybackType)playbackType;
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer presentationSizeDidChange:(CGSize)size;
@end



@protocol SJVolumeBrightnessRateControlDelegate <NSObject>
@optional
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer muteChanged:(BOOL)mute;
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer volumeChanged:(float)volume;
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer brightnessChanged:(float)brightness;
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer rateChanged:(float)rate;
@end


@protocol SJRotationControlDelegate <NSObject>
@optional
/// Whether trigger rotation of video player
- (BOOL)canTriggerRotationOfVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;

/// Call it when player will rotate, `isFull` if YES, then full screen.
/// 当播放器将要旋转的时候, 会回调这个方法
/// isFull 标识是否是全屏
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull;

/// When rotated player, this method will be called.
/// 当播放器旋转完成的时候, 会回调这个方法
/// isFull 标识是否是全屏
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer didEndRotation:(BOOL)isFull;
@end


/// v1.3.1 新增
/// 全屏但不旋转
@protocol SJFitOnScreenControlDelegate <NSObject>
@optional
///  When `fitOnScreen` of player will change, this method will be called;
/// 当播放器即将全屏(但不旋转)时, 这个方法将会被调用
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willFitOnScreen:(BOOL)isFitOnScreen;
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer didCompleteFitOnScreen:(BOOL)isFitOnScreen;
@end



@protocol SJGestureControlDelegate <NSObject>
@optional
/// Asks the delegate if gesture should trigger in the video player.
/// 是否可以触发某个手势
- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location;

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer panGestureTriggeredInTheHorizontalDirection:(SJPanGestureRecognizerState)state progressTime:(NSTimeInterval)progressTime;

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer longPressGestureStateDidChange:(SJLongPressGestureRecognizerState)state;
@end



@protocol SJNetworkStatusControlDelegate <NSObject>
@optional
/// 网络状态变更
/// 当网络状态变更时, 会回调这个方法
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer reachabilityChanged:(SJNetworkStatus)status;
@end



@protocol SJLockScreenStateControlDelegate <NSObject>
@optional
/// This Tap gesture triggered when player locked screen.
/// If player locked(videoPlayer.lockedScreen == YES), When the user tapped on the player this method will be called.
/// 这是一个只有在播放器锁屏状态下, 才会回调的方法
/// 当播放器锁屏后, 用户每次点击都会回调这个方法
- (void)tappedPlayerOnTheLockedState:(__kindof SJBaseVideoPlayer *)videoPlayer;

/// Call it when set videoPlayer.lockedScreen == YES.
/// 当设置 videoPlayer.lockedScreen == YES 时, 这个方法将会调用
- (void)lockedVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;

/// Call it when set videoPlayer.lockedScreen == NO.
/// 当设置 videoPlayer.lockedScreen == NO 时, 这个方法将会调用
- (void)unlockedVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;
@end



@protocol SJSwitchVideoDefinitionControlDelegate <NSObject>
@optional
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer switchingDefinitionStatusDidChange:(SJDefinitionSwitchStatus)status media:(id<SJMediaModelProtocol>)media;
@end



@protocol SJAppActivityControlDelegate <NSObject>
@optional
- (void)applicationWillEnterForegroundWithVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;
- (void)applicationDidBecomeActiveWithVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;
- (void)applicationWillResignActiveWithVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;
- (void)applicationDidEnterBackgroundWithVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;
@end
#endif /* SJVideoPlayerControlLayerProtocol_h */
