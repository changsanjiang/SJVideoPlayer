//
//  SJVideoPlayerPresentView.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/11/29.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "SJVideoPlayerPresentView.h"
#import "SJBaseVideoPlayerConst.h"
#import "NSTimer+SJAssetAdd.h"
#import <UIKit/UIGraphicsRendererSubclass.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerPresentView ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *pan;
@property (nonatomic, strong, readonly) UIPinchGestureRecognizer *pinch;
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPress;

@property (nonatomic, strong, nullable) NSTimer *timer; ///< 单击与双击手势识别timer
@property (nonatomic) NSInteger numberOfTaps;
@end

@implementation SJVideoPlayerPresentView
@synthesize placeholderImageView = _placeholderImageView;
@synthesize supportedGestureTypes = _supportedGestureTypes;
@synthesize gestureRecognizerShouldTrigger = _gestureRecognizerShouldTrigger;
@synthesize singleTapHandler = _singleTapHandler;
@synthesize doubleTapHandler = _doubleTapHandler;
@synthesize panHandler = _panHandler;
@synthesize pinchHandler = _pinchHandler;
@synthesize longPressHandler = _longPressHandler;
@synthesize movingDirection = _movingDirection;
@synthesize triggeredPosition = _triggeredPosition;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupViews];
    return self;
}

#ifdef SJ_MAC
- (void)dealloc {
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
}
#endif

- (void)layoutSubviews {
    [super layoutSubviews];
    if ( [self.delegate respondsToSelector:@selector(presentViewDidLayoutSubviews:)] ) {
        [self.delegate presentViewDidLayoutSubviews:self];
    }
}

- (void)willMoveToWindow:(nullable UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if ( [self.delegate respondsToSelector:@selector(presentViewWillMoveToWindow:)] ) {
        [self.delegate presentViewWillMoveToWindow:newWindow];
    }
}

- (void)handleSingleTap:(UITouch *)tap {
    if ( ![self _isSupported:SJPlayerGestureTypeMask_SingleTap ] )
        return;
    
    CGPoint location = [tap locationInView:self];
    if ( _gestureRecognizerShouldTrigger && _gestureRecognizerShouldTrigger(self, SJPlayerGestureType_SingleTap, location) ) {
        if ( _singleTapHandler )
            _singleTapHandler(self, location);
    }
}

