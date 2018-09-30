//
//  SJProgressSlider.m
//  Pods-SJProgressSlider_Example
//
//  Created by BlueDancer on 2018/5/9.
//

#import "SJProgressSlider.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJProgressSliderImageView : UIImageView
@property (nonatomic, copy) void(^setImageExeBlock)(SJProgressSliderImageView *imageView);
@end

@implementation SJProgressSliderImageView
- (void)setImage:(nullable UIImage *)image {
    [super setImage:image];
    if ( _setImageExeBlock ) _setImageExeBlock(self);
}
@end

@interface SJProgressSlider ()
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

#pragma mark -
@implementation SJProgressSlider (SJBufferProgress)

- (BOOL)enableBufferProgress {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setEnableBufferProgress:(BOOL)enableBufferProgress {
    if ( enableBufferProgress == self.enableBufferProgress ) return;
    objc_setAssociatedObject(self, @selector(enableBufferProgress), @(enableBufferProgress), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    dispatch_async(dispatch_get_main_queue(), ^{
        if ( enableBufferProgress ) {
            UIView *bufferView = [self bufferProgressView];
            [self.containerView insertSubview:bufferView aboveSubview:self.trackImageView];
            bufferView.frame = CGRectMake(0, 0, 0, self.containerView.frame.size.height);
            CGFloat bufferProgress = self.bufferProgress;
            if ( 0 != bufferProgress ) [self _needUpdateBufferLayout];
        }
        else {
            [[self bufferProgressView] removeFromSuperview];
        }
    });
}

- (UIColor *)bufferProgressColor {
    UIColor *bufferProgressColor = objc_getAssociatedObject(self, _cmd);
    if ( bufferProgressColor ) return bufferProgressColor;
    return [UIColor grayColor];
}

- (void)setBufferProgressColor:(UIColor *)bufferProgressColor {
    if ( !bufferProgressColor ) return;
    objc_setAssociatedObject(self, @selector(bufferProgressColor), bufferProgressColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bufferProgressView.backgroundColor = bufferProgressColor;
    });
}

- (CGFloat)bufferProgress {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setBufferProgress:(CGFloat)bufferProgress {
    if ( isnan(bufferProgress) ) return;
    if ( bufferProgress < 0 ) bufferProgress = 0;
    else if ( bufferProgress > 1 ) bufferProgress = 1;
    objc_setAssociatedObject(self, @selector(bufferProgress), @(bufferProgress), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _needUpdateBufferLayout];
}

- (UIView *)bufferProgressView {
    UIView *bufferProgressView = objc_getAssociatedObject(self, _cmd);
    if ( bufferProgressView ) return bufferProgressView;
    bufferProgressView = [UIView new];
    bufferProgressView.backgroundColor = self.bufferProgressColor;
    objc_setAssociatedObject(self, _cmd, bufferProgressView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return bufferProgressView;
}

- (void)_needUpdateBufferLayout {
    UIView *bufferView = [self bufferProgressView];
    CGFloat width = self.bufferProgress * self.containerView.frame.size.width;
    CGRect frame = bufferView.frame;
    frame.size.height = self.containerView.frame.size.height;
    frame.size.width = width;
    bufferView.frame = frame;
}
@end


#pragma mark -
@implementation SJProgressSlider {
    UILabel *_promptLabel;
    NSLayoutConstraint *_promptLabelBottomConstraint;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupDefaultValues];
    [self _setupView];
    [self _setupGestrue];
    [self _needUpdateContainerCornerRadius];
    return self;
}

#pragma mark
- (void)_setupGestrue {
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGR:)];
    _pan.delaysTouchesBegan = YES;
    [self addGestureRecognizer:_pan];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGR:)];
    _tap.delaysTouchesBegan = YES;
    [self addGestureRecognizer:_tap];

    [_tap requireGestureRecognizerToFail:_pan];
    
    _tap.enabled = NO;
}

