//
//  UIView+SJBaseVideoPlayerExtended.m
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/11/22.
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

- (void)setSj_x:(CGFloat)sj_x {
    CGRect frame = self.frame;
    frame.origin.x = sj_x;
    self.frame = frame;
}

- (CGFloat)sj_x {
    return self.frame.origin.x;
}

- (void)setSj_y:(CGFloat)sj_y {
    CGRect frame = self.frame;
    frame.origin.y = sj_y;
    self.frame = frame;
}

- (CGFloat)sj_y {
    return self.frame.origin.y;
}

- (void)setSj_w:(CGFloat)sj_w {
    CGRect frame = self.frame;
    frame.size.width = sj_w;
    self.frame = frame;
}

- (CGFloat)sj_w {
    return self.frame.size.width;
}

- (void)setSj_h:(CGFloat)sj_h {
    CGRect frame = self.frame;
    frame.size.height = sj_h;
    self.frame = frame;
}

- (CGFloat)sj_h {
    return self.frame.size.height;
}

- (void)setSj_size:(CGSize)sj_size {
    CGRect frame = self.frame;
    frame.size = sj_size;
    self.frame = frame;
}

- (CGSize)sj_size {
    return self.frame.size;
}
@end
NS_ASSUME_NONNULL_END
