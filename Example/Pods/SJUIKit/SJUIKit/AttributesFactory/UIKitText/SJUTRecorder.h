//
//  SJUTRecorder.h
//  AttributesFactory
//
//  Created by 畅三江 on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJUIKitAttributesDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJUTStroke : NSObject<SJUTStroke>
@property (nonatomic, strong, nullable) UIColor *color;
@property (nonatomic) float width;
@end

@interface SJUTDecoration : NSObject<SJUTDecoration>
@property (nonatomic, strong, nullable) UIColor *color;
@property (nonatomic) NSUnderlineStyle style;
@end

@interface SJUTImageAttachment : NSObject<SJUTImageAttachment>
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic) CGRect bounds;
@property (nonatomic) SJUTVerticalAlignment alignment;
@end

@interface SJUTReplace : NSObject
@property (nonatomic, strong, nullable) NSString *fromString;
@property (nonatomic, copy, nullable) void(^block)(id<SJUIKitTextMakerProtocol> make);
@end

@interface SJUTRecorder : NSObject {
    @package
    // text attributes
    UIFont *_Nullable font;
    UIColor *_Nullable textColor;
    UIColor *_Nullable backgroundColor;
    NSNumber *_Nullable kern;  // CGFloat
    NSShadow *_Nullable shadow;
    SJUTStroke *_Nullable stroke; 
    SJUTDecoration *_Nullable underLine;
    SJUTDecoration *_Nullable strikethrough;
    NSNumber *_Nullable baseLineOffset;  // CGFloat
    
    // paragraph attributes
    NSNumber *_Nullable lineSpacing; // CGFloat
    NSNumber *_Nullable paragraphSpacing; // CGFloat
    NSNumber *_Nullable alignment; // NSTextAlignment
    NSNumber *_Nullable firstLineHeadIndent; // CGFloat
    NSNumber *_Nullable headIndent; // CGFloat
    NSNumber *_Nullable tailIndent; // CGFloat
    NSNumber *_Nullable lineBreakMode; // NSLineBreakMode
    NSNumber *_Nullable minimumLineHeight; // CGFloat
    NSNumber *_Nullable maximumLineHeight; // CGFloat
    NSNumber *_Nullable baseWritingDirection; // NSWritingDirection
    NSNumber *_Nullable lineHeightMultiple; // CGFloat
    NSNumber *_Nullable paragraphSpacingBefore; // CGFloat
    NSNumber *_Nullable hyphenationFactor; // float
    NSArray<NSTextTab *> *_Nullable tabStops;
    NSNumber *_Nullable defaultTabInterval;  // CGFloat
    NSNumber *_Nullable allowsDefaultTighteningForTruncation API_AVAILABLE(ios(9.0)); // BOOL
    NSNumber *_Nullable lineBreakStrategy API_AVAILABLE(ios(9.0)); // NSLineBreakStrategy

    // custom attributes
    NSMutableDictionary<NSString *, id> *_Nullable _customAttributes;

    // - sources
    NSString *_Nullable string;
    NSRange range;
    SJUTImageAttachment *_Nullable attachment;
    NSMutableAttributedString *_Nullable attrStr;
}

- (void)setValue:(nullable id)value forAttributeKey:(NSString *)key;
- (void)setValuesForAttributeKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues;
- (NSDictionary<NSAttributedStringKey, id> *)textAttributes;
- (NSParagraphStyle *)paragraphAttributesForStyle:(nullable NSParagraphStyle *)style;
- (NSDictionary<NSAttributedStringKey, id> *)customAttributes;
- (void)setValuesForCommonRecorder:(SJUTRecorder *)common;
- (void)setValuesForAttributedString:(NSAttributedString *)attributedString;
@end
NS_ASSUME_NONNULL_END
