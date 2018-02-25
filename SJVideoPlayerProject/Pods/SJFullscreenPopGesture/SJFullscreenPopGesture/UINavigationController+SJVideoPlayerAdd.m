//
//  UINavigationController+SJVideoPlayerAdd.m
//  SJBackGR
//
//  Created by BlueDancer on 2017/9/26.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "UINavigationController+SJVideoPlayerAdd.h"
#import <objc/message.h>
#import "UIViewController+SJVideoPlayerAdd.h"
#import "SJScreenshotView.h"
#import <WebKit/WebKit.h>

// MARK: UIViewController

@interface UIViewController (SJExtension)

@property (nonatomic, strong, readonly) SJScreenshotView *SJ_screenshotView;
@property (nonatomic, strong, readonly) NSMutableArray<UIView *> * SJ_snapshotsM;

@end

@implementation UIViewController (SJExtension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL sel[] = {
            @selector(presentViewController:animated:completion:),
            @selector(SJ_presentViewController:animated:completion:),
            @selector(dismissViewControllerAnimated:completion:),
            @selector(SJ_dismissViewControllerAnimated:completion:)
        };
        
        Class class = [self class];
        for ( int i = 0 ; i < sizeof(sel) / sizeof(SEL) ; ++ i ) {
            SEL originalSelector = sel[i];
            SEL swizzledSelector = sel[++ i];
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)SJ_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if ( ![viewControllerToPresent isKindOfClass:[UIAlertController class]] ) SJ_updateScreenshot();
    [self SJ_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)SJ_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ( ![self.modalViewController isKindOfClass:[UIAlertController class]] ) {
        if ( [self isKindOfClass:[UINavigationController class]] &&
            self.presentingViewController ) {
            [self SJ_dumpingScreenshotWithNum:(NSInteger)self.childViewControllers.count];
        }
        else if ( self.navigationController &&
                 self.presentingViewController ) { // nav.child + nav
            [self SJ_dumpingScreenshotWithNum:(NSInteger)self.navigationController.childViewControllers.count + 1];
        }
        else {
            [self SJ_dumpingScreenshotWithNum:1];
        }
    }
#pragma clang diagnostic pop
    // call origin method
    [self SJ_dismissViewControllerAnimated:flag completion:completion];
}

- (void)SJ_dumpingScreenshotWithNum:(NSInteger)num {
    if ( num <= 0 || num >= self.SJ_snapshotsM.count ) return;
    [self.SJ_snapshotsM removeObjectsInRange:NSMakeRange(self.SJ_snapshotsM.count - num, num)];
}

- (SJScreenshotView *)SJ_screenshotView {
    return [[self class] SJ_screenshotView];
}

- (NSMutableArray<UIView *> *)SJ_snapshotsM {
    return [[self class] SJ_snapshotsM];
}

static SJScreenshotView *SJ_screenshotView;
+ (SJScreenshotView *)SJ_screenshotView {
    if ( SJ_screenshotView ) return SJ_screenshotView;
    SJ_screenshotView = [SJScreenshotView new];
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat width = MIN(bounds.size.width, bounds.size.height);
    CGFloat height = MAX(bounds.size.width, bounds.size.height);
    SJ_screenshotView.frame = CGRectMake(0, 0, width, height);
    return SJ_screenshotView;
}

static NSMutableArray<UIView *> * SJ_snapshotsM;
+ (NSMutableArray<UIView *> *)SJ_snapshotsM {
    if ( SJ_snapshotsM ) return SJ_snapshotsM;
    SJ_snapshotsM = [NSMutableArray array];
    return SJ_snapshotsM;
}

static UIWindow *SJ_window;
static inline void SJ_updateScreenshot() {
    if ( !SJ_window ) SJ_window = [(id)[UIApplication sharedApplication].delegate valueForKey:@"window"];
    UIView *view = [SJ_window snapshotViewAfterScreenUpdates:NO];
    if ( view ) [UIViewController.SJ_snapshotsM addObject:view];
}

@end



// MARK: UINavigationController

@interface UINavigationController (SJVideoPlayerAdd)<UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *SJ_pan;
@property (nonatomic, strong, readonly) UIScreenEdgePanGestureRecognizer *SJ_edgePan;
@property (nonatomic, assign, readwrite) SJFullscreenPopGestureType SJ_selectedType;

@end

@interface UINavigationController (SJExtension)<UINavigationControllerDelegate>

@property (nonatomic, assign, readwrite) BOOL SJ_tookOver;

@end


