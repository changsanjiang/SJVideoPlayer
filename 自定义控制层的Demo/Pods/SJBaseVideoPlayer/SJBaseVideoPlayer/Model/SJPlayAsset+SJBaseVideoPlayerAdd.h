//
//  SJPlayAsset+SJBaseVideoPlayerAdd.h
//  Masonry
//
//  Created by 畅三江 on 2018/7/2.
//

#import "SJPlayAsset.h"
#import "SJVideoPlayerPreviewInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJPlayAsset (SJBaseVideoPlayerAdd_Screenshot)

- (UIImage * __nullable)screenshot;
- (UIImage * __nullable)screenshotWithTime:(CMTime)time;

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(SJPlayAsset *a, UIImage * __nullable images, NSError *__nullable error))block;

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(SJPlayAsset *a, UIImage * __nullable image, NSError *__nullable error))block;

- (void)cancelScreenshotOperation;
@end


@interface SJPlayAsset (SJBaseVideoPlayerAdd_Previews)
@property (nonatomic, strong, readonly, nullable) NSArray<id<SJVideoPlayerPreviewInfo>> *generatedPreviewImages;
@property (nonatomic, readonly) BOOL hasBeenGeneratedPreviewImages;
- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(SJPlayAsset *a, NSArray<id<SJVideoPlayerPreviewInfo>> *__nullable images, NSError *__nullable error))block;
- (void)cancelPreviewImagesGeneration;
@end



@interface SJPlayAsset (SJBaseVideoPlayerAdd_Export)
/// preset name default is `AVAssetExportPresetMediumQuality`.
- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    endTime:(NSTimeInterval)endTime
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(SJPlayAsset *a, float progress))progress
                 completion:(void(^)(SJPlayAsset *a, AVAsset * __nullable sandboxAsset, NSURL * __nullable fileURL, UIImage * __nullable thumbImage))completion
                    failure:(void(^)(SJPlayAsset *a, NSError * __nullable error))failure;
- (void)cancelExportOperation;

/// interval: The interval at which the image is captured, Recommended setting 0.1f.
- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                     maximumSize:(CGSize)maximumSize
                        interval:(float)interval
                     gifSavePath:(NSURL *)gifSavePath
                        progress:(void(^)(SJPlayAsset *a, float progress))progressBlock
                      completion:(void(^)(SJPlayAsset *a, UIImage *imageGIF, UIImage *thumbnailImage))completion
                         failure:(void(^)(SJPlayAsset *a, NSError *error))failure;
- (void)cancelGenerateGIFOperation;
@end


@interface SJPlayAsset (SJBaseVideoPlayerAdd_CancelOperation)
- (void)cancelOperation;
@end

NS_ASSUME_NONNULL_END
