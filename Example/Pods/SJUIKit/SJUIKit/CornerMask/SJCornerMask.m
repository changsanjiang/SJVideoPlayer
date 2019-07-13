//
//  SJRoundCornerMask.m
//  Pods
//
//  Created by 畅三江 on 2018/7/17.
//

#import "SJCornerMask.h"
#import "NSObject+SJObserverHelper.h"

NS_ASSUME_NONNULL_BEGIN
void
SJCornerMaskSetRectCorner(__kindof UIView *view, UIRectCorner corners, CGFloat radius, CGFloat borderWidth, UIColor *_Nullable borderColor) {
    if ( view == nil )
        return;
    if ( view.layer.mask == nil && corners != 0 && radius != 0) {
        CAShapeLayer *mask = [[CAShapeLayer alloc] init];
        view.layer.mask = mask;
        
        CAShapeLayer *_Nullable border = nil;
        if ( borderWidth != 0 && borderColor != nil ) {
            border = [[CAShapeLayer alloc] init];
            border.strokeColor = borderColor.CGColor;
            border.lineWidth = borderWidth;
            border.fillColor = UIColor.clearColor.CGColor;
            [view.layer addSublayer:border];
        }
        
        SJKVOObservedChangeHandler handler = ^(__kindof UIView *target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            CGRect bounds = target.bounds;
            if ( !CGSizeEqualToSize(CGSizeZero, bounds.size) ) {
                mask.frame = bounds;
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
                mask.path = path.CGPath;
                
                if ( border != nil ) {
                    border.frame = bounds;
                    border.path = mask.path;
                }
            }
        };

        sjkvo_observe(view, @"frame", handler);
        sjkvo_observe(view, @"bounds", handler);
    }
}

/// rect corner
void __attribute__((overloadable))
SJCornerMaskSetRectCorner(__kindof UIView *view, UIRectCorner corners, CGFloat radius) {
    SJCornerMaskSetRectCorner(view, corners, radius, 0, nil);
}

/// round & border
void
SJCornerMaskSetRound(__kindof UIView *view, CGFloat borderWidth, UIColor *_Nullable borderColor) {
    if ( view == nil )
        return;
    if ( view.layer.mask == nil ) {
        CAShapeLayer *mask = [[CAShapeLayer alloc] init];
        view.layer.mask = mask;
        
        CAShapeLayer *_Nullable border = nil;
        if ( borderWidth != 0 && borderColor != nil ) {
            border = [[CAShapeLayer alloc] init];
            border.strokeColor = borderColor.CGColor;
            border.lineWidth = borderWidth;
            border.fillColor = UIColor.clearColor.CGColor;
            [view.layer addSublayer:border];
        }
        
        SJKVOObservedChangeHandler handler = ^(__kindof UIView *target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            CGRect bounds = target.bounds;
            if ( !CGSizeEqualToSize(CGSizeZero, bounds.size) ) {
                mask.frame = bounds;
                UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(bounds.size.width * 0.5, bounds.size.width * 0.5) radius:bounds.size.width * 0.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
                mask.path = path.CGPath;
                
                if ( border != nil) {
                    border.frame = bounds;
                    border.path = mask.path;
                }
            }
        };
        
        sjkvo_observe(view, @"frame", handler);
        sjkvo_observe(view, @"bounds", handler);
    }

}

/// round
void __attribute__((overloadable))
SJCornerMaskSetRound(__kindof UIView *view) {
    SJCornerMaskSetRound(view, 0, nil);
}
NS_ASSUME_NONNULL_END
