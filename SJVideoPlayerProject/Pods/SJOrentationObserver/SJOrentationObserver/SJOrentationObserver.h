//
//  SJOrentationObserver.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//
//  https://github.com/changsanjiang/SJOrentationObserver
//  changsanjiang@gmail.com
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Auto rotate supported orientation
typedef NS_ENUM(NSUInteger, SJAutoRotateSupportedOrientation) {
    SJAutoRotateSupportedOrientation_All,
    SJAutoRotateSupportedOrientation_Portrait = 1 << 0,
    SJAutoRotateSupportedOrientation_LandscapeLeft = 1 << 1,  // UIDeviceOrientationLandscapeLeft
    SJAutoRotateSupportedOrientation_LandscapeRight = 1 << 2, // UIDeviceOrientationLandscapeRight
};

typedef NS_ENUM(NSUInteger, SJOrientation) {
    SJOrientation_Portrait,
    SJOrientation_LandscapeLeft,  // UIDeviceOrientationLandscapeLeft
    SJOrientation_LandscapeRight, // UIDeviceOrientationLandscapeRight
};

@interface SJOrentationObserver : NSObject

- (instancetype)initWithTarget:(UIView *)rotateView container:(UIView *)rotateViewSuperView rotationCondition:(BOOL(^)(SJOrentationObserver *observer))rotationCondition;

- (instancetype)initWithTarget:(UIView *)rotateView container:(UIView *)rotateViewSuperView;

/// The block invoked when orientation will changed, if return YES, auto rotate will be triggered
@property (nonatomic, copy, nullable) BOOL(^rotationCondition)(SJOrentationObserver *observer);

/// Auto rotate supported orientation
@property (nonatomic) SJAutoRotateSupportedOrientation supportedOrientation;

/// Current Orientation. Can also change it, rotate to the specified orientation. Animated
@property (nonatomic) SJOrientation orientation;

/// If rotating, this value is YES
@property (nonatomic, readonly, getter=isTransitioning) BOOL transitioning;

/// If orientation is landscapeLeft or landscapeRight this value is YES
@property (nonatomic, readonly, getter=isFullScreen) BOOL fullScreen;

/// Rotate duration, default is 0.25
@property (nonatomic) float duration;

/// The block invoked when orientation will changed
@property (nonatomic, copy, nullable) void(^orientationWillChange)(SJOrentationObserver *observer, BOOL isFullScreen);

/// The block invoked when orientation changed
@property (nonatomic, copy, nullable) void(^orientationChanged)(SJOrentationObserver *observer, BOOL isFullScreen);

/// Auto roate, Animated
- (BOOL)rotate;

/// Rotate to the specified orientation
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated;

/// Rotate to the specified orientation
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completion:(void(^__nullable)(SJOrentationObserver *observer))block;  // rotate to the specified orientation.

@end

NS_ASSUME_NONNULL_END
