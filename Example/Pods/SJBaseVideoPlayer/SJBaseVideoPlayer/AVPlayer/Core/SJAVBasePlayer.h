//
//  SJAVBasePlayer.h
//  SJUIKit
//
//  Created by 畅三江 on 2019/8/26.
//

#import <AVFoundation/AVFoundation.h>
#import "SJVideoPlayerPlaybackControllerDefines.h"
#import "SJAVBasePlayerItem.h"

NS_ASSUME_NONNULL_BEGIN
extern SJWaitingReason const SJWaitingToMinimizeStallsReason;
extern SJWaitingReason const SJWaitingWhileEvaluatingBufferingRateReason;
extern SJWaitingReason const SJWaitingWithNoAssetToPlayReason;

@interface SJAVBasePlayer : AVPlayer
///
/// 初始化时, 请传入 playerItem. 不可为空!
///
- (nullable instancetype)initWithBasePlayerItem:(SJAVBasePlayerItem *)item;

/// - Note: you should recreate new player when an error occurs
///
/// - 注意: 当前为错误状态时, 你应该重新创建一个播放器实例!
///
/// - 同步 AVPlayer.status && AVPlayerItem.status
/// - 同步 AVPlayerItem.status == faield 的状态, 此状态将同步为 .failed 的状态
/// - 同步 AVPlayerItemFailedToPlayToEndTime 的通知, 此状态将同步为 .failed 的状态
/// - 发生错误时, 通过 sj_error 查看错误信息.
/// - 当错误发生后, 请重新创建播放器进行播放.
///
/// You can observe this change using key-value observing.
///
@property (nonatomic, readonly) SJAssetStatus sj_assetStatus;

///
/// - 同步 AVPlayer.timeControlStatus(>=10.0之后引入的)
/// - 同步 版本 < 10.0 的系统, 也就是 < 10.0 的也可通过此获取状态
///
///
/// You can observe this change using key-value observing.
///
@property (nonatomic, readonly) SJPlaybackTimeControlStatus sj_timeControlStatus;
@property (nonatomic, readonly, nullable) SJWaitingReason sj_reasonForWaitingToPlay;

///
/// - 同步 AVPlayer.error
/// - 同步 AVPlayerItem.error
/// - 同步 AVPlayerItemFailedToPlayToEndTime.error
///
@property (nonatomic, strong, readonly, nullable) NSError *sj_error;

@property (nonatomic, readonly) SJSeekingInfo seekingInfo;

- (void)sj_playImmediatelyAtRate:(float)rate;

///
/// 该观察者可以不移除, 当播放器销毁时, 内部将自动移除
///
- (id)addPeriodicTimeObserverForInterval:(CMTime)interval queue:(nullable dispatch_queue_t)queue usingBlock:(void (^)(CMTime))block;

///
/// 主动移除
///
- (void)removeTimeObserver:(id)observer;

+ (instancetype)playerWithURL:(NSURL *)URL NS_UNAVAILABLE;
+ (instancetype)playerWithPlayerItem:(nullable AVPlayerItem *)item NS_UNAVAILABLE;
- (instancetype)initWithPlayerItem:(nullable AVPlayerItem *)item NS_UNAVAILABLE;
- (instancetype)initWithURL:(NSURL *)URL NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context NS_REQUIRES_SUPER;
@end
NS_ASSUME_NONNULL_END
