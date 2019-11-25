//
//  SJBaseVideoPlayerConst.m
//  Pods
//
//  Created by 畅三江 on 2019/8/6.
//

#import "SJBaseVideoPlayerConst.h"
#import "SJVideoPlayerPlayStatusDefines.h"

NS_ASSUME_NONNULL_BEGIN

NSInteger const SJBaseVideoPlayerViewTag = 10000;
NSInteger const SJBaseVideoPlayerPresentViewTag = 10001;

///
/// assetStatus 改变的通知
///
NSNotificationName const SJVideoPlayerAssetStatusDidChangeNotification = @"SJVideoPlayerAssetStatusDidChangeNotification";

///
/// timeControlStatus 改变的通知
///
NSNotificationName const SJVideoPlayerPlaybackTimeControlStatusDidChangeNotification = @"SJVideoPlayerPlaybackTimeControlStatusDidChangeNotification";

///
/// 播放完毕的通知
///
NSNotificationName const SJVideoPlayerDidPlayToEndTimeNotification = @"SJVideoPlayerDidPlayToEndTimeNotification";

///
/// 切换清晰度状态 改变的通知
///
NSNotificationName const SJVideoPlayerDefinitionSwitchStatusDidChangeNotification = @"SJVideoPlayerDefinitionSwitchStatusDidChangeNotification";

///
/// 当前播放时间 改变的通知
///
NSNotificationName const SJVideoPlayerCurrentTimeDidChangeNotification = @"SJVideoPlayerCurrentTimeDidChangeNotification";

///
/// 获取到播放时长的通知
///
NSNotificationName const SJVideoPlayerDurationDidChangeNotification = @"SJVideoPlayerDurationDidChangeNotification";

///
/// 缓冲时长 改变的通知
///
NSNotificationName const SJVideoPlayerPlayableDurationDidChangeNotification = @"SJVideoPlayerPlayableDurationDidChangeNotification";

///
/// 获取到视频宽高的通知
///
NSNotificationName const SJVideoPlayerPresentationSizeDidChangeNotification = @"SJVideoPlayerPresentationSizeDidChangeNotification";

///
/// 获取到播放类型的通知
///
NSNotificationName const SJVideoPlayerPlaybackTypeDidChangeNotification = @"SJVideoPlayerPlaybackTypeDidChangeNotification";

///
/// 锁屏状态 改变的通知
///
NSNotificationName const SJVideoPlayerLockedScreenDidChangeNotification = @"SJVideoPlayerLockedScreenDidChangeNotification";

///
/// 静音状态 改变的通知
///
NSNotificationName const SJVideoPlayerMutedDidChangeNotification = @"SJVideoPlayerMutedDidChangeNotification";

///
/// 音量 改变的通知
///
NSNotificationName const SJVideoPlayerVolumeDidChangeNotification = @"SJVideoPlayerVolumeDidChangeNotification";

///
/// 调速 改变的通知
///
NSNotificationName const SJVideoPlayerRateDidChangeNotification = @"SJVideoPlayerRateDidChangeNotification";


SJWaitingReason const SJWaitingToMinimizeStallsReason = @"AVPlayerWaitingToMinimizeStallsReason";
SJWaitingReason const SJWaitingWhileEvaluatingBufferingRateReason = @"AVPlayerWaitingWhileEvaluatingBufferingRateReason";
SJWaitingReason const SJWaitingWithNoAssetToPlayReason = @"AVPlayerWaitingWithNoItemToPlayReason";
NS_ASSUME_NONNULL_END
