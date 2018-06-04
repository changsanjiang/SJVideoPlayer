//
//  SJAttributesRecorder.h
//  SJAttributesFactory
//
//  Created by BlueDancer on 2018/1/27.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJStrokeAttribute: NSObject<NSCopying, NSMutableCopying>
@property (nonatomic, assign) double value;
@property (nonatomic, strong) UIColor *color;
+ (instancetype)strokeWithValue:(double)value color:(UIColor *)color;
- (instancetype)initWithValue:(double)value color:(UIColor *)color;
@end


#pragma mark -
@interface SJUnderlineAttribute: NSObject<NSCopying, NSMutableCopying>
@property (nonatomic, assign) NSUnderlineStyle value;
@property (nonatomic, strong) UIColor *color;
+ (instancetype)underLineWithStyle:(NSUnderlineStyle)value color:(UIColor *)color;
- (instancetype)initWithStyle:(NSUnderlineStyle)value color:(UIColor *)color;
@end

#pragma mark -
@interface SJAttributesRecorder: NSObject<NSCopying>
@property (nonatomic, assign) NSRange range;
@property (nonatomic, strong, nullable) UIFont *font;
@property (nonatomic, strong, nullable) UIColor *textColor;
@property (nonatomic, assign) double expansion;
@property (nonatomic, strong, nullable) NSShadow *shadow;
@property (nonatomic, strong, nullable) UIColor *backgroundColor;
@property (nonatomic, strong, nullable) SJUnderlineAttribute *underLine;
@property (nonatomic, strong, nullable) SJUnderlineAttribute *strikethrough;
@property (nonatomic, strong, nullable) SJStrokeAttribute *stroke;
@property (nonatomic, assign) double obliqueness;
@property (nonatomic, assign) double letterSpacing;
@property (nonatomic, assign) double offset;
@property (nonatomic, assign) BOOL link;
#pragma mark -
@property (nonatomic, strong) NSMutableParagraphStyle *paragraphStyleM;
@property (nonatomic, assign) double lineSpacing;
@property (nonatomic, assign) double paragraphSpacing;
@property (nonatomic, assign) double paragraphSpacingBefore;
@property (nonatomic, assign) double firstLineHeadIndent;
@property (nonatomic, assign) double headIndent;
@property (nonatomic, assign) double tailIndent;
@property (nonatomic, assign) double alignment;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
- (void)addAttributes:(NSMutableAttributedString *)attrStr;
- (void)removeAttribute:(NSAttributedStringKey)attributedStringKey;
- (NSArray<NSString *> *)properties;
@end

NS_ASSUME_NONNULL_END
