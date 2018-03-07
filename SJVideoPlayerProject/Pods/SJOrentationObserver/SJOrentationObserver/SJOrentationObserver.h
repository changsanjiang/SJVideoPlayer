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

typedef NS_ENUM(NSUInteger, SJSupportedRotateViewOrientation) {
    SJSupportedRotateViewOrientation_All,
    SJSupportedRotateViewOrientation_Portrait = 1 << 0,
    SJSupportedRotateViewOrientation_LandscapeLeft = 1 << 1,  // UIDeviceOrientationLandscapeLeft
    SJSupportedRotateViewOrientation_LandscapeRight = 1 << 2, // UIDeviceOrientationLandscapeRight
};

typedef NS_ENUM(NSUInteger, SJRotateViewOrientation) {
    SJRotateViewOrientation_Portrait,
    SJRotateViewOrientation_LandscapeLeft,  // UIDeviceOrientationLandscapeLeft
    SJRotateViewOrientation_LandscapeRight, // UIDeviceOrientationLandscapeRight
};

@interface SJOrentationObserver : NSObject

@property (nonatomic, copy, readwrite, nullable) BOOL(^rotationCondition)(SJOrentationObserver *observer); // rotate condition, u must set this block, return yes to trigger the rotation. 返回 YES 才会旋转.

- (instancetype)initWithTarget:(UIView *)rotateView container:(UIView *)rotateViewSuperView rotationCondition:(BOOL(^)(SJOrentationObserver *observer))rotationCondition;

- (instancetype)initWithTarget:(UIView *)rotateView container:(UIView *)rotateViewSuperView;

@property (nonatomic, assign, readwrite) float duration; // rotate duration, default is 0.25

@property (nonatomic, readwrite) SJSupportedRotateViewOrientation supportedRotateViewOrientation;

@property (nonatomic, readwrite) SJRotateViewOrientation rotateOrientation; // rotate to the specified orientation, Animated.

@property (nonatomic, assign, readonly, getter=isFullScreen) BOOL fullScreen;

@property (nonatomic, copy, readwrite, nullable) void(^orientationWillChange)(SJOrentationObserver *observer, BOOL isFullScreen);

@property (nonatomic, copy, readwrite, nullable) void(^orientationChanged)(SJOrentationObserver *observer, BOOL isFullScreen);

- (BOOL)_changeOrientation; // Animated.

- (void)rotate:(SJRotateViewOrientation)orientation animated:(BOOL)animated;  // rotate to the specified orientation.

- (void)rotate:(SJRotateViewOrientation)orientation animated:(BOOL)animated completion:(void(^__nullable)(SJOrentationObserver *observer))block;  // rotate to the specified orientation.
@end

NS_ASSUME_NONNULL_END
