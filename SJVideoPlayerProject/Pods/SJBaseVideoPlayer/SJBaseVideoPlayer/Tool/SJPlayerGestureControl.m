//
//  SJPlayerGestureControl.m
//  Masonry
//
//  Created by 畅三江 on 2019/1/3.
//

#import "SJPlayerGestureControl.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJPlayerGestureControl ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong, readonly) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *pan;
@property (nonatomic, strong, readonly) UIPinchGestureRecognizer *pinch;
@end

@implementation SJPlayerGestureControl
@synthesize targetView = _targetView;

@synthesize disabledGestures = _disabledGestures;
@synthesize gestureRecognizerShouldTrigger = _gestureRecognizerShouldTrigger;
@synthesize singleTapHandler = _singleTapHandler;
@synthesize doubleTapHandler = _doubleTapHandler;
@synthesize panHandler = _panHandler;
@synthesize pinchHandler = _pinchHandler;
@synthesize movingDirection = _movingDirection;
@synthesize triggeredPosition = _triggeredPosition;

- (instancetype)initWithTargetView:(UIView * _Nonnull __weak)view {
    self = [super init];
    if ( !self ) return nil;
    NSAssert(view, @"view can not be empty!");
    _targetView = view;
    
    /// Single Tap
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _singleTap.delegate = self;
    _singleTap.delaysTouchesBegan = YES;
    
    /// Double Tap
    _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    _doubleTap.numberOfTapsRequired = 2;
    _doubleTap.delegate = self;
    _doubleTap.delaysTouchesBegan = YES;

    /// Pan
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _pan.minimumNumberOfTouches = 1;
    _pan.maximumNumberOfTouches = 1;
    _pan.delegate = self;
    _pan.delaysTouchesBegan = YES;

    /// Pinch
    _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    _pinch.delegate = self;
    
    [_singleTap requireGestureRecognizerToFail:_doubleTap];
    [_doubleTap requireGestureRecognizerToFail:_pan];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [view addGestureRecognizer:self->_singleTap];
        [view addGestureRecognizer:self->_doubleTap];
        [view addGestureRecognizer:self->_pan];
        [view addGestureRecognizer:self->_pinch];
    });
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    SJPlayerGestureType type = SJPlayerGestureType_Pan;
    if ( gestureRecognizer == _singleTap )
        type = SJPlayerGestureType_SingleTap;
    else if ( gestureRecognizer == _doubleTap )
        type = SJPlayerGestureType_DoubleTap;
    else if ( gestureRecognizer == _pinch )
        type = SJPlayerGestureType_Pinch;
    
    switch ( type ) {
        case SJPlayerGestureType_SingleTap: {
            if ( SJPlayerDisabledGestures_SingleTap & _disabledGestures )
                return NO;
        }
            break;
        case SJPlayerGestureType_DoubleTap: {
            if ( SJPlayerDisabledGestures_DoubleTap & _disabledGestures )
                return NO;
        }
            break;
        case SJPlayerGestureType_Pan: {
            CGPoint location = [_pan locationInView:_pan.view];
            if ( location.x > _targetView.bounds.size.width * 0.5 ) {
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
            
            if ( SJPlayerDisabledGestures_Pan & _disabledGestures )
                return NO;
            
            if ( SJPanGestureMovingDirection_H == _movingDirection &&
                 SJPlayerDisabledGestures_Pan_H & _disabledGestures )
                return NO;
            
            if ( SJPanGestureMovingDirection_V == _movingDirection &&
                SJPlayerDisabledGestures_Pan_V & _disabledGestures )
                return NO;
        }
            break;
        case SJPlayerGestureType_Pinch: {
            if ( SJPlayerDisabledGestures_Pinch & _disabledGestures )
                return NO;
        }
            break;
    }
    
    if ( _gestureRecognizerShouldTrigger && !_gestureRecognizerShouldTrigger(self, type, [gestureRecognizer locationInView:gestureRecognizer.view]) )
        return NO;
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( UIGestureRecognizerStateFailed ==  gestureRecognizer.state ||
         UIGestureRecognizerStateCancelled == gestureRecognizer.state )
        return NO;
    
    if ( otherGestureRecognizer != _singleTap &&
         otherGestureRecognizer != _doubleTap &&
         otherGestureRecognizer != _pan &&
         otherGestureRecognizer != _pinch )
        return NO;
    
    if ( gestureRecognizer.numberOfTouches >= 2 )
        return NO;
    
    return YES;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    if ( _singleTapHandler )
        _singleTapHandler(self, [tap locationInView:tap.view]);
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    if ( _doubleTapHandler )
        _doubleTapHandler(self, [tap locationInView:tap.view]);
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

- (void)cancelGesture:(SJPlayerGestureType)type {
    UIGestureRecognizer *gesture = nil;
    switch ( type ) {
        case SJPlayerGestureType_SingleTap:
            gesture = _singleTap;
            break;
        case SJPlayerGestureType_DoubleTap:
            gesture = _doubleTap;
            break;
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
        case SJPlayerGestureType_SingleTap:
            gesture = _singleTap;
            break;
        case SJPlayerGestureType_DoubleTap:
            gesture = _doubleTap;
            break;
        case SJPlayerGestureType_Pan:
            gesture = _pan;
            break;
        case SJPlayerGestureType_Pinch:
            gesture = _pinch;
            break;
    }
    return gesture.state;
}
@end
NS_ASSUME_NONNULL_END
