//
//  SJLabel.m
//  SJAttributesFactory
//
//  Created by BlueDancer on 2017/12/14.
//  Copyright © 2017年 畅三江. All rights reserved.
//

#import "SJLabel.h"
#import <CoreText/CoreText.h>
#import "SJCTData.h"
#import "SJCTFrameParser.h"
#import "SJStringParserConfig.h"
#import "SJCTImageData.h"
#import <SJAttributesFactory/SJAttributesFactoryHeader.h>

@interface SJLabel ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) SJCTData *drawData;

@property (nonatomic, strong, readonly) SJStringParserConfig *config;

@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation SJLabel

@synthesize text = _text;
@synthesize config = _config;

- (instancetype)init {
    return [self initWithText:nil font:nil textColor:nil lineSpacing:8 userInteractionEnabled:NO];
}

- (instancetype)initWithText:(NSString * __nullable)text
                        font:(UIFont * __nullable)font
                   textColor:(UIColor * __nullable)textColor
                 lineSpacing:(CGFloat)lineSpacing
      userInteractionEnabled:(BOOL)userInteractionEnabled {
    
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    _config = [SJStringParserConfig defaultConfig];
    self.backgroundColor = [UIColor clearColor];
    self.text = text;
    self.font = font;
    self.textColor = textColor;
    self.lineSpacing = lineSpacing;
    [self _setupGestures];
    self.userInteractionEnabled = userInteractionEnabled;
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    if ( 0 == _preferredMaxLayoutWidth &&
        0 != layer.bounds.size.width ) {
        _config.maxWidth = floor(layer.bounds.size.width);
    }
    [self _considerUpdating];
    [self invalidateIntrinsicContentSize];
    [super layoutSublayersOfLayer:layer];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(_drawData.width, _drawData.height_t);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if ( _drawData ) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, _drawData.height_t);
        CGContextScaleCTM(context, 1.0, -1.0);
        [_drawData drawingWithContext:context];
    }
}

- (void)sizeToFit {
    self.bounds = (CGRect){CGPointZero, CGSizeMake(_drawData.width, _drawData.height)};
}

- (void)_setupGestures {
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    self.userInteractionEnabled = YES;
    _tap.delegate = self;
    [self addGestureRecognizer:_tap];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ( gestureRecognizer != _tap ) return YES;
    if ( !_drawData ) return NO;
    
    CGPoint point = [gestureRecognizer locationInView:self];
    signed long index = [_drawData touchIndexWithPoint:point];
    __block BOOL action = NO;
    if ( index != kCFNotFound && index < _drawData.attrStr.length ) {
        NSRange range = NSMakeRange(0, 0);
        NSDictionary<NSAttributedStringKey, id> *attributes = [_drawData.attrStr attributesAtIndex:index effectiveRange:&range];
        id value = attributes[SJActionAttributeName];
        if ( value ) {
            void(^block)(NSRange range, NSAttributedString *str) = value;
            action = YES;
            block(range, [_drawData.attrStr attributedSubstringFromRange:range]);
        }
    }
    return action;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tap {}


#pragma mark - Private

- (void)_considerUpdating {
    if ( _text ) {
        self.drawData = [SJCTFrameParser parserContent:_text config:_config];
    }
    else if ( _attributedText ) {
        self.drawData = [SJCTFrameParser parserAttributedStr:_attributedText config:_config];
    }
}

#pragma mark - Property

- (void)setText:(NSString *)text {
    _text = text.copy;
    _attributedText = nil;
    [self _considerUpdating];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText.copy;
    _text = nil;
    [self _considerUpdating];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if ( textAlignment == _config.textAlignment ) return;
    self.config.textAlignment = textAlignment;
    [self _considerUpdating];
}

- (NSTextAlignment)textAlignment {
    return self.config.textAlignment;
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    if ( numberOfLines == _config.numberOfLines ) return;
    self.config.numberOfLines = numberOfLines;
    [self _considerUpdating];
}

- (NSUInteger)numberOfLines {
    return self.config.numberOfLines;
}

- (void)setFont:(UIFont *)font {
    if ( !font || font == _config.font || [font isEqual:_config.font] ) return;
    self.config.font = font;
    [self _considerUpdating];
}

- (UIFont *)font {
    return self.config.font;
}

- (void)setTextColor:(UIColor *)textColor {
    if ( !textColor || textColor == _config.textColor ) return;
    self.config.textColor = textColor;
    [self _considerUpdating];
}

- (UIColor *)textColor {
    return self.config.textColor;
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    self.config.maxWidth = preferredMaxLayoutWidth;
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    if ( lineSpacing == _config.lineSpacing ) return;
    self.config.lineSpacing = lineSpacing;
    [self _considerUpdating];
}

- (CGFloat)lineSpacing {
    return self.config.lineSpacing;
}

- (CGFloat)height {
    return ceil(_drawData.height_t);
}

+ (SJCTData *)parserContent:(NSString *)content config:(SJStringParserConfig *)config {
    return [SJCTFrameParser parserContent:content config:config];
}

+ (SJCTData *)parserAttributedStr:(NSAttributedString *)content maxWidth:(CGFloat)maxWidth numberOfLines:(NSUInteger)numberOfLines lineSpacing:(CGFloat)lineSpacing {
    SJCTFrameParserConfig *config = [SJCTFrameParserConfig defaultConfig];
    config.maxWidth = maxWidth;
    config.numberOfLines = numberOfLines;
    config.lineSpacing = lineSpacing;
    return [SJCTFrameParser parserAttributedStr:content config:config];
}

+ (SJCTData *)parserAttributedStr:(NSAttributedString *)content config:(SJCTFrameParserConfig *)config {
    return [SJCTFrameParser parserAttributedStr:content config:config];
}

- (void)setDrawData:(SJCTData *)drawData {
    if ( drawData != _drawData ) {
        _drawData = drawData;
        [self invalidateIntrinsicContentSize];
        [_drawData needsDrawing];
        [self.layer setNeedsDisplay];
    }
}

@end

