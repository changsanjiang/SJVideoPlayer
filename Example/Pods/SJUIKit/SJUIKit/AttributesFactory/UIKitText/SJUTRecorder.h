//
//  SJUTRecorder.h
//  AttributesFactory
//
//  Created by BlueDancer on 2019/4/12.
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
    UIFont *_Nullable font;
    UIColor *_Nullable textColor;
    UIColor *_Nullable backgroundColor;
    NSNumber *_Nullable alignment;
    NSNumber *_Nullable lineSpacing;
    NSNumber *_Nullable kern;
    NSShadow *_Nullable shadow;
    SJUTStroke *_Nullable stroke;
    NSMutableParagraphStyle *_Nullable style;
    NSNumber *_Nullable lineBreakMode;
    SJUTDecoration *_Nullable underLine;
    SJUTDecoration *_Nullable strikethrough;
    NSNumber *_Nullable baseLineOffset;
    
    // - sources
    NSString *_Nullable string;
    NSRange range;
    SJUTImageAttachment *_Nullable attachment;
    NSMutableAttributedString *_Nullable attrStr;
}

- (NSParagraphStyle *)paragraphStyle;
@end
NS_ASSUME_NONNULL_END