@implementation UINavigationController (SJExtension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL sel[] = {
            @selector(pushViewController:animated:),
            @selector(SJ_pushViewController:animated:),
            @selector(popViewControllerAnimated:),
            @selector(SJ_popViewControllerAnimated:),
            @selector(popToViewController:animated:),
            @selector(SJ_popToViewController:animated:),
            @selector(popToRootViewControllerAnimated:),
            @selector(SJ_popToRootViewControllerAnimated:),
        };
        
        Class nav = [self class];
        for ( int i = 0 ; i < sizeof(sel) / sizeof(SEL) ; ++ i ) {
            SEL originalSelector = sel[i];
            SEL swizzledSelector = sel[++ i];
            Method originalMethod = class_getInstanceMethod(nav, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(nav, swizzledSelector);
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)SJ_navSettings {
    self.SJ_tookOver = YES;
    self.interactivePopGestureRecognizer.enabled = NO;
    self.SJ_selectedType = self.SJ_selectedType;    // need update
    
    // border shadow
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.view.layer.shadowOffset = CGSizeMake(0.5, 0);
    self.view.layer.shadowColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
    self.view.layer.shadowOpacity = 1;
    self.view.layer.shadowRadius = 2;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    [CATransaction commit];
}

// Push
- (void)SJ_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ( self.interactivePopGestureRecognizer &&
        !self.SJ_tookOver ) [self SJ_navSettings];
    SJ_updateScreenshot();
    [self SJ_pushViewController:viewController animated:animated]; // note: If Crash, please confirm that `viewController 'is ` UIViewController'(`UINavigationController` cannot be pushed).
}

// Pop
- (UIViewController *)SJ_popViewControllerAnimated:(BOOL)animated {
    [self SJ_dumpingScreenshotWithNum:1];
    return [self SJ_popViewControllerAnimated:animated];
}

// Pop To RootView Controller
- (NSArray<UIViewController *> *)SJ_popToRootViewControllerAnimated:(BOOL)animated {
    [self SJ_dumpingScreenshotWithNum:(NSInteger)self.childViewControllers.count - 1];
    return [self SJ_popToRootViewControllerAnimated:animated];
}

// Pop To View Controller
- (NSArray<UIViewController *> *)SJ_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( viewController != obj ) return;
        *stop = YES;
        [self SJ_dumpingScreenshotWithNum:(NSInteger)self.childViewControllers.count - 1 - (NSInteger)idx];
    }];
    return [self SJ_popToViewController:viewController animated:animated];
}

