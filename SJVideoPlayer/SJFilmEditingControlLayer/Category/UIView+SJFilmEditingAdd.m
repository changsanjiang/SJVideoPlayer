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

- (void)setDisappearTransform:(CGAffineTransform)disappearTransform {
    objc_setAssociatedObject(self, @selector(disappearTransform), [NSValue valueWithCGAffineTransform:disappearTransform], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGAffineTransform)disappearTransform {
    return [(NSValue *)objc_getAssociatedObject(self, _cmd) CGAffineTransformValue];
}

- (void)setDisappearType:(SJViewDisappearType)disappearType {
    objc_setAssociatedObject(self, @selector(disappearType), @(disappearType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJViewDisappearType)disappearType {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setAppearState:(BOOL)appearState {
    objc_setAssociatedObject(self, @selector(appearState), @(appearState), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)appearState {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setAppearExeBlock:(void (^)(__kindof UIView * _Nonnull))appearExeBlock {
    objc_setAssociatedObject(self, @selector(appearExeBlock), appearExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof UIView * _Nonnull))appearExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDisappearExeBlock:(void (^)(__kindof UIView * _Nonnull))disappearExeBlock {
    objc_setAssociatedObject(self, @selector(disappearExeBlock), disappearExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof UIView * _Nonnull))disappearExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)appear {
    [self __changeState:YES];
}

- (void)disappear {
    [self __changeState:NO];
}

- (void)__changeState:(BOOL)show {
    if ( SJViewDisappearType_All == (self.disappearType & SJViewDisappearType_All) ) {
        self.disappearType = SJViewDisappearType_Alpha | SJViewDisappearType_Transform;
    }
    
    if ( SJViewDisappearType_Transform == (self.disappearType & SJViewDisappearType_Transform) ) {
        if ( show ) {
            self.transform = CGAffineTransformIdentity;
        }
        else {
            self.transform = self.disappearTransform;
        }
    }
    
    if ( SJViewDisappearType_Alpha == (self.disappearType & SJViewDisappearType_Alpha) ) {
        if ( show ) {
            self.alpha = 1;
        }
        else {
            self.alpha = 0.001;
        }
    }

    self.appearState = show;
    
    if ( show ) {
        if ( self.appearExeBlock ) self.appearExeBlock(self);
    }
    else {
        if ( self.disappearExeBlock ) self.disappearExeBlock(self);
    }

}

@end
