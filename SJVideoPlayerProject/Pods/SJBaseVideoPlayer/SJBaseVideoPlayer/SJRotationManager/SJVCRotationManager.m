//
//  SJVCRotationManager.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/9/20.
//  Copyright © 2018 SanJiang. All rights reserved.
//

#import "SJVCRotationManager.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif


NS_ASSUME_NONNULL_BEGIN
@interface SJVCRotationManager()
@property (nonatomic, copy) void(^rotateCompletionHandler)(id<SJRotationManagerProtocol> mgr);
@property (nonatomic) UIDeviceOrientation rec_deviceOrientation;
@property (nonatomic) SJOrientation currentOrientation;
@property (nonatomic) BOOL transitioning;
@property (nonatomic) BOOL needToForceRotation;
@end

@implementation SJVCRotationManager {
    __weak UIViewController *_atViewController;
}
@synthesize autorotationSupportedOrientation = _autorotationSupportedOrientation;
@synthesize disableAutorotation = _disableAutorotation;
@synthesize rotationCondition = _rotationCondition;
@synthesize delegate = _delegate;
@synthesize duration = _duration;
@synthesize superview = _superview;
@synthesize target = _target;

- (instancetype)initWithViewController:(__weak UIViewController *)atViewController {
    self = [super init];
    if ( !self ) return nil;
    _rec_deviceOrientation = UIDeviceOrientationPortrait;
    _autorotationSupportedOrientation = SJAutoRotateSupportedOrientation_All;
    [UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_refreshDeviceOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
    _atViewController = atViewController;
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)_refreshDeviceOrientation {
    UIDeviceOrientation dev_orientation = [UIDevice currentDevice].orientation;
    switch ( dev_orientation ) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            _rec_deviceOrientation = dev_orientation;
        }
            break;
        default:    break;
    }
}

- (BOOL)_isSupported:(SJOrientation)orientation {
    switch ( orientation ) {
        case SJOrientation_Portrait:
            return _autorotationSupportedOrientation & SJAutoRotateSupportedOrientation_Portrait;
        case SJOrientation_LandscapeLeft:
            return _autorotationSupportedOrientation & SJAutoRotateSupportedOrientation_LandscapeLeft;
        case SJOrientation_LandscapeRight:
            return _autorotationSupportedOrientation & SJAutoRotateSupportedOrientation_LandscapeRight;
    }
    return NO;
}

- (BOOL)isFullscreen {
    return _currentOrientation == SJOrientation_LandscapeLeft || _currentOrientation == SJOrientation_LandscapeRight;
}

- (void)rotate {
    if ( ![self _isSupported:SJOrientation_LandscapeLeft] &&
        ![self _isSupported:SJOrientation_LandscapeRight] ) {
        if ( [self isFullscreen] ) [self rotate:SJOrientation_Portrait animated:YES];
        else [self rotate:SJOrientation_LandscapeLeft animated:YES];
        return;
    }
    
    if ( [self isFullscreen] &&
        [self _isSupported:SJOrientation_Portrait] ) {
        [self rotate:SJOrientation_Portrait animated:YES];
        return;
    }
    
    if ( [self _isSupported:SJOrientation_LandscapeLeft] &&
        [self _isSupported:SJOrientation_LandscapeRight] ) {
        SJOrientation orientation = _sjOrientationForDeviceOrentation(_rec_deviceOrientation);
        if ( orientation == SJOrientation_Portrait ) orientation = SJOrientation_LandscapeLeft;
        [self rotate:orientation animated:YES];
        return;
    }
    
    if ( [self _isSupported:SJOrientation_LandscapeLeft] &&
        ![self _isSupported:SJOrientation_LandscapeRight] ) {
        [self rotate:SJOrientation_LandscapeLeft animated:YES];
        return;
    }
    
    if ( ![self _isSupported:SJOrientation_LandscapeLeft] &&
        [self _isSupported:SJOrientation_LandscapeRight] ) {
        [self rotate:SJOrientation_LandscapeRight animated:YES];
        return;
    }
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated {
    [self rotate:orientation animated:animated completionHandler:nil];
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void(^)(id<SJRotationManagerProtocol> mgr))completionHandler {
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.transitioning ) return;
        if ( !self.superview ) return;
        if ( !self.target ) return;
        if ( self.rotationCondition ) { if ( !self.rotationCondition(self) ) return; }
        if ( orientation == self.currentOrientation ) { if (completionHandler) completionHandler(self); return; }
        self.needToForceRotation = YES;
        self.rotateCompletionHandler = ^(id<SJRotationManagerProtocol>  _Nonnull mgr) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            self.needToForceRotation = NO;
            if ( completionHandler ) completionHandler(self);
        };
        [UIDevice.currentDevice setValue:@(_deviceOrentationForSJOrientation(orientation)) forKey:@"orientation"];
        [UIViewController attemptRotationToDeviceOrientation];
    });
}

- (void)vc_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    self.transitioning = YES;
    [self _refreshDeviceOrientation];
    self.currentOrientation = _sjOrientationForDeviceOrentation(self->_rec_deviceOrientation);
    BOOL isFull = size.width > size.height;
    if ( [self.delegate respondsToSelector:@selector(rotationManager:willRotateView:)] ) {
        [self.delegate rotationManager:self willRotateView:isFull];
    }
    
    [self.target mas_remakeConstraints:^(MASConstraintMaker *make) {
        if ( isFull ) make.edges.equalTo(self->_atViewController.view);
        else make.edges.equalTo(self.superview);
    }];
    [UIView animateWithDuration:coordinator.transitionDuration animations:^{
        [self.target layoutIfNeeded];
    }];
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.transitioning = NO;
        if ( isFull ) [self->_atViewController.view addSubview:self.target];
        else [self.superview addSubview:self.target];
        if ( [self.delegate respondsToSelector:@selector(rotationManager:didRotateView:)] ) {
            [self.delegate rotationManager:self didRotateView:isFull];
        }
        if ( self->_rotateCompletionHandler ) self->_rotateCompletionHandler(self);
        self->_rotateCompletionHandler = nil;
    }];
}

- (BOOL)vc_shouldAutorotate {
    [self _refreshDeviceOrientation];
    if ( self.rotationCondition && !self.rotationCondition(self) ) return NO;
    if ( self.needToForceRotation ) return YES;
    if ( [self _isSupported:_sjOrientationForDeviceOrentation(_rec_deviceOrientation)] ) return !self.disableAutorotation;
    return NO;
}
- (UIInterfaceOrientationMask)vc_supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (UIInterfaceOrientation)vc_preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

static UIDeviceOrientation _deviceOrentationForSJOrientation(SJOrientation orientation) {
    switch ( orientation ) {
        case SJOrientation_Portrait:
            return UIDeviceOrientationPortrait;
        case SJOrientation_LandscapeLeft:
            return UIDeviceOrientationLandscapeLeft;
        case SJOrientation_LandscapeRight:
            return UIDeviceOrientationLandscapeRight;
    }
}

static SJOrientation _sjOrientationForDeviceOrentation(UIDeviceOrientation orientation) {
    switch ( orientation ) {
        case UIDeviceOrientationPortrait:
            return SJOrientation_Portrait;
        case UIDeviceOrientationLandscapeLeft:
            return SJOrientation_LandscapeLeft;
        case UIDeviceOrientationLandscapeRight:
            return SJOrientation_LandscapeRight;
        default:
            return SJOrientation_Portrait;
    }
}
@end
NS_ASSUME_NONNULL_END
