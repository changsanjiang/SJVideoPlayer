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

@interface UINavigationController (Settings)

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
 *
 *  0.0 .. 1.0
 *  偏移多少, 触发pop.
 **/
@property (nonatomic) float scMaxOffset;

@end

NS_ASSUME_NONNULL_END
