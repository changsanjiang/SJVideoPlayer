//
//  SJAVMediaPlaybackDefines.h
//  Pods
//
//  Created by BlueDancer on 2019/4/9.
//

#ifndef SJAVMediaPlaybackDefines_h
#define SJAVMediaPlaybackDefines_h
#import <AVFoundation/AVFoundation.h>
#import "SJVideoPlayerPlayStatusDefines.h"
#import "SJPlayerBufferStatus.h"

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN NSNotificationName const SJAVMediaPlaybackStatusDidChangeNotification;
UIKIT_EXTERN NSNotificationName const SJAVMediaBufferStatusDidChangeNotification;
UIKIT_EXTERN NSNotificationName const SJAVMediaPlayableDurationDidChangeNotification;
UIKIT_EXTERN NSNotificationName const SJAVMediaPlayDidToEndTimeNotification;
UIKIT_EXTERN NSNotificationName const SJAVMediaLoadedPresentationSizeNotification;
UIKIT_EXTERN NSNotificationName const SJAVMediaLoadedPlaybackTypeNotification;
UIKIT_EXTERN NSNotificationName const SJAVMediaLoadedDurationNotification;
UIKIT_EXTERN NSNotificationName const SJAVMediaItemStatusDidChangeNotification;

@protocol SJAVMediaPlayerProtocol <NSObject>
- (instancetype)initWithURL:(NSURL *)URL;
- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime;
- (instancetype)initWithAVAsset:(__kindof AVAsset *)asset specifyStartTime:(NSTimeInterval)specifyStartTime;
- (instancetype)initWithPlayerItem:(AVPlayerItem *_Nullable)item specifyStartTime:(NSTimeInterval)specifyStartTime;

@property (nonatomic) float sj_playbackRate;
@property (nonatomic) float sj_playbackVolume;
@property (nonatomic, getter=sj_isMuted) BOOL sj_muted;
@property (nonatomic, getter=sj_isReplayed, readonly) BOOL sj_replayed;

- (void)sj_setForceDuration:(NSTimeInterval)forceDuration;

// - status -
@property (nonatomic, readonly) SJVideoPlayerInactivityReason sj_inactivityReason;
@property (nonatomic, readonly) SJVideoPlayerPausedReason sj_pausedReason;
@property (nonatomic, readonly) SJVideoPlayerPlayStatus sj_playbackStatus;
@property (nonatomic, readonly) SJPlayerBufferStatus sj_bufferStatus;
@property (nonatomic) NSTimeInterval sj_bufferTimeToContinuePlaying;
- (BOOL)sj_getPlayerIsPlaying;    ///< 是否正在播放
- (BOOL)sj_getIsPlayed;           ///< 是否调用过play
- (SJMediaPlaybackType)sj_getPlaybackType;
- (NSTimeInterval)sj_getDuration;
- (NSTimeInterval)sj_getCurrentPlaybackTime;
- (NSTimeInterval)sj_getPlayableDuration;
- (AVPlayerItemStatus)sj_getAVPlayerItemStatus;
- (CGSize)sj_getPresentationSize;
- (NSError *_Nullable)sj_getError;
- (AVPlayer *)sj_getAVPlayer;
- (AVAsset *)sj_getAVAsset;

- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL))completionHandler;
- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL))completionHandler;

- (void)play;
- (void)replay;
- (void)pause;
- (void)reset;

- (void)report; ///< post 当前播放状态
@end
NS_ASSUME_NONNULL_END
#endif /* SJAVMediaPlaybackDefines_h */
