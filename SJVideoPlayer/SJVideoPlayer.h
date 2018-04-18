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
#import "SJLightweightTopItem.h"
#import "SJVideoPlayerFilmEditingCommonHeader.h"
#import "SJVideoPlayerFilmEditingConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayer : SJBaseVideoPlayer

+ (instancetype)sharedPlayer;   // 使用默认的控制层

+ (instancetype)player;         // 使用默认的控制层

- (instancetype)init;           // 使用默认的控制层

- (instancetype)initWithControlLayerDataSource:(nullable id<SJVideoPlayerControlLayerDataSource> )controlLayerDataSource
                          controlLayerDelegate:(nullable id<SJVideoPlayerControlLayerDelegate>)controlLayerDelegate;    // 指定控制层

/**
 A lightweight player with simple functions.
 一个具有简单功能的播放器.
 
 @return player
 */
+ (instancetype)lightweightPlayer;


/**
 Clicked back btn exe block.
 点击`返回`按钮的回调.
 
 readwrite.
 */
@property (nonatomic, copy, readwrite) void(^clickedBackEvent)(SJVideoPlayer *player);


/**
 If yes, the player will prompt the user when the network status changes.
 是否禁止网络状态变化时的提示, 默认是NO.
 
 readwrite.
 */
@property (nonatomic) BOOL disableNetworkStatusChangePrompt; // default is NO. 是否禁止网路状态变化提示. 默认为No.

@end


#pragma mark - Setting lightweight control layer

@interface SJVideoPlayer (SettingLightweightControlLayer)

@property (nonatomic, copy, nullable) NSArray<SJLightweightTopItem *> *topControlItems;

@property (nonatomic, copy, nullable) void(^clickedTopControlItemExeBlock)(SJVideoPlayer *player, SJLightweightTopItem *item);

@end


#pragma mark - Setting default control layer

@interface SJVideoPlayer (SettingDefaultControlLayer)

/**
 *  Whether to generate a preview view. default is YES.
 *
 *  是否自动生成预览视图, 默认是 YES. 如果为NO, 则预览按钮将不会显示.
 *
 *  readwrite.
 */
@property (nonatomic) BOOL generatePreviewImages;

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
 *
 *  readwrite.
 **/
@property (nonatomic, strong, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

@end



#pragma mark - Film Editing [GIF/Export/Screenshot]

@interface SJVideoPlayer (FilmEditing)

/**
 If yes, the player will display the right control view.
 But if the format of the video is m3u8, it does not work.
 
 default is  NO.
 
 readwrite.
 */
@property (nonatomic) BOOL enableFilmEditing;

@property (nonatomic, strong, readonly) SJVideoPlayerFilmEditingConfig *filmEditingConfig;

- (void)dismissFilmEditingViewCompletion:(void(^__nullable)(SJVideoPlayer *player))completionBlock;


- (void)exitFilmEditingCompletion:(void(^__nullable)(SJVideoPlayer *player))completion NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "use `dismissFilmEditingViewCompletion:`");
@end

NS_ASSUME_NONNULL_END
