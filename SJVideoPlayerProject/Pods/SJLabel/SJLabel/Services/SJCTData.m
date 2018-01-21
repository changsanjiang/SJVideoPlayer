//
//  SJCTData.m
//  Test
//
//  Created by BlueDancer on 2017/12/13.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJCTData.h"

typedef NSString * NSAttributedStringKey NS_EXTENSIBLE_STRING_ENUM;

@interface SJLineModel : NSObject
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat ascent;
@property (nonatomic, assign) CGFloat descent;
@property (nonatomic, assign) CFRange range;
@property (nonatomic, assign) CTLineRef line;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) BOOL hasImages;
@property (nonatomic, strong, readonly) NSMutableArray<SJCTImageData *> *images;

@end

@implementation SJLineModel

@synthesize images = _images;

- (NSMutableArray<SJCTImageData *> *)images {
    if ( _images ) return _images;
    _images = [NSMutableArray array];
    return _images;
}

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
@property (nonatomic, assign, readwrite) NSRange truncatedLineRange;
@property (nonatomic, strong, readwrite) NSArray<SJCTImageData *> *imageDataArray;

@end

@implementation SJCTData

@synthesize drawingLinesM = _drawingLinesM;

+ (NSAttributedString *)_attrStrWithString:(NSString *)string onfig:(SJStringParserConfig *)config {
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)config.font.fontName, config.font.pointSize, NULL);
    CGFloat lineSpacing = config.lineSpacing;
    CTTextAlignment textAlignment = kCTTextAlignmentLeft;
    switch ( config.textAlignment ) {
        case NSTextAlignmentRight: { textAlignment = kCTTextAlignmentRight; } break;
        case NSTextAlignmentCenter: { textAlignment = kCTTextAlignmentCenter; } break;
        default: { textAlignment = (CTTextAlignment)config.textAlignment; } break;
    }
    const size_t _kNumberOfSettings = 4;
    CTParagraphStyleSetting paragraphStyleSettings[_kNumberOfSettings] = {
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &textAlignment}
    };
    
    CTParagraphStyleRef paragraphRef = CTParagraphStyleCreate(paragraphStyleSettings, _kNumberOfSettings);
    
    UIColor *textColor = config.textColor;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (__bridge id _Nullable)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id _Nullable)(fontRef);
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)paragraphRef;
    
    CFRelease(paragraphRef);
    CFRelease(fontRef);
    return [[NSAttributedString alloc] initWithString:string attributes:dict];
}

- (instancetype)initWithString:(NSString *)string config:(SJStringParserConfig *)config {
    return [self initWithAttributedString:[SJCTData _attrStrWithString:string onfig:config] config:config];
}

- (instancetype)initWithAttributedString:(NSAttributedString *)attrStr config:(SJCTFrameParserConfig *)config {
    self = [super init];
    if ( !self ) return nil;
    if ( 0 == attrStr.length ) return self;
    _drawingLinesM = [NSMutableArray array];
    _attrStr = attrStr;
    _config = config;
    [self parserAttrStr];
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

#pragma mark - parser

- (void)parserAttrStr {
    
    [self _updateConfigLineSpacing];
    
    [self _parserImageData];
    
    [self _createFrameRef];
    
    [self _settingImagesDelegate];
}

- (void)_updateConfigLineSpacing {
    [_attrStr enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0, _attrStr.length) options:kNilOptions usingBlock:^(id _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ( [value isKindOfClass:[NSParagraphStyle class]] ) {
            _config.lineSpacing = [(NSParagraphStyle *)value lineSpacing];
        }
        else {
            CGFloat lineSpacing = 0;
            CTParagraphStyleGetValueForSpecifier((CTParagraphStyleRef)value, kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing);
            _config.lineSpacing = lineSpacing;
        }
    }];
}

