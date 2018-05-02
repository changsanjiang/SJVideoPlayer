//
//  SJOrentationObserver.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJOrentationObserver.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJOrentationObserver () {
    CGRect _portrait;
    UIDeviceOrientation _deviceOrientation;
}

@property (nonatomic, copy, nullable) void(^rotatedCompletionBlock)(SJOrentationObserver *observer);
@property (nonatomic, readwrite, getter=isTransitioning) BOOL transitioning;
@property (nonatomic, strong, readonly) UIView *blackView;
@property (nonatomic, strong) UIView *targetSuperview;
@property (nonatomic, strong) UIView *view;

@end

@implementation SJOrentationObserver

static UIWindow *__window;

- (instancetype)initWithTarget:(UIView *)view container:(UIView *)targetSuperview {
    self = [super init];
    if ( !self ) return nil;
    [self _observerDeviceOrientation];
    _view = view;
    _targetSuperview = targetSuperview;
    _duration = 0.25;
    _blackView = [UIView new];
    _blackView.backgroundColor = [UIColor blackColor];
    _orientation = SJOrientation_Portrait;
    _deviceOrientation = UIDeviceOrientationPortrait;
    __window = [(id)[UIApplication sharedApplication].delegate valueForKey:@"window"];
    return self;
}

- (instancetype)initWithTarget:(UIView *)rotateView container:(UIView *)rotateViewSuperView rotationCondition:(BOOL(^)(SJOrentationObserver *observer))rotationCondition {
    self = [self initWithTarget:rotateView container:rotateViewSuperView];
    if ( !self ) return nil;
    _rotationCondition = rotationCondition;
    return self;
}

- (void)dealloc {
    [_blackView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (SJAutoRotateSupportedOrientation)supported_Ori {
    SJAutoRotateSupportedOrientation supported = self.supportedOrientation;
    if ( SJAutoRotateSupportedOrientation_All == supported ) supported = SJAutoRotateSupportedOrientation_Portrait | SJAutoRotateSupportedOrientation_LandscapeRight | SJAutoRotateSupportedOrientation_LandscapeLeft;
    return supported;
}

- (void)_observerDeviceOrientation {
    if ( ![UIDevice currentDevice].generatesDeviceOrientationNotifications ) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)_handleDeviceOrientationChange {
    switch ( [UIDevice currentDevice].orientation ) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            _deviceOrientation = [UIDevice currentDevice].orientation;
        }
            break;
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown: break;
    }
    
    SJAutoRotateSupportedOrientation supported = self.supported_Ori;
    switch ( [UIDevice currentDevice].orientation ) {
        case UIDeviceOrientationPortrait: {
            if ( SJAutoRotateSupportedOrientation_Portrait == (supported & SJAutoRotateSupportedOrientation_Portrait) ) {
                self.orientation = SJOrientation_Portrait;
            }
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            if ( SJAutoRotateSupportedOrientation_LandscapeLeft == (supported & SJAutoRotateSupportedOrientation_LandscapeLeft) ) {
                self.orientation = SJOrientation_LandscapeLeft;
            }
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            if ( SJAutoRotateSupportedOrientation_LandscapeRight == (supported & SJAutoRotateSupportedOrientation_LandscapeRight) ) {
                self.orientation = SJOrientation_LandscapeRight;
            }
        }
            break;
        default: break;
    }
}

- (BOOL)isFullScreen {
    return (SJOrientation_LandscapeLeft == self.orientation ||
            SJOrientation_LandscapeRight == self.orientation );
}

- (void)setOrientation:(SJOrientation)orientation {
    if ( orientation == _orientation ) return;
    [self rotate:orientation animated:YES];
}

