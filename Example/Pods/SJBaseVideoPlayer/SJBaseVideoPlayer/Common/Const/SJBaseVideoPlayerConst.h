//
//  SJBaseVideoPlayerConst.h
//  Pods
//
//  Created by 畅三江 on 2019/8/6.
//

#import <Foundation/Foundation.h>

/**
 用于记录常量和一些未来可能提供的通知.
 */

NS_ASSUME_NONNULL_BEGIN

extern NSInteger const SJBaseVideoPlayerViewTag;
extern NSInteger const SJBaseVideoPlayerPresentViewTag;

// - Playback Notifications -


extern NSNotificationName const SJVideoPlayerAssetStatusDidChangeNotification;
extern NSNotificationName const SJVideoPlayerDefinitionSwitchStatusDidChangeNotification;

extern NSNotificationName const SJVideoPlayerURLAssetWillChangeNotification;
extern NSNotificationName const SJVideoPlayerURLAssetDidChangeNotification;

extern NSNotificationName const SJVideoPlayerApplicationDidEnterBackgroundNotification;
extern NSNotificationName const SJVideoPlayerApplicationWillEnterForegroundNotification;
extern NSNotificationName const SJVideoPlayerApplicationWillTerminateNotification;

extern NSNotificationName const SJVideoPlayerPlaybackControllerWillDeallocateNotification; ///< 注意: 发送对象变为了`SJMediaPlaybackController`(目前只此一个, 其他都为player对象)

extern NSNotificationName const SJVideoPlayerPlaybackTimeControlStatusDidChangeNotification;
extern NSNotificationName const SJVideoPlayerPictureInPictureStatusDidChangeNotification;
extern NSNotificationName const SJVideoPlayerPlaybackDidFinishNotification;         // 播放完毕后发出的通知
extern NSNotificationName const SJVideoPlayerPlaybackDidReplayNotification;         // 执行replay发出的通知
extern NSNotificationName const SJVideoPlayerPlaybackWillStopNotification;          // 执行stop前发出的通知
extern NSNotificationName const SJVideoPlayerPlaybackDidStopNotification;           // 执行stop后发出的通知
extern NSNotificationName const SJVideoPlayerPlaybackWillRefreshNotification;       // 执行refresh前发出的通知
extern NSNotificationName const SJVideoPlayerPlaybackDidRefreshNotification;        // 执行refresh后发出的通知
extern NSNotificationName const SJVideoPlayerPlaybackWillSeekNotification;          // 执行seek前发出的通知
extern NSNotificationName const SJVideoPlayerPlaybackDidSeekNotification;           // 执行seek后发出的通知

extern NSNotificationName const SJVideoPlayerCurrentTimeDidChangeNotification;
extern NSNotificationName const SJVideoPlayerDurationDidChangeNotification;
extern NSNotificationName const SJVideoPlayerPlayableDurationDidChangeNotification;
extern NSNotificationName const SJVideoPlayerPresentationSizeDidChangeNotification;
extern NSNotificationName const SJVideoPlayerPlaybackTypeDidChangeNotification;

extern NSNotificationName const SJVideoPlayerRateDidChangeNotification;
extern NSNotificationName const SJVideoPlayerMutedDidChangeNotification;
extern NSNotificationName const SJVideoPlayerVolumeDidChangeNotification;
extern NSNotificationName const SJVideoPlayerScreenLockStateDidChangeNotification;

extern NSString *const SJVideoPlayerNotificationUserInfoKeySeekTime;
NS_ASSUME_NONNULL_END
