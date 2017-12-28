//
//  SJLoadingView.m
//  SJLoadingViewProject
//
//  Created by 畅三江 on 2017/12/24.
//  Copyright © 2017年 畅三江. All rights reserved.
//

#import "SJLoadingView.h"

@interface SJLoadingView ()<CAAnimationDelegate>

@property (nonatomic, strong, readonly) CAGradientLayer *gradientLayer;
@property (nonatomic, strong, readonly) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign, getter=isAnimating) BOOL animating;
@property (nonatomic, assign) BOOL strokeShow;

@end

@implementation SJLoadingView

@synthesize lineColor = _lineColor;
@synthesize gradientLayer = _gradientLayer;
@synthesize shapeLayer = _shapeLayer;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self.layer addSublayer:self.gradientLayer];
    self.gradientLayer.mask = self.shapeLayer;
    self.alpha = 0.001;
    self.speed = 1;
    self.lineWidth = 2;
    self.lineColor = [UIColor whiteColor];
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(38, 38);
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    _shapeLayer.lineWidth = _lineWidth;
}

- (void)setLineColor:(UIColor *)lineColor {
    if ( !lineColor ) return;
    _lineColor = lineColor;
    _gradientLayer.colors = @[
                              (id)[UIColor colorWithWhite:0.001 alpha:0.001].CGColor,
                              (id)[lineColor colorWithAlphaComponent:0.25].CGColor,
                              (id)lineColor.CGColor];
}

- (UIColor *)lineColor {
    if ( _lineColor ) return _lineColor;
    return [UIColor whiteColor];
}

- (void)start {
    if ( _animating ) return;
    _animating = YES;
    if ( _animType == SJLoadingType_FadeOut ) [self _strokeAnim_Show];
    self.alpha = 1;
    CABasicAnimation *rotationAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnim.toValue = [NSNumber numberWithFloat:2 * M_PI];
    rotationAnim.duration = _speed;
    rotationAnim.repeatCount = CGFLOAT_MAX;
    [_gradientLayer addAnimation:rotationAnim forKey:@"rotation"];
}

- (void)_strokeAnim_Show {
    _strokeShow = YES;
    CAKeyframeAnimation *strokeAnim = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    strokeAnim.values = @[@(_shapeLayer.strokeStart), @(_shapeLayer.strokeEnd)];
    strokeAnim.duration = _speed * 1.5;
    strokeAnim.delegate = self;
    strokeAnim.removedOnCompletion = NO;
    strokeAnim.fillMode = kCAFillModeForwards;
    [_shapeLayer addAnimation:strokeAnim forKey:@"strokeAnim"];
}

- (void)_strokeAnim_Dismiss {
    _strokeShow = NO;
    CAKeyframeAnimation *strokeAnim = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    strokeAnim.values = @[@(_shapeLayer.strokeEnd), @(_shapeLayer.strokeStart)];
    strokeAnim.duration = _speed * 1.5;
    strokeAnim.delegate = self;
    strokeAnim.removedOnCompletion = NO;
    strokeAnim.fillMode = kCAFillModeForwards;
    [_shapeLayer addAnimation:strokeAnim forKey:@"strokeAnim"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ( !_animating ) return;
    if ( _strokeShow ) [self _strokeAnim_Dismiss];
    else [self _strokeAnim_Show];
}

- (void)stop {
    if ( !_animating ) return;
    _animating = NO;
    self.alpha = 0.001;
    [_shapeLayer removeAllAnimations];
    [_gradientLayer removeAllAnimations];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat height = width;
    self.gradientLayer.bounds = CGRectMake(0, 0, width, height);
    self.gradientLayer.position = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    self.shapeLayer.position = CGPointMake(_lineWidth, _lineWidth);
    self.shapeLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width * 0.5 - _lineWidth, height * 0.5 - _lineWidth) radius:(width - _lineWidth) * 0.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES].CGPath;
}

- (CAGradientLayer *)gradientLayer {
    if ( _gradientLayer ) return _gradientLayer;
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.startPoint = CGPointMake(1, 1);
    _gradientLayer.endPoint = CGPointMake(0, 0);
    _gradientLayer.locations = @[@(0), @(0.3), @(0.5), @(1)];
    return _gradientLayer;
}

- (CAShapeLayer *)shapeLayer {
    if ( _shapeLayer ) return _shapeLayer;
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.strokeColor = [UIColor blueColor].CGColor;
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;
    _shapeLayer.strokeStart = 0.15;
    _shapeLayer.strokeEnd = 0.8;
    _shapeLayer.lineCap = @"round";
    return _shapeLayer;
}

@end
