//
//  SJVideoPlayerPresentView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerPresentView.h"
NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerPresentView ()
@end

@implementation SJVideoPlayerPresentView {
    BOOL _isHidden;
    BOOL _isDelayed;
}

@synthesize placeholderImageView = _placeholderImageView;
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _presentSetupView];
    return self;
}

#ifdef SJ_MAC
- (void)dealloc {
    NSLog(@"%d - %s", (int)__LINE__, __func__);
}
#endif

- (void)layoutSubviews {
    [super layoutSubviews];
    if ( _layoutSubviewsExeBlock ) _layoutSubviewsExeBlock(self);
}

- (BOOL)placeholderImageViewIsHidden {
    return _isHidden;
}

- (void)showPlaceholderAnimated:(BOOL)animated {
    if ( _isDelayed )
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hiddenPlaceholderAnimated:) object:nil];
    if ( !_isHidden ) return; _isHidden = NO;
    if ( animated ) {
        [UIView animateWithDuration:0.4 animations:^{
            self->_placeholderImageView.alpha = 1;
        }];
    }
    else {
        _placeholderImageView.alpha = 1;
    }
}

- (void)hiddenPlaceholderAnimated:(BOOL)animated delay:(NSTimeInterval)secs {
    if ( _isDelayed )
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hiddenPlaceholderAnimated:) object:nil];
    if ( _isHidden ) return; _isHidden = YES;
    if ( secs == 0 ) {
        [self _hiddenPlaceholderAnimated:@(animated)];
    }
    else {
        [self performSelector:@selector(_hiddenPlaceholderAnimated:) withObject:@(animated) afterDelay:secs];
        _isDelayed = YES;
    }
}

- (void)_hiddenPlaceholderAnimated:(NSNumber *)animated {
    if ( [animated boolValue] ) {
        [UIView animateWithDuration:0.4 animations:^{
            self->_placeholderImageView.alpha = 0.001;
        }];
    }
    else {
        _placeholderImageView.alpha = 0.001;
    }
    _isDelayed = NO;
}

- (void)_presentSetupView {
    self.backgroundColor = [UIColor blackColor];
    self.placeholderImageView.frame = self.bounds;
    _placeholderImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_placeholderImageView];
    [self hiddenPlaceholderAnimated:NO delay:0];
}

- (UIImageView *)placeholderImageView {
    if ( _placeholderImageView ) return _placeholderImageView;
    _placeholderImageView = [UIImageView new];
    _placeholderImageView.contentMode = UIViewContentModeScaleAspectFill;
    _placeholderImageView.clipsToBounds = YES;
    return _placeholderImageView;
}

@end
NS_ASSUME_NONNULL_END
