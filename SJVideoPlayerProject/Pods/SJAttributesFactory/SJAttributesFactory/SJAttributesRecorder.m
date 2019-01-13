//
//  SJAttributesRecorder.m
//  SJAttributesFactory
//
//  Created by BlueDancer on 2018/1/27.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJAttributesRecorder.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
#define __Set_Property(__value__)   \
if ( __value__ == _##__value__ ) \
    return; \
 \
_##__value__ = __value__;   \
if ( _propertyDidChangeExeBlock ) \
    _propertyDidChangeExeBlock(self);

#define __Set_Paragraph_Property(__value__)  \
if ( __value__ == self.paragraphStyleM.__value__ ) \
    return; \
\
self.paragraphStyleM.__value__ = __value__; \
if ( _propertyDidChangeExeBlock ) \
    _propertyDidChangeExeBlock(self);

@implementation SJStrokeAttribute
+ (instancetype)strokeWithValue:(double)value color:(UIColor *)color {
    return [[self alloc] initWithValue:value color:color];
}
- (instancetype)initWithValue:(double)value color:(UIColor *)color {
    self = [super init];
    if ( !self ) return nil;
    _value = value;
    _color = color;
    return self;
}

- (id)mutableCopyWithZone:(NSZone *_Nullable)zone {
    return [SJStrokeAttribute strokeWithValue:_value color:_color];
}
@end

#pragma mark -
@implementation SJUnderlineAttribute
+ (instancetype)underLineWithStyle:(NSUnderlineStyle)value color:(UIColor *)color {
    return [[self alloc] initWithStyle:value color:color];
}
- (instancetype)initWithStyle:(NSUnderlineStyle)value color:(UIColor *)color {
    self = [super init];
    if ( !self ) return nil;
    _value = value;
    _color = color;
    return self;
}

- (id)mutableCopyWithZone:(NSZone *_Nullable)zone {
    return [SJUnderlineAttribute underLineWithStyle:_value color:_color];
}
@end

#pragma mark -
@implementation SJAttributesRecorder
- (void)setFont:(UIFont *_Nullable)font {
    __Set_Property(font);
}

- (void)setTextColor:(UIColor *_Nullable)textColor {
    __Set_Property(textColor);
}

- (void)setExpansion:(double)expansion {
    __Set_Property(expansion);
}

- (void)setShadow:(NSShadow *_Nullable)shadow {
    __Set_Property(shadow);
}

- (void)setBackgroundColor:(UIColor *_Nullable)backgroundColor {
    __Set_Property(backgroundColor);
}

- (void)setUnderLine:(SJUnderlineAttribute *_Nullable)underLine {
    __Set_Property(underLine);
}

- (void)setStrikethrough:(SJUnderlineAttribute *_Nullable)strikethrough {
    __Set_Property(strikethrough);
}

- (void)setStroke:(SJStrokeAttribute *_Nullable)stroke {
    __Set_Property(stroke);
}

- (void)setObliqueness:(double)obliqueness {
    __Set_Property(obliqueness);
}

- (void)setLetterSpacing:(double)letterSpacing {
    __Set_Property(letterSpacing);
}

- (void)setOffset:(double)offset {
    __Set_Property(offset);
}

- (void)setLink:(BOOL)link {
    __Set_Property(link);
}

@synthesize paragraphStyleM = _paragraphStyleM;
- (void)setParagraphStyleM:(NSMutableParagraphStyle *_Nullable)paragraphStyleM {
    if ( [paragraphStyleM isMemberOfClass:[NSParagraphStyle class]] ) paragraphStyleM = paragraphStyleM.mutableCopy;
    __Set_Property(paragraphStyleM);
}
- (NSMutableParagraphStyle *)paragraphStyleM {
    if ( _paragraphStyleM ) return _paragraphStyleM;
    _paragraphStyleM = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    return _paragraphStyleM;
}
- (void)setLineSpacing:(double)lineSpacing {
    __Set_Paragraph_Property(lineSpacing);
}
- (double)lineSpacing {return self.paragraphStyleM.lineSpacing;}

- (void)setParagraphSpacing:(double)paragraphSpacing {
   __Set_Paragraph_Property(paragraphSpacing);
}
- (double)paragraphSpacing {return self.paragraphStyleM.paragraphSpacing;}

- (void)setParagraphSpacingBefore:(double)paragraphSpacingBefore {
    __Set_Paragraph_Property(paragraphSpacingBefore);
}
- (double)paragraphSpacingBefore {return self.paragraphStyleM.paragraphSpacingBefore;}

- (void)setFirstLineHeadIndent:(double)firstLineHeadIndent {
    __Set_Paragraph_Property(firstLineHeadIndent);
}
- (double)firstLineHeadIndent {return self.paragraphStyleM.firstLineHeadIndent;}

- (void)setHeadIndent:(double)headIndent {
    __Set_Paragraph_Property(headIndent);
}
- (double)headIndent {return self.paragraphStyleM.headIndent;}

- (void)setTailIndent:(double)tailIndent {
    __Set_Paragraph_Property(tailIndent);
}
- (double)tailIndent {return self.paragraphStyleM.tailIndent;}

@synthesize alignment = _alignment;
- (void)setAlignment:(NSNumber *_Nullable)ali {
    _alignment = ali;
    NSTextAlignment alignment = [ali integerValue];
    __Set_Paragraph_Property(alignment);
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    __Set_Paragraph_Property(lineBreakMode);
}
- (NSLineBreakMode)lineBreakMode {return self.paragraphStyleM.lineBreakMode;}

- (id)mutableCopyWithZone:(NSZone *_Nullable)zone {
    SJAttributesRecorder *obj = [SJAttributesRecorder new];
    obj.range = _range;
    obj.font = _font;
    obj.textColor = _textColor;
    obj.expansion = _expansion;
    obj.shadow = _shadow;
    obj.backgroundColor = _backgroundColor;
    obj.underLine = _underLine;
    obj.strikethrough = _strikethrough;
    obj.stroke = _stroke;
    obj.obliqueness = _obliqueness;
    obj.letterSpacing = _letterSpacing;
    obj.offset = _offset;
    obj.link = _link;
    obj.paragraphStyleM = _paragraphStyleM;
    return obj;
}
@end
NS_ASSUME_NONNULL_END
