//
//  UIView+SJFilmEditingAdd.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/5.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "UIView+SJFilmEditingAdd.h"
#import <objc/message.h>

@implementation UIView (SJFilmEditingAdd)

- (void)setSj_disappearTransform:(CGAffineTransform)sj_disappearTransform {
    objc_setAssociatedObject(self, @selector(sj_disappearTransform), [NSValue valueWithCGAffineTransform:sj_disappearTransform], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGAffineTransform)sj_disappearTransform {
    return [(NSValue *)objc_getAssociatedObject(self, _cmd) CGAffineTransformValue];
}

- (void)setSj_disappearType:(SJViewDisappearType)sj_disappearType {
    objc_setAssociatedObject(self, @selector(sj_disappearType), @(sj_disappearType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJViewDisappearType)sj_disappearType {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setSj_appearState:(BOOL)sj_appearState {
    objc_setAssociatedObject(self, @selector(sj_appearState), @(sj_appearState), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sj_appearState {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSj_appearExeBlock:(void (^)(__kindof UIView * _Nonnull))sj_appearExeBlock {
    objc_setAssociatedObject(self, @selector(sj_appearExeBlock), sj_appearExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof UIView * _Nonnull))sj_appearExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_disappearExeBlock:(void (^)(__kindof UIView * _Nonnull))sj_disappearExeBlock {
    objc_setAssociatedObject(self, @selector(sj_disappearExeBlock), sj_disappearExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof UIView * _Nonnull))sj_disappearExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)sj_appear {
    [self sj_changeState:YES];
}

- (void)sj_disappear {
    [self sj_changeState:NO];
}

- (void)sj_changeState:(BOOL)show {
    if ( SJViewDisappearType_All == (self.sj_disappearType & SJViewDisappearType_All) ) {
        self.sj_disappearType = SJViewDisappearType_Alpha | SJViewDisappearType_Transform;
    }
    
    if ( SJViewDisappearType_Transform == (self.sj_disappearType & SJViewDisappearType_Transform) ) {
        if ( show ) {
            self.transform = CGAffineTransformIdentity;
        }
        else {
            self.transform = self.sj_disappearTransform;
        }
    }
    
    if ( SJViewDisappearType_Alpha == (self.sj_disappearType & SJViewDisappearType_Alpha) ) {
        if ( show ) {
            self.alpha = 1;
        }
        else {
            self.alpha = 0.001;
        }
    }

    self.sj_appearState = show;
    
    if ( show ) {
        if ( self.sj_appearExeBlock ) self.sj_appearExeBlock(self);
    }
    else {
        if ( self.sj_disappearExeBlock ) self.sj_disappearExeBlock(self);
    }

}

@end
