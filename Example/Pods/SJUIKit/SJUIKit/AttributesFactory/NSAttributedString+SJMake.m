//
//  NSAttributedString+SJMake.m
//  AttributesFactory
//
//  Created by BlueDancer on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "NSAttributedString+SJMake.h"
#import "SJUIKitTextMaker.h"

NS_ASSUME_NONNULL_BEGIN
@implementation NSAttributedString (SJMake)
+ (instancetype)sj_UIKitText:(void(^)(id<SJUIKitTextMakerProtocol> make))block {
    SJUIKitTextMaker *maker = [SJUIKitTextMaker new];
    block(maker);
    return maker.install;
}

- (CGSize)sj_textSize {
    return [self sj_textSizeForPreferredMaxLayoutWidth:CGFLOAT_MAX];
}
- (CGSize)sj_textSizeForRange:(NSRange)range {
    if ( range.length < 1 || range.length > self.length )
        return CGSizeZero;
    return sj_textSize([self attributedSubstringFromRange:range], CGFLOAT_MAX, CGFLOAT_MAX);
}
- (CGSize)sj_textSizeForPreferredMaxLayoutWidth:(CGFloat)width {
    return sj_textSize(self, width, CGFLOAT_MAX);
}
- (CGSize)sj_textSizeForPreferredMaxLayoutHeight:(CGFloat)height {
    return sj_textSize(self, CGFLOAT_MAX, height);
}

static CGSize sj_textSize(NSAttributedString *attrStr, CGFloat width, CGFloat height) {
    if ( attrStr.length < 1 )
        return CGSizeZero;
    CGRect bounds = [attrStr boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    bounds.size.width = ceil(bounds.size.width);
    bounds.size.height = ceil(bounds.size.height);
    return bounds.size;
}
@end
NS_ASSUME_NONNULL_END
