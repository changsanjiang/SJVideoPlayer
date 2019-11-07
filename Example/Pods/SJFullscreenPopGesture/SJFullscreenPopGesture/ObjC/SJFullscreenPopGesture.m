//
//  SJFullscreenPopGesture.m
//  SJBackGRProject
//
//  Created by 畅三江 on 2019/7/17.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJFullscreenPopGesture.h"
#import <objc/message.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJFullscreenPopGestureDelegate : NSObject<UIGestureRecognizerDelegate>
+ (instancetype)shared;
@end

@implementation SJFullscreenPopGestureDelegate
+ (instancetype)shared {
    static SJFullscreenPopGestureDelegate *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = SJFullscreenPopGestureDelegate.alloc.init;
    });
    return instance;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UINavigationController *_Nullable nav = [self _lookupResponder:gestureRecognizer.view class:UINavigationController.class];
    
    if ( nav == nil )
        return false;
    
    if ( nav.childViewControllers.count <= 1 )
        return false;
    
    if ( [[nav valueForKey:@"isTransitioning"] boolValue] )
        return false;
    
    if ( nav.topViewController.sj_disableFullscreenGesture )
        return false;
    
    if ( [self _blindAreaContains:nav point:[touch locationInView:nav.view]] )
        return false;
    
    if ( [nav.childViewControllers.lastObject isKindOfClass:UINavigationController.class] )
        return false;
    
    if ( nav.topViewController.sj_considerWebView )
        return !nav.topViewController.sj_considerWebView.canGoBack;
    
    return true;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if ( SJFullscreenPopGesture.gestureType == SJFullscreenPopGestureTypeEdgeLeft )
        return true;
    
    CGPoint translate = [gestureRecognizer translationInView:gestureRecognizer.view];
    
    if ( translate.x > 0 && translate.y == 0 )
        return true;
    
    return false;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ( gestureRecognizer.state == UIGestureRecognizerStateFailed ||
         gestureRecognizer.state == UIGestureRecognizerStateCancelled )
        return false;
    
    if ( SJFullscreenPopGesture.gestureType == SJFullscreenPopGestureTypeEdgeLeft ) {
        [self _cancelGesture:otherGestureRecognizer];
        return true;
    }

    UINavigationController *nav = [self _lookupResponder:gestureRecognizer.view class:UINavigationController.class];

    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    
    if ( [self _blindAreaContains:nav point:location] )
        return false;
    
    if ( [otherGestureRecognizer isMemberOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] ||
         [otherGestureRecognizer isMemberOfClass:NSClassFromString(@"UIScrollViewPagingSwipeGestureRecognizer")] ) {
        if ( [otherGestureRecognizer.view isKindOfClass:UIScrollView.class] ) {
            return [self _shouldRecognizeSimultaneously:(id)otherGestureRecognizer.view gestureRecognizer:gestureRecognizer otherGestureRecognizer:otherGestureRecognizer];
        }
    }
    
    if ( [otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"_MKMapContentView")] ||
         [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIWebTouchEventsGestureRecognizer")] ) {
        if ( [self _edgeAreaContains:nav point:location] ) {
            [self _cancelGesture:otherGestureRecognizer];
            return true;
        }
        else
            return false;
    }

    if ( [otherGestureRecognizer isKindOfClass:UIPanGestureRecognizer.class] )
        return false;

    return false;
}

- (BOOL)_shouldRecognizeSimultaneously:(UIScrollView *)scrollView gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer otherGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    if ( [scrollView isKindOfClass:NSClassFromString(@"_UIQueuingScrollView")] ) {
        if ( scrollView.isDecelerating )
            return false;
        
        UIPageViewController *pageVC = [self _lookupResponder:scrollView class:UIPageViewController.class];
        
        if ( pageVC.viewControllers.count == 0 )
            return false;
        
        if ( [pageVC.dataSource pageViewController:pageVC viewControllerBeforeViewController:pageVC.viewControllers.firstObject] != nil )
            return false;
        
        [self _cancelGesture:otherGestureRecognizer];
        
        return true;
    }
    
    CGPoint translate = [gestureRecognizer translationInView:gestureRecognizer.view];
    
    if ( 0 == scrollView.contentOffset.x + scrollView.contentInset.left
        && !scrollView.isDecelerating
        && translate.x > 0 && 0 == translate.y ) {
        [self _cancelGesture:otherGestureRecognizer];
        return true;
    }
    
    return false;
}

