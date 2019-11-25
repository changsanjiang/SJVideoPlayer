//
//  SJEdgeFastForwardViewController.m
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/6/30.
//

#import "SJEdgeFastForwardViewController.h"
#import "CALayer+SJBaseVideoPlayerExtended.h"

NS_ASSUME_NONNULL_BEGIN
UIKIT_STATIC_INLINE CGFloat
_getControlPoint(CGFloat p0, CGFloat p2, CGFloat t, CGFloat c) {
    //  c = pow(1 - t, 2) * p0 + 2 * t * (1 - t) * p1 + pow(t, 2) * p2;
    //  2 * t * (1 - t) * p1 = c - pow(1 - t, 2) * p0 + pow(t, 2) * p2;
    //  p1 = (pow(1 - t, 2) * p0 +  pow(t, 2) * p2 + c) / (2 * t * (1 - t));
    //
    return (c - (pow(1 - t, 2) * p0 +  pow(t, 2) * p2)) / (2 * t * (1 - t));
}


@interface _SJEdgeFastForwardView : UIView
@property (nonatomic, readonly) SJFastForwardTriggeredPosition position;
@property (nonatomic, strong, readonly) UIView *roundView;
@property (nonatomic, strong, readonly) CAShapeLayer *roundLayer;
@property (nonatomic, strong, readonly) NSArray<CAShapeLayer *> *triangles;
@property (nonatomic, strong, readonly) CATextLayer *textLayer;
@property (nonatomic, strong, nullable) UIColor *blockColor;
@end

@implementation _SJEdgeFastForwardView
- (instancetype)initWithFrame:(CGRect)frame position:(SJFastForwardTriggeredPosition)position {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    
    _position = position;
    
    {
        _roundLayer = [CAShapeLayer layer];
        _roundLayer.opacity = 0.001;
        _roundLayer.fillColor = [UIColor colorWithWhite:0.8 alpha:0.3].CGColor;
        [self.layer addSublayer:_roundLayer];
    }
    
    {
        NSMutableArray<CAShapeLayer *> *m = [NSMutableArray new];
        CGFloat size = 8;
        for ( int i = 0 ; i < 3 ; ++ i ) {
            CAShapeLayer *triangleLayer = [CAShapeLayer layer];
            triangleLayer.bounds = CGRectMake(0, 0, size, size);
            
            CGFloat angle = 60 * M_PI/180.0;
            CGFloat a = size * sin(angle);
            CGFloat b = size * cos(angle);
            CGPoint start = CGPointZero;
            CGPoint middle = CGPointZero;
            CGPoint end = CGPointZero;
            
            switch ( self.position ) {
                case SJFastForwardTriggeredPosition_Left: {
                    start = CGPointMake(a, 0);
                    middle = CGPointMake(0, b);
                    end = CGPointMake(a, size);
                }
                    break;
                case SJFastForwardTriggeredPosition_Right: {
                    start = CGPointMake(0, 0);
                    middle = CGPointMake(a, b);
                    end = CGPointMake(0, size);
                }
                    break;
            }
            
            UIBezierPath *bezierPath = [UIBezierPath bezierPath];
            [bezierPath moveToPoint:start];
            [bezierPath addLineToPoint:middle];
            [bezierPath addLineToPoint:end];
            [bezierPath closePath];
            triangleLayer.path = bezierPath.CGPath;
            triangleLayer.lineJoin = kCALineJoinRound;
            triangleLayer.lineWidth = size * 0.5;
            [self.layer addSublayer:triangleLayer];
            [m addObject:triangleLayer];
            
            triangleLayer.opacity = 0.001;
        }
        _triangles = m;
    }
    
    {
        _textLayer = [CATextLayer layer];
        _textLayer.fontSize = 10;
        _textLayer.contentsScale = UIScreen.mainScreen.scale;
        _textLayer.opacity = 0.001;
        switch ( _position ) {
            case SJFastForwardTriggeredPosition_Left: {
                _textLayer.alignmentMode = kCAAlignmentRight;
            }
                break;
            case SJFastForwardTriggeredPosition_Right: {
                _textLayer.alignmentMode = kCAAlignmentLeft;
            }
                break;
        }
        [self.layer addSublayer:_textLayer];
    }
    return self;
}

