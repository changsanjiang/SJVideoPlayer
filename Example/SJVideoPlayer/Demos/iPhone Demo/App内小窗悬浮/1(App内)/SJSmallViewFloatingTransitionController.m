//
//  SJSmallViewFloatingTransitionController.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2021/1/13.
//  Copyright © 2021 changsanjiang. All rights reserved.
//

#import "SJSmallViewFloatingTransitionController.h"
#import <objc/message.h>
#import "UIView+SJBaseVideoPlayerExtended.h"
#import "NSObject+SJObserverHelper.h"
#import "SJBaseVideoPlayerConst.h"

@interface SJSmallViewFloatingTransitionView : UIView<SJSmallViewFloatingTransitionView>
@property (nonatomic, weak, nullable) SJSmallViewFloatingTransitionController *transitionController;
@end

@implementation SJSmallViewFloatingTransitionView

- (UIView *)containerView {
    return self;
}

@end


@interface SJSmallViewFloatingTransitionControllerObserver : NSObject<SJSmallViewFloatingControllerObserverProtocol>
- (instancetype)initWithController:(id<SJSmallViewFloatingController>)controller;
@end

@implementation SJSmallViewFloatingTransitionControllerObserver
@synthesize onAppearChanged = _onAppearChanged;
@synthesize onEnabled = _onEnabled;
@synthesize controller = _controller;

- (instancetype)initWithController:(id<SJSmallViewFloatingController>)controller {
    self = [super init];
    if ( self ) {
        _controller = controller;
        
        sjkvo_observe(controller, @"isAppeared", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( self.onAppearChanged )
                    self.onAppearChanged(target);
            });
        });
        
        sjkvo_observe(controller, @"enabled", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( self.onEnabled )
                    self.onEnabled(target);
            });
        });
    }
    return self;
}
@end

@interface UINavigationController (SJSmallViewFloatingTransitionControllerExtended)
+ (void)SVTC_initialize;
- (UIViewController *)SVTC_popViewControllerAnimated:(BOOL)animated;
- (void)SVTC_pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)SVTC_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated;
@end

@interface SJSmallViewFloatingTransitionController ()<UIGestureRecognizerDelegate>
@property (nonatomic) BOOL isAppeared;
@property (nonatomic, strong, nullable) UIViewController *playbackViewController;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGesture;
@end

@implementation SJSmallViewFloatingTransitionController
@synthesize enabled = _enabled;
@synthesize slidable = _slidable;
@synthesize floatingViewShouldAppear = _floatingViewShouldAppear;
@synthesize onSingleTapped = _onSingleTapped;
@synthesize onDoubleTapped = _onDoubleTapped;
@synthesize floatingView = _floatingView;
///// - target 为播放器呈现视图
///// - targetSuperview 为播放器视图
///// 当显示小浮窗时, 可以将target添加到小浮窗中
///// 当隐藏小浮窗时, 可以将target恢复到targetSuperview中
@synthesize target = _target;
@synthesize targetSuperview = _targetSuperview;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UINavigationController SVTC_initialize];
    });
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _automaticallyEnterFloatingMode = YES;
        _layoutInsets = UIEdgeInsetsMake(20, 12, 20, 12);
        _layoutPosition = SJSmallViewLayoutPositionBottomRight;
        _enabled = YES;
        self.onSingleTapped = ^(id<SJSmallViewFloatingController>  _Nonnull controller) {
            SJSmallViewFloatingTransitionController *transitionController = (id)controller;
            [transitionController resume];
        };
    }
    return self;
}

