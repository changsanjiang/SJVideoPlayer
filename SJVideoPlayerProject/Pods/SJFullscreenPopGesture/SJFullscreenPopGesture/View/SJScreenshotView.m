//
//  SJScreenshotView.m
//  SJBackGR
//
//  Created by BlueDancer on 2017/9/27.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJScreenshotView.h"

@interface SJScreenshotView ()

@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, assign, readonly) CGFloat shift;
@property (nonatomic, strong, readonly) UIView *shadeView;

@end

@implementation SJScreenshotView

@synthesize containerView = _containerView;
@synthesize shadeView = _shadeView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJScreenshotViewSetupUI];
    _shift = -[UIScreen mainScreen].bounds.size.width * 0.382;
    return self;
}

- (void)beginTransition  {
    switch ( _transitionMode ) {
        case SJScreenshotTransitionModeShifting: {
            self.transform = CGAffineTransformMakeTranslation( self.shift, 0 );
            _shadeView.alpha = 0.001;
        }
            break;
        case SJScreenshotTransitionModeShadeAndShifting: {
            self.transform = CGAffineTransformMakeTranslation( self.shift, 0 );
            CGFloat width = self.frame.size.width;
            _shadeView.transform = CGAffineTransformMakeTranslation( - (self.shift + width), 0 );
            _shadeView.alpha = 1;
        }
            break;
    }
}

- (void)transitioningWithOffset:(CGFloat)offset {
    CGFloat width = self.frame.size.width;
    if ( 0 == width ) return;
    switch ( _transitionMode ) {
        case SJScreenshotTransitionModeShifting: {
            CGFloat rate = offset / width;
            self.transform = CGAffineTransformMakeTranslation( self.shift * ( 1 - rate ), 0 );
        }
            break;
        case SJScreenshotTransitionModeShadeAndShifting: {
            CGFloat rate = offset / width;
            self.transform = CGAffineTransformMakeTranslation( self.shift * ( 1 - rate ), 0 );
            _shadeView.alpha = 1 - rate;
            _shadeView.transform = CGAffineTransformMakeTranslation( - (self.shift + width) + (self.shift * rate) + offset, 0 );
        }
            break;
    }
}

- (void)reset {
    [self beginTransition];
}

- (void)finishedTransition {
    self.transform = CGAffineTransformIdentity;
    _shadeView.transform = CGAffineTransformIdentity;
    _shadeView.alpha = 0.001;
}

// MARK:

- (void)_SJScreenshotViewSetupUI {
    [self addSubview:self.containerView];
    [_containerView addSubview:self.shadeView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _shadeView.frame = _containerView.frame = self.bounds;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.layer.contents = (id)image.CGImage;
}

- (UIView *)containerView {
    if ( _containerView ) return _containerView;
    _containerView = [UIView new];
    return _containerView;
}

- (UIView *)shadeView {
    if ( _shadeView ) return _shadeView;
    _shadeView = [UIView new];
    _shadeView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    return _shadeView;
}

@end
