//
//  SJSlider.m
//  dancebaby
//
//  Created by BlueDancer on 2017/6/12.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJSlider.h"

#import <Masonry/Masonry.h>

#import <objc/message.h>




@interface UIView (SJExtension)
@property (nonatomic, assign) CGFloat csj_x;
@property (nonatomic, assign) CGFloat csj_y;
@property (nonatomic, assign) CGFloat csj_w;
@property (nonatomic, assign) CGFloat csj_h;
@end


@implementation UIView (SJExtension)
- (void)setCsj_x:(CGFloat)csj_x {
    CGRect frame    = self.frame;
    frame.origin.x  = csj_x;
    self.frame      = frame;
}
- (CGFloat)csj_x {
    return self.frame.origin.x;
}


- (void)setCsj_y:(CGFloat)csj_y {
    CGRect frame    = self.frame;
    frame.origin.y  = csj_y;
    self.frame      = frame;
}

- (CGFloat)csj_y {
    return self.frame.origin.y;
}


- (void)setCsj_w:(CGFloat)csj_w {
    CGRect frame        = self.frame;
    frame.size.width    = csj_w;
    self.frame          = frame;
}
- (CGFloat)csj_w {
    return self.frame.size.width;
}


- (void)setCsj_h:(CGFloat)csj_h {
    CGRect frame        = self.frame;
    frame.size.height   = csj_h;
    self.frame          = frame;
}
- (CGFloat)csj_h {
    return self.frame.size.height;
}
@end



// MARK:

@interface _SJImageView : UIImageView

@property (nonatomic, copy) void(^layoutedCallBlock)(_SJImageView *imageView);

@end

@implementation _SJImageView

- (void)layoutSubviews {
    [super layoutSubviews];
    if ( _layoutedCallBlock ) _layoutedCallBlock(self);
}

@end


@interface SJContainerView : UIView

@end

@implementation SJContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJContainerViewSetupUI];
    return self;
}

// MARK: UI

- (void)_SJContainerViewSetupUI {
    self.clipsToBounds = YES;
}

@end



@interface SJSlider ()

@property (nonatomic, strong, readonly) SJContainerView *containerView;
@property (nonatomic, strong, readonly) NSLayoutConstraint *thumbCenterXConstraint;
@property (nonatomic, strong, readonly) NSLayoutConstraint *thumbLeadingConstraint;
@property (nonatomic, strong, readonly) NSLayoutConstraint *thumbTrailingConstraint;

@end







@implementation SJSlider

@synthesize containerView = _containerView;
@synthesize trackImageView = _trackImageView;
@synthesize traceImageView = _traceImageView;
@synthesize thumbImageView = _thumbImageView;
@synthesize pan = _pan;
@synthesize thumbCenterXConstraint = _thumbCenterXConstraint;
@synthesize thumbLeadingConstraint = _thumbLeadingConstraint;
@synthesize thumbTrailingConstraint = _thumbTrailingConstraint;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    
    [self _SJSliderSetupUI];
    
    [self _SJSliderInitialize];
    
    [self _SJSliderPanGR];
    
    return self;
}

#pragma mark - Setter

- (void)setIsRound:(BOOL)isRound {
    _isRound = isRound;
    
    if ( isRound ) self.containerView.layer.cornerRadius = self.trackHeight * 0.5;
    else self.containerView.layer.cornerRadius = 0.0;
}

- (void)setThumbCornerRadius:(CGFloat)thumbCornerRadius size:(CGSize)size {
    [self setThumbCornerRadius:thumbCornerRadius size:size thumbBackgroundColor:[UIColor greenColor]];
}

- (void)setThumbCornerRadius:(CGFloat)thumbCornerRadius
                        size:(CGSize)size
        thumbBackgroundColor:(UIColor *)thumbBackgroundColor {
    if ( 0 != thumbCornerRadius ) {
        self.thumbImageView.layer.masksToBounds = NO;
        self.thumbImageView.layer.shadowColor = [UIColor colorWithWhite:0.382 alpha:0.614].CGColor;
        self.thumbImageView.layer.shadowOpacity = 1;
        self.thumbImageView.layer.shadowOffset = CGSizeMake(0.001, 0.2);
        self.thumbImageView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:(CGRect){CGPointZero, size} cornerRadius:thumbCornerRadius].CGPath;
        [self.thumbImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_offset(size).priorityHigh();
        }];
    }
    else {
        [_thumbImageView removeFromSuperview];
        _thumbImageView = nil;
    }
    self.thumbImageView.layer.cornerRadius = thumbCornerRadius;
    self.thumbImageView.backgroundColor = thumbBackgroundColor;
    [self _updateLayout];
}

