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

// MARK:

static SJScreenshotView *SJ_screenshotView;
static NSMutableArray<UIImage *> * SJ_screenshotImagesM;

// MARK: UIViewController

@interface UIViewController (SJExtension)

@property (nonatomic, strong, readonly) SJScreenshotView *SJ_screenshotView;
@property (nonatomic, strong, readonly) NSMutableArray<UIImage *> * SJ_screenshotImagesM;

@end

@implementation UIViewController (SJExtension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class vc = [self class];
        
        // dismiss
        Method dismissViewControllerAnimatedCompletion = class_getInstanceMethod(vc, @selector(dismissViewControllerAnimated:completion:));
        Method SJ_dismissViewControllerAnimatedCompletion = class_getInstanceMethod(vc, @selector(SJ_dismissViewControllerAnimated:completion:));
        
        method_exchangeImplementations(SJ_dismissViewControllerAnimatedCompletion, dismissViewControllerAnimatedCompletion);
    });
}

- (void)SJ_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if ( [self isKindOfClass:[UIImagePickerController class]] ) { /// nav
        [self SJ_dumpingScreenshotWithNum:(NSInteger)self.childViewControllers.count - 1];
    }
    else if ( self.navigationController &&
              self.presentingViewController &&
              0 != self.navigationController.childViewControllers ) {
        [self SJ_dumpingScreenshotWithNum:(NSInteger)self.navigationController.childViewControllers.count];
    }
    
    // call origin method
    [self SJ_dismissViewControllerAnimated:flag completion:completion];
}

static UIWindow *SJ_window;
- (void)SJ_updateScreenshot {
    if ( !SJ_window ) {
        SJ_window = [(id)[UIApplication sharedApplication].delegate valueForKey:@"window"];
        NSAssert(SJ_window, @"Window was not found and cannot continue!");
    }
    UIGraphicsBeginImageContextWithOptions(SJ_window.bounds.size, YES, 0);
    [SJ_window drawViewHierarchyInRect:SJ_window.bounds afterScreenUpdates:NO];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // add to container
    [self.SJ_screenshotImagesM addObject:viewImage];
}

- (void)SJ_dumpingScreenshotWithNum:(NSInteger)num {
    if ( num <= 0 || num >= self.SJ_screenshotImagesM.count ) return;
    [self.SJ_screenshotImagesM removeObjectsInRange:NSMakeRange(self.SJ_screenshotImagesM.count - num, num)];
}

- (SJScreenshotView *)SJ_screenshotView {
    return [[self class] SJ_screenshotView];
}

- (NSMutableArray<UIImage *> *)SJ_screenshotImagesM {
    return [[self class] SJ_screenshotImagesM];
}

+ (SJScreenshotView *)SJ_screenshotView {
    if ( SJ_screenshotView ) return SJ_screenshotView;
    SJ_screenshotView = [SJScreenshotView new];
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat width = MIN(bounds.size.width, bounds.size.height);
    CGFloat height = MAX(bounds.size.width, bounds.size.height);
    SJ_screenshotView.frame = CGRectMake(0, 0, width, height);
    return SJ_screenshotView;
}

+ (NSMutableArray<UIImage *> *)SJ_screenshotImagesM {
    if ( SJ_screenshotImagesM ) return SJ_screenshotImagesM;
    SJ_screenshotImagesM = [NSMutableArray array];
    return SJ_screenshotImagesM;
}

@end



// MARK: UINavigationController
@interface UINavigationController (SJExtension)<UINavigationControllerDelegate>

@property (nonatomic, assign, readwrite) BOOL SJ_tookOver;

@end


@interface UINavigationController (SJVideoPlayerAdd)<UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *SJ_pan;

@end


