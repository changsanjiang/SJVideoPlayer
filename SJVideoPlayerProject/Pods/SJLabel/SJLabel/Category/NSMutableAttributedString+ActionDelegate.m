//
//  NSMutableAttributedString+ActionDelegate.m
//  SJLabel
//
//  Created by BlueDancer on 2018/1/27.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "NSMutableAttributedString+ActionDelegate.h"
#import <objc/message.h>


NSAttributedStringKey const SJActionAttributedStringKey = @"SJActionAttributedStringKey";


@implementation NSAttributedString (ActionDelegate)

- (void)setActionDelegate:(id<NSAttributedStringActionDelegate>)actionDelegate {
    objc_setAssociatedObject(self, @selector(actionDelegate), actionDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<NSAttributedStringActionDelegate>)actionDelegate {
    return objc_getAssociatedObject(self, _cmd);
}
@end


#pragma mark -
@implementation NSMutableAttributedString (ActionDelegate)

- (void (^)(NSString * _Nonnull))addAction {
    return ^ void(NSString *regStr) {
        self.regexp(regStr, NO, ^(NSArray<NSValue *> * _Nullable matchedRanges) {
            [matchedRanges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange range = obj.rangeValue;
                [self addAttribute:SJActionAttributedStringKey value:obj range:range];
            }];
        });
    };
}

- (void (^)(NSString * _Nonnull, BOOL, void (^ _Nonnull)(NSArray<NSValue *> * _Nullable)))regexp {
    return ^ void (NSString *regStr, BOOL reverse, void(^task)(NSArray<NSValue *> *ranges)) {
        NSMutableArray<NSValue *> *rangesM = [NSMutableArray array];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr options:kNilOptions error:nil];
        [regex enumerateMatchesInString:self.string options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if ( result ) { [rangesM addObject:[NSValue valueWithRange:result.range]];}
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
