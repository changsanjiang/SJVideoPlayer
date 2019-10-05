//
//  SJVideoPlayerPlayStatusDefines.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/11/29.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#ifndef SJVideoPlayerPlayStatusDefines_h
#define SJVideoPlayerPlayStatusDefines_h
@class SJBaseVideoPlayer;

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    SJPlaybackTypeUnknown,
    SJPlaybackTypeLIVE,
    SJPlaybackTypeVOD,
    SJPlaybackTypeFILE
} SJPlaybackType;

typedef NS_ENUM(NSInteger, SJAssetStatus) {
    ///
    /// 未知状态
    ///
    SJAssetStatusUnknown,
    
    ///
    /// 准备中
    ///
    SJAssetStatusPreparing,
    
    ///
    /// 当前资源可随时进行播放(播放控制请查看`timeControlStatus`)
    ///
    SJAssetStatusReadyToPlay,
    
    ///
    /// 发生错误
    ///
    SJAssetStatusFailed
};

typedef NS_ENUM(NSInteger, SJPlaybackTimeControlStatus) {
    ///
    /// 暂停状态(已调用暂停或未执行任何操作的状态)
    ///
    SJPlaybackTimeControlStatusPaused,
    
    ///
    /// 播放状态(已调用播放), 当前正在缓冲或正在评估能否播放. 可以通过`reasonForWaitingToPlay`来获取原因, UI层可以根据原因来控制loading视图的状态.
    ///
    SJPlaybackTimeControlStatusWaitingToPlay,
    
    ///
    /// 播放状态(已调用播放), 当前播放器正在播放
    ///
    SJPlaybackTimeControlStatusPlaying
};


typedef NSString *SJWaitingReason;

///
/// 缓冲中, UI层建议显示loading视图 
///
extern SJWaitingReason const SJWaitingToMinimizeStallsReason;

///
/// 正在评估能否播放, 处于此状态时, 不建议UI层显示loading视图
///
extern SJWaitingReason const SJWaitingWhileEvaluatingBufferingRateReason;

///
/// 未设置资源
///
extern SJWaitingReason const SJWaitingWithNoAssetToPlayReason;




///
/// 清晰度的切换状态
///
typedef NS_ENUM(NSInteger, SJDefinitionSwitchStatus) {
    SJDefinitionSwitchStatusUnknown,
    SJDefinitionSwitchStatusSwitching,
    SJDefinitionSwitchStatusFinished,
    SJDefinitionSwitchStatusFailed,
};
NS_ASSUME_NONNULL_END
#endif /* SJVideoPlayerPlayStatusDefines_h */