- (void)_createFrameRef {
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attrStr);
    CGSize constraints = CGSizeMake(_config.maxWidth, CGFLOAT_MAX);
    CGSize contentSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, 0), NULL, constraints, NULL);
    CGSize size = CGSizeMake(ceil(contentSize.width), ceil(contentSize.height));
    CGRect rect = (CGRect){CGPointZero, size};
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), path, NULL);
    self.frameRef = frameRef;
    _width = size.width;
    if ( path ) CFRelease(path);
    if ( framesetterRef ) CFRelease(framesetterRef);
    if ( frameRef ) CFRelease(frameRef);
}

#pragma mark - parser image

- (void)_parserImageData {
    NSMutableAttributedString *attrStrM = _attrStr.mutableCopy;
    NSMutableArray<SJCTImageData *> *imagesAttM = [NSMutableArray new];
    
    [_attrStr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, _attrStr.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSTextAttachment * _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        NSTextAttachment *attachment = value;
        if ( ! attachment ) return;
        [self _setPlaceholderSpaceWithAttrStrM:attrStrM range:range refCon:(__bridge void *)(attachment)];
        [imagesAttM addObject:[[SJCTImageData alloc] initWithImageAttachment:attachment position:(int)(range.location + range.length) bounds:value.bounds]];
    }];
    
    if ( 0 != imagesAttM.count ) {
        _attrStr = attrStrM;
        _imageDataArray = imagesAttM;
    }
}

- (void)_setPlaceholderSpaceWithAttrStrM:(NSMutableAttributedString *)attrStrM range:(NSRange)range refCon:(void *)refCon {
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, refCon);
    
    unichar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    
    NSMutableAttributedString *placeholderSpace =
    [[NSMutableAttributedString alloc] initWithString:content attributes:[attrStrM attributesAtIndex:range.location effectiveRange:NULL]];
    
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)placeholderSpace,
                                   CFRangeMake(0, 1),
                                   kCTRunDelegateAttributeName,
                                   delegate);
    CFRelease(delegate);
    [attrStrM replaceCharactersInRange:range withAttributedString:placeholderSpace];
}

- (void)_settingImagesDelegate {
    CTFrameRef frameRef = _frameRef;
    NSArray *lines = (NSArray *)CTFrameGetLines(frameRef);
    NSUInteger lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), lineOrigins);
    int imgIndex = 0;
    
    SJCTImageData *imageData = _imageDataArray[0];
    for ( int i = 0 ; i < lineCount ; ++ i ) {
        if ( imageData == nil ) break;
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray * runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        for ( id runObj in runObjArray ) {
            CTRunRef run = (__bridge CTRunRef)runObj;
            NSDictionary *runAttr = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttr valueForKey:(id)kCTRunDelegateAttributeName];
            id refCon = (id)CTRunDelegateGetRefCon(delegate);
            if ( NULL == delegate ||
                ![refCon isKindOfClass:[NSTextAttachment class]] ) continue;
            imgIndex++;
            if ( imgIndex == _imageDataArray.count ) {
                imageData = nil;
                break;
            }
            else {
                imageData = _imageDataArray[imgIndex];
            }
        }
    }
}

static CGFloat ascentCallback(void *ref){
    return [(__bridge NSTextAttachment *)ref bounds].size.height;
}

static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat widthCallback(void* ref){
    return [(__bridge NSTextAttachment *)ref bounds].size.width;
}

#pragma mark - drawing

