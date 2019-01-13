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

- (BOOL)placeholderImageViewIsHidden {
    return _isHidden;
}

- (void)showPlaceholder {
    if ( !_isHidden ) return; _isHidden = NO;
    self.placeholderImageView.alpha = 1;
}

- (void)hiddenPlaceholder {
    if ( _isHidden ) return; _isHidden = YES;
    self.placeholderImageView.alpha = 0.001;
}

- (void)_presentSetupView {
    self.backgroundColor = [UIColor blackColor];
    self.placeholderImageView.frame = self.bounds;
    _placeholderImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_placeholderImageView];
    [self hiddenPlaceholder];
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
