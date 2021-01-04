//
//  SJSpeedupPlaybackPopupView.m
//  Pods
//
//  Created by BlueDancer on 2020/2/21.
//

#import "SJSpeedupPlaybackPopupView.h"
#import "SJVideoPlayerConfigurations.h"
#import <SJBaseVideoPlayer/CALayer+SJBaseVideoPlayerExtended.h>
#import <SJUIKit/NSAttributedString+SJMake.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJSpeedupPlaybackPopupView ()
@property (nonatomic, strong, readonly) NSArray<CAShapeLayer *> *triangles;
@property (nonatomic, strong, readonly) CATextLayer *textLayer;
@end

@implementation SJSpeedupPlaybackPopupView
@synthesize animating = _animating;
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        [self _setupViews];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_updateSettings) name:SJVideoPlayerConfigurationsDidUpdateNotification object:nil];
        [self _updateSettings];
        self.rate = 2.0;
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (CGSize)intrinsicContentSize {
    CGFloat size = _triangles.firstObject.bounds.size.width;
    CGFloat left = 8;
    CGFloat lineWidth = _triangles.firstObject.lineWidth;
    return CGSizeMake(ceil(left + lineWidth * 2 + size * 2 + 2 + _textLayer.bounds.size.width + left), 28);
}

- (void)setRate:(CGFloat)rate {
    if ( rate != _rate ) {
        _rate = rate;
        id<SJVideoPlayerControlLayerResources> sources = SJVideoPlayerConfigurations.shared.resources;
        id<SJVideoPlayerLocalizedStrings> strings = SJVideoPlayerConfigurations.shared.localizedStrings;
        NSAttributedString *text = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append([NSString stringWithFormat:@"%.01fx", rate]).textColor(sources.speedupPlaybackRateTextColor).font(sources.speedupPlaybackRateTextFont);
            if ( strings.longPressSpeedupPlayback.length != 0 ) {
                make.append(@" ");
                make.append(strings.longPressSpeedupPlayback).font(sources.speedupPlaybackTextFont).textColor(sources.speedupPlaybackTextColor);
            }
        }];
        
        _textLayer.string = text;
        _textLayer.bounds = (CGRect){0, 0, [text sj_textSize]};
        [self invalidateIntrinsicContentSize];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    self.layer.cornerRadius = bounds.size.height * 0.5;
    CGFloat left = 8;
    CGFloat lineWidth = _triangles.firstObject.lineWidth;
    CAShapeLayer *first = _triangles.firstObject;
    first.frame = (CGRect){left + lineWidth, (bounds.size.height - first.bounds.size.height) * 0.5, first.bounds.size};
    CAShapeLayer *last = _triangles.lastObject;
    last.frame = (CGRect){CGRectGetMaxX(first.frame), (bounds.size.height - last.bounds.size.height) * 0.5, last.bounds.size};
    _textLayer.frame = (CGRect){CGRectGetMaxX(last.frame) + lineWidth + 2, (bounds.size.height - _textLayer.bounds.size.height) * 0.5, _textLayer.bounds.size};
}

- (void)_setupViews {
    _animating = NO;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    self.alpha = 0.001;
    self.userInteractionEnabled = NO;

    {
        NSMutableArray<CAShapeLayer *> *m = [NSMutableArray new];
        CGFloat size = 6;
        CGRect bounds = CGRectMake(0, 0, size, size);
        for ( int i = 0 ; i < 2 ; ++ i ) {
            CAShapeLayer *triangleLayer = [CAShapeLayer layer];
            triangleLayer.bounds = bounds;
            
            CGFloat angle = 60 * M_PI/180.0;
            CGFloat a = size * sin(angle);
            CGFloat b = size * cos(angle);
            CGPoint start = CGPointMake(0, 0);
            CGPoint middle = CGPointMake(a, b);
            CGPoint end = CGPointMake(0, size);
            
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
            
            triangleLayer.opacity = 1;
        }
        _triangles = m;
    }
    
    _textLayer = [CATextLayer layer];
    _textLayer.contentsScale = UIScreen.mainScreen.scale;
    [self.layer addSublayer:_textLayer];
}

- (void)show {
    _animating = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
    [self _showAnimations];
}

- (void)hidden {
    _animating = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.001;
    }];
}

- (void)_showAnimations {
    [self _recursiveAnimationWithBeginIndex:0];
}

- (void)_recursiveAnimationWithBeginIndex:(NSInteger)idx {
    if ( _animating == NO )
        return;
    if ( idx < 0 )
        return;
    
    CAShapeLayer *layer = self.triangles[idx];
    __weak typeof(self) _self = self;
    [layer addAnimation:[self _opacityAnimationWithDuration:0.3] stopHandler:^(CAAnimation * _Nonnull anim, BOOL isFinished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _recursiveAnimationWithBeginIndex:idx > 0 ? (idx - 1) : (self.triangles.count - 1)];
    }];
}

- (CAKeyframeAnimation *)_opacityAnimationWithDuration:(NSTimeInterval)duration {
    CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    anima.values = @[ @(1), @(0.1), @(1) ];
    anima.duration = duration;
    return anima;
}

- (void)_updateSettings {
    id<SJVideoPlayerControlLayerResources> sources = SJVideoPlayerConfigurations.shared.resources;
    for ( CAShapeLayer *layer in _triangles ) {
        layer.strokeColor = layer.fillColor = sources.speedupPlaybackTriangleColor.CGColor;
    }
}
@end
NS_ASSUME_NONNULL_END
