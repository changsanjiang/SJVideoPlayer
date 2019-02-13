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
#import "SJVideoPlayerPreviewInfo.h"
#import "SJPlayerBufferStatus.h"
#import "SJVideoPlayerState.h"

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
@property (nonatomic, weak, nullable) id<SJMediaPlaybackControllerDelegate> delegate;

@property (nonatomic, strong, readonly) __kindof UIView *playerView;
@property (nonatomic, strong, nullable) id<SJMediaModelProtocol> media;
@property (nonatomic, strong) SJVideoGravity videoGravity; // default is AVLayerVideoGravityResizeAspect

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSTimeInterval bufferLoadedTime;
@property (nonatomic, readonly) SJPlayerBufferStatus bufferStatus;
@property (nonatomic, readonly) CGSize presentationSize;
@property (nonatomic, readonly) BOOL isReadyForDisplay;

@property (nonatomic) float volume;
@property (nonatomic) float rate;
@property (nonatomic) BOOL mute;

@property (nonatomic, readonly) SJMediaPlaybackPrepareStatus prepareStatus;
@property (nonatomic, strong, readonly, nullable) NSError *error;
- (void)prepareToPlay;
- (void)play;
@property (nonatomic) BOOL pauseWhenAppDidEnterBackground;
- (void)pause;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;
- (nullable UIImage *)screenshot;

- (void)switchVideoDefinitionByURL:(NSURL *)URL;

@optional
- (void)cancelPendingSeeks;
@end

/// screenshot
@protocol SJMediaPlaybackScreenshotController
- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(id<SJMediaPlaybackController> controller, UIImage * __nullable image, NSError *__nullable error))block;

- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(__kindof id<SJMediaPlaybackController> controller, NSArray<id<SJVideoPlayerPreviewInfo>> *__nullable images, NSError *__nullable error))block;
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

- (void)playbackController:(id<SJMediaPlaybackController>)controller prepareToPlayStatusDidChange:(SJMediaPlaybackPrepareStatus)prepareStatus;

- (void)playbackController:(id<SJMediaPlaybackController>)controller durationDidChange:(NSTimeInterval)duration;

- (void)playbackController:(id<SJMediaPlaybackController>)controller currentTimeDidChange:(NSTimeInterval)currentTime;

- (void)mediaDidPlayToEndForPlaybackController:(id<SJMediaPlaybackController>)controller;

- (void)playbackController:(id<SJMediaPlaybackController>)controller bufferLoadedTimeDidChange:(NSTimeInterval)bufferLoadedTime;

- (void)playbackController:(id<SJMediaPlaybackController>)controller bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus;

- (void)playbackController:(id<SJMediaPlaybackController>)controller presentationSizeDidChange:(CGSize)presentationSize;

- (void)playbackController:(id<SJMediaPlaybackController>)controller switchVideoDefinitionByURL:(NSURL *)URL statusDidChange:(SJMediaPlaybackSwitchDefinitionStatus)status;

- (void)playbackControllerIsReadyForDisplay:(id<SJMediaPlaybackController>)controller;

@optional
- (void)pausedForAppDidEnterBackgroundOfPlaybackController:(id<SJMediaPlaybackController>)controller;

@end


/// media
@protocol SJMediaModelProtocol
/// played by URL
@property (nonatomic, strong, nullable) NSURL *mediaURL;

/// played by other media
@property (nonatomic, weak, readonly, nullable) id<SJMediaModelProtocol> otherMedia;

@property (nonatomic) NSTimeInterval specifyStartTime;
@end
NS_ASSUME_NONNULL_END

#endif /* SJMediaPlaybackProtocol_h */
