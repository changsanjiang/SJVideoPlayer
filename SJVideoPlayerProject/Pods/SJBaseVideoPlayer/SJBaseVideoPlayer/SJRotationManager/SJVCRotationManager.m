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
#if __has_include(<SJObserverHelper/NSObject+SJObserverHelper.h>)
#import <SJObserverHelper/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJVCRotationManagerObserver : NSObject<SJRotationManagerObserver>
@end

@implementation SJVCRotationManagerObserver
@synthesize rotationDidStartExeBlock = _rotationDidStartExeBlock;
@synthesize rotationDidEndExeBlock = _rotationDidEndExeBlock;
- (instancetype)initWithMgr:(id<SJRotationManagerProtocol>)mgr {
    self = [super init];
    if ( !self )
        return nil;
    [(id)mgr sj_addObserver:self forKeyPath:@"transitioning"];
    return self;
}

- (void)observeValueForKeyPath:(NSString *_Nullable)keyPath ofObject:(id _Nullable)object change:(NSDictionary<NSKeyValueChangeKey,id> * _Nullable)change context:(void * _Nullable)context {
    if ( [change[NSKeyValueChangeOldKey] boolValue] == [change[NSKeyValueChangeNewKey] boolValue] )
        return;
    
    id<SJRotationManagerProtocol> mgr = object;
    if ( mgr.isTransitioning ) {
        if ( _rotationDidStartExeBlock )
            _rotationDidStartExeBlock(mgr);
    }
    else {
        if ( _rotationDidEndExeBlock )
            _rotationDidEndExeBlock(mgr);
    }
}
@end

@interface SJVCRotationManager()
@property (nonatomic, weak, readonly, nullable) UIViewController *atViewController;
@property (nonatomic, getter=isTransitioning) BOOL transitioning;
@property (nonatomic) UIDeviceOrientation rec_deviceOrientation;
@property (nonatomic) SJOrientation currentOrientation;
@property (nonatomic) BOOL needToForceRotation;

@property (nonatomic, copy, nullable) void(^rotateCompletionHandler)(id<SJRotationManagerProtocol> mgr);
@end

@implementation SJVCRotationManager
@synthesize autorotationSupportedOrientation = _autorotationSupportedOrientation;
@synthesize disableAutorotation = _disableAutorotation;
@synthesize shouldTriggerRotation = _shouldTriggerRotation;
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

- (id<SJRotationManagerObserver>)getObserver {
    return [[SJVCRotationManagerObserver alloc] initWithMgr:self];
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
        if ( self.isTransitioning ) return;
        if ( !self.superview ) return;
        if ( !self.target ) return;
        if ( self.shouldTriggerRotation ) { if ( !self.shouldTriggerRotation(self) ) return; }
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
    [self _refreshDeviceOrientation];
    _currentOrientation = _sjOrientationForDeviceOrentation(_rec_deviceOrientation);
    self.transitioning = YES;
    BOOL isFull = self.isFullscreen;

    [self.target mas_remakeConstraints:^(MASConstraintMaker *make) {
        if ( isFull ) make.edges.equalTo(self->_atViewController.view);
        else make.edges.equalTo(self.superview);
    }];
    __weak typeof(self) _self = self;
    [UIView animateWithDuration:coordinator.transitionDuration animations:^{
        [self.target layoutIfNeeded];
    } completion:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( isFull ) [self.atViewController.view addSubview:self.target];
        else [self.superview addSubview:self.target];
        self.transitioning = NO;
        if ( self.rotateCompletionHandler ) self.rotateCompletionHandler(self);
        self.rotateCompletionHandler = nil;
    }];
}

- (BOOL)vc_shouldAutorotate {
    [self _refreshDeviceOrientation];
    if ( self.shouldTriggerRotation && !self.shouldTriggerRotation(self) )
        return NO;
    
    if ( self.needToForceRotation )
        return YES;
    
    if ( [self _isSupported:_sjOrientationForDeviceOrentation(_rec_deviceOrientation)] )
        return !self.disableAutorotation;
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
