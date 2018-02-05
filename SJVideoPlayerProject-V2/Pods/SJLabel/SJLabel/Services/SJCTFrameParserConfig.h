//
//  SJCTFrameParserConfig.h
//  Test
//
//  Created by BlueDancer on 2017/12/13.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJCTFrameParserConfig : NSObject

+ (instancetype)defaultConfig;

@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) NSUInteger numberOfLines;
//@property (nonatomic, assign) NSLineBreakMode lineBreakMode;

@end

NS_ASSUME_NONNULL_END
