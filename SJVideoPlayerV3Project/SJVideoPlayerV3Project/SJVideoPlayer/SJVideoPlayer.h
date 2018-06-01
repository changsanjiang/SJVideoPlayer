//
//  SJVideoPlayer.h
//  SJVideoPlayerV3Project
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJBaseVideoPlayer.h"
#import "SJVideoPlayerSettings.h"
#import "SJVideoPlayerMoreSetting.h"
#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import "SJVideoPlayerMoreSettingSecondary.h"
#import "SJFilmEditingResultShareItem.h"
#import "SJLightweightTopItem.h"
#import "SJVideoPlayerFilmEditingCommonHeader.h"
#import "SJVideoPlayerFilmEditingConfig.h"

NS_ASSUME_NONNULL_BEGIN
typedef long SJControlLayerIdentifier;
@class SJControlLayerCarrier;



typedef NS_ENUM(NSUInteger, SJControlLayerSwitchingState) {
    SJControlLayerSwitchingState_Unknown,
    SJControlLayerSwitchingState_Restart,
    SJControlLayerSwitchingState_Exit,
};


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
extern SJControlLayerIdentifier SJControlLayer_Edge;
extern SJControlLayerIdentifier SJControlLayer_FilmEditing;

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



#pragma mark
@interface SJControlLayerCarrier : NSObject
- (instancetype)initWithIdentifier:(SJControlLayerIdentifier)identifier
                        dataSource:(id<SJVideoPlayerControlLayerDataSource>)dataSource
                          delegate:(id<SJVideoPlayerControlLayerDelegate>)delegate
                      exitExeBlock:(void(^)(SJControlLayerCarrier *carrier))exitExeBlock
                   restartExeBlock:(void(^)(SJControlLayerCarrier *carrier))restartExeBlock;

@property (nonatomic, strong, readonly) id <SJVideoPlayerControlLayerDataSource> dataSource;
@property (nonatomic, strong, readonly) id <SJVideoPlayerControlLayerDelegate> delegate;
@property (nonatomic, readonly) SJControlLayerIdentifier identifier;

@property (nonatomic, copy, readonly, nullable) void(^exitExeBlock)(SJControlLayerCarrier *carrier);
@property (nonatomic, copy, readonly, nullable) void(^restartExeBlock)(SJControlLayerCarrier *carrier);
@end

NS_ASSUME_NONNULL_END
