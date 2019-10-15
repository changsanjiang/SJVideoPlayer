//
//  NSAttributedString+SJMake.h
//  AttributesFactory
//
//  Created by BlueDancer on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//
//  Project: https://github.com/changsanjiang/SJAttributesFactory
//  Email:  changsanjiang@gmail.com
//

#import <Foundation/Foundation.h>
#import "SJUIKitAttributesDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface NSAttributedString (SJMake)
/**
 * - make attributed string:
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
+ (instancetype)sj_UIKitText:(void(^)(id<SJUIKitTextMakerProtocol> make))block;

- (CGSize)sj_textSize;
- (CGSize)sj_textSizeForRange:(NSRange)range;
- (CGSize)sj_textSizeForPreferredMaxLayoutWidth:(CGFloat)width;
- (CGSize)sj_textSizeForPreferredMaxLayoutHeight:(CGFloat)height;
@end
NS_ASSUME_NONNULL_END
