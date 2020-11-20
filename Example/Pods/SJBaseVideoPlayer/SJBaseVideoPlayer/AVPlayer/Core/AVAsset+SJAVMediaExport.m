//
//  AVAsset+SJAVMediaExport.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/2/2.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "AVAsset+SJAVMediaExport.h"
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSTimer+SJAssetAdd.h"

NS_ASSUME_NONNULL_BEGIN
@interface _SJAVAssetPreviewImagesGenerator : NSObject
- (instancetype)initWithAsset:(__weak AVAsset *)asset;
@property (nonatomic, weak, readonly, nullable) AVAsset *asset;
- (void)generatePreviewImagesWithMaxItemSize:(CGSize)itemSize count:(NSUInteger)count completionHandler:(void (^)(AVAsset * _Nonnull, NSArray<UIImage *> * _Nullable, NSError * _Nullable))block;
- (void)cancel;
@end

@interface _SJAVAssetPreviewImagesGenerator ()
@property (nonatomic, strong, readonly) AVAssetImageGenerator *imageGenerator;
@end

@implementation _SJAVAssetPreviewImagesGenerator
- (instancetype)initWithAsset:(AVAsset *)asset {
    self = [super init];
    if ( !self ) return nil;
    _asset = asset;
    _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    _imageGenerator.appliesPreferredTrackTransform = YES;
    return self;
}

- (void)sj_loadDurationOfAsset:(void(^)(CMTime duration))completionHandler {
    if ( 0 != CMTimeCompare(kCMTimeZero, _asset.duration) ) {
        if ( completionHandler ) completionHandler(_asset.duration);
    }
    else {
        __weak typeof(self) _self = self;
        [_asset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( completionHandler ) completionHandler(self.asset.duration);
        }];
    }
}

- (void)generatePreviewImagesWithMaxItemSize:(CGSize)itemSize count:(NSUInteger)count completionHandler:(void (^)(AVAsset * _Nonnull, NSArray<UIImage *> * _Nullable, NSError * _Nullable))block {
    NSParameterAssert(count);
    [self cancel];
    
    __weak typeof(self) _self = self;
    [self sj_loadDurationOfAsset:^(CMTime duration) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        NSTimeInterval secs = CMTimeGetSeconds(duration);
        NSTimeInterval interval = secs / count;
        NSMutableArray<NSValue *> *timesM = [NSMutableArray arrayWithCapacity:count];
        for ( int i = 0 ; i < count ; ++ i ) {
            [timesM addObject:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(interval * i, NSEC_PER_SEC)]];
        }
        
        NSMutableArray<UIImage *> *m = [NSMutableArray arrayWithCapacity:count];
        self.imageGenerator.maximumSize = itemSize;
        __block NSInteger imgs = count;
        [self.imageGenerator generateCGImagesAsynchronouslyForTimes:timesM completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            switch ( result ) {
                case AVAssetImageGeneratorSucceeded: {
                    UIImage *image = [UIImage imageWithCGImage:imageRef];
                    [m addObject:image];
                    if ( --imgs != 0 ) return;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __strong typeof(_self) self = _self;
                        if ( !self ) return;
                        if ( block ) block(self.asset, m, nil);
                    });
                }
                    break;
                case AVAssetImageGeneratorFailed: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __strong typeof(_self) self = _self;
                        if ( !self ) return;
                        [self cancel];
                        if ( block ) block(self.asset, nil, error);
                    });
                }
                    break;
                case AVAssetImageGeneratorCancelled: break;
            }
        }];
    }];
}

- (void)cancel {
    [self.imageGenerator cancelAllCGImageGeneration];
}

@end


@interface _SJAVAssetExporter : NSObject
- (instancetype)initWithAsset:(__weak AVAsset *)asset;
@property (nonatomic, weak, readonly, nullable) AVAsset *asset;
@end

@interface _SJAVAssetExporter ()
@property (nonatomic, strong, nullable) AVAssetExportSession *exportSession;
@property (nonatomic, strong, nullable) NSTimer *exportProgressRefreshTimer;
@end