@implementation UINavigationController (SJExtension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // App launching
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SJ_addscreenshotImageViewToWindow) name:UIApplicationDidFinishLaunchingNotification object:nil];
        
        Class nav = [self class];
        
        // Push
        Method pushViewControllerAnimated = class_getInstanceMethod(nav, @selector(pushViewController:animated:));
        Method SJ_pushViewControllerAnimated = class_getInstanceMethod(nav, @selector(SJ_pushViewController:animated:));
        method_exchangeImplementations(SJ_pushViewControllerAnimated, pushViewControllerAnimated);
        
        // Pop
        Method popViewControllerAnimated = class_getInstanceMethod(nav, @selector(popViewControllerAnimated:));
        Method SJ_popViewControllerAnimated = class_getInstanceMethod(nav, @selector(SJ_popViewControllerAnimated:));
        method_exchangeImplementations(popViewControllerAnimated, SJ_popViewControllerAnimated);
        
        // Pop Root VC
        Method popToRootViewControllerAnimated = class_getInstanceMethod(nav, @selector(popToRootViewControllerAnimated:));
        Method SJ_popToRootViewControllerAnimated = class_getInstanceMethod(nav, @selector(SJ_popToRootViewControllerAnimated:));
        method_exchangeImplementations(popToRootViewControllerAnimated, SJ_popToRootViewControllerAnimated);
        
        // Pop To View Controller
        Method popToViewControllerAnimated = class_getInstanceMethod(nav, @selector(popToViewController:animated:));
        Method SJ_popToViewControllerAnimated = class_getInstanceMethod(nav, @selector(SJ_popToViewController:animated:));
        method_exchangeImplementations(popToViewControllerAnimated, SJ_popToViewControllerAnimated);
    });
}

// App launching
+ (void)SJ_addscreenshotImageViewToWindow {
    UIWindow *window = [(id)[UIApplication sharedApplication].delegate valueForKey:@"window"];
    NSAssert(window, @"Window was not found and cannot continue!");
    [window insertSubview:self.SJ_screenshotView atIndex:0];
    self.SJ_screenshotView.hidden = YES;
}

- (void)SJ_navSettings {
    self.SJ_tookOver = YES;
    self.interactivePopGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:self.SJ_pan];
    
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
    [self SJ_updateScreenshot];
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
    objc_setAssociatedObject(self, _cmd, SJ_pan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return SJ_pan;
}

- (BOOL)SJ_isFadeAreaWithPoint:(CGPoint)point {
    __block BOOL isFadeArea = NO;
    UIView *view = self.topViewController.view;
    if ( 0 != self.topViewController.sj_fadeArea ) {
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ( self.topViewController.sj_DisableGestures ||
         self.childViewControllers.count <= 1 ||
         [[self valueForKey:@"_isTransitioning"] boolValue] ) return NO;
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if ( [self SJ_isFadeAreaWithPoint:[gestureRecognizer locationInView:gestureRecognizer.view]] ) return NO;
    CGPoint translate = [gestureRecognizer translationInView:self.view];
    if ( translate.x > 0 && 0 == translate.y ) return YES;
    else return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( UIGestureRecognizerStateFailed ==  gestureRecognizer.state ||
         UIGestureRecognizerStateCancelled == gestureRecognizer.state ) return YES;
    else if ( ([otherGestureRecognizer isMemberOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] ||
               [otherGestureRecognizer isMemberOfClass:NSClassFromString(@"UIScrollViewPagingSwipeGestureRecognizer")])
            && [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]] ) {
        return [self SJ_considerScrollView:(UIScrollView *)otherGestureRecognizer.view
                         gestureRecognizer:gestureRecognizer
                    otherGestureRecognizer:otherGestureRecognizer];
    }
    else if ( [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ) return NO;
    else return YES;
}

- (BOOL)SJ_considerScrollView:(UIScrollView *)subScrollView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer otherGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( [subScrollView isKindOfClass:NSClassFromString(@"_UIQueuingScrollView")] ) {
        return [self SJ_considerQueuingScrollView:subScrollView gestureRecognizer:gestureRecognizer otherGestureRecognizer:otherGestureRecognizer];
    }
    else if ( 0 != subScrollView.contentOffset.x + subScrollView.contentInset.left ) return NO;
    else if ( [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view].x <= 0 ) return NO;
    else {
        [otherGestureRecognizer setValue:@(UIGestureRecognizerStateCancelled) forKey:@"state"];
        return YES;
    }
}

