//
//  SJVideoPlayerURLAsset+SJAVMediaPlaybackAdd.h
//  Project
//
//  Created by 畅三江 on 2018/8/12.
//  Copyright © 2018 changsanjiang. All rights reserved.
//

#import "SJVideoPlayerURLAsset.h"
#import <AVFoundation/AVFoundation.h>
#import "SJPlayModel.h"
#import "SJVideoPlayerPlaybackControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerURLAsset (SJAVMediaPlaybackAdd)
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset;
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset
                               playModel:(__kindof SJPlayModel *)playModel;
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset
                           startPosition:(NSTimeInterval)startPosition
                               playModel:(__kindof SJPlayModel *)playModel;

- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem;
- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem
                                    playModel:(__kindof SJPlayModel *)playModel;
- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem
                                startPosition:(NSTimeInterval)startPosition
                                    playModel:(__kindof SJPlayModel *)playModel;

- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player;
- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player
                                playModel:(__kindof SJPlayModel *)playModel;
- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player
                            startPosition:(NSTimeInterval)startPosition
                                playModel:(__kindof SJPlayModel *)playModel;

@property (nonatomic, strong, readonly, nullable) __kindof AVAsset *avAsset;
@property (nonatomic, strong, readonly, nullable) AVPlayerItem *avPlayerItem;
@property (nonatomic, strong, readonly, nullable) AVPlayer *avPlayer;

- (nullable instancetype)initWithOtherAsset:(SJVideoPlayerURLAsset *)otherAsset
                                  playModel:(nullable __kindof SJPlayModel *)playModel;

@property (nonatomic, strong, readonly, nullable) SJVideoPlayerURLAsset *original;
- (nullable SJVideoPlayerURLAsset *)originAsset __deprecated_msg("ues `original`");
@end
NS_ASSUME_NONNULL_END
