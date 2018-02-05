//
//  SJCTFrameParserConfig.m
//  Test
//
//  Created by BlueDancer on 2017/12/13.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJCTFrameParserConfig.h"

@implementation SJCTFrameParserConfig

+ (instancetype)defaultConfig {
    SJCTFrameParserConfig *defaultConfig = [SJCTFrameParserConfig new];
    defaultConfig.maxWidth = [UIScreen mainScreen].bounds.size.width;
    defaultConfig.lineSpacing = 0;
    defaultConfig.numberOfLines = 1;
//    defaultConfig.lineBreakMode = NSLineBreakByTruncatingTail;
    return defaultConfig;
}

@end
