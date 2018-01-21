//
//  UIViewController+SJVideoPlayerAdd.h
//  SJBackGR
//
//  Created by BlueDancer on 2017/9/27.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJScreenshotTransitionMode.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (SJVideoPlayerAdd)

@property (nonatomic, readonly) UIGestureRecognizerState sj_fullscreenGestureState;

/*!
 *  The specified area does not trigger gestures. It does not affect other ViewControllers.
 *  In the array is subview frame.
 *  @[@(self.label.frame)]
 *
 *  指定区域不触发手势. see `sj_fadeAreaViews` method
 **/
@property (nonatomic, strong, readwrite, nullable) NSArray<NSValue *> *sj_fadeArea;

/*!
 *  The specified area does not trigger gestures. It does not affect other ViewControllers.
 *  In the array is subview.
 *  @[@(self.label)]
 *
 *  指定区域不触发手势.
 **/
@property (nonatomic, strong, readwrite, nullable) NSArray<UIView *> *sj_fadeAreaViews;

/*!
 *  disable pop Gestures. default is NO. It does not affect other ViewControllers.
 *
 *  禁用全屏手势. 默认是 NO.
 **/
@property (nonatomic, assign, readwrite) BOOL sj_DisableGestures;


@property (nonatomic, copy, readwrite, nullable) void(^sj_viewWillBeginDragging)(__kindof UIViewController *vc);
@property (nonatomic, copy, readwrite, nullable) void(^sj_viewDidDrag)(__kindof UIViewController *vc);
@property (nonatomic, copy, readwrite, nullable) void(^sj_viewDidEndDragging)(__kindof UIViewController *vc);

@end

NS_ASSUME_NONNULL_END
