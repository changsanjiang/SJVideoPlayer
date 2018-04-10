//
//  SJAttributeWorker.h
//  SJAttributeWorker
//
//  Created by 畅三江 on 2017/11/12.
//  Copyright © 2017年 畅三江. All rights reserved.
//
//  Project Address: https://github.com/changsanjiang/SJAttributesFactory
//  Email:  changsanjiang@gmail.com
//

#import <UIKit/UIKit.h>
#import "SJAttributesRecorder.h"

@class SJAttributeWorker;

NS_ASSUME_NONNULL_BEGIN

/*!
 *  make attributed string:
 
 *   NSAttributedString *attrStr = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
 
 *       // set font , text color.
 *       make.font([UIFont boldSystemFontOfSize:14]).textColor([UIColor blackColor]);
 
 *       make.append(@"@迷你世界联机 :@江叔 用小淘气耍赖野人#迷你世界#");
 
 *       make.regexp(@"[@][^@]+\\s", ^(SJAttributesRangeOperator * _Nonnull matched) {
 *           matched.textColor([UIColor purpleColor]);
 *          // some code
 *       });
 
 *       make.regexp(@"[#][^#]+#", ^(SJAttributesRangeOperator * _Nonnull matched) {
 *          matched.textColor([UIColor orangeColor]);
 *          // some code
 *       });
 *   });
 **/
extern NSMutableAttributedString *sj_makeAttributesString(void(^block)(SJAttributeWorker *make));

#pragma mark -
@interface SJAttributesRangeOperator: NSObject
@property (nonatomic, strong, nullable) SJAttributesRecorder *recorder;
@end


#pragma mark -

@interface SJAttributeWorker : SJAttributesRangeOperator

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign, readonly) NSRange range;

@property (nonatomic, assign, readonly) NSMutableAttributedString *workInProcess;

- (NSMutableAttributedString *)endTask;

- (NSMutableAttributedString *)endTaskAndComplete:(void(^)(SJAttributeWorker *worker))block;

/*!
 *  default font.
 *
 *  default is UIFont.systemFont(ofSize: 14)
 **/
@property (nonatomic, strong) UIFont *defaultFont;

/*!
 *  default textColor.
 *
 *  default is UIColor.black
 **/
@property (nonatomic, strong) UIColor *defaultTextColor;

/*!
 *  range editing. can be used it with `regexp` method.
 *
 *  范围编辑, 可以配合正则使用.
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^rangeEdit)(NSRange range, void (^task)(SJAttributesRangeOperator *make));

/*!
 *  get sub attributedString by `range`.
 *
 *  按照范围获取文本
 **/
@property (nonatomic, copy, readonly) NSAttributedString *(^subAttrStr)(NSRange subRange);

@property (nonatomic, assign, readonly) NSInteger length;

@end


#pragma mark - 正则 - regexp
@interface SJAttributeWorker(Regexp)

/**
 default is kNilOptions
 */
@property (nonatomic, readwrite) NSRegularExpressionOptions regexpOptions;


/*!
 *  regular expression.
 *
 *  正则匹配
 *
 make.regexp(@"Hello", ^(SJAttributesRangeOperator * _Nonnull matched) {
    matched.font([UIFont systemFontOfSize:18]).textColor([UIColor redColor]);
 });
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^regexp)(NSString *regStr, void(^matchedTask)(SJAttributesRangeOperator *make));


/*!
 *  regular expression. value is [NSRange].
 *
 *  正则匹配
 *
 make.regexp_r(@"H", ^(NSArray<NSValue *> * _Nonnull matchedRanges) {
    [matchedRanges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange matchedRange = [obj rangeValue];

        make.replace(matchedRange, @"h");
        NSInteger index = matchedRange.location + matchedRange.length;
        make.insert(@"ello", index); // h + ello == hello
    }];
 }, YES);
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^regexp_r)(NSString *regStr, void(^matchedTask)(NSArray<NSValue *> *matchedRanges), BOOL reverse);


/**
 make.regexp_replace(@"Hello", @" World!");
 make.regexp_replace(@"Hello", [UIImage imageNamed:@"sample2"], CGPointZero, CGSizeZero);
 */
@property (nonatomic, copy, readonly) void(^regexp_replace)(NSString *regexp, id replaceByStrOrAttrStrOrImg, ...);


typedef NS_ENUM(NSUInteger, SJAttributeRegexpInsertPosition) {
    SJAttributeRegexpInsertPositionLeft,
    SJAttributeRegexpInsertPositionRight,
};
/**
 make.regexp_insert(@"Hello", SJAttributeRegexpInsertPositionRight, @" World!");
 make.regexp_insert(@"Hello", SJAttributeRegexpInsertPositionRight, [UIImage imageNamed:@"sample2"], CGPointZero, CGSizeZero);
 */
@property (nonatomic, copy, readonly) void(^regexp_insert)(NSString *regexp, SJAttributeRegexpInsertPosition position, id insertingStrOrAttrStrOrImg, ...);

@end




#pragma mark - 大小 - size
@interface SJAttributeWorker(Size)
@property (nonatomic, copy, readonly) CGSize(^size)(void);
@property (nonatomic, copy, readonly) CGSize(^sizeByRange)(NSRange range);
@property (nonatomic, copy, readonly) CGSize(^sizeByWidth)(double maxWidth);
@property (nonatomic, copy, readonly) CGSize(^sizeByHeight)(double maxHeight);
@end




#pragma mark - 插入 - insert
@interface SJAttributeWorker(Insert)

#pragma mark - 常用方法

