//
//  SJRotationManager.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/7/13.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJRotationManager.h"
#import "SJTimerControl.h"
#import "UIView+SJBaseVideoPlayerExtended.h"

#if __has_include(<SJUIKit/SJRunLoopTaskQueue.h>)
#import <SJUIKit/SJRunLoopTaskQueue.h>
#else
#import "SJRunLoopTaskQueue.h"
#endif


@class SJFullscreenModeViewController, SJFullscreenModeNavigationController;

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
@property (nonatomic, readonly, getter=isRotating) BOOL rotating;
@property (nonatomic) BOOL disableAnimations;
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
    if ( self.presentedViewController != nil )
        return 1 << _currentOrientation;
    return UIInterfaceOrientationMaskAll;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationPortrait;
//}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    _rotating = YES;
    
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
    
    if ( self.disableAnimations ) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
    }
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        if ( isFullscreen )
            self.delegate.target.frame = CGRectMake(0, 0, size.width, size.height);
        else
            self.delegate.target.frame = self.delegate.targetOriginFrame;
        
        [self.delegate.target layoutIfNeeded];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        if ( self.disableAnimations )
            [CATransaction commit];
        self->_rotating = NO;
        [self.delegate fullscreenModeViewController:self didRotateFromOrientation:self.currentOrientation];
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

- (void)setNeedsStatusBarAppearanceUpdate {
    [super setNeedsStatusBarAppearanceUpdate];
}
@end


@protocol SJFullscreenModeNavigationControllerDelegate <NSObject>
- (void)vc_forwardPushViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end

@interface SJFullscreenModeNavigationController : UINavigationController
@property (nonatomic, weak, nullable) id<SJFullscreenModeNavigationControllerDelegate> sj_delegate;
@end

@implementation SJFullscreenModeNavigationController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    [super setNavigationBarHidden:YES];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [super setNavigationBarHidden:YES animated:animated];
}

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
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ( [viewController isKindOfClass:SJFullscreenModeViewController.class] ) {
        [super pushViewController:viewController animated:animated];
    }
    else if ( [self.sj_delegate respondsToSelector:@selector(vc_forwardPushViewController:animated:)] ) {
        [self.sj_delegate vc_forwardPushViewController:viewController animated:animated];
    }
}
@end

#pragma mark -

@interface SJFullscreenModeWindow : UIWindow
@property (nonatomic, strong, nullable) SJFullscreenModeNavigationController *rootViewController;
@property (nonatomic, strong, readonly) SJFullscreenModeViewController *fullscreenModeViewController;
@end

@implementation SJFullscreenModeWindow
@dynamic rootViewController;

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
}
#endif

- (void)setBackgroundColor:(nullable UIColor *)backgroundColor {}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    self.windowLevel = UIWindowLevelNormal;
    _fullscreenModeViewController = SJFullscreenModeViewController.new;
    self.rootViewController = [[SJFullscreenModeNavigationController alloc] initWithRootViewController:_fullscreenModeViewController];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    if ( @available(iOS 13.0, *) ) {
        if ( self.windowScene == nil )
            self.windowScene = UIApplication.sharedApplication.keyWindow.windowScene;
    }
#endif
    self.hidden = YES;
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
        
        UIView *superview = self;
        if ( @available(iOS 13.0, *) ) {
            superview = self.subviews.firstObject;
        }

        [UIView performWithoutAnimation:^{
            for ( UIView *view in superview.subviews ) {
                if ( view != self.rootViewController.view && [view isMemberOfClass:UIView.class] ) {
                    view.backgroundColor = UIColor.clearColor;
                    for ( UIView *subview in view.subviews ) {
                        subview.backgroundColor = UIColor.clearColor;
                    }
                }
                
            }
        }];
    }
    
    bounds = self.bounds;
    self.rootViewController.view.frame = bounds;
}
@end



static NSNotificationName const SJRotationManagerTransitioningValueDidChangeNotification = @"SJRotationManagerTransitioningValueDidChangeNotification";

@interface SJRotationManagerObserver : NSObject<SJRotationManagerObserver>
- (instancetype)initWithRotationManager:(SJRotationManager *)mgr;
@end

