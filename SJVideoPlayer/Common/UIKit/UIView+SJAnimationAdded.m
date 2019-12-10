//
//  UIView+SJAnimationAdded.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/23.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "UIView+SJAnimationAdded.h"
#import <objc/message.h>
#import "SJVideoPlayerConst.h"

NS_ASSUME_NONNULL_BEGIN
@implementation UIView (SJAnimationAdded)
- (void)setSjv_disappeared:(BOOL)sjv_disappeared {
    objc_setAssociatedObject(self, @selector(sjv_disappeared), @(sjv_disappeared), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)sjv_disappeared {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSjv_disappearDirection:(SJViewDisappearAnimation)sjv_disappearDirection {
    objc_setAssociatedObject(self, @selector(sjv_disappearDirection), @(sjv_disappearDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (SJViewDisappearAnimation)sjv_disappearDirection {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)sjv_disapear {
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch ( self.sjv_disappearDirection ) {
        case SJViewDisappearAnimation_None: break;
        case SJViewDisappearAnimation_Top: {
            transform = CGAffineTransformMakeTranslation(0, -self.bounds.size.height);
        }
            break;
        case SJViewDisappearAnimation_Left: {
            transform = CGAffineTransformMakeTranslation(-self.bounds.size.width, 0);
        }
            break;
        case SJViewDisappearAnimation_Bottom: {
            transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
        }
            break;
        case SJViewDisappearAnimation_Right: {
            transform = CGAffineTransformMakeTranslation(self.bounds.size.width, 0);
        }
            break;
        case SJViewDisappearAnimation_HorizontalScaling: {
            transform = CGAffineTransformMakeScale(0.001, 1);
        }
            break;
        case SJViewDisappearAnimation_VerticalScaling: {
            transform = CGAffineTransformMakeScale(1, 0.001);
        }
            break;
    }
    self.transform = transform;
    self.alpha = 0.001;
    self.sjv_disappeared = YES;
}

- (void)sjv_appear { 
    self.transform = CGAffineTransformIdentity;
    self.alpha = 1;
    self.sjv_disappeared = NO;
}
@end

#pragma mark -

BOOL sj_view_isDisappeared(UIView *view) {
    if ( !view )
        return NO;
    return view.sjv_disappeared;
}
void __attribute__((overloadable))
sj_view_makeAppear(UIView *view, BOOL animated, void(^_Nullable completionHandler)(void)) {
    if ( !view ) return;
    sj_view_makeAppear(@[view], animated, completionHandler);
}
void __attribute__((overloadable))
sj_view_makeDisappear(UIView *view, BOOL animated, void(^_Nullable completionHandler)(void)) {
    if ( !view ) return;
    sj_view_makeDisappear(@[view], animated, completionHandler);
}
void sj_view_initializes(UIView *view) {
    view.alpha = 0.001;
}

void __attribute__((overloadable)) sj_view_makeAppear(UIView *view, BOOL animated) {
    sj_view_makeAppear(view, animated, nil);
}
void __attribute__((overloadable)) sj_view_makeDisappear(UIView *view, BOOL animated) {
    sj_view_makeDisappear(view, animated, nil);
}
void __attribute__((overloadable)) sj_view_initializes(NSArray<UIView *> *views) {
    for ( UIView *view in views ) {
        sj_view_initializes(view);
    }
}

void __attribute__((overloadable))
sj_view_makeAppear(NSArray<UIView *> *views, BOOL animated) {
    sj_view_makeAppear(views, animated, nil);
}
void
sj_view_makeAppear(NSArray<UIView *> *views, BOOL animated, void(^_Nullable completionHandler)(void)) {
    if ( views.count == 0 ) return;
    for ( UIView *view in views ) {
        view.sjv_disappeared = NO;
        [UIView animateWithDuration:0 animations:^{} completion:^(BOOL finished) {
            if ( animated ) {
                [UIView animateWithDuration:CommonAnimaDuration animations:^{
                    [view sjv_appear];
                } completion:^(BOOL finished) {
                    if ( view == views.lastObject && completionHandler ) completionHandler();
                }];
            }
            else {
                [view sjv_appear];
                if ( view == views.lastObject && completionHandler ) completionHandler();
            }
        }];
    }
}

void __attribute__((overloadable))
sj_view_makeDisappear(NSArray<UIView *> *views, BOOL animated) {
    sj_view_makeDisappear(views, animated, nil);
}
void
sj_view_makeDisappear(NSArray<UIView *> *views, BOOL animated, void(^_Nullable completionHandler)(void)) {
    if ( views.count == 0 ) return;
    for ( UIView *view in views ) {
        view.sjv_disappeared = YES;
        [UIView animateWithDuration:0 animations:^{} completion:^(BOOL finished) {
            if ( animated ) {
                [UIView animateWithDuration:CommonAnimaDuration animations:^{
                    [view sjv_disapear];
                } completion:^(BOOL finished) {
                    if ( view == views.lastObject && completionHandler ) completionHandler();
                }];
            }
            else {
                [view sjv_disapear];
                if ( view == views.lastObject && completionHandler ) completionHandler();
            }
        }];
    }
}
NS_ASSUME_NONNULL_END
