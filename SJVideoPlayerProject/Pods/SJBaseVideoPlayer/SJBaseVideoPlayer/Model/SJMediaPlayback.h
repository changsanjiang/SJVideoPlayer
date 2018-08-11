//
//  SJMediaPlaybackController.h
//  Project
//
//  Created by BlueDancer on 2018/8/10.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#ifndef SJMediaPlaybackController_h
#define SJMediaPlaybackController_h
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SJVideoPlayerState.h"
#import "SJVideoPlayerPreviewInfo.h"
#import "SJPlayerBufferStatus.h"

typedef NS_ENUM(NSUInteger, SJMediaPlaybackPrepareStatus) {
    SJMediaPlaybackPrepareStatusUnknown = AVPlayerItemStatusUnknown,
    SJMediaPlaybackPrepareStatusReadyToPlay =  AVPlayerItemStatusReadyToPlay,
    SJMediaPlaybackPrepareStatusFailed = AVPlayerItemStatusFailed,
};
typedef AVLayerVideoGravity SJVideoGravity;
@protocol SJMediaPlaybackControllerDelegate, SJMediaModel;


NS_ASSUME_NONNULL_BEGIN
@protocol SJMediaPlaybackController<NSObject>
@property (nonatomic, weak, nullable) id<SJMediaPlaybackControllerDelegate> delegate;

@property (nonatomic, strong, readonly) __kindof UIView *playerView;
@property (nonatomic, strong, nullable) id<SJMediaModel> media;
@property (nonatomic, strong) SJVideoGravity videoGravity; // default is AVLayerVideoGravityResizeAspect

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSTimeInterval bufferLoadedTime;
@property (nonatomic, readonly) SJPlayerBufferStatus bufferStatus;
@property (nonatomic, readonly) CGSize presentationSize;

@property (nonatomic) BOOL pauseWhenAppDidEnterBackground;
@property (nonatomic) float rate;
@property (nonatomic) BOOL mute;

@property (nonatomic, readonly) SJMediaPlaybackPrepareStatus prepareStatus;
@property (nonatomic, strong, nullable) NSError *error;
- (void)prepareToPlay;
- (void)play;
- (void)pause;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

- (nullable UIImage *)screenshot;
@end


@protocol SJMediaPlaybackScreenshotController
- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(id<SJMediaPlaybackController> controller, UIImage * __nullable image, NSError *__nullable error))block;

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(id<SJMediaPlaybackController> controller, UIImage * __nullable image, NSError *__nullable error))block;

- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(__kindof id<SJMediaPlaybackController> controller, NSArray<id<SJVideoPlayerPreviewInfo>> *__nullable images, NSError *__nullable error))block;
@end


@protocol SJMediaPlaybackExportController
- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    endTime:(NSTimeInterval)endTime
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(id<SJMediaPlaybackController> controller, float progress))progress
                 completion:(void(^)(id<SJMediaPlaybackController> controller, NSURL *_Nullable saveURL, NSURL * __nullable fileURL, UIImage * __nullable thumbImage))completion
                    failure:(void(^)(id<SJMediaPlaybackController> controller, NSError * __nullable error))failure;

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                     maximumSize:(CGSize)maximumSize
                        interval:(float)interval
                     gifSavePath:(NSURL *)gifSavePath
                        progress:(void(^)(id<SJMediaPlaybackController> controller, float progress))progressBlock
                      completion:(void(^)(id<SJMediaPlaybackController> controller, UIImage *imageGIF, UIImage *screenshot))completion
                         failure:(void(^)(id<SJMediaPlaybackController> controller, NSError *error))failure;

- (void)cancelOperation;
@end


@protocol SJMediaPlaybackControllerDelegate<NSObject>

- (void)playbackController:(id<SJMediaPlaybackController>)controller prepareStatusDidChange:(SJMediaPlaybackPrepareStatus)prepareStatus;

- (void)playbackController:(id<SJMediaPlaybackController>)controller durationDidChange:(NSTimeInterval)duration;

- (void)playbackController:(id<SJMediaPlaybackController>)controller currentTimeDidChange:(NSTimeInterval)currentTime;

- (void)mediaDidPlayToEndForPlaybackController:(id<SJMediaPlaybackController>)controller;

- (void)playbackController:(id<SJMediaPlaybackController>)controller bufferLoadedTimeDidChange:(NSTimeInterval)bufferLoadedTime;

- (void)playbackController:(id<SJMediaPlaybackController>)controller bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus;

- (void)playbackController:(id<SJMediaPlaybackController>)controller presentationSizeDidChange:(CGSize)presentationSize;

- (void)playbackController:(id<SJMediaPlaybackController>)controller willSeekToTime:(NSTimeInterval)time;

- (void)playbackController:(id<SJMediaPlaybackController>)controller didSeekToTime:(NSTimeInterval)time finished:(BOOL)finished;
@end


@protocol SJMediaModel
@property (nonatomic, strong, readonly) NSURL *mediaURL;
@property (nonatomic) NSTimeInterval specifyStartTime;
@end
NS_ASSUME_NONNULL_END

#endif /* SJMediaPlaybackController_h */
