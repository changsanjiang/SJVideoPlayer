//
//  SJCTData.m
//  Test
//
//  Created by BlueDancer on 2017/12/13.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJCTData.h"

@interface SJLineModel : NSObject
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat ascent;
@property (nonatomic, assign) CGFloat descent;
@property (nonatomic, assign) CGFloat leading;
@property (nonatomic, assign) CFRange range;
@property (nonatomic, assign) CTLineRef line;
@property (nonatomic, assign) CGFloat height;
@end

@implementation SJLineModel

- (void)setLine:(CTLineRef)line {
    if ( line != _line ) {
        if ( _line ) CFRelease(_line);
        _line = nil;
    }
    if ( line ) CFRetain(_line = line);
}

- (void)dealloc {
    if ( _line ) {
        CFRelease(_line);
        _line = nil;
    }
}
@end

#pragma mark -

@interface SJCTData ()
@property (nonatomic, strong, readonly) NSMutableArray<SJLineModel *> *drawingLinesM;
@property (nonatomic, assign, readwrite) BOOL inited;
@property (nonatomic, assign, readwrite) BOOL truncated;
@property (nonatomic, assign, readwrite) NSInteger truncatedLineLocation;
@end

@implementation SJCTData
@synthesize drawingLinesM = _drawingLinesM;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _drawingLinesM = [NSMutableArray array];
    return self;
}

- (void)setFrameRef:(CTFrameRef)frameRef {
    if ( _frameRef != frameRef ) {
        if ( _frameRef ) CFRelease(_frameRef);
        _frameRef = nil;
    }
    if ( frameRef ) CFRetain(_frameRef = frameRef);
}

- (void)dealloc {
    if ( _frameRef ) {
        CFRelease(_frameRef);
        _frameRef = nil;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    SJCTData *data = [SJCTData new];
    data.frameRef = self.frameRef;
    data.height = self.height;
    data.imageDataArray = self.imageDataArray;
    return data;
}

- (void)needsDrawing {
    if ( _inited ) return;
    _inited = YES;
    NSUInteger numberOfLines = _config.numberOfLines;
    CTFrameRef frameRef = _frameRef;
    CFArrayRef linesArr = CTFrameGetLines(frameRef);
    NSUInteger lines = CFArrayGetCount(linesArr);
    if ( numberOfLines > lines || 0 == numberOfLines ) numberOfLines = lines;
    CGPoint baseLineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, numberOfLines), baseLineOrigins);
    
    //    CGFloat lineH = ABS(_config.font.descender) + _config.font.ascender + _config.font.leading + _config.lineSpacing;
    for ( CFIndex lineIndex = 0 ; lineIndex < numberOfLines ; lineIndex ++ ) {
        
        CGPoint lineOrigin = baseLineOrigins[lineIndex];
        CTLineRef nextLine = CFArrayGetValueAtIndex(linesArr, lineIndex);
        CGFloat ascent = 0;
        CGFloat descent = 0;
        CGFloat leading = 0;
        CTLineGetTypographicBounds(nextLine, &ascent, &descent, &leading);
        SJLineModel *recordLine = [SJLineModel new];
        recordLine.origin = lineOrigin;
        recordLine.line = nextLine;
        recordLine.ascent = ascent;
        recordLine.descent = descent;
        recordLine.leading = leading;
        recordLine.height = ABS(descent) + ascent + leading;
        recordLine.range = CTLineGetStringRange(nextLine);
        [_drawingLinesM addObject:recordLine];
    }
    
    if ( 0 != _config.numberOfLines && _config.numberOfLines < lines ) {
        NSUInteger lastLineIndex = _config.numberOfLines - 1;
        CFRange lastLineRange = CTLineGetStringRange(CFArrayGetValueAtIndex(linesArr, lastLineIndex));
        
        CTLineTruncationType truncationType = kCTLineTruncationEnd;
        NSInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;
        
        NSDictionary *lastAttributes = [_attrStr attributesAtIndex:truncationAttributePosition effectiveRange:NULL];
        NSAttributedString *ellipsisAttrStr = [[NSAttributedString alloc] initWithString:@"\u2026" attributes:lastAttributes];
        CTLineRef ellipsisLineRef = CTLineCreateWithAttributedString((CFAttributedStringRef)ellipsisAttrStr);
        
        NSMutableAttributedString *lastAttrStr =
        [[_attrStr attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
        
        if ( lastLineRange.length > 0 ) {
            [lastAttrStr deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
        }
        [lastAttrStr appendAttributedString:ellipsisAttrStr];
        
        
        CTLineRef truncationLine = CTLineCreateWithAttributedString((CFAttributedStringRef)lastAttrStr);
        CTLineRef truncatedLine = CTLineCreateTruncatedLine( truncationLine,
                                                            _config.maxWidth,
                                                            truncationType,
                                                            ellipsisLineRef );
        if ( !truncatedLine ) {
            CFRelease(truncationLine);
            CFRelease(ellipsisLineRef);
            return;
        }
        
        SJLineModel *recordLine = _drawingLinesM.lastObject;
        recordLine.line = truncatedLine;
        
        CFRelease(truncationLine);
        CFRelease(ellipsisLineRef);
        CFRelease(truncatedLine);
        
        _height_t = 0;
        __block CGFloat height = 0;
        [_drawingLinesM enumerateObjectsUsingBlock:^(SJLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            height += obj.height + _config.lineSpacing;
        }];
        _height_t = ceil(height);
        
        CGFloat offset = _height - _height_t;
        [_drawingLinesM enumerateObjectsUsingBlock:^(SJLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.origin = CGPointMake(obj.origin.x, obj.origin.y - offset);
        }];
        
        [_imageDataArray enumerateObjectsUsingBlock:^(SJCTImageData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect position = obj.imagePosition;
            position.origin.y -= ( _height - _height_t );
            obj.imagePosition = position;
        }];
        
        _truncated = YES;
        _truncatedLineLocation = lastLineRange.location;
    }
    else {
        _height_t = _height;
    }
}

- (void)drawingWithContext:(CGContextRef)context {
    [_drawingLinesM enumerateObjectsUsingBlock:^(SJLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGContextSetTextPosition(context, obj.origin.x, obj.origin.y);
        CTLineDraw(obj.line, context);
    }];
    
    for ( SJCTImageData *imageData in _imageDataArray ) {
        UIImage *image = imageData.imageAttachment.image;
        if ( image ) { CGContextDrawImage(context, imageData.imagePosition, image.CGImage);}
    }
}

- (signed long)touchIndexWithPoint:(CGPoint)point {
    __block CFIndex index = kCFNotFound;
    [_drawingLinesM enumerateObjectsUsingBlock:^(SJLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint origin = obj.origin;
        origin.y = _height_t - origin.y;
        CGFloat head = origin.y - obj.ascent;
        CGFloat tail = origin.y + ABS(obj.descent) + obj.leading;
        
        if ( point.y > head && point.y < tail ) {
            *stop = YES;
            index = CTLineGetStringIndexForPosition(obj.line, point);
            if ( idx + 1 == _drawingLinesM.count ) {
                if ( _truncated ) index += _truncatedLineLocation;
            }
        }
    }];
    return index;
}
@end

