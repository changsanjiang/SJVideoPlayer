//
//  SJOrentationObserver.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJOrentationObserver.h"
#import <Masonry/Masonry.h>

@interface SJOrentationObserver ()

@property (nonatomic, assign, readwrite, getter=isFullScreen) BOOL fullScreen;

@property (nonatomic, strong, readwrite) UIView *view;
@property (nonatomic, strong, readwrite) UIView *targetSuperview;

@property (nonatomic, assign, readwrite, getter=isTransitioning) BOOL transitioning;

@end

@implementation SJOrentationObserver

- (instancetype)initWithTarget:(UIView *)view container:(UIView *)targetSuperview {
    self = [super init];
    if ( !self ) return nil;
    [self _observerDeviceOrientation];
    _view = view;
    _targetSuperview = targetSuperview;
    _duration = 0.3;
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
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
        case UIDeviceOrientationPortrait: {
            self.fullScreen = NO;
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            self.fullScreen = YES;
        }
            break;
        default: break;
    }
}

- (void)setFullScreen:(BOOL)fullScreen {
    if ( !_view || !_targetSuperview ) return;
    
    if ( self.rotationCondition ) {
        if ( !self.rotationCondition(self) ) return;
    }
    
    if ( self.isTransitioning ) return;
    
    
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if ( (UIDeviceOrientation)statusBarOrientation == deviceOrientation ) return;
    
    _fullScreen = fullScreen;
    self.transitioning = YES;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIView *superview = nil;
    UIInterfaceOrientation ori = UIInterfaceOrientationUnknown;
    switch ( [UIDevice currentDevice].orientation ) {
        case UIDeviceOrientationPortrait: {
            ori = UIInterfaceOrientationPortrait;
            transform = CGAffineTransformIdentity;
            superview = self.targetSuperview;
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            ori = UIInterfaceOrientationLandscapeRight;
            transform = CGAffineTransformMakeRotation(M_PI_2);
            superview = [UIApplication sharedApplication].keyWindow;
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            ori = UIInterfaceOrientationLandscapeLeft;
            transform = CGAffineTransformMakeRotation(-M_PI_2);
            superview = [UIApplication sharedApplication].keyWindow;
        }
            break;
        default: break;
    }
    
    if ( !superview || UIInterfaceOrientationUnknown == ori ) {
        self.transitioning = NO;
        return;
    }
    
    [superview addSubview:_view];
    _view.translatesAutoresizingMaskIntoConstraints = NO;
    if ( UIInterfaceOrientationPortrait == ori ) {
        [_view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
    }
    else {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        CGFloat max = MAX(width, height);
        CGFloat min = MIN(width, height);
        [_view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.offset(0);
            make.size.mas_offset(CGSizeMake(max, min));
        }];
    }
    
    [UIView animateWithDuration:_duration animations:^{
        _view.transform = transform;
    } completion:^(BOOL finished) {
        self.transitioning = NO;
    }];
    [UIApplication sharedApplication].statusBarOrientation = ori;
    if ( _orientationChanged ) _orientationChanged(self);
}

- (BOOL)_changeOrientation {
    if ( self.isTransitioning ) return NO;
    UIDeviceOrientation n_ori = UIDeviceOrientationUnknown;
    if ( self.fullScreen ) n_ori = UIDeviceOrientationPortrait;
    else n_ori = UIDeviceOrientationLandscapeLeft;
    
    
    if ( n_ori == [UIDevice currentDevice].orientation ) {
        self.fullScreen = !self.fullScreen;
    }
    else {
        [[UIDevice currentDevice] setValue:@(n_ori) forKey:@"orientation"];
    }
    return YES;
}

@end
