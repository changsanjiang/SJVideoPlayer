//
//  SJControlLayerSwitcher.h
//  SJVideoPlayerV3Project
//
//  Created by 畅三江 on 2018/6/1.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJControlLayerCarrier.h"
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <SJEdgeControlLayer/SJEdgeControlLayer.h>
#import <SJFilmEditingControlLayer/SJFilmEditingControlLayer.h>

NS_ASSUME_NONNULL_BEGIN
@class SJBaseVideoPlayer;

extern SJControlLayerIdentifier SJControlLayer_Uninitialized;
extern SJControlLayerIdentifier SJControlLayer_Edge;
extern SJControlLayerIdentifier SJControlLayer_FilmEditing;

/**
 切换器示例:
 切换到GIF控制层,  就设置 baseVideoPlayer.delegate 和 dataSource = GIF控制层
 切换到导出视频的控制层, 就设置 baseVideoPlayer.delegate 和 dataSource = 导出视频控制层
 
 思路:
 1. 当某个`控制层`不在使用, 退出时, 该`控制层`告诉`切换器`需要切换别的控制层了
 2. `切换器`负责切换控制层
 注册方式:
    2.1 通过标识符, 注册一个控制层
    2.1 由标识符获取控制层
 
 3. 拿到控制层后, 设置这个控制层为`base播放器`的delegate和dataSource
 
 切换器关键可以无缝接入别的开发者的控制层
 */
@interface SJControlLayerSwitcher : NSObject

- (instancetype)init;

@property (nonatomic, readonly) SJControlLayerIdentifier currentIdentifier; // 当前控制层的标识

@property (nonatomic, readonly) SJControlLayerIdentifier previousIdentifier; // 前一个标识


/// 切换控制层
/// 将当前的控制层切换为指定标识的控制层
- (void)switchControlLayerForIdentitfier:(SJControlLayerIdentifier)identifier toVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;

/// 添加一个备选的控制层
/// 也可替换, 只要将identifier设置为想要替换的控制层即可
- (void)addControlLayer:(SJControlLayerCarrier *)carrier;

- (void)deleteControlLayerForIdentifier:(SJControlLayerIdentifier)identifier;

- (nullable SJControlLayerCarrier *)controlLayerForIdentifier:(SJControlLayerIdentifier)identifier;
@end

NS_ASSUME_NONNULL_END