- (void)handlePanGR:(UIPanGestureRecognizer *)pan {
    CGFloat offset = [pan translationInView:pan.view].x;
    CGFloat add = ( offset / _containerView.bounds.size.width) * ( _maxValue - _minValue );
    [self setValue:self.value + add animated:YES];
    [pan setTranslation:CGPointZero inView:pan.view];

    switch ( pan.state ) {
        case UIGestureRecognizerStateBegan: {
            _isDragging = YES;
            if ( [self.delegate respondsToSelector:@selector(sliderWillBeginDragging:)] ) {
                [self.delegate sliderWillBeginDragging:self];
            }
        }
        case UIGestureRecognizerStateChanged: {
            if ( [self.delegate respondsToSelector:@selector(sliderDidDrag:)] ) {
                [self.delegate sliderDidDrag:self];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled: {
            if ( [self.delegate respondsToSelector:@selector(sliderDidEndDragging:)] ) {
                [self.delegate sliderDidEndDragging:self];
            }
            _isDragging = NO;
        }
            break;
        default:
            break;
    }
}

- (void)handleTapGR:(UITapGestureRecognizer *)tap {
    if ( _containerView.frame.size.width == 0 ) return;
    CGFloat point = [tap locationInView:tap.view].x;
    CGFloat value = point / _containerView.frame.size.width * (_maxValue - _minValue);
    [self setValue:value animated:YES];
}

#pragma mark -

- (void)setRound:(BOOL)round {
    if ( round == _round ) return;
    _round = round;
    [self _needUpdateContainerCornerRadius];
}

- (void)setTrackHeight:(CGFloat)trackHeight {
    _trackHeight = trackHeight;
    [self _needUpdateContainerCornerRadius];
    [self _needUpdateContainerLayout];
}

- (void)setThumbCornerRadius:(CGFloat)thumbCornerRadius
                        size:(CGSize)size {
    [self setThumbCornerRadius:thumbCornerRadius size:size thumbBackgroundColor:[UIColor greenColor]];
}

- (void)setThumbCornerRadius:(CGFloat)thumbCornerRadius
                        size:(CGSize)size
        thumbBackgroundColor:(UIColor *)thumbBackgroundColor {
    self.thumbImageView.layer.masksToBounds = NO;
    self.thumbImageView.layer.shadowColor = [UIColor colorWithWhite:0.382 alpha:0.614].CGColor;
    self.thumbImageView.layer.shadowOpacity = 1;
    self.thumbImageView.layer.shadowOffset = CGSizeMake(0.001, 0.2);
    self.thumbImageView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:(CGRect){CGPointZero, size} cornerRadius:thumbCornerRadius].CGPath;
    self.thumbImageView.layer.cornerRadius = thumbCornerRadius;
    self.thumbImageView.backgroundColor = thumbBackgroundColor;
    [self _updateThumbSize:size];
}

- (void)setValue:(CGFloat)value {
    [self setValue:value animated:NO];
}

- (void)setValue:(CGFloat)value_new animated:(BOOL)animated {
    if ( _minValue > _maxValue ) return;
    if ( isnan(value_new) ) return;
    if ( value_new == _value ) return;
    CGFloat value_old = _value;
    if      ( value_new < _minValue ) value_new = _minValue;
    else if ( value_new > _maxValue ) value_new = _maxValue;
    _value = value_new;
    
    if ( animated ) {
        CGFloat duration = 0;
        if ( animated ) duration = [self _calculateAnimaDuration:value_new - value_old];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animated ? duration : 0];
        [self _needUpdateTraceLayout];
        [UIView commitAnimations];
    }
    else {
        [self _needUpdateTraceLayout];
    }
}

/// add 此次增加的值
- (CGFloat)_calculateAnimaDuration:(CGFloat)add {
    add = ABS(add);
    CGFloat sum = _maxValue - _minValue;
    CGFloat scale = add / sum;
    return _animaMaxDuration * scale + 0.08/**/;
}

- (void)setIsLoading:(BOOL)isLoading {
    _isLoading = isLoading;
    if ( isLoading ) [self.indicatorView startAnimating];
    else [self.indicatorView stopAnimating];
}

- (void)setLoadingColor:(UIColor *)loadingColor {
    _loadingColor = loadingColor;
    _indicatorView.color = loadingColor;
}

#pragma mark
- (void)_setupDefaultValues {
    _animaMaxDuration = 0.5;
    _trackHeight = 8;
    _maxValue = 1;
    _minValue = 0;
    _round = YES;
    _value = 0;
    self.promptSpacing = 4.0;
    _loadingColor = [UIColor blackColor];
}

#pragma mark
- (void)_setupView {
    _containerView = [UIView new];
    _containerView.clipsToBounds = YES;
    
    SJProgressSliderImageView *(^makeImageView)(void) = ^SJProgressSliderImageView *{
        SJProgressSliderImageView *imageView = [SJProgressSliderImageView new];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeCenter;
        return imageView;
    };
    
    _traceImageView = makeImageView();
    _trackImageView = makeImageView();
    _thumbImageView = makeImageView();
    __weak typeof(self) _self = self;
    [(SJProgressSliderImageView *)_thumbImageView setSetImageExeBlock:^(SJProgressSliderImageView * _Nonnull imageView) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        imageView.bounds = (CGRect){CGPointZero, imageView.image.size};
        [self _needUpdateThumbLayout];
    }];
    
    [self addSubview:_containerView];
    [_containerView addSubview:self.trackImageView];
    [_containerView addSubview:self.traceImageView];
    [self addSubview:self.thumbImageView];
    
    _traceImageView.backgroundColor = [UIColor greenColor];
    _trackImageView.backgroundColor = [UIColor lightGrayColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _needUpdateContainerLayout];
}

