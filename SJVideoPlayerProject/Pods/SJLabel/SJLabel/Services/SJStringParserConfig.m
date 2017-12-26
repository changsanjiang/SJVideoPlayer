//
//  SJStringParserConfig.m
//  SJLabel
//
//  Created by BlueDancer on 2017/12/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJStringParserConfig.h"

@implementation SJStringParserConfig

+ (SJStringParserConfig *)defaultConfig {
    SJStringParserConfig *defaultConfig = [SJStringParserConfig new];
    defaultConfig.maxWidth = [UIScreen mainScreen].bounds.size.width;
    defaultConfig.lineSpacing = 0;
    defaultConfig.numberOfLines = 1;

    defaultConfig.font = [UIFont systemFontOfSize:14];
    defaultConfig.textColor = [UIColor blackColor];
    defaultConfig.textAlignment = NSTextAlignmentLeft;
    return defaultConfig;
}

@end
