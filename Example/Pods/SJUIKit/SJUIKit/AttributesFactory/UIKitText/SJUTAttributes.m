//
//  SJUTAttributes.m
//  AttributesFactory
//
//  Created by 畅三江 on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJUTAttributes.h"

NS_ASSUME_NONNULL_BEGIN
#define SJUT_BLOCK_SET_ATTRIBUTE_Obj(__type__, __attr__) \
    ^id<SJUTAttributesProtocol>(__type__ __attr__) { \
        self.recorder->__attr__ = __attr__; \
        return self; \
    }

#define SJUT_BLOCK_SET_ATTRIBUTE_Obj_copy(__type__, __attr__) \
    ^id<SJUTAttributesProtocol>(__type__ __attr__) { \
        self.recorder->__attr__ = __attr__.copy; \
        return self; \
    }


#define SJUT_BLOCK_SET_ATTRIBUTE_NSNumber(__type__, __attr__) \
    ^id<SJUTAttributesProtocol>(__type__ __attr__) { \
        self.recorder->__attr__ = @(__attr__); \
        return self; \
    }

#define SJUT_BLOCK_SET_ATTRIBUTE_CGFloat(__attr__) SJUT_BLOCK_SET_ATTRIBUTE_NSNumber(CGFloat, __attr__)


@implementation SJUTAttributes
@synthesize recorder = _recorder;
- (SJUTRecorder *)recorder {
    if ( !_recorder ) {
        _recorder = [[SJUTRecorder alloc] init];
    }
    return _recorder;
}

- (SJUTFontAttribute)font {
    return SJUT_BLOCK_SET_ATTRIBUTE_Obj(UIFont *, font);
}

- (SJUTColorAttribute)textColor {
    return SJUT_BLOCK_SET_ATTRIBUTE_Obj(UIColor *, textColor);
}

///
/// Thanks @donggelaile
/// https://github.com/changsanjiang/SJAttributesFactory/issues/9
///
- (SJUTKernAttribute)kern {
    return SJUT_BLOCK_SET_ATTRIBUTE_CGFloat(kern);
}

- (SJUTShadowAttribute)shadow {
    return ^id<SJUTAttributesProtocol>(void(^block)(NSShadow *make)) {
        NSShadow *_Nullable shadow = self.recorder->shadow;
        if ( !shadow ) {
            self.recorder->shadow = shadow = [NSShadow new];
        }
        block(shadow);
        return self;
    };
}

- (SJUTColorAttribute)backgroundColor {
    return SJUT_BLOCK_SET_ATTRIBUTE_Obj(UIColor *, backgroundColor);
}

- (SJUTStrokeAttribute)stroke {
    return ^id<SJUTAttributesProtocol>(void(^block)(id<SJUTStroke> stroke)) {
        SJUTStroke *_Nullable stroke = self.recorder->stroke;
        if ( !stroke ) {
            self.recorder->stroke = stroke = [SJUTStroke new];
        }
        block(stroke);
        return self;
    };
}

- (SJUTDecorationAttribute)underLine {
    return ^id<SJUTAttributesProtocol>(void(^block)(id<SJUTDecoration> decoration)) {
        SJUTDecoration *_Nullable decoration = self.recorder->underLine;
        if ( !decoration ) {
            self.recorder->underLine = decoration = [SJUTDecoration new];
        }
        block(decoration);
        return self;
    };
}

- (SJUTDecorationAttribute)strikethrough {
    return ^id<SJUTAttributesProtocol>(void(^block)(id<SJUTDecoration> decoration)) {
        SJUTDecoration *_Nullable decoration = self.recorder->strikethrough;
        if ( !decoration ) {
            self.recorder->strikethrough = decoration = [SJUTDecoration new];
        }
        block(decoration);
        return self;
    };
}
//typedef id<SJUTAttributesProtocol>_Nonnull(^SJUTBaseLineOffsetAttribute)(double offset);
//#define SJUT_BLOCK_SET_ATTRIBUTE_CGFloat(__attr__) SJUT_BLOCK_SET_ATTRIBUTE_NSNumber(CGFloat, __attr__)
//#define SJUT_BLOCK_SET_ATTRIBUTE_NSNumber(__type__, __attr__) \
//    ^id<SJUTAttributesProtocol>(__type__ __attr__) { \
//        self.recorder->__attr__ = @(__attr__); \
//        return self; \
//    }

