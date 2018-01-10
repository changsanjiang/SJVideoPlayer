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
#import <SJObserverHelper/NSObject+SJObserverHelper.h>

#define SJ_Shift        (-[UIScreen mainScreen].bounds.size.width * 0.382)



#pragma mark -

static SJScreenshotView *SJ_screenshotView;
static NSMutableArray<UIImage *> * SJ_screenshotImagesM;



#pragma mark - UIViewController

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
    if ( [self isKindOfClass:[UIImagePickerController class]] ) {
        if ( 0 != self.childViewControllers.count ) {
            // 由于最顶层的视图还未截取, 所以这里 - 1. 以下相同.
            [self SJ_dumpingScreenshotWithNum:(NSInteger)self.navigationController.childViewControllers.count - 1];
            // reset image
            [self SJ_resetScreenshotImage];
        }
    }
    else if ( self.navigationController && self.presentingViewController ) {
        if ( 0 != self.navigationController.childViewControllers ) {
            [self SJ_dumpingScreenshotWithNum:(NSInteger)self.navigationController.childViewControllers.count - 1];
            [self SJ_resetScreenshotImage];
        }
    }
    
    // call origin method
    [self SJ_dismissViewControllerAnimated:flag completion:completion];
}

- (void)SJ_resetScreenshotImage {
    [[self class] SJ_resetScreenshotImage];
}

static __weak UIWindow *_window;
- (void)SJ_updateScreenshot {
    // get scrrenshort
    if ( !_window ) {
        id appDelegate = [UIApplication sharedApplication].delegate;
        _window = [appDelegate valueForKey:@"window"];
    }
    UIGraphicsBeginImageContextWithOptions(_window.bounds.size, YES, 0);
    [_window drawViewHierarchyInRect:_window.bounds afterScreenUpdates:NO];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // add to container
    [self.SJ_screenshotImagesM addObject:viewImage];
    
    // change screenshotImage
    [self.SJ_screenshotView setImage:viewImage];
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
    SJ_screenshotView.hidden = YES;
    return SJ_screenshotView;
}

+ (NSMutableArray<UIImage *> *)SJ_screenshotImagesM {
    if ( SJ_screenshotImagesM ) return SJ_screenshotImagesM;
    SJ_screenshotImagesM = [NSMutableArray array];
    return SJ_screenshotImagesM;
}

+ (void)SJ_resetScreenshotImage {
    // remove last screenshot
    [self.SJ_screenshotImagesM removeLastObject];
    // update screenshotImage
    [self.SJ_screenshotView setImage:[self.SJ_screenshotImagesM lastObject]];
}

@end



#pragma mark - UINavigationController
@interface UINavigationController (SJExtension)<UINavigationControllerDelegate>

@property (nonatomic, assign, readwrite) BOOL isObserver;

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

- (void)setIsObserver:(BOOL)isObserver {
    objc_setAssociatedObject(self, @selector(isObserver), @(isObserver), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isObserver {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

// App launching
+ (void)SJ_addscreenshotImageViewToWindow {
    UIWindow *window = [(id)[UIApplication sharedApplication].delegate valueForKey:@"window"];
    NSAssert(window, @"Window was not found and cannot continue!");
    [window insertSubview:self.SJ_screenshotView atIndex:0];
}

- (void)SJ_navSettings {
    self.isObserver = YES;
    
    [self.interactivePopGestureRecognizer sj_addObserver:self forKeyPath:@"state"];
    
    // use custom gesture
    self.useNativeGesture = NO;
    
    // border shadow
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    self.view.layer.shadowOffset = CGSizeMake(-1, 0);
    self.view.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
    self.view.layer.shadowRadius = 1;
    self.view.layer.shadowOpacity = 1;
}

// observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIScreenEdgePanGestureRecognizer *)gesture change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    switch ( gesture.state ) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            break;
        default: {
            // update
            self.useNativeGesture = self.useNativeGesture;
        }
            break;
    }
}

// Push
- (void)SJ_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ( self.interactivePopGestureRecognizer &&
        !self.isObserver ) [self SJ_navSettings];
    // push update screenshot
    [self SJ_updateScreenshot];
    // call origin method
    [self SJ_pushViewController:viewController animated:animated];
}

