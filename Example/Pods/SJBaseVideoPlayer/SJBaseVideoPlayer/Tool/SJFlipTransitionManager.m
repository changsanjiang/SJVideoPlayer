//
//  SJFlipTransitionManager.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJFlipTransitionManager.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJFlipTransitionManagerObserver : NSObject<SJFlipTransitionManagerObserver>
- (instancetype)initWithManager:(id<SJFlipTransitionManager>)mgr;
@end

@implementation SJFlipTransitionManagerObserver
@synthesize flipTransitionDidStopExeBlock = _flipTransitionDidStopExeBlock;
@synthesize flipTransitionDidStartExeBlock = _flipTransitionDidStartExeBlock;

- (instancetype)initWithManager:(id<SJFlipTransitionManager>)mgr {
    self = [super init];
    if ( !self )
        return nil;
    [(id)mgr sj_addObserver:self forKeyPath:@"transitioning"];
    return self;
}

- (void)observeValueForKeyPath:(NSString *_Nullable)keyPath ofObject:(id _Nullable)object change:(NSDictionary<NSKeyValueChangeKey,id> *_Nullable)change context:(void *_Nullable)context {
    if ( [change[NSKeyValueChangeOldKey] integerValue] == [change[NSKeyValueChangeNewKey] integerValue] )
        return;
    
    id<SJFlipTransitionManager> mgr = object;
    if ( mgr.isTransitioning ) {
        if ( _flipTransitionDidStartExeBlock )
            _flipTransitionDidStartExeBlock(mgr);
    }
    else {
        if ( _flipTransitionDidStopExeBlock )
            _flipTransitionDidStopExeBlock(mgr);
    }
}
@end

@interface SJFlipTransitionManager ()<CAAnimationDelegate>
@property (nonatomic) SJViewFlipTransition innerFlipTransition;
@property (nonatomic, strong, readonly) UIView *target;
@property (nonatomic, getter=isTransitioning) BOOL transitioning;
@end

@implementation SJFlipTransitionManager {
    void(^_Nullable _completionHandler)(id<SJFlipTransitionManager> mgr);
}

@synthesize duration = _duration;

- (instancetype)initWithTarget:(UIView *)target {
    self = [super init];
    if ( !self )
        return nil;
    _target = target;
    _duration = 1.0;
    return self;
}

- (id<SJFlipTransitionManagerObserver>)getObserver {
    return [[SJFlipTransitionManagerObserver alloc] initWithManager:self];
}

- (SJViewFlipTransition)flipTransition {
    return _innerFlipTransition;
}

- (void)setFlipTransition:(SJViewFlipTransition)flipTransition {
    [self setFlipTransition:flipTransition animated:YES];
}

- (void)setFlipTransition:(SJViewFlipTransition)t animated:(BOOL)animated {
    [self setFlipTransition:t animated:animated completionHandler:nil];
}

- (void)setFlipTransition:(SJViewFlipTransition)t animated:(BOOL)animated completionHandler:(void(^_Nullable)(id<SJFlipTransitionManager> mgr))completionHandler {
    if ( t == _innerFlipTransition )
        return;
    
    if ( self.isTransitioning )
        return;
    
    _innerFlipTransition = t;
    self.transitioning = YES;
    
    CATransform3D transform = CATransform3DIdentity;
    switch ( t ) {
        case SJViewFlipTransition_Identity: {
            transform = CATransform3DIdentity;
        }
            break;
        case SJViewFlipTransition_Horizontally: {
            transform = CATransform3DConcat(CATransform3DMakeRotation(M_PI, 0, 1, 0), CATransform3DMakeTranslation(0, 0, -10000));
        }
            break;
    }

    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotationAnimation.fromValue = [NSValue valueWithCATransform3D:_target.layer.transform];
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:transform];
    rotationAnimation.duration = _duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.delegate = self;
    [_target.layer addAnimation:rotationAnimation forKey:nil];
    _target.layer.transform = transform;
    _completionHandler = completionHandler;
}

- (void)animationDidStart:(CAAnimation *)anim { }

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.transitioning = NO;
    
    if ( _completionHandler ) {
        _completionHandler(self);
        _completionHandler = nil;
    }
}
@end
NS_ASSUME_NONNULL_END
