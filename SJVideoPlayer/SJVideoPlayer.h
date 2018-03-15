//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//
//  The base player, without the control layer, can be used if you need a custom control layer.
//  https://github.com/changsanjiang/SJBaseVideoPlayer
//
//  Player with default control layer.
//  https://github.com/changsanjiang/SJVideoPlayer
//
//  changsanjiang@gmail.com
//

#import <UIKit/UIKit.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import "SJVideoPlayerSettings.h"
#import "SJVideoPlayerMoreSetting.h"
#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import "SJVideoPlayerMoreSettingSecondary.h"
#import "SJFilmEditingResultShareItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayer : SJBaseVideoPlayer

+ (instancetype)sharedPlayer;   // 使用默认的控制层

+ (instancetype)player;         // 使用默认的控制层

- (instancetype)init;           // 使用默认的控制层

- (instancetype)initWithControlLayerDataSource:(nullable id<SJVideoPlayerControlLayerDataSource> )controlLayerDataSource
                          controlLayerDelegate:(nullable id<SJVideoPlayerControlLayerDelegate>)controlLayerDelegate;    // 指定控制层
@end


#pragma mark - 配置`默认控制层`

@interface SJVideoPlayer (SettingDefaultControlLayer)

/**
 *  Whether to generate a preview view. default is YES.
 *
 *  是否自动生成预览视图, 默认是 YES. 如果为NO, 则预览按钮将不会显示.
 */
@property (nonatomic, assign, readwrite) BOOL generatePreviewImages;

/**
 *  clicked back btn exe block.
 *
 *  点击`返回`按钮的回调.
 */
@property (nonatomic, copy, readwrite) void(^clickedBackEvent)(SJVideoPlayer *player);


/**
    If yes, the player will prompt the user when the network status changes.
 */
@property (nonatomic, assign, readwrite) BOOL disableNetworkStatusChangePrompt; // default is NO. 是否禁止网路状态变化提示. 默认为No.

/**
 *  Configure the player, Note: T his `block` is run on the child thread.
 *
 *  配置播放器, 注意: 这个`block`在子线程运行.
 *
 *  SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {
        ..... setting player ......
        commonSettings.placeholder = [UIImage imageNamed:@"placeholder"];
        commonSettings.more_trackColor = [UIColor whiteColor];
        commonSettings.progress_trackColor = [UIColor colorWithWhite:0.4 alpha:1];
        commonSettings.progress_bufferColor = [UIColor whiteColor];
    });
 **/
@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(SJVideoPlayerSettings *commonSettings));
+ (void)resetSetting; // 重置配置, 恢复默认设置

/**
 *  clicked More button to display items.
 *
 *  点击`更多(右上角的三个点)`按钮, 弹出来的选项.
 **/
@property (nonatomic, strong, readwrite, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;


/**
    If yes, the player will display the right control view.
    But if the format of the video is m3u8, it does not work.
 */
@property (nonatomic, assign, readwrite) BOOL enableFilmEditing;

@property (nonatomic, strong, readwrite, nullable) SJFilmEditingResultShare *filmEditingResultShare;

- (void)exitFilmEditingCompletion:(void(^__nullable)(SJVideoPlayer *player))completion;

@end

NS_ASSUME_NONNULL_END
