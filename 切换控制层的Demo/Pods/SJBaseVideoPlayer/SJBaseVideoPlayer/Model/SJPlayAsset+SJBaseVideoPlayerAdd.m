//
//  SJPlayAsset+SJBaseVideoPlayerAdd.m
//  Masonry
//
//  Created by 畅三江 on 2018/7/2.
//

#import "SJPlayAsset+SJBaseVideoPlayerAdd.h"
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSTimer+SJAssetAdd.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJPlayAsset (SJBaseVideoPlayerAdd_Screenshot)
- (nullable AVAssetImageGenerator *)screenshotGenerator {
    if ( !self.URLAsset ) return nil;
    AVAssetImageGenerator *screenshotGenerator = objc_getAssociatedObject(self, _cmd);
    if ( screenshotGenerator ) return screenshotGenerator;
    screenshotGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.URLAsset];
    screenshotGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    screenshotGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    screenshotGenerator.appliesPreferredTrackTransform = YES;
    objc_setAssociatedObject(self, _cmd, screenshotGenerator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return screenshotGenerator;
}
- (UIImage * __nullable)screenshot {
    return [self screenshotWithTime:self.playerItem.currentTime];
}
- (UIImage * __nullable)screenshotWithTime:(CMTime)time {
    if ( !self.URLAsset ) return nil;
    CGImageRef imgRef = [[self screenshotGenerator] copyCGImageAtTime:time actualTime:&time error:nil];
    if ( !imgRef ) return nil;
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    return image;
}
- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(SJPlayAsset *a, UIImage * __nullable image, NSError *__nullable error))block {
    return [self screenshotWithTime:time size:CGSizeZero completion:block];
}
- (void)screenshotWithTime:(NSTimeInterval)t
                      size:(CGSize)size
                completion:(void(^)(SJPlayAsset *a, UIImage * __nullable image, NSError *__nullable error))block {
    if ( !self.playerItem ) return;
    [self.screenshotGenerator cancelAllCGImageGeneration];
    CMTime time = CMTimeMakeWithSeconds(t, NSEC_PER_SEC);
    self.screenshotGenerator.maximumSize = size;
    __weak typeof(self) _self = self;
    [self.screenshotGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( result == AVAssetImageGeneratorSucceeded ) {
            if ( block ) block(self, [UIImage imageWithCGImage:imageRef], nil);
        }
        else if ( result == AVAssetImageGeneratorFailed ) {
            if ( block ) block(self, nil, error);
        }
    }];
}
- (void)cancelScreenshotOperation {
    AVAssetImageGenerator *screenshotGenerator = objc_getAssociatedObject(self, @selector(screenshotGenerator));
    if ( !screenshotGenerator ) return;
    if ( screenshotGenerator ) [screenshotGenerator cancelAllCGImageGeneration];
}
@end



@interface _SJVideoPreviewModel : NSObject<SJVideoPlayerPreviewInfo>
+ (instancetype)previewModelWithImage:(UIImage *)image
                            localTime:(CMTime)time;
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) CMTime localTime;
@end

@implementation _SJVideoPreviewModel
+ (instancetype)previewModelWithImage:(UIImage *)image localTime:(CMTime)time {
    _SJVideoPreviewModel *model = [self new];
    model -> _image = image;
    model -> _localTime = time;
    return model;
}
@end

