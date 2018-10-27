//
//  SJVideoPlayerMoreSettingSecondary.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSettingSecondary.h"
#import <objc/message.h>

@implementation SJVideoPlayerMoreSettingSecondary

+ (void)setTopTitleFontSize:(float)topTitleFontSize {
    objc_setAssociatedObject(self, @selector(topTitleFontSize), @(topTitleFontSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (float)topTitleFontSize {
    float fontSize = [objc_getAssociatedObject(self, _cmd) floatValue];
    if ( 0 != fontSize ) return fontSize;
    fontSize = 14;
    [self setTopTitleFontSize:fontSize];
    return fontSize;
}

@end
