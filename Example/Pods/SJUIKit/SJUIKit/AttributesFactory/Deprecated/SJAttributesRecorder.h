//
//  SJAttributesRecorder.h
//  SJAttributesFactory
//
//  Created by 畅三江 on 2018/1/27.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>

// - deprecated (use `NSAttributedString+SJMake.h`).
// - 已弃用, 未来可能会删除

NS_ASSUME_NONNULL_BEGIN
#pragma mark -
@interface SJStrokeAttribute: NSObject<NSMutableCopying>
@property (nonatomic) double value;
@property (nonatomic, strong) UIColor *color;
+ (instancetype)strokeWithValue:(double)value color:(UIColor *)color;
- (instancetype)initWithValue:(double)value color:(UIColor *)color;
@end


#pragma mark -
@interface SJUnderlineAttribute: NSObject<NSMutableCopying>
@property (nonatomic) NSUnderlineStyle value;
@property (nonatomic, strong) UIColor *color;
+ (instancetype)underLineWithStyle:(NSUnderlineStyle)value color:(UIColor *)color;
- (instancetype)initWithStyle:(NSUnderlineStyle)value color:(UIColor *)color;
@end

#pragma mark -
@interface SJAttributesRecorder: NSObject<NSMutableCopying>
@property (nonatomic) NSRange range;
@property (nonatomic, strong, nullable) UIFont *font;
@property (nonatomic, strong, nullable) UIColor *textColor;
@property (nonatomic) double expansion;
@property (nonatomic, strong, nullable) NSShadow *shadow;
@property (nonatomic, strong, nullable) UIColor *backgroundColor;
@property (nonatomic, strong, nullable) SJUnderlineAttribute *underLine;
@property (nonatomic, strong, nullable) SJUnderlineAttribute *strikethrough;
@property (nonatomic, strong, nullable) SJStrokeAttribute *stroke;
@property (nonatomic) double obliqueness;
@property (nonatomic) double letterSpacing;
@property (nonatomic) double offset;
@property (nonatomic) BOOL link;

@property (nonatomic, strong, null_resettable) NSMutableParagraphStyle *paragraphStyleM;
@property (nonatomic) double lineSpacing;
@property (nonatomic) double paragraphSpacing;
@property (nonatomic) double paragraphSpacingBefore;
@property (nonatomic) double firstLineHeadIndent;
@property (nonatomic) double headIndent;
@property (nonatomic) double tailIndent;
@property (nonatomic, strong, nullable) NSNumber *alignment;
@property (nonatomic) NSLineBreakMode lineBreakMode;

@property (nonatomic, copy, nullable) void(^propertyDidChangeExeBlock)(SJAttributesRecorder *recorder);
@end
NS_ASSUME_NONNULL_END