- (void)dealloc {
    [_floatingView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
}

- (id<SJSmallViewFloatingControllerObserverProtocol>)getObserver {
    return [[SJSmallViewFloatingTransitionControllerObserver alloc] initWithController:self];
}

- (__kindof UIView *)floatingView {
    if ( _floatingView == nil ) {
        _floatingView = [[SJSmallViewFloatingTransitionView alloc] initWithFrame:CGRectZero];
        [(SJSmallViewFloatingTransitionView *)_floatingView setTransitionController:self];
    }
    return _floatingView;
}

- (void)setAddFloatViewToKeyWindow:(BOOL)addFloatViewToKeyWindow {}
- (BOOL)addFloatViewToKeyWindow { return YES; }

// 进入小浮窗模式
- (void)show {
    [self enterFloatingMode];
}

// 关闭小浮窗
- (void)dismiss {
    if ( !_enabled ) return;
    _playbackViewController = nil;
    self.isAppeared = NO;
}

// - gestures -

- (void)_addGesturesToFloatView:(SJSmallViewFloatingTransitionView *)floatingView {
    if ( self.panGesture.view != floatingView )
        [floatingView addGestureRecognizer:self.panGesture];
}

- (void)setSlidable:(BOOL)slidable {
    self.panGesture.enabled = slidable;
}
- (BOOL)slidable {
    return self.panGesture.enabled;
}

@synthesize panGesture = _panGesture;
- (UIPanGestureRecognizer *)panGesture {
    if ( _panGesture == nil ) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( [otherGestureRecognizer isKindOfClass:UIPanGestureRecognizer.class] ) {
        otherGestureRecognizer.state = UIGestureRecognizerStateCancelled;
        return YES;
    }
    return NO;
}

- (void)_handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    SJSmallViewFloatingTransitionView *view = _floatingView;
    UIView *superview = view.superview;
    CGPoint offset = [panGesture translationInView:superview];
    CGPoint center = view.center;
    view.center = CGPointMake(center.x + offset.x, center.y + offset.y);
    [panGesture setTranslation:CGPointZero inView:superview];
    
    switch ( panGesture.state ) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
                if (@available(iOS 11.0, *)) {
                    if ( !self.ignoreSafeAreaInsets ) safeAreaInsets = superview.safeAreaInsets;
                }

                CGFloat left = safeAreaInsets.left + self.layoutInsets.left;
                CGFloat right = superview.bounds.size.width - view.bounds.size.width - self.layoutInsets.right - safeAreaInsets.right;
                if ( view.frame.origin.x <= left ) {
                    SVTC_setX(view, left);
                }
                else if ( view.frame.origin.x >= right ) {
                    SVTC_setX(view, right);
                }
                
                CGFloat top = safeAreaInsets.top + self.layoutInsets.top;
                CGFloat bottom = superview.bounds.size.height - view.bounds.size.height - self.layoutInsets.bottom - safeAreaInsets.bottom;
                if ( view.frame.origin.y <= top ) {
                    SVTC_setY(view, top);
                }
                else if ( view.frame.origin.y >= bottom ) {
                    SVTC_setY(view, bottom);
                }
            } completion:nil];
        }
            break;
        default: break;
    }
}

UIKIT_STATIC_INLINE void
SVTC_setX(UIView *view, CGFloat x) {
    CGRect frame = view.frame;
    frame.origin.x = x;
    view.frame = frame;
}
 
UIKIT_STATIC_INLINE void
SVTC_setY(UIView *view, CGFloat y) {
    CGRect frame = view.frame;
    frame.origin.y = y;
    view.frame = frame;
}
 
UIKIT_STATIC_INLINE __kindof UIViewController *
SVTC_getTopViewController(void) {
    UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (  [vc isKindOfClass:[UINavigationController class]] ||
             [vc isKindOfClass:[UITabBarController class]] ||
              vc.presentedViewController ) {
        if ( [vc isKindOfClass:[UINavigationController class]] )
            vc = [(UINavigationController *)vc topViewController];
        if ( [vc isKindOfClass:[UITabBarController class]] )
            vc = [(UITabBarController *)vc selectedViewController];
        if ( vc.presentedViewController )
            vc = vc.presentedViewController;
    }
    return vc;
}

#pragma mark -

