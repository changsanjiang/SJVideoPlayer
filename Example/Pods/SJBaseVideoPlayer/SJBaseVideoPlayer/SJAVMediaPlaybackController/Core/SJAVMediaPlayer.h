//
//  SJAVMediaPlayer.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/8/26.
//

#import <Foundation/Foundation.h>
#import "SJAVBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN
extern NSNotificationName const SJAVMediaPlayerAssetStatusDidChangeNotification;
extern NSNotificationName const SJAVMediaPlayerTimeControlStatusDidChangeNotification;
extern NSNotificationName const SJAVMediaPlayerDurationDidChangeNotification;
extern NSNotificationName const SJAVMediaPlayerPlayableDurationDidChangeNotification;
extern NSNotificationName const SJAVMediaPlayerPresentationSizeDidChangeNotification;
extern NSNotificationName const SJAVMediaPlayerPlaybackTypeDidChangeNotification;
extern NSNotificationName const SJAVMediaPlayerDidPlayToEndTimeNotification;

typedef struct {
    NSTimeInterval specifyStartTime;    ///< 初始化完成后, 跳转到指定的时间开始播放
    NSTimeInterval duration;            ///< 播放时长
    NSTimeInterval playableDuration;    ///< 已缓冲的时间
    NSTimeInterval minBufferedDuration; ///< 最小缓冲时长, 当达到最小缓冲时长后, 可能会尝试恢复播放
    CGSize presentationSize;
    SJPlaybackType playbackType;
    float rate;
    BOOL isPlayedToEndTime;             ///< 是否播放结束
    BOOL isReplayed;                    ///< 是否重播过
    BOOL isPlayed;                      ///< 是否调用过播放
} SJAVMediaPlayerPlaybackInfo;

@interface SJAVMediaPlayer : SJAVBasePlayer
- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime;
- (instancetype)initWithAVAsset:(__kindof AVAsset *)asset specifyStartTime:(NSTimeInterval)specifyStartTime;
- (instancetype)initWithPlayerItem:(SJAVBasePlayerItem *)item specifyStartTime:(NSTimeInterval)specifyStartTime;

@property (nonatomic, readonly) SJAVMediaPlayerPlaybackInfo sj_playbackInfo;

@property (nonatomic) NSTimeInterval sj_minBufferedDuration;
@property (nonatomic) float sj_rate;

- (void)replay;
- (void)report; ///< 反馈当前状态
@end
NS_ASSUME_NONNULL_END