// Pop
- (UIViewController *)SJ_popViewControllerAnimated:(BOOL)animated {
    // reset
    [self SJ_resetScreenshotImage];
    // call origin method
    return [self SJ_popViewControllerAnimated:animated];
}

// Pop To RootView Controller
- (NSArray<UIViewController *> *)SJ_popToRootViewControllerAnimated:(BOOL)animated {
    [self SJ_dumpingScreenshotWithNum:((NSInteger)self.childViewControllers.count - 1) - 1];
    // reset
    [self SJ_resetScreenshotImage];
    return [self SJ_popToRootViewControllerAnimated:animated];
}

// Pop To View Controller
- (NSArray<UIViewController *> *)SJ_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( viewController != obj ) return;
        *stop = YES;
        // 由于数组索引从 0 开始, 所以这里 idx + 1, 以下相同
        [self SJ_dumpingScreenshotWithNum:((NSInteger)self.childViewControllers.count - 1) - ((NSInteger)idx + 1)];
    }];
    // reset
    [self SJ_resetScreenshotImage];
    return [self SJ_popToViewController:viewController animated:animated];
}

@end






#pragma mark - Gesture
@implementation UINavigationController (SJVideoPlayerAdd)

- (UIPanGestureRecognizer *)sj_pan {
    UIPanGestureRecognizer *sj_pan = objc_getAssociatedObject(self, _cmd);
    if ( sj_pan ) return sj_pan;
    sj_pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(SJ_handlePanGR:)];
    [self.view addGestureRecognizer:sj_pan];
    sj_pan.delegate = self;
    objc_setAssociatedObject(self, _cmd, sj_pan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return sj_pan;
}

- (BOOL)isFadeAreaWithPoint:(CGPoint)point {
    if ( !self.topViewController.sj_fadeAreaViews && !self.topViewController.sj_fadeArea ) return NO;
    __block BOOL isFadeArea = NO;
    UIView *view = self.topViewController.view;
    if ( 0 != self.topViewController.sj_fadeArea ) {
        [self.topViewController.sj_fadeArea enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect rect = [self.view convertRect:[obj CGRectValue] fromView:view];
            if ( !CGRectContainsPoint(rect, point) ) return ;
            isFadeArea = YES;
            *stop = YES;
        }];
    }
    
    if ( !isFadeArea && 0 != self.topViewController.sj_fadeAreaViews.count ) {
        [self.topViewController.sj_fadeAreaViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect rect = [self.view convertRect:obj.frame fromView:view];
            if ( !CGRectContainsPoint(rect, point) ) return ;
            isFadeArea = YES;
            *stop = YES;
        }];
    }
    return isFadeArea;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if ( self.childViewControllers.count <= 1 ) return NO;
    if ( [[self.navigationController valueForKey:@"_isTransitioning"] boolValue] ) return NO;
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if ( [self isFadeAreaWithPoint:point] ) return NO;
    
    CGPoint translate = [gestureRecognizer translationInView:self.view];
    BOOL possible = translate.x > 0 && translate.y == 0;
    if ( possible ) return YES;
    else return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isMemberOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] ||
        [otherGestureRecognizer isMemberOfClass:NSClassFromString(@"UIScrollViewPagingSwipeGestureRecognizer")]) {
        if ( [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]] ) {
            return [self SJ_considerScrollView:(UIScrollView *)otherGestureRecognizer.view otherGestureRecognizer:otherGestureRecognizer];
        }
    }
    
    if ( [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIPanGestureRecognizer")] ) {
        return NO;
    }
    return YES;
}

- (BOOL)SJ_considerScrollView:(UIScrollView *)subScrollView otherGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( 0 != subScrollView.contentOffset.x ) return NO;
    
    CGPoint translate = [self.sj_pan translationInView:self.view];
    if ( translate.x <= 0 ) return NO;
    else {
        [otherGestureRecognizer setValue:@(UIGestureRecognizerStateCancelled) forKey:@"state"];
        return YES;
    }
}