// --

- (nullable __kindof UIResponder *)_lookupResponder:(UIView *)view class:(Class)cls {
    __kindof UIResponder *_Nullable next = view.nextResponder;
    while ( next != nil && [next isKindOfClass:cls] == NO ) {
        next = next.nextResponder;
    }
    return next;
}

- (void)_cancelGesture:(UIGestureRecognizer *)gesture {
    [gesture setValue:@(UIGestureRecognizerStateCancelled) forKey:@"state"];
}

- (BOOL)_edgeAreaContains:(UINavigationController *)nav point:(CGPoint)point {
    CGFloat offset = 50;
    CGRect rect = CGRectMake(0, 0, offset, nav.view.bounds.size.height);
    
    return [self _rectContains:nav rect:rect point:point shouldConvertRect:NO];
}

- (BOOL)_blindAreaContains:(UINavigationController *)nav point:(CGPoint)point {
    for ( NSValue *rect in nav.topViewController.sj_blindArea ) {
        if ( [self _rectContains:nav rect:[rect CGRectValue] point:point shouldConvertRect:YES] )
            return true;
    }
    
    for ( UIView *view in nav.topViewController.sj_blindAreaViews ) {
        if ( [self _rectContains:nav rect:[view frame] point:point shouldConvertRect:YES] )
            return true;
    }
    
    return false;
}

- (BOOL)_rectContains:(UINavigationController *)nav rect:(CGRect)rect point:(CGPoint)point shouldConvertRect:(BOOL)shouldConvert {
    
    if ( shouldConvert ) {
        rect = [nav.topViewController.view convertRect:rect toView:nav.view];
    }
    
    return CGRectContainsPoint(rect, point);
}
@end


#pragma mark -

@interface SJSnapshot : NSObject
- (instancetype)initWithTarget:(UIViewController *)target;
@end

@interface SJSnapshot ()
@property (nonatomic, weak, readonly, nullable) UIViewController *target;
@property (nonatomic, strong, readonly) UIView *rootView;
@property (nonatomic, strong, nullable) UIView *maskView;
@end

@implementation SJSnapshot
- (instancetype)initWithTarget:(UIViewController *)target {
    self = [super init];
    if ( self ) {
        // target
        _target = target;
        
        // nav
        UINavigationController *nav = target.navigationController;
        _rootView = [[UIView alloc] initWithFrame:nav.view.bounds];
        _rootView.backgroundColor = UIColor.whiteColor;
        
        // snapshot
        switch ( target.sj_displayMode ) {
            case SJPreViewDisplayModeSnapshot: {
                UIView *superview = nav.tabBarController != nil ? nav.tabBarController.view : nav.view;
                UIView *snapshot = [superview snapshotViewAfterScreenUpdates:NO];
                [_rootView addSubview:snapshot];
            }
                break;
            case SJPreViewDisplayModeOrigin: {
                if ( nav.isNavigationBarHidden == false ) {
                    CGRect rect = [nav.view convertRect:nav.navigationBar.frame toView:nav.view.window];
                    rect.size.height += rect.origin.y + 1;
                    rect.origin.y = 0;
                    UIView *navbarSnapshot = [nav.view.superview resizableSnapshotViewFromRect:rect afterScreenUpdates:false withCapInsets:UIEdgeInsetsZero];
                    [_rootView addSubview:navbarSnapshot];
                }
                
                
                UITabBar *tabBar = nav.tabBarController.tabBar;
                if ( tabBar.isHidden == false ) {
                    CGRect rect = [tabBar convertRect:tabBar.bounds toView:nav.view.window];
                    rect.origin.y -= 1;
                    rect.size.height += 1;
                    UIView *snapshot = [nav.view.window resizableSnapshotViewFromRect:rect afterScreenUpdates:false withCapInsets:UIEdgeInsetsZero];
                    snapshot.frame = rect;
                    [_rootView addSubview:snapshot];
                }
            }
                break;
        }
        
        // mask
        if ( SJFullscreenPopGesture.transitionMode == SJFullscreenPopGestureTransitionModeMaskAndShifting ) {
            _maskView = [[UIView alloc] initWithFrame:_rootView.bounds];
            _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
            [_rootView addSubview:_maskView];
        }
    }
    return self;
}