- (void)handleDoubleTap:(UITouch *)tap {
    if ( ![self _isSupported:SJPlayerGestureTypeMask_DoubleTap] )
        return;
    
    CGPoint location = [tap locationInView:self];
    if ( _gestureRecognizerShouldTrigger && _gestureRecognizerShouldTrigger(self, SJPlayerGestureType_DoubleTap, location) ) {
        if ( _doubleTapHandler )
            _doubleTapHandler(self, location);
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translate = [pan translationInView:pan.view];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            if ( _panHandler ) _panHandler(self, _triggeredPosition, _movingDirection, SJPanGestureRecognizerStateBegan, translate);
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if ( _panHandler ) _panHandler(self, _triggeredPosition, _movingDirection, SJPanGestureRecognizerStateChanged, translate);
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if ( _panHandler ) _panHandler(self, _triggeredPosition, _movingDirection, SJPanGestureRecognizerStateEnded, translate);
        }
            break;
        default: break;
    }
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch {
    switch ( pinch.state ) {
        case UIGestureRecognizerStateEnded: {
            if ( _pinchHandler )
                _pinchHandler(self, pinch.scale);
        }
            break;
        default:
            break;
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress {
    switch ( longPress.state ) {
        case UIGestureRecognizerStateBegan: {
            if ( _longPressHandler ) _longPressHandler(self, SJLongPressGestureRecognizerStateBegan);
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if ( _longPressHandler ) _longPressHandler(self, SJLongPressGestureRecognizerStateChanged);
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            if ( _longPressHandler ) _longPressHandler(self, SJLongPressGestureRecognizerStateEnded);
        }
            break;
        default: break;
    }
}

- (void)showPlaceholderAnimated:(BOOL)animated {
    if ( _placeholderImageView.isHidden == NO )
        return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    _placeholderImageView.alpha = 0.001;
    _placeholderImageView.hidden = NO;
    
    if ( animated ) {
        [UIView animateWithDuration:0.4 animations:^{
            self->_placeholderImageView.alpha = 1;
        }];
    }
    else {
        _placeholderImageView.alpha = 1;
    }
}

- (void)hiddenPlaceholderAnimated:(BOOL)animated {
    [self hiddenPlaceholderAnimated:animated delay:0];
}

- (void)hiddenPlaceholderAnimated:(BOOL)animated delay:(NSTimeInterval)secs {
    if ( _placeholderImageView.isHidden == YES )
        return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if ( secs == 0 ) {
        [self _hiddenPlaceholderAnimated:@(animated)];
    }
    else {
        [self performSelector:@selector(_hiddenPlaceholderAnimated:)
                   withObject:@(animated) afterDelay:secs inModes:@[NSRunLoopCommonModes]];
    }
}

- (void)_hiddenPlaceholderAnimated:(NSNumber *)animated {
    if ( [animated boolValue] ) {
        [UIView animateWithDuration:0.4 animations:^{
            self->_placeholderImageView.alpha = 0.001;
        } completion:^(BOOL finished) {
            self->_placeholderImageView.hidden = YES;
        }];
    }
    else {
        _placeholderImageView.alpha = 0.001;
        _placeholderImageView.hidden = YES;
    }
}

- (void)cancelGesture:(SJPlayerGestureType)type {
    UIGestureRecognizer *gesture = nil;
    switch ( type ) {
        default: break;
        case SJPlayerGestureType_Pan:
            gesture = _pan;
            break;
        case SJPlayerGestureType_Pinch:
            gesture = _pinch;
            break;
        case SJPlayerGestureType_LongPress:
            gesture = _longPress;
            break;
    }
    gesture.state = UIGestureRecognizerStateCancelled;
}

- (UIGestureRecognizerState)stateOfGesture:(SJPlayerGestureType)type {
    UIGestureRecognizer *gesture = nil;
    switch ( type ) {
        default: break;
        case SJPlayerGestureType_Pan:
            gesture = _pan;
            break;
        case SJPlayerGestureType_Pinch:
            gesture = _pinch;
            break;
    }
    return gesture.state;
}

#pragma mark -

- (void)_setupViews {
    self.supportedGestureTypes = SJPlayerGestureTypeMask_Default;
    self.tag = SJBaseVideoPlayerPresentViewTag;
    self.backgroundColor = [UIColor blackColor];
    self.placeholderImageView.frame = self.bounds;
    _placeholderImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _placeholderImageView.hidden = YES;
    [self addSubview:_placeholderImageView];
    
    /// Pan
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _pan.minimumNumberOfTouches = 1;
    _pan.maximumNumberOfTouches = 1;
    _pan.delegate = self;
    _pan.delaysTouchesBegan = YES;
    
    /// Pinch
    _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    _pinch.delegate = self;

    /// LongPress
    _longPress = [UILongPressGestureRecognizer.alloc initWithTarget:self action:@selector(handleLongPress:)];
    _longPress.delaysTouchesBegan = YES;
    _longPress.delegate = self;
    [_pan shouldRequireFailureOfGestureRecognizer:_longPress];
    
    [self addGestureRecognizer:_pan];
    [self addGestureRecognizer:_pinch];
    [self addGestureRecognizer:_longPress];
}

- (UIImageView *)placeholderImageView {
    if ( _placeholderImageView ) return _placeholderImageView;
    _placeholderImageView = [UIImageView new];
    _placeholderImageView.contentMode = UIViewContentModeScaleAspectFill;
    _placeholderImageView.clipsToBounds = YES;
    return _placeholderImageView;
}

- (BOOL)isPlaceholderImageViewHidden {
    return _placeholderImageView.isHidden;
}

#pragma mark - gestures

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    SJPlayerGestureType type = SJPlayerGestureType_Pan;
    if ( gestureRecognizer == _pinch )
        type = SJPlayerGestureType_Pinch;
    else if ( gestureRecognizer == _longPress )
        type = SJPlayerGestureType_LongPress;
    
    switch ( type ) {
        default: break;
        case SJPlayerGestureType_Pan: {
            if ( ![self _isSupported:SJPlayerGestureTypeMask_Pan] )
                return NO;

            CGPoint location = [_pan locationInView:self];
            if ( location.x > self.bounds.size.width * 0.5 ) {
                _triggeredPosition = SJPanGestureTriggeredPosition_Right;
            }
            else {
                _triggeredPosition = SJPanGestureTriggeredPosition_Left;
            }
            
            CGPoint velocity = [_pan velocityInView:_pan.view];
            CGFloat x = fabs(velocity.x);
            CGFloat y = fabs(velocity.y);
            if (x > y) {
                _movingDirection = SJPanGestureMovingDirection_H;
            }
            else {
                _movingDirection = SJPanGestureMovingDirection_V;
            }
            
            if ( _movingDirection == SJPanGestureMovingDirection_H && ![self _isSupported:SJPlayerGestureTypeMask_Pan_H] )
                return NO;
            
            if ( _movingDirection == SJPanGestureMovingDirection_V && ![self _isSupported:SJPlayerGestureTypeMask_Pan_V] )
                return NO;
            
            if ( _longPress.state == UIGestureRecognizerStateChanged )
                return NO;
        }
            break;
        case SJPlayerGestureType_Pinch: {
            if ( ![self _isSupported:SJPlayerGestureTypeMask_Pinch] )
                return NO;
        }
            break;
        case SJPlayerGestureType_LongPress: {
            if ( ![self _isSupported:SJPlayerGestureTypeMask_LongPress] )
                return NO;
        }
            break;
    }
    
    if ( _gestureRecognizerShouldTrigger && !_gestureRecognizerShouldTrigger(self, type, [gestureRecognizer locationInView:self]) )
        return NO;

    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( UIGestureRecognizerStateFailed == gestureRecognizer.state ||
         UIGestureRecognizerStateCancelled == gestureRecognizer.state )
        return NO;
     
    if ( otherGestureRecognizer != _pan &&
         otherGestureRecognizer != _pinch )
        return NO;
    
    if ( gestureRecognizer.numberOfTouches >= 2 )
        return NO;
    
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if ( event.allTouches.count != 1 ) {
        [self _reset];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    /// 由于pan手势的存在, 拖动事件将会被pan手势拦截, 因此 此处可以放心的处理点击事件
    
    ///
    /// 只识别单指操作, 此处取消识别, return
    ///
    if ( event.allTouches.count != 1 ) {
        [self _reset];
        return;
    }
    
    ///
    /// 增加点击数
    ///
    _numberOfTaps += 1;
    
    ///
    /// 开启timer, 用于间隔到达之后, 识别单击手势
    ///
    if ( _timer == nil ) {
        _timer = [NSTimer sj_timerWithTimeInterval:0.2 repeats:YES];
        [_timer sj_fire];
        [NSRunLoop.currentRunLoop addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    
    ///
    /// 间隔到达之后, 识别为单击手势, 执行单击处理
    ///
    __weak typeof(self) _self = self;
    _timer.sj_usingBlock = ^(NSTimer * _Nonnull timer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _reset];
        [self handleSingleTap:touches.anyObject];
    };
    
    ///
    /// 计数为2时, 识别为双击手势, 执行双击处理
    ///
    if ( _numberOfTaps >= 2 ) {
        [self _reset];
        [_timer invalidate];
        [self handleDoubleTap:touches.anyObject];
    }
}

#pragma mark -

- (void)_reset {
    if ( _timer != nil ) {
        [_timer invalidate];
        _timer = nil;
    }
    _numberOfTaps = 0;
}

- (BOOL)_isSupported:(SJPlayerGestureTypeMask)type {
    return _supportedGestureTypes & type;
}
@end
NS_ASSUME_NONNULL_END