@interface SJRotationManager ()<SJFullscreenModeViewControllerDelegate, SJFullscreenModeNavigationControllerDelegate>
@property (nonatomic, strong, readonly) SJFullscreenModeWindow *window;
@property (nonatomic, weak, nullable) UIWindow *previousKeyWindow;

@property (nonatomic, getter=isForcedRotation) BOOL forcedRotation;
@property (nonatomic, getter=isTransitioning) BOOL transitioning;
@property (nonatomic) UIDeviceOrientation deviceOrientation;
@property (nonatomic) SJOrientation currentOrientation;

///
/// 默认为活跃状态
///
///     进入后台时, 将设置状态为不活跃状态, 此时将不会触发自动旋转
///     进入前台时, 两秒后将恢复为活跃状态, 两秒之后才能开始响应自动旋转
///
///     主动调用旋转时, 将直接激活为活跃状态
///
@property (nonatomic, getter=isInactivated) BOOL inactivated;
@property (nonatomic, strong, readonly) SJTimerControl *timerControl;
@end

@implementation SJRotationManager {
    void(^_Nullable _completionHandler)(id<SJRotationManager> mgr);
}

@synthesize autorotationSupportedOrientations = _autorotationSupportedOrientations;
@synthesize shouldTriggerRotation = _shouldTriggerRotation;
@synthesize disabledAutorotation = _disabledAutorotation;
@synthesize superview = _superview;
@synthesize target = _target;

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentOrientation = SJOrientation_Portrait;
        _autorotationSupportedOrientations = SJOrientationMaskAll;
        [self _observeNotifies];
        [self performSelectorOnMainThread:@selector(_setupWindow) withObject:nil waitUntilDone:NO];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)_setupWindow {
    self->_window = [SJFullscreenModeWindow new];
    self->_window.fullscreenModeViewController.delegate = self;
    self->_window.rootViewController.sj_delegate = self;
    self->_window.frame = UIScreen.mainScreen.bounds;
    if ( @available(iOS 9.0, *) ) {
        [self->_window.rootViewController loadViewIfNeeded];
    }
    else {
        [self->_window.rootViewController loadView];
        [self->_window.rootViewController viewDidLoad];
    }
}

- (void)_observeNotifies {
    UIDevice *device = UIDevice.currentDevice;
    if ( !device.isGeneratingDeviceOrientationNotifications ) {
        [device beginGeneratingDeviceOrientationNotifications];
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:device];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
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

- (void)willResignActive {
    [self.timerControl clear];
    _inactivated = YES;
}

- (void)didBecomeActive {
    [self.timerControl start];
}

#pragma mark -

- (BOOL)isFullscreen {
    return _currentOrientation == (NSInteger)UIDeviceOrientationLandscapeLeft ||
           _currentOrientation == (NSInteger)UIDeviceOrientationLandscapeRight;
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
        if ( self.window.fullscreenModeViewController.currentOrientation == SJOrientation_Portrait )
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

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void(^)(id<SJRotationManager> mgr))completionHandler {
    _completionHandler = completionHandler;
    if ( orientation == (NSInteger)self.window.fullscreenModeViewController.currentOrientation ) {
        [self _finishTransition];
        return;
    }
    
    _inactivated = NO;
    _forcedRotation = YES;
    _window.fullscreenModeViewController.disableAnimations = !animated;
    [UIDevice.currentDevice setValue:@(UIDeviceOrientationUnknown) forKey:@"orientation"];
    [UIDevice.currentDevice setValue:@(orientation) forKey:@"orientation"];
}

#pragma mark -

- (CGRect)targetOriginFrame {
    if ( self.superview.window == nil )
        return CGRectZero;
    return [self.superview convertRect:self.superview.bounds toView:self.superview.window];
}

- (BOOL)prefersStatusBarHidden {
    return self.delegate.prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.delegate.preferredStatusBarStyle;
}

- (void)vc_forwardPushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.delegate pushViewController:viewController animated:animated];
}

#pragma mark -

