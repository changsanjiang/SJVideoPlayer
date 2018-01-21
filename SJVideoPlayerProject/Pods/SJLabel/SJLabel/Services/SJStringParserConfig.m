//
//  SJStringParserConfig.m
//  SJLabel
//
//  Created by BlueDancer on 2017/12/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJStringParserConfig.h"

@implementation SJStringParserConfig

+ (UIFont *)defaultFont {
    return [UIFont systemFontOfSize:14];
}

+ (SJStringParserConfig *)defaultConfig {
    SJStringParserConfig *defaultConfig = [SJStringParserConfig new];
    defaultConfig.maxWidth = [UIScreen mainScreen].bounds.size.width;
    defaultConfig.lineSpacing = 0;
    defaultConfig.numberOfLines = 1;
    defaultConfig.textAlignment = NSTextAlignmentLeft;
    return defaultConfig;
}

- (UIFont *)font {
    if ( !_font ) return [[self class] defaultFont];
    return _font;
}

- (UIColor *)textColor {
    if ( !_textColor ) return [UIColor blackColor];
    return _textColor;
}
@end
