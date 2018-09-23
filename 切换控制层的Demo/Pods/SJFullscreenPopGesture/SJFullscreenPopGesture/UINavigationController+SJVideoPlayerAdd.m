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
#import <WebKit/WebKit.h>
#import "SJSnapshotRecorder.h"

// MARK: UINavigationController

NS_ASSUME_NONNULL_BEGIN
@interface UINavigationController (SJVideoPlayerAdd)
@property (nonatomic, strong, readonly) UIScreenEdgePanGestureRecognizer *SJ_edgePan;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *SJ_pan;
@property (nonatomic) SJFullscreenPopGestureType SJ_selectedType;
@end

@interface UINavigationController (SJExtension)<UINavigationControllerDelegate>
@property (nonatomic) BOOL SJ_tookOver;
@end

@implementation UINavigationController (SJExtension)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class nav = [self class];
        SEL originalSelector = @selector(pushViewController:animated:);
        SEL swizzledSelector = @selector(SJ_pushViewController:animated:);
        Method originalMethod = class_getInstanceMethod(nav, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(nav, swizzledSelector);
        BOOL added = class_addMethod([self class], originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if ( added ) {
            class_replaceMethod([self class], swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }
        else {
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
    [[SJSnapshotServer shared] nav:self pushViewController:viewController];
    [self SJ_pushViewController:viewController animated:animated]; // note: If Crash, please confirm that `viewController 'is ` UIViewController'(`UINavigationController` cannot be pushed).
}

- (void)setSJ_tookOver:(BOOL)SJ_tookOver {
    objc_setAssociatedObject(self, @selector(SJ_tookOver), @(SJ_tookOver), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)SJ_tookOver {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end


// MARK: Gesture

@interface _SJFullscreenGestureDelegate: NSObject<UIGestureRecognizerDelegate>
@property (nonatomic, weak, nullable) UINavigationController *navigationController;
@end

@implementation _SJFullscreenGestureDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ( self.navigationController.topViewController.sj_DisableGestures ||
        [[self.navigationController valueForKey:@"_isTransitioning"] boolValue] ||
        [self.navigationController.topViewController.sj_considerWebView canGoBack] ) return NO;
    else if ( self.navigationController.childViewControllers.count <= 1 ) return NO;
    else if ( [self.navigationController.childViewControllers.lastObject isKindOfClass:[UINavigationController class]] ) return NO;
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if ( SJFullscreenPopGestureType_EdgeLeft == self.navigationController.SJ_selectedType ) return YES;
    if ( [self SJ_isFadeAreaWithPoint:[gestureRecognizer locationInView:gestureRecognizer.view]] ) return NO;
    CGPoint translate = [gestureRecognizer translationInView:self.navigationController.view];
    if ( translate.x > 0 && 0 == translate.y ) return YES;
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( UIGestureRecognizerStateFailed ==  gestureRecognizer.state ||
         UIGestureRecognizerStateCancelled == gestureRecognizer.state ) return NO;
    
    if ( gestureRecognizer == [self.navigationController SJ_edgePan] ) {
        [self _sjCancellGesture:otherGestureRecognizer];
        return YES;
    }
    
    if ( ([otherGestureRecognizer isMemberOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] ||
          [otherGestureRecognizer isMemberOfClass:NSClassFromString(@"UIScrollViewPagingSwipeGestureRecognizer")])
          && [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]] ) {
        return [self SJ_considerScrollView:(UIScrollView *)otherGestureRecognizer.view
                         gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
                    otherGestureRecognizer:otherGestureRecognizer];
    }
    
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if ( [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ) {
        if ( ![otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"_MKMapContentView")] ) {
            return NO;
        }
        
        // consider `MKMapContentView`
        
        if ( (self.navigationController.topViewController.sj_fadeArea || self.navigationController.topViewController.sj_fadeAreaViews)
              && ![self SJ_isFadeAreaWithPoint:point] ) {
            [self _sjCancellGesture:otherGestureRecognizer];
            return YES;
        }
        
        // map view default fade area
        CGRect rect = (CGRect){CGPointMake(50, 0), self.navigationController.view.frame.size};
        if ( ![self rect:rect containerPoint:point] ) {
            [self _sjCancellGesture:otherGestureRecognizer];
            return YES;
        }
        
        return NO;
    }
    
    if ( (self.navigationController.topViewController.sj_fadeArea || self.navigationController.topViewController.sj_fadeAreaViews)
         && ![self SJ_isFadeAreaWithPoint:point] ) {
        [self _sjCancellGesture:otherGestureRecognizer];
        return YES;
    }
    
    return NO;
}

- (BOOL)SJ_isFadeAreaWithPoint:(CGPoint)point {
    __block BOOL isFadeArea = NO;
    if ( 0 != self.navigationController.topViewController.sj_fadeArea.count ) {
        [self.navigationController.topViewController.sj_fadeArea enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( ![self rect:[obj CGRectValue] containerPoint:point] ) return;
            isFadeArea = YES;
            *stop = YES;
        }];
    }
    
    if ( !isFadeArea &&
        0 != self.navigationController.topViewController.sj_fadeAreaViews.count ) {
        [self.navigationController.topViewController.sj_fadeAreaViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( ![self rect:obj.frame containerPoint:point] ) return;
            isFadeArea = YES;
            *stop = YES;
        }];
    }
    return isFadeArea;
}

- (BOOL)rect:(CGRect)rect containerPoint:(CGPoint)point {
    if ( !self.navigationController.isNavigationBarHidden ) rect = [self.navigationController.view convertRect:rect fromView:self.navigationController.topViewController.view];
    return CGRectContainsPoint(rect, point);
}

- (BOOL)SJ_considerScrollView:(UIScrollView *)scrollView gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer otherGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( [scrollView isKindOfClass:NSClassFromString(@"_UIQueuingScrollView")] ) {
        return [self SJ_considerQueuingScrollView:scrollView gestureRecognizer:gestureRecognizer otherGestureRecognizer:otherGestureRecognizer];
    }
    
    CGPoint translate = [gestureRecognizer translationInView:self.navigationController.view];
    if ( 0 == scrollView.contentOffset.x + scrollView.contentInset.left && !scrollView.decelerating && translate.x > 0 && 0 == translate.y ) {
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

- (void)_sjCancellGesture:(UIGestureRecognizer *)gesture {
    [gesture setValue:@(UIGestureRecognizerStateCancelled) forKey:@"state"];
}
@end


@implementation UINavigationController (SJVideoPlayerAdd)
static const char *k_SJFullscreenGestureDelegate = "_SJFullscreenGestureDelegate";
- (_SJFullscreenGestureDelegate *)_sjFullscreenGestureDelegate {
    _SJFullscreenGestureDelegate *delegate = objc_getAssociatedObject(self, k_SJFullscreenGestureDelegate);
    if ( !delegate ) {
        delegate = _SJFullscreenGestureDelegate.new;
        objc_setAssociatedObject(self, k_SJFullscreenGestureDelegate, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (UIPanGestureRecognizer *)SJ_pan {
    UIPanGestureRecognizer *SJ_pan = objc_getAssociatedObject(self, _cmd);
    if ( SJ_pan ) return SJ_pan;
    SJ_pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(SJ_handlePanGR:)];
    SJ_pan.delaysTouchesBegan = YES;
    objc_setAssociatedObject(self, _cmd, SJ_pan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return SJ_pan;
}

- (UIScreenEdgePanGestureRecognizer *)SJ_edgePan {
    UIScreenEdgePanGestureRecognizer *SJ_edgePan = objc_getAssociatedObject(self, _cmd);
    if ( SJ_edgePan ) return SJ_edgePan;
    SJ_edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(SJ_handlePanGR:)];
    SJ_edgePan.delaysTouchesBegan = YES;
    SJ_edgePan.edges = UIRectEdgeLeft;
    objc_setAssociatedObject(self, _cmd, SJ_edgePan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return SJ_edgePan;
}

- (void)setSJ_selectedType:(SJFullscreenPopGestureType)SJ_selectedType {
    _SJFullscreenGestureDelegate *gestureDelegate = [self _sjFullscreenGestureDelegate];
    gestureDelegate.navigationController = self;
    objc_setAssociatedObject(self, @selector(SJ_selectedType), @(SJ_selectedType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    switch ( SJ_selectedType ) {
        case SJFullscreenPopGestureType_EdgeLeft: {
            self.SJ_edgePan.delegate = gestureDelegate;
            self.SJ_pan.delegate = nil;
            [self.view addGestureRecognizer:self.SJ_edgePan];
            [self.view removeGestureRecognizer:self.SJ_pan];
        }
            break;
        case SJFullscreenPopGestureType_Full: {
            self.SJ_edgePan.delegate = nil;
            self.SJ_pan.delegate = gestureDelegate;
            [self.view addGestureRecognizer:self.SJ_pan];
            [self.view removeGestureRecognizer:self.SJ_edgePan];
        }
            break;
    }
}

- (SJFullscreenPopGestureType)SJ_selectedType {
    return  [objc_getAssociatedObject(self, _cmd) integerValue];
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
    [[SJSnapshotServer shared] nav:self preparePopViewController:self.childViewControllers.lastObject];
    if ( self.topViewController.sj_viewWillBeginDragging ) self.topViewController.sj_viewWillBeginDragging(self.topViewController);
    [self SJ_ViewDidDrag:offset];
}

- (void)SJ_ViewDidDrag:(CGFloat)offset {
    if ( offset < 0 ) offset = 0;
    self.view.transform = CGAffineTransformMakeTranslation(offset, 0);
    [[SJSnapshotServer shared] nav:self poppingViewController:self.childViewControllers.lastObject offset:offset];
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
        [[SJSnapshotServer shared] nav:self willEndPopViewController:self.childViewControllers.lastObject pop:pop];
        if ( pop ) {
            self.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
        }
        else {
            self.view.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
        [[SJSnapshotServer shared] nav:self endPopViewController:self.childViewControllers.lastObject];
        if ( pop ) {
            [self popViewControllerAnimated:NO];
            self.view.transform = CGAffineTransformIdentity;
        }
        if ( self.topViewController.sj_viewDidEndDragging ) self.topViewController.sj_viewDidEndDragging(self.topViewController);
    }];
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
    [SJSnapshotServer shared].transitionMode = sj_transitionMode;
}

- (SJScreenshotTransitionMode)sj_transitionMode {
    return [SJSnapshotServer shared].transitionMode;
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

- (void)setSj_backgroundColor:(nullable UIColor *)sj_backgroundColor {
    objc_setAssociatedObject(self, @selector(sj_backgroundColor), sj_backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.navigationBar.barTintColor = sj_backgroundColor;
    self.view.backgroundColor = sj_backgroundColor;
}

- (nullable UIColor *)sj_backgroundColor {
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
NS_ASSUME_NONNULL_END
