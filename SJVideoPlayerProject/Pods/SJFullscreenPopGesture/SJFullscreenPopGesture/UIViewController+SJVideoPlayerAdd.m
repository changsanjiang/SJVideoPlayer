//
//  UIViewController+SJVideoPlayerAdd.m
//  SJBackGR
//
//  Created by BlueDancer on 2017/9/27.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "UIViewController+SJVideoPlayerAdd.h"
#import "UINavigationController+SJVideoPlayerAdd.h"
#import <objc/message.h>

@implementation UIViewController (SJVideoPlayerAdd)

- (UIGestureRecognizerState)sj_fullscreenGestureState {
    return self.navigationController.sj_fullscreenGestureState;
}

- (void)setSj_fadeArea:(NSArray<NSValue *> *)sj_fadeArea {
    objc_setAssociatedObject(self, @selector(sj_fadeArea), sj_fadeArea, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<NSValue *> *)sj_fadeArea {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_fadeAreaViews:(NSArray<UIView *> *)sj_fadeAreaViews {
    objc_setAssociatedObject(self, @selector(sj_fadeAreaViews), sj_fadeAreaViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<UIView *> *)sj_fadeAreaViews {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_viewWillBeginDragging:(void (^)(__kindof UIViewController *))sj_viewWillBeginDragging {
    objc_setAssociatedObject(self, @selector(sj_viewWillBeginDragging), sj_viewWillBeginDragging, OBJC_ASSOCIATION_COPY);
}

- (void (^)(__kindof UIViewController *))sj_viewWillBeginDragging {
    return objc_getAssociatedObject(self, _cmd);
}


- (void)setSj_viewDidDrag:(void (^)(__kindof UIViewController *))sj_viewDidDrag {
    objc_setAssociatedObject(self, @selector(sj_viewDidDrag), sj_viewDidDrag, OBJC_ASSOCIATION_COPY);
}

- (void (^)(__kindof UIViewController *))sj_viewDidDrag {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_viewDidEndDragging:(void (^)(__kindof UIViewController *))sj_viewDidEndDragging {
    objc_setAssociatedObject(self, @selector(sj_viewDidEndDragging), sj_viewDidEndDragging, OBJC_ASSOCIATION_COPY);
}

- (void (^)(__kindof UIViewController *))sj_viewDidEndDragging {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_DisableGestures:(BOOL)sj_DisableGestures {
    objc_setAssociatedObject(self, @selector(sj_DisableGestures), @(sj_DisableGestures), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sj_DisableGestures {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
