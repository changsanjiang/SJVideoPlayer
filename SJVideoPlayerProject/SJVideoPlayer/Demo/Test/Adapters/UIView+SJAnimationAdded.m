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

- (void)setSjv_disappearDirection:(SJViewDisappearDirection)sjv_disappearDirection {
    objc_setAssociatedObject(self, @selector(sjv_disappearDirection), @(sjv_disappearDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (SJViewDisappearDirection)sjv_disappearDirection {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)sjv_disapear {
    if ( self.sjv_disappeared ) return;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch ( self.sjv_disappearDirection ) {
        case SJViewDisappearDirection_None: break;
        case SJViewDisappearDirection_Top: {
            transform = CGAffineTransformMakeTranslation(0, -self.bounds.size.height);
        }
            break;
        case SJViewDisappearDirection_Left: {
            transform = CGAffineTransformMakeTranslation(-self.bounds.size.width, 0);
        }
            break;
        case SJViewDisappearDirection_Bottom: {
            transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
        }
            break;
        case SJViewDisappearDirection_Right: {
            transform = CGAffineTransformMakeTranslation(self.bounds.size.width, 0);
        }
            break;
    }
    self.transform = transform;
    self.alpha = 0.001;
    self.sjv_disappeared = YES;
}

- (void)sjv_appear {
    if ( !self.sjv_disappeared ) return;
    self.transform = CGAffineTransformIdentity;
    self.alpha = 1;
    self.sjv_disappeared = NO;
}
@end
NS_ASSUME_NONNULL_END
