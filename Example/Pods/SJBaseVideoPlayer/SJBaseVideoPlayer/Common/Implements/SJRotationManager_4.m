//
//  SJRotationManager_4.m
//  version_4
//
//  Created by 畅三江 on 2022/7/6.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJRotationManager_4.h"
#import "SJTimerControl.h"
#import "SJBaseVideoPlayerConst.h"
#import "SJRotationManagerInternal_4.h"
#import "UIView+SJBaseVideoPlayerExtended.h"

FOUNDATION_STATIC_INLINE  BOOL
_isFullscreenOrientation(SJOrientation orientation) {
    return orientation != SJOrientation_Portrait;
}

FOUNDATION_STATIC_INLINE  BOOL
_isSupportedOrientation(SJOrientationMask supportedOrientations, SJOrientation orientation) {
    switch ( orientation ) {
        case SJOrientation_Portrait:
            return supportedOrientations & SJOrientationMaskPortrait;
        case SJOrientation_LandscapeLeft:
            return supportedOrientations & SJOrientationMaskLandscapeLeft;
        case SJOrientation_LandscapeRight:
            return supportedOrientations & SJOrientationMaskLandscapeRight;
    }
    return NO;
}

#pragma mark - observer


static NSNotificationName const SJRotationManagerRotationNotification_4 = @"SJRotationManagerRotationNotification_4";
static NSNotificationName const SJRotationManagerTransitionNotification_4 = @"SJRotationManagerTransitionNotification_4";


@interface SJRotationObserver_4 : NSObject<SJRotationManagerObserver>
- (instancetype)initWithManager:(id<SJRotationManager>)manager;

@property (nonatomic, copy, nullable) void(^onRotatingChanged)(id<SJRotationManager> mgr, BOOL isRotating);
@property (nonatomic, copy, nullable) void(^onTransitioningChanged)(id<SJRotationManager> mgr, BOOL isTransitioning);
@end

@implementation SJRotationObserver_4
- (instancetype)initWithManager:(id<SJRotationManager>)manager {
    self = [super init];
    if ( self ) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onRotation:) name:SJRotationManagerRotationNotification_4 object:manager];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onTransition:) name:SJRotationManagerTransitionNotification_4 object:manager];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)onRotation:(NSNotification *)note {
    BOOL isRotating = [(SJRotationManager_4 *)note.object isRotating];
    if ( _onRotatingChanged != nil ) _onRotatingChanged(note.object, isRotating);
}

- (void)onTransition:(NSNotification *)note {
    BOOL isTransitioning = [(SJRotationManager_4 *)note.object isTransitioning];
    if ( _onTransitioningChanged != nil ) _onTransitioningChanged(note.object, isTransitioning);
}
@end

#pragma mark - view controller

@protocol SJRotationFullscreenViewController_4Delegate;

@interface SJRotationFullscreenViewController_4 : UIViewController

@property (nonatomic, weak, nullable) id<SJRotationFullscreenViewController_4Delegate> sj_4_delegate;

@property (nonatomic, strong, readonly) UIView *playerSuperview;

@end


@protocol SJRotationFullscreenViewController_4Delegate <NSObject>
- (BOOL)shouldAutorotate;
- (void)viewController:(SJRotationFullscreenViewController_4 *)viewController viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

- (BOOL)prefersStatusBarHidden;
- (UIStatusBarStyle)preferredStatusBarStyle;
@end

@interface SJRotationFullscreenView_4 : UIView

@end

@implementation SJRotationFullscreenView_4
- (UIEdgeInsets)safeAreaInsets {
    CGSize size = self.bounds.size;
    if ( size.width > size.height ) return [super safeAreaInsets];
    return [UIApplication.sharedApplication.keyWindow safeAreaInsets];
}
@end

@implementation SJRotationFullscreenViewController_4

