//
//  SJItemTags.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2020/12/31.
//

#import "SJEdgeControlButtonItem.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - SJEdgeControlLayer

// top adapter items
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_Back;             // 返回按钮
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_Title;            // 标题
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_PictureInPicture API_AVAILABLE(ios(14.0)); // 画中画item
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_More;             // More


// left adapter items
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerLeftItem_Lock;            // 锁屏按钮

// right adapter items
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerRightItem_Clips;         // GIF/导出/截屏

// bottom adapter items
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Play;          // 播放按钮
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_CurrentTime;   // 当前时间
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_DurationTime;  // 全部时长
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Separator;     // 时间分隔符(斜杠/)
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Progress;      // 播放进度条
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Full;          // 全屏按钮
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_LIVEText;      // 实时直播
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Definition;    // 清晰度

// center adapter items
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerCenterItem_Replay;        // 重播按钮

NS_ASSUME_NONNULL_END