- (BOOL)SJ_considerQueuingScrollView:(UIScrollView *)scrollView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer otherGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    UIPageViewController *pageVC = [self SJ_findingPageViewControllerWithQueueingScrollView:scrollView];
    if ( !pageVC ) return NO;
    
    id<UIPageViewControllerDataSource> dataSource = pageVC.dataSource;
    if ( !pageVC.dataSource ||
         0 == pageVC.viewControllers.count ) return NO;
    else if ( [dataSource pageViewController:pageVC viewControllerBeforeViewController:pageVC.viewControllers.firstObject] ) {
        [gestureRecognizer setValue:@(UIGestureRecognizerStateCancelled) forKey:@"state"];
        return YES;
    }
    else {
        [otherGestureRecognizer setValue:@(UIGestureRecognizerStateCancelled) forKey:@"state"];
        return NO;
    }
}

- (UIPageViewController *)SJ_findingPageViewControllerWithQueueingScrollView:(UIScrollView *)scrollView {
    UIResponder *responder = scrollView.nextResponder;
    while ( ![responder isKindOfClass:[UIPageViewController class]] ) {
        responder = responder.nextResponder;
        if ( [responder isMemberOfClass:[UIResponder class]] || !responder ) break;
    }
    return (UIPageViewController *)responder;
}

- (void)SJ_handlePanGR:(UIPanGestureRecognizer *)pan {
    CGFloat offset = [pan translationInView:self.view].x;
    switch ( pan.state ) {
        case UIGestureRecognizerStatePossible: break;
        case UIGestureRecognizerStateBegan: {
            [self SJ_ViewWillBeginDragging];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if ( offset < 0 ) return;
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

- (void)SJ_ViewWillBeginDragging {
    // resign keybord
    [self.view endEditing:YES];
    
    // Move the `screenshot` to the bottom of the `obj`.
    UIWindow *window = self.view.window;
    [window.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( [obj isMemberOfClass:NSClassFromString(@"UITransitionView")] ||
             [obj isMemberOfClass:NSClassFromString(@"UILayoutContainerView")] ) {
            *stop = YES;
            [window insertSubview:self.SJ_screenshotView belowSubview:obj];
        }
    }];
    
    self.SJ_screenshotView.hidden = NO;
    [self.SJ_screenshotView setImage:self.SJ_screenshotImagesM.lastObject];
    [self.SJ_screenshotView beginTransition];
    if ( self.topViewController.sj_viewWillBeginDragging ) self.topViewController.sj_viewWillBeginDragging(self.topViewController);
}

- (void)SJ_ViewDidDrag:(CGFloat)offset {
    self.view.transform = CGAffineTransformMakeTranslation(offset, 0);
    [self.SJ_screenshotView transitioningWithOffset:offset];
    if ( self.topViewController.sj_viewDidDrag ) self.topViewController.sj_viewDidDrag(self.topViewController);
}

- (void)SJ_ViewDidEndDragging:(CGFloat)offset {
    CGFloat maxWidth = self.view.frame.size.width;
    if ( 0 == maxWidth ) return;
    CGFloat rate = offset / maxWidth;
    CGFloat maxOffset = self.scMaxOffset;
    BOOL pull = rate > maxOffset;
    NSTimeInterval duration = 0.25;
    if ( !pull ) duration = duration * ( offset / (maxOffset * maxWidth) ) + 0.05;
    
    [UIView animateWithDuration:duration animations:^{
        if ( pull ) {
            self.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
            [self.SJ_screenshotView finishedTransition];
        }
        else {
            self.view.transform = CGAffineTransformIdentity;
            [self.SJ_screenshotView reset];
        }
    } completion:^(BOOL finished) {
        if ( pull ) {
            [self popViewControllerAnimated:NO];
            self.view.transform = CGAffineTransformIdentity;
        }
        self.SJ_screenshotView.hidden = YES;
        if ( self.topViewController.sj_viewDidEndDragging ) self.topViewController.sj_viewDidEndDragging(self.topViewController);
    }];
}

@end







// MARK: Settings

@implementation UINavigationController (Settings)

- (void)setSj_transitionMode:(SJScreenshotTransitionMode)sj_transitionMode {
    self.SJ_screenshotView.transitionMode = sj_transitionMode;
}

- (SJScreenshotTransitionMode)sj_transitionMode {
    return self.SJ_screenshotView.transitionMode;
}

- (UIGestureRecognizerState)sj_fullscreenGestureState {
    return self.SJ_pan.state;
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

