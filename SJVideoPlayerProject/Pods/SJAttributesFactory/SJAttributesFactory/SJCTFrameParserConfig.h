//
//  SJCTFrameParserConfig.h
//  Test
//
//  Created by BlueDancer on 2017/12/13.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJCTFrameParserConfig : NSObject

@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) NSUInteger numberOfLines;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;

+ (CGFloat)fontSize:(UIFont *)font;

@end
