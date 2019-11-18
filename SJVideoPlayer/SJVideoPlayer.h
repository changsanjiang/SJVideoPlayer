//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//
//  GitHub:     https://github.com/changsanjiang/SJBaseVideoPlayer
//  GitHub:     https://github.com/changsanjiang/SJVideoPlayer
//
//  Email:      changsanjiang@gmail.com
//  QQGroup:    930508201
//

#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#else
#import "SJBaseVideoPlayer.h"
#endif
#import "SJVideoPlayerSettings.h"
#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import "SJVideoPlayerFilmEditingCommonHeader.h"
#import "SJVideoPlayerFilmEditingConfig.h"
#import "SJControlLayerSwitcher.h"

#import "SJEdgeControlLayer.h"
#import "SJFilmEditingControlLayer.h"
#import "SJMoreSettingControlLayer.h"
#import "SJLoadFailedControlLayer.h"
#import "SJNotReachableControlLayer.h"
#import "SJFloatSmallViewControlLayer.h"
#import "SJSwitchVideoDefinitionControlLayer.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayer : SJBaseVideoPlayer

///
/// 使用默认的控制层
///
+ (instancetype)player;

///
/// A lightweight player with simple functions.
///
/// 一个具有简单功能的播放器.
///
+ (instancetype)lightweightPlayer;

- (instancetype)init;

///
/// v2.0.8
///
/// 新增: 控制层 切换器, 管理控制层的切换
///
@property (nonatomic, strong, readonly) SJControlLayerSwitcher *switcher;

// - 以下为各种状态下的播放器控制层, 均为懒加载 -

///
/// 默认的边缘控制层
///
///         当需要在竖屏隐藏返回按钮时, 可以设置`player.defaultEdgeControlLayer.hiddenBackButtonWhenOrientationIsPortrait = YES`
///         更多配置, 请前往该控制层头文件查看
///
@property (nonatomic, strong, readonly) SJEdgeControlLayer *defaultEdgeControlLayer;

///
/// 默认的无网状态下显示的控制层
///
@property (nonatomic, strong, readonly) SJNotReachableControlLayer *defaultNotReachableControlLayer;

///
/// 默认的剪辑(GIF, Export, Screenshot)控制层
///
@property (nonatomic, strong, readonly) SJFilmEditingControlLayer *defaultFilmEditingControlLayer;

///
/// 默认的`more setting`控制层(调整音量/亮度/速率)
///
@property (nonatomic, strong, readonly) SJMoreSettingControlLayer *defaultMoreSettingControlLayer;

///
/// 默认的加载失败或播放出错时显示的控制层
///
@property (nonatomic, strong, readonly) SJLoadFailedControlLayer *defaultLoadFailedControlLayer;

///
/// 默认的小浮窗模式下的控制层
///
@property (nonatomic, strong, readonly) SJFloatSmallViewControlLayer *defaultFloatSmallViewControlLayer;

///
/// 默认的切换清晰度时的控制层
///
@property (nonatomic, strong, readonly) SJSwitchVideoDefinitionControlLayer *defaultSwitchVideoDefinitionControlLayer;


- (instancetype)_init;
+ (NSString *)version;
@end


@interface SJVideoPlayer (CommonSettings)

///
/// 配置`播放器图片或slider的颜色等`
/// Configure the player, Note: This `block` is run on the child thread.
/// 配置播放器, 例如: 滚动条的颜色等... 注意: 这个`block`在子线程运行
///
/// \code
///
///     SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {
///         commonSettings.placeholder = [UIImage imageNamed:@"placeholder"];
///         commonSettings.more_trackColor = [UIColor whiteColor];
///         commonSettings.progress_trackColor = [UIColor colorWithWhite:0.4 alpha:1];
///         commonSettings.progress_bufferColor = [UIColor whiteColor];
///     });
///
/// \endcode
///
@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(SJVideoPlayerSettings *commonSettings));
+ (void)resetSetting; // 重置配置, 恢复默认设置
@end


