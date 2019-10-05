//
//  SJVideoPlayerPresentView.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/11/29.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "SJVideoPlayerPresentView.h"
#import "SJBaseVideoPlayerConst.h"

NS_ASSUME_NONNULL_BEGIN
@interface _SJPerformRequestInfo : NSObject
@property (nonatomic) SEL selector;
@property (nonatomic, strong, nullable) id object;
@end

@implementation _SJPerformRequestInfo
@end


@interface SJVideoPlayerPresentView ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *pan;
@property (nonatomic, strong, readonly) UIPinchGestureRecognizer *pinch;

@property (nonatomic, strong, nullable) _SJPerformRequestInfo *placeholderRequestInfo;
@property (nonatomic, strong, nullable) _SJPerformRequestInfo *touchRequestInfo;
@end

@implementation SJVideoPlayerPresentView
@synthesize placeholderImageView = _placeholderImageView;
@synthesize supportedGestureTypes = _supportedGestureTypes;
@synthesize gestureRecognizerShouldTrigger = _gestureRecognizerShouldTrigger;
@synthesize singleTapHandler = _singleTapHandler;
@synthesize doubleTapHandler = _doubleTapHandler;
@synthesize panHandler = _panHandler;
@synthesize pinchHandler = _pinchHandler;
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
    if ( ![self _isSupporedGestureType:SJPlayerGestureTypeMask_SingleTap ] )
        return;
    
    CGPoint location = [tap locationInView:self];
    if ( _gestureRecognizerShouldTrigger && _gestureRecognizerShouldTrigger(self, SJPlayerGestureType_SingleTap, location) ) {
        if ( _singleTapHandler )
            _singleTapHandler(self, location);
    }
}

- (void)handleDoubleTap:(UITouch *)tap {
    if ( ![self _isSupporedGestureType:SJPlayerGestureTypeMask_DoubleTap] )
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

- (void)showPlaceholderAnimated:(BOOL)animated {
    if ( _placeholderImageView.isHidden == NO )
        return;
    
    if ( _placeholderRequestInfo != nil ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:_placeholderRequestInfo.selector
                                                   object:_placeholderRequestInfo.object];
        _placeholderRequestInfo = nil;
    }

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
    
    if ( _placeholderRequestInfo != nil ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:_placeholderRequestInfo.selector
                                                   object:_placeholderRequestInfo.object];
        _placeholderRequestInfo = nil;
    }
    
    if ( secs == 0 ) {
        [self _hiddenPlaceholderAnimated:@(animated)];
    }
    else {
        _placeholderRequestInfo = [_SJPerformRequestInfo new];
        _placeholderRequestInfo.selector = @selector(_hiddenPlaceholderAnimated:);
        _placeholderRequestInfo.object = @(animated);
        [self performSelector:_placeholderRequestInfo.selector
                   withObject:_placeholderRequestInfo.object afterDelay:secs inModes:@[NSRunLoopCommonModes]];
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
    }
    [gesture setValue:@(UIGestureRecognizerStateCancelled) forKey:@"state"];
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
    self.supportedGestureTypes = SJPlayerGestureTypeMask_All;
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

    [self addGestureRecognizer:_pan];
    [self addGestureRecognizer:_pinch];
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
    
    switch ( type ) {
        default: break;
        case SJPlayerGestureType_Pan: {
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
            
            if ( ![self _isSupporedGestureType:SJPlayerGestureTypeMask_Pan] )
                return NO;
            
            if ( _movingDirection == SJPanGestureMovingDirection_H && ![self _isSupporedGestureType:SJPlayerGestureTypeMask_Pan_H] )
                return NO;
            
            if ( _movingDirection == SJPanGestureMovingDirection_V && ![self _isSupporedGestureType:SJPlayerGestureTypeMask_Pan_V] )
                return NO;
        }
            break;
        case SJPlayerGestureType_Pinch: {
            if ( ![self _isSupporedGestureType:SJPlayerGestureTypeMask_Pinch] )
                return NO;
        }
            break;
    }
    
    if ( _gestureRecognizerShouldTrigger && !_gestureRecognizerShouldTrigger(self, type, [gestureRecognizer locationInView:gestureRecognizer.view]) )
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
        if ( _touchRequestInfo != nil ) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                     selector:_touchRequestInfo.selector
                                                       object:_touchRequestInfo.object];
            _touchRequestInfo = nil;
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if ( event.allTouches.count == 1 ) {
        if ( _touchRequestInfo != nil ) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                     selector:_touchRequestInfo.selector
                                                       object:_touchRequestInfo.object];
            _touchRequestInfo = nil;
        }
        
        UITouch *touch = touches.anyObject;
        
        if ( touch.tapCount == 0 )
            return;
        
        if ( touch.tapCount == 2 ) {
            [self _recognize:touch];
        }
        else {
            _touchRequestInfo = [_SJPerformRequestInfo new];
            _touchRequestInfo.selector = @selector(_recognize:);
            _touchRequestInfo.object = touch;
            [self performSelector:_touchRequestInfo.selector
                       withObject:_touchRequestInfo.object
                       afterDelay:0.180 inModes:@[NSRunLoopCommonModes]];
        }
    }
}

- (void)_recognize:(UITouch *)touch {
    if ( _touchRequestInfo != nil ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:_touchRequestInfo.selector
                                                   object:_touchRequestInfo.object];
        _touchRequestInfo = nil;
    }

    if ( touch.tapCount % 2 == 0 )
        [self handleDoubleTap:touch];
    else
        [self handleSingleTap:touch];
}

- (BOOL)_isSupporedGestureType:(SJPlayerGestureTypeMask)type {
    return _supportedGestureTypes & type;
}
@end
NS_ASSUME_NONNULL_END
