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
- (BOOL)isViewAppeared:(UIView *_Nullable)childView insets:(UIEdgeInsets)insets {
    if ( !childView ) return NO;
    return !CGRectIsEmpty([self intersectionWithView:childView insets:insets]);
}

///
/// 两者在window上的交叉点
///
- (CGRect)intersectionWithView:(UIView *)view insets:(UIEdgeInsets)insets {
    if ( view == nil || view.window == nil || self.window == nil ) return CGRectZero;
    CGRect rect1 = [view convertRect:view.bounds toView:self.window];
    CGRect rect2 = [self convertRect:self.bounds toView:self.window];
    rect1 = UIEdgeInsetsInsetRect(rect1, insets);
    rect2 = UIEdgeInsetsInsetRect(rect2, insets);
    
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

///
/// 寻找实现了该协议的视图, 包括自己
///
- (__kindof UIView *_Nullable)viewWithProtocol:(Protocol *)protocol tag:(NSInteger)tag {
    if ( [self conformsToProtocol:protocol] && self.tag == tag ) {
        return self;
    }
    
    for ( UIView *subview in self.subviews ) {
        UIView *target = [subview viewWithProtocol:protocol tag:tag];
        if ( target != nil ) return target;
    }
    return nil;
}


///
/// 对应视图是否在window中显示
///
- (BOOL)isViewAppearedWithProtocol:(Protocol *)protocol tag:(NSInteger)tag insets:(UIEdgeInsets)insets {
   return [self isViewAppeared:[self viewWithProtocol:protocol tag:tag] insets:insets];
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
