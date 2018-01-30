//
//  SJStringParserConfig.h
//  SJLabel
//
//  Created by BlueDancer on 2017/12/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJCTFrameParserConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJStringParserConfig : SJCTFrameParserConfig

+ (UIFont *)defaultFont;

@property (nonatomic, strong, null_resettable) UIFont *font;
@property (nonatomic, strong, null_resettable) UIColor *textColor;
@property (nonatomic, assign) NSTextAlignment textAlignment;

@end

NS_ASSUME_NONNULL_END
