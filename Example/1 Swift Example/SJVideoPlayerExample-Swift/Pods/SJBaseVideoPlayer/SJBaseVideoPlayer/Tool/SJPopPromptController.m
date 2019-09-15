//
//  SJPopPromptController.m
//  Pods
//
//  Created by 畅三江 on 2019/7/12.
//

#import "SJPopPromptController.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#define _AnimDuration (0.4)

@interface SJPopTextContainerView : UIView
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@end

@implementation SJPopTextContainerView
- (instancetype)initWithFrame:(CGRect)frame contentInset:(UIEdgeInsets)contentInset {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        self.layer.cornerRadius = 5;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(contentInset);
        }];
    }
    return self;
}
@end


@interface SJPopPromptController ()
@property (nonatomic, strong, readonly) NSMutableArray<SJPopTextContainerView *> *subviews;
@end

@implementation SJPopPromptController
@synthesize target = _target;
@synthesize leftMargin = _leftMargin;
@synthesize bottomMargin = _bottomMargin;
@synthesize itemSpacing = _itemSpacing;
@synthesize contentInset = _contentInset;

- (instancetype)init {
    self = [super init];
    if (self) {
        _subviews = [NSMutableArray new];
        _leftMargin = 16;
        _bottomMargin = 16;
        _itemSpacing = 12;
        _contentInset = UIEdgeInsetsMake(12, 22, 12, 22);
    }
    return self;
}

- (void)setBottomMargin:(CGFloat)bottomMargin {
    if ( bottomMargin != _bottomMargin ) {
        _bottomMargin = bottomMargin;
        if ( self.subviews.count != 0 ) {
            [self _remakeConstraintsAtIndex:self.subviews.count - 1];
            [UIView animateWithDuration:_AnimDuration animations:^{
                [self.target layoutIfNeeded];
            }];
        }
    }
}

- (void)show:(NSAttributedString *)title {
    [self show:title duration:3];
}

- (void)show:(NSAttributedString *)title duration:(NSTimeInterval)duration {
    SJPopTextContainerView *view = [[SJPopTextContainerView alloc] initWithFrame:CGRectZero contentInset:_contentInset];
    view.titleLabel.attributedText = title;
    [self _addSubview:view];
    
    __weak typeof(view) _view = view;
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _removeSubview:_view];
    });
}

- (void)clear {
    [self _removeAllSubviews];
}

- (void)_addSubview:(SJPopTextContainerView *)view {
    CGRect bounds = self.target.bounds;
    view.frame = CGRectMake(-bounds.size.width, bounds.size.height - _bottomMargin, 0, 0);
    [self.target addSubview:view];
    [self.subviews addObject:view];

    [self.subviews enumerateObjectsUsingBlock:^(SJPopTextContainerView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _remakeConstraintsAtIndex:idx];
    }];
    
    [UIView animateWithDuration:_AnimDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.target layoutIfNeeded];
    } completion:nil];
}

- (void)_removeSubview:(SJPopTextContainerView *)view {
    NSUInteger idx = [self.subviews indexOfObject:view];
    if ( idx == NSNotFound )
        return;
    
    [self.subviews removeObjectAtIndex:idx];
    
    [self _remakeConstraintsAtIndex:idx - 1];
    [self _remakeConstraintsAtIndex:idx];

    [UIView animateWithDuration:_AnimDuration animations:^{
        view.alpha = 0.01;
        [self.target layoutIfNeeded];
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

- (void)_removeAllSubviews {
    if ( self.subviews.count != 0 ) {
        NSArray<SJPopTextContainerView *> *subviews = self.subviews.copy;
        [self.subviews removeAllObjects];
        [UIView animateWithDuration:_AnimDuration animations:^{
            for ( UIView *subview in subviews ) {
                subview.alpha = 0.001;
            }
        } completion:^(BOOL finished) {
            [subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SJPopTextContainerView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
                [subview removeFromSuperview];
            }];
        }];
    }
}

- (void)_remakeConstraintsAtIndex:(NSInteger)idx {
    if ( idx < 0 || idx >= self.subviews.count )
        return;
    
    NSUInteger count = self.subviews.count;
    SJPopTextContainerView *view = self.subviews[idx];
    [view mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.target.mas_safeAreaLayoutGuideLeft).offset(self.leftMargin);
        } else {
            make.left.offset(self.leftMargin);
        }
        
        if ( idx != count - 1 ) {
            make.bottom.equalTo(self.subviews[idx + 1].mas_top).offset(-self.itemSpacing);
        }
        else {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.target.mas_safeAreaLayoutGuideBottom).offset(-self.bottomMargin);
            } else {
                make.bottom.offset(-self.bottomMargin);
            }
        }
    }];
}
@end
NS_ASSUME_NONNULL_END
