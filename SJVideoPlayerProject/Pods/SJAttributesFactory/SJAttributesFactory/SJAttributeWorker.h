//
//  SJAttributeWorker.h
//  SJAttributeWorker
//
//  Created by 畅三江 on 2017/11/12.
//  Copyright © 2017年 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJAttributedStringKeys.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJAttributeWorker : NSObject

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (NSAttributedString *)endTask;

#pragma mark - All
/*!
 *  Setting the whole may affect the local range properties,
 *  please set the whole first, and then set the local range properties.
 *
 *  设置整体可能会影响局部范围属性, 请先设置整体, 然后再设置局部范围属性.
 *  也可不设置整体, 只设置局部属性.
 **/
/// 整体 字体
@property (nonatomic, copy, readonly) SJAttributeWorker *(^font)(UIFont *font);
/// 整体 放大
@property (nonatomic, copy, readonly) SJAttributeWorker *(^expansion)(float expansion);
/// 整体 字体颜色
@property (nonatomic, copy, readonly) SJAttributeWorker *(^fontColor)(UIColor *fontColor);
/// 整体 字体阴影
@property (nonatomic, copy, readonly) SJAttributeWorker *(^shadow)(NSShadow *shadow);
/// 整体 背景颜色
@property (nonatomic, copy, readonly) SJAttributeWorker *(^backgroundColor)(UIColor *color);
/// 整体 每行间隔
@property (nonatomic, copy, readonly) SJAttributeWorker *(^lineSpacing)(float spacing);
/// 整体 段后间隔(\n)
@property (nonatomic, copy, readonly) SJAttributeWorker *(^paragraphSpacing)(float paragraphSpacing);
/// 整体 段前间隔(\n)
@property (nonatomic, copy, readonly) SJAttributeWorker *(^paragraphSpacingBefore)(float paragraphSpacingBefore);
/// 首行头缩进
@property (nonatomic, copy, readonly) SJAttributeWorker *(^firstLineHeadIndent)(float padding);
/// 左缩进
@property (nonatomic, copy, readonly) SJAttributeWorker *(^headIndent)(float headIndent);
/// 右缩进(正值从左算起, 负值从右算起)
@property (nonatomic, copy, readonly) SJAttributeWorker *(^tailIndent)(float tailIndent);
/// 整体 字间隔
@property (nonatomic, copy, readonly) SJAttributeWorker *(^letterSpacing)(float spacing);
/// 整体 对齐方式
@property (nonatomic, copy, readonly) SJAttributeWorker *(^alignment)(NSTextAlignment alignment);
/// line break mode
@property (nonatomic, copy, readonly) SJAttributeWorker *(^lineBreakMode)(NSLineBreakMode mode);
/*!
 *  整体 添加下划线
 *  ex:
 *  worker.underline(NSUnderlineByWord |
 *                   NSUnderlinePatternSolid |
 *                   NSUnderlineStyleDouble, [UIColor blueColor])
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^underline)(NSUnderlineStyle style, UIColor *color);
/*!
 *  整体 添加删除线
 *  ex:
 *  worker.strikethrough(NSUnderlineByWord |
 *                       NSUnderlinePatternSolid |
 *                       NSUnderlineStyleDouble, [UIColor blueColor])
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^strikethrough)(NSUnderlineStyle style, UIColor *color);
/// border 如果大于0, 则显示的是空心字体. 如果小于0, 则显示实心字体(就像正常字体那样, 只不过是描边了).
@property (nonatomic, copy, readonly) SJAttributeWorker *(^stroke)(float border, UIColor *color);
/// 整体 凸版
@property (nonatomic, copy, readonly) SJAttributeWorker *(^letterpress)(void);
/// 整体 链接
@property (nonatomic, copy, readonly) SJAttributeWorker *(^link)(void);
/// 整体 段落样式
@property (nonatomic, copy, readonly) SJAttributeWorker *(^paragraphStyle)(NSParagraphStyle *style);
/// 整体 倾斜. 建议值 -1 到 1 之间.
@property (nonatomic, copy, readonly) SJAttributeWorker *(^obliqueness)(float obliqueness);
/// key: NSAttributedStringKey
@property (nonatomic, copy, readonly) SJAttributeWorker *(^addAttribute)(NSAttributedStringKey key, id value);
/// 点击触发动作(需要配合 SJLabel 使用)
@property (nonatomic, copy, readonly) SJAttributeWorker *(^action)(void(^task)(NSRange range, NSAttributedString *matched));



#pragma mark - Range
/*!
 *  range Edit 1:
 *  [SJAttributesFactory alteringStr:@"I am a bad man!" task:^(SJAttributeWorker * _Nonnull worker) {
 *      worker.alteringRange(NSMakeRange(0, 1), ^(SJAttributeWorker * _Nonnull range) {
 *           range
 *              .nextFont([UIFont boldSystemFontOfSize:30])
 *              .nextFontColor([UIColor orangeColor]);
 *      });
 *  }];
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^rangeEdit)(NSRange range, void(^task)(SJAttributeWorker *range));
/*!
 *  range Edit 2:
 *  [SJAttributesFactory alteringStr:[NSString stringWithFormat:@"%@%@%@", pre, mid, end] task:^(SJAttributeWorker * _Nonnull worker) {
 *      worker
 *      .nextFont([UIFont boldSystemFontOfSize:12])
 *      .nextFontColor([UIColor yellowColor])
 *      .nextAlignment(NSTextAlignmentRight)
 *      .range(NSMakeRange(pre.length, mid.length));  // -->>>>> must set it up.
 *  }];
 **/
