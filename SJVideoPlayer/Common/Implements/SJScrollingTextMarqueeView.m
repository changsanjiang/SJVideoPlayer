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
@interface SJScrollingTextMarqueeView ()
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
    [self stop];
    [self startScrollingIfNeeded];
}

static NSInteger indexKey = 0;
- (void)startScrollingIfNeeded {
    if ( self.isScrolling ) return;
    if ( self.isScrollEnabled == NO ) return;
    if ( self.bounds.size.width == 0 ) return;
    NSAttributedString *astr = self.attributedText;
    CGSize size = [astr sj_textSize];
    if ( size.width > self.bounds.size.width ) {
        _scrolling = YES;
        _rightLabel.hidden = NO;
        _rightLabel.attributedText = astr;
        
        CGFloat points = size.width + self.margin;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-points, 0, 0)];
        animation.duration = points * 0.02;
        animation.repeatCount = HUGE_VALF;
        [_contentView.layer addAnimation:animation forKey:[NSString stringWithFormat:@"%ld", (long)(indexKey += 1)]];
        self.layer.mask = self.fadeMaskLayer;
    }
}

- (void)stop {
    if ( _scrolling ) {
        _scrolling = NO;
        _rightLabel.hidden = YES;
        self.layer.mask = nil;
        [_contentView.layer removeAnimationForKey:[NSString stringWithFormat:@"%ld", (long)indexKey]];
    }
}
@end
NS_ASSUME_NONNULL_END
