//
//  UINavigationController+SJVideoPlayerAdd.h
//  SJBackGR
//
//  Created by BlueDancer on 2017/9/26.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJScreenshotTransitionMode.h"

NS_ASSUME_NONNULL_BEGIN

// default is `SJFullscreenPopGestureType_EdgeLeft`.
typedef NS_ENUM(NSUInteger, SJFullscreenPopGestureType) {
    SJFullscreenPopGestureType_EdgeLeft,    // 默认, 屏幕左边缘触发手势
    SJFullscreenPopGestureType_Full,        // 全屏触发手势
};

@interface UINavigationController (Settings)

@property (nonatomic, readwrite) SJFullscreenPopGestureType sj_gestureType;

@property (nonatomic, readwrite) SJScreenshotTransitionMode sj_transitionMode;

@property (nonatomic, readonly) UIGestureRecognizerState sj_fullscreenGestureState;

/*!
 *  bar Color. If there is a black top on the navigation bar, set it.
 *
 *  如果导航栏上出现了黑底, 请设置他.
 **/
@property (nonatomic, strong, readwrite, nullable) UIColor *sj_backgroundColor;

/*!
 *  default is 0.35. The proportion of pop gesture offset.
 *  It is useful only when the gesture type is set to `SJFullscreenPopGestureType_Full`.
 *
 *  0.0 .. 1.0
 *  偏移多少, 触发pop.
 **/
@property (nonatomic) float scMaxOffset;

@end

NS_ASSUME_NONNULL_END