@implementation _SJAVAssetExporter
- (instancetype)initWithAsset:(AVAsset *)asset {
    self = [super init];
    if ( !self ) return nil;
    _asset = asset;
    return self;
}

- (void)exportWithStartTime:(NSTimeInterval)startTime
                   duration:(NSTimeInterval)secs1
                     toFile:(NSURL *)fileURL
                 presetName:(nullable NSString *)presetName
                   progress:(nullable void(^)(AVAsset *a, float progress))progress
                    success:(nullable void(^)(AVAsset *a, AVAsset * __nullable sandboxAsset, NSURL * __nullable fileURL, UIImage * __nullable thumbImage))success
                    failure:(nullable void(^)(AVAsset *a, NSError * __nullable error))failure {
    [self cancel];
    
    NSTimeInterval endTime = startTime + secs1;
    if ( endTime - startTime <= 0 ) {
        if ( failure ) failure(self.asset, [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"msg":@"Error: Start time is greater than end time!"}]);
        return;
    }
    if ( !presetName ) presetName = AVAssetExportPresetMediumQuality;
    AVAsset *asset = self.asset;
    AVMutableComposition *compositionM = [AVMutableComposition composition];
    AVMutableCompositionTrack *audioTrackM = [compositionM addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *videoTrackM = [compositionM addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTimeRange cutRange = CMTimeRangeMake(CMTimeMakeWithSeconds(startTime, NSEC_PER_SEC), CMTimeMakeWithSeconds(endTime - startTime, NSEC_PER_SEC));
    AVAssetTrack *assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    AVAssetTrack *assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    NSError *error = nil;
    [audioTrackM insertTimeRange:cutRange ofTrack:assetAudioTrack atTime:kCMTimeZero error:&error];
    if ( error ) { NSLog(@"Export Failed: error = %@", error); if ( failure ) failure(self.asset, error); return;}
    [videoTrackM insertTimeRange:cutRange ofTrack:assetVideoTrack atTime:kCMTimeZero error:&error];
    if ( error ) { NSLog(@"Export Failed: error = %@", error); if ( failure ) failure(self.asset, error); return;}
    videoTrackM.preferredTransform = assetVideoTrack.preferredTransform;
    
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
    self.exportSession = [AVAssetExportSession exportSessionWithAsset:compositionM presetName:presetName];
    self.exportSession.outputURL = fileURL;
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    
    __weak typeof(self) _self = self;
    self.exportProgressRefreshTimer = [NSTimer assetAdd_timerWithTimeInterval:0.1 block:^(NSTimer *timer) {
        __strong typeof(_self) self = _self;
        if ( !self ) {
            [timer invalidate];
            return ;
        }
        if ( progress ) progress(self.asset, self.exportSession.progress);
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
                UIImage *image = [compositionM sj_screenshotWithTime:kCMTimeZero];
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    if ( progress ) progress(self.asset, 1);
                    if ( success ) success(self.asset, compositionM, fileURL, image);
                });
            }
                break;
            case AVAssetExportSessionStatusFailed: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    if ( failure ) failure(self.asset, error);
                });
            }
                break;
        }
        
        // clear timer & session
        if ( self.exportSession.status == AVAssetExportSessionStatusCancelled ||
            self.exportSession.status == AVAssetExportSessionStatusCompleted ||
            self.exportSession.status == AVAssetExportSessionStatusFailed ) {
            [self cancel];
        }
    }];

}

- (void)cancel {
    [_exportSession cancelExport];
    [_exportProgressRefreshTimer invalidate];
    _exportProgressRefreshTimer = nil;
}
@end

@interface _SJAVAssetScreenshotGenerator : NSObject
- (instancetype)initWithAsset:(__weak AVAsset *)asset;
@property (nonatomic, strong, readonly) AVAssetImageGenerator *screenshotGenerator;
@property (nonatomic, weak, readonly, nullable) AVAsset *asset;
@end

