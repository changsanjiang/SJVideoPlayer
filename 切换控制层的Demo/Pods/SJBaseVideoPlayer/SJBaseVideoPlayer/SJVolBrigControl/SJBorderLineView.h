//
//  SJBorderLineView.h
//  SJLine
//
//  Created by BlueDancer on 2017/6/11.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SJBorderLineSide) {
    SJBorderLineSideNone     = 0,
    SJBorderLineSideTop      = 1 << 0,
    SJBorderLineSideLeading  = 1 << 1,
    SJBorderLineSideTrailing = 1 << 2,
    SJBorderLineSideBottom   = 1 << 3,
    SJBorderLineSideAll      = 1 << 4,
};

@interface SJBorderLineView : UIView

+ (instancetype)borderlineViewWithSide:(SJBorderLineSide)side startMargin:(CGFloat)startMargin endMargin:(CGFloat)endMargin lineColor:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

+ (instancetype)borderlineViewWithSide:(SJBorderLineSide)side startMargin:(CGFloat)startMargin endMargin:(CGFloat)endMargin lineColor:(UIColor *)color lineWidth:(CGFloat)width backgroundColor:(UIColor *)backgroundColor;



// MARK: Change

@property (nonatomic, strong, readwrite) UIColor *lineColor;

@property (nonatomic, assign, readwrite) CGFloat lineWidth;

@property (nonatomic, assign, readwrite) SJBorderLineSide side;

- (void)setStartMargin:(CGFloat)startMargin endMargin:(CGFloat)endMargin;

/*!
 *  if you changed property. you should call this method.
 */
- (void)update;

@end

