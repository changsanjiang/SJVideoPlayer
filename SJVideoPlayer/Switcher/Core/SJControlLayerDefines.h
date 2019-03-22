//
//  SJControlLayerDefines.h
//  Pods
//
//  Created by 畅三江 on 2018/6/1.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#ifndef SJControlLayerDefines_h
#define SJControlLayerDefines_h
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJVideoPlayerControlLayerProtocol.h>
#else
#import "SJVideoPlayerControlLayerProtocol.h"
#endif
typedef long SJControlLayerIdentifier;
@protocol SJControlLayer;

NS_ASSUME_NONNULL_BEGIN
// - 启用控制层 -
// 切换器(switcher)切换控制层时, 该方法将会被调用
@protocol SJControlLayerRestartProtocol <NSObject>
@property (nonatomic, readonly) BOOL restarted; // 是否已重新启用
- (void)restartControlLayer;
@end

// - 退出控制层 -
// 切换器(switcher)切换控制层时, 该方法将会被调用
@protocol SJControlLayerExitProtocol <NSObject>
- (void)exitControlLayer;
@end

// - 控制层 -
@protocol SJControlLayer <
    SJVideoPlayerControlLayerDataSource,
    SJVideoPlayerControlLayerDelegate,
    SJControlLayerRestartProtocol,
    SJControlLayerExitProtocol
>
@end
NS_ASSUME_NONNULL_END

#endif /* SJControlLayerDefines_h */
