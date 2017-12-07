//
//  SJVideoPlayerMoreSetting.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSetting.h"
#import <objc/message.h>
#import <UIKit/UIKit.h>

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

+ (float)titleFontSize {
    float fontSize = [objc_getAssociatedObject(self, _cmd) floatValue];
    if ( 0 != fontSize ) return fontSize;
    fontSize = 12;
    [self setTitleFontSize:fontSize];
    return fontSize;
}

+ (void)setTitleFontSize:(float)titleFontSize {
    objc_setAssociatedObject(self, @selector(titleFontSize), @(titleFontSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image clickedExeBlock:(void(^)(SJVideoPlayerMoreSetting *model))block {
    return [self initWithTitle:title image:image showTowSetting:NO twoSettingTopTitle:@"" twoSettingItems:@[] clickedExeBlock:block];
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image showTowSetting:(BOOL)showTowSetting twoSettingTopTitle:(nonnull NSString *)twoSettingTopTitle twoSettingItems:(nonnull NSArray<SJVideoPlayerMoreSettingSecondary *> *)items clickedExeBlock:(nonnull void (^)(SJVideoPlayerMoreSetting * _Nonnull))block {
    self = [super init];
    if ( !self ) return self;
    self.title = title;
    self.image = image;
    self.twoSettingTopTitle = twoSettingTopTitle;
    self.showTowSetting = showTowSetting;
    self.twoSettingItems = items;
    self.clickedExeBlock = block;
    return self;
}

@end
