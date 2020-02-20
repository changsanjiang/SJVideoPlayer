//
//  SJRoundCornerMask.m
//  Pods
//
//  Created by 畅三江 on 2018/7/17.
//

#import "SJCornerMask.h"
#import "NSObject+SJObserverHelper.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIView (SJCornerMaskExtended)
@property (nonatomic, strong, nullable) CAShapeLayer *sj_borderLayer;
@end

@implementation UIView (SJCornerMaskExtended)
- (void)setSj_borderLayer:(nullable CAShapeLayer *)sj_borderLayer {
    objc_setAssociatedObject(self, @selector(sj_borderLayer), sj_borderLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable CAShapeLayer *)sj_borderLayer {
    return objc_getAssociatedObject(self, _cmd);
}
@end

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
            view.sj_borderLayer = border;
            [view.layer addSublayer:border];
        }
        
        __block SJKVOObservedChangeHandler handler = ^(__kindof UIView *target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            CAShapeLayer *_Nullable border = target.sj_borderLayer;
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
    
    CAShapeLayer *_Nullable border = view.sj_borderLayer;
    border.strokeColor = borderColor.CGColor;
    border.lineWidth = borderWidth;
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
            view.sj_borderLayer = border;
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
    
    CAShapeLayer *_Nullable border = view.sj_borderLayer;
    border.strokeColor = borderColor.CGColor;
    border.lineWidth = borderWidth;
}

/// round
void __attribute__((overloadable))
SJCornerMaskSetRound(__kindof UIView *view) {
    SJCornerMaskSetRound(view, 0, nil);
}
NS_ASSUME_NONNULL_END
