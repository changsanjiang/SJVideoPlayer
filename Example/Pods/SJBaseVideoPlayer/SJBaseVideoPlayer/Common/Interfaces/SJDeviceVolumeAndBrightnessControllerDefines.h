//
//  SJDeviceVolumeAndBrightnessControllerProtocol.h
//  Pods
//
//  Created by 畅三江 on 2019/1/5.
//

#ifndef SJDeviceVolumeAndBrightnessControllerProtocol_h
#define SJDeviceVolumeAndBrightnessControllerProtocol_h
#import <UIKit/UIKit.h>
@protocol SJDeviceVolumeAndBrightnessControllerObserver;

NS_ASSUME_NONNULL_BEGIN
@protocol SJDeviceVolumeAndBrightnessController
- (id<SJDeviceVolumeAndBrightnessControllerObserver>)getObserver;
@property (nonatomic) float volume; // device volume
@property (nonatomic) float brightness; // device brightness

/// 以下属性由播放器自动维护
///
@property (nonatomic, weak, nullable) UIView *target;
@property (nonatomic, getter=isVolumeTracking) BOOL volumeTracking;
@property (nonatomic, getter=isBrightnessTracking) BOOL brightnessTracking;
@end


@protocol SJDeviceVolumeAndBrightnessControllerObserver
@property (nonatomic, copy, nullable) void(^volumeDidChangeExeBlock)(id<SJDeviceVolumeAndBrightnessController> mgr, float volume);
@property (nonatomic, copy, nullable) void(^brightnessDidChangeExeBlock)(id<SJDeviceVolumeAndBrightnessController> mgr, float brightness);
@end
NS_ASSUME_NONNULL_END

#endif /* SJDeviceVolumeAndBrightnessControllerProtocol_h */
