//
//  SJMediaPlaybackController.h
//  Project
//
//  Created by BlueDancer on 2018/8/10.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#ifndef SJMediaPlaybackProtocol_h
#define SJMediaPlaybackProtocol_h
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SJPlayerBufferStatus.h"
#import "SJVideoPlayerPlayStatusDefines.h"

@protocol SJMediaPlaybackControllerDelegate, SJMediaModelProtocol;

typedef NS_ENUM(NSInteger, SJMediaPlaybackPrepareStatus) {
    SJMediaPlaybackPrepareStatusUnknown = AVPlayerItemStatusUnknown,
    SJMediaPlaybackPrepareStatusReadyToPlay =  AVPlayerItemStatusReadyToPlay,
    SJMediaPlaybackPrepareStatusFailed = AVPlayerItemStatusFailed,
};

typedef NS_ENUM(NSInteger, SJMediaPlaybackSwitchDefinitionStatus) {
    SJMediaPlaybackSwitchDefinitionStatusUnknown,
    SJMediaPlaybackSwitchDefinitionStatusSwitching,
    SJMediaPlaybackSwitchDefinitionStatusFinished,
    SJMediaPlaybackSwitchDefinitionStatusFailed,
};

typedef AVLayerVideoGravity SJVideoGravity;

NS_ASSUME_NONNULL_BEGIN
@protocol SJMediaPlaybackController<NSObject>
@required
@property (nonatomic) NSTimeInterval refreshTimeInterval; // default value is 0.5
@property (nonatomic, strong, readonly, nullable) NSError *error;
@property (nonatomic, weak, nullable) id<SJMediaPlaybackControllerDelegate> delegate;

@property (nonatomic, readonly) SJMediaPlaybackType playbackType;
@property (nonatomic, strong, readonly) __kindof UIView *playerView;
@property (nonatomic, strong, nullable) id<SJMediaModelProtocol> media;
@property (nonatomic, strong) SJVideoGravity videoGravity; // default value is AVLayerVideoGravityResizeAspect

// - status -
@property (nonatomic, readonly) SJVideoPlayerInactivityReason inactivityReason;
@property (nonatomic, readonly) SJVideoPlayerPausedReason pausedReason;
@property (nonatomic, readonly) SJVideoPlayerPlayStatus playStatus;
@property (nonatomic, readonly) SJPlayerBufferStatus bufferStatus;
@property (nonatomic, readonly) SJMediaPlaybackPrepareStatus prepareStatus;
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSTimeInterval bufferLoadedTime;
@property (nonatomic, readonly) CGSize presentationSize;
@property (nonatomic, readonly, getter=isReadyForDisplay) BOOL readyForDisplay;

@property (nonatomic) float volume;
@property (nonatomic) float rate;
@property (nonatomic) BOOL mute;

@property (nonatomic, readonly) BOOL isPlayed; ///< 当前media是否调用过play
@property (nonatomic, readonly, getter=isReplayed) BOOL replayed; ///< 当前media是否调用过replay
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
                completion:(void(^)(id<SJMediaPlaybackController> controller, UIImage * __nullable image, NSError *__nullable error))block;
@end


/// export
@protocol SJMediaPlaybackExportController
- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    endTime:(NSTimeInterval)endTime
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(id<SJMediaPlaybackController> controller, float progress))progress
                 completion:(void(^)(id<SJMediaPlaybackController> controller, NSURL * __nullable saveURL, UIImage * __nullable thumbImage))completion
                    failure:(void(^)(id<SJMediaPlaybackController> controller, NSError * __nullable error))failure;

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                     maximumSize:(CGSize)maximumSize
                        interval:(float)interval
                     gifSavePath:(NSURL *)gifSavePath
                        progress:(void(^)(id<SJMediaPlaybackController> controller, float progress))progressBlock
                      completion:(void(^)(id<SJMediaPlaybackController> controller, UIImage *imageGIF, UIImage *screenshot))completion
                         failure:(void(^)(id<SJMediaPlaybackController> controller, NSError *error))failure;

- (void)cancelExportOperation;
- (void)cancelGenerateGIFOperation;
@end


/// delegate
@protocol SJMediaPlaybackControllerDelegate<NSObject>

@optional
// - new -
- (void)playbackController:(id<SJMediaPlaybackController>)controller playbackStatusDidChange:(SJVideoPlayerPlayStatus)playbackStatus;
- (void)playbackController:(id<SJMediaPlaybackController>)controller bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus;
- (void)playbackController:(id<SJMediaPlaybackController>)controller durationDidChange:(NSTimeInterval)duration;
- (void)playbackController:(id<SJMediaPlaybackController>)controller currentTimeDidChange:(NSTimeInterval)currentTime;
- (void)mediaDidPlayToEndForPlaybackController:(id<SJMediaPlaybackController>)controller;
- (void)playbackController:(id<SJMediaPlaybackController>)controller presentationSizeDidChange:(CGSize)presentationSize;
- (void)playbackController:(id<SJMediaPlaybackController>)controller playbackTypeLoaded:(SJMediaPlaybackType)playbackType;
- (void)playbackController:(id<SJMediaPlaybackController>)controller bufferLoadedTimeDidChange:(NSTimeInterval)bufferLoadedTime;
- (void)playbackControllerIsReadyForDisplay:(id<SJMediaPlaybackController>)controller;
- (void)playbackController:(id<SJMediaPlaybackController>)controller switchingDefinitionStatusDidChange:(SJMediaPlaybackSwitchDefinitionStatus)status media:(id<SJMediaModelProtocol>)media;
@end


/// media
@protocol SJMediaModelProtocol
/// played by URL
@property (nonatomic, strong, nullable) NSURL *mediaURL;

/// played by other media
@property (nonatomic, weak, readonly, nullable) id<SJMediaModelProtocol> originMedia;

@property (nonatomic) NSTimeInterval specifyStartTime;

@property (nonatomic) NSTimeInterval playableLimit;
@end

@protocol SJAVMediaModelProtocol<SJMediaModelProtocol>
@property (nonatomic, strong, readonly, nullable) __kindof AVAsset *avAsset;
@end
NS_ASSUME_NONNULL_END

#endif /* SJMediaPlaybackProtocol_h */