@implementation SJPlayAsset (SJBaseVideoPlayerAdd_Previews)
- (void)setGeneratedPreviewImages:(nullable NSArray<id<SJVideoPlayerPreviewInfo>> *)generatedPreviewImages {
    objc_setAssociatedObject(self, @selector(generatedPreviewImages), generatedPreviewImages, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable NSArray<id<SJVideoPlayerPreviewInfo>> *)generatedPreviewImages {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setHasBeenGeneratedPreviewImages:(BOOL)hasBeenGeneratedPreviewImages {
    objc_setAssociatedObject(self, @selector(hasBeenGeneratedPreviewImages), @(hasBeenGeneratedPreviewImages), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)hasBeenGeneratedPreviewImages {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setBeforeSize:(CGSize)beforeSize {
    objc_setAssociatedObject(self, @selector(beforeSize), [NSValue valueWithCGSize:beforeSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGSize)beforeSize {
    return [objc_getAssociatedObject(self, _cmd) CGSizeValue];
}
- (nullable AVAssetImageGenerator *)previewGenerator {
    if ( !self.URLAsset ) return nil;
    AVAssetImageGenerator *previewGenerator = objc_getAssociatedObject(self, _cmd);
    if ( previewGenerator ) return previewGenerator;
    previewGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.URLAsset];
    previewGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    previewGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    previewGenerator.appliesPreferredTrackTransform = YES;
    objc_setAssociatedObject(self, _cmd, previewGenerator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return previewGenerator;
}
static float const _GeneratePreImgScale = 0.05;
- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(SJPlayAsset *carrier, NSArray<id<SJVideoPlayerPreviewInfo>> *__nullable images, NSError *__nullable error))block {
    if ( !self.URLAsset ) return;

    if ( self.hasBeenGeneratedPreviewImages && CGSizeEqualToSize(itemSize, self.beforeSize) ) {
        if ( block ) block(self, self.generatedPreviewImages, nil);
        return;
    }
    
    [self cancelPreviewImagesGeneration];
    
    if ( 0 == self.URLAsset.duration.timescale ) return;
    NSMutableArray<NSValue *> *timesM = [NSMutableArray new];
    NSInteger seconds = (long)self.URLAsset.duration.value / self.URLAsset.duration.timescale;
    if ( 0 == seconds || isnan(seconds) ) return;
    if ( _GeneratePreImgScale > 1.0 || _GeneratePreImgScale <= 0 ) return;
    __block short maxCount = (short)floorf(1.0 / _GeneratePreImgScale);
    short interval = (short)floor(seconds * _GeneratePreImgScale);
    for ( short i = 0 ; i < maxCount ; i ++ ) {
        CMTime time = CMTimeMake(i * interval, 1);
        NSValue *tV = [NSValue valueWithCMTime:time];
        if ( tV ) [timesM addObject:tV];
    }
    __weak typeof(self) _self = self;
    NSMutableArray <id<SJVideoPlayerPreviewInfo>> *imagesM = [NSMutableArray new];
    self.previewGenerator.maximumSize = itemSize;
    [self.previewGenerator generateCGImagesAsynchronouslyForTimes:timesM completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        switch ( result ) {
            case AVAssetImageGeneratorSucceeded: {
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                _SJVideoPreviewModel *model = [_SJVideoPreviewModel previewModelWithImage:image localTime:actualTime];
                [imagesM addObject:model];
                if ( --maxCount != 0 ) return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    self.hasBeenGeneratedPreviewImages = YES;
                    self.generatedPreviewImages = imagesM;
                    self.beforeSize = itemSize;
                    if ( block ) block(self, imagesM, nil);
                });
            }
                break;
            case AVAssetImageGeneratorFailed: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    [self cancelPreviewImagesGeneration];
                    if ( block ) block(self, nil, error);
                });
            }
                break;
            case AVAssetImageGeneratorCancelled: break;
        }
    }];
}
- (void)cancelPreviewImagesGeneration {
    AVAssetImageGenerator *previewGenerator = objc_getAssociatedObject(self, @selector(previewGenerator));
    if ( previewGenerator ) [previewGenerator cancelAllCGImageGeneration];
}
@end

@interface __SJGIFCreator : NSObject
@property (nonatomic, strong, readonly) UIImage *firstImage;
- (instancetype)initWithSavePath:(NSURL *)savePath imagesCount:(int)count;
- (void)addImage:(CGImageRef)imageRef;
- (BOOL)finalize;
@end
@interface __SJGIFCreator ()
@property (nonatomic) CGImageDestinationRef destination;
@property (nonatomic, strong, readonly) NSDictionary *frameProperties;
@end
@implementation __SJGIFCreator
- (instancetype)initWithSavePath:(NSURL *)savePath imagesCount:(int)count {
    self = [super init];
    if ( !self ) return nil;
    [[NSFileManager defaultManager] removeItemAtURL:savePath error:nil];
    _destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)savePath, kUTTypeGIF, count, NULL);
    NSDictionary *fileProperties = @{ (__bridge id)kCGImagePropertyGIFDictionary: @{(__bridge id)kCGImagePropertyGIFLoopCount: @(0)} };
    CGImageDestinationSetProperties(_destination, (__bridge CFDictionaryRef)fileProperties);
    _frameProperties = @{ (__bridge id)kCGImagePropertyGIFDictionary: @{(__bridge id)kCGImagePropertyGIFDelayTime: @(0.25f)} };
    return self;
}
- (void)addImage:(CGImageRef)imageRef {
    if ( !_firstImage ) _firstImage = [UIImage imageWithCGImage:imageRef];
    CGImageDestinationAddImage(_destination, imageRef, (__bridge CFDictionaryRef)_frameProperties);
    //    @autoreleasepool {
    //    }
}
- (BOOL)finalize {
    BOOL result = CGImageDestinationFinalize(_destination);
    CFRelease(_destination);
    _destination = NULL;
    return result;
}
- (void)dealloc {
    if ( _destination != NULL ) CFRelease(_destination);
}
@end

