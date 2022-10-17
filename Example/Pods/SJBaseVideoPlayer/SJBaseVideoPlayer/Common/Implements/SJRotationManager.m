//
//  SJRotationManager.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJRotationManager.h"
#import "SJRotationManagerInternal.h"
#import "SJRotationObserver.h"
#import "SJRotationManager_iOS_16_Later.h"
#import "SJRotationManager_iOS_9_15.h"
#import "SJRotationFullscreenNavigationController.h"
#import "SJRotationFullscreenWindow.h"
#import "SJRotationDefines.h"
#import "SJTimerControl.h"
#import <objc/message.h>

@interface SJRotationActivation : NSObject
@property (nonatomic, readonly, getter=isActive) BOOL active;
- (void)forceActive;
@end

@implementation SJRotationActivation {
    SJTimerControl *_timer;
}
- (instancetype)init {
    self = [super init];
    if ( self ) {
        __weak typeof(self) _self = self;
        _timer = [SJTimerControl.alloc init];
        _timer.exeBlock = ^(SJTimerControl * _Nonnull control) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            self->_active = YES;
        };
        _active = UIApplication.sharedApplication.applicationState == UIApplicationStateActive;
        [self _observeNotifies];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)_observeNotifies {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_onApplicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_onApplicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)forceActive {
    if ( !_active ) {
        _active = YES;
        [_timer interrupt];
    }
}

- (void)_onApplicationWillResignActive:(NSNotification *)note {
    [_timer interrupt];
    _active = NO;
}

- (void)_onApplicationDidBecomeActive:(NSNotification *)note {
    [_timer resume];
}
@end

@interface SJRotationManager ()<SJRotationFullscreenWindowDelegate, SJRotationFullscreenNavigationControllerDelegate, SJRotationFullscreenViewControllerDelegate> {
    SJRotationFullscreenWindow *_window;
    BOOL _windowPreparing;
    SJRotationActivation *_rotationActivation;
    SJOrientation _deviceOrientation;
    BOOL _forcedRotation;
}
@property (nonatomic) SJOrientation currentOrientation;
@end

@implementation SJRotationManager

+ (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    if ( [window isKindOfClass:SJRotationFullscreenWindow.class] ) {
        SJRotationManager *manager = ((SJRotationFullscreenWindow *)window).rotationManager;
        if ( manager != nil ) {
            return [manager supportedInterfaceOrientationsForWindow:window];
        }
    }
    return UIInterfaceOrientationMaskAll;
}

+ (instancetype)rotationManager {
    if ( @available(iOS 16.0, *) )
        return [SJRotationManager_iOS_16_Later.alloc _init];
    else
        return [SJRotationManager_iOS_9_15.alloc _init];
}

