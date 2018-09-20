//
//  SJAVMediaPlayAsset+SJAVMediaPlaybackControllerAdd.h
//  Masonry
//
//  Created by 畅三江 on 2018/7/2.
//

#import "SJAVMediaPlayAsset.h"
#import "SJVideoPlayerPreviewInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJAVMediaPlayAsset (SJBaseVideoPlayerAdd_Screenshot)

- (UIImage * __nullable)screenshot;
- (UIImage * __nullable)screenshotWithTime:(CMTime)time;

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(SJAVMediaPlayAsset *a, UIImage * __nullable images, NSError *__nullable error))block;

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(SJAVMediaPlayAsset *a, UIImage * __nullable image, NSError *__nullable error))block;

- (void)cancelScreenshotOperation;
@end


@interface SJAVMediaPlayAsset (SJBaseVideoPlayerAdd_Previews)
@property (nonatomic, strong, readonly, nullable) NSArray<id<SJVideoPlayerPreviewInfo>> *generatedPreviewImages;
@property (nonatomic, readonly) BOOL hasBeenGeneratedPreviewImages;
- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(SJAVMediaPlayAsset *a, NSArray<id<SJVideoPlayerPreviewInfo>> *__nullable images, NSError *__nullable error))block;
- (void)cancelPreviewImagesGeneration;
@end



@interface SJAVMediaPlayAsset (SJBaseVideoPlayerAdd_Export)
/// preset name default is `AVAssetExportPresetMediumQuality`.
- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    endTime:(NSTimeInterval)endTime
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(SJAVMediaPlayAsset *a, float progress))progress
                 completion:(void(^)(SJAVMediaPlayAsset *a, AVAsset * __nullable sandboxAsset, NSURL * __nullable fileURL, UIImage * __nullable thumbImage))completion
                    failure:(void(^)(SJAVMediaPlayAsset *a, NSError * __nullable error))failure;
- (void)cancelExportOperation;

/// interval: The interval at which the image is captured, Recommended setting 0.1f.
- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                     maximumSize:(CGSize)maximumSize
                        interval:(float)interval
                     gifSavePath:(NSURL *)gifSavePath
                        progress:(void(^)(SJAVMediaPlayAsset *a, float progress))progressBlock
                      completion:(void(^)(SJAVMediaPlayAsset *a, UIImage *imageGIF, UIImage *thumbnailImage))completion
                         failure:(void(^)(SJAVMediaPlayAsset *a, NSError *error))failure;
- (void)cancelGenerateGIFOperation;
@end


@interface SJAVMediaPlayAsset (SJBaseVideoPlayerAdd_CancelOperation)
- (void)cancelOperation;
@end

NS_ASSUME_NONNULL_END