- (BOOL)enterFloatingMode {
    if ( !_enabled ) return NO;
    if ( _isAppeared ) return YES;

    // 1 获取当前的vc
    // 2 转换到window中的位置
    // 3 退出`playbackViewController`
    // 4 设置转场动画
    
    if ( _floatingViewShouldAppear && !_floatingViewShouldAppear(self) )
        return NO;
    
    // 1.
    UIViewController *viewController = [_targetSuperview lookupResponderForClass:UIViewController.class];
    if ( viewController == nil )
        return NO;
    
    UIViewController *parentViewController = viewController.parentViewController;
    while ( parentViewController != nil && ![parentViewController isKindOfClass:UINavigationController.class] ) {
        viewController = parentViewController;
        parentViewController = parentViewController.parentViewController;
    }
    
    _playbackViewController = viewController;
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if ( _playbackViewController == nil || window == nil )
        return NO;
      
    if ( self.floatingView.superview != window ) {
        // 首次显示, 将floatingView添加到window并设置frame
        [window addSubview:_floatingView];
        [self _addGesturesToFloatView:_floatingView];

        CGRect windowBounds = window.bounds;
        CGFloat windowW = windowBounds.size.width;
        CGFloat windowH = windowBounds.size.height;
        
        UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            if ( !_ignoreSafeAreaInsets ) safeAreaInsets = window.safeAreaInsets;
        }

        //
        CGSize size = _layoutSize;
        CGFloat w = size.width;
        CGFloat h = size.height;
        CGFloat x = 0;
        CGFloat y = 0;
        
        if ( CGSizeEqualToSize(CGSizeZero, size) ) {
            CGFloat maxW = ceil(windowW * 0.48);
            w = maxW > 300.0 ? 300.0 : maxW;
            h = w * 9.0 / 16.0;
        }
        
        switch ( _layoutPosition ) {
            case SJSmallViewLayoutPositionTopLeft:
            case SJSmallViewLayoutPositionBottomLeft:
                x = safeAreaInsets.left + _layoutInsets.left;
                break;
            case SJSmallViewLayoutPositionTopRight:
            case SJSmallViewLayoutPositionBottomRight:
                x = windowW - w - _layoutInsets.right - safeAreaInsets.right;
                break;
        }
          
        switch ( _layoutPosition ) {
            case SJSmallViewLayoutPositionTopLeft:
            case SJSmallViewLayoutPositionTopRight:
                y = safeAreaInsets.top + _layoutInsets.top;
                break;
            case SJSmallViewLayoutPositionBottomLeft:
            case SJSmallViewLayoutPositionBottomRight:
                y = windowH - h - _layoutInsets.bottom - safeAreaInsets.bottom;
                break;
        }

        _floatingView.frame = CGRectMake(x, y, w, h);
        [_floatingView layoutIfNeeded];
    }
    
    // 2.
    CGRect from = [_targetSuperview convertRect:_targetSuperview.bounds toView:_floatingView.containerView];
    [_floatingView.containerView addSubview:_target];
    _target.frame = from;
    [_target layoutSubviews];
    [_target layoutIfNeeded];
    self->_floatingView.hidden = NO;
    [UIView animateWithDuration:0.4 animations:^{
        self->_target.frame = self->_floatingView.containerView.bounds;
        [self->_target layoutSubviews];
        [self->_target layoutIfNeeded];
    }];
    
    self.isAppeared = YES;
    return YES;
}

- (BOOL)resumeMode {
    if ( !_enabled )  return NO;
    if ( !_isAppeared ) return YES;
    
    // 1. push`playbackController`
    // 2. 将播放器添加回去
    
    CGRect to = [_targetSuperview convertRect:_targetSuperview.bounds toView:_floatingView.containerView];
    [UIView animateWithDuration:0.4 animations:^{
        self->_target.frame = to;
        [self->_target layoutSubviews];
        [self->_target layoutIfNeeded];
    } completion:^(BOOL finished) {
        self->_floatingView.hidden = YES;
        
        [self->_targetSuperview addSubview:self->_target];
        self->_target.frame = self->_targetSuperview.bounds;
        [self->_target layoutSubviews];
        [self->_target layoutIfNeeded];
    }];
     
    _playbackViewController = nil;
    self.isAppeared = NO;
    return YES;
}

- (void)resume {
    if ( _playbackViewController == nil )
        return;
    
    UIViewController *topViewController = SVTC_getTopViewController();
    UINavigationController *nav = topViewController.navigationController;
    NSInteger idx = [nav.viewControllers indexOfObject:_playbackViewController];
    if ( idx != NSNotFound ) {
        NSRange range = NSMakeRange(0, idx + 1);
        [nav setViewControllers:[nav.viewControllers subarrayWithRange:range] animated:YES];
    }
    else {
        [nav pushViewController:_playbackViewController animated:YES];
    }
}
@end