- (void)setSJ_tookOver:(BOOL)SJ_tookOver {
    objc_setAssociatedObject(self, @selector(SJ_tookOver), @(SJ_tookOver), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)SJ_tookOver {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end






// MARK: Gesture

@implementation UINavigationController (SJVideoPlayerAdd)

- (UIPanGestureRecognizer *)SJ_pan {
    UIPanGestureRecognizer *SJ_pan = objc_getAssociatedObject(self, _cmd);
    if ( SJ_pan ) return SJ_pan;
    SJ_pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(SJ_handlePanGR:)];
    SJ_pan.delegate = self;
    SJ_pan.delaysTouchesBegan = YES;
    objc_setAssociatedObject(self, _cmd, SJ_pan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return SJ_pan;
}

- (UIScreenEdgePanGestureRecognizer *)SJ_edgePan {
    UIScreenEdgePanGestureRecognizer *SJ_edgePan = objc_getAssociatedObject(self, _cmd);
    if ( SJ_edgePan ) return SJ_edgePan;
    SJ_edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(SJ_handlePanGR:)];
    SJ_edgePan.delegate = self;
    SJ_edgePan.delaysTouchesBegan = YES;
    SJ_edgePan.edges = UIRectEdgeLeft;
    objc_setAssociatedObject(self, _cmd, SJ_edgePan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return SJ_edgePan;
}

- (void)setSJ_selectedType:(SJFullscreenPopGestureType)SJ_selectedType {
    objc_setAssociatedObject(self, @selector(SJ_selectedType), @(SJ_selectedType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    switch ( SJ_selectedType ) {
        case SJFullscreenPopGestureType_EdgeLeft: {
            [self.view addGestureRecognizer:self.SJ_edgePan];
            [self.view removeGestureRecognizer:self.SJ_pan];
        }
            break;
        case SJFullscreenPopGestureType_Full: {
            [self.view addGestureRecognizer:self.SJ_pan];
            [self.view removeGestureRecognizer:self.SJ_edgePan];
        }
            break;
    }
}

- (SJFullscreenPopGestureType)SJ_selectedType {
    return  [objc_getAssociatedObject(self, _cmd) integerValue];
}

#pragma mark -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ( self.topViewController.sj_DisableGestures ||
        [[self valueForKey:@"_isTransitioning"] boolValue] ||
        [self.topViewController.sj_considerWebView canGoBack] ) return NO;
    else if ( self.childViewControllers.count <= 1 ) return NO;
    else return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if ( SJFullscreenPopGestureType_EdgeLeft == self.SJ_selectedType ) return YES;
    if ( [self SJ_isFadeAreaWithPoint:[gestureRecognizer locationInView:gestureRecognizer.view]] ) return NO;
    CGPoint translate = [gestureRecognizer translationInView:self.view];
    if ( translate.x > 0 && 0 == translate.y ) return YES;
    else return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( UIGestureRecognizerStateFailed ==  gestureRecognizer.state ||
         UIGestureRecognizerStateCancelled == gestureRecognizer.state ) return NO;
    else if ( ([otherGestureRecognizer isMemberOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] ||
               [otherGestureRecognizer isMemberOfClass:NSClassFromString(@"UIScrollViewPagingSwipeGestureRecognizer")])
             && [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]] ) {
        return [self SJ_considerScrollView:(UIScrollView *)otherGestureRecognizer.view
                         gestureRecognizer:gestureRecognizer
                    otherGestureRecognizer:otherGestureRecognizer];
    }
    else if ( [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] )  {
        return NO;  // pop手势不触发
    }
    
    // 除 pan 手势, 其他手势同时触发
    return YES;
}

#pragma mark -

- (BOOL)SJ_isFadeAreaWithPoint:(CGPoint)point {
    __block BOOL isFadeArea = NO;
    UIView *view = self.topViewController.view;
    if ( 0 != self.topViewController.sj_fadeArea.count ) {
        [self.topViewController.sj_fadeArea enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect rect = [obj CGRectValue];
            if ( !self.isNavigationBarHidden ) rect = [self.view convertRect:rect fromView:view];
            if ( !CGRectContainsPoint(rect, point) ) return ;
            isFadeArea = YES;
            *stop = YES;
        }];
    }
    
    if ( !isFadeArea &&
         0 != self.topViewController.sj_fadeAreaViews.count ) {
        [self.topViewController.sj_fadeAreaViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect rect = obj.frame;
            if ( !self.isNavigationBarHidden ) rect = [self.view convertRect:rect fromView:view];
            if ( !CGRectContainsPoint(rect, point) ) return ;
            isFadeArea = YES;
            *stop = YES;
        }];
    }
    return isFadeArea;
}

- (BOOL)SJ_considerScrollView:(UIScrollView *)scrollView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer otherGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( [scrollView isKindOfClass:NSClassFromString(@"_UIQueuingScrollView")] ) {
        return [self SJ_considerQueuingScrollView:scrollView gestureRecognizer:gestureRecognizer otherGestureRecognizer:otherGestureRecognizer];
    }
    
    if ( 0 == scrollView.contentOffset.x + scrollView.contentInset.left && !scrollView.decelerating ) {
        [self _sjCancellGesture:otherGestureRecognizer];
        return YES;
    }
    
    return NO;
}

- (BOOL)SJ_considerQueuingScrollView:(UIScrollView *)scrollView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer otherGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    UIPageViewController *pageVC = [self SJ_findingPageViewControllerWithQueueingScrollView:scrollView];

    id<UIPageViewControllerDataSource> dataSource = pageVC.dataSource;
    UIViewController *beforeViewController = nil;
    
    if ( 0 != pageVC.viewControllers.count ) {
        beforeViewController = [dataSource pageViewController:pageVC viewControllerBeforeViewController:pageVC.viewControllers.firstObject];
    }
    
    if ( beforeViewController || scrollView.decelerating ) {
        return NO;
    }
    else {
        [self _sjCancellGesture:otherGestureRecognizer];
        return YES;
    }
}

- (UIPageViewController *)SJ_findingPageViewControllerWithQueueingScrollView:(UIScrollView *)scrollView {
    UIResponder *responder = scrollView.nextResponder;
    while ( ![responder isKindOfClass:[UIPageViewController class]] ) {
        responder = responder.nextResponder;
        if ( [responder isMemberOfClass:[UIResponder class]] || !responder ) { responder = nil; break;}
    }
    return (UIPageViewController *)responder;
}