- (void)began {
    if ( _target.sj_displayMode == SJPreViewDisplayModeOrigin ) {
        [_rootView insertSubview:_target.view atIndex:0];
    }
}

- (void)completed {
    if ( _target.sj_displayMode == SJPreViewDisplayModeOrigin &&
         _target.view.superview == _rootView ) {
        [_target.view removeFromSuperview];
    }
}

@end


#pragma mark -

@interface UIViewController (_SJFullscreenPopGesturePrivate)
@property (nonatomic, strong, nullable) SJSnapshot *sj_previousViewControllerSnapshot;
@end

@implementation UIViewController (_SJFullscreenPopGesturePrivate)
- (void)setSj_previousViewControllerSnapshot:(nullable SJSnapshot *)sj_previousViewControllerSnapshot {
    objc_setAssociatedObject(self, @selector(sj_previousViewControllerSnapshot), sj_previousViewControllerSnapshot, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable SJSnapshot *)sj_previousViewControllerSnapshot {
    return objc_getAssociatedObject(self, _cmd);
}
@end


#pragma mark -

@interface SJTransitionHandler : NSObject
+ (instancetype)shared;

@property (nonatomic) CGFloat shift;
@end

@implementation SJTransitionHandler
+ (instancetype)shared {
    static SJTransitionHandler *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = SJTransitionHandler.alloc.init;
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _shift = - UIScreen.mainScreen.bounds.size.width * 0.382;
    }
    return self;
}

- (void)pushWithNav:(UINavigationController *)nav viewController:(UIViewController *)viewController {
    UIViewController *last = nav.childViewControllers.lastObject;
    if ( last != nil ) {
        viewController.sj_previousViewControllerSnapshot = [SJSnapshot.alloc initWithTarget:last];
    }
}

- (void)beganWithNav:(UINavigationController *)nav viewController:(UIViewController *)viewController offset:(CGFloat)offset {
    SJSnapshot *snapshot = viewController.sj_previousViewControllerSnapshot;
    if ( snapshot == nil )
        return;
    
    // keyboard
    [nav.view endEditing:YES];
    [nav.view.superview insertSubview:snapshot.rootView belowSubview:nav.view];
    
    //
    [snapshot began];
    
    snapshot.rootView.transform = CGAffineTransformMakeTranslation(self.shift, 0);
    
    if ( SJFullscreenPopGesture.transitionMode == SJFullscreenPopGestureTransitionModeMaskAndShifting ) {
        snapshot.maskView.alpha = 1;
        CGFloat width = snapshot.rootView.frame.size.width;
        snapshot.maskView.transform = CGAffineTransformMakeTranslation(-(self.shift + width), 0);
    }
    
    //
    if ( viewController.sj_viewWillBeginDragging ) {
        viewController.sj_viewWillBeginDragging(viewController);
    }
    
    [self changedWithNav:nav viewController:viewController offset:offset];
}

- (void)changedWithNav:(UINavigationController *)nav viewController:(UIViewController *)viewController offset:(CGFloat)offset {
    SJSnapshot *snapshot = viewController.sj_previousViewControllerSnapshot;
    if ( snapshot == nil )
        return;

    if ( offset < 0 ) offset = 0;
    
    //
    nav.view.transform = CGAffineTransformMakeTranslation(offset, 0);
    
    //
    CGFloat width = snapshot.rootView.frame.size.width;
    CGFloat rate = offset / width;
    
    snapshot.rootView.transform = CGAffineTransformMakeTranslation(self.shift * ( 1 - rate), 0);
    
    if ( SJFullscreenPopGesture.transitionMode == SJFullscreenPopGestureTransitionModeMaskAndShifting ) {
        snapshot.maskView.alpha = 1 - rate;
        snapshot.maskView.transform = CGAffineTransformMakeTranslation(-(self.shift + width) + (self.shift *rate) + offset, 0);
    }
    
    //
    if ( viewController.sj_viewDidDrag ) {
        viewController.sj_viewDidDrag(viewController);
    }
}

