//
//  SJControlLayerIdentifiers.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2020/12/31.
//

#import "SJControlLayerDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// 以下标识是默认存在的控制层标识
/// - 可以像下面这样扩展您的标识, 将相应的控制层加入到switcher(切换器)中, 通过switcher进行切换.
/// - SJControlLayerIdentifier YourControlLayerIdentifier;
/// - 当然, 也可以直接将已存在控制层, 替换成您的控制层.
extern SJControlLayerIdentifier const SJControlLayer_Edge;                              ///< 默认的边缘控制层
extern SJControlLayerIdentifier const SJControlLayer_Clips;                             ///< 默认的剪辑层
extern SJControlLayerIdentifier const SJControlLayer_More;                              ///< 默认的更多设置控制层
extern SJControlLayerIdentifier const SJControlLayer_LoadFailed;                        ///< 默认加载失败时显示的控制层
extern SJControlLayerIdentifier const SJControlLayer_NotReachableAndPlaybackStalled;    ///< 默认加载失败时显示的控制层
extern SJControlLayerIdentifier const SJControlLayer_FloatSmallView;                    ///< 默认的小浮窗控制层
extern SJControlLayerIdentifier const SJControlLayer_SwitchVideoDefinition;             ///< 默认的切换视频清晰度控制层

NS_ASSUME_NONNULL_END
