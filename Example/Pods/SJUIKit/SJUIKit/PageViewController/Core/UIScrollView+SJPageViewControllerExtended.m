//
//  UIScrollView+SJPageViewControllerExtended.m
//  Pods
//
//  Created by BlueDancer on 2020/2/5.
//

#import "UIScrollView+SJPageViewControllerExtended.h"
#import <objc/message.h>

@implementation UIView (SJPageViewControllerExtended)
- (void)sj_lock {
    objc_setAssociatedObject(self, @selector(sj_locked), @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)sj_unlock {
    objc_setAssociatedObject(self, @selector(sj_locked), @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)sj_locked {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end

@implementation UIScrollView (SJPageViewControllerExtended)
- (__kindof UIResponder *_Nullable)sj_page_lookupResponderForClass:(Class)cls {
    __kindof UIResponder *_Nullable cur = self;
    while ( cur != nil && ![cur isKindOfClass:cls] ) {
        cur = cur.nextResponder;
    }
    return cur;
}
@end
