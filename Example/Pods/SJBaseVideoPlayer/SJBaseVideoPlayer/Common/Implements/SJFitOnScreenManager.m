//
//  SJFitOnScreenManager.m
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2018/12/31.
//

#import "SJFitOnScreenManager.h"
#import "UIViewController+SJBaseVideoPlayerExtended.h"

NS_ASSUME_NONNULL_BEGIN
static NSNotificationName const SJFitOnScreenManagerTransitioningValueDidChangeNotification = @"SJFitOnScreenManagerTransitioningValueDidChange";

@interface SJFitOnScreenManagerObserver : NSObject<SJFitOnScreenManagerObserver>
- (instancetype)initWithManager:(id<SJFitOnScreenManager>)manager;
@end

@implementation SJFitOnScreenManagerObserver
@synthesize fitOnScreenWillBeginExeBlock = _fitOnScreenWillBeginExeBlock;
@synthesize fitOnScreenDidEndExeBlock = _fitOnScreenDidEndExeBlock;

- (instancetype)initWithManager:(id<SJFitOnScreenManager>)manager {
    self = [super init];
    if ( !self )
        return nil;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(transitioningValueDidChange:) name:SJFitOnScreenManagerTransitioningValueDidChangeNotification object:manager];
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)transitioningValueDidChange:(NSNotification *)note {
    id<SJFitOnScreenManager> mgr = note.object;
    if ( mgr.isTransitioning ) {
        if ( _fitOnScreenWillBeginExeBlock )
            _fitOnScreenWillBeginExeBlock(mgr);
    }
    else {
        if ( _fitOnScreenDidEndExeBlock )
            _fitOnScreenDidEndExeBlock(mgr);
    }
}
@end

#pragma mark -

@interface SJFitOnScreenModeViewController : UIViewController
@end

@implementation SJFitOnScreenModeViewController
- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
@end

@interface SJFitOnScreenModeNavigationController : UINavigationController
@property (nonatomic, weak, nullable) id<SJViewControllerManager> viewControllerManager;
@end

@implementation SJFitOnScreenModeNavigationController
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
- (UIStatusBarStyle)preferredStatusBarStyle {
    return _viewControllerManager.preferredStatusBarStyle;
}
- (BOOL)prefersStatusBarHidden {
    return _viewControllerManager.prefersStatusBarHidden;
}
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
@end

#pragma mark -

@interface SJFitOnScreenManager ()
@property (nonatomic, getter=isTransitioning) BOOL transitioning;
@property (nonatomic) BOOL innerFitOnScreen;
@property (nonatomic, strong, readonly) UIView *target;
@property (nonatomic, strong, readonly) UIView *superview;
@property (nonatomic, strong, readonly) SJFitOnScreenModeNavigationController *viewController;
@end

@implementation SJFitOnScreenManager
@synthesize duration = _duration;
- (instancetype)initWithTarget:(__strong UIView *)target targetSuperview:(__strong UIView *)superview {
    self = [super init];
    if ( !self )
        return nil;
    _target = target;
    _superview = superview;
    _duration = 0.3;
    return self;
}

- (id<SJFitOnScreenManagerObserver>)getObserver {
    return [[SJFitOnScreenManagerObserver alloc] initWithManager:self];
}

- (BOOL)isFitOnScreen {
    return _innerFitOnScreen;
}
- (void)setFitOnScreen:(BOOL)fitOnScreen {
    [self setFitOnScreen:fitOnScreen animated:YES];
}
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated {
    [self setFitOnScreen:fitOnScreen animated:animated completionHandler:nil];
}
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated completionHandler:(nullable void (^)(id<SJFitOnScreenManager>))completionHandler {
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.isTransitioning ) return;
        if ( fitOnScreen == self.isFitOnScreen ) { if ( completionHandler ) completionHandler(self); return; }
        self.innerFitOnScreen = fitOnScreen;
        self.transitioning = YES;
        if ( fitOnScreen ) {
            UIViewController *top = [self topMostController];
            if ( !animated ) [self _presentedAnimationWithDuration:0 completionHandler:nil];
            [top presentViewController:self.viewController animated:animated completion:^{
                if ( completionHandler ) completionHandler(self);
            }];
        }
        else {
            if ( !animated ) [self _dismissedAnimationWithDuration:0 completionHandler:nil];
            [self.viewController dismissViewControllerAnimated:animated completion:^{
                if ( completionHandler ) completionHandler(self);
            }];
        } 
    });
}

- (UIViewController *)topMostController {
    UIViewController *topController = UIApplication.sharedApplication.keyWindow.rootViewController;
    while( topController.presentedViewController != nil ) {
        topController = topController.presentedViewController;
    }
    return topController;
}

- (void)setInnerFitOnScreen:(BOOL)innerFitOnScreen {
    if ( innerFitOnScreen == _innerFitOnScreen )
        return;
    _innerFitOnScreen = innerFitOnScreen;
}

- (void)setTransitioning:(BOOL)transitioning {
    _transitioning = transitioning;
    [NSNotificationCenter.defaultCenter postNotificationName:SJFitOnScreenManagerTransitioningValueDidChangeNotification object:self];
}

- (void)setViewControllerManager:(nullable id<SJViewControllerManager>)viewControllerManager {
    self.viewController.viewControllerManager = viewControllerManager;
}

- (nullable id<SJViewControllerManager>)viewControllerManager {
    return self.viewController.viewControllerManager;
}

@synthesize viewController = _viewController;
- (SJFitOnScreenModeNavigationController *)viewController {
    if ( _viewController == nil ) {
        SJFitOnScreenModeViewController *vc = SJFitOnScreenModeViewController.alloc.init;
        _viewController = [SJFitOnScreenModeNavigationController.alloc initWithRootViewController:vc];
        NSTimeInterval duration = self.duration;
        __weak typeof(self) _self = self;
        [_viewController setTransitionDuration:duration presentedAnimation:^(__kindof UIViewController * _Nonnull vc, SJAnimationCompletionHandler  _Nonnull completion) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _presentedAnimationWithDuration:duration completionHandler:completion];
        } dismissedAnimation:^(__kindof UIViewController * _Nonnull vc, SJAnimationCompletionHandler  _Nonnull completion) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _dismissedAnimationWithDuration:duration completionHandler:completion];
        }];
    }
    return _viewController;
}

- (void)_presentedAnimationWithDuration:(NSTimeInterval)duration completionHandler:(nullable SJAnimationCompletionHandler)completion {
    CGRect frame = [self.superview convertRect:self.superview.bounds toView:UIApplication.sharedApplication.keyWindow];
    self.target.frame = frame;
    [self.viewController.view addSubview:self.target];
    [UIView animateWithDuration:duration animations:^{
        self.target.frame = self.viewController.view.bounds;
        [self.target layoutIfNeeded];
    } completion:^(BOOL finished) {
        if ( completion != nil ) completion();
        self.transitioning = NO;
    }];
}

- (void)_dismissedAnimationWithDuration:(NSTimeInterval)duration completionHandler:(nullable SJAnimationCompletionHandler)completion {
    CGRect frame = [self.superview convertRect:self.superview.bounds toView:UIApplication.sharedApplication.keyWindow];
    [UIView animateWithDuration:duration animations:^{
        self.target.frame = frame;
        [self.target layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.target.frame = self.superview.bounds;
        [self.superview addSubview:self.target];
        if ( completion != nil ) completion();
        self.transitioning = NO;
    }];
}
@end
NS_ASSUME_NONNULL_END