- (void)completedWithNav:(UINavigationController *)nav viewController:(UIViewController *)viewController offset:(CGFloat)offset {
    SJSnapshot *snapshot = viewController.sj_previousViewControllerSnapshot;
    if ( snapshot == nil )
        return;
    
    CGFloat screenwidth = nav.view.frame.size.width;
    CGFloat rate = offset / screenwidth;
    CGFloat maxOffset = SJFullscreenPopGesture.maxOffsetToTriggerPop;
    BOOL shouldPop = rate > maxOffset;
    CGFloat animDuration = 0.25;
    
    if ( shouldPop == false ) {
        animDuration = animDuration * ( offset / (maxOffset * screenwidth) ) + 0.05;
    }
    
    [UIView animateWithDuration:animDuration animations:^{
        if ( shouldPop == true ) {
            snapshot.rootView.transform = CGAffineTransformIdentity;
            snapshot.maskView.transform = CGAffineTransformIdentity;
            snapshot.maskView.alpha = 0.001;
            
            nav.view.transform = CGAffineTransformMakeTranslation(screenwidth, 0);
        }
        else {
            snapshot.maskView.transform = CGAffineTransformMakeTranslation(-(self.shift + screenwidth), 0);
            snapshot.maskView.alpha = 1;
            
            nav.view.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
        [snapshot.rootView removeFromSuperview];
        [snapshot completed];
        
        if ( shouldPop == true ) {
            nav.view.transform = CGAffineTransformIdentity;
            [nav popViewControllerAnimated:false];
        }
        
        if ( viewController.sj_viewDidEndDragging ) {
            viewController.sj_viewDidEndDragging(viewController);
        }
    }];
}
@end


#pragma mark -

@interface UINavigationController (_SJFullscreenPopGesturePrivate)
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *sj_fullscreenGesture;
@end

@implementation UINavigationController (_SJFullscreenPopGesturePrivate)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = UINavigationController.class;
        SEL originalSelector = @selector(pushViewController:animated:);
        SEL swizzledSelector = @selector(sj_pushViewController:animated:);
        
        Method originalMethod = class_getInstanceMethod(cls, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)sj_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self sj_setupIfNeeded];
    [SJTransitionHandler.shared pushWithNav:self viewController:viewController];
    [self sj_pushViewController:viewController animated:animated];
}

