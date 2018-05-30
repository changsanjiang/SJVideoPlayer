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
 
 1. 控制层告诉`切换器`需要切换控制层了
 2. `切换器`通知`delegate`切换控制层
 3. `delegate`选择好一个控制层交个`切换器` 进行切换
 
 
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
