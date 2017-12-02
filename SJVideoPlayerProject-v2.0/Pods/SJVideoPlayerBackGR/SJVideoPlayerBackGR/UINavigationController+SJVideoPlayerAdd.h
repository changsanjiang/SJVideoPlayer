//
//  UINavigationController+SJVideoPlayerAdd.h
//  SJBackGR
//
//  Created by BlueDancer on 2017/9/26.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UINavigationController (SJVideoPlayerAdd)<UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *sj_pan;

@end





@interface UINavigationController (Settings)

/*!
 *  bar Color
 *
 *  如果导航栏上出现了黑底, 请设置他.
 **/
@property (nonatomic, strong, readwrite) UIColor *sj_backgroundColor;

/*!
 *  default is NO.
 *  If you use native gestures, some methods(sj_viewWillBeginDragging...) of the controller will not be called.
 *  使用系统边缘返回手势, 还是使用自定义的全屏手势
 **/
@property (nonatomic, assign, readwrite) BOOL useNativeGesture;

/*!
 *  default is 0.35.
 *
 *  0.0 .. 1.0
 *  偏移多少, 触发pop操作
 **/
@property (nonatomic, assign, readwrite) float scMaxOffset;

/*!
 *  default is NO.
 *
 *  禁用系统手势和全屏手势.
 **/
@property (nonatomic, assign, readwrite) BOOL sj_DisableGestures;

@end
