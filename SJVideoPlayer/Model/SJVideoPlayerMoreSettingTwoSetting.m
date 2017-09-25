//
//  SJVideoPlayerMoreSettingTwoSetting.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSettingTwoSetting.h"
#import <objc/message.h>


@implementation SJVideoPlayerMoreSettingTwoSetting

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