- (void)SJ_handlePanGR:(UIPanGestureRecognizer *)pan {
    CGFloat offset = [pan translationInView:self.view].x;
    switch ( pan.state ) {
        case UIGestureRecognizerStatePossible: break;
        case UIGestureRecognizerStateBegan: {
            [self SJ_ViewWillBeginDragging:offset];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            [self SJ_ViewDidDrag:offset];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            [self SJ_ViewDidEndDragging:offset];
        }
            break;
    }
}

- (void)SJ_ViewWillBeginDragging:(CGFloat)offset {
    // resign keybord
    [self.view endEditing:YES];
    
    // Move the `screenshot` to the bottom
    [self.view.superview insertSubview:self.SJ_screenshotView atIndex:0];
    
    self.SJ_screenshotView.hidden = NO;
    [self.SJ_screenshotView beginTransitionWithSnapshot:self.SJ_snapshotsM.lastObject];
    if ( self.topViewController.sj_viewWillBeginDragging ) self.topViewController.sj_viewWillBeginDragging(self.topViewController);
    [self SJ_ViewDidDrag:offset];
}

- (void)SJ_ViewDidDrag:(CGFloat)offset {
    if ( offset < 0 ) offset = 0;
    self.view.transform = CGAffineTransformMakeTranslation(offset, 0);
    [self.SJ_screenshotView transitioningWithOffset:offset];
    if ( self.topViewController.sj_viewDidDrag ) self.topViewController.sj_viewDidDrag(self.topViewController);
}

- (void)SJ_ViewDidEndDragging:(CGFloat)offset {
    CGFloat maxWidth = self.view.frame.size.width;
    if ( 0 == maxWidth ) return;
    CGFloat rate = offset / maxWidth;
    CGFloat maxOffset = self.scMaxOffset;
    BOOL pop = rate > maxOffset;
    NSTimeInterval duration = 0.25;
    if ( !pop ) duration = duration * ( offset / (maxOffset * maxWidth) ) + 0.05;
    
    [UIView animateWithDuration:duration animations:^{
        if ( pop ) {
            self.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
            [self.SJ_screenshotView finishedTransition];
        }
        else {
            self.view.transform = CGAffineTransformIdentity;
            [self.SJ_screenshotView reset];
        }
    } completion:^(BOOL finished) {
        if ( pop ) {
            [self popViewControllerAnimated:NO];
            self.view.transform = CGAffineTransformIdentity;
        }
        self.SJ_screenshotView.hidden = YES;
        if ( self.topViewController.sj_viewDidEndDragging ) self.topViewController.sj_viewDidEndDragging(self.topViewController);
    }];
}

- (void)_sjCancellGesture:(UIGestureRecognizer *)gesture {
    [gesture setValue:@(UIGestureRecognizerStateCancelled) forKey:@"state"];
}
@end







// MARK: Settings

@implementation UINavigationController (Settings)

- (void)setSj_gestureType:(SJFullscreenPopGestureType)sj_gestureType {
    self.SJ_selectedType = sj_gestureType;
}

- (SJFullscreenPopGestureType)sj_gestureType {
    return self.SJ_selectedType;
}

- (void)setSj_transitionMode:(SJScreenshotTransitionMode)sj_transitionMode {
    self.SJ_screenshotView.transitionMode = sj_transitionMode;
}

- (SJScreenshotTransitionMode)sj_transitionMode {
    return self.SJ_screenshotView.transitionMode;
}

- (UIGestureRecognizerState)sj_fullscreenGestureState {
    UIGestureRecognizer *gesture = nil;
    switch ( self.SJ_selectedType ) {
        case SJFullscreenPopGestureType_Full:
            gesture = self.SJ_pan;
            break;
        case SJFullscreenPopGestureType_EdgeLeft:
            gesture = self.SJ_edgePan;
            break;
    }
    return gesture.state;
}

- (void)setSj_backgroundColor:(UIColor *)sj_backgroundColor {
    objc_setAssociatedObject(self, @selector(sj_backgroundColor), sj_backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.navigationBar.barTintColor = sj_backgroundColor;
    self.view.backgroundColor = sj_backgroundColor;
}

- (UIColor *)sj_backgroundColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setScMaxOffset:(float)scMaxOffset {
    objc_setAssociatedObject(self, @selector(scMaxOffset), @(scMaxOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)scMaxOffset {
    float offset = [objc_getAssociatedObject(self, _cmd) floatValue];
    if ( 0 == offset ) return 0.35;
    else return offset;
}

@end