- (void)setBlockColor:(nullable UIColor *)blockColor {
    _blockColor = blockColor;
    for ( CAShapeLayer *triangleLayer in _triangles ) {
        triangleLayer.strokeColor = blockColor.CGColor;
        triangleLayer.fillColor = blockColor.CGColor;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    {
        _roundLayer.frame = bounds;
        
        CGPoint p0 = CGPointZero;
        CGPoint p2 = CGPointZero;
        CGPoint point = CGPointZero;
        switch ( _position ) {
            case SJFastForwardTriggeredPosition_Left: {
                point = CGPointMake(bounds.size.width, bounds.size.height * 0.5);
                
                p0 = CGPointMake(0, 0);
                p2 = CGPointMake(0, bounds.size.height);
            }
                break;
            case SJFastForwardTriggeredPosition_Right: {
                point = CGPointMake(0, bounds.size.height * 0.5);
                
                p0 = CGPointMake(bounds.size.width, 0);
                p2 = CGPointMake(bounds.size.width, bounds.size.height);
            }
                break;
        }
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        CGFloat controlPointX = _getControlPoint(p0.x, p2.x, 0.5, point.x);
        CGFloat controlPointY = _getControlPoint(p0.y, p2.y, 0.5, point.y);
        [bezierPath moveToPoint:p0];
        [bezierPath addQuadCurveToPoint:p2 controlPoint:CGPointMake(controlPointX, controlPointY)];
        [bezierPath closePath];
        _roundLayer.path = bezierPath.CGPath;
    }
    
    {
        __block CGFloat position = 0;
        switch ( self.position ) {
            case SJFastForwardTriggeredPosition_Left:
                position = bounds.size.width * 0.8;
                break;
            case SJFastForwardTriggeredPosition_Right:
                position = bounds.size.width * 0.2;
                break;
        }
        [_triangles enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGPoint new = CGPointMake(position, bounds.size.height * 0.5);
            obj.position = new;
            switch ( self.position ) {
                case SJFastForwardTriggeredPosition_Left:
                    position -= obj.bounds.size.width + 4;
                    break;
                case SJFastForwardTriggeredPosition_Right:
                    position += obj.bounds.size.width + 4;
                    break;
            }
        }];
    }
    
    {
        switch ( self.position ) {
            case SJFastForwardTriggeredPosition_Left: {
                CALayer *topLayer = _triangles.lastObject;
                _textLayer.frame = CGRectMake(0,
                                              CGRectGetMaxY(topLayer.frame) + 8,
                                              CGRectGetMaxX(topLayer.frame),
                                              30);
            }
                break;
            case SJFastForwardTriggeredPosition_Right: {
                CALayer *topLayer = _triangles.lastObject;
                _textLayer.frame = CGRectMake(CGRectGetMinX(topLayer.frame),
                                              CGRectGetMaxY(topLayer.frame) + 8,
                                              bounds.size.width - CGRectGetMinX(topLayer.frame),
                                              30);
            }
                break;
        }
    }
}

- (void)showAnimations {
    [_roundLayer addAnimation:[self _opacityAnimationWithDuration:1] forKey:nil];
    [self _recursiveAnimation:self.triangles.count - 1];
    [_textLayer addAnimation:[self _opacityAnimationWithDuration:1] forKey:nil];
}

- (void)_recursiveAnimation:(NSInteger)idx {
    if ( idx < 0 )
        return;
    
    CAShapeLayer *layer = self.triangles[idx];
    __weak typeof(self) _self = self;
    [layer addAnimation:[self _opacityAnimationWithDuration:0.3] stopHandler:^(CAAnimation * _Nonnull anim, BOOL isFinished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _recursiveAnimation:idx - 1];
    }];
}

- (CABasicAnimation *)_opacityAnimationWithDuration:(NSTimeInterval)duration {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.fromValue = @(1);
    anim.toValue = @(0.001);
    anim.duration = duration;
    return anim;
}
@end


