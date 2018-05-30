//
//  SJVideoPlayerSwitcher.h
//  SJVideoPlayerV3Project
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class SJBaseVideoPlayer;

/**
 比如:
 切换到GIF控制层,  就设置 baseVideoPlayer.delegate = GIF控制层
 切换到导出视频的控制层, 就设置 baseVideoPlayer.delegate = 导出视频控制层
 
 思路:
 1. 当某个控制层完成任务将要退出时, 控制层告诉`切换器`需要切换别的控制层了
 2. `切换器`负责切换控制层
            2.1 如果`切换器`存在`代理`, 则询问`代理`是否`切换器`自己处理
            2.2 如果`代理说``切换器`你别不处理, 则让`代理`返回一个控制层
                2.2.1 如果未返回, 是直接crash还是警告处理?
            2.3 如果自己处理, 则使用默认的控制层
 3. 拿到控制层后, 设置这个控制层为`base播放器`的delegate和dataSource
 
 
 问题:
 1. `控制层`怎么告诉`切换器` .....
 */
@protocol SJVideoPlayerSwitcherDelegate <NSObject>

@end

/**
 delegate与dataSource切换器
 */
@interface SJVideoPlayerSwitcher : NSObject

- (instancetype)initWithVideoPlayer:(SJBaseVideoPlayer *)videoPlayer;

- (void)needSwitchControlLayer;

@property (nonatomic, weak) id<SJVideoPlayerSwitcherDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
