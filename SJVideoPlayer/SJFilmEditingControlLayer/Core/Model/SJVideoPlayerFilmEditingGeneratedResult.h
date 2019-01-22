//
//  SJVideoPlayerFilmEditingGeneratedResult.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerFilmEditingCommonHeader.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerFilmEditingGeneratedResult : NSObject<SJVideoPlayerFilmEditingResult>
@property (nonatomic) SJVideoPlayerFilmEditingOperation operation;
@property (nonatomic) SJFilmEditingExportState exportState;
@property (nonatomic) float exportProgress;
@property (nonatomic) SJFilmEditingResultUploadState uploadState;
@property (nonatomic) float uploadProgress;

// results
@property (nonatomic, strong, nullable) UIImage *thumbnailImage;
@property (nonatomic, strong, nullable) UIImage *image; // screenshot or GIF
@property (nonatomic, strong, nullable) NSURL *fileURL;
@property (nonatomic, strong, nullable) SJVideoPlayerURLAsset *currentPlayAsset;
- (NSData * __nullable)data;

@property (nonatomic, copy, nullable) void(^exportProgressDidChangeExeBlock)(SJVideoPlayerFilmEditingGeneratedResult *result);
@property (nonatomic, copy, nullable) void(^uploadProgressDidChangeExeBlock)(SJVideoPlayerFilmEditingGeneratedResult *result);

@property (nonatomic, copy, nullable) void(^exportStateDidChangeExeBlock)(SJVideoPlayerFilmEditingGeneratedResult *result);
@property (nonatomic, copy, nullable) void(^uploadStateDidChangeExeBlock)(SJVideoPlayerFilmEditingGeneratedResult *result);
@end
NS_ASSUME_NONNULL_END
