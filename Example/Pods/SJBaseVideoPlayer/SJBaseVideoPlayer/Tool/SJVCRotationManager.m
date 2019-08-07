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
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJVCRotationManagerObserver : NSObject<SJRotationManagerObserver>
@property (nonatomic, copy, nullable) void(^rotationDidStartExeBlock)(id<SJRotationManagerProtocol> mgr);
@property (nonatomic, copy, nullable) void(^rotationDidEndExeBlock)(id<SJRotationManagerProtocol> mgr);
@end

@implementation SJVCRotationManagerObserver
- (instancetype)initWithMgr:(id<SJRotationManagerProtocol>)mgr {
    self = [super init];
    if ( self ) {
        [(id)mgr sj_addObserver:self forKeyPath:@"transitioning"];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *_Nullable)keyPath ofObject:(id _Nullable)object change:(NSDictionary<NSKeyValueChangeKey,id> * _Nullable)change context:(void * _Nullable)context {
    if ( [change[NSKeyValueChangeOldKey] boolValue] == [change[NSKeyValueChangeNewKey] boolValue] )
        return;

    id<SJRotationManagerProtocol> mgr = object;
    if ( mgr.isTransitioning ) {
        !_rotationDidStartExeBlock?:_rotationDidStartExeBlock(mgr);
    }
    else {
        !_rotationDidEndExeBlock?:_rotationDidEndExeBlock(mgr);
    }
}
@end

@interface SJVCRotationManager()
@property (nonatomic, getter=isTransitioning) BOOL transitioning;
@end

@implementation SJVCRotationManager {
    __weak UIViewController *_Nullable _atViewController;
    __weak UIView *_Nullable _fullscreenToView;
    void(^_Nullable _rotateCompletionHandler)(id<SJRotationManagerProtocol> mgr);
    UIView *_containerView;
    UIDeviceOrientation _deviceOrientation;
    CGRect _smlFrame;
    SJOrientation _currentOrientation;
    BOOL _needToForceRotation;
}

@synthesize autorotationSupportedOrientation = _autorotationSupportedOrientation;
@synthesize disableAutorotation = _disableAutorotation;
@synthesize shouldTriggerRotation = _shouldTriggerRotation;
@synthesize superview = _superview;
@synthesize target = _target; 

- (instancetype)initWithViewController:(__weak UIViewController *)atViewController {
    return [self initWithViewController:atViewController fullscreenToView:nil];
}

- (instancetype)initWithViewController:(UIViewController * _Nonnull __weak)atViewController fullscreenToView:(nullable UIView *)fullscreenToView {
    self = [super init];
    if ( !self ) return nil;
    _fullscreenToView = fullscreenToView;
    _atViewController = atViewController;
    _currentOrientation = SJOrientation_Portrait;
    _deviceOrientation = UIDeviceOrientationPortrait;
    _autorotationSupportedOrientation = SJAutoRotateSupportedOrientation_All;
    _containerView = [[UIView alloc] initWithFrame:CGRectZero];
    _containerView.hidden = YES;
    UIWindow *window = [(id)[UIApplication sharedApplication].delegate valueForKey:@"window"];
    [window addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    [UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_refreshDeviceOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (id<SJRotationManagerObserver>)getObserver {
    return [[SJVCRotationManagerObserver alloc] initWithMgr:self];
}

- (SJOrientation)currentOrientation {
    return _currentOrientation;
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
        SJOrientation orientation = _sjOrientationForDeviceOrentation(_deviceOrientation);
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( self.isTransitioning ) return;
        if ( self.shouldTriggerRotation ) { if ( !self.shouldTriggerRotation(self) ) return; }
        if ( orientation == self->_currentOrientation ) { if (completionHandler) completionHandler(self); return; }
        self->_needToForceRotation = YES;
        self->_rotateCompletionHandler = ^(id<SJRotationManagerProtocol>  _Nonnull mgr) {
            if ( completionHandler ) completionHandler(mgr);
        };
        [UIDevice.currentDevice setValue:@(_deviceOrentationForSJOrientation(orientation)) forKey:@"orientation"];
        [UIViewController attemptRotationToDeviceOrientation];
    });
}

- (void)vc_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    UIWindow *_Nullable window = _atViewController.view.window;
    if ( window != nil ) {
        _containerView.hidden = NO;
        BOOL isFullscreen = size.width > size.height;
        CGRect bounds = window.frame;
        CGFloat max = MAX(bounds.size.width, bounds.size.height);
        CGFloat min = MIN(bounds.size.width, bounds.size.height);
        CGRect fullscreenRect = CGRectMake(0, 0, max, min);
        if ( isFullscreen && _currentOrientation == SJOrientation_Portrait ) {
            _smlFrame = [_superview convertRect:_target.frame toView:window];
            _target.frame = _smlFrame;
        }
        else {
            _target.frame = fullscreenRect;
        }
        [_containerView addSubview:_target];
        
        [self _refreshDeviceOrientation];
        [self _updateCurrentOrientation];
        
        self.transitioning = YES;
        [UIView animateWithDuration:coordinator.transitionDuration animations:^{
            self.target.frame = isFullscreen?fullscreenRect:self->_smlFrame;
            [self.target layoutIfNeeded];
        } completion:^(BOOL finished) {
            UIView *superview = nil;
            if ( isFullscreen )
                superview = self->_fullscreenToView?:window.rootViewController.view;
            else
                superview = self->_superview;
            [superview addSubview:self.target];
            self.transitioning = NO;
            self->_containerView.hidden = YES;
            self->_needToForceRotation = NO;
            if ( self->_rotateCompletionHandler )
                self->_rotateCompletionHandler(self);
            self->_rotateCompletionHandler = nil;
        }];
    }
}

- (BOOL)vc_shouldAutorotate {
    if ( _atViewController.presentedViewController != nil )
        return NO;
    
    [self _refreshDeviceOrientation];
    if ( self.shouldTriggerRotation && !self.shouldTriggerRotation(self) )
        return NO;
    
    if ( _needToForceRotation )
        return YES;
    
    if ( [self _isSupported:_sjOrientationForDeviceOrentation(_deviceOrientation)] )
        return !self.disableAutorotation;
    return NO;
}

- (UIInterfaceOrientationMask)vc_supportedInterfaceOrientations {
    if ( _atViewController.presentedViewController != nil ) {
        switch ( _currentOrientation ) {
            case SJOrientation_Portrait:
                return UIInterfaceOrientationMaskPortrait;
            case SJOrientation_LandscapeRight:
                return UIInterfaceOrientationMaskLandscapeLeft;
            case SJOrientation_LandscapeLeft:
                return UIInterfaceOrientationMaskLandscapeRight;
            default: break;
        }
    }

    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)vc_preferredInterfaceOrientationForPresentation {
    if ( _atViewController.presentedViewController != nil ) {
        switch ( _currentOrientation ) {
            case SJOrientation_Portrait:
                return UIInterfaceOrientationPortrait;
            case SJOrientation_LandscapeLeft:
                return UIInterfaceOrientationLandscapeRight;
            case SJOrientation_LandscapeRight:
                return UIInterfaceOrientationLandscapeLeft;
        }
    }
    
    return UIInterfaceOrientationPortrait;
}

#pragma mark -

- (void)_refreshDeviceOrientation {
    UIDeviceOrientation dev_orientation = [UIDevice currentDevice].orientation;
    switch ( dev_orientation ) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            _deviceOrientation = dev_orientation;
        }
            break;
        default:    break;
    }
}

- (void)_updateCurrentOrientation {
    _currentOrientation = _sjOrientationForDeviceOrentation(_deviceOrientation);
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
