//
//  SJControlLayerSwitcher.h
//  SJVideoPlayerV3Project
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SJBaseVideoPlayer;

/**
 下一步:  切换器
 
 切换器示例:
 切换到GIF控制层,  就设置 baseVideoPlayer.delegate 和 dataSource = GIF控制层
 切换到导出视频的控制层, 就设置 baseVideoPlayer.delegate 和 dataSource = 导出视频控制层
 
 思路:
 1. 当某个`控制层`不在使用, 退出时, 该`控制层`告诉`切换器`需要切换别的控制层了
 2. `切换器`负责切换控制层
        代理方式:
            2.1 如果`切换器`存在`代理`, 则询问`代理`是否`切换器`自己处理
            2.2 如果`代理说``切换器`你别处理, 则让`代理`返回一个控制层
                2.2.1 如果未返回, 是直接crash还是警告处理?
            2.3 如果自己处理, 则使用默认处理方式返回控制层
        注册方式:
            2.1 通过标识符, 注册一个控制层
            2.1 由标识符获取控制层
 
 3. 拿到控制层后, 设置这个控制层为`base播放器`的delegate和dataSource
 
 
 优点:
 切换器的代理是个关键, 可以无缝接入别的开发者的控制层
 
 缺点:
 ??? 不知道
 
 问题:
 1. `控制层`怎么告诉`切换器` .....
 */


typedef long SJControlLayerIdentifier;


@protocol SJControlLayerSwitcherDelegate <NSObject>

@end

/**
 delegate与dataSource切换器
 */
@interface SJControlLayerSwitcher : NSObject
@property (nonatomic, weak) id<SJControlLayerSwitcherDelegate> delegate;

- (instancetype)initWithVideoPlayer:(__weak __kindof SJBaseVideoPlayer *)videoPlayer;

- (void)registerWithIdentifier:(SJControlLayerIdentifier)identifier
                  controlLayer:(__kindof UIView *(^)(SJControlLayerSwitcher *switcher, SJControlLayerIdentifier identifier))controlLayer;

- (void)switchControlLayerForIdentifier:(SJControlLayerIdentifier)identifier;

@end

NS_ASSUME_NONNULL_END
