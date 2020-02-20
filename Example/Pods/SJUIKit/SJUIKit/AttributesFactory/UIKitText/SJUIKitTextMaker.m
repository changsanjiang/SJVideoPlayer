//
//  SJUIKitTextMaker.m
//  AttributesFactory
//
//  Created by 畅三江 on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJUIKitTextMaker.h"
#import "SJUTRegexHandler.h"
#import "SJUTRangeHandler.h"

NS_ASSUME_NONNULL_BEGIN
inline static BOOL _rangeContains(NSRange main, NSRange sub) {
    return (main.location <= sub.location) && (main.location + main.length >= sub.location + sub.length);
}

inline static NSRange _textRange(NSAttributedString *text) {
    return NSMakeRange(0, text.length);
}

@interface SJUIKitTextMaker ()
@property (nonatomic, strong, readonly) NSMutableArray<SJUTAttributes *> *uts;
@property (nonatomic, strong, readonly) NSMutableArray<SJUTAttributes *> *updates;
@property (nonatomic, strong, readonly) NSMutableArray<SJUTRegexHandler *> *regexs;
@property (nonatomic, strong, readonly) NSMutableArray<SJUTRangeHandler *> *ranges;
@end

@implementation SJUIKitTextMaker
@synthesize uts = _uts;
- (NSMutableArray<SJUTAttributes *> *)uts {
    if ( !_uts ) _uts = [NSMutableArray array];
    return _uts;
}
@synthesize updates = _updates;
- (NSMutableArray<SJUTAttributes *> *)updates {
    if ( !_updates ) _updates = [NSMutableArray array];
    return _updates;
}
@synthesize regexs = _regexs;
- (NSMutableArray<SJUTRegexHandler *> *)regexs {
    if ( !_regexs ) _regexs = [NSMutableArray array];
    return _regexs;
}
@synthesize ranges = _ranges;
- (NSMutableArray<SJUTRangeHandler *> *)ranges {
    if ( !_ranges ) _ranges = [NSMutableArray array];
    return _ranges;
}

- (id<SJUTAttributesProtocol>  _Nonnull (^)(NSString * _Nonnull))append {
    return ^id<SJUTAttributesProtocol>(NSString *str) {
        SJUTAttributes *ut = [SJUTAttributes new];
        ut.recorder->string = str;
        [self.uts addObject:ut];
        return ut;
    };
}
- (id<SJUTAttributesProtocol>  _Nonnull (^)(NSRange))update {
    return ^id<SJUTAttributesProtocol>(NSRange range) {
        SJUTAttributes *ut = [SJUTAttributes new];
        ut.recorder->range = range;
        [self.updates addObject:ut];
        return ut;
    };
}
- (id<SJUTAttributesProtocol>  _Nonnull (^)(void (^ _Nonnull)(id<SJUTImageAttachment> _Nonnull)))appendImage {
    return ^id<SJUTAttributesProtocol>(void(^block)(id<SJUTImageAttachment> make)) {
        SJUTAttributes *ut = [SJUTAttributes new];
        SJUTImageAttachment *attachment = [SJUTImageAttachment new];
        ut.recorder->attachment = attachment;
        block(attachment);
        [self.uts addObject:ut];
        return ut;
    };
}
- (id<SJUTAttributesProtocol>  _Nonnull (^)(NSAttributedString * _Nonnull))appendText {
    return ^id<SJUTAttributesProtocol>(NSAttributedString *attrStr) {
        SJUTAttributes *ut = [SJUTAttributes new];
        ut.recorder->attrStr = [attrStr mutableCopy];
        [self.uts addObject:ut];
        return ut;
    };
}
- (id<SJUTRegexHandlerProtocol>  _Nonnull (^)(NSString * _Nonnull))regex {
    return ^id<SJUTRegexHandlerProtocol>(NSString *regex) {
        SJUTRegexHandler *handler = [[SJUTRegexHandler alloc] initWithRegex:regex];
        [self.regexs addObject:handler];
        return handler;
    };
}
- (id<SJUTRangeHandlerProtocol>  _Nonnull (^)(NSRange))range {
    return ^id<SJUTRangeHandlerProtocol>(NSRange range) {
        SJUTRangeHandler *handler = [[SJUTRangeHandler alloc] initWithRange:range];
        [self.ranges addObject:handler];
        return handler;
    };
}
- (NSMutableAttributedString *)install {
    // default values
    SJUTRecorder *recorder = self.recorder;
    if ( recorder->font == nil ) recorder->font = [UIFont systemFontOfSize:14];
    if ( recorder->textColor == nil ) recorder->textColor = [UIColor blackColor];

    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    [self _appendUTAttributesToResultIfNeeded:result];
    [self _executeUpdateHandlersIfNeeded:result];
    [self _executeRangeHandlersIfNeeded:result];
    [self _executeUpdateHandlersIfNeeded:result];
    [self _executeRegexHandlersIfNeeded:result];
    [self _executeUpdateHandlersIfNeeded:result];
    return result;
}