- (void)sj_setupIfNeeded {
    if ( self.interactivePopGestureRecognizer == nil )
        return;
    
    if ( [objc_getAssociatedObject(self, _cmd) boolValue] )
        return;
    
    objc_setAssociatedObject(self, _cmd, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.interactivePopGestureRecognizer.enabled = false;
    self.view.clipsToBounds = false;
    
    [CATransaction begin];
    [CATransaction setDisableActions:true];
    self.view.layer.shadowOffset = CGSizeMake(0.5, 0);
    self.view.layer.shadowColor = [[UIColor alloc] initWithWhite:0.2 alpha:1].CGColor;
    self.view.layer.shadowOpacity = 1;
    self.view.layer.shadowRadius = 2;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    [CATransaction commit];
    
    [self.view addGestureRecognizer:self.sj_fullscreenGesture];
}

- (UIPanGestureRecognizer *)sj_fullscreenGesture {
    UIPanGestureRecognizer *_Nullable gesture = objc_getAssociatedObject(self, _cmd);
    if ( gesture == nil ) {
        if ( SJFullscreenPopGesture.gestureType == SJFullscreenPopGestureTypeEdgeLeft ) {
            gesture = UIScreenEdgePanGestureRecognizer.alloc.init;
            [(UIScreenEdgePanGestureRecognizer *)gesture setEdges:UIRectEdgeLeft];
        }
        else {
            gesture = UIPanGestureRecognizer.alloc.init;
        }
        
        gesture.delaysTouchesBegan = YES;
        gesture.delegate = SJFullscreenPopGestureDelegate.shared;
        [gesture addTarget:self action:@selector(sj_handleFullscreenGesture:)];
        objc_setAssociatedObject(self, _cmd, gesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return gesture;
}

- (void)sj_handleFullscreenGesture:(UIPanGestureRecognizer *)gesture {
    CGFloat offset = [gesture translationInView:gesture.view].x;
    switch ( gesture.state ) {
        case UIGestureRecognizerStateBegan:
            [SJTransitionHandler.shared beganWithNav:self viewController:self.topViewController offset:offset];
            break;
        case UIGestureRecognizerStateChanged:
            [SJTransitionHandler.shared changedWithNav:self viewController:self.topViewController offset:offset];
            break;
        case UIGestureRecognizerStateEnded: case UIGestureRecognizerStateCancelled: case UIGestureRecognizerStateFailed:
            [SJTransitionHandler.shared completedWithNav:self viewController:self.topViewController offset:offset];
            break;
        case UIGestureRecognizerStatePossible:
            break;
    }
}
@end


#pragma mark -

@implementation SJFullscreenPopGesture
static SJFullscreenPopGestureType _gestureType = SJFullscreenPopGestureTypeEdgeLeft;
+ (void)setGestureType:(SJFullscreenPopGestureType)gestureType {
    _gestureType = gestureType;
}
+ (SJFullscreenPopGestureType)gestureType {
    return _gestureType;
}

static SJFullscreenPopGestureTransitionMode _transitionMode = SJFullscreenPopGestureTransitionModeShifting;
+ (void)setTransitionMode:(SJFullscreenPopGestureTransitionMode)transitionMode {
    _transitionMode = transitionMode;
}
+ (SJFullscreenPopGestureTransitionMode)transitionMode {
    return _transitionMode;
}

static CGFloat _maxOffsetToTriggerPop = 0.35;
+ (void)setMaxOffsetToTriggerPop:(CGFloat)maxOffsetToTriggerPop {
    _maxOffsetToTriggerPop = maxOffsetToTriggerPop;
}
+ (CGFloat)maxOffsetToTriggerPop {
    return _maxOffsetToTriggerPop;
}
@end


#pragma mark -

@implementation UIViewController (SJExtendedFullscreenPopGesture)
- (void)setSj_displayMode:(SJPreViewDisplayMode)sj_displayMode {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    objc_setAssociatedObject(self, @selector(sj_displayMode), @(sj_displayMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (SJPreViewDisplayMode)sj_displayMode {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setSj_disableFullscreenGesture:(BOOL)sj_disableFullscreenGesture {
    objc_setAssociatedObject(self, @selector(sj_disableFullscreenGesture), @(sj_disableFullscreenGesture), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)sj_disableFullscreenGesture {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSj_blindArea:(nullable NSArray<NSValue *> *)sj_blindArea {
    objc_setAssociatedObject(self, @selector(sj_blindArea), sj_blindArea, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (nullable NSArray<NSValue *> *)sj_blindArea {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_blindAreaViews:(nullable NSArray<UIView *> *)sj_blindAreaViews {
    objc_setAssociatedObject(self, @selector(sj_blindAreaViews), sj_blindAreaViews, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (nullable NSArray<UIView *> *)sj_blindAreaViews {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_viewWillBeginDragging:(void (^_Nullable)(__kindof UIViewController * _Nonnull))sj_viewWillBeginDragging {
    objc_setAssociatedObject(self, @selector(sj_viewWillBeginDragging), sj_viewWillBeginDragging, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^_Nullable)(__kindof UIViewController * _Nonnull))sj_viewWillBeginDragging {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_viewDidDrag:(void (^_Nullable)(__kindof UIViewController * _Nonnull))sj_viewDidDrag {
    objc_setAssociatedObject(self, @selector(sj_viewDidDrag), sj_viewDidDrag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^_Nullable)(__kindof UIViewController * _Nonnull))sj_viewDidDrag {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_viewDidEndDragging:(void (^_Nullable)(__kindof UIViewController * _Nonnull))sj_viewDidEndDragging {
    objc_setAssociatedObject(self, @selector(sj_viewDidEndDragging), sj_viewDidEndDragging, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^_Nullable)(__kindof UIViewController * _Nonnull))sj_viewDidEndDragging {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_considerWebView:(nullable WKWebView *)sj_considerWebView {
    sj_considerWebView.allowsBackForwardNavigationGestures = YES;
    objc_setAssociatedObject(self, @selector(sj_considerWebView), sj_considerWebView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable WKWebView *)sj_considerWebView {
    return objc_getAssociatedObject(self, _cmd);
}

@end

#pragma mark -
@implementation UINavigationController (SJExtendedFullscreenPopGesture)
- (UIGestureRecognizerState)sj_fullscreenGestureState {
    return self.sj_fullscreenGesture.state;
}
@end
NS_ASSUME_NONNULL_END
