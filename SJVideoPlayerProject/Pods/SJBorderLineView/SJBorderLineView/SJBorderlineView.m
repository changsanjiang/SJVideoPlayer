//
//  SJBorderlineView.m
//  SJLine
//
//  Created by BlueDancer on 2017/6/11.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJBorderlineView.h"

@interface SJBorderlineView ()

@property (nonatomic, assign, readwrite) CGFloat startMargin;
@property (nonatomic, assign, readwrite) CGFloat endMargin;

@end

@implementation SJBorderlineView

+ (instancetype)borderlineViewWithSide:(SJBorderlineSide)side startMargin:(CGFloat)startMargin endMargin:(CGFloat)endMargin lineColor:(UIColor *)color backgroundColor:(UIColor *)backgroundColor {
    return [self borderlineViewWithSide:side startMargin:startMargin endMargin:endMargin lineColor:color lineWidth:1.0 backgroundColor:backgroundColor];
}

+ (instancetype)borderlineViewWithSide:(SJBorderlineSide)side startMargin:(CGFloat)startMargin endMargin:(CGFloat)endMargin lineColor:(UIColor *)color lineWidth:(CGFloat)width backgroundColor:(UIColor *)backgroundColor {
    SJBorderlineView *view = [SJBorderlineView new];
    view.backgroundColor = backgroundColor;
    view.side = side;
    view.startMargin = startMargin;
    view.endMargin = endMargin;
    view.lineColor = color;
    view.lineWidth = width;
    return view;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = 1.0;
    
    CGPoint movePoint = CGPointZero;
    CGPoint addLineToPoint = CGPointZero;
    
    if ( 0 == _side ) return;
    if ( SJBorderlineSideAll == ( _side & SJBorderlineSideAll ) ) {
        _side = SJBorderlineSideTop | SJBorderlineSideLeading | SJBorderlineSideBottom | SJBorderlineSideTrailing;
    }
    
    if ( SJBorderlineSideTop == ( _side & SJBorderlineSideTop ) ) {
        movePoint = CGPointMake(_startMargin, 0);
        addLineToPoint = CGPointMake(rect.size.width - _endMargin, 0);
        [self drawLineWithBezierPath:bezierPath MovePoint:movePoint addLineToPoint:addLineToPoint];
    }
    if ( SJBorderlineSideLeading == ( _side & SJBorderlineSideLeading ) ) {
        movePoint = CGPointMake(0, _startMargin);
        addLineToPoint = CGPointMake(0, rect.size.height - _endMargin);
        [self drawLineWithBezierPath:bezierPath MovePoint:movePoint addLineToPoint:addLineToPoint];
    }
    if ( SJBorderlineSideBottom == ( _side & SJBorderlineSideBottom ) ) {
        movePoint = CGPointMake(_startMargin, rect.size.height);
        addLineToPoint = CGPointMake(rect.size.width - _endMargin, rect.size.height);
        [self drawLineWithBezierPath:bezierPath MovePoint:movePoint addLineToPoint:addLineToPoint];
    }
    if ( SJBorderlineSideTrailing == ( _side & SJBorderlineSideTrailing ) ) {
        movePoint = CGPointMake(rect.size.width, _startMargin);
        addLineToPoint = CGPointMake(rect.size.width, rect.size.height - _endMargin);
        [self drawLineWithBezierPath:bezierPath MovePoint:movePoint addLineToPoint:addLineToPoint];
    }
}

- (void)drawLineWithBezierPath:(UIBezierPath *)bezierPath MovePoint:(CGPoint)movePoint addLineToPoint:(CGPoint)addLineToPoint {
    bezierPath.lineWidth = _lineWidth * 2;
    [bezierPath moveToPoint:movePoint];
    [bezierPath addLineToPoint:addLineToPoint];
    [_lineColor setStroke];
    [bezierPath strokeWithBlendMode:kCGBlendModeCopy alpha:1];
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
}

- (void)setSide:(SJBorderlineSide)side {
    _side = side;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
}

- (void)setStartMargin:(CGFloat)startMargin endMargin:(CGFloat)endMargin {
    _startMargin = startMargin;
    _endMargin = endMargin;
}

- (void)update {
    [self setNeedsDisplay];
}
@end
