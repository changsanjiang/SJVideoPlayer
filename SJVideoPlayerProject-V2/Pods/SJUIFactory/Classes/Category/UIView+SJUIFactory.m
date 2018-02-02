//
//  UIView+SJUIFactory.m
//  SJUIFactory
//
//  Created by BlueDancer on 2017/11/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "UIView+SJUIFactory.h"
#import <objc/message.h>

@implementation UIView (SJUIFactory)

- (void)setCsj_x:(CGFloat)csj_x {
    CGRect frame    = self.frame;
    frame.origin.x  = csj_x;
    self.frame      = frame;
}
- (CGFloat)csj_x {
    return self.frame.origin.x;
}


- (void)setCsj_y:(CGFloat)csj_y {
    CGRect frame    = self.frame;
    frame.origin.y  = csj_y;
    self.frame      = frame;
}
- (CGFloat)csj_y {
    return self.frame.origin.y;
}


- (void)setCsj_w:(CGFloat)csj_w {
    CGRect frame        = self.frame;
    frame.size.width    = csj_w;
    self.frame          = frame;
}
- (CGFloat)csj_w {
    return self.frame.size.width;
}


- (void)setCsj_h:(CGFloat)csj_h {
    CGRect frame        = self.frame;
    frame.size.height   = csj_h;
    self.frame          = frame;
}
- (CGFloat)csj_h {
    return self.frame.size.height;
}

- (void)setCsj_size:(CGSize)csj_size {
    CGRect frame        = self.frame;
    frame.size          = csj_size;
    self.frame          = frame;
    
}
- (CGSize)csj_size {
    return self.frame.size;
}

- (void)setCsj_centerX:(CGFloat)csj_centerX {
    CGPoint center  = self.center;
    center.x        = csj_centerX;
    self.center     = center;
}
- (CGFloat)csj_centerX {
    return self.center.x;
}


- (void)setCsj_centerY:(CGFloat)csj_centerY {
    CGPoint center  = self.center;
    center.y        = csj_centerY;
    self.center     = center;
}
- (CGFloat)csj_centerY {
    return self.center.y;
}

- (CGFloat)csj_maxX {
    return self.csj_x + self.csj_w;
}

- (CGFloat)csj_maxY {
    return self.csj_y + self.csj_h;
}

- (UIViewController *)csj_viewController {
    UIResponder *responder = self.nextResponder;
    while ( ![responder isKindOfClass:[UIViewController class]] ) {
        responder = responder.nextResponder;
        if ( [responder isMemberOfClass:[UIResponder class]] || !responder ) return nil;
    }
    return (UIViewController *)responder;
}

@end

