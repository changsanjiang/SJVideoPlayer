//
//  SJCTFrameParser.h
//  Test
//
//  Created by BlueDancer on 2017/12/13.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJCTData, SJCTFrameParserConfig, SJStringParserConfig;

@interface SJCTFrameParser : NSObject

+ (SJCTData *)parserContent:(NSString *)content config:(SJStringParserConfig *)config;

+ (SJCTData *)parserAttributedStr:(NSAttributedString *)content config:(SJCTFrameParserConfig *)config;

@end