- (BOOL)rotate {
    if ( self.isTransitioning ) return NO;
    SJAutoRotateSupportedOrientation supported = self.supported_Ori;
    if ( self.isFullScreen &&
        SJAutoRotateSupportedOrientation_Portrait == (supported & SJAutoRotateSupportedOrientation_Portrait) ) {
        self.orientation = SJOrientation_Portrait;
    }
    else {
        // 当前设备朝哪个方向, 就转到那个方向.
        switch ( _deviceOrientation ) {
            case UIDeviceOrientationLandscapeLeft: {
                if ( SJAutoRotateSupportedOrientation_LandscapeLeft == (supported & SJAutoRotateSupportedOrientation_LandscapeLeft) ) {
                    self.orientation = SJOrientation_LandscapeLeft;
                }
            }
                break;
            case UIDeviceOrientationLandscapeRight: {
                if ( SJAutoRotateSupportedOrientation_LandscapeRight == (supported & SJAutoRotateSupportedOrientation_LandscapeRight) ) {
                    self.orientation = SJOrientation_LandscapeRight;
                }
            }
                break;
            default: {
                if ( SJAutoRotateSupportedOrientation_LandscapeLeft == (supported & SJAutoRotateSupportedOrientation_LandscapeLeft) ) {
                    self.orientation = SJOrientation_LandscapeLeft;
                }
                else if ( SJAutoRotateSupportedOrientation_LandscapeRight == (supported & SJAutoRotateSupportedOrientation_LandscapeRight) ) {
                    self.orientation = SJOrientation_LandscapeRight;
                }
            }
                break;
        }
    }
    return YES;
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated {
    [self rotate:orientation animated:animated completion:nil];
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completion:(void (^__nullable)(SJOrentationObserver * _Nonnull))block {
    if ( !_view || !_targetSuperview ) return;
    
    if ( self.isTransitioning ) return;
    
    if ( orientation == _orientation ) { if ( block ) block(self); return; }
    
    if ( _rotationCondition ) { if ( !_rotationCondition(self) ) return; }
    
    _transitioning = YES;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIInterfaceOrientation ori = UIInterfaceOrientationUnknown;
    
    switch ( orientation ) {
        case SJOrientation_LandscapeRight: {
            ori = UIInterfaceOrientationLandscapeLeft;
            transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
            break;
        case SJOrientation_LandscapeLeft: {
            ori = UIInterfaceOrientationLandscapeRight;
            transform = CGAffineTransformMakeRotation(M_PI_2);
        }
            break;
        case SJOrientation_Portrait: {
            ori = UIInterfaceOrientationPortrait;
            transform = CGAffineTransformIdentity;
            [_blackView removeFromSuperview];
        }
            break;
    }
    
    SJOrientation oldOri = _orientation;
    SJOrientation newOri = orientation;
    
    if ( oldOri == SJOrientation_Portrait ) {
        CGRect frame = [__window convertRect:_view.frame fromView:_targetSuperview];
        _view.frame = frame;
        [__window addSubview:_view];
        _portrait = frame;
    }
    
    
    // update
    _orientation = orientation;
    
    [UIApplication sharedApplication].statusBarOrientation = ori;
    
    [UIView beginAnimations:@"rotation" context:NULL];
    if ( animated ) [UIView setAnimationDuration:_duration];
    else [UIView setAnimationDuration:0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(_animationDidStop)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    if ( newOri == SJOrientation_Portrait ) {
        _view.bounds = CGRectMake(0, 0, _portrait.size.width, _portrait.size.height);
        _view.center = CGPointMake(_portrait.origin.x + _portrait.size.width * 0.5, _portrait.origin.y + _portrait.size.height * 0.5);
    }
    else {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        CGFloat max = MAX(width, height);
        CGFloat min = MIN(width, height);
        _view.bounds = CGRectMake(0, 0, max, min);
        _view.center = CGPointMake(min * 0.5, max * 0.5);
    }
    [_view setTransform:transform];
    [UIView commitAnimations];
    _rotatedCompletionBlock = [block copy];
    if ( _orientationWillChange ) _orientationWillChange(self, self.isFullScreen);
}

- (void)_animationDidStop {
    _transitioning = NO;
    if ( _orientation == SJOrientation_Portrait ) {
        [_targetSuperview addSubview:_view];
        _view.frame = _targetSuperview.bounds;
    }
    else {
        self.blackView.bounds = _view.bounds;
        self.blackView.center = _view.center;
        self.blackView.transform = _view.transform;
        [__window insertSubview:self.blackView belowSubview:_view];
    }
    
    if ( _orientationChanged ) _orientationChanged(self, self.isFullScreen);
    
    if ( _rotatedCompletionBlock ) { _rotatedCompletionBlock(self); _rotatedCompletionBlock = nil;}
}
@end
NS_ASSUME_NONNULL_END
