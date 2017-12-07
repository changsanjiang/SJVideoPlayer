//
//  UIView+SJUIFactory.h
//  SJUIFactory
//
//  Created by BlueDancer on 2017/11/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SJUIFactory)

@property (nonatomic, assign) CGFloat csj_x;
@property (nonatomic, assign) CGFloat csj_y;
@property (nonatomic, assign) CGFloat csj_w;
@property (nonatomic, assign) CGFloat csj_h;
@property (nonatomic, assign) CGSize  csj_size;
@property (nonatomic, assign) CGFloat csj_centerX;
@property (nonatomic, assign) CGFloat csj_centerY;
@property (nonatomic, assign, readonly) CGFloat csj_maxX;
@property (nonatomic, assign, readonly) CGFloat csj_maxY;
@property (nonatomic, strong, readonly, nullable) UIViewController *csj_viewController;

@end

NS_ASSUME_NONNULL_END
