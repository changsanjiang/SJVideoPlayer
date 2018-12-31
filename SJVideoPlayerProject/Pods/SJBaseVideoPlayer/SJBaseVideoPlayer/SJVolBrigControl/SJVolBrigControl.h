//
//  SJVolBrigControl.h
//  SJVolBrigControl
//
//  Created by BlueDancer on 2017/12/10.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJVolBrigControl : NSObject

@property (nonatomic, strong, readonly) UIView *brightnessView;

/// 0..1
@property (nonatomic) float volume;
@property (nonatomic, copy, nullable) void(^volumeChanged)(float volume);
@property (nonatomic) BOOL disableVolumeSetting;

/// 0.1..1
@property (nonatomic) float brightness;
@property (nonatomic, copy, nullable) void(^brightnessChanged)(float brightness);
@property (nonatomic) BOOL disableBrightnessSetting;

@end
NS_ASSUME_NONNULL_END

