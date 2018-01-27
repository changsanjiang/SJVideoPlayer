//
//  SJAttributesRecorder.m
//  SJAttributesFactory
//
//  Created by BlueDancer on 2018/1/27.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJAttributesRecorder.h"
#import <objc/message.h>

@implementation SJBorderAttribute
+ (instancetype)borderWithValue:(double)value color:(UIColor *)color {
    return [[self alloc] initWithValue:value color:color];
}
- (instancetype)initWithValue:(double)value color:(UIColor *)color {
    self = [super init];
    if ( !self ) return nil;
    _value = value;
    _color = color;
    return self;
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
@end

#pragma mark -
@implementation SJAttributesRecorder {
   NSMutableParagraphStyle * _paragraphStyleM;
}

- (NSMutableParagraphStyle *)paragraphStyleM {
    if ( _paragraphStyleM ) return _paragraphStyleM;
    _paragraphStyleM = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    return _paragraphStyleM;
}
- (void)setLineSpacing:(double)lineSpacing {self.paragraphStyleM.lineSpacing = lineSpacing;}
- (double)lineSpacing {return self.paragraphStyleM.lineSpacing;}

- (void)setParagraphSpacing:(double)paragraphSpacing {self.paragraphStyleM.paragraphSpacing = paragraphSpacing;}
- (double)paragraphSpacing {return self.paragraphStyleM.paragraphSpacing;}

- (void)setParagraphSpacingBefore:(double)paragraphSpacingBefore {self.paragraphStyleM.paragraphSpacingBefore = paragraphSpacingBefore;}
- (double)paragraphSpacingBefore {return self.paragraphStyleM.paragraphSpacingBefore;}

- (void)setFirstLineHeadIndent:(double)firstLineHeadIndent {self.paragraphStyleM.firstLineHeadIndent = firstLineHeadIndent;}
- (double)firstLineHeadIndent {return self.paragraphStyleM.firstLineHeadIndent;}

- (void)setHeadIndent:(double)headIndent {self.paragraphStyleM.headIndent = headIndent;}
- (double)headIndent {return self.paragraphStyleM.headIndent;}

- (void)setTailIndent:(double)tailIndent {self.paragraphStyleM.tailIndent = tailIndent;}
- (double)tailIndent {return self.paragraphStyleM.tailIndent;}

- (void)setAlignment:(double)alignment {self.paragraphStyleM.alignment = alignment;}
- (double)alignment {return self.paragraphStyleM.alignment;}

- (void)addAttributes:(NSMutableAttributedString *)attrStr {
    NSRange range = self.range;
    if ( range.location == 0 && range.length == 0 ) {
        range = NSMakeRange(0, attrStr.length);
    }
    if ( nil != self.font ) {
        [attrStr addAttribute:NSFontAttributeName value:self.font range:range];
    }
    if ( nil != self.textColor ) {
        [attrStr addAttribute:NSForegroundColorAttributeName value:self.textColor range:range];
    }
    if ( 0 != self.expansion ) {
        [attrStr addAttribute:NSExpansionAttributeName value:@(self.expansion) range:range];
    }
    if ( nil != self.shadow ) {
        [attrStr addAttribute:NSShadowAttributeName value:self.shadow range:range];
    }
    if ( nil != self.backgroundColor ) {
        [attrStr addAttribute:NSBackgroundColorAttributeName value:self.backgroundColor range:range];
    }
    if ( nil != self.underLine ) {
        [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(self.underLine.value) range:range];
        [attrStr addAttribute:NSUnderlineColorAttributeName value:self.underLine.color range:range];
    }
    if ( nil != self.strikethrough ) {
        [attrStr addAttribute:NSStrikethroughStyleAttributeName value:@(self.strikethrough.value) range:range];
        [attrStr addAttribute:NSStrikethroughColorAttributeName value:self.strikethrough.color range:range];
    }
    if ( nil != self.border ) {
        [attrStr addAttribute:NSStrokeWidthAttributeName value:@(self.border.value) range:range];
        [attrStr addAttribute:NSStrokeColorAttributeName value:self.border.color range:range];
    }
    if ( 0 != self.obliqueness ) {
        [attrStr addAttribute:NSObliquenessAttributeName value:@(self.obliqueness) range:range];
    }
    if ( 0 != self.letterSpacing ) {
        [attrStr addAttribute:NSKernAttributeName value:@(self.letterSpacing) range:range];
    }
    if ( 0 != self.offset ) {
        [attrStr addAttribute:NSBaselineOffsetAttributeName value:@(self.offset) range:range];
    }
    if ( YES == self.link ) {
        [attrStr addAttribute:NSLinkAttributeName value:@(1) range:range];
    }
    if ( nil != _paragraphStyleM ) {
        [attrStr addAttribute:NSParagraphStyleAttributeName value:self.paragraphStyleM range:range];
    }
}
- (id)copyWithZone:(NSZone *)zone {
    SJAttributesRecorder *newRecorder = [SJAttributesRecorder new];
    [[self csj_propertyList] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [newRecorder setValue:[[self valueForKey:obj] copy] forKey:obj];
    }];
    return newRecorder;
}

- (NSArray<NSString *> *)csj_propertyList {
    NSMutableArray <NSString *> *namesArrM = [NSMutableArray array];
    unsigned int outCount = 0;
    objc_property_t *propertyList = class_copyPropertyList([self class], &outCount);
    if ( propertyList != NULL && outCount > 0 ) {
        for ( int i = 0; i < outCount; i ++ ) {
            objc_property_t property = propertyList[i];
            const char *name  = property_getName(property);
            NSString *nameStr = [NSString stringWithUTF8String:name];
            [namesArrM addObject:nameStr];
        }
    }
    free(propertyList);
    return namesArrM.copy;
}

@end
