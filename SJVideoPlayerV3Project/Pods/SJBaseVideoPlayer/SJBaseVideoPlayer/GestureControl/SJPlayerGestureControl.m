//
//  SJPlayerGestureControl.m
//  SJPlayerGestureControl
//
//  Created by BlueDancer on 2017/12/10.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJPlayerGestureControl.h"

@interface SJPlayerGestureControl ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGR;
@property (nonatomic, strong, readonly) UIPinchGestureRecognizer *pinchGR;
@property (nonatomic, assign, readwrite) SJPanDirection panDirection;
@property (nonatomic, assign, readwrite) SJPanLocation panLocation;
@property (nonatomic, assign, readwrite) SJPanMovingDirection panMovingDirection;

@property (nonatomic, weak, readwrite) UIView *targetView;

@end

@implementation SJPlayerGestureControl

@synthesize singleTap = _singleTap;
@synthesize doubleTap = _doubleTap;
@synthesize panGR = _panGR;
@synthesize pinchGR = _pinchGR;

- (instancetype)initWithTargetView:(UIView *)view {
    self = [super init];
    if ( !self ) return nil;
    NSAssert(view, @"view can not be empty!");
    
    _targetView = view;
    [self _addGestureToControlView];
    return self;
}

- (void)_addGestureToControlView {
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    [self.doubleTap requireGestureRecognizerToFail:self.panGR];
    
    [_targetView addGestureRecognizer:_singleTap];
    [_targetView addGestureRecognizer:_doubleTap];
    [_targetView addGestureRecognizer:_panGR];
    [_targetView addGestureRecognizer:self.pinchGR];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ( gestureRecognizer == self.pinchGR ) {
        if ( self.pinchGR.numberOfTouches <= 1 ) return NO;
    }
    SJPlayerGestureType type = SJPlayerGestureType_Unknown;
    if ( gestureRecognizer == self.singleTap ) type = SJPlayerGestureType_SingleTap;
    else if ( gestureRecognizer == self.doubleTap ) type = SJPlayerGestureType_DoubleTap;
    else if ( gestureRecognizer == self.panGR ) type = SJPlayerGestureType_Pan;
    else if ( gestureRecognizer == self.pinchGR ) type = SJPlayerGestureType_Pinch;
    CGPoint locationPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    if ( locationPoint.x > _targetView.bounds.size.width / 2 ) {
        self.panLocation = SJPanLocation_Right;
    }
    else {
        self.panLocation = SJPanLocation_Left;
    }
    if ( _triggerCondition ) return _triggerCondition(self, type, gestureRecognizer);
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( otherGestureRecognizer != self.singleTap &&
         otherGestureRecognizer != self.doubleTap &&
         otherGestureRecognizer != self.panGR &&
         otherGestureRecognizer != self.pinchGR ) return NO;
    if ( gestureRecognizer.numberOfTouches >= 2 ) {
        return NO;
    }
    return YES;
}

- (UITapGestureRecognizer *)singleTap {
    if ( _singleTap ) return _singleTap;
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _singleTap.delegate = self;
    _singleTap.delaysTouchesBegan = YES;
    return _singleTap;
}
- (UITapGestureRecognizer *)doubleTap {
    if ( _doubleTap ) return _doubleTap;
    _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    _doubleTap.numberOfTapsRequired = 2;
    _doubleTap.delegate = self;
    _doubleTap.delaysTouchesBegan = YES;
    return _doubleTap;
}
- (UIPanGestureRecognizer *)panGR {
    if ( _panGR ) return _panGR;
    _panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panGR.delegate = self;
    _panGR.delaysTouchesBegan = YES;
    return _panGR;
}
- (UIPinchGestureRecognizer *)pinchGR {
    if ( _pinchGR ) return _pinchGR;
    _pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    _pinchGR.delegate = self;
    _pinchGR.delaysTouchesBegan = YES;
    return _pinchGR;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    if ( _singleTapped ) _singleTapped(self);
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    if ( _doubleTapped ) _doubleTapped(self);
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    
    CGPoint translate = [pan translationInView:pan.view];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            self.panMovingDirection = SJPanMovingDirection_Unkown;
            
            CGPoint velocity = [pan velocityInView:pan.view];
            CGFloat x = fabs(velocity.x);
            CGFloat y = fabs(velocity.y);
            if (x > y) {
                self.panDirection = SJPanDirection_H;
            }
            else {
                self.panDirection = SJPanDirection_V;
            }
            
            if ( _beganPan ) _beganPan(self, _panDirection, _panLocation);
        }
            break;
        case UIGestureRecognizerStateChanged: {
            switch ( _panDirection ) {
                case SJPanDirection_H: {
                    if ( translate.x > 0 ) self.panMovingDirection = SJPanMovingDirection_Right;
                    else if ( translate.y < 0 ) self.panMovingDirection = SJPanMovingDirection_Left;
                }
                    break;
                case SJPanDirection_V: {
                    if ( translate.y > 0 ) self.panMovingDirection = SJPanMovingDirection_Bottom;
                    else self.panMovingDirection = SJPanMovingDirection_Top;
                }
                    break;
                case SJPanDirection_Unknown: break;
            }
            if ( _changedPan ) _changedPan(self, _panDirection, _panLocation, translate);
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if ( _endedPan ) _endedPan(self, _panDirection, _panLocation);
        }
            break;
        default: break;
    }
    
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch {
    switch ( pinch.state ) {
        case UIGestureRecognizerStateEnded: {
            if ( self.pinched ) self.pinched(self, pinch.scale);
        }
            break;
        default:
            break;
    }
}
- (void)setPanMovingDirection:(SJPanMovingDirection)panMovingDirection {
    _panMovingDirection = panMovingDirection;
}

@end
