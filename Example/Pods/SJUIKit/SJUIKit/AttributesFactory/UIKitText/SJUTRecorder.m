//
//  SJUTRecorder.m
//  AttributesFactory
//
//  Created by 畅三江 on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJUTRecorder.h"

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
- (NSParagraphStyle *)paragraphStyle {
    if ( !self->style ) {
        NSMutableParagraphStyle *style = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
        style.lineSpacing = [self->lineSpacing doubleValue];
        style.alignment = [self->alignment integerValue];
        style.lineBreakMode = [self->lineBreakMode integerValue];
        return style;
    }
    return self->style;
}

- (void)setCustomValue:(nullable id)value forAttributeKey:(NSString *)key {
    if ( customAttributes == nil ) {
        customAttributes = NSMutableDictionary.dictionary;
    }
    if ( key != nil ) customAttributes[key] = value;
}
@end
NS_ASSUME_NONNULL_END