- (instancetype)_init {
    self = [super init];
    if ( self ) {
        _autorotationSupportedOrientations = SJOrientationMaskAll;
        _currentOrientation = SJOrientation_Portrait;
        _deviceOrientation = SJOrientation_Portrait;
        _rotationActivation = [SJRotationActivation.alloc init];
        // 先注册通知, 再做准备, 保证通知回调先执行;
        [self _observeDeviceOrientation];
        [self _prepareWindowForRotation];
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif
    [_window setHidden:YES];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (id<SJRotationManagerObserver>)getObserver {
    return [SJRotationObserver.alloc initWithManager:self];
}

- (UIWindow *)window {
    return _window;
}

- (BOOL)isForcedRotation {
    return _forcedRotation;
}

- (SJOrientation)deviceOrientation {
    return _deviceOrientation;
}

- (BOOL)allowsRotation {
    if ( _windowPreparing ) return NO;
    if ( !_rotationActivation.isActive ) return NO;
    if ( _rotating && !_transitioning ) return YES;
    if ( _currentOrientation == _deviceOrientation ) return NO;
    if ( !_forcedRotation ) {
        if ( _disabledAutorotation ) return NO;
        if ( !SJRotationIsSupportedOrientation(_deviceOrientation, _autorotationSupportedOrientations) ) return NO;
    }
    if ( _rotating && _transitioning ) return NO;
    if ( _shouldTriggerRotation != nil && !_shouldTriggerRotation(self) ) return NO;
    return YES;
}

- (void)rotationBegin {
    _rotating = YES;
    [NSNotificationCenter.defaultCenter postNotificationName:SJRotationManagerRotationNotification object:self];
}

- (void)rotationEnd {
    _rotating = NO;
    _forcedRotation = NO;
    [NSNotificationCenter.defaultCenter postNotificationName:SJRotationManagerRotationNotification object:self];
}

- (void)transitionBegin {
    _transitioning = YES;
    [NSNotificationCenter.defaultCenter postNotificationName:SJRotationManagerTransitionNotification object:self];
}

- (void)transitionEnd {
    _transitioning = NO;
    [NSNotificationCenter.defaultCenter postNotificationName:SJRotationManagerTransitionNotification object:self];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (__kindof SJRotationFullscreenViewController *)rotationFullscreenViewController {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)rotateToOrientation:(SJOrientation)orientation animated:(BOOL)animated complete:(void (^)(SJRotationManager * _Nonnull))completionHandler {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)onDeviceOrientationChanged:(SJOrientation)deviceOrientation {
    
}

#pragma mark -

- (BOOL)isFullscreen {
    return SJRotationIsFullscreenOrientation(_currentOrientation);
}

- (void)rotate {
    SJOrientation orientation;
    if ( SJRotationIsFullscreenOrientation(_currentOrientation) ) {
        orientation = SJOrientation_Portrait;
    }
    else {
        orientation = SJRotationIsFullscreenOrientation(_deviceOrientation) ? _deviceOrientation : SJOrientation_LandscapeLeft;
    }
    [self rotate:orientation animated:YES];
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated {
    [self rotate:orientation animated:animated completionHandler:nil];
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void(^)(id<SJRotationManager> mgr))completionHandler {
    SJOrientation fromOrientation = self.currentOrientation;
    SJOrientation toOrientation = orientation;
    if ( fromOrientation == toOrientation ) {
        if ( completionHandler != nil ) completionHandler(self);
        return;
    }

    _forcedRotation = YES;
    _deviceOrientation = orientation;
    [_rotationActivation forceActive];
    [self rotateToOrientation:orientation animated:animated complete:completionHandler];
}

#pragma mark - SJRotationFullscreenWindowDelegate, SJRotationFullscreenNavigationControllerDelegate, SJRotationFullscreenViewControllerDelegate

- (BOOL)window:(SJRotationFullscreenWindow *)window pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return [self pointInside:point withEvent:event];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [_actionForwarder pushViewController:viewController animated:animated];
}

- (BOOL)prefersStatusBarHiddenForRotationFullscreenViewController:(SJRotationFullscreenViewController *)viewController {
    return _rotating ? SJRotationIsFullscreenOrientation(_deviceOrientation) : [_actionForwarder prefersStatusBarHidden];
}
- (UIStatusBarStyle)preferredStatusBarStyleForRotationFullscreenViewController:(SJRotationFullscreenViewController *)viewController {
    return [_actionForwarder preferredStatusBarStyle];
}

#pragma mark -

- (void)_prepareWindowForRotation {
    if ( @available(iOS 13.0, *) ) {
        _window = [SJRotationFullscreenWindow.alloc initWithWindowScene:UIApplication.sharedApplication.keyWindow.windowScene ?: (UIWindowScene *)UIApplication.sharedApplication.connectedScenes.anyObject delegate:self];
    }
    else {
        _window = [SJRotationFullscreenWindow.alloc initWithFrame:UIScreen.mainScreen.bounds delegate:self];
    }
    _window.rotationManager = self;
    SJRotationFullscreenViewController *fullscreenViewController = [self rotationFullscreenViewController];
    fullscreenViewController.delegate = self;
    SJRotationFullscreenNavigationController *rootViewController = [SJRotationFullscreenNavigationController.alloc initWithRootViewController:fullscreenViewController delegate:self];
    _window.rootViewController = rootViewController;
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

- (void)_observeDeviceOrientation {
    UIDevice *device = UIDevice.currentDevice;
    if ( !device.isGeneratingDeviceOrientationNotifications ) {
        [device beginGeneratingDeviceOrientationNotifications];
    }
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_onDeviceOrientationChangedWithNote:) name:UIDeviceOrientationDidChangeNotification object:device];
}

- (void)_onDeviceOrientationChangedWithNote:(NSNotification *)note {
    NSInteger orientation = UIDevice.currentDevice.orientation;
    switch ( orientation ) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            if ( _deviceOrientation != orientation ) {
                _deviceOrientation = orientation;
                
                [self onDeviceOrientationChanged:orientation];
            }
            
        }
            break;
        default: break;
    }
}
@end