@property (nonatomic, copy, readonly) void(^range)(NSRange range);
/// 指定范围内的 字体
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextFont)(UIFont *font);
/// 指定范围内的 字体放大
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextExpansion)(float nextExpansion);
/// 指定范围内的 字体颜色
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextFontColor)(UIColor *fontColor);
/// 指定范围内的 阴影
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextShadow)(NSShadow *shadow);
/// 指定范围内的 背景颜色
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextBackgroundColor)(UIColor *color);
/// 指定范围内的 字间隔
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextLetterSpacing)(float spacing);
/// 指定范围内的 行间隔
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextLineSpacing)(float lineSpacing);
/// 指定范围内的 段后间隔(\n)
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextParagraphSpacing)(float paragraphSpacing);
/// 指定范围内的 段前间隔(\n)
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextParagraphSpacingBefore)(float paragraphSpacingBefore);
/// 指定范围内的 首行头缩进
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextFirstLineHeadIndent)(float padding);
/// 指定范围内的 左缩进
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextHeadIndent)(float headIndent);
/// 指定范围内的 右缩进(正值从左算起, 负值从右算起)
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextTailIndent)(float tailIndent);
/// 指定范围内的 对齐方式
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextAlignment)(NSTextAlignment alignment);
/// 指定范围内的 下划线
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextUnderline)(NSUnderlineStyle style, UIColor *color);
/// 指定范围内的 删除线
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextStrikethough)(NSUnderlineStyle style, UIColor *color);
/// 指定范围内的 填充. 效果同 storke.
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextStroke)(float border, UIColor *color);
/// 指定范围内的 凸版
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextLetterpress)(void);
/// 指定范围内为链接
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextLink)(void);
/// 指定范围内上下的偏移量. 正值向上, 负数向下.
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextOffset)(float offset);
/// 指定范围内倾斜. 建议值 -1 到 1 之间.
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextObliqueness)(float obliqueness);
/// attrKey: NSAttributedStringKey
@property (nonatomic, copy, readonly) SJAttributeWorker *(^next)(NSAttributedStringKey attrKey, id value);
/// Action, 需要使用 SJLabel
@property (nonatomic, copy, readonly) SJAttributeWorker *(^nextAction)(void(^task)(NSRange range, NSAttributedString *matched));