- (void)SJ_handlePanGR:(UIPanGestureRecognizer *)pan {
    CGFloat offset = [pan translationInView:self.view].x;
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            [self SJ_ViewWillBeginDragging];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if ( offset < 0 ) return;
            [self SJ_ViewDidDrag:offset];
        }
            break;
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            [self SJ_ViewDidEndDragging:offset];
        }
            break;
    }
}

- (UIScrollView *)SJ_findingPossibleRootScrollView {
    __block UIScrollView *scrollView = nil;
    [self.topViewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( ![obj isKindOfClass:[UIScrollView class]] ) return;
        *stop = YES;
        scrollView = obj;
    }];
    return scrollView;
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
    
    [self SJ_findingPossibleRootScrollView].scrollEnabled = NO;
    
    // begin animation
    self.SJ_screenshotView.transform = CGAffineTransformMakeTranslation(SJ_Shift, 0);
    
    // call block
    if ( self.topViewController.sj_viewWillBeginDragging ) self.topViewController.sj_viewWillBeginDragging(self.topViewController);
}

- (void)SJ_ViewDidDrag:(CGFloat)offset {
    self.view.transform = CGAffineTransformMakeTranslation(offset, 0);
    
    // continuous animation
    CGFloat rate = offset / self.view.frame.size.width;
    self.SJ_screenshotView.transform = CGAffineTransformMakeTranslation(SJ_Shift - SJ_Shift * rate, 0);
    [self.SJ_screenshotView setShadeAlpha:1 - rate];
    
    // call block
    if ( self.topViewController.sj_viewDidDrag ) self.topViewController.sj_viewDidDrag(self.topViewController);
}

- (void)SJ_ViewDidEndDragging:(CGFloat)offset {
    [self SJ_findingPossibleRootScrollView].scrollEnabled = YES;
    
    CGFloat rate = offset / self.view.frame.size.width;
    if ( rate < self.scMaxOffset ) {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.transform = CGAffineTransformIdentity;
            // reset status
            self.SJ_screenshotView.transform = CGAffineTransformMakeTranslation(SJ_Shift, 0);
            [self.SJ_screenshotView setShadeAlpha:1];
        } completion:^(BOOL finished) {
            self.SJ_screenshotView.hidden = YES;
        }];
    }
    else {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
            // finished animation
            self.SJ_screenshotView.transform = CGAffineTransformMakeTranslation(0, 0);
            [self.SJ_screenshotView setShadeAlpha:0.001];
        } completion:^(BOOL finished) {
            [self popViewControllerAnimated:NO];
            self.view.transform = CGAffineTransformIdentity;
            self.SJ_screenshotView.hidden = YES;
        }];
    }
    
    // call block
    if ( self.topViewController.sj_viewDidEndDragging ) self.topViewController.sj_viewDidEndDragging(self.topViewController);
}

@end







#pragma mark - Settings

@implementation UINavigationController (Settings)

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

- (void)setUseNativeGesture:(BOOL)useNativeGesture {
    if ( self.sj_DisableGestures ) return;
    objc_setAssociatedObject(self, @selector(useNativeGesture), @(useNativeGesture), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    switch (self.interactivePopGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:  break;
        default: {
            self.interactivePopGestureRecognizer.enabled = useNativeGesture;
            self.sj_pan.enabled = !useNativeGesture;
        }
            break;
    }
}

- (BOOL)useNativeGesture {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSj_DisableGestures:(BOOL)sj_DisableGestures {
    if ( sj_DisableGestures == self.sj_DisableGestures ) return;
    objc_setAssociatedObject(self, @selector(sj_DisableGestures), @(sj_DisableGestures), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( self.useNativeGesture ) {
        self.interactivePopGestureRecognizer.enabled = !sj_DisableGestures;
    }
    else {
        self.sj_pan.enabled = !sj_DisableGestures;
    }
}

- (BOOL)sj_DisableGestures {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end


