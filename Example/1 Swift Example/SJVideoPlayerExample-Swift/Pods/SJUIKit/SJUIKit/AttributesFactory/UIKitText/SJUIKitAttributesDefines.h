//
//  SJUIKitAttributesDefines.h
//  AttributesFactory
//
//  Created by 畅三江 on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#ifndef SJUIKitAttributesDefines_h
#define SJUIKitAttributesDefines_h
#import <UIKit/UIKit.h>
@protocol   SJUIKitTextMakerProtocol,
            SJUTAttributesProtocol,
            SJUTImageAttributesProtocol,
            SJUTRegexHandlerProtocol,
            SJUTRangeHandlerProtocol,
            SJUTStroke,
            SJUTDecoration,
            SJUTImageAttachment;

NS_ASSUME_NONNULL_BEGIN
@protocol SJUIKitTextMakerProtocol <SJUTAttributesProtocol>
/**
 * - Append a `string` to the text.
 *
 * \code
 *    NSAttributedString *text = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.append(@"String 1").font([UIFont boldSystemFontOfSize:14]);
 *   }];
 *
 *   // It's equivalent to below code.
 *
 *   NSDictionary *attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};
 *   NSAttributedString *text1 = [[NSAttributedString alloc] initWithString:@"String 1" attributes:attributes];
 *
 * \endcode
 */
@property (nonatomic, copy, readonly) id<SJUTAttributesProtocol>(^append)(NSString *str);

typedef void(^SJUTAppendImageHandler)(id<SJUTImageAttachment> make);
/**
 * - Append an `image attachment` to the text.
 *
 * \code
 *    NSAttributedString *text = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
 *           make.image = [UIImage imageNamed:@"image"];
 *           make.bounds = CGRectMake(0, 0, 50, 50);
 *       });
 *   }];
 *
 *   // It's equivalent to below code.
 *
 *   NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
 *   attachment.image = [UIImage imageNamed:@"image"];
 *   attachment.bounds = CGRectMake(0, 0, 50, 50);
 *   NSAttributedString *text1 = [NSAttributedString attributedStringWithAttachment:attachment];
 *
 * \endcode
 */
@property (nonatomic, copy, readonly) id<SJUTAttributesProtocol>(^appendImage)(SJUTAppendImageHandler block);

/**
 * - Append a `subtext` to the text.
 *
 * \code
 *   NSAttributedString *subtext = _label.attributedText;
 *
 *   NSAttributedString *text = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.appendText(subtext);
 *   }];
 *
 * \endcode
 */
@property (nonatomic, copy, readonly) id<SJUTAttributesProtocol>(^appendText)(NSAttributedString *subtext);

/**
 * - Update the attributes for the specified range of `text`.
 *
 * \code
 *    NSAttributedString *text = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.append(@"String 1");
 *       make.update(NSMakeRange(0, 1)).font([UIFont boldSystemFontOfSize:20]);
 *   }];
 * \endcode
 */
@property (nonatomic, copy, readonly) id<SJUTAttributesProtocol>(^update)(NSRange range);

/**
 * - Use regular to process `text`.
 *
 * \code
 *    NSAttributedString *text1 = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.append(@"123 123 4 123 123");
 *       // Replace `123` with `oOo`.
 *       make.regex(@"123").replaceWithString(@"oOo").font([UIFont boldSystemFontOfSize:20]);
 *   }];
 *
 *    NSAttributedString *text2 = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.append(@"123 123 4 123 123");
 *       // Replace `123` with `oOo`.
 *       make.regex(@"123").replaceWithText(^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
 *           make.append(@"oOo").font([UIFont boldSystemFontOfSize:20]);
 *       });
 *   }];
 *
 *    NSAttributedString *text3 = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.append(@"123 123 4 123 123");
 *       // Update the attributes of the matched text.
 *       make.regex(@"123").update(^(id<SJUTAttributesProtocol>  _Nonnull make) {
 *           make.font([UIFont boldSystemFontOfSize:20]).textColor([UIColor redColor]);
 *       });
 *   }];
 * \endcode
 */
@property (nonatomic, copy, readonly) id<SJUTRegexHandlerProtocol>(^regex)(NSString *regularExpression);

/**
 * - Edit the subtext for the specified range of `text`.
 *
 * \code
 *    NSAttributedString *text = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.append(@"123 123 M 123 123").font([UIFont boldSystemFontOfSize:20]);
 *       // Update the attributes for the specified range of `text`.
 *       make.range(NSMakeRange(0, 1)).update(^(id<SJUTAttributesProtocol>  _Nonnull make) {
 *           make.font([UIFont boldSystemFontOfSize:20]).textColor([UIColor orangeColor]);
 *       });
 *
 *       // Replace the subtext for the specified range of `text`.
 *       make.range(NSMakeRange(1, 1)).replaceWithString(@"O").textColor([UIColor purpleColor]);
 *
 *       // Replace the subtext for the specified range of `text`.
 *       make.range(NSMakeRange(2, 1)).replaceWithText(^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
 *           make.append(@"S").font([UIFont boldSystemFontOfSize:24]).textColor([UIColor greenColor]);
 *       });
 *   }];
 * \endcode
 */