@implementation _SJAVAssetScreenshotGenerator
- (instancetype)initWithAsset:(AVAsset *)asset {
    self = [super init];
    if ( !self ) return nil;
    _asset = asset;
    _screenshotGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    _screenshotGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    _screenshotGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    _screenshotGenerator.appliesPreferredTrackTransform = YES;
    return self;
}

- (UIImage * __nullable)sj_screenshotWithTime:(CMTime)time {
    CGImageRef imgRef = [self.screenshotGenerator copyCGImageAtTime:time actualTime:&time error:nil];
    if ( !imgRef ) return nil;
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    return image;
}

- (void)sj_screenshotWithTime:(NSTimeInterval)t
                         size:(CGSize)size
            completionHandler:(void(^)(AVAsset *a, UIImage * __nullable image, NSError *__nullable error))block {
    [self.screenshotGenerator cancelAllCGImageGeneration];
    CMTime time = CMTimeMakeWithSeconds(t, NSEC_PER_SEC);
    self.screenshotGenerator.maximumSize = size;
    __weak typeof(self) _self = self;
    [self.screenshotGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( result == AVAssetImageGeneratorSucceeded ) {
            if ( block ) block(self.asset, [UIImage imageWithCGImage:imageRef], nil);
        }
        else if ( result == AVAssetImageGeneratorFailed ) {
            if ( block ) block(self.asset, nil, error);
        }
    }];
}

- (void)sj_cancelScreenshotOperation {
    [self.screenshotGenerator cancelAllCGImageGeneration];
}
@end


@interface _SJGIFCreator : NSObject
@property (nonatomic, strong, readonly) UIImage *firstImage;
- (instancetype)initWithSavePath:(NSURL *)savePath imagesCount:(int)count interval:(NSTimeInterval)interval;
- (void)addImage:(CGImageRef)imageRef;
- (BOOL)finalize;
@end

@interface _SJGIFCreator ()
@property (nonatomic, nullable) CGImageDestinationRef destination;
@property (nonatomic, strong, readonly) NSDictionary *frameProperties;
@end

@implementation _SJGIFCreator
- (instancetype)initWithSavePath:(NSURL *)savePath imagesCount:(int)count interval:(NSTimeInterval)interval {
    self = [super init];
    if ( !self ) return nil;
    if ( interval < 0.02 ) interval = 0.1;
    [[NSFileManager defaultManager] removeItemAtURL:savePath error:nil];
    _destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)savePath, kUTTypeGIF, count, NULL);
    NSDictionary *fileProperties = @{ (__bridge id)kCGImagePropertyGIFDictionary: @{(__bridge id)kCGImagePropertyGIFLoopCount: @(0)} };
    CGImageDestinationSetProperties(_destination, (__bridge CFDictionaryRef)fileProperties);
    _frameProperties = @{ (__bridge id)kCGImagePropertyGIFDictionary: @{(__bridge id)kCGImagePropertyGIFDelayTime: @(interval)} };
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

@interface _SJAVAssetGIFGenerator : NSObject
- (instancetype)initWithAsset:(__weak AVAsset *)asset;
@property (nonatomic, strong, readonly) AVAssetImageGenerator *generator;
@property (nonatomic, weak, readonly, nullable) AVAsset *asset;
@property (nonatomic, strong, nullable) _SJGIFCreator *creator;
@end

@implementation _SJAVAssetGIFGenerator
- (instancetype)initWithAsset:(AVAsset *)asset {
    self = [super init];
    if ( !self ) return nil;
    _asset = asset;
    _generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    _generator.requestedTimeToleranceBefore = kCMTimeZero;
    _generator.requestedTimeToleranceAfter = kCMTimeZero;
    _generator.appliesPreferredTrackTransform = YES;
    return self;
}

