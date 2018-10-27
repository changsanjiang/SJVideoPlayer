//
//  UIView+SJAnimationAdded.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/23.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "UIView+SJAnimationAdded.h"
#import <objc/message.h> 

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
    if ( self.sjv_disappeared ) return;
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
            transform = CGAffineTransformMakeScale(0.001f, 1);
        }
            break;
        case SJViewDisappearAnimation_VerticalScaling: {
            transform = CGAffineTransformMakeScale(1, 0.001f);
        }
            break;
    }
    self.transform = transform;
    if ( !self.sjv_doNotSetAlpha ) self.alpha = 0.001;
    self.sjv_disappeared = YES;
}

- (void)sjv_appear {
    if ( !self.sjv_disappeared ) return;
    self.transform = CGAffineTransformIdentity;
    self.alpha = 1;
    self.sjv_disappeared = NO;
}

- (void)setSjv_doNotSetAlpha:(BOOL)sjv_doNotSetAlpha {
    objc_setAssociatedObject(self, @selector(sjv_doNotSetAlpha), @(sjv_doNotSetAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sjv_doNotSetAlpha {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end
NS_ASSUME_NONNULL_END