@interface SJVideoPlayer (SJExtendedSwitchVideoDefinitionControlLayer)

///
/// 切换清晰度
///
/// \code
///
///     SJVideoPlayerURLAsset *asset1 = [[SJVideoPlayerURLAsset alloc] initWithURL:VideoURL_Level4];
///     asset1.definition_fullName = @"超清 1080P";
///     asset1.definition_lastName = @"超清";
///
///     SJVideoPlayerURLAsset *asset2 = [[SJVideoPlayerURLAsset alloc] initWithURL:VideoURL_Level3];
///     asset2.definition_fullName = @"高清 720P";
///     asset2.definition_lastName = @"AAAAAAA";
///
///     SJVideoPlayerURLAsset *asset3 = [[SJVideoPlayerURLAsset alloc] initWithURL:VideoURL_Level2];
///     asset3.definition_fullName = @"清晰 480P";
///     asset3.definition_lastName = @"480P";
///
///     // 1. 配置清晰度资源
///     _player.definitionURLAssets = @[asset1, asset2, asset3];
///
///     // 2. 先播放asset1 (asset2 和 asset3 将会在用户选择后进行切换)
///     _player.URLAsset = asset1;
///
/// \endcode
///
@property (nonatomic, copy, nullable) NSArray<SJVideoPlayerURLAsset *> *definitionURLAssets;

@end


@interface SJVideoPlayer (SJExtendedEdgeControlLayer)

///
/// 是否在默认控制层的Top栏上显示`more item`(三个点). default value is YES
///
@property (nonatomic) BOOL showMoreItemToTopControlLayer;

@end


@interface SJVideoPlayer (SJExtendedFilmEditingControlLayer)

///
/// 是否开启剪辑功能
///         - 默认是NO
///         - 不支持剪辑m3u8(如果开启, 将会自动隐藏剪辑按钮)
///
@property (nonatomic, getter=isEnabledFilmEditing) BOOL enabledFilmEditing;

///
/// 剪辑功能配置
///
@property (nonatomic, strong, readonly) SJVideoPlayerFilmEditingConfig *filmEditingConfig;
@end


@interface SJVideoPlayer (SJExtendedControlLayerSwitcher)

///
/// 切换控制层
///
- (void)switchControlLayerForIdentitfier:(SJControlLayerIdentifier)identifier;
@end


// - control layer -

/// 以下标识是默认存在的控制层标识
/// - 可以像下面这样扩展您的标识, 将相应的控制层加入到switcher(切换器)中, 通过switcher进行切换.
/// - SJControlLayerIdentifier YourControlLayerIdentifier;
/// - 当然, 也可以直接将已存在控制层, 替换成您的控制层.
extern SJControlLayerIdentifier const SJControlLayer_Edge;            ///< 默认的边缘控制层
extern SJControlLayerIdentifier const SJControlLayer_FilmEditing;     ///< 默认的剪辑层
extern SJControlLayerIdentifier const SJControlLayer_MoreSettting;    ///< 默认的更多设置控制层
extern SJControlLayerIdentifier const SJControlLayer_LoadFailed;      ///< 默认加载失败时显示的控制层
extern SJControlLayerIdentifier const SJControlLayer_NotReachableAndPlaybackStalled;    ///< 默认加载失败时显示的控制层
extern SJControlLayerIdentifier const SJControlLayer_FloatSmallView;  ///< 默认的小浮窗控制层
extern SJControlLayerIdentifier const SJControlLayer_SwitchVideoDefinition; ///< 默认的切换视频清晰度控制层

// - edge button item -

extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_FilmEditing;   ///< GIF/导出/截屏
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerTopItem_More;             ///< More
extern SJEdgeControlButtonItemTag const SJEdgeControlLayerBottomItem_Definition;    ///< 清晰度
NS_ASSUME_NONNULL_END
