//
//  SJVideoPlayerFilmEditingDefines.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/4/12.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#ifndef SJVideoPlayerFilmEditingDefines_h
#define SJVideoPlayerFilmEditingDefines_h

#import <UIKit/UIKit.h>
#import "SJFilmEditingStatus.h"
#import <AVFoundation/AVFoundation.h>
@class SJFilmEditingControlLayer, SJFilmEditingResultShareItem, SJVideoPlayerURLAsset, SJBaseVideoPlayer;
@protocol SJVideoPlayerFilmEditingResult, SJVideoPlayerFilmEditingResultUpload;
typedef enum : NSUInteger {
    SJVideoPlayerFilmEditingOperation_Unknown,
    SJVideoPlayerFilmEditingOperation_Screenshot,
    SJVideoPlayerFilmEditingOperation_Export,
    SJVideoPlayerFilmEditingOperation_GIF,
} SJVideoPlayerFilmEditingOperation;

typedef enum : NSUInteger {
    SJFilmEditingResultUploadStateUnknown,
    SJFilmEditingResultUploadStateUploading,
    SJFilmEditingResultUploadStateFailed,
    SJFilmEditingResultUploadStateSuccessful,
    SJFilmEditingResultUploadStateCancelled,
} SJFilmEditingResultUploadState;

typedef enum : NSUInteger {
    SJFilmEditingExportStateUnknown,
    SJFilmEditingExportStateExporting,
    SJFilmEditingExportStateFailed,
    SJFilmEditingExportStateSuccess,
    SJFilmEditingExportStateCancelled,
} SJFilmEditingExportState;

NS_ASSUME_NONNULL_BEGIN
@protocol SJVideoPlayerFilmEditingParameters <NSObject>
// operation
@property (nonatomic, readonly) SJVideoPlayerFilmEditingOperation operation;
@property (nonatomic, readonly) CMTimeRange range;

// upload
@property (nonatomic) BOOL resultNeedUpload;
@property (nonatomic, weak, nullable) id<SJVideoPlayerFilmEditingResultUpload> resultUploader;

// album
@property (nonatomic) BOOL saveResultToAlbumWhenExportSuccess;
@end

@protocol SJVideoPlayerFilmEditingResult <NSObject>
@property (nonatomic, readonly) SJVideoPlayerFilmEditingOperation operation;
@property (nonatomic, readonly) SJFilmEditingExportState exportState;
@property (nonatomic, readonly) SJFilmEditingResultUploadState uploadState;

/// results
@property (nonatomic, strong, readonly, nullable) UIImage *thumbnailImage;
@property (nonatomic, strong, readonly, nullable) UIImage *image; // screenshot or GIF
@property (nonatomic, strong, readonly, nullable) NSURL *fileURL;
@property (nonatomic, strong, readonly, nullable) SJVideoPlayerURLAsset *currentPlayAsset;
- (NSData * __nullable)data;
@end

@protocol SJVideoPlayerFilmEditingResultUpload <NSObject>
- (void)upload:(id<SJVideoPlayerFilmEditingResult>)result
      progress:(void(^ __nullable)(float progress))progressBlock
       success:(void(^ __nullable)(void))success
       failure:(void (^ __nullable)(NSError *error))failure;

- (void)cancelUpload:(id<SJVideoPlayerFilmEditingResult>)result;
@end
NS_ASSUME_NONNULL_END

#endif /* SJVideoPlayerFilmEditingDefines_h */
