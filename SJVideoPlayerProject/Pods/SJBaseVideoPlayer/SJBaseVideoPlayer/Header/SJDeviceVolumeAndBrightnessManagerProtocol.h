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
@property (nonatomic, weak, nullable) UIView *targetView;

@property (nonatomic) float volume; // device volume
@property (nonatomic) float brightness; // device brightness
@end


@protocol SJDeviceVolumeAndBrightnessManagerObserver
@property (nonatomic, copy, nullable) void(^volumeDidChangeExeBlock)(id<SJDeviceVolumeAndBrightnessManager> mgr, float volume);
@property (nonatomic, copy, nullable) void(^brightnessDidChangeExeBlock)(id<SJDeviceVolumeAndBrightnessManager> mgr, float brightness);
@end
NS_ASSUME_NONNULL_END

#endif /* SJDeviceVolumeAndBrightnessManagerProtocol_h */
