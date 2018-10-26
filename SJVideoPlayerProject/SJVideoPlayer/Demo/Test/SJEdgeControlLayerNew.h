//
//  SJEdgeControlLayerNew.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/24.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#if __has_include(<SJBaseVideoPlayer/SJVideoPlayerControlLayerProtocol.h>)
#import <SJBaseVideoPlayer/SJVideoPlayerControlLayerProtocol.h>
#else
#import "SJVideoPlayerControlLayerProtocol.h"
#endif

NS_ASSUME_NONNULL_BEGIN
#pragma mark - Top
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_Back;             // 返回按钮
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_Title;            // 标题
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_Preview;          // 预览按钮

#pragma mark - Left
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerLeftItem_Lock;            // 锁屏按钮

#pragma mark - bottom
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Play;          // 播放按钮
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_CurrentTime;   // 当前时间
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_DurationTime;  // 全部时长
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Separator;     // 时间分隔符(斜杠/)
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Slider;        // 播放进度条
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_FullBtn;       // 全屏按钮


@interface SJEdgeControlLayerNew : SJEdgeControlLayerAdapters<SJVideoPlayerControlLayerDelegate, SJVideoPlayerControlLayerDataSource>
- (void)restartControlLayerCompeletionHandler:(nullable void(^)(void))compeletionHandler;
- (void)exitControlLayerCompeletionHandler:(nullable void(^)(void))compeletionHandler;

@property (nonatomic, copy, nullable) void(^clickedBackItemExeBlock)(SJEdgeControlLayerNew *control);
@property (nonatomic) BOOL hideBackButtonWhenOrientationIsPortrait;
@property (nonatomic) BOOL disablePromptWhenNetworkStatusChanges;
@property (nonatomic) BOOL generatePreviewImages;
@end
NS_ASSUME_NONNULL_END