/**
 append text.
 
 make.append(@"Hello").font([UIFont systemFontOfSize:14]).textColor([UIColor yellowColor]);
 make.append([UIImage imageNamed:@"sample2"], CGPointZero, CGSizeZero);
 */
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^append)(id strOrImg, ...);




#pragma mark -
/*!
 *  the range of the last inserted text.
 *
 *  最近一次插入的文本的范围.
 **/
@property (nonatomic, assign, readonly) NSRange lastInsertedRange;
/*!
 *  editing the last inserted text
 *
 *  编辑最后插入的文本.
 
 make.lastInserted(^(SJAttributesRangeOperator * _Nonnull lastOperator) {
    lastOperator.textColor([UIColor redColor]);
    lastOperator.font([UIFont boldSystemFontOfSize:17]);
 });
 
 4/10 2018 : Because someone ignores the `last operator` and uses `make`, I change the `last operator` to `make`
 
 For example: editing the last inserted text.
 make.lastInserted(^(SJAttributesRangeOperator * _Nonnull make) {
    // so it's editing the last inserted text
    make.textColor([UIColor redColor]);
    make.font([UIFont boldSystemFontOfSize:17]);
 });
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^lastInserted)(void(^task)(SJAttributesRangeOperator *make));
/*!
 *  add attribute of `key, value, range`.
 *
 *  添加
 *
 make.add(YYTextBackgroundBorderAttributeName, border, range);
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^add)(NSAttributedStringKey key, id value, NSRange range);
/*!
 *  insert text, `-1` indicates the insertion to the end.
 *
 *  插入文本, `-1` 表示插入到最后
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^insertText)(NSString *text, NSInteger index);
/*!
 *  insert image, `-1` indicates the insertion to the end.
 *  if size == CGSizeZero, the image size will be used.
 *
 *  插入图片, `-1` 表示插入到最后
 *  如果 size == CGSizeZero, 将使用图片的size
 make.insert([UIImage imageNamed:@"sample2"], -1, CGPointZero, CGSizeZero);
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^insertImage)(UIImage *image, NSInteger index, CGPoint offset, CGSize size);
/*!
 *  inset text, `-1` indicates the insertion to the end.
 *
 *  插入文本, `-1` 表示插入到最后
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^insertAttrStr)(NSAttributedString *text, NSInteger index);

/*!
 *  inset text or image, `-1` indicates the insertion to the end.
 *
 *  插入, `-1` 表示插入到最后
 *
 make.insert(@"Hello", -1);
 make.insert([UIImage imageNamed:@"sample2"], 12, CGPointZero, CGSizeMake(50, 50));
 make.insert([UIImage imageNamed:@"sample2"], -1, CGPointZero, CGSizeZero);
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^insert)(id strOrAttrStrOrImg, NSInteger idx, ...);

@end



#pragma mark - 替换 - replace
@interface SJAttributeWorker(Replace)
/**
 make.replace(NSMakeRange(0, 2), @"Hello world!");
 make.replace(NSMakeRange(0, 2), [UIImage imageNamed:@"name"], CGPointZero, CGSizeZero);
 
 or use regular expression
 
 make.regexp_r(@"[#][^#]+#", ^(NSArray<NSValue *> * _Nonnull matchedRanges) {
    [matchedRanges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        make.replace([obj rangeValue], @"replace the result");
    }];
 }, YES);
 */
@property (nonatomic, copy, readonly) void(^replace)(NSRange range, id strOrAttrStrOrImg, ...);
@end



#pragma mark - 删除 - remove
@interface SJAttributeWorker(Delete)
@property (nonatomic, copy, readonly) void(^removeText)(NSRange range);
@property (nonatomic, copy, readonly) void(^removeAttribute)(NSAttributedStringKey key, NSRange range);
@property (nonatomic, copy, readonly) void(^removeAttributes)(NSRange range);
@end



#pragma mark - 属性 - property
@interface SJAttributesRangeOperator(Property)

/// 字体
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^font)(UIFont *font);
/// 文本颜色
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^textColor)(UIColor *color);
/// 放大, 扩大
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^expansion)(double expansion);
/// 阴影. note: `shadow`会与`backgroundColor`冲突, 设置了`backgroundColor`后, `shadow`将不会显示.
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^shadow)(CGSize shadowOffset, CGFloat shadowBlurRadius, UIColor *shadowColor);
/// 背景颜色
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^backgroundColor)(UIColor *color);
/// 下划线
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^underLine)(NSUnderlineStyle style, UIColor *color);
/// 删除线
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^strikethrough)(NSUnderlineStyle style, UIColor *color);
/// 边界
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^stroke)(UIColor *color, double stroke);
/// 倾斜(-1 ... 1)
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^obliqueness)(double obliqueness);
/// 字间隔
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^letterSpacing)(double letterSpacing);
/// 上下偏移, 正值向上, 负值向下
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^offset)(double offset);
/// 链接
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^isLink)(void);
/// 段落 style
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^paragraphStyle)(NSParagraphStyle *style);
/// 行间隔
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^lineSpacing)(double lineSpacing);
/// 段后间隔(\n)
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^paragraphSpacing)(double paragraphSpacing);
/// 段前间隔(\n)
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^paragraphSpacingBefore)(double paragraphSpacingBefore);
/// 首行头缩进
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^firstLineHeadIndent)(double firstLineHeadIndent);
/// 左缩进
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^headIndent)(double headIndent);
/// 右缩进(正值从左算起, 负值从右算起)
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^tailIndent)(double tailIndent);
/// 对齐方式
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^alignment)(NSTextAlignment alignment);
/// 截断模式
@property (nonatomic, copy, readonly) SJAttributesRangeOperator *(^lineBreakMode)(NSLineBreakMode lineBreakMode);

@end

NS_ASSUME_NONNULL_END
