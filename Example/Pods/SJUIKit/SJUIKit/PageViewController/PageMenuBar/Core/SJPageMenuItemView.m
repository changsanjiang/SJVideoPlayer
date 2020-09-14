//
//  SJPageMenuItemView.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/11.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJPageMenuItemView.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJPageMenuItemView ()
@property (nonatomic, strong, nullable) UILabel *label;
@end

@implementation SJPageMenuItemView
@synthesize focusedMenuItem = _focusedMenuItem;
@synthesize transitionProgress = _transitionProgress;
- (instancetype)initWithText:(NSString *)text font:(UIFont *)font {
    self = [self initWithFrame:CGRectZero];
    if ( self ) {
        _label.text = text;
        _label.font = font;
    }
    return self;
}

- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText {
    self = [self initWithFrame:CGRectZero];
    if ( self ) {
        _label.attributedText = attributedText;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _label = [UILabel.alloc initWithFrame:CGRectZero];
        _label.font = [UIFont systemFontOfSize:20];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = UIColor.whiteColor;
        [self addSubview:_label];
    }
    return self;
}

#pragma mark -

- (void)setFont:(nullable UIFont *)font {
    _label.font = font;
}

- (UIFont *)font {
    return _label.font;
}

- (void)setText:(nullable NSString *)text {
    _label.text = text;
}
- (nullable NSString *)text {
    return _label.text;
}

- (void)setAttributedText:(nullable NSAttributedString *)attributedText {
    _label.attributedText = attributedText;
}
- (nullable NSAttributedString *)attributedText {
    return _label.attributedText;
}

- (void)setTintColor:(nullable UIColor *)tintColor {
    [_label setTextColor:tintColor];
}
- (UIColor *)tintColor {
    return _label.textColor;
}

#pragma mark -

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    CGPoint center = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    _label.center = center;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [_label sizeThatFits:size];
}

- (void)sizeToFit {
    [_label sizeToFit];
    CGRect bounds = self.bounds;
    bounds.size = _label.bounds.size;
    self.bounds = bounds;
}

@end
NS_ASSUME_NONNULL_END
