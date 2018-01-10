//
//  SJLabel.h
//  SJAttributesFactory
//
//  Created by BlueDancer on 2017/12/14.
//  Copyright © 2017年 畅三江. All rights reserved.
//

#import <UIKit/UIView.h>
#import <UIKit/NSText.h>
#import <UIKit/NSParagraphStyle.h>

NS_ASSUME_NONNULL_BEGIN

@class SJCTData, SJStringParserConfig, SJCTFrameParserConfig;

@interface SJLabel : UIView

/*!
 *  [font, textColor] if set nil, its will use the default values.
 **/
- (instancetype)initWithText:(NSString * __nullable)text
                        font:(UIFont * __nullable)font
                   textColor:(UIColor * __nullable)textColor
                 lineSpacing:(CGFloat)lineSpacing
      userInteractionEnabled:(BOOL)userInteractionEnabled;

@property (nonatomic, copy, nullable) NSString *text;

@property (nonatomic, copy, nullable) NSAttributedString *attributedText;
/*!
 *  default is NSTextAlignmentLeft.
 **/
@property (nonatomic) NSTextAlignment textAlignment;

/*!
 *  default is 1.
 **/
@property (nonatomic) NSUInteger numberOfLines;

/*!
 *  default is NSLineBreakByTruncatingTail.
 **/
//@property (nonatomic) NSLineBreakMode lineBreakMode;

/*!
 *  default is systemFont(14).
 **/
@property (nonatomic, strong, null_resettable) UIFont *font;

/*!
 *  default is black.
 **/
@property (nonatomic, strong, null_resettable) UIColor *textColor;

@property(nonatomic) CGFloat preferredMaxLayoutWidth;

/*!
 *  default is 0.
 **/
@property (nonatomic) CGFloat lineSpacing;

@property (nonatomic, readonly) CGFloat height;


#pragma mark -

+ (SJCTData *)parserContent:(NSString *)content
                     config:(SJStringParserConfig *)config;

+ (SJCTData *)parserAttributedStr:(NSAttributedString *)content
                         maxWidth:(CGFloat)maxWidth
                    numberOfLines:(NSUInteger)numberOfLines
                      lineSpacing:(CGFloat)lineSpacing;

+ (SJCTData *)parserAttributedStr:(NSAttributedString *)content
                           config:(SJCTFrameParserConfig *)config;

@property (nonatomic, strong) SJCTData *drawData;

@end

NS_ASSUME_NONNULL_END
