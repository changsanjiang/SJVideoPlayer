//
//  SJModalViewControlllerManager.m
//  Pods
//
//  Created by BlueDancer on 2019/1/28.
//

#import "SJModalViewControlllerManager.h"
#import "SJVideoPlayerURLAsset.h"
#import "SJRotationManagerDefines.h"
#import "SJControlLayerAppearManagerDefines.h"

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

@class __SJTransitionAnimator;

NS_ASSUME_NONNULL_BEGIN
typedef void(^_Nullable __SJTransitionAnimationHandler)(__SJTransitionAnimator *animator, id<UIViewControllerContextTransitioning> transitionContext);

typedef NS_ENUM(NSUInteger, __SJModalViewControllerState) {
    __SJModalViewControllerStatePresented = 0,
    __SJModalViewControllerStateDismissed = 1
};

@interface __SJTransitionAnimator : NSObject
@property (nonatomic, weak, nullable) UIViewController *modalViewController;
@property (nonatomic) NSTimeInterval duration;

- (void)setPresentAnimation:(__SJTransitionAnimationHandler)presentAnimationBlock
           dismissAnimation:(__SJTransitionAnimationHandler)dismissAnimationBlock;
@end

@interface __SJTransitionAnimator ()<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>
@property (nonatomic, copy, nullable) __SJTransitionAnimationHandler presentAnimationBlock;
@property (nonatomic, copy, nullable) __SJTransitionAnimationHandler dismissAnimationBlock;
@property (nonatomic) __SJModalViewControllerState state;
@end

@implementation __SJTransitionAnimator
#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%d - %s", (int)__LINE__, __func__);
}
#endif

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _duration = 0.5;
    }
    return self;
}

- (void)setModalViewController:(UIViewController *_Nullable)modalViewController {
    _modalViewController = modalViewController;
    modalViewController.transitioningDelegate  = self;
    modalViewController.modalPresentationStyle = UIModalPresentationCustom;
}

- (void)setPresentAnimation:(__SJTransitionAnimationHandler)presentAnimationBlock
           dismissAnimation:(__SJTransitionAnimationHandler)dismissAnimationBlock {
    _presentAnimationBlock = presentAnimationBlock;
    _dismissAnimationBlock = dismissAnimationBlock;
}

/// delegate methods

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.state = __SJModalViewControllerStatePresented;
    return self;
}
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.state = __SJModalViewControllerStateDismissed;
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    switch (self.state) {
        case __SJModalViewControllerStatePresented: {
            if ( self.presentAnimationBlock ) {
                self.presentAnimationBlock(self, transitionContext);
            }
        }
            break;
        case __SJModalViewControllerStateDismissed: {
            if ( self.dismissAnimationBlock ) {
                self.dismissAnimationBlock(self, transitionContext);
            }
        }
            break;
        default: break;
    }
}
@end

#pragma mark -

@interface __SJFitOnScreenViewControlller : UIViewController
@property (nonatomic, weak, nullable) id<SJModalViewControllerPlayer> player;
@property (nonatomic, copy, nullable) void(^dismissExeBlock)(__SJFitOnScreenViewControlller *vc);
@end

@implementation __SJFitOnScreenViewControlller
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(nullable void (^)(void))completion {
    [super dismissViewControllerAnimated:flag completion:^{
        if ( self.dismissExeBlock ) self.dismissExeBlock(self);
        if ( completion ) completion();
    }];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return [_player vc_preferredStatusBarStyle];
}
- (BOOL)prefersStatusBarHidden {
    return [_player vc_prefersStatusBarHidden];
}
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
- (BOOL)shouldAutorotate {
    return NO;
}
@end

#pragma mark -

@interface SJModalViewControlllerManager ()
@property (nonatomic, weak, nullable) UIView *target;
@property (nonatomic, weak, nullable) UIView *targetSuperView;
@property (nonatomic, weak, nullable) id<SJModalViewControllerPlayer> player;
@property (nonatomic, strong, nullable) __SJTransitionAnimator *animator;
@property (nonatomic, strong, nullable) __SJFitOnScreenViewControlller *viewController;
@property (nonatomic, weak, nullable) UIViewController *atViewController;
@property (nonatomic, getter=isTransitioning) BOOL transitioning;

// asset
@property (nonatomic, strong, nullable) SJVideoPlayerURLAsset *originAsset;
@property (nonatomic, strong, readonly) SJPlayModel *modalVCPlayModel;
@property (nonatomic, strong, nullable) SJPlayModel *originPlayModel;
@end

