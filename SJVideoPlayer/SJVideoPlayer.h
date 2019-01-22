//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#else
#import "SJBaseVideoPlayer.h"
#endif
#import "SJVideoPlayerSettings.h"
#import "SJVideoPlayerMoreSetting.h"
#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import "SJVideoPlayerMoreSettingSecondary.h"
#import "SJFilmEditingResultShareItem.h"
#import "SJLightweightTopItem.h"
#import "SJVideoPlayerFilmEditingCommonHeader.h"
#import "SJVideoPlayerFilmEditingConfig.h"
#import "SJControlLayerSwitcher.h"
#import "SJEdgeControlButtonItem.h"
#import "SJEdgeControlLayer.h"
#import "SJFilmEditingControlLayer.h"
#import "SJEdgeLightweightControlLayer.h"
#import "SJMoreSettingControlLayer.h"
#import "SJLoadFailedControlLayer.h"
#import "SJNotReachableControlLayer.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayer : SJBaseVideoPlayer

/// 使用默认的控制层
+ (instancetype)player;

/// A lightweight player with simple functions.
/// 一个具有简单功能的播放器.
+ (instancetype)lightweightPlayer;

/// Use default control layer.
/// 使用默认的控制层
- (instancetype)init;

/// v2.0.8
/// 新增: 控制层 切换器, 管理控制层的切换
@property (nonatomic, strong, readonly) SJControlLayerSwitcher *switcher;

+ (NSString *)version;
- (instancetype)_init;

- (nullable SJEdgeControlLayer *)defaultEdgeControlLayer;
- (nullable SJFilmEditingControlLayer *)defaultFilmEditingControlLayer;
- (nullable SJEdgeLightweightControlLayer *)defaultEdgeLightweightControlLayer;
- (nullable SJMoreSettingControlLayer *)defaultMoreSettingControlLayer;

- (nullable SJLoadFailedControlLayer *)defaultLoadFailedControlLayer;
- (nullable SJNotReachableControlLayer *)defaultNotReachableControlLayer;
@end


@interface SJVideoPlayer (CommonSettings)
/// 配置`播放器图片或slider的颜色等`
/// Configure the player, Note: This `block` is run on the child thread.
/// 配置播放器, 例如: 滚动条的颜色等... 注意: 这个`block`在子线程运行
///
/// SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {
///     ..... setting player ......
///     commonSettings.placeholder = [UIImage imageNamed:@"placeholder"];
///     commonSettings.more_trackColor = [UIColor whiteColor];
///     commonSettings.progress_trackColor = [UIColor colorWithWhite:0.4 alpha:1];
///     commonSettings.progress_bufferColor = [UIColor whiteColor];
/// });
@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(SJVideoPlayerSettings *commonSettings));
+ (void)resetSetting; // 重置配置, 恢复默认设置

/// This block invoked when clicked back btn, if videoPlayer.isFullscreen == NO.
/// 点击`返回`按钮的回调
@property (nonatomic, copy, null_resettable) void(^clickedBackEvent)(SJVideoPlayer *player);

/// 当播放器为竖屏时, 是否隐藏返回按钮
/// v2.1.4 新增
@property (nonatomic) BOOL hideBackButtonWhenOrientationIsPortrait;

/// Default value is NO.
/// 是否禁止网络状态变化时的提示
@property (nonatomic) BOOL disablePromptWhenNetworkStatusChanges;

@end


/// 配置`轻量级的控制层`
@interface SJVideoPlayer (SettingLightweightControlLayer)

/// 配置top控制层上的item
@property (nonatomic, copy, nullable) NSArray<SJLightweightTopItem *> *topControlItems;

/// 点击item执行的block
@property (nonatomic, copy, nullable) void(^clickedTopControlItemExeBlock)(SJVideoPlayer *player, SJLightweightTopItem *item);

@end


/// 配置`默认的控制层`
@interface SJVideoPlayer (SettingDefaultControlLayer)

/// Whether to generate a preview view. default is YES.
/// 是否自动生成预览视图, 默认是 YES.
@property (nonatomic) BOOL generatePreviewImages;

/// Default control layer show `more item`.
/// 默认控制层中`Top层`显示更多按钮
/// Default is YES.
@property (nonatomic) BOOL showMoreItemForTopControlLayer;

/// clicked More button to display items.
/// 点击`更多(右上角的三个点)`按钮, 弹出来的选项.
@property (nonatomic, strong, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

@end


/// 配置`剪辑的控制层`
/// 以下为控制层items的扩展tag
@interface SJVideoPlayer (FilmEditing)
/// The player will display the right control view if YES
/// If the format of the video is m3u8, it does not work
/// Default value is NO.
/// 是否开启剪辑功能
/// 默认是NO
/// 不支持剪辑m3u8(如果开启, 将会自动隐藏剪辑按钮)
@property (nonatomic) BOOL enableFilmEditing;

/// 剪辑功能配置
@property (nonatomic, strong, readonly) SJVideoPlayerFilmEditingConfig *filmEditingConfig;

/// 退出剪辑层
- (void)dismissFilmEditingViewCompletion:(void(^__nullable)(SJVideoPlayer *player))completionBlock;
@end



/// 控制层切换器扩展(切换控制层)
@interface SJVideoPlayer(SwitcherExtension)
/// 切换控制层
- (void)switchControlLayerForIdentitfier:(SJControlLayerIdentifier)identifier;
@end


/// 以下标识是默认存在的控制层标识
/// - 可以像下面这样扩展您的标识, 将相应的控制层加入到switcher(切换器)中, 通过switcher进行切换.
/// - SJControlLayerIdentifier YourControlLayerIdentifier;
/// - 当然, 也可以直接将已存在控制层, 替换成您的控制层.
extern SJControlLayerIdentifier const SJControlLayer_Edge;            // 默认的边缘控制层
extern SJControlLayerIdentifier const SJControlLayer_FilmEditing;     // 默认的剪辑层
extern SJControlLayerIdentifier const SJControlLayer_MoreSettting;    // 默认的更多设置控制层
extern SJControlLayerIdentifier const SJControlLayer_LoadFailed;      // 默认加载失败时显示的控制层
extern SJControlLayerIdentifier const SJControlLayer_NotReachableAndPlaybackStalled;    // 默认加载失败时显示的控制层

extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_FilmEditing;   // GIF/导出/截屏
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_More;             // More



@interface SJVideoPlayer (SJVideoPlayerDeprecated)
@property (nonatomic) BOOL disableNetworkStatusChangePrompt __deprecated_msg("use `disablePromptWhenNetworkStatusChanges`");
@end
NS_ASSUME_NONNULL_END
