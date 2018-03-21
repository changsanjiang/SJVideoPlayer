//
//  YYTapActionLabel.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "YYTapActionLabel.h"
#import <YYTextAttribute.h>
#import <NSAttributedString+YYText.h>
#import <YYTextParser.h>
#import <objc/message.h>

@interface YYTapActionLabel ()
@end

@implementation YYTapActionLabel

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if ( attributedText.tappedDelegate && [attributedText isKindOfClass:[NSMutableAttributedString class]] ) {
        __weak typeof(self) _self = self;
        self.textTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( range.location >= text.length ) return;
            if ( [text attribute:YYTextBindingAttributeName atIndex:range.location effectiveRange:NULL] ) {
                if ( [attributedText.tappedDelegate respondsToSelector:@selector(attributedString:tappedStr:)] ) {
                    [attributedText.tappedDelegate attributedString:attributedText tappedStr:[attributedText attributedSubstringFromRange:range]];
                }
            }
        };;
    }
    [super setAttributedText:attributedText];
}

- (void)setTextLayout:(YYTextLayout *)textLayout {
    NSAttributedString *attributedText = textLayout.tapActionAttributedString;
    if ( attributedText ) {
        __weak typeof(self) _self = self;
        self.textTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( range.location >= text.length ) return;
            if ( [text attribute:YYTextBindingAttributeName atIndex:range.location effectiveRange:NULL] ) {
                if ( [attributedText.tappedDelegate respondsToSelector:@selector(attributedString:tappedStr:)] ) {
                    [attributedText.tappedDelegate attributedString:attributedText tappedStr:[attributedText attributedSubstringFromRange:range]];
                }
            }
        };;
    }
    [super setTextLayout:textLayout];
}

@end

@implementation YYTextLayout(SJAdd)

+ (YYTextLayout *)sj_layoutWithContainer:(YYTextContainer *)container text:(NSAttributedString *)text {
    YYTextLayout *layout = [self layoutWithContainer:container text:text];
    if ( text.tappedDelegate && [text isKindOfClass:[NSMutableAttributedString class]] ) {
        layout.tapActionAttributedString = text;
    }
    return layout;
}
- (void)setTapActionAttributedString:(NSAttributedString * _Nullable)tapActionAttributedString {
    objc_setAssociatedObject(self, @selector(tapActionAttributedString), tapActionAttributedString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSAttributedString *)tapActionAttributedString {
    return objc_getAssociatedObject(self, _cmd);
}
@end

@implementation NSMutableAttributedString (SJAdd)

- (void (^)(NSString * _Nonnull))addTapAction {
    return ^ void(NSString *regStr) {
        self.sj_regexp(regStr, NO, ^(NSArray<NSValue *> * _Nullable matchedRanges) {
            [matchedRanges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange range = obj.rangeValue;
                if ( [self attribute:YYTextBindingAttributeName atIndex:range.location effectiveRange:NULL] ) return;
                YYTextBinding *binding = [YYTextBinding bindingWithDeleteConfirm:YES];
                [self yy_setTextBinding:binding range:range];
                //                [self setTextBinding:binding range:range];
            }];
        });
    };
}

- (void (^)(NSString * _Nonnull, BOOL, void (^ _Nonnull)(NSArray<NSValue *> * _Nullable)))sj_regexp {
    return ^ void (NSString *regStr, BOOL reverse, void(^task)(NSArray<NSValue *> *ranges)) {
        NSMutableArray<NSValue *> *rangesM = [NSMutableArray array];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr options:kNilOptions error:nil];
        [regex enumerateMatchesInString:self.string options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if ( !result ) return;
            NSRange range = result.range;
            if ( range.location == NSNotFound || range.length < 1 ) return;
            [rangesM addObject:[NSValue valueWithRange:range]];
        }];
        if ( reverse ) {
            NSMutableArray<NSValue *> *reverseM = [NSMutableArray array];
            [rangesM enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [reverseM addObject:obj];}];
            rangesM = reverseM;
        }
        if ( task ) task(rangesM);
    };
}

@end


@implementation NSAttributedString (SJAddDelegate)

- (void)setTappedDelegate:(id<NSAttributedStringTappedDelegate>)tappedDelegate {
    objc_setAssociatedObject(self, @selector(tappedDelegate), tappedDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<NSAttributedStringTappedDelegate>)tappedDelegate {
    return objc_getAssociatedObject(self, _cmd);
}

@end

