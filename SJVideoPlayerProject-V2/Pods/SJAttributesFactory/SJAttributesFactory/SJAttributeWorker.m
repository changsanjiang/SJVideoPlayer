//
//  SJAttributeWorker.m
//  SJAttributeWorker
//
//  Created by 畅三江 on 2017/11/12.
//  Copyright © 2017年 畅三江. All rights reserved.
//

#import "SJAttributeWorker.h"
#import <CoreText/CoreText.h>
#import <objc/message.h>
#import "SJAttributesRecorder.h"

NS_ASSUME_NONNULL_BEGIN

NSMutableAttributedString *sj_makeAttributesString(void(^block)(SJAttributeWorker *make)) {
    SJAttributeWorker *worker = [SJAttributeWorker new];
    block(worker);
    return worker.endTask;
}

inline static BOOL _rangeContains(NSRange range, NSRange subRange) {
    return range.location <= subRange.location && range.length >= subRange.location + subRange.length;
}

inline static void _errorLog(NSString *msg, id __nullable target) {
    NSLog(@"\n__Error__: %@\nTarget: %@", msg, target);
}

#pragma mark -

@interface SJAttributesRangeOperator ()
@property (nonatomic, strong) SJAttributesRecorder *recorder;
@end

@implementation SJAttributesRangeOperator
- (SJAttributesRecorder *)recorder {
    if ( _recorder ) return _recorder;
    _recorder = [SJAttributesRecorder new];
    return _recorder;
}
@end

#pragma mark -

@interface SJAttributeWorker ()

@property (nonatomic, strong, readonly) NSMutableAttributedString *attrStr;
@property (nonatomic, strong, readonly) NSMutableArray<SJAttributesRangeOperator *> *rangeOperatorsM;

@end

@implementation SJAttributeWorker

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _defaultFont = [UIFont systemFontOfSize:14];
    _defaultTextColor = [UIColor blackColor];
    _attrStr = [NSMutableAttributedString new];
    _rangeOperatorsM = [NSMutableArray array];
    return self;
}

- (NSRange)range {
    return NSMakeRange(0, self.attrStr.length);
}

- (NSInteger)length {
    return self.attrStr.length;
}

- (void)pauseTask {
    [self endTask];
}

- (NSMutableAttributedString *)endTask {
    if ( 0 == self.attrStr.length ) return self.attrStr;
    if ( nil == self.recorder.font ) self.recorder.font = self.defaultFont;
    if ( nil == self.recorder.textColor ) self.recorder.textColor = self.defaultTextColor;

    [self.recorder addAttributes:self.attrStr];
    [self.rangeOperatorsM enumerateObjectsUsingBlock:^(SJAttributesRangeOperator * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.recorder addAttributes:self.attrStr];
    }];
    return self.attrStr;
}

- (NSMutableAttributedString *)endTaskAndComplete:(void(^)(SJAttributeWorker *worker))block; {
    [self endTask];
    if ( block ) block(self);
    return self.attrStr;
}

/// 范围编辑. 可以配合正则使用.
- (SJAttributeWorker * _Nonnull (^)(NSRange, void (^ _Nonnull)(SJAttributesRangeOperator * _Nonnull)))rangeEdit {
    return ^ SJAttributeWorker *(NSRange range, void(^task)(SJAttributesRangeOperator *matched)) {
        if ( !_rangeContains(self.range, range) ) {
            _errorLog(@"Edit Failed! param 'range' is unlawfulness!", self.attrStr.string);
            return self;
        }
        SJAttributesRangeOperator *rangeOperator = [self _getRangeOperatorWithRange:range];
        task(rangeOperator);
        return self;
    };
}

/// sub attr str
- (NSAttributedString * _Nonnull (^)(NSRange))subAttrStr {
    return ^ NSAttributedString *(NSRange subRange) {
        if ( !_rangeContains(self.range, subRange) ) {
            _errorLog(@"Get `subAttributedString` Failed! param 'range' is unlawfulness!", self.attrStr.string);
            return nil;
        }
        [self pauseTask];
        return [self.attrStr attributedSubstringFromRange:subRange];
    };
}

