//
//  SJScrollingTextMarqueeView.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/12/7.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJScrollingTextMarqueeView.h"
#if __has_include(<SJUIKit/NSAttributedString+SJMake.h>)
#import <SJUIKit/NSAttributedString+SJMake.h>
#else
#import "NSAttributedString+SJMake.h"
#endif
#if __has_include(<SJBaseVideoPlayer/CALayer+SJBaseVideoPlayerExtended.h>)
#import <SJBaseVideoPlayer/CALayer+SJBaseVideoPlayerExtended.h>
#import <SJBaseVideoPlayer/UIView+SJBaseVideoPlayerExtended.h>
#else
#import "CALayer+SJBaseVideoPlayerExtended.h"
#import "UIView+SJBaseVideoPlayerExtended.h"
#endif


NS_ASSUME_NONNULL_BEGIN
@interface SJScrollingTextMarqueeView () {
    CGRect _previousBounds;
}
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UILabel *leftLabel;
@property (nonatomic, strong, readonly) UILabel *rightLabel;
@property (nonatomic, strong, readonly) CAGradientLayer *fadeMaskLayer;
@property (nonatomic, getter=isScrolling) BOOL scrolling;
@end

@implementation SJScrollingTextMarqueeView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _margin = 28;
        _scrollEnabled = YES;
        self.clipsToBounds = YES;
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_reset) name:UIApplicationWillEnterForegroundNotification object:nil];
        [self _setupViews];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setAttributedText:(nullable NSAttributedString *)attributedText {
    if ( ![self.attributedText isEqual:attributedText] ) {
        _leftLabel.attributedText = attributedText;
        _leftLabel.sj_w = self.isScrollEnabled ? attributedText.sj_textSize.width : self.sj_w;
        _leftLabel.sj_h = self.sj_h;
        if ( self.isScrollEnabled ) [self _reset];
    }
}

- (nullable NSAttributedString *)attributedText {
    return _leftLabel.attributedText;
}

- (void)setMargin:(CGFloat)margin {
    if ( margin != _margin ) {
        _margin = margin;
        if ( self.isScrollEnabled ) [self _reset];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    if ( scrollEnabled != _scrollEnabled ) {
        _scrollEnabled = scrollEnabled;
        [self _reset];
    }
}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    if ( !CGRectEqualToRect(_previousBounds, bounds) ) {
        _previousBounds = bounds;
        _fadeMaskLayer.frame = bounds;
        _leftLabel.sj_h = self.sj_h;
        _rightLabel.sj_h = self.sj_h;
        _contentView.sj_h = self.sj_h;
        if ( !_scrollEnabled ) _leftLabel.sj_w = bounds.size.width;
        [self _reset];
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self _reset];
}

#pragma mark -

- (void)_setupViews {
    _contentView = [UIView.alloc initWithFrame:CGRectZero];
    [self addSubview:_contentView];
    
    _leftLabel = [UILabel.alloc initWithFrame:CGRectZero];
    [_contentView addSubview:_leftLabel];
    
    _rightLabel = [UILabel.alloc initWithFrame:CGRectZero];
    [_contentView addSubview:_rightLabel];
    
    _fadeMaskLayer = CAGradientLayer.layer;
    _fadeMaskLayer.startPoint = CGPointMake(0, 0.5);
    _fadeMaskLayer.endPoint = CGPointMake(1, 0.5);
    [self _setFadeMasks];
    self.layer.mask = _fadeMaskLayer;
}

- (BOOL)_shouldScroll {
    return _scrollEnabled && _leftLabel.attributedText != nil && _leftLabel.sj_w > self.sj_w && self.sj_h != 0;
}

- (void)_reset {
    [_contentView.layer removeAllAnimations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    if ( [self _shouldScroll] ) {
        [self _prepareForAnimation];
        if ( self.window != nil ) {
            [self _startAnimationIfNeededAfterDelay:2];
        }
    }
    else {
        [self _prepareForNormalState];
    }
}

- (void)_prepareForAnimation {
    [self _setRightFadeMask];
    
    _rightLabel.hidden = NO;
    _rightLabel.attributedText = _leftLabel.attributedText;
    _rightLabel.sj_x = _leftLabel.sj_w + _margin;
    _rightLabel.sj_w = _leftLabel.sj_w;
    
    _contentView.sj_w = CGRectGetMaxX(_rightLabel.frame);
}

- (void)_prepareForNormalState {
    [self _removeFadeMasks];
    
    _rightLabel.hidden = YES;
}

- (void)_startAnimationIfNeededAfterDelay:(NSTimeInterval)seconds {
    if ( ![self _shouldScroll] ) return;
    
    // - 静止2秒
    // - 2秒后开始滚动, 如此循环
    [self performSelector:@selector(_startAnimation) withObject:self afterDelay:seconds inModes:@[NSRunLoopCommonModes]];
}

- (void)_startAnimation {
    CGFloat pointDuration = 0.02;
    CGFloat points = _leftLabel.sj_w + _margin;
    CABasicAnimation *step1 = [CABasicAnimation animationWithKeyPath:@"transform"];
    step1.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    step1.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-points, 0, 0)];
    step1.duration = points * pointDuration;
    step1.repeatCount = 1;
    [self _setFadeMasks];
    __weak typeof(self) _self = self;
    _scrolling = YES;
    [_contentView.layer addAnimation:step1 stopHandler:^(CAAnimation * _Nonnull anim, BOOL isFinished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.scrolling = NO;
        [self _startAnimationIfNeededAfterDelay:2];
    }];
    
    NSTimeInterval step2 = _leftLabel.sj_w * pointDuration;
    [self performSelector:@selector(_setRightFadeMask) withObject:nil afterDelay:step2 inModes:@[NSRunLoopCommonModes]];
}

- (void)_setFadeMasks {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _fadeMaskLayer.colors = @[
        (__bridge id)[UIColor colorWithWhite:1 alpha:0.05].CGColor,
        (__bridge id)[UIColor colorWithWhite:1 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithWhite:1 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithWhite:1 alpha:0.05].CGColor
    ];
    _fadeMaskLayer.locations = @[@0, @0.1, @0.9, @1];
    [CATransaction commit];
}

- (void)_setRightFadeMask {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _fadeMaskLayer.colors = @[
        (__bridge id)[UIColor colorWithWhite:1 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithWhite:1 alpha:0.05].CGColor
    ];
    _fadeMaskLayer.locations = @[@0.9, @1];
    [CATransaction commit];
}

- (void)_removeFadeMasks {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _fadeMaskLayer.colors = @[
        (__bridge id)[UIColor colorWithWhite:1 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithWhite:1 alpha:1.0].CGColor
    ];
    _fadeMaskLayer.locations = @[@0, @1];
    [CATransaction commit];
}
@end
NS_ASSUME_NONNULL_END