@implementation SJPlayAsset (SJBaseVideoPlayerAdd_Export)
- (void)setExportSession:(AVAssetExportSession * _Nullable)exportSession {
    objc_setAssociatedObject(self, @selector(exportSession), exportSession, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable AVAssetExportSession *)exportSession {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setExportProgressRefreshTimer:(NSTimer * _Nullable)exportProgressRefreshTimer {
    objc_setAssociatedObject(self, @selector(exportProgressRefreshTimer), exportProgressRefreshTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable NSTimer *)exportProgressRefreshTimer {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    endTime:(NSTimeInterval)endTime
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(SJPlayAsset *a, float progress))progress
                 completion:(void(^)(SJPlayAsset *a, AVAsset * __nullable sandboxAsset, NSURL * __nullable fileURL, UIImage * __nullable thumbImage))completion
                    failure:(void(^)(SJPlayAsset *a, NSError * __nullable error))failure {
    [self cancelExportOperation];
    if ( endTime - beginTime <= 0 ) {
        if ( failure ) failure(self, [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"msg":@"Error: Start time is greater than end time!"}]);
        return;
    }
    if ( !presetName ) presetName = AVAssetExportPresetMediumQuality;
    AVAsset *asset = self.URLAsset;
    AVMutableComposition *compositionM = [AVMutableComposition composition];
    AVMutableCompositionTrack *audioTrackM = [compositionM addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *videoTrackM = [compositionM addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTimeRange cutRange = CMTimeRangeMake(CMTimeMakeWithSeconds(beginTime, NSEC_PER_SEC), CMTimeMakeWithSeconds(endTime - beginTime, NSEC_PER_SEC));
    AVAssetTrack *assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    AVAssetTrack *assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    NSError *error;
    [audioTrackM insertTimeRange:cutRange ofTrack:assetAudioTrack atTime:kCMTimeZero error:&error];
    if ( error ) { NSLog(@"Export Failed: error = %@", error); if ( failure ) failure(self, error); return;}
    [videoTrackM insertTimeRange:cutRange ofTrack:assetVideoTrack atTime:kCMTimeZero error:&error];
    if ( error ) { NSLog(@"Export Failed: error = %@", error); if ( failure ) failure(self, error); return;}
    
    NSURL *exportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"Export.mp4"];
    [[NSFileManager defaultManager] removeItemAtURL:exportURL error:nil];
    self.exportSession = [AVAssetExportSession exportSessionWithAsset:compositionM presetName:presetName];
    self.exportSession.outputURL = exportURL;
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    
    __weak typeof(self) _self = self;
    self.exportProgressRefreshTimer = [NSTimer assetAdd_timerWithTimeInterval:0.1 block:^(NSTimer *timer) {
        __strong typeof(_self) self = _self;
        if ( !self ) {
            [timer invalidate];
            return ;
        }
        if ( progress ) progress(self, self.exportSession.progress);
    } repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.exportProgressRefreshTimer forMode:NSRunLoopCommonModes];
    [self.exportProgressRefreshTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch ( self.exportSession.status ) {
            case AVAssetExportSessionStatusUnknown:
            case AVAssetExportSessionStatusWaiting:
            case AVAssetExportSessionStatusCancelled:
            case AVAssetExportSessionStatusExporting:
                break;
            case AVAssetExportSessionStatusCompleted: {
                [self screenshotWithTime:beginTime completion:^(SJPlayAsset * _Nonnull a, UIImage * _Nullable image, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __strong typeof(_self) self = _self;
                        if ( !self ) return;
                        if ( progress ) progress(self, 1);
                        if ( completion ) completion(self, compositionM, exportURL, image);
                    });
                }];
            }
                break;
            case AVAssetExportSessionStatusFailed: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    if ( failure ) failure(self, error);
                });
            }
                break;
        }
        if ( self.exportSession.status == AVAssetExportSessionStatusCancelled ||
            self.exportSession.status == AVAssetExportSessionStatusCompleted ||
            self.exportSession.status == AVAssetExportSessionStatusFailed ) {
            // clear
            [self cancelExportOperation];
        }
    }];
}