- (void)_appendUTAttributesToResultIfNeeded:(NSMutableAttributedString *)result {
    if ( _uts ) {
        for ( SJUTAttributes *ut in _uts ) {
            id _Nullable current = [self _convertToUIKitTextForUTAttributes:ut];
            if ( current != nil ) {
                [result appendAttributedString:current];
            }
        }
        _uts = nil;
    }
}

- (NSMutableAttributedString *_Nullable)_convertToUIKitTextForUTAttributes:(SJUTAttributes *)attr {
    NSMutableAttributedString *_Nullable current = nil;
    SJUTRecorder *recorder = attr.recorder;
    if      ( recorder->string != nil ) {
        current = [[NSMutableAttributedString alloc] initWithString:recorder->string];
    }
    else if ( recorder->attachment != nil ) {
        SJUTVerticalAlignment alignment = recorder->attachment.alignment;
        UIImage *image = recorder->attachment.image;
        CGRect bounds = recorder->attachment.bounds;
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = recorder->attachment.image;
        attachment.bounds = [self _adjustVerticalOffsetOfImageAttachmentForBounds:bounds imageSize:image.size alignment:alignment commonFont:self.recorder->font];
        current = [NSAttributedString attributedStringWithAttachment:attachment].mutableCopy;
    }
    
    if      ( current != nil ) {
        [self _setCommonValuesForUTAttributesRecorderIfNeeded:recorder];
        id attributes = [self _convertToUIKitTextAttributesForUTAttributesRecorder:recorder];
        [current addAttributes:attributes range:_textRange(current)];
    }
    else if ( recorder->attrStr != nil ) {
        current = recorder->attrStr;
        // ignore common values
        // [self _setCommonValuesForUTAttributesRecorderIfNeeded:recorder];
        id attributes = [self _convertToUIKitTextAttributesForUTAttributesRecorder:recorder];
        [current addAttributes:attributes range:_textRange(current)];
    }
    
    return current;
}

- (void)_executeRangeHandlersIfNeeded:(NSMutableAttributedString *)result {
    if ( _ranges ) {
        for ( SJUTRangeHandler *handler in _ranges ) {
            SJUTRangeRecorder *recorder = handler.recorder;
            if ( _rangeContains(_textRange(result), recorder.range) ) {
                if      ( recorder.utOfReplaceWithString != nil ) {
                    [self _executeReplaceWithString:result ut:recorder.utOfReplaceWithString inRange:recorder.range];
                }
                else if ( recorder.replaceWithText != nil ) {
                    [self _executeReplaceWithText:result handler:recorder.replaceWithText inRange:recorder.range];
                }
                else if ( recorder.update != nil ) {
                    [self _appendUpdateHandlerToUpdates:recorder.update inRange:recorder.range];
                }
            }
        }
        _ranges = nil;
    }
}

