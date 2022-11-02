//
//  SJPageMenuItemView.h
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/11.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJPageMenuBarInterfaces.h"

/// 此处为 ItemView 的一种实现
///
///     可以直接使用, 但更多的用意是作为一种示例, 我们鼓励你自定义该视图
///
NS_ASSUME_NONNULL_BEGIN
@interface SJPageMenuItemView : UIView<SJPageMenuItemView>
- (instancetype)initWithText:(NSString *)text font:(UIFont *)font;
- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText;

@property (nonatomic, strong, null_resettable) UIFont *font;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSAttributedString *attributedText;
@end
NS_ASSUME_NONNULL_END
