//
//  SJVideoPlayerClipsDefines.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/4/12.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#ifndef SJVideoPlayerClipsDefines_h
#define SJVideoPlayerClipsDefines_h

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class SJClipsControlLayer, SJClipsResultShareItem, SJVideoPlayerURLAsset, SJBaseVideoPlayer;
@protocol SJVideoPlayerClipsResult, SJVideoPlayerClipsResultUpload;

typedef NS_ENUM(NSUInteger, SJClipsStatus) {
    SJClipsStatus_Unknown,
    SJClipsStatus_Recording,
    SJClipsStatus_Cancelled,
    SJClipsStatus_Paused,
    SJClipsStatus_Finished,
};

typedef enum : NSUInteger {
    SJVideoPlayerClipsOperation_Unknown,
    SJVideoPlayerClipsOperation_Screenshot,
    SJVideoPlayerClipsOperation_Export,
    SJVideoPlayerClipsOperation_GIF,
} SJVideoPlayerClipsOperation;

typedef enum : NSUInteger {
    SJClipsResultUploadStateUnknown,
    SJClipsResultUploadStateUploading,
    SJClipsResultUploadStateFailed,
    SJClipsResultUploadStateSuccessfully,
    SJClipsResultUploadStateCancelled,
} SJClipsResultUploadState;

typedef enum : NSUInteger {
    SJClipsExportStateUnknown,
    SJClipsExportStateExporting,
    SJClipsExportStateFailed,
    SJClipsExportStateSuccess,
    SJClipsExportStateCancelled,
} SJClipsExportState;

NS_ASSUME_NONNULL_BEGIN
@protocol SJVideoPlayerClipsParameters <NSObject>
// operation
@property (nonatomic, readonly) SJVideoPlayerClipsOperation operation;
@property (nonatomic, readonly) CMTimeRange range;

// upload
@property (nonatomic) BOOL resultNeedUpload;
@property (nonatomic, weak, nullable) id<SJVideoPlayerClipsResultUpload> resultUploader;

// album
@property (nonatomic) BOOL saveResultToAlbum;
@end

@protocol SJVideoPlayerClipsResult <NSObject>
@property (nonatomic, readonly) SJVideoPlayerClipsOperation operation;
@property (nonatomic, readonly) SJClipsExportState exportState;
@property (nonatomic, readonly) SJClipsResultUploadState uploadState;

/// results
@property (nonatomic, strong, readonly, nullable) UIImage *thumbnailImage;
@property (nonatomic, strong, readonly, nullable) UIImage *image; // screenshot or GIF
@property (nonatomic, strong, readonly, nullable) NSURL *fileURL;
@property (nonatomic, strong, readonly, nullable) SJVideoPlayerURLAsset *currentPlayAsset;
- (NSData * __nullable)data;
@end

@protocol SJVideoPlayerClipsResultUpload <NSObject>
- (void)upload:(id<SJVideoPlayerClipsResult>)result
      progress:(void(^ __nullable)(float progress))progressBlock
       success:(void(^ __nullable)(void))success
       failure:(void (^ __nullable)(NSError *error))failure;

- (void)cancelUpload:(id<SJVideoPlayerClipsResult>)result;
@end
NS_ASSUME_NONNULL_END

#endif /* SJVideoPlayerClipsDefines_h */
