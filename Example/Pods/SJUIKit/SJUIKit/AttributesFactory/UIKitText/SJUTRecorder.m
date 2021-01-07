//
//  SJUTRecorder.m
//  AttributesFactory
//
//  Created by 畅三江 on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJUTRecorder.h"
#import <CoreText/CTStringAttributes.h>
#import "SJUTUtils.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJUTStroke
@end
@implementation SJUTDecoration
@end
@implementation SJUTImageAttachment
@end
@implementation SJUTReplace
@end

@implementation SJUTRecorder

static NSArray<NSAttributedStringKey> *SJUT_Keys;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray<NSAttributedStringKey> *m = @[
            NSFontAttributeName,
            NSForegroundColorAttributeName,
            NSBackgroundColorAttributeName,
            NSKernAttributeName,
            NSShadowAttributeName,
            NSStrokeColorAttributeName,
            NSStrokeWidthAttributeName,
            NSUnderlineStyleAttributeName,
            NSUnderlineColorAttributeName,
            NSStrikethroughStyleAttributeName,
            NSStrikethroughColorAttributeName,
            NSBaselineOffsetAttributeName,
            NSParagraphStyleAttributeName,
        ].mutableCopy;
        
        if (@available(iOS 11.0, *)) {
            [m addObject:(__bridge NSString *)kCTBaselineOffsetAttributeName];
        }
        
        SJUT_Keys = m.copy;
    });
}


- (void)setValue:(nullable id)value forAttributeKey:(NSString *)key {
    if ( key == nil ) return;
    if ( _customAttributes == nil ) {
        _customAttributes = NSMutableDictionary.dictionary;
    }
    _customAttributes[key] = value;
}

- (void)setValuesForAttributeKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    if ( keyedValues.count == 0 ) return;
    if ( _customAttributes == nil ) {
        _customAttributes = NSMutableDictionary.dictionary;
    }
    [_customAttributes setValuesForKeysWithDictionary:keyedValues];
}

- (NSDictionary<NSAttributedStringKey, id> *)textAttributes {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    attrs[NSForegroundColorAttributeName] = textColor;
    if ( backgroundColor != nil ) attrs[NSBackgroundColorAttributeName] = backgroundColor;
    if ( kern != nil ) attrs[NSKernAttributeName] = kern;
    if ( shadow != nil ) attrs[NSShadowAttributeName] = shadow;
    if ( stroke != nil ) {
        attrs[NSStrokeColorAttributeName] = stroke.color;
        attrs[NSStrokeWidthAttributeName] = @(stroke.width);
    }
    if ( underLine != nil ) {
        attrs[NSUnderlineStyleAttributeName] = @(underLine.style);
        attrs[NSUnderlineColorAttributeName] = underLine.color;
    }
    if ( strikethrough != nil ) {
        attrs[NSStrikethroughStyleAttributeName] = @(strikethrough.style);
        attrs[NSStrikethroughColorAttributeName] = strikethrough.color;
    }
    if ( @available(iOS 14.0, *) ) {
        attrs[NSBaselineOffsetAttributeName] = @(baseLineOffset.doubleValue);
        attrs[(__bridge NSString *)kCTBaselineOffsetAttributeName] = attrs[NSBaselineOffsetAttributeName];
    }
    else if ( baseLineOffset != nil ) {
        attrs[NSBaselineOffsetAttributeName] = baseLineOffset;
        if ( @available(iOS 11.0, *) ) {
            attrs[(__bridge NSString *)kCTBaselineOffsetAttributeName] = attrs[NSBaselineOffsetAttributeName];
        }
    }
    return attrs;
}

- (NSParagraphStyle *)paragraphAttributesForStyle:(nullable NSParagraphStyle *)style {
#define SJUT_SET_ATTRIBUTE_VALUE(__attr__, __value__) if ( __attr__ != nil ) m.__attr__ = __attr__.__value__;
    NSMutableParagraphStyle *m = (style ?: [NSParagraphStyle defaultParagraphStyle]).mutableCopy;
    SJUT_SET_ATTRIBUTE_VALUE(lineSpacing, doubleValue);
    SJUT_SET_ATTRIBUTE_VALUE(paragraphSpacing, doubleValue);
    SJUT_SET_ATTRIBUTE_VALUE(alignment, integerValue);
    SJUT_SET_ATTRIBUTE_VALUE(firstLineHeadIndent, doubleValue);
    SJUT_SET_ATTRIBUTE_VALUE(headIndent, doubleValue);
    SJUT_SET_ATTRIBUTE_VALUE(tailIndent, doubleValue);
    SJUT_SET_ATTRIBUTE_VALUE(lineBreakMode, integerValue);
    SJUT_SET_ATTRIBUTE_VALUE(minimumLineHeight, doubleValue);
    SJUT_SET_ATTRIBUTE_VALUE(maximumLineHeight, doubleValue);
    SJUT_SET_ATTRIBUTE_VALUE(baseWritingDirection, integerValue);
    SJUT_SET_ATTRIBUTE_VALUE(lineHeightMultiple, doubleValue);
    SJUT_SET_ATTRIBUTE_VALUE(paragraphSpacingBefore, doubleValue);
    SJUT_SET_ATTRIBUTE_VALUE(hyphenationFactor, floatValue);
    SJUT_SET_ATTRIBUTE_VALUE(tabStops, copy);
    SJUT_SET_ATTRIBUTE_VALUE(defaultTabInterval, doubleValue);
    if ( @available(iOS 9.0, *) ) {
        SJUT_SET_ATTRIBUTE_VALUE(allowsDefaultTighteningForTruncation, boolValue);
        SJUT_SET_ATTRIBUTE_VALUE(lineBreakStrategy, integerValue);
    }
    return m.copy;
#undef SJUT_SET_ATTRIBUTE_VALUE
}

