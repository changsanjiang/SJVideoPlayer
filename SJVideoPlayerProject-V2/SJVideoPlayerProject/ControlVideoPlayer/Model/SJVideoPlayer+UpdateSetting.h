//
//  SJVideoPlayer+UpdateSetting.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/2/4.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayer.h"
#import "SJVideoPlayerSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayer (UpdateSetting)
/*!
 *  Configure the player, Note: This `block` is run on the child thread.
 *
 *  配置播放器, 注意: 这个`block`在子线程运行.
 
 示例:
 *  SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {
        ..... .............. ......
        ..... setting player ......
        ..... .............. ......
        commonSettings.placeholder = [UIImage imageNamed:@"placeholder"];
        commonSettings.more_trackColor = [UIColor whiteColor];
        commonSettings.progress_trackColor = [UIColor colorWithWhite:0.4 alpha:1];
        commonSettings.progress_bufferColor = [UIColor whiteColor];
    });
 **/
@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(SJVideoPlayerSettings *commonSettings));

+ (void)resetSetting; // 重置配置, 恢复默认设置

/*!
 *  Configure the player, Note: This `block` is run on the child thread.
 
    [SJVideoPlayer update:^(SJVideoPlayerSettings * _Nonnull commonSettings) {
        // update common settings
        commonSettings.more_trackColor = [UIColor whiteColor];
        commonSettings.progress_trackColor = [UIColor colorWithWhite:0.4 alpha:1];
        commonSettings.progress_bufferColor = [UIColor whiteColor];
        // .... other settings ....
        // .... .... .... .... ....
    } completion:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.initialized = YES; // 初始化已完成, 在初始化期间不显示控制层.
        [self controlLayerNeedAppear:self.videoPlayer]; // 显示控制层
    }];
 **/
+ (void)update:(void(^__nullable)(SJVideoPlayerSettings *commonSettings))block completion:(void(^__nullable)(void))completeBlock;

+ (void)loadDefaultSettingAndCompletion:(void(^__nullable)(void))completeBlock;

@end

NS_ASSUME_NONNULL_END
