//
//  UIView+SJBaseVideoPlayerExtended.m
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2019/11/22.
//

#import "UIView+SJBaseVideoPlayerExtended.h"

NS_ASSUME_NONNULL_BEGIN
@implementation UIView (SJBaseVideoPlayerExtended)
///
/// 子视图是否显示中
///
- (BOOL)isViewAppeared:(UIView *_Nullable)childView {
    return !CGRectIsEmpty([self intersectionWithView:childView]);
}

///
/// 两者在window上的交叉点
///
- (CGRect)intersectionWithView:(UIView *)view {
    if ( view == nil || view.window == nil || self.window == nil ) return CGRectZero;
    CGRect rect1 = [view convertRect:view.bounds toView:self.window];
    CGRect rect2 = [self convertRect:self.bounds toView:self.window];
    CGRect intersection = CGRectIntersection(rect1, rect2);
    return (CGRectIsEmpty(intersection) || CGRectIsNull(intersection)) ? CGRectZero : intersection;
}

///
/// 寻找响应者
///
- (__kindof UIResponder *_Nullable)lookupResponderForClass:(Class)cls {
    __kindof UIResponder *_Nullable next = self.nextResponder;
    while ( next != nil && [next isKindOfClass:cls] == NO ) {
        next = next.nextResponder;
    }
    return next;
}
@end
NS_ASSUME_NONNULL_END
