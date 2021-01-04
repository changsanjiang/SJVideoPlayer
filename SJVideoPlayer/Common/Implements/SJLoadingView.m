//
//  SJLoadingView.m
//  Pods
//
//  Created by 畅三江 on 2019/11/27.
//

#import "SJLoadingView.h"
#import "SJVideoPlayerConfigurations.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface _SJRotatingAnimationView : UIView

/// default is whiteColor.
@property (nonatomic, strong, null_resettable) UIColor *lineColor;

/// default is 1.
@property (nonatomic) double speed;

/// anima state
@property (nonatomic, readonly, getter=isAnimating) BOOL animating;

/// begin anim
- (void)start;

/// stop anim
- (void)stop;
@end

@interface _SJRotatingAnimationView ()<CAAnimationDelegate>
@property (nonatomic, strong, readonly) CAGradientLayer *gradientLayer;
@property (nonatomic, strong, readonly) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign, getter=isAnimating) BOOL animating;
@end

@implementation _SJRotatingAnimationView
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

- (void)setLineColor:(nullable UIColor *)lineColor {
    _lineColor = lineColor ?: UIColor.whiteColor;
    _gradientLayer.colors = @[
                              (id)[UIColor colorWithWhite:0.001 alpha:0.001].CGColor,
                              (id)[_lineColor colorWithAlphaComponent:0.25].CGColor,
                              (id)_lineColor.CGColor];
}

- (UIColor *)lineColor {
    if ( _lineColor ) return _lineColor;
    return [UIColor whiteColor];
}

- (void)start {
    if ( _animating ) return;
    _animating = YES;
    self.alpha = 1;
    CABasicAnimation *rotationAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnim.toValue = [NSNumber numberWithFloat:2 * M_PI];
    rotationAnim.duration = self->_speed;
    rotationAnim.repeatCount = CGFLOAT_MAX;
    rotationAnim.removedOnCompletion = NO;
    [self->_gradientLayer addAnimation:rotationAnim forKey:@"rotation"];
}

- (void)stop {
    if ( !_animating ) return;
    _animating = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.001;
    } completion:^(BOOL finished) {
        if ( !self->_animating )
            [self->_gradientLayer removeAnimationForKey:@"rotation"];
    }];
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



@interface SJLoadingView ()
@property (nonatomic, strong, readonly) UILabel *speedLabel;
@property (nonatomic, strong, readonly) _SJRotatingAnimationView *animationView;
@end

@implementation SJLoadingView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    [self _updateSettings];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_updateSettings) name:SJVideoPlayerConfigurationsDidUpdateNotification object:nil];
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
- (BOOL)isAnimating {
    return _animationView.isAnimating;
}

- (void)start {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(_start) withObject:nil afterDelay:0.1 inModes:@[NSRunLoopCommonModes]];
}

- (void)stop {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(_stop) withObject:nil afterDelay:0.1 inModes:@[NSRunLoopCommonModes]];
}

- (void)setShowsNetworkSpeed:(BOOL)showsNetworkSpeed {
    _speedLabel.hidden = !showsNetworkSpeed;
}
- (BOOL)showsNetworkSpeed {
    return !_speedLabel.isHidden;
}

- (void)setNetworkSpeedStr:(nullable NSAttributedString *)networkSpeedStr {
    _speedLabel.attributedText = networkSpeedStr;
}
- (nullable NSAttributedString *)networkSpeedStr {
    return _speedLabel.attributedText;
}

#pragma mark -

- (void)_start {
    if ( self->_animationView.isAnimating )
        return;
    [UIView animateWithDuration:0.3 animations:^{
        [self->_animationView start];
        self.alpha = 1;
    }];
}

- (void)_stop {
    if ( !self->_animationView.isAnimating )
        return;
    [UIView animateWithDuration:0.3 animations:^{
        [self->_animationView stop];
        self.alpha = 0.001;
    }];
}

- (void)_setupView {
    self.clipsToBounds = NO;
    self.userInteractionEnabled = NO;
    
    _animationView = [[_SJRotatingAnimationView alloc] initWithFrame:CGRectZero];
    [self addSubview:_animationView];
    
    _speedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_speedLabel];
    
    [_animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_animationView.mas_bottom).offset(8);
        make.centerX.offset(0);
        make.width.offset(80);
    }];
    
    self.alpha = 0.001;
}

- (void)_updateSettings {
    _animationView.lineColor = SJVideoPlayerConfigurations.shared.resources.loadingLineColor;
}
@end
NS_ASSUME_NONNULL_END
