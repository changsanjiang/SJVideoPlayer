//
//  SJPlaybackObservation.h
//  Pods
//
//  Created by 畅三江 on 2019/8/27.
//

#import <Foundation/Foundation.h>
@class SJBaseVideoPlayer;

NS_ASSUME_NONNULL_BEGIN

@interface SJPlaybackObservation : NSObject
- (instancetype)initWithPlayer:(__kindof SJBaseVideoPlayer *)player;

///
/// 播放状态改变后的回调
///
///     以下状态发生变更时将会触发该回调
///     1.  timeControlStatus(播放控制改变的时候)
///     2.  assetStatus(资源状态改变的时候)
///     3.  didPlayToEndTime(播放完毕的时候)
///
///     该block相当于集合了`assetStatusDidChangeExeBlock`&`timeControlStatusDidChangeExeBlock`&`didPlayToEndTimeExeBlock`的回调.
///
@property (nonatomic, copy, nullable) void(^playbackStatusDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);

/// 推荐使用`playbackStatusDidChangeExeBlock`
@property (nonatomic, copy, nullable) void(^assetStatusDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
/// 推荐使用`playbackStatusDidChangeExeBlock`
@property (nonatomic, copy, nullable) void(^timeControlStatusDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
/// 推荐使用`playbackStatusDidChangeExeBlock`
@property (nonatomic, copy, nullable) void(^didPlayToEndTimeExeBlock)(__kindof SJBaseVideoPlayer *player);

@property (nonatomic, copy, nullable) void(^definitionSwitchStatusDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);

@property (nonatomic, copy, nullable) void(^currentTimeDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^durationDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^playableDurationDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^presentationSizeDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^playbackTypeDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);

@property (nonatomic, copy, nullable) void(^lockedScreenDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^mutedDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^playerVolumeDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^rateDidChangeExeBlock)(__kindof SJBaseVideoPlayer *player);

@property (nonatomic, weak, readonly, nullable) __kindof SJBaseVideoPlayer *player;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