- (void)sj_generateGIFWithBeginTime:(NSTimeInterval)beginTime
                           duration:(NSTimeInterval)duration
                       imageMaxSize:(CGSize)size
                           interval:(float)interval
                             toFile:(NSURL *)fileURL
                           progress:(void(^)(AVAsset *a, float progress))progressBlock
                            success:(void(^)(AVAsset *a, UIImage *GIFImage, UIImage *thumbnailImage))successBlock
                            failure:(void(^)(AVAsset *a, NSError *error))failureBlock {
    [self cancelGenerateGIFOperation];
    if ( interval < 0.02 ) interval = 0.1f;
    __block int count = (int)ceil(duration / interval);
    NSMutableArray<NSValue *> *timesM = [NSMutableArray new];
    for ( int i = 0 ; i < count ; ++ i ) {
        [timesM addObject:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(beginTime + i * interval, NSEC_PER_SEC)]];
    }
    self.generator.maximumSize = size;
    self.creator = [[_SJGIFCreator alloc] initWithSavePath:fileURL imagesCount:count interval:interval];
    int all = count;
    __weak typeof(self) _self = self;
    [self.generator generateCGImagesAsynchronouslyForTimes:timesM completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch ( result ) {
            case AVAssetImageGeneratorSucceeded: {
                [self.creator addImage:imageRef];
                if ( progressBlock ) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progressBlock(self.asset, 1 - count * 1.0f / all);
                    });
                }
                if ( --count != 0 ) return;
                BOOL result = [self.creator finalize];
                UIImage *image = getImage([NSData dataWithContentsOfURL:fileURL], [UIScreen mainScreen].scale);
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    if ( !result ) {
                        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                             code:-1
                                                         userInfo:@{@"msg":@"Generate Gif Failed!"}];
                        if ( failureBlock ) failureBlock(self.asset, error);
                    }
                    else {
                        if ( progressBlock ) progressBlock(self.asset, 1);
                        if ( successBlock ) successBlock(self.asset, image, self.creator.firstImage);
                        self.creator = nil;
                    }
                });
            }
                break;
            case AVAssetImageGeneratorFailed: {
                [self.generator cancelAllCGImageGeneration];
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    if ( failureBlock ) failureBlock(self.asset, error);
                });
            }
                break;
            case AVAssetImageGeneratorCancelled: break;
        }
        
        if ( result == AVAssetImageGeneratorCancelled ) {
            self.creator = nil;
        }
    }];
}

