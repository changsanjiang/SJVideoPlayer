//
//  SJIJKMediaPlayer.h
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/10/12.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>
#import "SJVideoPlayerPlaybackControllerDefines.h"
#import "SJAVMediaPlayer.h"

NS_ASSUME_NONNULL_BEGIN
extern NSNotificationName const SJIJKMediaPlayerAssetStatusDidChangeNotification;
extern NSNotificationName const SJIJKMediaPlayerTimeControlStatusDidChangeNotification;
extern NSNotificationName const SJIJKMediaPlayerDurationDidChangeNotification;
extern NSNotificationName const SJIJKMediaPlayerPlayableDurationDidChangeNotification;
extern NSNotificationName const SJIJKMediaPlayerPresentationSizeDidChangeNotification;
extern NSNotificationName const SJIJKMediaPlayerPlaybackTypeDidChangeNotification;
extern NSNotificationName const SJIJKMediaPlayerDidPlayToEndTimeNotification;

@interface SJIJKMediaPlayer : IJKFFMoviePlayerController
- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime;
@property (nonatomic, strong, readonly, nullable) NSError *sj_error;
@property (nonatomic, readonly, nullable) SJWaitingReason sj_reasonForWaitingToPlay;
@property (nonatomic, readonly) SJPlaybackTimeControlStatus sj_timeControlStatus;
@property (nonatomic, readonly) SJAssetStatus sj_assetStatus;
@property (nonatomic, readonly) SJSeekingInfo sj_seekingInfo;

@property (nonatomic, readonly) SJAVMediaPlayerPlaybackInfo sj_playbackInfo;
@property (nonatomic) NSTimeInterval sj_minBufferedDuration;
@property (nonatomic) float sj_rate;

- (void)sj_playImmediatelyAtRate:(float)rate;
- (id)sj_addPeriodicTimeObserverForInterval:(CMTime)interval queue:(nullable dispatch_queue_t)queue usingBlock:(void (^)(CMTime))block;
- (void)sj_removeTimeObserver:(id)observer;
- (void)sj_setPauseInBackground:(BOOL)pause;

- (void)replay;
- (void)report;

@property (nonatomic, strong, readonly) NSURL *sj_URL;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