@implementation SJModalViewControlllerManager
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _modalVCPlayModel = [SJPlayModel new];
    return self;
}

- (BOOL)isPresentedModalViewControlller {
    return _viewController != nil;
}

- (void)presentModalViewControlllerWithTarget:(__weak UIView *)target
                              targetSuperView:(__weak UIView *)targetSuperView
                                       player:(__weak id<SJModalViewControllerPlayer>)player
                                   completion:(void (^ _Nullable)(void))completion {
    if ( self.isPresentedModalViewControlller )
        return;
    _target = target;
    _targetSuperView = targetSuperView;
    _player = player;
    [self _updateAsset];

    [(id)_player sj_addObserver:self forKeyPath:@"URLAsset"];
    
    if ( !_animator ) {
        [self _initializeTransitionAnimator];
    }
    
    _viewController = [[__SJFitOnScreenViewControlller alloc] init];
    _viewController.player = player;
    __weak typeof(self) _self = self;
    _viewController.dismissExeBlock = ^(__SJFitOnScreenViewControlller * _Nonnull vc) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.viewController = nil;
        self.targetSuperView = nil;
        self.target = nil;
        self.player = nil;
        self.originAsset = nil;
    };
    _animator.modalViewController = _viewController;
    
    _atViewController = [self targetAtViewController];
    [_atViewController presentViewController:_viewController animated:YES completion:completion];
}

- (void)dismissModalViewControlllerCompletion:(nullable void (^)(void))completion {
    if ( !self.isPresentedModalViewControlller )
        return;
    [_player.rotationManager rotate:SJOrientation_Portrait animated:YES completionHandler:^(id<SJRotationManagerProtocol>  _Nonnull mgr) {
        [self->_viewController dismissViewControllerAnimated:YES completion:completion];
    }];
}

- (nullable __kindof UIViewController *)targetAtViewController {
    if ( _targetSuperView == nil ) return nil;
    UIResponder *responder = _targetSuperView.nextResponder;
    while ( ![responder isKindOfClass:[UIViewController class]] ) {
        responder = responder.nextResponder;
        if ( [responder isMemberOfClass:[UIResponder class]] || !responder ) return nil;
    }
    return (__kindof UIViewController *)responder;
}

/// animator

- (void)_initializeTransitionAnimator {
    _animator = [[__SJTransitionAnimator alloc] init];
    
    __weak typeof(self) _self = self;
    [_animator setPresentAnimation:^(__SJTransitionAnimator * _Nonnull animator, id<UIViewControllerContextTransitioning>  _Nonnull transitionContext) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.transitioning = YES;
        self.player.URLAsset.playModel = self.modalVCPlayModel;
        [self.player.controlLayerAppearManager needDisappear];
        
        UIView *containerView = [transitionContext containerView];
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        [containerView addSubview:toView];
        
        toView.backgroundColor = [UIColor clearColor];
        CGRect frame = [self.targetSuperView convertRect:self.target.frame toView:toView];
        self.target.frame = frame;
        [toView addSubview:self.target];
        [self.target mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        
        [UIView animateWithDuration:animator.duration animations:^{
            [toView layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.transitioning = NO;
            [transitionContext completeTransition:YES];
            [self.player.controlLayerAppearManager needAppear];
        }];
    } dismissAnimation:^(__SJTransitionAnimator * _Nonnull animator, id<UIViewControllerContextTransitioning>  _Nonnull transitionContext) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.transitioning = YES;
        self.player.URLAsset.playModel = self.originPlayModel;
        [self.player.controlLayerAppearManager needDisappear];
        
        UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        CGRect frame = [self.targetSuperView.superview convertRect:self.targetSuperView.frame toView:fromView];
        [self.target mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self.targetSuperView);
            make.top.offset(frame.origin.y);
            make.left.offset(frame.origin.x);
        }];
        
        [UIView animateWithDuration:animator.duration animations:^{
            [fromView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.targetSuperView addSubview:self.target];
            [self.target mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.offset(0);
            }];
            self.transitioning = NO;
            [transitionContext completeTransition:YES];
            [self.player.controlLayerAppearManager needAppear];
        }];
    }];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( self.isPresentedModalViewControlller ) {
        [self _updateAsset];
    }
}

- (void)_updateAsset {
    _originAsset = _player.URLAsset;
    _originPlayModel = _player.URLAsset.playModel;
    
    if ( self.isPresentedModalViewControlller ) {
        _player.URLAsset.playModel = _modalVCPlayModel;
    }
}
@end
NS_ASSUME_NONNULL_END