@interface SJEdgeFastForwardViewController ()
@property (nonatomic, strong, readonly) _SJEdgeFastForwardView *leftView;
@property (nonatomic, strong, readonly) _SJEdgeFastForwardView *rightView;
@end

@implementation SJEdgeFastForwardViewController {
    NSLayoutConstraint *_Nullable _leftWidth;
    NSLayoutConstraint *_Nullable _rightWidth;
}
@synthesize enabled = _enabled;
@synthesize target = _target;
@synthesize triggerAreaWidth = _triggerAreaWidth;
@synthesize spanSecs = _spanSecs;
@synthesize blockColor = _blockColor;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _spanSecs = 10;
    _triggerAreaWidth = 100;
    return self;
}

- (void)setTriggerAreaWidth:(CGFloat)triggerAreaWidth {
    if ( triggerAreaWidth != _triggerAreaWidth ) {
        _triggerAreaWidth = triggerAreaWidth;
        _leftWidth.constant = triggerAreaWidth;
        _rightWidth.constant = triggerAreaWidth;
    }
}

- (UIColor *)blockColor {
    if ( _blockColor == nil ) {
        _blockColor = UIColor.orangeColor;
    }
    return _blockColor;
}

- (void)showFastForwardView:(SJFastForwardTriggeredPosition)position {
    if ( !_enabled )
        return;
    
    switch ( position ) {
        case SJFastForwardTriggeredPosition_Left: {
            if ( self.leftView.superview == nil ) {
                [self.target addSubview:self.leftView];
                self.leftView.translatesAutoresizingMaskIntoConstraints = NO;
                if ( @available(iOS 9.0, *) ) {
                    [self.leftView.topAnchor constraintEqualToAnchor:self.target.topAnchor].active = YES;
                    [self.leftView.leftAnchor constraintEqualToAnchor:self.target.leftAnchor].active = YES;
                    [self.leftView.bottomAnchor constraintEqualToAnchor:self.target.bottomAnchor].active = YES;
                    _leftWidth = [self.leftView.widthAnchor constraintEqualToConstant:_triggerAreaWidth];
                    _leftWidth.active = YES;
                }
                [self.target layoutIfNeeded];
            }
            
            self.leftView.textLayer.string = [NSString stringWithFormat:@"快退%.0lf秒", self.spanSecs];
            self.leftView.blockColor = self.blockColor;
            [self.leftView showAnimations];
        }
            break;
        case SJFastForwardTriggeredPosition_Right: {
            if ( self.rightView.superview == nil ) {
                [self.target addSubview:self.rightView];
                self.rightView.translatesAutoresizingMaskIntoConstraints = NO;
                if ( @available(iOS 9.0, *) ) {
                    [self.rightView.topAnchor constraintEqualToAnchor:self.target.topAnchor].active = YES;
                    [self.rightView.rightAnchor constraintEqualToAnchor:self.target.rightAnchor].active = YES;
                    [self.rightView.bottomAnchor constraintEqualToAnchor:self.target.bottomAnchor].active = YES;
                    _rightWidth = [self.rightView.widthAnchor constraintEqualToConstant:_triggerAreaWidth];
                    _rightWidth.active = YES;
                }
                
                [self.target layoutIfNeeded];
            }
            
            self.rightView.textLayer.string = [NSString stringWithFormat:@"快进%.0lf秒", self.spanSecs];
            self.rightView.blockColor = self.blockColor;
            [self.rightView showAnimations];
        }
            break;
    }
}

@synthesize leftView = _leftView;
- (_SJEdgeFastForwardView *)leftView {
    if ( _leftView == nil ) {
        _leftView = [[_SJEdgeFastForwardView alloc] initWithFrame:CGRectZero position:SJFastForwardTriggeredPosition_Left];
        _leftView.userInteractionEnabled = NO;
    }
    return _leftView;
}

@synthesize rightView = _rightView;
- (_SJEdgeFastForwardView *)rightView {
    if ( _rightView == nil ) {
        _rightView = [[_SJEdgeFastForwardView alloc] initWithFrame:CGRectZero position:SJFastForwardTriggeredPosition_Right];
        _rightView.userInteractionEnabled = NO;
    }
    return _rightView;
}
@end
NS_ASSUME_NONNULL_END