- (void)setTrackHeight:(CGFloat)trackHeight {
    if ( trackHeight == _trackHeight ) return;
    _trackHeight = trackHeight;
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(trackHeight);
    }];
    
    if ( self.isRound ) self.containerView.layer.cornerRadius = self.trackHeight * 0.5;
    else self.containerView.layer.cornerRadius = 0.0;
}

- (void)setValue:(CGFloat)value {
    if ( isnan(value) ) return;
    if ( value == _value ) return;
    if      ( value < _minValue ) value = _minValue;
    else if ( value > _maxValue ) value = _maxValue;
    else if ( _minValue > _maxValue ) value = 0;
    _value = value;
    [self _updateLayout];
}

- (void)setValue:(CGFloat)value animated:(BOOL)animated {
    self.value = value;
    if ( animated ) {
        [self _anima];
    }
}

- (void)_anima {
    [UIView animateWithDuration:0.15 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)_updateLayout {
    CGFloat sub = _maxValue - _minValue;
    if ( sub <= 0 ) return;
    [_containerView.constraints enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( obj.firstItem == _traceImageView ) {
            if ( obj.firstAttribute == NSLayoutAttributeWidth ) {
                [_containerView removeConstraint:obj];
            }
        }
    }];
    
    CGFloat baseW = _thumbImageView.bounds.size.width * 0.4;
    if ( 0 == baseW ) baseW = 0.001;
    NSLayoutConstraint *traceWidthConstraint =
    [NSLayoutConstraint constraintWithItem:_traceImageView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_containerView
                                 attribute:NSLayoutAttributeWidth
                                multiplier:(_value - _minValue) / sub constant:baseW];
    [_containerView addConstraint:traceWidthConstraint];
}

- (void)setMinValue:(CGFloat)minValue {
    _minValue = minValue;
    self.value = _value;
}

- (void)setMaxValue:(CGFloat)maxValue {
    _maxValue = maxValue;
    self.value = _value;
}

// MARK: 生命周期

- (void)dealloc {
    NSLog(@"%s", __func__);
}


// MARK: 初始化参数

- (void)_SJSliderInitialize {
    
    self.trackHeight = 8.0;
    self.borderWidth = 0.4;
    self.borderColor = [UIColor lightGrayColor];
    self.isRound = YES;
    
    self.enableBufferProgress = NO;
    self.bufferProgress = 0;
    self.bufferProgressColor = [UIColor grayColor];
    
    _minValue = 0.0;
    _maxValue = 1.0;
    [self _updateLayout];
}

- (void)_SJSliderPanGR {
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGR:)];
    [self addGestureRecognizer:_pan];
}

- (void)handlePanGR:(UIPanGestureRecognizer *)pan {
    
    CGFloat offset = [pan translationInView:pan.view].x;
    CGFloat add = ( offset / _containerView.csj_w) * ( _maxValue - _minValue );
    [self setValue:self.value + add animated:YES];
    [pan setTranslation:CGPointZero inView:pan.view];
    
    switch (pan.state) {
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

#pragma mark -

- (void)_SJSliderSetupUI {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.trackImageView];
    [self.containerView addSubview:self.traceImageView];
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.offset(0);
        make.centerY.offset(0);
    }];
    
    [_trackImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_traceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.leading.offset(0).priority(UILayoutPriorityDefaultLow);
    }];
}

- (UIView *)containerView {
    if ( _containerView ) return _containerView;
    _containerView = [SJContainerView new];
    return _containerView;
}

- (UIImageView *)trackImageView {
    if ( _trackImageView ) return _trackImageView;
    _trackImageView = [self imageViewWithImageStr:@""];
    _trackImageView.backgroundColor = [UIColor whiteColor];
    return _trackImageView;
}

- (UIImageView *)traceImageView {
    if ( _traceImageView ) return _traceImageView;
    _traceImageView = [self imageViewWithImageStr:@""];
    _traceImageView.frame = CGRectZero;
    _traceImageView.backgroundColor = [UIColor greenColor];
    return _traceImageView;
}

