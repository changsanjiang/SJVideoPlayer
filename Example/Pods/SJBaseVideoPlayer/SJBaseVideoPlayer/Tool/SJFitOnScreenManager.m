//
//  SJFitOnScreenManager.m
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2018/12/31.
//

#import "SJFitOnScreenManager.h"

NS_ASSUME_NONNULL_BEGIN
static NSNotificationName const SJFitOnScreenManagerTransitioningValueDidChangeNotification = @"SJFitOnScreenManagerTransitioningValueDidChange";

typedef NS_ENUM(NSUInteger, ModalViewControllerState) {
    ModalViewControllerStatePresented = 0,
    ModalViewControllerStateDismissed = 1
};

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

@interface SJFitOnScreenAnimator : NSObject
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, weak, nullable) UIViewController *modalViewController;
- (void)presentedAnima:(void(^)(SJFitOnScreenAnimator *anim, UIView *presentView, id<UIViewControllerContextTransitioning> transitionContext))pBlock
        dismissedAnima:(void(^)(SJFitOnScreenAnimator *anim, UIView *presentView, id<UIViewControllerContextTransitioning> transitionContext))dBlock;
@end
@interface SJFitOnScreenAnimator ()<UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>
@property (nonatomic) ModalViewControllerState      state;
@property (nonatomic, copy, nullable) void(^presentedAnimBlock)(SJFitOnScreenAnimator *anim, UIView *presentView, id<UIViewControllerContextTransitioning> transitionContext);
@property (nonatomic, copy, nullable) void(^dismissedAnimBlock)(SJFitOnScreenAnimator *anim, UIView *presentView, id<UIViewControllerContextTransitioning> transitionContext);
@end

@implementation SJFitOnScreenAnimator
- (instancetype)initWithModalViewController:(UIViewController *)viewController {
    self = [self init];
    self.modalViewController = viewController;
    return self;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _duration = 0.5;
    }
    return self;
}

- (void)setModalViewController:(nullable UIViewController *)modalViewController {
    _modalViewController = modalViewController;
    modalViewController.transitioningDelegate  = self;
    modalViewController.modalPresentationStyle = UIModalPresentationCustom;
}

- (void)presentedAnima:(void (^)(SJFitOnScreenAnimator * _Nonnull, UIView * _Nonnull, id<UIViewControllerContextTransitioning> _Nonnull))pBlock dismissedAnima:(void (^)(SJFitOnScreenAnimator * _Nonnull, UIView * _Nonnull, id<UIViewControllerContextTransitioning> _Nonnull))dBlock {
    _presentedAnimBlock = pBlock;
    _dismissedAnimBlock = dBlock;
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.state) {
        case ModalViewControllerStatePresented: {
            if ( self.presentedAnimBlock ) {
                UIView *containerView = [transitionContext containerView];
                UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
                [containerView addSubview:toView];
                self.presentedAnimBlock(self, toView, transitionContext);
            }
        }
            break;
        case ModalViewControllerStateDismissed: {
            if ( self.dismissedAnimBlock ) {
                UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
                self.dismissedAnimBlock(self, fromView, transitionContext);
            }
        }
            break;
        default:
#ifdef DEBUG
            NSLog(@"default error, %s, %d", __FILE__, (int)__LINE__);
#endif
            break;
    }
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.state = ModalViewControllerStatePresented;
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.state = ModalViewControllerStateDismissed;
    return self;
}
@end



#pragma mark -
@interface SJFitOnScreenNavigationController: UINavigationController
@end
@implementation SJFitOnScreenNavigationController
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

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    if ( [viewController isKindOfClass:SJFullscreenModeViewController.class] ) {
//        [super pushViewController:viewController animated:animated];
//    }
//    else if ( [self.sj_delegate respondsToSelector:@selector(vc_forwardPushViewController:animated:)] ) {
//        [self.sj_delegate vc_forwardPushViewController:viewController animated:animated];
//    }
}
@end

@interface SJFitOnScreenViewController : UIViewController
@end
@implementation SJFitOnScreenViewController
@end

#pragma mark -





@interface SJFitOnScreenManager ()
@property (nonatomic, getter=isTransitioning) BOOL transitioning;
@property (nonatomic) BOOL innerFitOnScreen;
@property (nonatomic, strong, readonly) UIView *target;
@property (nonatomic, strong, readonly) UIView *superview;
@property (nonatomic, strong, readonly) SJFitOnScreenAnimator *animator;
@property (nonatomic, strong, readonly) SJFitOnScreenViewController *viewController;
@end

@implementation SJFitOnScreenManager
- (instancetype)initWithTarget:(__strong UIView *)target targetSuperview:(__strong UIView *)superview {
    self = [super init];
    if ( !self )
        return nil;
    _target = target;
    _superview = superview;
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
        
        // reset blocks
        
        [self.animator presentedAnima:^(SJFitOnScreenAnimator * _Nonnull anim, UIView * _Nonnull presentView, id<UIViewControllerContextTransitioning>  _Nonnull transitionContext) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            CGRect frame = [self.superview convertRect:self.superview.bounds toView:UIApplication.sharedApplication.keyWindow];
            self.target.frame = frame;
            [presentView addSubview:self.target];
            [UIView animateWithDuration:anim.duration animations:^{
                self.target.frame = presentView.bounds;
                [self.target layoutIfNeeded];
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
                self.transitioning = NO;
                if ( completionHandler ) completionHandler(self);
            }];
        } dismissedAnima:^(SJFitOnScreenAnimator * _Nonnull anim, UIView * _Nonnull presentView, id<UIViewControllerContextTransitioning>  _Nonnull transitionContext) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            CGRect frame = [self.superview convertRect:self.superview.bounds toView:UIApplication.sharedApplication.keyWindow];
            [UIView animateWithDuration:anim.duration animations:^{
                self.target.frame = frame;
                [self.target layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.target.frame = self.superview.bounds;
                [self.superview addSubview:self.target];
                [transitionContext completeTransition:YES];
                self.transitioning = NO;
                if ( completionHandler ) completionHandler(self);
            }];
        }];
        
        if ( fitOnScreen ) {
            UIViewController *rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
            [rootViewController presentViewController:self.viewController animated:YES completion:nil];
        }
        else {
            [self.viewController dismissViewControllerAnimated:YES completion:nil];
        } 
    });
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

- (void)setDuration:(NSTimeInterval)duration {
    self.animator.duration = duration;
}

- (NSTimeInterval)duration {
    return self.animator.duration;
}

@synthesize animator = _animator;
- (SJFitOnScreenAnimator *)animator {
    if ( _animator == nil ) {
        _animator = SJFitOnScreenAnimator.alloc.init;
        _animator.duration = 0.4;
        _animator.modalViewController = self.viewController;
    }
    return _animator;
}

@synthesize viewController = _viewController;
- (SJFitOnScreenViewController *)viewController {
    if ( _viewController == nil ) {
        _viewController = SJFitOnScreenViewController.alloc.init;
    }
    return _viewController;
}
@end
NS_ASSUME_NONNULL_END