- (BOOL)shouldAutorotateToOrientation:(UIDeviceOrientation)orientation {
    if ( _inactivated )
        return NO;
    
    if ( orientation == (NSInteger)_window.fullscreenModeViewController.currentOrientation )
        return NO;
    
    if ( self.isDisabledAutorotation && !_forcedRotation )
        return NO;
    
    if ( self.isTransitioning && _window.fullscreenModeViewController.isRotating )
        return NO;
    
    if ( !_forcedRotation ) {
        if ( ![self _isSupported:(NSInteger)orientation] )
            return NO;
    }
    
    if ( _shouldTriggerRotation && !_shouldTriggerRotation(self) )
        return NO;
    
    self.currentOrientation = (NSInteger)orientation;
    
    if ( self.isTransitioning == NO )
        [self _beginTransition];
    
    if ( orientation == UIDeviceOrientationLandscapeLeft ||
         orientation == UIDeviceOrientationLandscapeRight ) {
        UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
        if ( keyWindow != self.window && self.previousKeyWindow != keyWindow ) {
            self.previousKeyWindow = UIApplication.sharedApplication.keyWindow;
        }
        if ( self.window.isKeyWindow == NO )
            [self.window makeKeyAndVisible];
    }
    return YES;
}

- (void)fullscreenModeViewController:(SJFullscreenModeViewController *)vc willRotateToOrientation:(UIDeviceOrientation)orientation {
    if ( orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown ) {
        [self performSelector:@selector(_fixNavigationBarLayout) onThread:NSThread.mainThread withObject:@(NO) waitUntilDone:NO];
    }
}

- (void)_fixNavigationBarLayout {
    UINavigationController *nav = [self.superview lookupResponderForClass:UINavigationController.class];
    [nav viewDidAppear:NO];
    [nav.navigationBar layoutSubviews];
}

- (void)fullscreenModeViewController:(SJFullscreenModeViewController *)vc didRotateFromOrientation:(UIDeviceOrientation)orientation {
    if ( !vc.isFullscreen ) {
        UIView *snapshot = [self.target snapshotViewAfterScreenUpdates:NO];
        snapshot.frame = self.superview.bounds;
        [self.superview addSubview:snapshot];
        SJRunLoopTaskQueue.main.enqueue(^{
            [self.superview addSubview:self.target];
        }).enqueue(^{
            [snapshot removeFromSuperview];
            UIWindow *previousKeyWindow = self.previousKeyWindow ?: UIApplication.sharedApplication.windows.firstObject;
            [previousKeyWindow makeKeyAndVisible];
            self.previousKeyWindow = nil;
            self.window.hidden = YES;
            [self _finishTransition];
        });
    }
    else {
        [self _finishTransition];
    }
    
}

- (void)_beginTransition {
    self.transitioning = YES;
    if ( !_forcedRotation ) _window.fullscreenModeViewController.disableAnimations = NO; // 自动旋转时, 默认触发动画
}

- (void)_finishTransition {
    self.forcedRotation = NO;
    self.transitioning = NO;
    
    if ( _completionHandler )
        _completionHandler(self);
    
    _completionHandler = nil;
}

- (BOOL)_isSupported:(SJOrientation)orientation {
    switch ( orientation ) {
        case SJOrientation_Portrait:
            return _autorotationSupportedOrientations & SJOrientationMaskPortrait;
        case SJOrientation_LandscapeLeft:
            return _autorotationSupportedOrientations & SJOrientationMaskLandscapeLeft;
        case SJOrientation_LandscapeRight:
            return _autorotationSupportedOrientations & SJOrientationMaskLandscapeRight;
    }
    return NO;
}

#pragma mark -
- (void)setTransitioning:(BOOL)transitioning {
    _transitioning = transitioning;
    [NSNotificationCenter.defaultCenter postNotificationName:SJRotationManagerTransitioningValueDidChangeNotification object:self];
}

@synthesize timerControl = _timerControl;
- (SJTimerControl *)timerControl {
    if ( _timerControl == nil ) {
        _timerControl = [SJTimerControl.alloc init];
        _timerControl.interval = 2;
        __weak typeof(self) _self = self;
        _timerControl.exeBlock = ^(SJTimerControl * _Nonnull control) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.inactivated = NO;
        };
    }
    return _timerControl;
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
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(transitioningValueDidChange:) name:SJRotationManagerTransitioningValueDidChangeNotification object:mgr];
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)transitioningValueDidChange:(NSNotification *)note {
    if ( _mgr == nil ) return;
    SJRotationManager *mgr = note.object;
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
NS_ASSUME_NONNULL_END
