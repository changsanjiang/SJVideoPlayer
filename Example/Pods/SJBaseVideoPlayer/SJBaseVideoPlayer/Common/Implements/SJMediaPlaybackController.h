//
//  SJMediaPlaybackController.h
//  Pods
//
//  Created by 畅三江 on 2020/2/17.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerPlaybackControllerDefines.h"
#import "SJVideoPlayerURLAsset.h"
@protocol SJMediaPlayer, SJMediaPlayerView;

NS_ASSUME_NONNULL_BEGIN
@interface SJMediaPlaybackController : NSObject<SJVideoPlayerPlaybackController>
@property (nonatomic, strong, nullable) SJVideoPlayerURLAsset *media;
///
/// 当前的播放器
///
@property (nonatomic, strong, readonly, nullable) id<SJMediaPlayer> currentPlayer;
@property (nonatomic, strong, readonly, nullable) __kindof UIView<SJMediaPlayerView> *currentPlayerView;

///
/// 子类返回
///
///     第三方播放器需实现`<SJMediaPlayer>`协议
///
- (void)playerWithMedia:(SJVideoPlayerURLAsset *)media completionHandler:(void(^)(id<SJMediaPlayer> _Nullable player))completionHandler;

///
/// 子类返回
///
- (UIView<SJMediaPlayerView> *)playerViewWithPlayer:(id<SJMediaPlayer>)player;

///
/// 以下方法在接收到通知后执行
///
- (void)receivedApplicationDidBecomeActiveNotification;
- (void)receivedApplicationWillResignActiveNotification;
- (void)receivedApplicationWillEnterForegroundNotification;
- (void)receivedApplicationDidEnterBackgroundNotification;
@end

///
/// 当播放器状态改变时, 需发送相应的通知
///
/// player
extern NSNotificationName const SJMediaPlayerAssetStatusDidChangeNotification;
extern NSNotificationName const SJMediaPlayerTimeControlStatusDidChangeNotification;
extern NSNotificationName const SJMediaPlayerPresentationSizeDidChangeNotification;
extern NSNotificationName const SJMediaPlayerPlaybackDidFinishNotification;
extern NSNotificationName const SJMediaPlayerDidReplayNotification;
extern NSNotificationName const SJMediaPlayerDurationDidChangeNotification;
extern NSNotificationName const SJMediaPlayerPlayableDurationDidChangeNotification;

/// view
extern NSNotificationName const SJMediaPlayerViewReadyForDisplayNotification;

@protocol SJMediaPlayerView <NSObject>
@property (nonatomic) SJVideoGravity videoGravity;
@property (nonatomic, readonly, getter=isReadyForDisplay) BOOL readyForDisplay;
@end

@protocol SJMediaPlayer <NSObject>
@property (nonatomic, readonly, nullable) SJWaitingReason reasonForWaitingToPlay;
@property (nonatomic, readonly) SJPlaybackTimeControlStatus timeControlStatus;
@property (nonatomic, readonly) SJAssetStatus assetStatus;
@property (nonatomic, readonly) SJSeekingInfo seekingInfo;
@property (nonatomic, readonly) CGSize presentationSize;
@property (nonatomic, readonly) BOOL isReplayed; ///< 是否调用过`replay`方法
@property (nonatomic, readonly) BOOL isPlayed; ///< 是否调用过`play`方法
@property (nonatomic, readonly) BOOL isPlaybackFinished;                        ///< 播放结束
@property (nonatomic, readonly, nullable) SJFinishedReason finishedReason;      ///< 播放结束的reason
@property (nonatomic) NSTimeInterval trialEndPosition;                          ///< 试用结束的位置, 单位秒
@property (nonatomic) float rate;
@property (nonatomic) float volume;
@property (nonatomic, getter=isMuted) BOOL muted;

- (void)seekToTime:(CMTime)time completionHandler:(nullable void (^)(BOOL finished))completionHandler;

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;    
@property (nonatomic, readonly) NSTimeInterval playableDuration;

- (void)play;
- (void)pause;

- (void)replay;
- (void)report;

- (nullable UIImage *)screenshot;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

/// 这个通知是可选的(如果可以获取到playbacType, 请发送该通知)
extern NSNotificationName const SJMediaPlayerPlaybackTypeDidChangeNotification;


@interface SJMediaPlaybackController (SJSwitchDefinitionExtended)
///
/// 该方法通知子类, 切换清晰度即将完成, 将要设置media为新的清晰度资源
///
///         子类可根据自己需求决定是否重写该方法用于清理旧的资源
///
- (void)replaceMediaForDefinitionMedia:(SJVideoPlayerURLAsset *)definitionMedia NS_REQUIRES_SUPER;
@end
NS_ASSUME_NONNULL_END
