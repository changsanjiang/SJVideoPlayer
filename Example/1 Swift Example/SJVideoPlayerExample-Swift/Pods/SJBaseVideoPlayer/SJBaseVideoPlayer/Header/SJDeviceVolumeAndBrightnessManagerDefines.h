//
//  SJDeviceVolumeAndBrightnessManagerProtocol.h
//  Pods
//
//  Created by 畅三江 on 2019/1/5.
//

#ifndef SJDeviceVolumeAndBrightnessManagerProtocol_h
#define SJDeviceVolumeAndBrightnessManagerProtocol_h
#import <UIKit/UIKit.h>
@protocol SJDeviceVolumeAndBrightnessManagerObserver;

NS_ASSUME_NONNULL_BEGIN
@protocol SJDeviceVolumeAndBrightnessManager
- (id<SJDeviceVolumeAndBrightnessManagerObserver>)getObserver;
@property (nonatomic) float volume; // device volume
@property (nonatomic) float brightness; // device brightness

/// 以下属性由播放器自动维护
///
@property (nonatomic, getter=isVolumeTracking) BOOL volumeTracking;
@property (nonatomic, getter=isBrightnessTracking) BOOL brightnessTracking;
- (void)prepare;
@end


@protocol SJDeviceVolumeAndBrightnessManagerObserver
@property (nonatomic, copy, nullable) void(^volumeDidChangeExeBlock)(id<SJDeviceVolumeAndBrightnessManager> mgr, float volume);
@property (nonatomic, copy, nullable) void(^brightnessDidChangeExeBlock)(id<SJDeviceVolumeAndBrightnessManager> mgr, float brightness);
@end
NS_ASSUME_NONNULL_END

#endif /* SJDeviceVolumeAndBrightnessManagerProtocol_h */
