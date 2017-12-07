//
//  JDradualLoadingView.h
//  JCombineLoadingAnimation
//
//  Created by https://github.com/mythkiven/ on 15/01/16.
//  Copyright © 2015年 mythkiven. All rights reserved.
//

#import <UIKit/UIKit.h>


// 外层的渐变动画

@interface JDradualLoadingView : UIButton

/** 渐变线宽 默认10*/
@property (nonatomic, assign) CGFloat lineWidth;

/** 渐变线的颜色 默认redColor*/
@property (nonatomic, strong) UIColor *lineColor;

/** 开始动画 */
- (void)startAnimation;
/** 结束动画 */
- (void)stopAnimation;

@end
