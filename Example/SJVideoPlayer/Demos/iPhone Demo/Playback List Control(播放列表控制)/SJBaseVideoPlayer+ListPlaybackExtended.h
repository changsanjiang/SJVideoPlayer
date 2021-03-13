//
//  SJBaseVideoPlayer+ListPlaybackExtended.h
//  SJVideoPlayer_Example
//
//  Created by BD on 2021/3/13.
//  Copyright © 2021 changsanjiang. All rights reserved.
//

#import "SJBaseVideoPlayer.h"
@protocol SJBaseVideoPlayerAssetProvider;

NS_ASSUME_NONNULL_BEGIN
@interface SJBaseVideoPlayer (ListPlaybackExtended)
  
@property (nonatomic, weak, nullable) id<SJBaseVideoPlayerAssetProvider> assetProvider;
@property (nonatomic) NSInteger numberOfAssets;
@property (nonatomic, readonly) NSInteger currentAssetIndex;

- (void)playPreviousAsset;
- (void)playNextAsset;
- (void)playAtIndex:(NSInteger)index;

@end

@protocol SJBaseVideoPlayerAssetProvider <NSObject>
- (SJVideoPlayerURLAsset *)videoPlayer:(__kindof SJBaseVideoPlayer *)player assetAtIndex:(NSInteger)index;
@end
NS_ASSUME_NONNULL_END
