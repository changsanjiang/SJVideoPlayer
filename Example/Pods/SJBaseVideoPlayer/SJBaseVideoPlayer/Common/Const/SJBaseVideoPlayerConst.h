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

// - Playback Control -


extern NSNotificationName const SJVideoPlayerAssetStatusDidChangeNotification;
extern NSNotificationName const SJVideoPlayerPlaybackTimeControlStatusDidChangeNotification;
extern NSNotificationName const SJVideoPlayerDidPlayToEndTimeNotification;
extern NSNotificationName const SJVideoPlayerDefinitionSwitchStatusDidChangeNotification;

extern NSNotificationName const SJVideoPlayerCurrentTimeDidChangeNotification;
extern NSNotificationName const SJVideoPlayerDurationDidChangeNotification;
extern NSNotificationName const SJVideoPlayerPlayableDurationDidChangeNotification;
extern NSNotificationName const SJVideoPlayerPresentationSizeDidChangeNotification;
extern NSNotificationName const SJVideoPlayerPlaybackTypeDidChangeNotification;

extern NSNotificationName const SJVideoPlayerRateDidChangeNotification;
extern NSNotificationName const SJVideoPlayerMutedDidChangeNotification;
extern NSNotificationName const SJVideoPlayerVolumeDidChangeNotification;
extern NSNotificationName const SJVideoPlayerLockedScreenDidChangeNotification;

NS_ASSUME_NONNULL_END