#pragma mark - fix safe area

#import <objc/message.h>
#import "SJBaseVideoPlayerConst.h"

API_DEPRECATED("deprecated!", ios(13.0, 16.0)) @protocol _UIViewControllerSafeAreaFixingHooks <NSObject>
- (void)_setContentOverlayInsets:(UIEdgeInsets)insets andLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;
- (void)sj_setContentOverlayInsets:(UIEdgeInsets)insets andLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;
@end

API_DEPRECATED("deprecated!", ios(13.0, 16.0)) @implementation SJRotationManager (SJRotationSafeAreaFixing)
+ (void)initialize {
    if ( @available(iOS 16.0, *) )
        return;
    
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

API_DEPRECATED("deprecated!", ios(13.0, 16.0)) @implementation UIViewController (SJRotationSafeAreaFixing)
- (void)sj_setContentOverlayInsets:(UIEdgeInsets)insets andLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin {
    SJSafeAreaInsetsMask mask = self.disabledAdjustSafeAreaInsetsMask;
    if ( mask & SJSafeAreaInsetsMaskTop ) insets.top = 0;
    if ( mask & SJSafeAreaInsetsMaskLeft ) insets.left = 0;
    if ( mask & SJSafeAreaInsetsMaskBottom ) insets.bottom = 0;
    if ( mask & SJSafeAreaInsetsMaskRight ) insets.right = 0;
    
//    BOOL isFullscreen = self.view.bounds.size.width > self.view.bounds.size.height;
//    if ( ![self.class isKindOfClass:SJRotationFullscreenViewController.class] || isFullscreen ) {
//        if ( isFullscreen || insets.top != 0 || [self sj_containsPlayerView] == NO ) {
//            [self sj_setContentOverlayInsets:insets andLeftMargin:leftMargin rightMargin:rightMargin];
//        }
//    }
    
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    UIWindow *otherWindow = self.view.window;
    if ( [keyWindow isKindOfClass:SJRotationFullscreenWindow.class] && otherWindow != nil ) {
        SJRotationManager *manager = ((SJRotationFullscreenWindow *)keyWindow).rotationManager;
        UIWindow *superviewWindow = manager.superview.window;
        if ( superviewWindow != otherWindow ) {
            [self sj_setContentOverlayInsets:insets andLeftMargin:leftMargin rightMargin:rightMargin];
        }
    }
    else {
        [self sj_setContentOverlayInsets:insets andLeftMargin:leftMargin rightMargin:rightMargin];
    }
}

- (void)setDisabledAdjustSafeAreaInsetsMask:(SJSafeAreaInsetsMask)disabledAdjustSafeAreaInsetsMask {
    objc_setAssociatedObject(self, @selector(disabledAdjustSafeAreaInsetsMask), @(disabledAdjustSafeAreaInsetsMask), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJSafeAreaInsetsMask)disabledAdjustSafeAreaInsetsMask {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}
@end
