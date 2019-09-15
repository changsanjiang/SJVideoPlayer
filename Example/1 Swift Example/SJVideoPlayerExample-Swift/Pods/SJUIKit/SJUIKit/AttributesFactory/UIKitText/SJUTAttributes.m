//
//  SJUTAttributes.m
//  AttributesFactory
//
//  Created by BlueDancer on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJUTAttributes.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJUTAttributes
@synthesize recorder = _recorder;
- (SJUTRecorder *)recorder {
    if ( !_recorder ) {
        _recorder = [[SJUTRecorder alloc] init];
    }
    return _recorder;
}

- (SJUTFontAttribute)font {
    return ^id<SJUTAttributesProtocol>(UIFont *font) {
        self.recorder->font = font;
        return self;
    };
}

- (SJUTColorAttribute)textColor {
    return ^id<SJUTAttributesProtocol>(UIColor *color) {
        self.recorder->textColor = color;
        return self;
    };
}

- (SJUTAlignmentAttribute)alignment {
    return ^id<SJUTAttributesProtocol>(NSTextAlignment alignment) {
        self.recorder->alignment = @(alignment);
        return self;
    };
}

- (SJUTLineSpacingAttribute)lineSpacing {
    return ^id<SJUTAttributesProtocol>(CGFloat lineSpacing) {
        self.recorder->lineSpacing = @(lineSpacing);
        return self;
    };
}

- (SJUTKernAttribute)kern {
    return ^id<SJUTAttributesProtocol>(CGFloat kern) {
        ///
        /// Thanks @donggelaile
        /// https://github.com/changsanjiang/SJAttributesFactory/issues/9
        ///
        self.recorder->kern = @(kern);
        return self;
    };
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
    return ^id<SJUTAttributesProtocol>(UIColor *color) {
        self.recorder->backgroundColor = color;
        return self;
    };
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

- (SJUTParagraphStyleAttribute)paragraphStyle {
    return ^id<SJUTAttributesProtocol>(void(^block)(NSMutableParagraphStyle *style)) {
        NSMutableParagraphStyle *_Nullable style = self.recorder->style;
        if ( !style ) {
            self.recorder->style = style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        }
        block(style);
        return self;
    };
}

- (SJUTLineBreakModeAttribute)lineBreakMode {
    return ^id<SJUTAttributesProtocol>(NSLineBreakMode lineBreakMode) {
        self.recorder->lineBreakMode = @(lineBreakMode);
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

- (SJUTBaseLineOffsetAttribute)baseLineOffset {
    return ^id<SJUTAttributesProtocol>(double offset) {
        self.recorder->baseLineOffset = @(offset);
        return self;
    };
}
@end
NS_ASSUME_NONNULL_END