#pragma mark - Insert
/*!
 *  Insert a image at the specified position.
 *  You can get the length of the text through [worker.length].
 *  If index = -1, it will be inserted at the end of the text.
 *
 *  可以通过 worker.length 来获取文本的length
 *  指定位置 插入图片.
 *  如果 index = -1, 将会插到文本最后
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^insertImage)(UIImage *image, NSInteger index, CGPoint offset, CGSize size);
/*!
 *  You can get the length of the text through [worker.length].
 *  If index = -1, it will be inserted at the end of the text.
 *
 *  可以通过 worker.length 来获取文本的length
 *  指定位置 插入文本.
 *  如果 index = -1, 将会插到文本最后.
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^insertAttr)(NSAttributedString *attrStr, NSInteger index);
/*!
 *  You can get the length of the text through [worker.length].
 *  If index = -1, it will be inserted at the end of the text.
 *
 *  可以通过 worker.length 来获取文本的length
 *  指定位置 插入文本.
 *  如果 index = -1, 将会插到文本最后
 **/
@property (nonatomic, copy, readonly) SJAttributeWorker *(^insertText)(NSString *text, NSInteger index);
/**
 *  insert = NSString or NSAttributedString or UIImage
 *  insert(string, 0)
 *  insert(attributedString, 0)
 *  insert([UIImage imageNamed:name], 10, CGPointMake(0, -20), CGSizeMake(50, 50))
 */
@property (nonatomic, copy, readonly) SJAttributeWorker *(^insert)(id strOrAttrStrOrImg, NSInteger index, ...);
/*!
 *  worker.insert(@" recur ", worker.lastInsertedRange.location);
 *  worker.lastInserted(^(SJAttributeWorker * _Nonnull worker) {
 *      worker
 *      .nextFont([UIFont systemFontOfSize:30])
 *      .nextFontColor([UIColor redColor]);
 *  });
 */
@property (nonatomic, copy, readonly) SJAttributeWorker *(^lastInserted)(void(^rangeTask)(SJAttributeWorker *worker));
@property (nonatomic, assign, readonly) NSRange lastInsertedRange;

#pragma mark - Replace
/// value == NSString Or NSAttributedString
@property (nonatomic, copy, readonly) SJAttributeWorker *(^replace)(NSRange range, id strOrAttrStr);
/// oldPart and newPart == NSString Or NSAttributedString
@property (nonatomic, copy, readonly) SJAttributeWorker *(^replaceIt)(id oldPart, id newPart);


#pragma mark - Remove
/// 指定范围 删除文本
@property (nonatomic, copy, readonly) SJAttributeWorker *(^removeText)(NSRange range);
/// 指定范围 删除属性
@property (nonatomic, copy, readonly) SJAttributeWorker *(^removeAttribute)(NSAttributedStringKey key, NSRange range);
/// 除字体大小, 清除文本其他属性
@property (nonatomic, copy, readonly) void (^clean)(void);


#pragma mark - Regular Expression
/// 正则匹配
@property (nonatomic, copy, readonly) SJAttributeWorker *(^regexp)(NSString *ex, void(^task)(SJAttributeWorker *regexp));
/// 正则匹配
@property (nonatomic, copy, readonly) SJAttributeWorker *(^regexpRanges)(NSString *ex, void(^task)(NSArray<NSValue *> *ranges));


#pragma mark - Other
/// 获取当前文本的长度
@property (nonatomic, assign, readonly) NSInteger length;
/// 获取指定范围的宽度. (必须设置过字体)
@property (nonatomic, copy, readonly) CGFloat(^width)(NSRange range);
/// 获取指定范围的大小. (必须设置过字体)
@property (nonatomic, copy, readonly) CGSize(^size)(NSRange range);
/// 获取指定范围的大小. (必须设置过字体)
@property (nonatomic, copy, readonly) CGRect(^boundsByMaxWidth)(CGFloat maxWidth);
/// 获取指定范围的大小. (必须设置过字体)
@property (nonatomic, copy, readonly) CGRect(^boundsByMaxHeight)(CGFloat maxHeight);
/// 获取指定范围的文本
@property (nonatomic, copy, readonly) NSAttributedString *(^attrStrByRange)(NSRange range);

@end

NS_ASSUME_NONNULL_END

