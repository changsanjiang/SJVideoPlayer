//
//  SJPlaybackRecordSaveHandler.h
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/2/20.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#if __has_include(<YYModel/YYModel.h>) || __has_include(<YYKit/YYKit.h>)

#import <Foundation/Foundation.h>
#import "SJPlaybackHistoryController.h"
typedef enum : NSUInteger {
    /// 播放器暂停时保存
    SJPlaybackRecordSaveTimeMaskPlayerPaused                            = 1 << 0,
    /// 播放器资源将要改变时保存
    SJPlaybackRecordSaveTimeMaskPlayerURLAssetWillChange                = 1 << 1,
    /// 播放控制将要销毁前保存
    SJPlaybackRecordSaveTimeMaskPlayerPlaybackControllerWillDeallocate  = 1 << 2,
    /// 播放器将要执行stop前保存
    SJPlaybackRecordSaveTimeMaskPlayerPlaybackWillStop                  = 1 << 3,

    /// 播放器接收到App进入后台时保存
    SJPlaybackRecordSaveTimeMaskApplicationDidEnterBackground           = 1 << 5,
    /// 播放器接收到App将要销毁时保存
    SJPlaybackRecordSaveTimeMaskApplicationWillTerminate                = 1 << 6,
    
    SJPlaybackRecordSaveTimeMaskAll = (SJPlaybackRecordSaveTimeMaskPlayerPaused | SJPlaybackRecordSaveTimeMaskPlayerURLAssetWillChange | SJPlaybackRecordSaveTimeMaskPlayerPlaybackControllerWillDeallocate | SJPlaybackRecordSaveTimeMaskPlayerPlaybackWillStop | SJPlaybackRecordSaveTimeMaskApplicationDidEnterBackground | SJPlaybackRecordSaveTimeMaskApplicationWillTerminate),
} SJPlaybackRecordSaveTimeMask;

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerURLAsset (SJPlaybackRecordSaveHandlerExtended)
@property (nonatomic, strong, nullable) SJPlaybackRecord *record;
@end

@interface SJPlaybackRecordSaveHandler : NSObject
+ (instancetype)shared;
- (instancetype)initWithSaveTimes:(SJPlaybackRecordSaveTimeMask)times playbackHistoryController:(id<SJPlaybackHistoryController>)controller;

/// 保存的时机
@property (nonatomic) SJPlaybackRecordSaveTimeMask times;
@end
NS_ASSUME_NONNULL_END

#endif
