//
//  SJRotationManager.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/7/13.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJRotationManager.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

@class SJFullscreenModeViewController;

NS_ASSUME_NONNULL_BEGIN
@protocol SJFullscreenModeViewControllerDelegate <NSObject>
- (UIView *)target;
- (CGRect)targetOriginFrame;
- (BOOL)prefersStatusBarHidden;
- (UIStatusBarStyle)preferredStatusBarStyle;

- (BOOL)shouldAutorotateToOrientation:(UIDeviceOrientation)orientation;
- (void)fullscreenModeViewController:(SJFullscreenModeViewController *)vc willRotateToOrientation:(UIDeviceOrientation)orientation;
- (void)fullscreenModeViewController:(SJFullscreenModeViewController *)vc didRotateFromOrientation:(UIDeviceOrientation)orientation;
@end

@interface SJFullscreenModeViewController : UIViewController
@property (nonatomic, weak, nullable) id<SJFullscreenModeViewControllerDelegate> delegate;
@property (nonatomic) UIDeviceOrientation currentOrientation;
@property (nonatomic, readonly) BOOL isFullscreen;
@property (nonatomic) BOOL isTransitioning;
@end

@implementation SJFullscreenModeViewController
- (instancetype)init {
    self = [super init];
    if ( self ) {
        _currentOrientation = UIDeviceOrientationPortrait;
    }
    return self;
}

- (BOOL)shouldAutorotate {
    return [self.delegate shouldAutorotateToOrientation:UIDevice.currentDevice.orientation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    self.isTransitioning = YES;
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    UIDeviceOrientation new = UIDevice.currentDevice.orientation;
    UIDeviceOrientation old = _currentOrientation;
    
    if ( new == UIDeviceOrientationLandscapeLeft ||
         new == UIDeviceOrientationLandscapeRight ) {
        if ( self.delegate.target.superview != self.view ) {
            [self.view addSubview:self.delegate.target];
        }
    }
    
    if ( old == UIDeviceOrientationPortrait ) {
        self.delegate.target.frame = self.delegate.targetOriginFrame;
    }
    
    _currentOrientation = new;

    [self.delegate fullscreenModeViewController:self willRotateToOrientation:_currentOrientation];
    
    BOOL isFullscreen = size.width > size.height;
    [UIView animateWithDuration:0.3 animations:^{
        if ( isFullscreen )
            self.delegate.target.frame = CGRectMake(0, 0, size.width, size.height);
        else
            self.delegate.target.frame = self.delegate.targetOriginFrame;
        
        [self.delegate.target layoutIfNeeded];
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isTransitioning = NO;
            [self.delegate fullscreenModeViewController:self didRotateFromOrientation:self.currentOrientation];
        });
    }];
}

- (BOOL)isFullscreen {
    return _currentOrientation == UIDeviceOrientationLandscapeLeft || _currentOrientation == UIDeviceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden {
    return self.delegate.prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.delegate.preferredStatusBarStyle;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
@end


@interface SJFullscreenModeWindow : UIWindow
@property (nonatomic, strong, nullable) SJFullscreenModeViewController *rootViewController;
@end

@implementation SJFullscreenModeWindow
@dynamic rootViewController;

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
}
#endif

- (void)setBackgroundColor:(nullable UIColor *)backgroundColor {}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
//    self.windowLevel = UIWindowLevelStatusBar - 1;
    self.hidden = YES;
    self.rootViewController = SJFullscreenModeViewController.new;;
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *_Nullable)event {
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    static CGRect bounds;
    
    // 如果是大屏转大屏 就不需要修改了
    
    if ( !CGRectEqualToRect(bounds, self.bounds) ) {
        [UIView performWithoutAnimation:^{
            for ( UIView *view in self.subviews ) {
                if ( view != self.rootViewController.view ) {
                    view.backgroundColor = UIColor.clearColor;
                    for ( UIView *subview in view.subviews ) {
                        subview.backgroundColor = UIColor.clearColor;
                    }
                }
                
            }
        }];
    }
    
    bounds = self.bounds;
}
@end



@interface SJRotationManagerObserver : NSObject<SJRotationManagerObserver>
- (instancetype)initWithRotationManager:(SJRotationManager *)mgr;
@end


@interface SJRotationManager ()<SJFullscreenModeViewControllerDelegate>
@property (nonatomic, strong) SJFullscreenModeWindow *window;
@property (nonatomic) UIDeviceOrientation deviceOrientation;
@property (nonatomic) BOOL forcedRotation;
@end

@implementation SJRotationManager {
    void(^_Nullable _completionHandler)(id<SJRotationManagerProtocol> mgr);
}

@synthesize autorotationSupportedOrientation = _autorotationSupportedOrientation;
@synthesize shouldTriggerRotation = _shouldTriggerRotation;
@synthesize disableAutorotation = _disableAutorotation;
@synthesize superview = _superview;
@synthesize target = _target;

- (instancetype)init {
    self = [super init];
    if (self) {
        _autorotationSupportedOrientation = SJAutoRotateSupportedOrientation_All;
        _window = [SJFullscreenModeWindow new];
        _window.rootViewController.delegate = self;
        [_window.rootViewController loadViewIfNeeded];
        [self _observeDeviceOrientationChangeNotification];
    }
    return self;
}

- (void)_observeDeviceOrientationChangeNotification {
    UIDevice *device = UIDevice.currentDevice;
    if ( !device.isGeneratingDeviceOrientationNotifications ) {
        [device beginGeneratingDeviceOrientationNotifications];
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:device];
}

