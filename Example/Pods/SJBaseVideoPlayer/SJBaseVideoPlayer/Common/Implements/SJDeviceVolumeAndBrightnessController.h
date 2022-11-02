//
//  SJDeviceVolumeAndBrightnessControllerDefines.h
//  SJDeviceVolumeAndBrightnessController
//
//  Created by 畅三江 on 2017/12/10.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJDeviceVolumeAndBrightnessControllerDefines.h"
@protocol SJDeviceVolumeAndBrightnessPopupView, SJDeviceVolumeAndBrightnessPopupViewDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface SJDeviceVolumeAndBrightnessController : NSObject<SJDeviceVolumeAndBrightnessController>
@property (nonatomic, strong, nullable) UIView<SJDeviceVolumeAndBrightnessPopupView> *brightnessView;
@property (nonatomic, strong, nullable) UIView<SJDeviceVolumeAndBrightnessPopupView> *volumeView;
@end


#pragma mark -

@protocol SJDeviceVolumeAndBrightnessPopupViewDataSource <NSObject>
/// 起始状态(progress == 0)
@property (nonatomic, strong, nullable) UIImage *startImage;
/// 普通状态
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic) float progress;
@property (nonatomic, strong, null_resettable) UIColor *traceColor;
@property (nonatomic, strong, null_resettable) UIColor *trackColor;
@end

@protocol SJDeviceVolumeAndBrightnessPopupView <NSObject>
@property (nonatomic, strong) id<SJDeviceVolumeAndBrightnessPopupViewDataSource> dataSource;

- (void)refreshData;
@end



#pragma mark -

/// 系统音量条的显示管理
@interface SJDeviceSystemVolumeViewDisplayManager : NSObject
+ (instancetype)shared;

/// 是否自动控制系统音量条显示, default value is YES;
///
///     如需直接使用系统音量条, 请设置 NO 关闭自动控制;
///
@property (nonatomic) BOOL automaticallyDisplaySystemVolumeView;


// internal methods

- (void)update;
- (void)addController:(nullable id<SJDeviceVolumeAndBrightnessController>)controller;
- (void)removeController:(nullable id<SJDeviceVolumeAndBrightnessController>)controller;
@end
NS_ASSUME_NONNULL_END
