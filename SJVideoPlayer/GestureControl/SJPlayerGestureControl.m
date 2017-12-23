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

@property (nonatomic, weak, readwrite) UIView *targetView;
@property (nonatomic, assign, readwrite) SJPanDirection panDirection;
@property (nonatomic, assign, readwrite) SJPanLocation panLocation;

@end

@implementation SJPlayerGestureControl

@synthesize singleTap = _singleTap;
@synthesize doubleTap = _doubleTap;
@synthesize panGR = _panGR;

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
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ( _triggerCondition ) return _triggerCondition(self, gestureRecognizer);
    return YES;
}

- (UITapGestureRecognizer *)singleTap {
    if ( _singleTap ) return _singleTap;
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _singleTap.delegate = self;
    return _singleTap;
}
- (UITapGestureRecognizer *)doubleTap {
    if ( _doubleTap ) return _doubleTap;
    _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    _doubleTap.numberOfTapsRequired = 2;
    _doubleTap.delegate = self;
    return _doubleTap;
}
- (UIPanGestureRecognizer *)panGR {
    if ( _panGR ) return _panGR;
    _panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panGR.delegate = self;
    return _panGR;
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
        case UIGestureRecognizerStateBegan:{
            CGPoint locationPoint = [pan locationInView:pan.view];
            if ( locationPoint.x > _targetView.bounds.size.width / 2 ) {
                self.panLocation = SJPanLocation_Right;
            }
            else {
                self.panLocation = SJPanLocation_Left;
            }
            
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
        case UIGestureRecognizerStateChanged:{
            if ( _changedPan ) _changedPan(self, _panDirection, _panLocation, translate);
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            if ( _endedPan ) _endedPan(self, _panDirection, _panLocation);
        }
            break;
        default: break;
    }
    
    [pan setTranslation:CGPointZero inView:pan.view];
}

@end

