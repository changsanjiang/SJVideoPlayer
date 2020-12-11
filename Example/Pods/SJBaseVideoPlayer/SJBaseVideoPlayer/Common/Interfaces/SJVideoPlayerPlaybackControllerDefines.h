//
//  SJVideoPlayerPlaybackController.h
//  Project
//
//  Created by 畅三江 on 2018/8/10.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#ifndef SJMediaPlaybackProtocol_h
#define SJMediaPlaybackProtocol_h
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SJVideoPlayerPlayStatusDefines.h"
#import "SJPictureInPictureControllerDefines.h"

@protocol SJVideoPlayerPlaybackControllerDelegate, SJMediaModelProtocol;

typedef AVLayerVideoGravity SJVideoGravity;

typedef struct {
    BOOL isSeeking;
    CMTime time;
} SJSeekingInfo;

NS_ASSUME_NONNULL_BEGIN
@protocol SJVideoPlayerPlaybackController<NSObject>
@required
@property (nonatomic) NSTimeInterval periodicTimeInterval; // default value is 0.5
@property (nonatomic) NSTimeInterval minBufferedDuration; // default value is 8.0
@property (nonatomic, strong, readonly, nullable) NSError *error;
@property (nonatomic, weak, nullable) id<SJVideoPlayerPlaybackControllerDelegate> delegate;

@property (nonatomic, readonly) SJPlaybackType playbackType;
@property (nonatomic, strong, readonly) __kindof UIView *playerView;
@property (nonatomic, strong, nullable) id<SJMediaModelProtocol> media;
@property (nonatomic, strong) SJVideoGravity videoGravity; // default value is AVLayerVideoGravityResizeAspect

// - status -
@property (nonatomic, readonly) SJAssetStatus assetStatus;
@property (nonatomic, readonly) SJPlaybackTimeControlStatus timeControlStatus;
@property (nonatomic, readonly, nullable) SJWaitingReason reasonForWaitingToPlay;

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSTimeInterval playableDuration;
@property (nonatomic, readonly) NSTimeInterval durationWatched; // 已观看的时长
@property (nonatomic, readonly) CGSize presentationSize;
@property (nonatomic, readonly, getter=isReadyForDisplay) BOOL readyForDisplay;

@property (nonatomic) float volume;
@property (nonatomic) float rate;
@property (nonatomic, getter=isMuted) BOOL muted;

@property (nonatomic, readonly) BOOL isPlayed;                      ///< 当前media是否调用过play
@property (nonatomic, readonly, getter=isReplayed) BOOL replayed;   ///< 当前media是否调用过replay
@property (nonatomic, readonly) BOOL isPlaybackFinished;                        ///< 播放结束
@property (nonatomic, readonly, nullable) SJFinishedReason finishedReason;      ///< 播放结束的reason
- (void)prepareToPlay;
- (void)replay;
- (void)refresh;
- (void)play;
@property (nonatomic) BOOL pauseWhenAppDidEnterBackground;
- (void)pause;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;
- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^ __nullable)(BOOL))completionHandler;
- (nullable UIImage *)screenshot;
- (void)switchVideoDefinition:(id<SJMediaModelProtocol>)media;

- (BOOL)isPictureInPictureSupported API_AVAILABLE(ios(14.0));
@property (nonatomic) BOOL requiresLinearPlaybackInPictureInPicture API_AVAILABLE(ios(14.0));
@property (nonatomic, readonly) SJPictureInPictureStatus pictureInPictureStatus API_AVAILABLE(ios(14.0));
- (void)startPictureInPicture API_AVAILABLE(ios(14.0));
- (void)stopPictureInPicture API_AVAILABLE(ios(14.0));
@end

/// screenshot`
@protocol SJMediaPlaybackScreenshotController
- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(id<SJVideoPlayerPlaybackController> controller, UIImage * __nullable image, NSError *__nullable error))block;
@end


/// export
@protocol SJMediaPlaybackExportController
- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                   duration:(NSTimeInterval)duration
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(id<SJVideoPlayerPlaybackController> controller, float progress))progress
                 completion:(void(^)(id<SJVideoPlayerPlaybackController> controller, NSURL * __nullable saveURL, UIImage * __nullable thumbImage))completion
                    failure:(void(^)(id<SJVideoPlayerPlaybackController> controller, NSError * __nullable error))failure;

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                     maximumSize:(CGSize)maximumSize
                        interval:(float)interval
                     gifSavePath:(NSURL *)gifSavePath
                        progress:(void(^)(id<SJVideoPlayerPlaybackController> controller, float progress))progressBlock
                      completion:(void(^)(id<SJVideoPlayerPlaybackController> controller, UIImage *imageGIF, UIImage *screenshot))completion
                         failure:(void(^)(id<SJVideoPlayerPlaybackController> controller, NSError *error))failure;

- (void)cancelExportOperation;
- (void)cancelGenerateGIFOperation;
@end


/// delegate
@protocol SJVideoPlayerPlaybackControllerDelegate<NSObject>

@optional
#pragma mark -
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller assetStatusDidChange:(SJAssetStatus)status;
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller timeControlStatusDidChange:(SJPlaybackTimeControlStatus)status;
#pragma mark -


// - new -
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller playbackDidFinish:(SJFinishedReason)reason;
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller durationDidChange:(NSTimeInterval)duration;
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller currentTimeDidChange:(NSTimeInterval)currentTime;
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller presentationSizeDidChange:(CGSize)presentationSize;
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller playbackTypeDidChange:(SJPlaybackType)playbackType;
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller playableDurationDidChange:(NSTimeInterval)playableDuration;
- (void)playbackControllerIsReadyForDisplay:(id<SJVideoPlayerPlaybackController>)controller;
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller switchingDefinitionStatusDidChange:(SJDefinitionSwitchStatus)status media:(id<SJMediaModelProtocol>)media;
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller didReplay:(id<SJMediaModelProtocol>)media;

- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller pictureInPictureStatusDidChange:(SJPictureInPictureStatus)status API_AVAILABLE(ios(14.0));

- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller willSeekToTime:(CMTime)time;
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller didSeekToTime:(CMTime)time;

- (void)applicationWillEnterForegroundWithPlaybackController:(id<SJVideoPlayerPlaybackController>)controller;
- (void)applicationDidBecomeActiveWithPlaybackController:(id<SJVideoPlayerPlaybackController>)controller;
- (void)applicationWillResignActiveWithPlaybackController:(id<SJVideoPlayerPlaybackController>)controller;
- (void)applicationDidEnterBackgroundWithPlaybackController:(id<SJVideoPlayerPlaybackController>)controller;
@end


/// media
@protocol SJMediaModelProtocol
/// played by URL
@property (nonatomic, strong, nullable) NSURL *mediaURL;

/// 开始播放的位置, 单位秒
@property (nonatomic) NSTimeInterval startPosition;

/// 试用结束的位置, 单位秒
@property (nonatomic) NSTimeInterval trialEndPosition;
@end
NS_ASSUME_NONNULL_END

#endif /* SJMediaPlaybackProtocol_h */