UIKIT_STATIC_INLINE SJSmallViewFloatingTransitionController *_Nullable
SVTC_TransitionController(UIViewController *viewController) {
    id ctr = [viewController respondsToSelector:@selector(smallViewFloatingTransitionController)] ? viewController.smallViewFloatingTransitionController : nil;
    return [ctr isKindOfClass:SJSmallViewFloatingTransitionController.class] ? ctr : nil;
}

@implementation UINavigationController (SJSmallViewFloatingTransitionControllerExtended)
UIKIT_STATIC_INLINE void
SVTC_exchangeImplementation(Class cls, SEL originSel, SEL swizzledSel) {
    Method originalMethod = class_getInstanceMethod(cls, originSel);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSel);
    if ( class_addMethod(cls, originSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)) ) {
        class_replaceMethod(cls, swizzledSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)SVTC_initialize {
    Class cls = UINavigationController.class;
    SVTC_exchangeImplementation(cls, @selector(popViewControllerAnimated:), @selector(SVTC_popViewControllerAnimated:));
    SVTC_exchangeImplementation(cls, @selector(pushViewController:animated:), @selector(SVTC_pushViewController:animated:));
    SVTC_exchangeImplementation(cls, @selector(setViewControllers:animated:), @selector(SVTC_setViewControllers:animated:));
}

- (UIViewController *)SVTC_popViewControllerAnimated:(BOOL)animated {
    SJSmallViewFloatingTransitionController *transitionController = SVTC_TransitionController(self.topViewController);
    if ( transitionController != nil && transitionController.automaticallyEnterFloatingMode ) {
        [transitionController enterFloatingMode];
        return [self SVTC_popViewControllerAnimated:animated];
    }
    else {
        UIViewController *vc = [self SVTC_popViewControllerAnimated:animated];
        UIViewController *topViewController = self.topViewController;
        SJSmallViewFloatingTransitionController *transitionController = SVTC_TransitionController(topViewController);
        if ( transitionController != nil ) {
            [transitionController resumeMode];
        }
        return vc;
    }
}

- (void)SVTC_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    SJSmallViewFloatingTransitionController *transitionController = SVTC_TransitionController(viewController);
    if ( transitionController != nil ) {
        [self SVTC_pushViewController:viewController animated:animated];
        [transitionController resumeMode];
    }
    else {
        UIViewController *topViewController = self.topViewController;
        SJSmallViewFloatingTransitionController *transitionController = SVTC_TransitionController(topViewController);
        if ( transitionController != nil && transitionController.automaticallyEnterFloatingMode ) {
            [transitionController enterFloatingMode];
        }
        [self SVTC_pushViewController:viewController animated:animated];
    }
}

- (void)SVTC_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    SJSmallViewFloatingTransitionController *transitionController = SVTC_TransitionController(self.topViewController);
    if ( transitionController != nil ) {
        if ( viewControllers.lastObject != self.topViewController  && transitionController.automaticallyEnterFloatingMode )
            [transitionController enterFloatingMode];
    }
    else {
        SJSmallViewFloatingTransitionController *transitionController = SVTC_TransitionController(viewControllers.lastObject);
        if ( transitionController != nil ) {
            [transitionController resumeMode];
        }
    }
    [self SVTC_setViewControllers:viewControllers animated:animated];
}
@end

@implementation UIWindow (SJSmallViewFloatingTransitionControllerExtended)
- (NSArray<__kindof UIViewController *> *_Nullable)SVTC_playbackInFloatingViewControllers {
    NSMutableArray<__kindof UIViewController *> *_Nullable vcs = nil;
    for ( __kindof UIView * subview in self.subviews ) {
        if ( [subview isKindOfClass:SJSmallViewFloatingTransitionView.class] ) {
            SJSmallViewFloatingTransitionView *containerView = subview;
            UIViewController *playbackViewController = containerView.transitionController.playbackViewController;
            if ( playbackViewController != nil ) {
                if ( vcs == nil ) vcs = [NSMutableArray array];
                [vcs addObject:playbackViewController];
            }
        }
    }
    return vcs.copy;
}
@end