- (void)_executeRegexHandlersIfNeeded:(NSMutableAttributedString *)result {
    if ( _regexs ) {
        for ( SJUTRegexHandler *handler in _regexs ) {
            NSString *string = result.string;
            NSRange resultRange = NSMakeRange(0, result.length);
            SJUTRegexRecorder *recorder = handler.recorder;
            if ( recorder.regex.length < 1 )
                continue;
            
            NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:recorder.regex options:recorder.regularExpressionOptions error:nil];
            NSMutableArray<NSTextCheckingResult *> *results = [NSMutableArray new];
            [regular enumerateMatchesInString:string options:recorder.matchingOptions range:resultRange usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                if ( result ) [results addObject:result];
            }];
            
            [results enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange range = obj.range;
                if ( recorder.update != nil ) {
                    [self _appendUpdateHandlerToUpdates:recorder.update inRange:range];
                }
                else if ( recorder.utOfReplaceWithString != nil ) {
                    [self _executeReplaceWithString:result ut:recorder.utOfReplaceWithString inRange:range];
                }
                else if ( recorder.replaceWithText != nil ) {
                    [self _executeReplaceWithText:result handler:recorder.replaceWithText inRange:range];
                }
                else if ( recorder.handler != nil ) {
                    recorder.handler(result, obj);
                }
            }];
        }
        _regexs = nil;
    }
}

- (void)_executeReplaceWithString:(NSMutableAttributedString *)result ut:(id<SJUTAttributesProtocol>)ut inRange:(NSRange)range {
    if ( _rangeContains(_textRange(result), range) ) {
        SJUTAttributes *uta = (id)ut;
        [self _setSubtextCommonValuesToRecorder:uta.recorder inRange:range result:result];
        id _Nullable subtext = [self _convertToUIKitTextForUTAttributes:uta];
        if ( subtext ) {
            [result replaceCharactersInRange:range withAttributedString:subtext];
        }
    }
}

- (void)_executeReplaceWithText:(NSMutableAttributedString *)result handler:(void(^)(id<SJUIKitTextMakerProtocol> maker))handler inRange:(NSRange)range {
    if ( _rangeContains(_textRange(result), range) ) {
        SJUIKitTextMaker *maker = [SJUIKitTextMaker new];
        [self _setCommonValuesForUTAttributesRecorderIfNeeded:maker.recorder];
        [self _setSubtextCommonValuesToRecorder:maker.recorder inRange:range result:result];
        handler(maker);
        [result replaceCharactersInRange:range withAttributedString:maker.install];
    }
}

- (void)_executeUpdateHandlersIfNeeded:(NSMutableAttributedString *)result {
    if ( _updates ) {
        NSRange resultRange = NSMakeRange(0, result.length);
        for ( SJUTAttributes *ut in _updates ) {
            SJUTRecorder *recorder = ut.recorder;
            NSRange range = recorder->range;
            if ( _rangeContains(resultRange, range) ) {
                [self _setCommonValuesForUTAttributesRecorderIfNeeded:recorder];
                id attributes = [self _convertToUIKitTextAttributesForUTAttributesRecorder:recorder];
                [result addAttributes:attributes range:range];
            }
        }
        _updates = nil;
    }
}

- (void)_appendUpdateHandlerToUpdates:(void(^)(id<SJUTAttributesProtocol>))handler inRange:(NSRange)range {
    SJUTAttributes *ut = [SJUTAttributes new];
    ut.recorder->range = range;
    handler(ut);
    [self.updates addObject:ut];
}

- (void)_setSubtextCommonValuesToRecorder:(SJUTRecorder *)recorder inRange:(NSRange)range result:(NSAttributedString *)result {
    if ( _rangeContains(_textRange(result), range) ) {
        NSAttributedString *subtext = [result attributedSubstringFromRange:range];
        NSDictionary<NSAttributedStringKey, id> *dict = [subtext attributesAtIndex:0 effectiveRange:NULL];
        recorder->font = dict[NSFontAttributeName];
        recorder->textColor = dict[NSForegroundColorAttributeName];
    }
}