- (UIImageView *)thumbImageView {
    if ( _thumbImageView ) return _thumbImageView;
    _thumbImageView = [self imageViewWithImageStr:@""];
    [self addSubview:_thumbImageView];

    _thumbImageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *centerYConstraint =
    [NSLayoutConstraint constraintWithItem:_thumbImageView
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_containerView
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1 constant:0];
    
    _thumbCenterXConstraint =
    [NSLayoutConstraint constraintWithItem:_thumbImageView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_traceImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1 constant:0];
    _thumbLeadingConstraint.priority = UILayoutPriorityDefaultLow;
    
    _thumbLeadingConstraint =
    [NSLayoutConstraint constraintWithItem:_thumbImageView
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                    toItem:_containerView
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1 constant:0];
    _thumbLeadingConstraint.priority = UILayoutPriorityRequired;
    
    _thumbTrailingConstraint =
    [NSLayoutConstraint constraintWithItem:_thumbImageView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                    toItem:_containerView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1 constant:0];
    _thumbTrailingConstraint.priority = UILayoutPriorityRequired;
    
    [self addConstraint:_thumbLeadingConstraint];
    [self addConstraint:centerYConstraint];
    [self addConstraint:_thumbCenterXConstraint];
    [self addConstraint:_thumbTrailingConstraint];
    
    __weak typeof(self) _self = self;
    [(_SJImageView *)_thumbImageView setLayoutedCallBlock:^(_SJImageView *imageView) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        CGFloat constant = imageView.bounds.size.width * 0.4;
        self.thumbLeadingConstraint.constant = -constant;
        self.thumbTrailingConstraint.constant = -constant;
        [self _updateLayout];
    }];
    
    [_thumbImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_thumbImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_thumbImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_thumbImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    return _thumbImageView;
}

- (UIImageView *)imageViewWithImageStr:(NSString *)imageStr {
    UIImageView *imageView = [[_SJImageView alloc] initWithImage:[UIImage imageNamed:imageStr]];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.clipsToBounds = YES;
    return imageView;
}

@end





#pragma mark - Buffer

@implementation SJSlider (SJBufferProgress)

- (BOOL)enableBufferProgress {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setEnableBufferProgress:(BOOL)enableBufferProgress {
    if ( enableBufferProgress == self.enableBufferProgress ) return;
    objc_setAssociatedObject(self, @selector(enableBufferProgress), @(enableBufferProgress), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( enableBufferProgress ) {
            [self.containerView insertSubview:[self bufferProgressView] aboveSubview:self.trackImageView];
            [[self bufferProgressView] mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.leading.bottom.offset(0);
            }];
            CGFloat bufferProgress = self.bufferProgress;
            if ( 0 != bufferProgress ) self.bufferProgress = bufferProgress; // update
        }
        else {
            [[self bufferProgressView] removeFromSuperview];
        }
    });
    
}

- (UIColor *)bufferProgressColor {
    return objc_getAssociatedObject(self, _cmd);
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
    bufferProgress += 0.001;
    if      ( bufferProgress >= 1 ) bufferProgress = 1;
    else if ( bufferProgress < 0 ) bufferProgress = 0;
    objc_setAssociatedObject(self, @selector(bufferProgress), @(bufferProgress), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UIView *bufferProgressView = [self bufferProgressView];
    if ( !bufferProgressView.superview ) return ;
    [self.containerView.constraints enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( obj.firstItem == bufferProgressView ) {
            if ( obj.firstAttribute == NSLayoutAttributeWidth ) {
                [self.containerView removeConstraint:obj];
            }
        }
    }];
    NSLayoutConstraint *bufferProgressWidthConstraint =
    [NSLayoutConstraint constraintWithItem:bufferProgressView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.containerView
                                 attribute:NSLayoutAttributeWidth
                                multiplier:bufferProgress constant:0];
    [self.containerView addConstraint:bufferProgressWidthConstraint];
}

- (UIView *)bufferProgressView {
    UIView *bufferProgressView = objc_getAssociatedObject(self, _cmd);
    if ( bufferProgressView ) return bufferProgressView;
    bufferProgressView = [UIView new];
    objc_setAssociatedObject(self, _cmd, bufferProgressView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return bufferProgressView;
}

@end



#pragma mark - Border


@implementation SJSlider (BorderLine)

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

- (void)setBorderColor:(UIColor *)borderColor {
    objc_setAssociatedObject(self, @selector(borderColor), borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( self.visualBorder ) _containerView.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    objc_setAssociatedObject(self, @selector(borderWidth), @(borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( self.visualBorder ) _containerView.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

@end