- (UIActivityIndicatorView *)indicatorView {
    if ( _indicatorView ) return _indicatorView;
    _indicatorView = [[UIActivityIndicatorView alloc] init];
    [_thumbImageView addSubview:_indicatorView];
    _indicatorView.color = self.loadingColor;
    _indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [_thumbImageView addConstraint:[NSLayoutConstraint constraintWithItem:_indicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_thumbImageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [_thumbImageView addConstraint:[NSLayoutConstraint constraintWithItem:_indicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_thumbImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self _needUpdateIndicatorTransform];
    return _indicatorView;
}

#pragma mark -
- (void)_needUpdateContainerLayout {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    _containerView.bounds = CGRectMake(0, 0, width, _trackHeight);
    _containerView.center = CGPointMake(width * 0.5, height * 0.5);
    [self _needUpdateTrackLayout];
    if ( self.enableBufferProgress ) [self _needUpdateBufferLayout];
}

- (void)_needUpdateContainerCornerRadius {
    if ( _round ) _containerView.layer.cornerRadius = _trackHeight * 0.5;
    else _containerView.layer.cornerRadius = 0.0;
}

- (void)_needUpdateTrackLayout {
    CGFloat width = self.frame.size.width;
    _trackImageView.frame = CGRectMake(0, 0, width, _trackHeight);
    [self _needUpdateTraceLayout];
}

- (void)_needUpdateTraceLayout {
    CGFloat width = self.frame.size.width;
    CGFloat sum = _maxValue - _minValue;
    _traceImageView.frame = CGRectMake(0, 0, width * (_value - _minValue) / sum, _trackHeight);
    [self _needUpdateThumbLayout];
}

- (void)_needUpdateThumbLayout {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat maxX = CGRectGetMaxX(_traceImageView.frame);
    CGFloat margin = ceil(_thumbImageView.frame.size.width * 0.382);
    if ( maxX <= margin ) maxX = margin;
    else if ( maxX >= width - margin ) maxX = width - margin;
    _thumbImageView.center = CGPointMake(maxX, height * 0.5);
}

- (void)_updateThumbSize:(CGSize)size {
    _thumbImageView.bounds = (CGRect){CGPointZero, size};
    [self _needUpdateThumbLayout];
    [self _needUpdateIndicatorTransform];
}

- (void)_needUpdateIndicatorTransform {
    _indicatorView.transform = CGAffineTransformMakeScale(_thumbImageView.bounds.size.width / 16 * 0.6, _thumbImageView.bounds.size.height / 16 * 0.6);
}
@end


@implementation SJProgressSlider (Prompt)

- (UILabel *)promptLabel {
    if ( _promptLabel ) return _promptLabel;
    _promptLabel = [[UILabel alloc] init];
    [self addSubview:_promptLabel];
    _promptLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_promptLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_traceImageView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self addConstraint:_promptLabelBottomConstraint = [NSLayoutConstraint constraintWithItem:_promptLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_thumbImageView attribute:NSLayoutAttributeTop multiplier:1 constant:-self.promptSpacing]];
    return _promptLabel;
}

- (void)setPromptSpacing:(CGFloat)promptSpacing {
    objc_setAssociatedObject(self, @selector(promptSpacing), @(promptSpacing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _promptLabelBottomConstraint.constant = -promptSpacing;
}

- (CGFloat)promptSpacing {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

@end


@implementation SJProgressSlider (BorderLine)

- (void)setVisualBorder:(BOOL)visualBorder {
    if ( self.visualBorder == visualBorder ) return;
    objc_setAssociatedObject(self, @selector(visualBorder), @(visualBorder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( visualBorder ) {
        _containerView.layer.borderColor = self.borderColor.CGColor;
        _containerView.layer.borderWidth = self.borderWidth;
    }
    else {
        _containerView.layer.borderColor = nil;
        _containerView.layer.borderWidth = 0;
    }
}

- (BOOL)visualBorder {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setBorderColor:(UIColor * __nullable)borderColor {
    objc_setAssociatedObject(self, @selector(borderColor), borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( self.visualBorder ) _containerView.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor {
    UIColor *borderColor = objc_getAssociatedObject(self, _cmd);
    if ( borderColor ) return borderColor;
    return [UIColor lightGrayColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    objc_setAssociatedObject(self, @selector(borderWidth), @(borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( self.visualBorder ) _containerView.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth {
    CGFloat width = [objc_getAssociatedObject(self, _cmd) doubleValue];
    if ( width != 0 ) return width;
    return 0.4;
}

@end
NS_ASSUME_NONNULL_END