- (NSDictionary<NSAttributedStringKey, id> *)customAttributes {
    return _customAttributes.copy;
}

- (void)setValuesForCommonRecorder:(SJUTRecorder *)recorder {
#define SJUT_SET_ATTRIBUTE_COMMON_VALUE(__attr__) if ( __attr__ == nil ) __attr__ = recorder->__attr__;
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(_customAttributes);
    
    // text attributes
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(font);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(textColor);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(backgroundColor);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(kern);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(shadow);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(stroke);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(underLine);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(strikethrough);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(baseLineOffset);
    
    // paragraph attributes
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(lineSpacing);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(paragraphSpacing);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(alignment);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(firstLineHeadIndent);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(headIndent);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(tailIndent);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(lineBreakMode);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(minimumLineHeight);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(maximumLineHeight);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(baseWritingDirection);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(lineHeightMultiple);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(paragraphSpacingBefore);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(hyphenationFactor);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(tabStops);
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(defaultTabInterval);
    if ( @available(iOS 9.0, *) ) {
        SJUT_SET_ATTRIBUTE_COMMON_VALUE(allowsDefaultTighteningForTruncation);
        SJUT_SET_ATTRIBUTE_COMMON_VALUE(lineBreakStrategy);
    }
    
    // custom attributes
    SJUT_SET_ATTRIBUTE_COMMON_VALUE(_customAttributes);
#undef SJUT_SET_ATTRIBUTE_COMMON_VALUE
}

- (void)setValuesForAttributedString:(NSAttributedString *)attributedString {
    NSRange textRange = SJUTGetTextRange(attributedString);
    NSRange longestEffectiveRange;
    NSMutableDictionary<NSAttributedStringKey, id> *attrs = [attributedString attributesAtIndex:0 longestEffectiveRange:&longestEffectiveRange inRange:textRange].mutableCopy;
    if ( SJUTRangeContains(longestEffectiveRange, textRange) ) {
        
        // text attributes
        font = attrs[NSFontAttributeName];
        textColor = attrs[NSForegroundColorAttributeName];
        backgroundColor = attrs[NSBackgroundColorAttributeName];
        kern = attrs[NSKernAttributeName];
        shadow = attrs[NSShadowAttributeName];
        UIColor *strokeColor = attrs[NSStrokeColorAttributeName];
        NSNumber *strokeWidth = attrs[NSStrokeWidthAttributeName];
        if ( strokeColor != nil || strokeWidth != nil ) {
            stroke = SJUTStroke.alloc.init;
            stroke.color = strokeColor;
            stroke.width = strokeWidth.floatValue;
        }
        
        UIColor *underLineColor = attrs[NSUnderlineColorAttributeName];
        NSNumber *underLineStyle = attrs[NSUnderlineStyleAttributeName];
        if ( underLineColor != nil || underLineStyle != nil ) {
            underLine = SJUTDecoration.alloc.init;
            underLine.color = underLineColor;
            underLine.style = underLineStyle.integerValue;
        }
        
        UIColor *strikethroughColor = attrs[NSStrikethroughColorAttributeName];
        NSNumber *strikethroughStyle = attrs[NSStrikethroughStyleAttributeName];
        if ( strikethroughColor != nil || strikethroughStyle != nil ) {
            strikethrough = SJUTDecoration.alloc.init;
            strikethrough.color = strikethroughColor;
            strikethrough.style = strikethroughStyle.integerValue;
        }
        baseLineOffset = attrs[NSBaselineOffsetAttributeName];
        
        // paragraph attributes
        NSParagraphStyle *paragraphAttributes = attrs[NSParagraphStyleAttributeName];
        if ( paragraphAttributes != nil ) {
#define SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(__attr__) if ( paragraphAttributes.__attr__ != 0 ) __attr__ = @(paragraphAttributes.__attr__);
            SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(lineSpacing);
            SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(paragraphSpacing);
            SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(alignment);
            SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(firstLineHeadIndent);
            SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(headIndent);
            SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(tailIndent);
            SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(lineBreakMode);
            SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(minimumLineHeight);
            SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(maximumLineHeight);
            SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(baseWritingDirection);
            SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(lineHeightMultiple);
            SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(paragraphSpacingBefore);
            SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(hyphenationFactor);
            tabStops = paragraphAttributes.tabStops;
            SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(defaultTabInterval);
            if ( @available(iOS 9.0, *) ) {
                SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(allowsDefaultTighteningForTruncation);
                SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(lineBreakStrategy);
            }
#undef SJUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber
        }
        
        // custom attributes
        [attrs removeObjectsForKeys:SJUT_Keys];
        [self setValuesForAttributeKeysWithDictionary:attrs];
    }
}
@end
NS_ASSUME_NONNULL_END