- (void)loadView {
    self.view = [SJRotationFullscreenView_4.alloc initWithFrame:UIScreen.mainScreen.bounds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = NO;
    self.view.backgroundColor = UIColor.clearColor;
    
    _playerSuperview = [UIView.alloc initWithFrame:CGRectZero];
    _playerSuperview.backgroundColor = UIColor.clearColor;
    [self.view addSubview:_playerSuperview];
}

- (BOOL)shouldAutorotate {
    return [_sj_4_delegate shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return [_sj_4_delegate prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [_sj_4_delegate preferredStatusBarStyle];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

- (void)setNeedsStatusBarAppearanceUpdate {
    [super setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [_sj_4_delegate viewController:self viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
@end

@protocol SJRotationFullscreenNavigationController_4Delegate <NSObject>
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end

@interface SJRotationFullscreenNavigationController_4 : UINavigationController
@property (nonatomic, weak, nullable) id<SJRotationFullscreenNavigationController_4Delegate> sj_4_delegate;
@end

@implementation SJRotationFullscreenNavigationController_4
- (void)viewDidLoad {
    [super viewDidLoad];
    [super setNavigationBarHidden:YES animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden { }

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated { }

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
    if ( [viewController isKindOfClass:SJRotationFullscreenViewController_4.class] ) {
        [super pushViewController:viewController animated:animated];
    }
    else if ( [self.sj_4_delegate respondsToSelector:@selector(pushViewController:animated:)] ) {
        [self.sj_4_delegate pushViewController:viewController animated:animated];
    }
}
@end


#pragma mark - window

@protocol SJRotationFullscreenWindow_4Delegate;


@interface SJRotationFullscreenWindow_4 : UIWindow
@property (nonatomic, weak, nullable) id<SJRotationFullscreenWindow_4Delegate> sj_4_delegate;
@end


@protocol SJRotationFullscreenWindow_4Delegate <NSObject>
- (BOOL)window:(SJRotationFullscreenWindow_4 *)window pointInside:(CGPoint)point withEvent:(UIEvent *_Nullable)event;
- (BOOL)allowsRotation;
@end

@implementation SJRotationFullscreenWindow_4
@dynamic rootViewController;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene {
    self = [super initWithWindowScene:windowScene];
    if ( self ) {
        [self _setup];
    }
    return self;
}

- (BOOL)canBecomeKeyWindow {
    return NO;
}

- (void)makeKeyWindow { }

- (void)makeKeyAndVisible { }

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
}
#endif

- (void)setRootViewController:(UIViewController *)rootViewController {
    [super setRootViewController:rootViewController];
    rootViewController.view.frame = self.bounds;
    rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)_setup {
    self.frame = UIScreen.mainScreen.bounds;
}

- (void)setBackgroundColor:(nullable UIColor *)backgroundColor {}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *_Nullable)event {
    return [_sj_4_delegate window:self pointInside:point withEvent:event];
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

#pragma mark - manager

@interface SJRotationManager_4_iOS_9_15 : SJRotationManager_4

@end

API_AVAILABLE(ios(16.0))
@interface SJRotationManager_4_iOS_16_Later : SJRotationManager_4

@end

@interface SJRotationManager_4 ()<SJRotationFullscreenWindow_4Delegate, SJRotationFullscreenViewController_4Delegate, SJRotationFullscreenNavigationController_4Delegate>
@property (nonatomic) UIDeviceOrientation deviceOrientation;
@property (nonatomic, copy, nullable) void(^completionHandler)(id<SJRotationManager> mgr);

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

@property (nonatomic, getter=isForcedrotation) BOOL forcedrotation;
@property (nonatomic, getter=isTransitioning) BOOL transitioning;
@property (nonatomic, getter=isWindowPreparing) BOOL windowPreparing;

@property (nonatomic, strong) SJRotationFullscreenWindow_4 *window;
@property (nonatomic, strong) SJRotationFullscreenViewController_4 *viewController;
@property (nonatomic, weak, nullable) id<SJRotationManager_4Delegate> delegate;
@end

@implementation SJRotationManager_4
@synthesize shouldTriggerRotation = _shouldTriggerRotation;
@synthesize disabledAutorotation = _disabledAutorotation;
@synthesize autorotationSupportedOrientations = _autorotationSupportedOrientations;
@synthesize currentOrientation = _currentOrientation;
@synthesize rotating = _rotating;
@synthesize superview = _superview;
@synthesize target = _target;

+ (instancetype)rotationManager {
    if ( @available(iOS 16.0, *) )
        return [SJRotationManager_4_iOS_16_Later.alloc _init];
    else
        return [SJRotationManager_4_iOS_9_15.alloc _init];
}

- (instancetype)_init {
    self = [super init];
    if ( self ) {
        _autorotationSupportedOrientations = SJOrientationMaskAll;
        _currentOrientation = SJOrientation_Portrait;
        _deviceOrientation = UIDeviceOrientationPortrait;
        _timerControl = [SJTimerControl.alloc init];
        _timerControl.interval = 2;
        __weak typeof(self) _self = self;
        _timerControl.exeBlock = ^(SJTimerControl * _Nonnull control) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            self.inactivated = NO;
        };
        [self _observeNotifies];
        
        _viewController = [SJRotationFullscreenViewController_4.alloc init];
        _viewController.sj_4_delegate = self;
        
        SJRotationFullscreenNavigationController_4 *nav = [SJRotationFullscreenNavigationController_4.alloc initWithRootViewController:_viewController];
        nav.sj_4_delegate = self;
        
        if ( @available(iOS 13.0, *) ) {
            _window = [SJRotationFullscreenWindow_4.alloc initWithWindowScene:UIApplication.sharedApplication.keyWindow.windowScene];
        }
        else {
            _window = [SJRotationFullscreenWindow_4.alloc initWithFrame:UIScreen.mainScreen.bounds];
        }
        _window.sj_4_delegate = self;
        _window.rootViewController = nav;

        [self _prepareWindowForRotation];
    }
    return self;
}

- (void)_prepareWindowForRotation {
    _windowPreparing = YES;
    [UIView animateWithDuration:0.0 animations:^{ /** next */ } completion:^(BOOL finished) {
        self->_window.windowLevel = UIWindowLevelNormal - 1;
        self->_window.hidden = NO;
        [UIView animateWithDuration:0.0 animations:^{ /** preparing */} completion:^(BOOL finished) {
            self->_window.hidden = YES;
            self->_window.windowLevel = UIWindowLevelStatusBar - 1;
            self->_windowPreparing = NO;
        }];
    }];
}

- (id<SJRotationManagerObserver>)getObserver {
    return [SJRotationObserver_4.alloc initWithManager:self];
}

- (BOOL)isFullscreen {
    return _rotating ? _isFullscreenOrientation(_deviceOrientation) : _isFullscreenOrientation(_currentOrientation);
}

- (void)rotate {
    SJOrientation orientation;
    if ( _isFullscreenOrientation(_currentOrientation) ) {
        orientation = SJOrientation_Portrait;
    }
    else {
        orientation = _isFullscreenOrientation(_deviceOrientation) ? _deviceOrientation : SJOrientation_LandscapeLeft;
    }
    
    [self rotate:orientation animated:YES];
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated {
    [self rotate:orientation animated:animated completionHandler:nil];
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void(^)(id<SJRotationManager> mgr))completionHandler {
    // subclass
}

#pragma mark - SJRotationFullscreenWindow_4Delegate, SJRotationFullscreenViewController_4Delegate, SJRotationFullscreenNavigationController_4Delegate

- (BOOL)window:(SJRotationFullscreenWindow_4 *)window pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return (_target.superview == _viewController.playerSuperview) &&
          [_viewController.playerSuperview pointInside:[window convertPoint:point toView:_viewController.playerSuperview] withEvent:event];
}

- (BOOL)prefersStatusBarHidden {
    return _rotating ? _isFullscreenOrientation(_deviceOrientation) : [_delegate prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [_delegate preferredStatusBarStyle];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [_delegate pushViewController:viewController animated:animated];
}

- (BOOL)allowsRotation {
    if ( _windowPreparing ) return NO;
    if ( _inactivated ) return NO;
    if ( _currentOrientation == (SJOrientation)_deviceOrientation ) return NO;
    if ( !_forcedrotation ) {
        if ( _disabledAutorotation ) return NO;
        if ( !_isSupportedOrientation(_autorotationSupportedOrientations, _deviceOrientation) ) return NO;
    }
    if ( _rotating && _transitioning ) return NO;
    if ( _shouldTriggerRotation != nil && !_shouldTriggerRotation(self) ) return NO;
    return YES;
}

- (BOOL)shouldAutorotate {
    // subclass
    return NO;
}

- (void)viewController:(SJRotationFullscreenViewController_4 *)viewController viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    _currentOrientation = _deviceOrientation;
    [self _transitionBegin];
    
    if ( size.width > size.height ) {
        if ( _target.superview != _viewController.playerSuperview ) {
            CGRect frame = [_target convertRect:_target.bounds toView:_target.window];
            _viewController.playerSuperview.frame = frame; // t1
            
            _target.frame = (CGRect){0, 0, frame.size};
            _target.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [_viewController.playerSuperview addSubview:_target]; // t2
        }
        
        [UIView animateWithDuration:0.0 animations:^{ /* preparing */ } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self->_viewController.playerSuperview.frame = (CGRect){CGPointZero, size};
            } completion:^(BOOL finished) {
                [self _transitionEnd];
                [self _rotationEnd];
            }];
        }];
    }
    else {
        [UIView animateWithDuration:0.0 animations:^{ /* preparing */ } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self->_viewController.playerSuperview.frame = [self->_superview convertRect:self->_superview.bounds toView:self->_superview.window];
            } completion:^(BOOL finished) {
                UIView *snapshot = [self->_target snapshotViewAfterScreenUpdates:NO];
                snapshot.frame = self->_superview.bounds;
                snapshot.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self->_superview addSubview:snapshot];
                [UIView animateWithDuration:0.0 animations:^{ /* preparing */ } completion:^(BOOL finished) {
                    self->_target.frame = self->_superview.bounds;
                    self->_target.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [self->_superview addSubview:self->_target];
                    [snapshot removeFromSuperview];
                    [self _transitionEnd];
                    [self _rotationEnd];
                }];
            }];
        }];
    }
}