- (SJAttributesRangeOperator *)_getRangeOperatorWithRange:(NSRange)range {
    __block SJAttributesRangeOperator *rangeOperator = nil;
    [self.rangeOperatorsM enumerateObjectsUsingBlock:^(SJAttributesRangeOperator * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange objRange = obj.recorder.range;
        if ( objRange.location == range.location && objRange.length == range.length ) {
            rangeOperator = obj;
            *stop = YES;
        }
    }];
    
    if ( rangeOperator ) return rangeOperator;
    
    [self.rangeOperatorsM enumerateObjectsUsingBlock:^(SJAttributesRangeOperator * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange objRange = obj.recorder.range;
        if ( _rangeContains(objRange, range) ) {
            rangeOperator = [SJAttributesRangeOperator new];
            rangeOperator.recorder = obj.recorder.copy;
            rangeOperator.recorder.range = range;
            [self.rangeOperatorsM addObject:rangeOperator];
            *stop = YES;
        }
    }];
    
    if ( rangeOperator ) return rangeOperator;
    
    rangeOperator = [SJAttributesRangeOperator new];
    rangeOperator.recorder.range = range;
    [self.rangeOperatorsM addObject:rangeOperator];
    return rangeOperator;
}
@end

#pragma mark - regular
@implementation SJAttributeWorker(Regexp)
/// 正则匹配
- (SJAttributeWorker * _Nonnull (^)(NSString * _Nonnull, void (^ _Nonnull)(SJAttributesRangeOperator * _Nonnull)))regexp {
    return ^ SJAttributeWorker *(NSString *regStr, void(^task)(SJAttributesRangeOperator *matched)) {
        return self.regexp_r(regStr, ^(NSArray<NSValue *> * _Nonnull matchedRanges) {
            [matchedRanges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange matchedRange = [obj rangeValue];
                self.rangeEdit(matchedRange, task);
            }];
        }, YES);
    };
}
/// 正则匹配. [NSRange]
- (SJAttributeWorker * _Nonnull (^)(NSString * _Nonnull, void (^ _Nonnull)(NSArray<NSValue *> * _Nonnull), BOOL reverse))regexp_r {
    return ^ SJAttributeWorker *(NSString *regStr, void(^task)(NSArray<NSValue *> *ranges), BOOL reverse) {
        NSMutableArray<NSValue *> *rangesM = [NSMutableArray array];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr options:kNilOptions error:nil];
        [regex enumerateMatchesInString:self.attrStr.string options:NSMatchingWithoutAnchoringBounds range:self.range usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if ( result ) { [rangesM addObject:[NSValue valueWithRange:result.range]];}
        }];
        if ( reverse ) {
            NSMutableArray<NSValue *> *reverseM = [NSMutableArray array];
            [rangesM enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [reverseM addObject:obj];}];
            rangesM = reverseM;
        }
        task(rangesM);
        return self;
    };
}

@end


#pragma mark - size
@implementation SJAttributeWorker(Size)

- (CGSize (^)(void))size {
    return ^ CGSize() {
        return [self sizeWithAttrString:self.attrStr width:CGFLOAT_MAX height:CGFLOAT_MAX];
    };
}