@property (nonatomic, copy, readonly) id<SJUTRangeHandlerProtocol>(^range)(NSRange range);
@end

typedef id<SJUTAttributesProtocol>_Nonnull(^SJUTFontAttribute)(UIFont *font);
typedef id<SJUTAttributesProtocol>_Nonnull(^SJUTColorAttribute)(UIColor *color);
typedef id<SJUTAttributesProtocol>_Nonnull(^SJUTAlignmentAttribute)(NSTextAlignment alignment);
typedef id<SJUTAttributesProtocol>_Nonnull(^SJUTLineSpacingAttribute)(CGFloat lineSpacing);
typedef id<SJUTAttributesProtocol>_Nonnull(^SJUTKernAttribute)(CGFloat kern);
typedef id<SJUTAttributesProtocol>_Nonnull(^SJUTShadowAttribute)(void(^)(NSShadow *make));
typedef id<SJUTAttributesProtocol>_Nonnull(^SJUTStrokeAttribute)(void(^block)(id<SJUTStroke> make));
typedef id<SJUTAttributesProtocol>_Nonnull(^SJUTParagraphStyleAttribute)(void(^block)(NSMutableParagraphStyle *make));
typedef id<SJUTAttributesProtocol>_Nonnull(^SJUTLineBreakModeAttribute)(NSLineBreakMode lineBreakMode);
typedef id<SJUTAttributesProtocol>_Nonnull(^SJUTDecorationAttribute)(void(^)(id<SJUTDecoration> make));
typedef id<SJUTAttributesProtocol>_Nonnull(^SJUTBaseLineOffsetAttribute)(double offset);

@protocol SJUTAttributesProtocol
@property (nonatomic, copy, readonly) SJUTFontAttribute font;
@property (nonatomic, copy, readonly) SJUTColorAttribute textColor;
@property (nonatomic, copy, readonly) SJUTColorAttribute backgroundColor;
@property (nonatomic, copy, readonly) SJUTAlignmentAttribute alignment;
@property (nonatomic, copy, readonly) SJUTLineSpacingAttribute lineSpacing;
@property (nonatomic, copy, readonly) SJUTKernAttribute kern;
@property (nonatomic, copy, readonly) SJUTShadowAttribute shadow;
@property (nonatomic, copy, readonly) SJUTStrokeAttribute stroke;
@property (nonatomic, copy, readonly) SJUTParagraphStyleAttribute paragraphStyle;
@property (nonatomic, copy, readonly) SJUTLineBreakModeAttribute lineBreakMode;
@property (nonatomic, copy, readonly) SJUTDecorationAttribute underLine;
@property (nonatomic, copy, readonly) SJUTDecorationAttribute strikethrough;
@property (nonatomic, copy, readonly) SJUTBaseLineOffsetAttribute baseLineOffset;
@end

@protocol SJUTRangeHandlerProtocol
@property (nonatomic, copy, readonly) void(^update)(void(^)(id<SJUTAttributesProtocol> make));
@property (nonatomic, copy, readonly) void(^replaceWithText)(void(^)(id<SJUIKitTextMakerProtocol> make));
@property (nonatomic, copy, readonly) id<SJUTAttributesProtocol>(^replaceWithString)(NSString *string);
@end

@protocol SJUTRegexHandlerProtocol <SJUTRangeHandlerProtocol>
@property (nonatomic, copy, readonly) void(^handler)(void(^)(NSMutableAttributedString *attrStr, NSTextCheckingResult *result));

@property (nonatomic, copy, readonly) id<SJUTRegexHandlerProtocol>(^regularExpressionOptions)(NSRegularExpressionOptions ops);
@property (nonatomic, copy, readonly) id<SJUTRegexHandlerProtocol>(^matchingOptions)(NSMatchingOptions ops);
@end

@protocol SJUTStroke
@property (nonatomic, strong, nullable) UIColor *color;
@property (nonatomic) float width;
@end

@protocol SJUTDecoration
@property (nonatomic, strong, nullable) UIColor *color;
@property (nonatomic) NSUnderlineStyle style;
@end

typedef enum : NSUInteger {
    SJUTVerticalAlignmentBottom = 0,
    SJUTVerticalAlignmentCenter = 1,
    SJUTVerticalAlignmentTop = 2,
} SJUTVerticalAlignment;

@protocol SJUTImageAttachment <NSObject>
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic) SJUTVerticalAlignment alignment; ///< Text为统一的字体时生效
@property (nonatomic) CGRect bounds;
@end
NS_ASSUME_NONNULL_END
#endif /* SJUIKitAttributesDefines_h */