- (void)cancelExportOperation {
    AVAssetExportSession *session = [self exportSession];
    if ( session ) {
        [session cancelExport];
        [self setExportSession:nil];
        [self _clearExportProgressRefreshTimer];
    }
}

- (void)_clearExportProgressRefreshTimer {
    NSTimer *timer = [self exportProgressRefreshTimer];
    if ( timer ) {
        [timer invalidate];
        [self setExportProgressRefreshTimer:nil];
    }
}


#pragma mark
- (void)setGIFCreator:(nullable __SJGIFCreator *)GIFCreator {
    objc_setAssociatedObject(self, @selector(GIFCreator), GIFCreator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable __SJGIFCreator *)GIFCreator {
    return objc_getAssociatedObject(self, _cmd);
}

- (nullable AVAssetImageGenerator *)GIFImageGenerator {
    if ( !self.URLAsset ) return nil;
    AVAssetImageGenerator *GIFImageGenerator = objc_getAssociatedObject(self, _cmd);
    if ( GIFImageGenerator ) return GIFImageGenerator;
    GIFImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.URLAsset];
    GIFImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    GIFImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    GIFImageGenerator.appliesPreferredTrackTransform = YES;
    objc_setAssociatedObject(self, _cmd, GIFImageGenerator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return GIFImageGenerator;
}

/// interval: The interval at which the image is captured, Recommended setting 0.1f.
- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                     maximumSize:(CGSize)maximumSize
                        interval:(float)interval
                     gifSavePath:(NSURL *)gifSavePath
                        progress:(void(^)(SJPlayAsset *a, float progress))progressBlock
                      completion:(void(^)(SJPlayAsset *a, UIImage *imageGIF, UIImage *thumbnailImage))completion
                         failure:(void(^)(SJPlayAsset *a, NSError *error))failure {
    [self cancelGenerateGIFOperation];
    if ( interval == 0 ) interval = 0.2f;
    __block int count = (int)ceil(duration / interval);
    NSMutableArray<NSValue *> *timesM = [NSMutableArray new];
    for ( int i = 0 ; i < count ; ++ i ) {
        [timesM addObject:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(beginTime + i * interval, NSEC_PER_SEC)]];
    }
    self.GIFImageGenerator.maximumSize = maximumSize;
    self.GIFCreator = [[__SJGIFCreator alloc] initWithSavePath:gifSavePath imagesCount:count];
    int all = count;
    __weak typeof(self) _self = self;
    [self.GIFImageGenerator generateCGImagesAsynchronouslyForTimes:timesM completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch ( result ) {
            case AVAssetImageGeneratorSucceeded: {
                [self.GIFCreator addImage:imageRef];
                if ( progressBlock ) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progressBlock(self, 1 - count * 1.0f / all);
                    });
                }
                if ( --count != 0 ) return;
                BOOL result = [self.GIFCreator finalize];
                UIImage *image = getImage([NSData dataWithContentsOfURL:gifSavePath], [UIScreen mainScreen].scale);
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    if ( !result ) {
                        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                             code:-1
                                                         userInfo:@{@"msg":@"Generate Gif Failed!"}];
                        if ( failure ) failure(self, error);
                    }
                    else {
                        if ( progressBlock ) progressBlock(self, 1);
                        if ( completion ) completion(self, image, self.GIFCreator.firstImage);
                        self.GIFCreator = nil;
                    }
                });
            }
                break;
            case AVAssetImageGeneratorFailed: {
                [self.GIFImageGenerator cancelAllCGImageGeneration];
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    if ( failure ) failure(self, error);
                    self.GIFCreator = nil;
                });
            }
                break;
            case AVAssetImageGeneratorCancelled: break;
        }
    }];
}

- (void)cancelGenerateGIFOperation {
    AVAssetImageGenerator *GIFImageGenerator = objc_getAssociatedObject(self, @selector(GIFImageGenerator));
    if ( GIFImageGenerator ) {
        [GIFImageGenerator cancelAllCGImageGeneration];
        [self setGIFCreator:nil];
    }
}

