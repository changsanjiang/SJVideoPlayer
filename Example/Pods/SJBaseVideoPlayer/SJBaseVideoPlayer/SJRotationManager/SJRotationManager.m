//
//  SJRotationManager.m
//  SJOrentationObserverProject
//
//  Created by 畅三江 on 2018/6/25.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJRotationManager.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJRotationManagerObserver : NSObject<SJRotationManagerObserver>
- (instancetype)initWithMgr:(id<SJRotationManagerProtocol>)mgr;
@end

@implementation SJRotationManagerObserver
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


@interface SJRotationManager()
@property (nonatomic, strong, readonly) UIView *blackView;
@property (nonatomic) SJOrientation currentOrientation;
@property (nonatomic, getter=isTransitioning) BOOL transitioning;
@property (nonatomic) UIDeviceOrientation rec_deviceOrientation;
@end

@implementation SJRotationManager
@synthesize autorotationSupportedOrientation = _autorotationSupportedOrientation;
@synthesize disableAutorotation = _disableAutorotation;
@synthesize shouldTriggerRotation = _shouldTriggerRotation;
@synthesize duration = _duration;
@synthesize superview = _superview;
@synthesize target = _target;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _duration = 0.4;
    _currentOrientation = SJOrientation_Portrait;
    _rec_deviceOrientation = UIDeviceOrientationPortrait;
    _autorotationSupportedOrientation = SJAutoRotateSupportedOrientation_All;
    [self _observeNotifies];
    return self;
}

- (id<SJRotationManagerObserver>)getObserver {
    return [[SJRotationManagerObserver alloc] initWithMgr:self];
}

@synthesize blackView = _blackView;
- (UIView *)blackView {
    if ( _blackView ) return _blackView;
    _blackView = [UIView new];
    _blackView.backgroundColor = [UIColor blackColor];
    return _blackView;
}

- (void)dealloc {
    [_blackView removeFromSuperview];
}

- (BOOL)isFullscreen {
    return _currentOrientation == SJOrientation_LandscapeLeft || _currentOrientation == SJOrientation_LandscapeRight;
}

- (void)_observeNotifies {
    if ( !UIDevice.currentDevice.isGeneratingDeviceOrientationNotifications ) {
         [UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];
    }
    [self sj_observeWithNotification:UIDeviceOrientationDidChangeNotification target:nil usingBlock:^(SJRotationManager *_Nonnull self, NSNotification * _Nonnull note) {
        [self deviceOrientationDidChangeNotify];
    }];
}

- (void)deviceOrientationDidChangeNotify {
    UIDeviceOrientation dev_orientation = [UIDevice currentDevice].orientation;

    switch ( dev_orientation ) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            _rec_deviceOrientation = dev_orientation;
        
            if ( self.disableAutorotation ) {
#ifdef DEBUG
                NSLog(@"%d - %s - SJRotationManager - 自动旋转被禁止, 暂时无法旋转!", (int)__LINE__, __func__);
#endif
                return;
            }
        }
            break;
        default:    break;
    }
    
    switch ( dev_orientation ) {
        case UIDeviceOrientationPortrait: {
            if ( [self _isSupported:SJOrientation_Portrait] ) {
                 [self rotate:SJOrientation_Portrait animated:YES];
            }
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            if ( [self _isSupported:SJOrientation_LandscapeLeft] ) {
                 [self rotate:SJOrientation_LandscapeLeft animated:YES];
            }
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            if ( [self _isSupported:SJOrientation_LandscapeRight] ) {
                 [self rotate:SJOrientation_LandscapeRight animated:YES];
            }
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

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void (^)(id<SJRotationManagerProtocol> _Nonnull))completionHandler {
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.transitioning ) return;
        if ( !self.superview ) return;
        if ( !self.target ) return;
        if ( self.shouldTriggerRotation && !self.shouldTriggerRotation(self) ) return;
        SJOrientation ori_old = self.currentOrientation;
        SJOrientation ori_new = orientation;
        if ( ori_old == ori_new ) { if ( completionHandler ) completionHandler(self); return; }
        UIWindow *window = [(id)[UIApplication sharedApplication].delegate valueForKey:@"window"];
        if ( !window ) return;
        CGAffineTransform transform = CGAffineTransformIdentity;
        UIInterfaceOrientation statusBarOrientation = UIInterfaceOrientationUnknown;
        switch ( ori_new ) {
            case SJOrientation_Portrait: {
                statusBarOrientation = UIInterfaceOrientationPortrait;
                if ( self.blackView.superview != nil ) { [self.blackView removeFromSuperview]; }
            }
                break;
            case SJOrientation_LandscapeLeft: {
                statusBarOrientation = UIInterfaceOrientationLandscapeRight;
                transform = CGAffineTransformMakeRotation(M_PI_2);
            }
                break;
            case SJOrientation_LandscapeRight: {
                statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
                transform = CGAffineTransformMakeRotation(-M_PI_2);

            }
                break;
        }
        
        // update
        CGRect portraitRect = [window convertRect:self.superview.bounds fromView:self.superview];

        if ( ori_old == SJOrientation_Portrait ) {
            self.target.translatesAutoresizingMaskIntoConstraints = YES;
            self.target.frame = portraitRect;
            [window addSubview:self.target];
        }

        // update
        self.currentOrientation = ori_new;
        self.transitioning = true;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarOrientation:statusBarOrientation animated:NO];
#pragma clang diagnostic pop
        
        [UIView animateWithDuration:animated ? self.duration : 0 animations:^{
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( ori_new == SJOrientation_Portrait ) {
                self.target.transform = transform;
                self.target.bounds = (CGRect){CGPointZero, portraitRect.size};
                self.target.center =
                (CGPoint){portraitRect.origin.x +
                          portraitRect.size.width * 0.5,
                          portraitRect.origin.y +
                          portraitRect.size.height * 0.5};
                [self.target layoutIfNeeded];
            }
            else {
                CGFloat width  = window.bounds.size.width;
                CGFloat height = window.bounds.size.height;
                CGFloat max = MAX(width, height);
                CGFloat min = MIN(width, height);
                self.target.bounds = (CGRect){CGPointZero, (CGSize){max, min}};
                self.target.center = (CGPoint){min * 0.5, max * 0.5};
                [self.target layoutIfNeeded];
                self.target.transform = transform;
            }
        } completion:^(BOOL finished) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( self.currentOrientation == SJOrientation_Portrait ) {
                [self.superview addSubview:self.target];
                self.target.frame = self.superview.bounds;
            }
            else {
                self.blackView.bounds = self.target.bounds;
                self.blackView.center = self.target.center;
                self.blackView.transform = self.target.transform;
                [window insertSubview:self.blackView belowSubview:self.target];
            }
            self.transitioning = false;
            if ( completionHandler ) completionHandler(self);
        }];
    });
}
@end

@implementation UITabBarController (SJBaseVideoPlayerAdded)
- (UIViewController *)sj_topViewController {
    if ( self.selectedIndex == NSNotFound )
        return self.viewControllers.firstObject;
    return self.selectedViewController;
}

- (BOOL)shouldAutorotate {
    return [[self sj_topViewController] shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [[self sj_topViewController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self sj_topViewController] preferredInterfaceOrientationForPresentation];
}
@end

@implementation UINavigationController (SJBaseVideoPlayerAdded)
- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}
@end
NS_ASSUME_NONNULL_END
