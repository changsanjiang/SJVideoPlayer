//
//  SJVideoPlayerAssetCarrier.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/1.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SJVideoPreviewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerAssetCarrier : NSObject

- (instancetype)initWithAssetURL:(NSURL *)assetURL;

/// unit is sec.
- (instancetype)initWithAssetURL:(NSURL *)assetURL beginTime:(NSTimeInterval)beginTime;

@property (nonatomic, strong, readonly) AVURLAsset *asset;
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, strong, readonly) NSURL *assetURL;
@property (nonatomic, assign, readonly) NSTimeInterval beginTime;
@property (nonatomic, assign, readonly) NSInteger duration; // unit is sec.
@property (nonatomic, assign, readonly) NSInteger currentTime; // unit is sec.

@property (nonatomic, copy, readwrite, nullable) void(^playerItemStateChanged)(SJVideoPlayerAssetCarrier *asset, AVPlayerItemStatus status);

@property (nonatomic, copy, readwrite, nullable) void(^playTimeChanged)(SJVideoPlayerAssetCarrier *asset, NSTimeInterval currentTime, NSTimeInterval duration);

@property (nonatomic, copy, readwrite, nullable) void(^playDidToEnd)(SJVideoPlayerAssetCarrier *asset);

#pragma mark - Generated Preview Images

@property (nonatomic, assign, readonly) BOOL hasBeenGeneratedPreviewImages;
@property (nonatomic, strong, readonly) NSArray<SJVideoPreviewModel *> *generatedPreviewImages;

- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize completion:(void(^)(SJVideoPlayerAssetCarrier *asset, NSArray<SJVideoPreviewModel *> *__nullable images, NSError *__nullable error))block;

- (void)cancelPreviewImagesGeneration;

- (UIImage *)screenshot;

@end

NS_ASSUME_NONNULL_END
