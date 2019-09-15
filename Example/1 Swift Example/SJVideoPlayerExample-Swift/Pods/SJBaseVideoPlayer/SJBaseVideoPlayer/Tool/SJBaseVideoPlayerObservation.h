//
//  SJBaseVideoPlayerObservation.h
//  Pods
//
//  Created by BlueDancer on 2019/8/27.
//

#import <Foundation/Foundation.h>
@class SJBaseVideoPlayer;

NS_ASSUME_NONNULL_BEGIN

@interface SJPlaybackObservation : NSObject
- (instancetype)initWithPlayer:(__kindof SJBaseVideoPlayer *)player;

@property (nonatomic, copy, nullable) void(^assetStatusDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^timeControlStatusDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^didPlayToEndTimeExeBlock)(__kindof SJBaseVideoPlayer *player);

@property (nonatomic, copy, nullable) void(^currentTimeDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^durationDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^playableDurationDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^presentationSizeDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^playbackTypeDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);

@property (nonatomic, copy, nullable) void(^lockedScreenDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^mutedDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^playerVolumeDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^rateDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);

@property (nonatomic, weak, readonly) __kindof SJBaseVideoPlayer *player;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
