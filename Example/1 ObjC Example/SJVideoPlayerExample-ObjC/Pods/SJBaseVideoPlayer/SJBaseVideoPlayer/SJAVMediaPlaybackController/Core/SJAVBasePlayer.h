//
//  SJAVBasePlayer.h
//  SJUIKit
//
//  Created by BlueDancer on 2019/8/26.
//

#import <AVFoundation/AVFoundation.h>
#import "SJVideoPlayerPlaybackControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
extern SJWaitingReason const SJWaitingToMinimizeStallsReason;
extern SJWaitingReason const SJWaitingWhileEvaluatingBufferingRateReason;
extern SJWaitingReason const SJWaitingWithNoAssetToPlayReason;

@interface SJAVBasePlayer : AVPlayer

///
/// 初始化时, 请传入 playerItem. playerItem 不可为空!
///
- (instancetype)initWithPlayerItem:(nullable AVPlayerItem *)item;

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

- (void)sj_playImmediatelyAtRate:(float)rate;

- (instancetype)initWithURL:(NSURL *)URL NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
