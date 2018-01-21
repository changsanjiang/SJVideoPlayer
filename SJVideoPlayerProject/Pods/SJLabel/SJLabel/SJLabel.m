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
#import "SJStringParserConfig.h"
#import "SJCTImageData.h"
#import <SJAttributesFactory/SJAttributesFactoryHeader.h>


@interface SJDisplayLayer : CALayer

@property (nonatomic, strong) SJCTData *drawData;
@property (nonatomic, assign) BOOL directing;

@end

@implementation SJDisplayLayer

- (instancetype)initWithLayer:(id)layer {
    self = [super initWithLayer:layer];
    if ( !self ) return nil;
    self.contentsGravity = kCAGravityResizeAspect;
    return self;
}

- (void)setDrawData:(SJCTData *)drawData  {
    _drawData = drawData;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.bounds = CGRectMake(0, 0, drawData.config.maxWidth, drawData.height);
    self.position = CGPointMake(drawData.config.maxWidth * 0.5, drawData.height * 0.5);
    self.contents = drawData.contents;
    [CATransaction commit];
}

@end

#pragma mark -

@interface SJLabel ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) SJStringParserConfig *config;
@property (nonatomic, strong) SJDisplayLayer *displayLayer;

@property (nonatomic, strong) SJCTData *textDrawData;
@property (nonatomic, strong) SJCTData *attrTextDrawData;

@end

@implementation SJLabel

@synthesize text = _text;
@synthesize config = _config;

- (instancetype)initWithFrame:(CGRect)frame {
    return [self init];
}

- (instancetype)init {
    return [self initWithText:nil font:nil textColor:nil lineSpacing:0 userInteractionEnabled:NO];
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
    self.userInteractionEnabled = userInteractionEnabled;
    [self.layer addSublayer:_displayLayer = [SJDisplayLayer layer]];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ( 0 == _preferredMaxLayoutWidth &&
        0 != self.bounds.size.width ) {
        _config.maxWidth = floor(self.bounds.size.width);
    }
    [self _considerUpdating];
}

- (CGSize)intrinsicContentSize {
    if ( _drawData ) {
        return CGSizeMake(_drawData.width, _drawData.height);
    }
    else if ( _attributedText ) {
        return CGSizeMake(_attrTextDrawData.width, _attrTextDrawData.height);
    }
    else if ( _text ) {
        return CGSizeMake(_textDrawData.width, _textDrawData.height);
    }
    return CGSizeZero;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    __block BOOL action = NO;
    if ( _displayLayer.drawData ) {
        CGPoint point = [touches.anyObject locationInView:self];
        signed long index = [_displayLayer.drawData touchIndexWithPoint:point];
        if ( index != kCFNotFound && index < _displayLayer.drawData.attrStr.length ) {
            NSRange range = NSMakeRange(0, 0);
            NSDictionary<NSAttributedStringKey, id> *attributes = [_displayLayer.drawData.attrStr attributesAtIndex:index effectiveRange:&range];
            id value = attributes[SJActionAttributeName];
            if ( value ) {
                void(^block)(NSRange range, NSAttributedString *str) = value;
                action = YES;
                block(range, [_displayLayer.drawData.attrStr attributedSubstringFromRange:range]);
            }
        }
    }
    
    if ( !action ) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)sizeToFit {
    self.bounds = (CGRect){CGPointZero, CGSizeMake(_drawData.width, _drawData.height)};
}

#pragma mark - Property

- (void)setText:(NSString *)text {
    if ( [text isEqualToString:_text] ) return;
    _text = text.copy;
    [self _considerUpdating];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText.copy;
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

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _displayLayer.backgroundColor = backgroundColor.CGColor;
    [super setBackgroundColor:backgroundColor];
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
    return ceil(_drawData.height);
}

+ (SJCTData *)parserContent:(NSString *)content config:(SJStringParserConfig *)config {
    return [[SJCTData alloc] initWithString:content config:config];
}

+ (SJCTData *)parserAttributedStr:(NSAttributedString *)content maxWidth:(CGFloat)maxWidth numberOfLines:(NSUInteger)numberOfLines lineSpacing:(CGFloat)lineSpacing {
    SJCTFrameParserConfig *config = [SJCTFrameParserConfig defaultConfig];
    config.maxWidth = maxWidth;
    config.numberOfLines = numberOfLines;
    config.lineSpacing = lineSpacing;
    return [[SJCTData alloc] initWithAttributedString:content config:config];
}

+ (SJCTData *)parserAttributedStr:(NSAttributedString *)content config:(SJCTFrameParserConfig *)config {
    return [[SJCTData alloc] initWithAttributedString:content config:config];
}

#pragma mark - Private

- (void)_considerUpdating {
    if ( _drawData ) {
        
    }
    else if ( _attributedText ) {
        self.attrTextDrawData = [[SJCTData alloc] initWithAttributedString:_attributedText config:_config];
    }
    else if ( _text ) {
        self.textDrawData = [[SJCTData alloc] initWithString:_text config:_config];
    }
}

- (void)setTextDrawData:(SJCTData *)textDrawData {
    if ( textDrawData == _textDrawData ) return;
    _textDrawData = textDrawData;
    [self _setContentsWithDrawData:textDrawData];
}

- (void)setAttrTextDrawData:(SJCTData *)attrTextDrawData {
    if ( attrTextDrawData == _attrTextDrawData ) return;
    _attrTextDrawData = attrTextDrawData;
    [self _setContentsWithDrawData:attrTextDrawData];
}

- (void)setDrawData:(SJCTData *)drawData {
    if ( drawData == _drawData ) return;
    _drawData = drawData;
    [self _setContentsWithDrawData:drawData];
}

- (void)_setContentsWithDrawData:(SJCTData *)drawData {
    [drawData needsDrawing];
    [self invalidateIntrinsicContentSize];
    [_displayLayer setDrawData:drawData];
}
@end
