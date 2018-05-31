//
//  SJVideoPlayer.h
//  SJVideoPlayerV3Project
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJBaseVideoPlayer.h"

NS_ASSUME_NONNULL_BEGIN
typedef long SJControlLayerIdentifier;
@class SJControlLayerCarrier;

extern SJControlLayerIdentifier SJDefaultControlLayer_edge;
extern SJControlLayerIdentifier SJDefaultControlLayer_DraggingPreview;

@interface SJVideoPlayer : SJBaseVideoPlayer

+ (instancetype)sharedPlayer;   // 使用默认的控制层

+ (instancetype)player;         // 使用默认的控制层

- (instancetype)init;           // 使用默认的控制层

/**
 A lightweight player with simple functions.
 一个具有简单功能的播放器.
 
 @return player
 */
+ (instancetype)lightweightPlayer;



#pragma mark
/**
 下一步:  切换器
 
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
 
 切换器关键, 可以无缝接入别的开发者的控制层
 
 */

/// 当前控制层的标识
@property (nonatomic, readonly) SJControlLayerIdentifier currentControlLayerIdentifier;

/// 添加一个备选的控制层
- (void)appendControlLayer:(SJControlLayerCarrier *)carrier;
/// 删除一个备选的控制层
- (void)deleteControlLayerForIdentifier:(SJControlLayerIdentifier)identifier;
/// 根据标识获取一个控制层, 如果已加入备选, 则返回, 否之, 返回nil
- (nullable SJControlLayerCarrier *)controlLayerForIdentifier:(SJControlLayerIdentifier)identifier;

/// 关键方法
/// 切换控制层
/// 将当前的控制层切换为指定标识的控制层
- (void)switchControlLayerForIdentitfier:(SJControlLayerIdentifier)identifier;



/// 该方法准备过期, 待重构完成整理
- (instancetype)initWithControlLayerDataSource:(nullable __weak id<SJVideoPlayerControlLayerDataSource> )controlLayerDataSource
                          controlLayerDelegate:(nullable __weak id<SJVideoPlayerControlLayerDelegate>)controlLayerDelegate;    // 指定控制层
@end


#pragma mark
@interface SJControlLayerCarrier : NSObject
- (instancetype)initWithIdentifier:(SJControlLayerIdentifier)identifier
                        dataSource:(__strong id <SJVideoPlayerControlLayerDataSource>)dataSource
                          delegate:(__strong id<SJVideoPlayerControlLayerDelegate>)delegate;

@property (nonatomic, readonly) SJControlLayerIdentifier identifier;
@property (nonatomic, strong, readonly) id <SJVideoPlayerControlLayerDataSource> dataSource;
@property (nonatomic, strong, readonly) id <SJVideoPlayerControlLayerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
