//
//  SJScrollingTextMarqueeView.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/12/7.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJScrollingTextMarqueeView.h"
#if __has_include(<SJUIKit/NSAttributedString+SJMake.h>)
#import <SJUIKit/NSAttributedString+SJMake.h>
#else
#import "NSAttributedString+SJMake.h"
#endif
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJScrollingTextMarqueeView ()<CAAnimationDelegate>
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UILabel *leftLabel;
@property (nonatomic, strong, readonly) UILabel *rightLabel;
@property (nonatomic, strong, readonly) CAGradientLayer *fadeMaskLayer;
@end

@implementation SJScrollingTextMarqueeView {
    CGRect _bounds;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        self.clipsToBounds = YES;
        
        _margin = 28;
        _scrollEnabled = YES;
        
        _contentView = [UIView.alloc initWithFrame:CGRectZero];
        [self addSubview:_contentView];
        
        _leftLabel = [UILabel.alloc initWithFrame:CGRectZero];
        [_contentView addSubview:_leftLabel];
        
        _rightLabel = [UILabel.alloc initWithFrame:CGRectZero];
        [_contentView addSubview:_rightLabel];
        
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        
        [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.offset(0);
        }];
        
        [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.offset(0);
            make.left.equalTo(self.leftLabel.mas_right).offset(self.margin);
        }];
            
        _fadeMaskLayer = CAGradientLayer.layer;
        _fadeMaskLayer.colors = @[ (__bridge id)[UIColor colorWithWhite:0 alpha:0.05].CGColor,
                                   (__bridge id)[UIColor colorWithWhite:0 alpha:1.0].CGColor,
                                   (__bridge id)[UIColor colorWithWhite:0 alpha:1.0].CGColor,
                                   (__bridge id)[UIColor colorWithWhite:0 alpha:0.05].CGColor ];
        /* An optional array of NSNumber objects defining the location of each
        * gradient stop as a value in the range [0,1]. The values must be
        * monotonically increasing. If a nil array is given, the stops are
        * assumed to spread uniformly across the [0,1] range. When rendered,
        * the colors are mapped to the output colorspace before being
        * interpolated. Defaults to nil. Animatable. */
        _fadeMaskLayer.locations = @[@0, @0.1, @0.9, @1];
        /* The start and end points of the gradient when drawn into the layer's
        * coordinate space. The start point corresponds to the first gradient
        * stop, the end point to the last gradient stop. Both points are
        * defined in a unit coordinate space that is then mapped to the
        * layer's bounds rectangle when drawn. (I.e. [0,0] is the bottom-left
        * corner of the layer, [1,1] is the top-right corner.) The default values
        * are [.5,0] and [.5,1] respectively. Both are animatable. */
        _fadeMaskLayer.startPoint = CGPointMake(0, 0);
        _fadeMaskLayer.endPoint = CGPointMake(1, 0);
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(reset) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setAttributedText:(nullable NSAttributedString *)attributedText {
    if ( ![self.attributedText isEqual:attributedText] ) {
        _leftLabel.attributedText = attributedText;
        
        [self reset];
    }
}

- (nullable NSAttributedString *)attributedText {
    return _leftLabel.attributedText;
}

- (void)setMargin:(CGFloat)margin {
    if ( margin != _margin ) {
        _margin = margin;
        [_rightLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftLabel.mas_right).offset(margin);
        }];
    }
}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    if ( !CGRectEqualToRect(_bounds, bounds) ) {
        _bounds = bounds;
        _fadeMaskLayer.frame = bounds;

        [self reset];
    }
}

#pragma mark -

- (void)reset {
    if ( self.isScrolling ) {
        [self stop];
    }
    [self startScrollingIfNeeded];
}

- (void)startScrollingIfNeeded {
    if ( _scrolling ) return;
    if ( [self _shouldStartScrolling] ) {
        _scrolling = YES;
        _rightLabel.hidden = NO;
        _rightLabel.attributedText = _leftLabel.attributedText;
        
        CGFloat points = _leftLabel.bounds.size.width + self.margin;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-points, 0, 0)];
        animation.duration = points * 0.02;
        animation.repeatCount = HUGE_VALF;
        animation.delegate = self;
        [_contentView.layer addAnimation:animation forKey:nil];
        self.layer.mask = self.fadeMaskLayer;
    }
}

- (void)stop {
    if ( _scrolling == NO ) return;
    _scrolling = NO;
    _rightLabel.hidden = YES;
    self.layer.mask = nil;
    [_contentView.layer removeAllAnimations];
}

#pragma mark -

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    _scrolling = NO;
}

#pragma mark -

- (BOOL)_shouldStartScrolling {
    if ( self.isScrollEnabled == NO ) return NO;
    if ( self.window == nil ) return NO;
    
    [self layoutIfNeeded];
    
    if ( self.bounds.size.width == 0 ) return NO;

    NSAttributedString *astr = self.attributedText;
    CGSize size = [astr sj_textSize];
    return size.width > self.bounds.size.width;
}
@end
NS_ASSUME_NONNULL_END