- (CGSize (^)(NSRange))sizeByRange {
    return ^ CGSize (NSRange byRange) {
        return [self sizeWithAttrString:self.subAttrStr(byRange) width:CGFLOAT_MAX height:CGFLOAT_MAX];
    };
}
- (CGSize (^)(double))sizeByHeight {
    return ^ CGSize (double height) {
        return [self sizeWithAttrString:self.attrStr width:CGFLOAT_MAX height:height];
    };
}
- (CGSize (^)(double))sizeByWidth {
    return ^ CGSize (double width) {
        return [self sizeWithAttrString:self.attrStr width:width height:CGFLOAT_MAX];
    };
}
- (CGSize)sizeWithAttrString:(NSAttributedString *)attrStr width:(double)width height:(double)height {
    if ( 0 == attrStr ) {
        _errorLog(@"Get `size` Failed! param 'attrStr' is empty!", nil);
        return CGSizeZero;
    }
    [self pauseTask];
    CGRect bounds = [attrStr boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    bounds.size.width = ceil(bounds.size.width);
    bounds.size.height = ceil(bounds.size.height);
    return bounds.size;
}
@end



#pragma mark - insert
@implementation SJAttributeWorker(Insert)

- (void)setLastInsertedRange:(NSRange)lastInsertedRange {
    objc_setAssociatedObject(self, @selector(lastInsertedRange), [NSValue valueWithRange:lastInsertedRange], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSRange)lastInsertedRange {
    return [objc_getAssociatedObject(self, _cmd) rangeValue];
}
- (SJAttributeWorker * _Nonnull (^)(void (^ _Nonnull)(SJAttributesRangeOperator * _Nonnull)))lastInserted {
    return ^ SJAttributeWorker *(void(^task)(SJAttributesRangeOperator *lastOperator)) {
        return self.rangeEdit(self.lastInsertedRange, task);
    };
}
- (SJAttributeWorker * _Nonnull (^)(NSAttributedStringKey _Nonnull, id _Nonnull, NSRange))add {
    return ^ SJAttributeWorker *(NSAttributedStringKey key, id value, NSRange range) {
        if ( !key || !value ) {
            _errorLog(@"Added Attribute Failed! param `key or value` is Empty!", self.attrStr.string);
            return self;
        }
        [self.attrStr addAttribute:key value:value range:range];
        return self;
    };
}
- (SJAttributeWorker * _Nonnull (^)(NSString * _Nonnull, NSInteger))insertText {
    return ^ SJAttributeWorker *(NSString *text, NSInteger idx) {
        if ( 0 == text.length ) {
            _errorLog(@"inset `text` Failed! param `text` is Empty!", self.attrStr.string);
            return self;
        }
        return self.insertAttrStr([[NSAttributedString alloc] initWithString:text], idx);
    };
}
- (SJAttributeWorker * _Nonnull (^)(UIImage * _Nonnull, NSInteger, CGPoint, CGSize))insertImage {
    return ^ SJAttributeWorker *(UIImage *image, NSInteger idx, CGPoint offset, CGSize size) {
        if ( nil == image ) {
            _errorLog(@"inset `image` Failed! param `image` is Empty!", self.attrStr.string);
            return self;
        }
        NSTextAttachment *attachment = [NSTextAttachment new];
        attachment.image = image;
        attachment.bounds = (CGRect){offset, size};
        return self.insertAttrStr([NSAttributedString attributedStringWithAttachment:attachment], idx);
    };
}
- (SJAttributeWorker * _Nonnull (^)(NSAttributedString * _Nonnull, NSInteger))insertAttrStr {
    return ^ SJAttributeWorker *(NSAttributedString *text, NSInteger idx) {
        if ( 0 == text.length ) {
            _errorLog(@"inset `text` Failed! param `text` is Empty!", self.attrStr.string);
            return self;
        }
        if ( -1 == idx || idx > self.attrStr.length ) {
            idx = self.attrStr.length;
        }
        self.lastInsertedRange = NSMakeRange(idx, text.length);
        [self.attrStr insertAttributedString:text atIndex:idx];
        return self;
    };
}
- (SJAttributeWorker * _Nonnull (^)(id _Nonnull, NSInteger, ...))insert {
    return ^ SJAttributeWorker *(id strOrAttrStrOrImg, NSInteger idx, ...) {
        va_list args;
        va_start(args, idx);
        if      ( [strOrAttrStrOrImg isKindOfClass:[NSString class]] ) {
            self.insertText(strOrAttrStrOrImg, idx);
        }
        else if ( [strOrAttrStrOrImg isKindOfClass:[NSAttributedString class]] ) {
            self.insertAttrStr(strOrAttrStrOrImg, idx);
        }
        else if ( [strOrAttrStrOrImg isKindOfClass:[UIImage class]] ) {
            self.insertImage(strOrAttrStrOrImg, idx, va_arg(args, CGPoint), va_arg(args, CGSize));
        }
        else {
            _errorLog(@"inset `text` Failed! param `strOrAttrStrOrImg` is Unlawfulness!", self.attrStr.string);
        }
        va_end(args);
        return self;
    };
}
@end




#pragma mark - replace
@implementation SJAttributeWorker(Replace)
- (void (^)(NSRange, id _Nonnull, ...))replace {
    return ^ void (NSRange range, id strOrAttrStrOrImg, ...) {
        if ( !_rangeContains(self.range, range) ) {
            _errorLog(@"Replace Failed! param 'range' is unlawfulness!", self.attrStr.string);
            return;
        }
        va_list args;
        va_start(args, strOrAttrStrOrImg);
        if      ( [strOrAttrStrOrImg isKindOfClass:[NSString class]] ) {
            [self.attrStr replaceCharactersInRange:range withString:strOrAttrStrOrImg];
        }
        else if ( [strOrAttrStrOrImg isKindOfClass:[NSAttributedString class]] ) {
            [self.attrStr replaceCharactersInRange:range withAttributedString:strOrAttrStrOrImg];
        }
        else if ( [strOrAttrStrOrImg isKindOfClass:[UIImage class]] ) {
            NSTextAttachment *attachment = [NSTextAttachment new];
            attachment.image = strOrAttrStrOrImg;
            attachment.bounds = (CGRect){va_arg(args, CGPoint), va_arg(args, CGSize)};
            [self.attrStr replaceCharactersInRange:range withAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        }
        else {
            _errorLog(@"inset `text` Failed! param `strOrAttrStrOrImg` is Unlawfulness!", self.attrStr.string);
        }
        va_end(args);
    };
}
@end


#pragma mark - delete
@implementation SJAttributeWorker(Delete)
//@property (nonatomic, copy, readonly) void(^removeText)(NSRange range);
//@property (nonatomic, copy, readonly) void(^removeAttribute)(NSAttributedStringKey key, NSRange range);
//@property (nonatomic, copy, readonly) void(^removeAttributes)(NSRange range);
- (void (^)(NSRange))removeText {
    return ^ (NSRange range) {
        if ( !_rangeContains(self.range, range) ) {
            _errorLog(@"Remove Failed! param 'range' is unlawfulness!", self.attrStr.string);
        }
        else {
            [self.attrStr deleteCharactersInRange:range];
        }
    };
}
- (void (^)(NSAttributedStringKey _Nonnull, NSRange))removeAttribute {
    return ^ (NSAttributedStringKey key, NSRange range) {
        if ( !_rangeContains(self.range, range) ) {
            _errorLog(@"Remove Failed! param 'range' is unlawfulness!", self.attrStr.string);
        }
        else {
            [self.attrStr removeAttribute:key range:range];
        }
    };
}
- (void (^)(NSRange))removeAttributes {
    return ^ (NSRange range) {
        if ( !_rangeContains(self.range, range) ) {
            _errorLog(@"Remove Failed! param 'range' is unlawfulness!", self.attrStr.string);
        }
        else {
            NSString *subAttrStr = self.subAttrStr(range).string;
            self.replace(range, subAttrStr);
        }
    };
}
@end


#pragma mark - property
@implementation SJAttributesRangeOperator(Property)

/// 字体
- (SJAttributesRangeOperator * _Nonnull (^)(UIFont * _Nonnull))font {
    return ^ SJAttributesRangeOperator *(UIFont *font) {
        self.recorder.font = font;
        return self;
    };
}
/// 文本颜色
- (SJAttributesRangeOperator * _Nonnull (^)(UIColor * _Nonnull))textColor {
    return ^ SJAttributesRangeOperator *(UIColor *textColor) {
        self.recorder.textColor = textColor;
        return self;
    };
}
/// 放大, 扩大
- (SJAttributesRangeOperator * _Nonnull (^)(double))expansion {
    return ^ SJAttributesRangeOperator *(double expansion) {
        self.recorder.expansion = expansion;
        return self;
    };
}
/// 阴影
- (SJAttributesRangeOperator * _Nonnull (^)(CGSize, CGFloat, UIColor * _Nonnull))shadow {
    return ^ SJAttributesRangeOperator *(CGSize shadowOffset, CGFloat shadowBlurRadius, UIColor *shadowColor) {
        if ( nil != self.recorder.backgroundColor ) {
            _errorLog(@"`shadow`会与`backgroundColor`冲突, 设置了`backgroundColor`后, `shadow`将不会显示.", [NSValue valueWithRange:self.recorder.range]);
        }
        NSShadow *shadow = [NSShadow new];
        shadow.shadowOffset = shadowOffset;
        shadow.shadowBlurRadius = shadowBlurRadius;
        shadow.shadowColor = shadowColor;
        self.recorder.shadow = shadow;
        return self;
    };
}
/// 背景颜色
- (SJAttributesRangeOperator * _Nonnull (^)(UIColor * _Nonnull))backgroundColor {
    return ^ SJAttributesRangeOperator *(UIColor *color) {
        if ( nil != self.recorder.shadow ) {
            _errorLog(@"`shadow`会与`backgroundColor`冲突, 设置了`backgroundColor`后, `shadow`将不会显示.", [NSValue valueWithRange:self.recorder.range]);
        }
        self.recorder.backgroundColor = color;
        return self;
    };
}
/// 下划线
- (SJAttributesRangeOperator * _Nonnull (^)(NSUnderlineStyle, UIColor * _Nonnull))underLine {
    return ^ SJAttributesRangeOperator *(NSUnderlineStyle style, UIColor *color) {
        self.recorder.underLine = [SJUnderlineAttribute underLineWithStyle:style color:color];
        return self;
    };
}
/// 删除线
- (SJAttributesRangeOperator * _Nonnull (^)(NSUnderlineStyle, UIColor * _Nonnull))strikethrough {
    return ^ SJAttributesRangeOperator *(NSUnderlineStyle style, UIColor *color) {
        self.recorder.strikethrough = [SJUnderlineAttribute underLineWithStyle:style color:color];
        return self;
    };
}
/// 边界`border`
- (SJAttributesRangeOperator * _Nonnull (^)(UIColor * _Nonnull, double))stroke {
    return ^ SJAttributesRangeOperator *(UIColor * color, double stroke) {
        self.recorder.stroke = [SJStrokeAttribute strokeWithValue:stroke color:color];
        return self;
    };
}
/// 倾斜(-1 ... 1)
- (SJAttributesRangeOperator * _Nonnull (^)(double))obliqueness {
    return ^ SJAttributesRangeOperator *(double obliqueness) {
        self.recorder.obliqueness = obliqueness;
        return self;
    };
}
/// 字间隔
- (SJAttributesRangeOperator * _Nonnull (^)(double))letterSpacing {
    return ^ SJAttributesRangeOperator *(double letterSpacing) {
        self.recorder.letterSpacing = letterSpacing;
        return self;
    };
}
/// 上下偏移
- (SJAttributesRangeOperator * _Nonnull (^)(double))offset {
    return ^ SJAttributesRangeOperator *(double offset) {
        self.recorder.offset = offset;
        return self;
    };
}
/// 链接
- (SJAttributesRangeOperator * _Nonnull (^)(void))isLink {
    return ^ SJAttributesRangeOperator *() {
        self.recorder.link = YES;
        return self;
    };
}
/// 段落 style
- (SJAttributesRangeOperator * _Nonnull (^)(NSParagraphStyle * _Nonnull))paragraphStyle {
    return ^ SJAttributesRangeOperator *(NSParagraphStyle *style) {
        self.recorder.paragraphStyleM = style.mutableCopy;
        return self;
    };
}
/// 行间隔
- (SJAttributesRangeOperator * _Nonnull (^)(double))lineSpacing {
    return ^ SJAttributesRangeOperator *(double lineSpacing) {
        self.recorder.lineSpacing = lineSpacing;
        return self;
    };
}
/// 段后间隔(\n)
- (SJAttributesRangeOperator * _Nonnull (^)(double))paragraphSpacing {
    return ^ SJAttributesRangeOperator *(double paragraphSpacing) {
        self.recorder.paragraphSpacing = paragraphSpacing;
        return self;
    };
}
/// 段前间隔(\n)
- (SJAttributesRangeOperator * _Nonnull (^)(double))paragraphSpacingBefore {
    return ^ SJAttributesRangeOperator *(double paragraphSpacingBefore) {
        self.recorder.paragraphSpacingBefore = paragraphSpacingBefore;
        return self;
    };
}
/// 首行头缩进
- (SJAttributesRangeOperator * _Nonnull (^)(double))firstLineHeadIndent {
    return ^ SJAttributesRangeOperator *(double firstLineHeadIndent) {
        self.recorder.firstLineHeadIndent = firstLineHeadIndent;
        return self;
    };
}
/// 左缩进
- (SJAttributesRangeOperator * _Nonnull (^)(double))headIndent {
    return ^ SJAttributesRangeOperator *(double headIndent) {
        self.recorder.headIndent = headIndent;
        return self;
    };
}
/// 右缩进(正值从左算起, 负值从右算起)
- (SJAttributesRangeOperator * _Nonnull (^)(double))tailIndent {
    return ^ SJAttributesRangeOperator *(double tailIndent) {
        self.recorder.tailIndent = tailIndent;
        return self;
    };
}
/// 对齐方式
- (SJAttributesRangeOperator * _Nonnull (^)(NSTextAlignment))alignment {
    return ^ SJAttributesRangeOperator *(NSTextAlignment alignment) {
        self.recorder.alignment = alignment;
        return self;
    };
}
/// 截断模式
- (SJAttributesRangeOperator * _Nonnull (^)(NSLineBreakMode))lineBreakMode {
    return ^ SJAttributesRangeOperator *(NSLineBreakMode lineBreakMode) {
        self.recorder.lineBreakMode = lineBreakMode;
        return self;
    };
}
@end

NS_ASSUME_NONNULL_END
