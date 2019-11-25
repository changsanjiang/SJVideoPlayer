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
@interface SJDeviceVolumeAndBrightnessManager : NSObject<SJDeviceVolumeAndBrightnessManager>
+ (instancetype)shared;

@property (nonatomic, strong, null_resettable) UIColor *traceColor;
@property (nonatomic, strong, null_resettable) UIColor *trackColor;
@end
NS_ASSUME_NONNULL_END

