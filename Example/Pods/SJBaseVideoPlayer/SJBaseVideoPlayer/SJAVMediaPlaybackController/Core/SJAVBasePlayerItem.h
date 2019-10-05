//
//  SJAVBasePlayerItem.h
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/9/25.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJAVBasePlayerItem : AVPlayerItem
- (instancetype)initWithAsset:(AVAsset *)asset;

+ (instancetype)playerItemWithURL:(NSURL *)URL NS_UNAVAILABLE;
+ (instancetype)playerItemWithAsset:(AVAsset *)asset NS_UNAVAILABLE;
+ (instancetype)playerItemWithAsset:(AVAsset *)asset automaticallyLoadedAssetKeys:(nullable NSArray<NSString *> *)automaticallyLoadedAssetKeys API_AVAILABLE(macos(10.9), ios(7.0), tvos(9.0), watchos(1.0)) NS_UNAVAILABLE;
- (instancetype)initWithURL:(NSURL *)URL NS_UNAVAILABLE;
- (instancetype)initWithAsset:(AVAsset *)asset automaticallyLoadedAssetKeys:(nullable NSArray<NSString *> *)automaticallyLoadedAssetKeys API_AVAILABLE(macos(10.9), ios(7.0), tvos(9.0), watchos(1.0)) NS_UNAVAILABLE;
@end

@interface SJAVBasePlayerItemObserver : NSObject
- (instancetype)initWithBasePlayerItem:(SJAVBasePlayerItem *)item;
@property (nonatomic, copy, nullable) void(^statusDidChangeExeBlock)(SJAVBasePlayerItem *item);
@property (nonatomic, copy, nullable) void(^playbackLikelyToKeepUpExeBlock)(SJAVBasePlayerItem *item);
@property (nonatomic, copy, nullable) void(^playbackBufferEmptyDidChangeExeBlock)(SJAVBasePlayerItem *item);
@property (nonatomic, copy, nullable) void(^playbackBufferFullDidChangeExeBlock)(SJAVBasePlayerItem *item);
@property (nonatomic, copy, nullable) void(^loadedTimeRangesDidChangeExeBlock)(SJAVBasePlayerItem *item);
@property (nonatomic, copy, nullable) void(^presentationSizeDidChangeExeBlock)(SJAVBasePlayerItem *item);

@property (nonatomic, copy, nullable) void(^failedToPlayToEndTimeExeBlock)(SJAVBasePlayerItem *item, NSError *error);
@property (nonatomic, copy, nullable) void(^didPlayToEndTimeExeBlock)(SJAVBasePlayerItem *item);
@property (nonatomic, copy, nullable) void(^newAccessLogEntryExeBlock)(SJAVBasePlayerItem *item);
@end
NS_ASSUME_NONNULL_END