- (void)needsDrawing {
    if ( 0 == _attrStr.length ) return;
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
        
        CTLineRef nextLine = CFArrayGetValueAtIndex(linesArr, lineIndex);
        CFRange nextRange = CTLineGetStringRange(nextLine);
        SJLineModel *recordLine = [SJLineModel new];
        
        NSAttributedString *nextAttStr = [_attrStr attributedSubstringFromRange:NSMakeRange(nextRange.location, nextRange.length)];
        __block UIFont *font = nil;
        [nextAttStr enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, nextAttStr.length) options:kNilOptions usingBlock:^(UIFont * _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if ( value.pointSize > font.pointSize ) font = value;
        }];
        
        if ( !font ) font = [SJStringParserConfig defaultFont];
        CGFloat descender = ABS(font.descender);
        __block CGFloat rowHeight = font.ascender + descender + font.leading;
        [self.imageDataArray enumerateObjectsUsingBlock:^(SJCTImageData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( obj.position > nextRange.location && obj.position < nextRange.location + nextRange.length ) {
                CGFloat imageH = obj.bounds.size.height;
                if ( imageH > rowHeight ) rowHeight = imageH;
                recordLine.hasImages = YES;
                [recordLine.images addObject:obj];
            }
        }];
        
        CGPoint nextOrigin = baseLineOrigins[lineIndex];
        recordLine.origin = nextOrigin;
        recordLine.ascent = rowHeight - descender;
        recordLine.descent = descender;
        recordLine.line = nextLine;
        recordLine.height = rowHeight;
        recordLine.range = nextRange;
        [_drawingLinesM addObject:recordLine];
        
        _height += rowHeight + _config.lineSpacing;
    }
    
    _height = ceil(_height -= _config.lineSpacing);
    
    // reset origins
    __block CGFloat r_height = 0;
    [_drawingLinesM enumerateObjectsUsingBlock:^(SJLineModel * _Nonnull lineModel, NSUInteger modelIdx, BOOL * _Nonnull stop) {
        lineModel.origin = CGPointMake( lineModel.origin.x, _height - (r_height + lineModel.ascent) );
        if ( lineModel.hasImages ) {
            [lineModel.images enumerateObjectsUsingBlock:^(SJCTImageData * _Nonnull imageData, NSUInteger imageIdx, BOOL * _Nonnull stop) {
                CGRect rect = imageData.bounds;
                CGFloat offset = CTLineGetOffsetForStringIndex(CFArrayGetValueAtIndex(linesArr, modelIdx), imageData.position - 1, NULL);
                rect = CGRectOffset( rect, offset, lineModel.origin.y - lineModel.descent );
                imageData.imagePosition = rect;
            }];
        }
        r_height += lineModel.height + _config.lineSpacing;
    }];
    
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
        
        _truncated = YES;
        _truncatedLineLocation = lastLineRange.location;
        _truncatedLineRange = NSMakeRange(lastLineRange.location, lastLineRange.length);
    }
    
    CGRect rect = CGRectMake(0.0f, 0.0f, _config.maxWidth, _height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, _height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [self drawingWithContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _contents = (__bridge id)image.CGImage;
}

- (void)drawingWithContext:(CGContextRef)context {
    if ( 0 == _attrStr.length ) return;
    @autoreleasepool {
        [self _drawingLineWithContent:context];
        [self _drawingImageWithContent:context];
    }
}

- (void)_drawingLineWithContent:(CGContextRef)context {
    [_drawingLinesM enumerateObjectsUsingBlock:^(SJLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGContextSetTextPosition(context, obj.origin.x, obj.origin.y);
        CTLineDraw(obj.line, context);
    }];
}

- (void)_drawingImageWithContent:(CGContextRef)context {
    NSInteger length = _truncatedLineRange.location + _truncatedLineRange.length;
    [_imageDataArray enumerateObjectsUsingBlock:^(SJCTImageData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( _truncated && ( obj.position > length ) ) return;
        
        UIImage *image = obj.imageAttachment.image;
        if ( image ) CGContextDrawImage(context, obj.imagePosition, image.CGImage);
    }];
}

#pragma mark - touch

- (signed long)touchIndexWithPoint:(CGPoint)point {
    __block CFIndex index = kCFNotFound;
    [_drawingLinesM enumerateObjectsUsingBlock:^(SJLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint origin = obj.origin;
        origin.y = _height - origin.y;
        CGFloat head = origin.y - obj.ascent;
        CGFloat tail = origin.y + ABS(obj.descent);
        
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