- (void)cancelGenerateGIFOperation {
    [self.generator cancelAllCGImageGeneration];
}

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
    NSTimeInterval duration = 0;
    NSUInteger totalFrame = 0;
    NSUInteger gcdFrame = 0;
    for (size_t i = 0; i < count; i++) {
        NSTimeInterval delay = _yy_CGImageSourceGetGIFFrameDelayAtIndex(source, i);
        duration += delay;
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
    UIImage *image = [UIImage animatedImageWithImages:array duration:duration];
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


@implementation AVAsset (SJAVMediaExport)
#pragma mark -

- (_SJAVAssetPreviewImagesGenerator *)sj_imagesGenerator {
    _SJAVAssetPreviewImagesGenerator *_Nullable generator = objc_getAssociatedObject(self, _cmd);
    if (  generator ) return  generator;
     generator = [[_SJAVAssetPreviewImagesGenerator alloc] initWithAsset:self];
    objc_setAssociatedObject(self, _cmd,  generator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return  generator;
}

- (void)sj_generatePreviewImagesWithMaxItemSize:(CGSize)itemSize count:(NSUInteger)count completionHandler:(void (^)(AVAsset * _Nonnull, NSArray<UIImage *> * _Nullable, NSError * _Nullable))block {
    [self.sj_imagesGenerator generatePreviewImagesWithMaxItemSize:itemSize count:count completionHandler:block];
}

- (void)sj_cancelGeneratePreviewImages {
    _SJAVAssetPreviewImagesGenerator *_Nullable generator = objc_getAssociatedObject(self, _cmd);
    [generator cancel];
}

#pragma mark -

- (_SJAVAssetExporter *)sj_assetExporter {
    _SJAVAssetExporter *_Nullable exporter = objc_getAssociatedObject(self, _cmd);
    if ( exporter ) return exporter;
    exporter = [[_SJAVAssetExporter alloc] initWithAsset:self];
    objc_setAssociatedObject(self, _cmd, exporter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return exporter;
}

/// preset name default is `AVAssetExportPresetMediumQuality`.
- (void)sj_exportWithStartTime:(NSTimeInterval)startTime
                      duration:(NSTimeInterval)secs1
                        toFile:(NSURL *)fileURL
                    presetName:(nullable NSString *)presetName
                      progress:(nullable void(^)(AVAsset *a, float progress))progress
                       success:(nullable void(^)(AVAsset *a, AVAsset * __nullable sandboxAsset, NSURL * __nullable fileURL, UIImage * __nullable thumbImage))success
                       failure:(nullable void(^)(AVAsset *a, NSError * __nullable error))failure {
    [self.sj_assetExporter exportWithStartTime:startTime duration:secs1 toFile:fileURL presetName:presetName progress:progress success:success failure:failure];
}

- (void)sj_cancelExportOperation {
    _SJAVAssetExporter *_Nullable exporter = objc_getAssociatedObject(self, _cmd);
    [exporter cancel];
}

#pragma mark -

- (_SJAVAssetScreenshotGenerator *)sj_screenshotGenerator {
    _SJAVAssetScreenshotGenerator *_Nullable generator = objc_getAssociatedObject(self, _cmd);
    if ( generator ) return generator;
    generator = [[_SJAVAssetScreenshotGenerator alloc] initWithAsset:self];
    objc_setAssociatedObject(self, _cmd, generator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return generator;
}
- (UIImage * __nullable)sj_screenshotWithTime:(CMTime)time {
    return [self.sj_screenshotGenerator sj_screenshotWithTime:time];
}

- (void)sj_screenshotWithTime:(NSTimeInterval)time
            completionHandler:(void(^)(AVAsset *a, UIImage * __nullable images, NSError *__nullable error))block {
    [self sj_screenshotWithTime:time size:CGSizeZero completionHandler:block];
}

- (void)sj_screenshotWithTime:(NSTimeInterval)time
                         size:(CGSize)size
            completionHandler:(void(^)(AVAsset *a, UIImage * __nullable image, NSError *__nullable error))block {
    [self.sj_screenshotGenerator sj_screenshotWithTime:time size:size completionHandler:block];
}

- (void)sj_cancelScreenshotOperation {
    _SJAVAssetScreenshotGenerator *_Nullable generator = objc_getAssociatedObject(self, _cmd);
    [generator sj_cancelScreenshotOperation];
}

#pragma mark -
- (_SJAVAssetGIFGenerator *)sj_GIFGenerator {
    _SJAVAssetGIFGenerator *_Nullable generator = objc_getAssociatedObject(self, _cmd);
    if ( generator ) return generator;
    generator = [[_SJAVAssetGIFGenerator alloc] initWithAsset:self];
    objc_setAssociatedObject(self, _cmd, generator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return generator;
}

- (void)sj_generateGIFWithBeginTime:(NSTimeInterval)beginTime
                           duration:(NSTimeInterval)duration
                       imageMaxSize:(CGSize)size
                           interval:(float)interval
                             toFile:(NSURL *)fileURL
                           progress:(void(^)(AVAsset *a, float progress))progressBlock
                            success:(void(^)(AVAsset *a, UIImage *GIFImage, UIImage *thumbnailImage))successBlock
                            failure:(void(^)(AVAsset *a, NSError *error))failureBlock {
    [self.sj_GIFGenerator sj_generateGIFWithBeginTime:beginTime duration:duration imageMaxSize:size interval:interval toFile:fileURL progress:progressBlock success:successBlock failure:failureBlock];
}

- (void)sj_cancelGenerateGIFOperation {
    _SJAVAssetGIFGenerator *_Nullable generator = objc_getAssociatedObject(self, _cmd);
    [generator cancelGenerateGIFOperation];
}
@end
NS_ASSUME_NONNULL_END
