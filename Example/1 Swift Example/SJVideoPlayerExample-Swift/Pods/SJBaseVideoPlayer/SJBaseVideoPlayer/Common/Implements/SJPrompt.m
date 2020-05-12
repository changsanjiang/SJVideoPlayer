//
//  SJPrompt.m
//  SJPromptProject
//
//  Created by 畅三江 on 2017/9/26.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "SJPrompt.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJPrompt ()
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UILabel *label;
@property (nonatomic, copy, nullable) void(^completionHandler)(void);
@end

@implementation SJPrompt
@synthesize contentInset = _contentInset;
@synthesize maxLayoutWidth = _maxLayoutWidth;
@synthesize target = _target;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    self.contentInset = UIEdgeInsetsMake(12, 22, 12, 22);
    self.backgroundColor = UIColor.blackColor;
    self.cornerRadius = 8;
    return self;
}

- (void)show:(NSAttributedString *)title {
    [self show:title duration:1];
}
- (void)show:(NSAttributedString *)title duration:(NSTimeInterval)duration {
    [self show:title duration:duration completionHandler:nil];
}
- (void)show:(NSAttributedString *)title duration:(NSTimeInterval)duration completionHandler:(nullable void(^)(void))completionHandler {
    if ( title.length == 0 ) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        self.contentView.backgroundColor = self.backgroundColor;
        self.contentView.layer.cornerRadius = self.cornerRadius;
        self.label.attributedText = title;
        self.completionHandler = completionHandler;
        
        CGRect bounds = self.target.bounds;
        if ( self.contentView.superview != self.target ) {
            [self.target addSubview:self.contentView];
            self.contentView.center = CGPointMake(CGRectGetWidth(bounds) * 0.5, CGRectGetHeight(bounds) * 0.5);
            [self.contentView addSubview:self.label];
            [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.offset(0);
            }];
        }
        
        self.label.preferredMaxLayoutWidth = self.maxLayoutWidth ? : CGRectGetWidth(bounds) * 0.6;
        [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(self.contentInset);
        }];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.contentView.alpha = 1;
        }];
        
        if ( duration != -1 ) {
            [self performSelector:@selector(hidden) withObject:nil afterDelay:duration];
        }
    });
}
- (void)hidden {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [UIView animateWithDuration:0.25 animations:^{
            self.contentView.alpha = 0.001;
        } completion:^(BOOL finished) {
            if ( self.completionHandler != nil ) {
                self.completionHandler();
                self.completionHandler = nil;
            }
        }];
    });
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.contentView.layer.cornerRadius = cornerRadius;
}
- (CGFloat)cornerRadius {
    return self.contentView.layer.cornerRadius;
}

- (void)setBackgroundColor:(nullable UIColor *)backgroundColor {
    self.contentView.backgroundColor = backgroundColor;
}
- (nullable UIColor *)backgroundColor {
    return self.contentView.backgroundColor;
}

@synthesize contentView = _contentView;
- (UIView *)contentView {
    if ( _contentView == nil ) {
        _contentView = [UIView.alloc initWithFrame:CGRectZero];
    }
    return _contentView;
}

@synthesize label = _label;
- (UILabel *)label {
    if ( _label == nil ) {
        _label = [UILabel.alloc initWithFrame:CGRectZero];
        _label.numberOfLines = 0;
    }
    return _label;
}
@end
NS_ASSUME_NONNULL_END