#pragma mark -
/**
 ref: YYKit
 github: https://github.com/ibireme/YYKit/blob/4e1bd1cfcdb3331244b219cbd37cc9b1ccb62b7a/YYKit/Base/UIKit/UIImage%2BYYAdd.m#L25
 UIImage(YYAdd)
 */
static UIImage *getImage(NSData *data, CGFloat scale) {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFTypeRef)(data), NULL);
    if (!source) return nil;
    
    size_t count = CGImageSourceGetCount(source);
    if (count <= 1) {
        CFRelease(source);
        return [UIImage imageWithData:data scale:scale];
    }
    
    NSUInteger frames[count];
    double oneFrameTime = 1 / 50.0; // 50 fps
    NSTimeInterval totalTime = 0;
    NSUInteger totalFrame = 0;
    NSUInteger gcdFrame = 0;
    for (size_t i = 0; i < count; i++) {
        NSTimeInterval delay = _yy_CGImageSourceGetGIFFrameDelayAtIndex(source, i);
        totalTime += delay;
        NSInteger frame = lrint(delay / oneFrameTime);
        if (frame < 1) frame = 1;
        frames[i] = frame;
        totalFrame += frames[i];
        if (i == 0) gcdFrame = frames[i];
        else {
            NSUInteger frame = frames[i], tmp;
            if (frame < gcdFrame) {
                tmp = frame; frame = gcdFrame; gcdFrame = tmp;
            }
            while (true) {
                tmp = frame % gcdFrame;
                if (tmp == 0) break;
                frame = gcdFrame;
                gcdFrame = tmp;
            }
        }
    }
    NSMutableArray *array = [NSMutableArray new];
    for (size_t i = 0; i < count; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
        if (!imageRef) {
            CFRelease(source);
            return nil;
        }
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        if (width == 0 || height == 0) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        // BGRA8888 (premultiplied) or BGRX8888
        // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, space, bitmapInfo);
        CGColorSpaceRelease(space);
        if (!context) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
        CGImageRef decoded = CGBitmapContextCreateImage(context);
        CFRelease(context);
        if (!decoded) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        UIImage *image = [UIImage imageWithCGImage:decoded scale:scale orientation:UIImageOrientationUp];
        CGImageRelease(imageRef);
        CGImageRelease(decoded);
        if (!image) {
            CFRelease(source);
            return nil;
        }
        for (size_t j = 0, max = frames[i] / gcdFrame; j < max; j++) {
            [array addObject:image];
        }
    }
    CFRelease(source);
    UIImage *image = [UIImage animatedImageWithImages:array duration:totalTime];
    return image;
}

/**
 ref: YYKit
 github: https://github.com/ibireme/YYKit/blob/4e1bd1cfcdb3331244b219cbd37cc9b1ccb62b7a/YYKit/Base/UIKit/UIImage%2BYYAdd.m#L25
 UIImage(YYAdd)
 */
static NSTimeInterval _yy_CGImageSourceGetGIFFrameDelayAtIndex(CGImageSourceRef source, size_t index) {
    NSTimeInterval delay = 0;
    CFDictionaryRef dic = CGImageSourceCopyPropertiesAtIndex(source, index, NULL);
    if (dic) {
        CFDictionaryRef dicGIF = CFDictionaryGetValue(dic, kCGImagePropertyGIFDictionary);
        if (dicGIF) {
            NSNumber *num = CFDictionaryGetValue(dicGIF, kCGImagePropertyGIFUnclampedDelayTime);
            if (num.doubleValue <= __FLT_EPSILON__) {
                num = CFDictionaryGetValue(dicGIF, kCGImagePropertyGIFDelayTime);
            }
            delay = num.doubleValue;
        }
        CFRelease(dic);
    }
    
    // http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser-compatibility
    if (delay < 0.02) delay = 0.1;
    return delay;
}
@end


@implementation  SJPlayAsset (SJBaseVideoPlayerAdd_CancelOperation)
- (void)cancelOperation {
    [self cancelExportOperation];
    [self cancelScreenshotOperation];
    [self cancelGenerateGIFOperation];
    [self cancelPreviewImagesGeneration];
}
@end
NS_ASSUME_NONNULL_END
