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
extern NSNotificationName const SJVideoPlayerPlaybackDidFinishNotification;         // 播放完毕后发出的通知
extern NSNotificationName const SJVideoPlayerPlaybackDidReplayNotification;         // 调用了replay发出的通知
extern NSNotificationName const SJVideoPlayerPlaybackWillStopNotification;          // 调用了stop前发出的通知
extern NSNotificationName const SJVideoPlayerPlaybackDidStopNotification;           // 调用了stop后发出的通知
extern NSNotificationName const SJVideoPlayerPlaybackWillRereshNotification;        // 调用了refresh前发出的通知
extern NSNotificationName const SJVideoPlayerPlaybackDidRereshNotification;         // 调用了refresh后发出的通知

extern NSNotificationName const SJVideoPlayerCurrentTimeDidChangeNotification;
extern NSNotificationName const SJVideoPlayerDurationDidChangeNotification;
extern NSNotificationName const SJVideoPlayerPlayableDurationDidChangeNotification;
extern NSNotificationName const SJVideoPlayerPresentationSizeDidChangeNotification;
extern NSNotificationName const SJVideoPlayerPlaybackTypeDidChangeNotification;

extern NSNotificationName const SJVideoPlayerRateDidChangeNotification;
extern NSNotificationName const SJVideoPlayerMutedDidChangeNotification;
extern NSNotificationName const SJVideoPlayerVolumeDidChangeNotification;
extern NSNotificationName const SJVideoPlayeScreenLockStateDidChangeNotification;

NS_ASSUME_NONNULL_END
