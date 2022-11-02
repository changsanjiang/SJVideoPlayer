//
//  SJDeviceVolumeAndBrightness.h
//  SJBaseVideoPlayer
//
//  Created by 蓝舞者 on 2022/10/14.
//

#import <UIKit/UIKit.h>
@protocol SJDeviceVolumeAndBrightnessObserver;

NS_ASSUME_NONNULL_BEGIN
@interface SJDeviceVolumeAndBrightness : NSObject
+ (instancetype)shared;

@property (nonatomic, strong, readonly) UIView *sysVolumeView;

@property (nonatomic) float volume;
@property (nonatomic) float brightness;

- (void)addObserver:(id<SJDeviceVolumeAndBrightnessObserver>)observer;
- (void)removeObserver:(id<SJDeviceVolumeAndBrightnessObserver>)observer;
@end

@protocol SJDeviceVolumeAndBrightnessObserver <NSObject>
@optional
- (void)device:(SJDeviceVolumeAndBrightness *)device onVolumeChanged:(float)volume;
- (void)device:(SJDeviceVolumeAndBrightness *)device onBrightnessChanged:(float)brightness;
@end
NS_ASSUME_NONNULL_END
