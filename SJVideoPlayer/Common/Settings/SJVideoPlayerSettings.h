//
//  SJVideoPlayerSettings.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/9/25.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerConst.h"
@class UIImage, UIColor, UIFont, SJVideoPlayerSettings;

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN NSNotificationName const SJVideoPlayerSettingsUpdatedNotification;

@interface SJVideoPlayerSettings : NSObject
+ (instancetype)commonSettings;
///
/// 更新
///
/// \code
///
///     SJVideoPlayerSettings.update(^(SJVideoPlayerSettings * _Nonnull settings) {
///         // 注意, 该block将在子线程执行
///         settings.progress_thumbImage = [UIImage imageNamed:@"...."];
///     });
///
/// \endcode
///
@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(SJVideoPlayerSettings *settings));
///
/// 重置, 恢复默认设置
///
- (void)reset;
@end


@interface SJVideoPlayerSettings (SJEdgeControlLayer)
@property (nonatomic, strong, nullable) UIImage *placeholder;

// fast forward view(长按快进时显示的视图)
@property (nonatomic, strong, nullable) UIColor  *fastForwardTriangleColor;
@property (nonatomic, strong, nullable) UIColor  *fastForwardRateTextColor;
@property (nonatomic, strong, nullable) UIFont   *fastForwardRateTextFont;
@property (nonatomic, strong, nullable) UIColor  *fastForwardFFTextColor;
@property (nonatomic, strong, nullable) UIFont   *fastForwardFFTextFont;
@property (nonatomic, strong, nullable) NSString *fastForwardFFText;

// loading view
@property (nonatomic, strong, nullable) UIColor *loadingNetworkSpeedTextColor;
@property (nonatomic, strong, nullable) UIFont  *loadingNetworkSpeedTextFont;
@property (nonatomic, strong, nullable) UIColor *loadingLineColor;

// dragging view
@property (nonatomic, strong, nullable) UIImage *fastImage;
@property (nonatomic, strong, nullable) UIImage *forwardImage;

// network prompt text
@property (nonatomic, strong, nullable) NSString *unstableNetworkPrompt;
@property (nonatomic, strong, nullable) NSString *cellularNetworkPrompt;

// custom status bar
@property (nonatomic, strong, nullable) NSString *statusBarNoNetworkText;
@property (nonatomic, strong, nullable) NSString *statusBarWiFiText;
@property (nonatomic, strong, nullable) NSString *statusBarCellularNetworkText;
@property (nonatomic, strong, nullable) UIImage *batteryBorderImage;
@property (nonatomic, strong, nullable) UIImage *batteryNubImage;
@property (nonatomic, strong, nullable) UIImage *batteryLightningImage;

// top adapter items
@property (nonatomic, strong, nullable) UIImage *backBtnImage;
@property (nonatomic, strong, nullable) UIImage *moreBtnImage;
@property (nonatomic, strong, nullable) UIFont *titleFont;
@property (nonatomic, strong, nullable) UIColor *titleColor;

// left adapter items
@property (nonatomic, strong, nullable) UIImage *lockBtnImage;
@property (nonatomic, strong, nullable) UIImage *unlockBtnImage;

// bottom adapter items
@property (nonatomic, strong, nullable) UIImage *pauseBtnImage;
@property (nonatomic, strong, nullable) UIImage *playBtnImage;
@property (nonatomic, strong, nullable) UIFont *timeFont;
@property (nonatomic, strong, nullable) NSString *liveText;                       // 实时直播
@property (nonatomic, strong, nullable) UIImage *shrinkscreenImage;               // 缩回小屏的图片
@property (nonatomic, strong, nullable) UIImage *fullBtnImage;                    // 全屏的图片
@property (nonatomic, strong, nullable) UIColor *progress_trackColor;             // 轨道颜色
@property (nonatomic) float progress_traceHeight;                                 // 轨道高度
@property (nonatomic, strong, nullable) UIColor *progress_traceColor;             // 轨迹颜色, 走过的痕迹
@property (nonatomic, strong, nullable) UIColor *progress_bufferColor;            // 缓冲颜色
@property (nonatomic, strong, nullable) UIColor *progress_thumbColor;             // 滑块颜色, 请设置滑块大小
@property (nonatomic, strong, nullable) UIImage *progress_thumbImage;             // 滑块图片, 优先使用, 为nil时将会使用滑块颜色
@property (nonatomic) float progress_thumbSize;                                   // 滑块大小
@property (nonatomic, strong, nullable) UIColor *bottomIndicator_trackColor;      // 底部指示条轨道颜色
@property (nonatomic, strong, nullable) UIColor *bottomIndicator_traceColor;      // 底部指示条轨迹颜色
@property (nonatomic) float bottomIndicator_height;                               // 底部指示条高度
    
