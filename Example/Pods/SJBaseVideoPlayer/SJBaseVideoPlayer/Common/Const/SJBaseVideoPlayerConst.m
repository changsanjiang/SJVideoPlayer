//
//  SJBaseVideoPlayerConst.m
//  Pods
//
//  Created by 畅三江 on 2019/8/6.
//

#import "SJBaseVideoPlayerConst.h"
#import "SJVideoPlayerPlayStatusDefines.h"

NS_ASSUME_NONNULL_BEGIN

NSInteger const SJBaseVideoPlayerViewTag = 0xFFFFFFF0;
NSInteger const SJBaseVideoPlayerPresentViewTag = 0xFFFFFFF1;

///
/// assetStatus 改变的通知
///
NSNotificationName const SJVideoPlayerAssetStatusDidChangeNotification = @"SJVideoPlayerAssetStatusDidChangeNotification";

///
/// 切换清晰度状态 改变的通知
///
NSNotificationName const SJVideoPlayerDefinitionSwitchStatusDidChangeNotification = @"SJVideoPlayerDefinitionSwitchStatusDidChangeNotification";

///
/// 播放资源将要改变前发出的通知
///
NSNotificationName const SJVideoPlayerURLAssetWillChangeNotification = @"SJVideoPlayerURLAssetWillChangeNotification";
///
/// 播放资源改变后发出的通知
///
NSNotificationName const SJVideoPlayerURLAssetDidChangeNotification = @"SJVideoPlayerURLAssetDidChangeNotification";




///
/// 播放器收到App进入后台的通知后发出的通知
///
NSNotificationName const SJVideoPlayerApplicationDidEnterBackgroundNotification = @"SJVideoPlayerApplicationDidEnterBackgroundNotification";
///
/// 播放器收到App进入前台的通知后发出的通知
///
NSNotificationName const SJVideoPlayerApplicationWillEnterForegroundNotification = @"SJVideoPlayerApplicationWillEnterForegroundNotification";
///
/// 播放器收到App将要关闭的通知后发出的通知
///
NSNotificationName const SJVideoPlayerApplicationWillTerminateNotification = @"SJVideoPlayerApplicationWillTerminateNotification";

///
/// 播放器的playbackController将要进行销毁前的通知
///
NSNotificationName const SJVideoPlayerPlaybackControllerWillDeallocateNotification = @"SJVideoPlayerPlaybackControllerWillDeallocateNotification"; ///< 注意: object 为 SJMediaPlaybackController 的对象


///
/// timeControlStatus 改变的通知
///
NSNotificationName const SJVideoPlayerPlaybackTimeControlStatusDidChangeNotification = @"SJVideoPlayerPlaybackTimeControlStatusDidChangeNotification";
///
/// picture in picture status 改变的通知
///
NSNotificationName const SJVideoPlayerPictureInPictureStatusDidChangeNotification = @"SJVideoPlayerPictureInPictureStatusDidChangeNotification";
///
/// 播放完毕后发出的通知
///
NSNotificationName const SJVideoPlayerPlaybackDidFinishNotification = @"SJVideoPlayerPlaybackDidFinishNotification";

///
/// 执行replay发出的通知
///
NSNotificationName const SJVideoPlayerPlaybackDidReplayNotification = @"SJVideoPlayerPlaybackDidReplayNotification";
///
/// 执行stop前发出的通知
///
NSNotificationName const SJVideoPlayerPlaybackWillStopNotification = @"SJVideoPlayerPlaybackWillStopNotification";
///
/// 执行stop后发出的通知
///
NSNotificationName const SJVideoPlayerPlaybackDidStopNotification = @"SJVideoPlayerPlaybackDidStopNotification";
///
/// 执行refresh前发出的通知
///
NSNotificationName const SJVideoPlayerPlaybackWillRefreshNotification = @"SJVideoPlayerPlaybackWillRefreshNotification";
///
/// 执行refresh后发出的通知
///
NSNotificationName const SJVideoPlayerPlaybackDidRefreshNotification = @"SJVideoPlayerPlaybackDidRefreshNotification";
///
/// 执行seek前发出的通知
///
NSNotificationName const SJVideoPlayerPlaybackWillSeekNotification = @"SJVideoPlayerPlaybackWillSeekNotification";
///
/// 执行seek后发出的通知
///
NSNotificationName const SJVideoPlayerPlaybackDidSeekNotification = @"SJVideoPlayerPlaybackDidSeekNotification";



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
NSNotificationName const SJVideoPlayerScreenLockStateDidChangeNotification = @"SJVideoPlayerScreenLockStateDidChangeNotification";

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

SJFinishedReason const SJFinishedReasonToEndTimePosition = @"SJFinishedReasonToEndTimePosition";
SJFinishedReason const SJFinishedReasonToTrialEndPosition = @"SJFinishedReasonToTrialEndPosition";

NSString *const SJVideoPlayerNotificationUserInfoKeySeekTime = @"time";
NS_ASSUME_NONNULL_END
