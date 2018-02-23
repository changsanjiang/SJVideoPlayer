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

/// 支持的方向
typedef NS_ENUM(NSUInteger, SJSupportedRotateViewOrientation) {
    SJSupportedRotateViewOrientation_All,
    SJSupportedRotateViewOrientation_Portrait = 1 << 0,
    SJSupportedRotateViewOrientation_LandscapeLeft = 1 << 1,  // UIDeviceOrientationLandscapeLeft
    SJSupportedRotateViewOrientation_LandscapeRight = 1 << 2, // UIDeviceOrientationLandscapeRight
};

/// 旋转方向
typedef NS_ENUM(NSUInteger, SJRotateViewOrientation) {
    SJRotateViewOrientation_Portrait,
    SJRotateViewOrientation_LandscapeLeft,  // UIDeviceOrientationLandscapeLeft
    SJRotateViewOrientation_LandscapeRight, // UIDeviceOrientationLandscapeRight
};

@interface SJOrentationObserver : NSObject

- (instancetype)initWithTarget:(UIView *)rotateView container:(UIView *)rotateViewSuperView;

@property (nonatomic, readwrite) SJSupportedRotateViewOrientation supportedRotateViewOrientation; // 旋转支持的方向, 默认全部支持

@property (nonatomic, readwrite) SJRotateViewOrientation rotateOrientation; // 旋转到指定方向

@property (nonatomic, assign, readonly, getter=isFullScreen) BOOL fullScreen;

@property (nonatomic, assign, readwrite) float duration; // 旋转时间, default is 0.25

@property (nonatomic, copy, readwrite, nullable) BOOL(^rotationCondition)(SJOrentationObserver *observer); // 旋转条件, 返回 YES 才会旋转, 默认为 nil.

@property (nonatomic, copy, readwrite, nullable) void(^orientationWillChange)(SJOrentationObserver *observer, BOOL isFullScreen);

@property (nonatomic, copy, readwrite, nullable) void(^orientationChanged)(SJOrentationObserver *observer, BOOL isFullScreen);

- (BOOL)_changeOrientation;

@end

NS_ASSUME_NONNULL_END


