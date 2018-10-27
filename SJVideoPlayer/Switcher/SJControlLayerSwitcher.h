//
//  SJControlLayerSwitcher.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/6/1.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJControlLayerCarrier.h"
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#else
#import "SJBaseVideoPlayer.h"
#endif

NS_ASSUME_NONNULL_BEGIN


/// 控制层切换器
/// 使用示例请查看`SJVideoPlayer`的`init`方法.
@interface SJControlLayerSwitcher : NSObject
- (instancetype)initWithPlayer:(__weak SJBaseVideoPlayer *)player;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) SJControlLayerIdentifier currentIdentifier;  // 当前标识(控制层的标识)
@property (nonatomic, readonly) SJControlLayerIdentifier previousIdentifier; // 前一个标识

/// 切换控制层
/// 将当前的控制层切换为指定标识的控制层
- (void)switchControlLayerForIdentitfier:(SJControlLayerIdentifier)identifier;
- (BOOL)switchToPreviousControlLayer; // 切换到之前的控制层
/// 添加或替换控制层
- (void)addControlLayer:(SJControlLayerCarrier *)carrier;
- (void)deleteControlLayerForIdentifier:(SJControlLayerIdentifier)identifier;
- (nullable SJControlLayerCarrier *)controlLayerForIdentifier:(SJControlLayerIdentifier)identifier;
@end




@interface SJControlLayerSwitcher (Deprecated)
- (void)switchControlLayerForIdentitfier:(SJControlLayerIdentifier)identifier
                           toVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer __deprecated_msg("use `switchControlLayerForIdentitfier`;");
@end
NS_ASSUME_NONNULL_END
