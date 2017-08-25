//
//  SJVideoPlayerMoreSetting.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSetting.h"

#import <objc/message.h>

#import <UIKit/UIColor.h>


@implementation SJVideoPlayerMoreSetting

+ (UIColor *)titleColor {
    UIColor *color = objc_getAssociatedObject(self, _cmd);
    if ( color ) return color;
    color = [UIColor whiteColor];
    [self setTitleColor:color];
    return color;
}

+ (void)setTitleColor:(UIColor *)titleColor {
    objc_setAssociatedObject(self, @selector(titleColor), titleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (double)titleFontSize {
    double fontSize = [objc_getAssociatedObject(self, _cmd) doubleValue];
    if ( 0 != fontSize ) return fontSize;
    fontSize = 14;
    [self setTitleFontSize:fontSize];
    return fontSize;
}

+ (void)setTitleFontSize:(double)titleFontSize {
    objc_setAssociatedObject(self, @selector(titleFontSize), @(titleFontSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image clickedExeBlock:(void(^)(SJVideoPlayerMoreSetting *model))block; {
    self = [super init];
    if ( !self ) return self;
    self.title = title;
    self.image = image;
    self.clickedExeBlock = block;
    return self;
}


@end