- (SJUTBaseLineOffsetAttribute)baseLineOffset {
    return SJUT_BLOCK_SET_ATTRIBUTE_CGFloat(baseLineOffset);
}

#pragma mark - mark


- (SJUTLineSpacingAttribute)lineSpacing {
    return SJUT_BLOCK_SET_ATTRIBUTE_CGFloat(lineSpacing);
}

- (SJUTParagraphSpacingAttribute)paragraphSpacing {
    return SJUT_BLOCK_SET_ATTRIBUTE_CGFloat(paragraphSpacing);
}

- (SJUTAlignmentAttribute)alignment {
    return SJUT_BLOCK_SET_ATTRIBUTE_NSNumber(NSTextAlignment, alignment);
}

- (SJUTFirstLineHeadIndentAttribute)firstLineHeadIndent {
    return SJUT_BLOCK_SET_ATTRIBUTE_CGFloat(firstLineHeadIndent);
}

- (SJUTHeadIndentAttribute)headIndent {
    return SJUT_BLOCK_SET_ATTRIBUTE_CGFloat(headIndent);
}

- (SJUTTailIndentAttribute)tailIndent {
    return SJUT_BLOCK_SET_ATTRIBUTE_CGFloat(tailIndent);
}

- (SJUTLineBreakModeAttribute)lineBreakMode {
    return SJUT_BLOCK_SET_ATTRIBUTE_NSNumber(NSLineBreakMode, lineBreakMode);
}

- (SJUTMinimumLineHeightAttribute)minimumLineHeight {
    return SJUT_BLOCK_SET_ATTRIBUTE_CGFloat(minimumLineHeight);
}

- (SJUTMaximumLineHeightAttribute)maximumLineHeight {
    return SJUT_BLOCK_SET_ATTRIBUTE_CGFloat(maximumLineHeight);
}

- (SJUTBaseWritingDirectionAttribute)baseWritingDirection {
    return SJUT_BLOCK_SET_ATTRIBUTE_NSNumber(NSWritingDirection, baseWritingDirection);
}

- (SJUTLineHeightMultipleAttribute)lineHeightMultiple {
    return SJUT_BLOCK_SET_ATTRIBUTE_CGFloat(lineHeightMultiple);
}

- (SJUTParagraphSpacingBeforeAttribute)paragraphSpacingBefore {
    return SJUT_BLOCK_SET_ATTRIBUTE_CGFloat(paragraphSpacingBefore);
}

- (SJUTHyphenationFactorAttribute)hyphenationFactor {
    return SJUT_BLOCK_SET_ATTRIBUTE_NSNumber(float, hyphenationFactor);
}

- (SJUTTabStopsAttribute)tabStops {
    return SJUT_BLOCK_SET_ATTRIBUTE_Obj_copy(NSArray<NSTextTab *> *, tabStops);
}

- (SJUTDefaultTabIntervalAttribute)defaultTabInterval {
    return SJUT_BLOCK_SET_ATTRIBUTE_CGFloat(defaultTabInterval);
}

- (SJUTAllowsDefaultTighteningForTruncationAttribute)allowsDefaultTighteningForTruncation API_AVAILABLE(ios(9.0)) {
    return SJUT_BLOCK_SET_ATTRIBUTE_NSNumber(BOOL, allowsDefaultTighteningForTruncation);
}

- (SJUTLineBreakStrategyAttribute)lineBreakStrategy API_AVAILABLE(ios(9.0)) {
    return SJUT_BLOCK_SET_ATTRIBUTE_NSNumber(NSLineBreakStrategy, lineBreakStrategy);
}

- (SJUTSetAttribute)set {
    return ^id<SJUTAttributesProtocol>(id _Nullable value, NSString *forKey) {
        [self.recorder setValue:value forAttributeKey:forKey];
        return self;
    };
}
@end
#undef SJUT_BLOCK_SET_ATTRIBUTE_CGFloat
#undef SJUT_BLOCK_SET_ATTRIBUTE_NSNumber
#undef SJUT_BLOCK_SET_ATTRIBUTE_Obj_copy
#undef SJUT_BLOCK_SET_ATTRIBUTE_Obj
NS_ASSUME_NONNULL_END
