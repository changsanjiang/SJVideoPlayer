//
//  SJVideoPlayerState.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#ifndef SJVideoPlayerState_h
#define SJVideoPlayerState_h

/**
 当前播放的状态

 - SJVideoPlayerPlayStatusUnknown:      未播放任何资源时的状态
 - SJVideoPlayerPlayStatusPrepare:      准备播放一个资源
 - SJVideoPlayerPlayStatusReadyToPlay:  准备就绪, 可以播放
 - SJVideoPlayerPlayStatusPlaying:      播放中
 - SJVideoPlayerPlayStatusPaused:       暂停状态, 请通过`SJVideoPlayerPausedReason`, 查看暂停原因
 - SJVideoPlayerPlayStatusInactivity:   不活跃状态, 请通过`SJVideoPlayerInactivityReason`, 查看暂停原因
 */
typedef NS_ENUM(NSUInteger, SJVideoPlayerPlayStatus) {
    SJVideoPlayerPlayStatusUnknown,
    SJVideoPlayerPlayStatusPrepare,
    SJVideoPlayerPlayStatusReadyToPlay,
    SJVideoPlayerPlayStatusPlaying,
    SJVideoPlayerPlayStatusPaused,
    SJVideoPlayerPlayStatusInactivity,
};

/**
 暂停的理由

 - SJVideoPlayerPausedReasonBuffering:   正在缓冲
 - SJVideoPlayerPausedReasonPause:       被暂停
 - SJVideoPlayerPausedReasonSeeking:     正在跳转(调用seekToTime:时)
 */
typedef NS_ENUM(NSUInteger, SJVideoPlayerPausedReason) {
    SJVideoPlayerPausedReasonBuffering,
    SJVideoPlayerPausedReasonPause,
    SJVideoPlayerPausedReasonSeeking,
};

/**
 不活跃的原因
 
 - SJVideoPlayerInactivityReasonPlayEnd:    播放完毕
 - SJVideoPlayerInactivityReasonPlayFailed: 播放失败
 */
typedef NS_ENUM(NSUInteger, SJVideoPlayerInactivityReason) {
    SJVideoPlayerInactivityReasonPlayEnd,
    SJVideoPlayerInactivityReasonPlayFailed,
};


typedef NS_ENUM(NSUInteger, SJVideoPlayerPlayState) {
    SJVideoPlayerPlayState_Unknown = 0,
    SJVideoPlayerPlayState_Prepare,
    SJVideoPlayerPlayState_Playing,
    SJVideoPlayerPlayState_Buffing,
    SJVideoPlayerPlayState_Paused,
    SJVideoPlayerPlayState_PlayEnd,
    SJVideoPlayerPlayState_PlayFailed,
} __deprecated_msg("已弃用, 请使用`SJVideoPlayerPlayStatus`");

#endif /* SJVideoPlayerState_h */