// right adapter items
@property (nonatomic, strong, nullable) UIImage *filmEditingBtnImage;

// center adapter items
@property (nonatomic, strong, nullable) UIColor *replayBtnTitleColor;
@property (nonatomic, strong, nullable) NSString *replayBtnTitle;
@property (nonatomic, strong, nullable) UIImage *replayBtnImage;
@property (nonatomic, strong, nullable) UIFont *replayBtnFont;
@end


@interface SJVideoPlayerSettings (SJMoreSettingControlLayer)
@property (nonatomic, strong, nullable) UIColor *moreBackgroundColor; // more view background color
@property (nonatomic, strong, nullable) UIColor *more_traceColor;     // sider trace color of more view
@property (nonatomic, strong, nullable) UIColor *more_trackColor;     // sider track color of more view
@property (nonatomic) float more_trackHeight;                         // sider track height of more view
@property (nonatomic, strong, nullable) UIImage *more_thumbImage;     // sider thumb image of more view
@property (nonatomic) float more_thumbSize;                           // sider thumb size of more view
@property (nonatomic, strong, nullable) UIImage *more_minRateImage;
@property (nonatomic, strong, nullable) UIImage *more_maxRateImage;
@property (nonatomic, strong, nullable) UIImage *more_minVolumeImage;
@property (nonatomic, strong, nullable) UIImage *more_maxVolumeImage;
@property (nonatomic, strong, nullable) UIImage *more_minBrightnessImage;
@property (nonatomic, strong, nullable) UIImage *more_maxBrightnessImage;
@end


@interface SJVideoPlayerSettings (SJLoadFailedControlLayer)
@property (nonatomic, strong, nullable) NSString *playFailedText;
@property (nonatomic, strong, nullable) NSString *playFailedButtonText;
@property (nonatomic, strong, nullable) UIColor *playFailedButtonBackgroundColor;
@end


@interface SJVideoPlayerSettings (SJNotReachableControlLayer)
@property (nonatomic, strong, nullable) NSString *noNetworkPromptText;
@property (nonatomic, strong, nullable) NSString *noNetworkReloadButtonTitle;
@property (nonatomic, strong, nullable) UIColor *noNetworkButtonBackgroundColor;
@end


@interface SJVideoPlayerSettings (SJFloatSmallViewControlLayer)
@property (nonatomic, strong, nullable) UIImage *floatSmallViewCloseImage;
@end


@interface SJVideoPlayerSettings (SJFilmEditingControlLayer)
@property (nonatomic, strong, nullable) UIImage *screenshotBtnImage;
@property (nonatomic, strong, nullable) UIImage *exportBtnImage;
@property (nonatomic, strong, nullable) UIImage *gifBtnImage;
///
/// 左上角
///     - 取消按钮
///     - 完成按钮
@property (nonatomic, strong, nullable) NSString *cancelText;
@property (nonatomic, strong, nullable) NSString *doneText;
///
/// 录制时右侧按钮
///     - 等待中
///     - 可完成
@property (nonatomic, strong, nullable) NSString *waitingText;
@property (nonatomic, strong, nullable) UIImage *waitingImage;
@property (nonatomic, strong, nullable) NSString *finishText;
@property (nonatomic, strong, nullable) UIImage *finishImage;
///
/// 导出时
///     - 导出中
///     - 导出失败
///     - 导出成功
///     - 截屏成功
@property (nonatomic, strong, nullable) NSString *exportingText;
@property (nonatomic, strong, nullable) NSString *exportFailedText;
@property (nonatomic, strong, nullable) NSString *exportSucceededText;
@property (nonatomic, strong, nullable) NSString *screenshotSucceededText;
///
/// 保存至相册
///     - 保存失败, 相册访问权限未开启
///     - 正在保存
///     - 已保存至相册
@property (nonatomic, strong, nullable) NSString *albumAuthDeniedText;
@property (nonatomic, strong, nullable) NSString *savingToAlbumText;
@property (nonatomic, strong, nullable) NSString *savedToAlbumText;
///
/// 上传
///     - 上传中
///     - 上传成功
///     - 上传失败
@property (nonatomic, strong, nullable) NSString *uploadingText;
@property (nonatomic, strong, nullable) NSString *uploadFailedText;
@property (nonatomic, strong, nullable) NSString *uploadSucceededText;

@property (nonatomic, strong, nullable) NSString *operationFailedText;
@end
NS_ASSUME_NONNULL_END
