//
//  SJPlaybackRecordSaveHandler.h
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/2/20.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#if __has_include(<YYModel/YYModel.h>) || __has_include(<YYKit/YYKit.h>)

// 播放记录保存管理类

#import <Foundation/Foundation.h>
#import "SJPlaybackHistoryController.h"
typedef enum : NSUInteger {
    ///
    /// 播放器资源将要改变时
    ///
    SJPlayerEventURLAssetWillChange,
    ///
    /// 播放控制将要销毁前
    ///
    SJPlayerEventPlaybackControllerWillDeallocate,
    ///
    /// 播放器执行了暂停
    ///
    SJPlayerEventPlaybackDidPause,
    ///
    /// 播放器将要执行stop前
    ///
    SJPlayerEventPlaybackWillStop,
    ///
    /// 播放器将要执行refresh前
    ///
    SJPlayerEventPlaybackWillRefresh,
    
    
    ///
    /// 播放器接收到App进入后台时
    ///
    SJPlayerEventApplicationDidEnterBackground,
    ///
    /// 播放器接收到App将要销毁时
    ///
    SJPlayerEventApplicationWillTerminate,
} SJPlayerEvent;

typedef enum : NSUInteger {
    SJPlayerEventMaskURLAssetWillChange = 1 << SJPlayerEventURLAssetWillChange,
    
    SJPlayerEventMaskPlaybackControllerWillDeallocate = 1 << SJPlayerEventPlaybackControllerWillDeallocate,
    SJPlayerEventMaskPlaybackDidPause = 1 << SJPlayerEventPlaybackDidPause,
    SJPlayerEventMaskPlaybackWillStop = 1 << SJPlayerEventPlaybackWillStop,
    SJPlayerEventMaskPlaybackWillRefresh = 1 << SJPlayerEventPlaybackWillRefresh,
    
    SJPlayerEventMaskApplicationDidEnterBackground = 1 << SJPlayerEventApplicationDidEnterBackground,
    SJPlayerEventMaskApplicationWillTerminate = 1 << SJPlayerEventApplicationWillTerminate,
    
    SJPlayerEventMaskPlaybackEvents = SJPlayerEventMaskPlaybackControllerWillDeallocate | SJPlayerEventMaskPlaybackWillStop | SJPlayerEventMaskPlaybackWillRefresh | SJPlayerEventMaskPlaybackDidPause,
    
    SJPlayerEventMaskApplicationEvents = SJPlayerEventMaskApplicationDidEnterBackground | SJPlayerEventMaskApplicationWillTerminate,
    
    SJPlayerEventMaskAll = (SJPlayerEventMaskURLAssetWillChange | SJPlayerEventMaskPlaybackEvents | SJPlayerEventMaskApplicationEvents),
} SJPlayerEventMask;
 
NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerURLAsset (SJPlaybackRecordSaveHandlerExtended)
@property (nonatomic, strong, nullable) SJPlaybackRecord *record;
@end


@interface SJPlaybackRecordSaveHandler : NSObject
+ (instancetype)shared;
- (instancetype)initWithEvents:(SJPlayerEventMask)events playbackHistoryController:(id<SJPlaybackHistoryController>)controller;

/// 设置保存的时机(当发生某个事件之后, handler内部会自动保存播放记录)
@property (nonatomic) SJPlayerEventMask events;
@end


@interface SJPlayerEventObserver : NSObject
- (instancetype)initWithEvents:(SJPlayerEventMask)events handler:(void(^)(id target, SJPlayerEvent event))block;
@property (nonatomic) SJPlayerEventMask events;
@end
NS_ASSUME_NONNULL_END

#endif