- (void)_setCommonValuesForUTAttributesRecorderIfNeeded:(SJUTRecorder *)recorder {
    SJUTRecorder *common = self.recorder;
#define SJUTSetRecorderCommonValueIfNeeded(__var__) if ( recorder->__var__ == nil ) recorder->__var__ = common->__var__;
    SJUTSetRecorderCommonValueIfNeeded(font);
    SJUTSetRecorderCommonValueIfNeeded(textColor);
    SJUTSetRecorderCommonValueIfNeeded(backgroundColor);
    
    SJUTSetRecorderCommonValueIfNeeded(alignment);
    SJUTSetRecorderCommonValueIfNeeded(lineSpacing);
    SJUTSetRecorderCommonValueIfNeeded(lineBreakMode);
    SJUTSetRecorderCommonValueIfNeeded(style);
    
    SJUTSetRecorderCommonValueIfNeeded(kern);
    SJUTSetRecorderCommonValueIfNeeded(stroke);
    SJUTSetRecorderCommonValueIfNeeded(shadow);
    SJUTSetRecorderCommonValueIfNeeded(underLine);
    SJUTSetRecorderCommonValueIfNeeded(strikethrough);
    SJUTSetRecorderCommonValueIfNeeded(baseLineOffset);
#undef SJUTSetRecorderCommonValueIfNeeded
}

- (NSDictionary *)_convertToUIKitTextAttributesForUTAttributesRecorder:(SJUTRecorder *)recorder {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = recorder->font;
    attrs[NSForegroundColorAttributeName] = recorder->textColor;
    if ( recorder->backgroundColor != nil ) attrs[NSBackgroundColorAttributeName] = recorder->backgroundColor;
    attrs[NSParagraphStyleAttributeName] = [recorder paragraphStyle];
    if ( recorder->kern != nil ) attrs[NSKernAttributeName] = recorder->kern;
    SJUTStroke *_Nullable stroke = recorder->stroke;
    if ( stroke != nil ) {
        attrs[NSStrokeColorAttributeName] = stroke.color;
        attrs[NSStrokeWidthAttributeName] = @(stroke.width);
    }
    if ( recorder->shadow != nil ) attrs[NSShadowAttributeName] = recorder->shadow;
    SJUTDecoration *_Nullable underLine = recorder->underLine;
    if ( underLine != nil ) {
        attrs[NSUnderlineStyleAttributeName] = @(underLine.style);
        attrs[NSUnderlineColorAttributeName] = underLine.color;
    }
    SJUTDecoration *_Nullable strikethrough = recorder->strikethrough;
    if ( strikethrough != nil ) {
        attrs[NSStrikethroughStyleAttributeName] = @(strikethrough.style);
        attrs[NSStrikethroughColorAttributeName] = strikethrough.color;
    }
    if ( recorder->baseLineOffset != nil ) attrs[NSBaselineOffsetAttributeName] = recorder->baseLineOffset;
    return attrs;
}

- (CGRect)_adjustVerticalOffsetOfImageAttachmentForBounds:(CGRect)bounds imageSize:(CGSize)imageSize alignment:(SJUTVerticalAlignment)alignment commonFont:(UIFont *)font {
    switch ( alignment ) {
        case SJUTVerticalAlignmentTop: {
            if ( CGSizeEqualToSize(CGSizeZero, bounds.size) ) {
                bounds.size = imageSize;
            }
            CGFloat offset = -(bounds.size.height - ABS(font.capHeight));
            bounds.origin.y = offset;
        }
            break;
        case SJUTVerticalAlignmentCenter: {
            if ( CGSizeEqualToSize(CGSizeZero, bounds.size) ) {
                bounds.size = imageSize;
            }
            CGFloat offset = -(bounds.size.height * 0.5 - ABS(font.descender));
            bounds.origin.y = offset;
        }
            break;
        case SJUTVerticalAlignmentBottom: { }
            break;
    }
    return bounds;
}
@end
NS_ASSUME_NONNULL_END