- (void)_rotationBegin {
    _window.hidden = NO;
    _rotating = YES;
    [UIView animateWithDuration:0.0 animations:^{ } completion:^(BOOL finished) {
        [self->_window.rootViewController setNeedsStatusBarAppearanceUpdate];
    }];
    [NSNotificationCenter.defaultCenter postNotificationName:SJRotationManagerRotationNotification_4 object:self];
}

- (void)_rotationEnd {
    _rotating = NO;
    _forcedrotation = NO;
    if ( ![self isFullscreen] ) _window.hidden = YES;
    if ( _completionHandler ) {
        _completionHandler(self);
        _completionHandler = nil;
    }
    [NSNotificationCenter.defaultCenter postNotificationName:SJRotationManagerRotationNotification_4 object:self];
}

- (void)_transitionBegin {
    _transitioning = YES;
    [NSNotificationCenter.defaultCenter postNotificationName:SJRotationManagerTransitionNotification_4 object:self];
}

- (void)_transitionEnd {
    self->_transitioning = NO;
    [NSNotificationCenter.defaultCenter postNotificationName:SJRotationManagerTransitionNotification_4 object:self];
}

#pragma mark -

- (void)_observeNotifies {
    UIDevice *device = UIDevice.currentDevice;
    if ( !device.isGeneratingDeviceOrientationNotifications ) {
        [device beginGeneratingDeviceOrientationNotifications];
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_onDeviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:device];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_onApplicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_onApplicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)_onDeviceOrientationChanged:(NSNotification *)note {
    UIDeviceOrientation orientation = UIDevice.currentDevice.orientation;
    switch ( orientation ) {
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            if ( _deviceOrientation != orientation ) {
                _deviceOrientation = orientation;
                
                [self onDeviceOrientationChanged];
            }
            
        }
            break;
        default: break;
    }
}

