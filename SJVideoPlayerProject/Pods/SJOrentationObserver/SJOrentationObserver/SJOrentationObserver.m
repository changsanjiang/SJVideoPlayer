//
//  SJOrentationObserver.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJOrentationObserver.h"
#import <Masonry/Masonry.h>


@interface SJOrentationObserver () {
    CGRect _portrait;
}

@property (nonatomic, strong, readonly) UIView *blackView;
@property (nonatomic, strong, readwrite) UIView *view;
@property (nonatomic, strong, readwrite) UIView *targetSuperview;
@property (nonatomic, readwrite, getter=isTransitioning) BOOL transitioning;
@property (nonatomic, readonly) SJSupportedRotateViewOrientation supported_Ori;
@property (nonatomic, readwrite) UIDeviceOrientation currentOrientation;
@property (nonatomic, copy, nullable) void(^completion)(SJOrentationObserver *observer);

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
    _rotateOrientation = SJRotateViewOrientation_Portrait;
    _currentOrientation = UIDeviceOrientationPortrait;
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

- (SJSupportedRotateViewOrientation)supported_Ori {
    SJSupportedRotateViewOrientation supported = self.supportedRotateViewOrientation;
    if ( SJSupportedRotateViewOrientation_All == supported ) supported = SJSupportedRotateViewOrientation_Portrait | SJSupportedRotateViewOrientation_LandscapeRight | SJSupportedRotateViewOrientation_LandscapeLeft;
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
            self.currentOrientation = [UIDevice currentDevice].orientation;
        }
            break;
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown: break;
    }
    
    SJSupportedRotateViewOrientation supported = self.supported_Ori;
    switch ( [UIDevice currentDevice].orientation ) {
        case UIDeviceOrientationPortrait: {
            if ( SJSupportedRotateViewOrientation_Portrait == (supported & SJSupportedRotateViewOrientation_Portrait) ) {
                self.rotateOrientation = SJRotateViewOrientation_Portrait;
            }
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            if ( SJSupportedRotateViewOrientation_LandscapeLeft == (supported & SJSupportedRotateViewOrientation_LandscapeLeft) ) {
                self.rotateOrientation = SJRotateViewOrientation_LandscapeLeft;
            }
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            if ( SJSupportedRotateViewOrientation_LandscapeRight == (supported & SJSupportedRotateViewOrientation_LandscapeRight) ) {
                self.rotateOrientation = SJRotateViewOrientation_LandscapeRight;
            }
        }
            break;
        default: break;
    }
}

- (BOOL)isFullScreen {
    return (SJRotateViewOrientation_LandscapeLeft == self.rotateOrientation ||
            SJRotateViewOrientation_LandscapeRight == self.rotateOrientation );
}

- (void)setRotateOrientation:(SJRotateViewOrientation)rotateOrientation {
    if ( rotateOrientation == _rotateOrientation ) return;
    [self rotate:rotateOrientation animated:YES];
}

- (BOOL)_changeOrientation {
    if ( self.isTransitioning ) return NO;
    SJSupportedRotateViewOrientation supported = self.supported_Ori;
    if ( self.isFullScreen &&
        SJSupportedRotateViewOrientation_Portrait == (supported & SJSupportedRotateViewOrientation_Portrait) ) {
        self.rotateOrientation = SJRotateViewOrientation_Portrait;
    }
    else {
        // 当前设备朝哪个方向, 就转到那个方向.
        switch ( self.currentOrientation ) {
            case UIDeviceOrientationLandscapeLeft: {
                if ( SJSupportedRotateViewOrientation_LandscapeLeft == (supported & SJSupportedRotateViewOrientation_LandscapeLeft) ) {
                    self.rotateOrientation = SJRotateViewOrientation_LandscapeLeft;
                }
            }
                break;
            case UIDeviceOrientationLandscapeRight: {
                if ( SJSupportedRotateViewOrientation_LandscapeRight == (supported & SJSupportedRotateViewOrientation_LandscapeRight) ) {
                    self.rotateOrientation = SJRotateViewOrientation_LandscapeRight;
                }
            }
                break;
            default: {
                if ( SJSupportedRotateViewOrientation_LandscapeLeft == (supported & SJSupportedRotateViewOrientation_LandscapeLeft) ) {
                    self.rotateOrientation = SJRotateViewOrientation_LandscapeLeft;
                }
                else if ( SJSupportedRotateViewOrientation_LandscapeRight == (supported & SJSupportedRotateViewOrientation_LandscapeRight) ) {
                    self.rotateOrientation = SJRotateViewOrientation_LandscapeRight;
                }
            }
                break;
        }
    }
    return YES;
}

- (void)rotate:(SJRotateViewOrientation)orientation animated:(BOOL)animated {
    [self rotate:orientation animated:animated completion:nil];
}

- (void)rotate:(SJRotateViewOrientation)orientation animated:(BOOL)animated completion:(void (^)(SJOrentationObserver * _Nonnull))block {
    if ( !_view || !_targetSuperview ) return;
    
    if ( self.isTransitioning ) return;
    
    if ( orientation == _rotateOrientation ) { if ( block ) block(self); return; }
    
    if ( _rotationCondition ) { if ( !_rotationCondition(self) ) return; }
    
    _transitioning = YES;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIInterfaceOrientation ori = UIInterfaceOrientationUnknown;
    
    switch ( orientation ) {
        case SJRotateViewOrientation_LandscapeRight: {
            ori = UIInterfaceOrientationLandscapeLeft;
            transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
            break;
        case SJRotateViewOrientation_LandscapeLeft: {
            ori = UIInterfaceOrientationLandscapeRight;
            transform = CGAffineTransformMakeRotation(M_PI_2);
        }
            break;
        case SJRotateViewOrientation_Portrait: {
            ori = UIInterfaceOrientationPortrait;
            transform = CGAffineTransformIdentity;
            [_blackView removeFromSuperview];
        }
            break;
    }
    
    SJRotateViewOrientation oldOri = _rotateOrientation;
    SJRotateViewOrientation newOri = orientation;
    
    if ( oldOri == SJRotateViewOrientation_Portrait ) {
        CGRect frame = [__window convertRect:_view.frame fromView:_targetSuperview];
        _view.frame = frame;
        [__window addSubview:_view];
        _portrait = frame;
    }
    
    
    // update
    _rotateOrientation = orientation;
    
    [UIApplication sharedApplication].statusBarOrientation = ori;
    
    [UIView beginAnimations:@"rotation" context:NULL];
    if ( animated ) [UIView setAnimationDuration:_duration];
    else [UIView setAnimationDuration:0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(_animationDidStop)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    if ( newOri == SJRotateViewOrientation_Portrait ) {
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
    [_view layoutIfNeeded];
    [UIView commitAnimations];
    _completion = [block copy];
    if ( _orientationWillChange ) _orientationWillChange(self, self.isFullScreen);
}

- (void)_animationDidStop {
    _transitioning = NO;
    if ( _rotateOrientation == SJRotateViewOrientation_Portrait ) {
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
    
    if ( _completion ) { _completion(self); _completion = nil;}
}
@end
