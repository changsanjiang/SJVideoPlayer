//
//  SJVideoPlayerStringConstant.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/23.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>


/// 锁定
extern NSNotificationName const SJPlayerLockedScreenNotification;

/// 解锁
extern NSNotificationName const SJPlayerUnlockedScreenNotification;

/// 全屏
extern NSNotificationName const SJPlayerFullScreenNotitication;

/// 小屏
extern NSNotificationName const SJPlayerSmallScreenNotification;

/// 准备播放
extern NSNotificationName const SJPlayerPrepareToPlayNotification;

/// 开始播放
extern NSNotificationName const SJPlayerBeginPlayingNotification;

/// 播放完成
extern NSNotificationName const SJPlayerDidPlayToEndTimeNotification;

/// 播放Error
extern NSNotificationName const SJPlayerPlayFailedErrorNotification;

/// 配置播放器
extern NSNotificationName const SJSettingsPlayerNotification;

/// 配置更多
extern NSNotificationName const SJMoreSettingsNotification;

/// 拖拽完调速Slider后的通知
extern NSNotificationName const SJPlayerRateSliderDidEndDraggingNotification;

/// 滑入
extern NSNotificationName const SJPlayerScrollInNotification;

/// 滑出
extern NSNotificationName const SJPlayerScrollOutNotification;