- (void)deviceOrientationDidChange:(NSNotification *)note {
    UIDeviceOrientation orientation = UIDevice.currentDevice.orientation;
    switch ( orientation ) {
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            _deviceOrientation = orientation;
        }
            break;
        default: break;
    }
}

#pragma mark -

- (SJOrientation)currentOrientation {
    return (NSInteger)self.window.rootViewController.currentOrientation;
}

- (BOOL)isTransitioning {
    return self.window.rootViewController.isTransitioning;
}

- (BOOL)isFullscreen {
    return self.window.rootViewController.isFullscreen;
}

- (id<SJRotationManagerObserver>)getObserver {
    return [[SJRotationManagerObserver alloc] initWithRotationManager:self];
}

- (void)rotate {
    if ( ![self _isSupported:SJOrientation_LandscapeLeft] &&
         ![self _isSupported:SJOrientation_LandscapeRight] ) {
        if ( self.isFullscreen )
            [self rotate:SJOrientation_Portrait animated:YES];
        else
            [self rotate:SJOrientation_LandscapeLeft animated:YES];
        return;
    }
    
    if ( self.isFullscreen && [self _isSupported:SJOrientation_Portrait] ) {
        [self rotate:SJOrientation_Portrait animated:YES];
        return;
    }
    
    
    if ( [self _isSupported:SJOrientation_LandscapeLeft] &&
         [self _isSupported:SJOrientation_LandscapeRight] ) {
        SJOrientation orientation = (NSInteger)_deviceOrientation;
        if ( _window.rootViewController.currentOrientation == SJOrientation_Portrait )
            orientation = SJOrientation_LandscapeLeft;
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
    _forcedRotation = YES;
    _completionHandler = completionHandler;
    [UIDevice.currentDevice setValue:@(UIDeviceOrientationUnknown) forKey:@"orientation"];
    [UIDevice.currentDevice setValue:@(orientation) forKey:@"orientation"];
    _forcedRotation = NO;
}

#pragma mark -

- (CGRect)targetOriginFrame {
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    return [self.superview convertRect:self.superview.bounds toView:window];
}

- (BOOL)prefersStatusBarHidden {
    return self.delegate.vc_prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.delegate.vc_preferredStatusBarStyle;
}

- (BOOL)shouldAutorotateToOrientation:(UIDeviceOrientation)orientation {
    if ( _disableAutorotation && !_forcedRotation )
        return NO;
    
    if ( _window.rootViewController.isTransitioning )
        return NO;
    
    if ( !_forcedRotation ) {
        if ( ![self _isSupported:(NSInteger)orientation] )
            return NO;
    }
    
    if ( _shouldTriggerRotation && !_shouldTriggerRotation(self) )
        return NO;
    
    if ( orientation == UIDeviceOrientationLandscapeLeft ||
         orientation == UIDeviceOrientationLandscapeRight ) {
        self.window.hidden = NO;
    }
    
    return YES;
}

- (void)fullscreenModeViewController:(SJFullscreenModeViewController *)vc willRotateToOrientation:(UIDeviceOrientation)orientation { }

- (void)fullscreenModeViewController:(SJFullscreenModeViewController *)vc didRotateFromOrientation:(UIDeviceOrientation)orientation {
    if ( !vc.isFullscreen ) {
        [self.superview addSubview:self.target];
        [UIView animateWithDuration:0 animations:^{
            self.window.alpha = 0.001;
        } completion:^(BOOL finished) {
            self.window.hidden = YES;
            self.window.alpha = 1;
        }];
    }
    
    if ( _completionHandler )
        _completionHandler(self);
    
    _completionHandler = nil;
}

- (BOOL)_isSupported:(SJOrientation)orientation {
    switch ( orientation ) {
        case SJOrientation_Portrait:
            return _autorotationSupportedOrientation & SJAutoRotateSupportedOrientation_Portrait;
        case SJOrientation_PortraitUpsideDown:
            return _autorotationSupportedOrientation & SJAutoRotateSupportedOrientation_PortraitUpsideDown;
        case SJOrientation_LandscapeLeft:
            return _autorotationSupportedOrientation & SJAutoRotateSupportedOrientation_LandscapeLeft;
        case SJOrientation_LandscapeRight:
            return _autorotationSupportedOrientation & SJAutoRotateSupportedOrientation_LandscapeRight;
    }
    return NO;
}
@end



@implementation SJRotationManagerObserver {
    __weak SJRotationManager *_Nullable _mgr;
}
@synthesize rotationDidStartExeBlock = _rotationDidStartExeBlock;
@synthesize rotationDidEndExeBlock = _rotationDidEndExeBlock;

- (instancetype)initWithRotationManager:(SJRotationManager *)mgr {
    self = [super init];
    if ( !self )
        return nil;
    _mgr = mgr;
    [mgr.window.rootViewController sj_addObserver:self forKeyPath:@"isTransitioning"];
    return self;
}

- (void)observeValueForKeyPath:(NSString *_Nullable)keyPath ofObject:(id _Nullable)object change:(NSDictionary<NSKeyValueChangeKey,id> * _Nullable)change context:(void * _Nullable)context {
    if ( [change[NSKeyValueChangeOldKey] boolValue] == [change[NSKeyValueChangeNewKey] boolValue] )
        return;
    
    if ( _mgr.isTransitioning ) {
        if ( _rotationDidStartExeBlock )
            _rotationDidStartExeBlock(_mgr);
    }
    else {
        if ( _rotationDidEndExeBlock )
            _rotationDidEndExeBlock(_mgr);
    }
}
@end
NS_ASSUME_NONNULL_END
