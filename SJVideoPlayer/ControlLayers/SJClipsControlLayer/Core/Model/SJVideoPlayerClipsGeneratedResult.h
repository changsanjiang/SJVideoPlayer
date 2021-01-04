//
//  SJVideoPlayerClipsGeneratedResult.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerClipsDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerClipsGeneratedResult : NSObject<SJVideoPlayerClipsResult>
@property (nonatomic) SJVideoPlayerClipsOperation operation;
@property (nonatomic) SJClipsExportState exportState;
@property (nonatomic) float exportProgress;
@property (nonatomic) SJClipsResultUploadState uploadState;
@property (nonatomic) float uploadProgress;

// results
@property (nonatomic, strong, nullable) UIImage *thumbnailImage;
@property (nonatomic, strong, nullable) UIImage *image; // screenshot or GIF
@property (nonatomic, strong, nullable) NSURL *fileURL;
@property (nonatomic, strong, nullable) SJVideoPlayerURLAsset *currentPlayAsset;
- (NSData * __nullable)data;

@property (nonatomic, copy, nullable) void(^exportProgressDidChangeExeBlock)(SJVideoPlayerClipsGeneratedResult *result);
@property (nonatomic, copy, nullable) void(^uploadProgressDidChangeExeBlock)(SJVideoPlayerClipsGeneratedResult *result);

@property (nonatomic, copy, nullable) void(^exportStateDidChangeExeBlock)(SJVideoPlayerClipsGeneratedResult *result);
@property (nonatomic, copy, nullable) void(^uploadStateDidChangeExeBlock)(SJVideoPlayerClipsGeneratedResult *result);
@end
NS_ASSUME_NONNULL_END