- (void)_onApplicationWillResignActive:(NSNotification *)note {
    [_timerControl clear];
    _inactivated = YES;
}

- (void)_onApplicationDidBecomeActive:(NSNotification *)note {
    [_timerControl start];
}

- (void)dealloc {
    _window.hidden = YES;
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setNeedsStatusBarAppearanceUpdate {
    [_window.rootViewController setNeedsStatusBarAppearanceUpdate];
}

- (void)onDeviceOrientationChanged { /** subclass */ }
@end


//if ( UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM() ) { }
//else if ( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() ) { }

#pragma mark - iOS 9, 15;

@implementation SJRotationManager_4_iOS_9_15

- (BOOL)shouldAutorotate {
    if ( [self allowsRotation] ) {
        if ( !self.rotating ) [self _rotationBegin];
        return YES;
    }
    return NO;
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void(^)(id<SJRotationManager> mgr))completionHandler {
#ifdef DEBUG
    if ( !animated ) {
        NSAssert(false, @"暂不支持关闭动画!");
    }
#endif
    self.completionHandler = completionHandler;
    self.inactivated = NO;
    self.forcedrotation = YES;
    
    if ( orientation == self.currentOrientation ) {
        [self _rotationEnd];
        return;
    }
    
    [UIDevice.currentDevice setValue:@(UIDeviceOrientationUnknown) forKey:@"orientation"];
    [UIDevice.currentDevice setValue:@(orientation) forKey:@"orientation"];
}
@end

#pragma mark - iOS 16 later;

@implementation SJRotationManager_4_iOS_16_Later

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void(^)(id<SJRotationManager> mgr))completionHandler {
#ifdef DEBUG
    if ( !animated ) {
        NSAssert(false, @"暂不支持关闭动画!");
    }
#endif
    self.completionHandler = completionHandler;
    self.inactivated = NO;
    self.forcedrotation = YES;
    
    if ( orientation == self.currentOrientation ) {
        [self _rotationEnd];
        return;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
    __weak typeof(self) _self = self;
    UIWindowSceneGeometryPreferencesIOS *preferences = [UIWindowSceneGeometryPreferencesIOS.alloc initWithInterfaceOrientations:1 << orientation];
    self.deviceOrientation = orientation;
    [UIApplication.sharedApplication.keyWindow.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
    [UIView animateWithDuration:0.0 animations:^{ /* preparing */ } completion:^(BOOL finished) {
        [self _rotationBegin];
        [self.window.windowScene requestGeometryUpdateWithPreferences:preferences errorHandler:^(NSError * _Nonnull error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
#ifdef DEBUG
            NSLog(@"旋转失败: %@", error);
#endif
            [self _rotationEnd];
        }];
    }];
#endif
}

- (void)setDisabledAutorotation:(BOOL)disabledAutorotation {
    if ( disabledAutorotation != self.isDisabledAutorotation ) {
        [super setDisabledAutorotation:disabledAutorotation];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
        [UIApplication.sharedApplication.keyWindow.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
#endif
    }
}

- (void)onDeviceOrientationChanged {
#ifdef DEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif
    if ( [self allowsRotation] ) {
        [self _rotationBegin];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
        [UIApplication.sharedApplication.keyWindow.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
#endif
    }
}
@end


#pragma mark - window rotation orientations

@implementation UIWindow (SJRotationControls)
- (UIInterfaceOrientationMask)sj_4_supportedInterfaceOrientations {
    if ( [self isKindOfClass:SJRotationFullscreenWindow_4.class] ) {
        SJRotationFullscreenWindow_4 *window = (SJRotationFullscreenWindow_4 *)self;
        SJRotationManager_4 *rotationManager = (SJRotationManager_4 *)window.sj_4_delegate;
        if ( [rotationManager allowsRotation] ) {
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }
        return 1 << rotationManager.currentOrientation;
    }
    
    return UIInterfaceOrientationMaskAll;
}
@end


#pragma mark - fix safe area

#import <objc/message.h>

API_AVAILABLE(ios(13.0)) @protocol _UIViewControllerSafeAreaFixingHooks <NSObject>
- (void)_setContentOverlayInsets:(UIEdgeInsets)insets andLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;
- (void)sj_setContentOverlayInsets:(UIEdgeInsets)insets andLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;
@end

API_AVAILABLE(ios(13.0)) @implementation SJRotationManager_4 (SJRotationSafeAreaFixing)
+ (void)initialize {
    if ( @available(iOS 13.0, *) ) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class cls = UIViewController.class;
            NSData *data = [NSData.alloc initWithBase64EncodedString:@"X3NldENvbnRlbnRPdmVybGF5SW5zZXRzOmFuZExlZnRNYXJnaW46cmlnaHRNYXJnaW46" options:kNilOptions];
            NSString *method = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
            SEL originalSelector = NSSelectorFromString(method);
            SEL swizzledSelector = @selector(sj_setContentOverlayInsets:andLeftMargin:rightMargin:);
            
            Method originalMethod = class_getInstanceMethod(cls, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
            if ( originalMethod != NULL ) method_exchangeImplementations(originalMethod, swizzledMethod);
        });
    }
}
@end

API_AVAILABLE(ios(13.0)) @implementation UIViewController (SJRotationSafeAreaFixing)
- (BOOL)sj_containsPlayerView {
    return [self.view viewWithTag:SJPlayerViewTag] != nil;
}

- (void)sj_setContentOverlayInsets:(UIEdgeInsets)insets andLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin {
    SJSafeAreaInsetsMask mask = self.disabledAdjustSafeAreaInsetsMask;
    if ( mask & SJSafeAreaInsetsMaskTop ) insets.top = 0;
    if ( mask & SJSafeAreaInsetsMaskLeft ) insets.left = 0;
    if ( mask & SJSafeAreaInsetsMaskBottom ) insets.bottom = 0;
    if ( mask & SJSafeAreaInsetsMaskRight ) insets.right = 0;
    
    BOOL isFullscreen = self.view.bounds.size.width > self.view.bounds.size.height;
    if ( ![self.class isKindOfClass:SJRotationFullscreenViewController_4.class] || isFullscreen ) {
        if ( isFullscreen || insets.top != 0 || [self sj_containsPlayerView] == NO ) {
            [self sj_setContentOverlayInsets:insets andLeftMargin:leftMargin rightMargin:rightMargin];
        }
    }
}

- (void)setDisabledAdjustSafeAreaInsetsMask:(SJSafeAreaInsetsMask)disabledAdjustSafeAreaInsetsMask {
    objc_setAssociatedObject(self, @selector(disabledAdjustSafeAreaInsetsMask), @(disabledAdjustSafeAreaInsetsMask), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJSafeAreaInsetsMask)disabledAdjustSafeAreaInsetsMask {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}
@end

API_AVAILABLE(ios(13.0)) @implementation UINavigationController (SJRotationSafeAreaFixing)
- (BOOL)sj_containsPlayerView {
    return [self.topViewController sj_containsPlayerView];
}
@end

API_AVAILABLE(ios(13.0)) @implementation UITabBarController (SJRotationSafeAreaFixing)
- (BOOL)sj_containsPlayerView {
    UIViewController *vc = self.selectedIndex != NSNotFound ? self.selectedViewController : self.viewControllers.firstObject;
    return [vc sj_containsPlayerView];
}
@end
