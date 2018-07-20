//
//  SJVideoPlayerControlLayerProtocol.h
//  Project
//
//  Created by 畅三江 on 2018/6/1.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#ifndef SJVideoPlayerControlLayerProtocol_h
#define SJVideoPlayerControlLayerProtocol_h
#import <UIKit/UIKit.h>
#import "SJNetworkStatus.h"
#import "SJVideoPlayerState.h"
@protocol SJPlayStatusControlDelegate, SJLoadingControlDelegate, SJNetworkStatusControlDelegate, SJLockScreenStateControlDelegate, SJAppActivityControlDelegate, SJVolumeBrightnessRateControlDelegate, SJGestureControlDelegate, SJRotationControlDelegate, SJDeprecatedControlDelegate, SJFitOnScreenControlDelegate;
@class SJBaseVideoPlayer, SJVideoPlayerURLAsset;



@protocol SJVideoPlayerControlLayerDataSource <NSObject>
@required
/// Please return to the root view of the control layer, which will be added to the player view.
/// 请返回控制层的根视图
/// 这个视图将会添加的播放器中
- (UIView *)controlView;

/// This method is called before the control layer needs to be hidden, and `controlLayerNeedDisappear:` will not be called if NO is returned.
/// 此方法针对`自动隐藏`的控制. 如果返回YES, 将会触发隐藏控制层的相关方法(见下delegate的`controlLayerNeedDisappear:`)
///
/// 关于`自动隐藏`:
/// * 当控制层显示时, 播放器会在一段时间(默认3秒)后尝试隐藏控制层, 见delegate中的`controlLayerNeedAppear:`和`controlLayerNeedDisappear:`
- (BOOL)controlLayerDisappearCondition;

/// This method is called before the gesture is triggered. If NO is returned, will not trigger gestures.
/// 此方法将作为手势触发的一个条件, 如果返回NO, 将不会触发任何手势.
- (BOOL)triggerGesturesCondition:(CGPoint)location;

@optional
/// Call it When installed control view to player view.
/// 当安装好控制层后, 会回调这个方法
- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;
@end




@protocol SJVideoPlayerControlLayerDelegate <
    SJPlayStatusControlDelegate,
    SJLoadingControlDelegate,
    SJRotationControlDelegate,
    SJGestureControlDelegate,
    SJNetworkStatusControlDelegate,
    SJVolumeBrightnessRateControlDelegate,
    SJLockScreenStateControlDelegate,
    SJAppActivityControlDelegate,
    SJDeprecatedControlDelegate,
    SJFitOnScreenControlDelegate
>
@required
/// This method will be called when the control layer needs to be appear. You should do some appear work here.
/// 控制层需要显示的时候, 会回调这个方法. 你应该在这里做一些显示的工作
///
/// 关于控制层的显示: 默认情况下(videoPlayer.enableControlLayerDisplayController==YES)
/// * 当调用[videoPlayer controlLayerNeedAppear]时, 此时会立即回调这个方法
/// * 每当播放一个新的资源时, 1秒后播放器会自动回调这个方法
- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer;

/// This method will be called when the control layer needs to be disappear. You should do some disappear work here.
/// 当控制层需要隐藏的时候, 会回调这个方法. 你应该在这个做一些隐藏的工作
///
/// 关于控制层的隐藏: 默认情况下(videoPlayer.enableControlLayerDisplayController==YES)
/// * 当调用[videoPlayer controlLayerNeedDisappear]时, 此时会立即回调这个方法
/// * 当控制层显示时, 默认会在3秒后, 自动调用这个方法, 隐藏控制层
- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer;

@optional
/// Call it when `tableView` or` collectionView` is about to appear. Because scrollview may be scrolled.
/// 当滚动scrollView时, 播放器即将出现时会回调这个方法
- (void)videoPlayerWillAppearInScrollView:(__kindof SJBaseVideoPlayer *)videoPlayer;

/// Call it when `tableView` or` collectionView` is about to disappear. Because scrollview may be scrolled.
/// 当滚动scrollView时, 播放器即将消失时会回调这个方法
- (void)videoPlayerWillDisappearInScrollView:(__kindof SJBaseVideoPlayer *)videoPlayer;
@end



@protocol SJPlayStatusControlDelegate <NSObject>
@optional
/// When the player is prepare to play a new asset, this method will be called.
/// 当播放器准备播放一个新的资源时, 会回调这个方法
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset;

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer statusDidChanged:(SJVideoPlayerPlayStatus)status;
/// Deprecated
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer stateChanged:(SJVideoPlayerPlayState)state __deprecated_msg("已弃用, 请使用`videoPlayer:statusDidChanged:`;");

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer
        currentTime:(NSTimeInterval)currentTime currentTimeStr:(NSString *)currentTimeStr
          totalTime:(NSTimeInterval)totalTime totalTimeStr:(NSString *)totalTimeStr;

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer presentationSize:(CGSize)size;

@end



@protocol SJVolumeBrightnessRateControlDelegate <NSObject>
@optional
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer muteChanged:(BOOL)mute;
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer volumeChanged:(float)volume;
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer brightnessChanged:(float)brightness;
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer rateChanged:(float)rate;
@end



@protocol SJLoadingControlDelegate <NSObject>
@optional
/// When buffer progress changed, this method will be called.
/// 当缓冲进度更新的实时回调
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer loadedTimeProgress:(float)progress;

/// When player start the buffer, this method will be called.
/// 开始缓冲时调用
- (void)startLoading:(__kindof SJBaseVideoPlayer *)videoPlayer;

/// When the buffer is cancelled, this method will be called.
/// 取消缓冲时调用
- (void)cancelLoading:(__kindof SJBaseVideoPlayer *)videoPlayer;

/// When the buffer can continue to play, this method will be called.
/// 当缓冲可以继续播放的时候调用
- (void)loadCompletion:(__kindof SJBaseVideoPlayer *)videoPlayer;
@end



@protocol SJRotationControlDelegate <NSObject>
@optional
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
/// horizontal gesture
/// When horizontal direction is going to start dragging, this method will be called
/// 水平手势
/// 水平方向将要开始拖拽
- (void)horizontalDirectionWillBeginDragging:(__kindof SJBaseVideoPlayer *)videoPlayer;

/// horizontal gesture
/// progress represents the current drag progress
/// 水平手势
/// 水平方向拖动中, progress 为当前的拖拽进度
/// progress 表示当前拖拽的进度, 不是播放的进度
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer horizontalDirectionDidMove:(CGFloat)progress;

/// 水平手势
/// 水平方向拖动结束.
- (void)horizontalDirectionDidEndDragging:(__kindof SJBaseVideoPlayer *)videoPlayer;
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



@protocol SJAppActivityControlDelegate <NSObject>
@optional
- (void)appWillResignActive:(__kindof SJBaseVideoPlayer *)videoPlayer;
- (void)appDidBecomeActive:(__kindof SJBaseVideoPlayer *)videoPlayer;
- (void)appWillEnterForeground:(__kindof SJBaseVideoPlayer *)videoPlayer;
- (void)appDidEnterBackground:(__kindof SJBaseVideoPlayer *)videoPlayer;
@end


/// 一些已弃用的方法
@protocol SJDeprecatedControlDelegate <NSObject>
@optional
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer horizontalDirectionDidDrag:(CGFloat)translation __deprecated_msg("use `videoPlayer:horizontalDirectionDidMove:`;");
@end

#endif /* SJVideoPlayerControlLayerProtocol_h */
