//
//  UIScrollView+SJPageViewControllerExtended.m
//  Pods
//
//  Created by BlueDancer on 2020/2/5.
//

#import "UIScrollView+SJPageViewControllerExtended.h"
#import <objc/message.h>

@implementation UIScrollView (SJPageViewControllerExtended)
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
