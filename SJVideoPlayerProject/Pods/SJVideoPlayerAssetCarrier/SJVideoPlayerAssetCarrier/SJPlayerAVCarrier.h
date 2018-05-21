//
//  SJPlayerAVCarrier.h
//  SJVideoPlayerAssetCarrier
//
//  Created by BlueDancer on 2018/5/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJPlayerAVCarrier <NSObject>
@property (nonatomic, strong, readonly) AVURLAsset *asset;
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, strong, readonly) NSURL *assetURL;
@property (nonatomic, readonly) float rate;
@end

@protocol SJPlayerAVCarrierDelegate;
@class SJVideoPreviewModel;


@interface SJPlayerAVCarrier : NSObject<SJPlayerAVCarrier>
- (instancetype)initWithURL:(NSURL *)URL beginTime:(NSTimeInterval)beginTime;
- (instancetype)initWithOtherCarrier:(id<SJPlayerAVCarrier>)otherCarrier;
@property (nonatomic, weak) id<SJPlayerAVCarrierDelegate>delegate;
@property (nonatomic, readonly) BOOL isOtherAsset;

@property (nonatomic, assign, readonly, getter=isLoadedPlayer) BOOL loadedPlayer;
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) float loadedTimeProgress;
@property (nonatomic, readonly) BOOL bufferingFlag;
@property (nonatomic, readonly) float progress;
- (void)cancelBuffering;
@property (nonatomic) float rate; // default is 1.0

#pragma mark
- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;
- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

#pragma mark
- (UIImage * __nullable)screenshot;
- (UIImage * __nullable)screenshotWithTime:(CMTime)time;
- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(SJPlayerAVCarrier *carrier, SJVideoPreviewModel * __nullable images, NSError *__nullable error))block;
- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(SJPlayerAVCarrier *carrier, SJVideoPreviewModel * __nullable images, NSError *__nullable error))block;

#pragma mark
@property (nonatomic, strong, readonly, nullable) NSArray<SJVideoPreviewModel *> *generatedPreviewImages;
@property (nonatomic, readonly) BOOL hasBeenGeneratedPreviewImages;
@property (nonatomic, readonly) CGSize maxItemSize; // preview item max size
- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(SJPlayerAVCarrier *carrier, NSArray<SJVideoPreviewModel *> *__nullable images, NSError *__nullable error))block;
- (void)cancelPreviewImagesGeneration;

#pragma mark
/// preset name default is `AVAssetExportPresetMediumQuality`.
- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    endTime:(NSTimeInterval)endTime
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(SJPlayerAVCarrier *carrier, float progress))progress
                 completion:(void(^)(SJPlayerAVCarrier *carrier, AVAsset * __nullable sandboxAsset, NSURL * __nullable fileURL, UIImage * __nullable thumbImage))completion
                    failure:(void(^)(SJPlayerAVCarrier *carrier, NSError * __nullable error))failure;
- (void)cancelExportOperation;
/// interval: The interval at which the image is captured, Recommended setting 0.1f.
- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                     maximumSize:(CGSize)maximumSize
                        interval:(float)interval
                     gifSavePath:(NSURL *)gifSavePath
                        progress:(void(^)(SJPlayerAVCarrier *carrier, float progress))progressBlock
                      completion:(void(^)(SJPlayerAVCarrier *carrier, UIImage *imageGIF, UIImage *thumbnailImage))completion
                         failure:(void(^)(SJPlayerAVCarrier *carrier, NSError *error))failure;
- (void)cancelGenerateGIFOperation;

#pragma mark
- (NSString *)timeString:(NSTimeInterval)secs;
- (void)pause;
- (void)play;

@end

@protocol SJPlayerAVCarrierDelegate <NSObject>

@optional
/// 播放器初始化完成的时候调用
- (void)playerInitializedForAVCarrier:(SJPlayerAVCarrier *)carrier;
/// 资源的缓冲进度
- (void)AVCarrier:(SJPlayerAVCarrier *)carrier loadedTimeProgress:(float)progress;
/// item的状态改变的时候调用
- (void)AVCarrier:(SJPlayerAVCarrier *)carrier playerItemStatusChanged:(AVPlayerItemStatus)status;
/// 开始缓冲的时候调用
- (void)startBufferForAVCarrier:(SJPlayerAVCarrier *)carrier;
/// 完成缓冲的时候调用
- (void)completeBufferForAVCarrier:(SJPlayerAVCarrier *)carrier;
/// 视频呈现的size
- (void)AVCarrier:(SJPlayerAVCarrier *)carrier presentationSize:(CGSize)size;
/// rate 改变的时候调用
- (void)AVCarrier:(SJPlayerAVCarrier *)carrier rateChanged:(float)rate;
/// 播放时间
- (void)AVCarrier:(SJPlayerAVCarrier *)carrier currentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;
/// 播放结束的时候调用
- (void)playDidToEndForAVCarrier:(SJPlayerAVCarrier *)carrier;

@end


@interface SJVideoPreviewModel : NSObject
+ (instancetype)previewModelWithImage:(UIImage *)image
                            localTime:(CMTime)time;
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) CMTime localTime;
@end
NS_ASSUME_NONNULL_END
