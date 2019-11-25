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
@property (nonatomic, readonly) BOOL isPlayedToEndTime;               ///< 是否已播放完毕
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
@end

/// screenshot
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
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller durationDidChange:(NSTimeInterval)duration;
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller currentTimeDidChange:(NSTimeInterval)currentTime;
- (void)mediaDidPlayToEndForPlaybackController:(id<SJVideoPlayerPlaybackController>)controller;
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller presentationSizeDidChange:(CGSize)presentationSize;
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller playbackTypeDidChange:(SJPlaybackType)playbackType;
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller playableDurationDidChange:(NSTimeInterval)playableDuration;
- (void)playbackControllerIsReadyForDisplay:(id<SJVideoPlayerPlaybackController>)controller;
- (void)playbackController:(id<SJVideoPlayerPlaybackController>)controller switchingDefinitionStatusDidChange:(SJDefinitionSwitchStatus)status media:(id<SJMediaModelProtocol>)media;
@end


/// media
@protocol SJMediaModelProtocol
/// played by URL
@property (nonatomic, strong, nullable) NSURL *mediaURL;

/// played by other media
@property (nonatomic, weak, readonly, nullable) id<SJMediaModelProtocol> originMedia;

@property (nonatomic) NSTimeInterval specifyStartTime;
@end

@protocol SJAVMediaModelProtocol<SJMediaModelProtocol>
@property (nonatomic, strong, readonly, nullable) __kindof AVAsset *avAsset;
@end
NS_ASSUME_NONNULL_END

#endif /* SJMediaPlaybackProtocol_h */
