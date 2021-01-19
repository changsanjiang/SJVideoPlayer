//
//  SJDeviceVolumeAndBrightnessManagerDefines.h
//  SJDeviceVolumeAndBrightnessManager
//
//  Created by 畅三江 on 2017/12/10.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJDeviceVolumeAndBrightnessManagerDefines.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - SJDeviceOutputPromptView
@protocol SJDeviceOutputPromptViewDataSource <NSObject>

/// 普通状态
@property (nonatomic, strong, nullable) UIImage *image;
/// 其实状态
@property (nonatomic, strong, nullable) UIImage *startImage;

@property (nonatomic, assign) float progress;
@property (nonatomic, strong, nullable) UIColor *traceColor;
@property (nonatomic, strong, nullable) UIColor *trackColor;
@end

@protocol SJDeviceOutputPromptView <NSObject>
@property (nonatomic, strong) id<SJDeviceOutputPromptViewDataSource> dataSource;

- (void)refreshData;
@end


#pragma mark -

@interface SJDeviceVolumeAndBrightnessManager : NSObject<SJDeviceVolumeAndBrightnessManager>
+ (instancetype)shared;

@property (nonatomic, strong, nullable) id<SJDeviceOutputPromptView> brightnessView;
@property (nonatomic, strong, nullable) id<SJDeviceOutputPromptView> volumeView;

/// 以下属性 优先于 brightnessView，volumeView中的dataSource的配置
@property (nonatomic, strong, null_resettable) UIColor *traceColor;
@property (nonatomic, strong, null_resettable) UIColor *trackColor;

///
/// 是否在播放器中显示音量或亮度提示视图
///
///     default value is YES.
///
@property (nonatomic) BOOL showsPromptView;
@end
NS_ASSUME_NONNULL_END

