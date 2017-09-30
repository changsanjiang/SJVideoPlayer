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


#define SJ_Shift        (-100)


#pragma mark - Timer


@interface NSTimer (SJVideoPlayerExtension)

+ (instancetype)SJVideoPlayer_scheduledTimerWithTimeInterval:(NSTimeInterval)ti exeBlock:(void(^)(NSTimer *timer))block repeats:(BOOL)yesOrNo;

@end


@implementation NSTimer (SJVideoPlayerExtension)

+ (instancetype)SJVideoPlayer_scheduledTimerWithTimeInterval:(NSTimeInterval)ti exeBlock:(void(^)(NSTimer *timer))block repeats:(BOOL)yesOrNo {
    NSAssert(block, @"block 不可为空");
    return [self scheduledTimerWithTimeInterval:ti target:self selector:@selector(SJVideoPlayer_exeTimerEvent:) userInfo:[block copy] repeats:yesOrNo];
}

+ (void)SJVideoPlayer_exeTimerEvent:(NSTimer *)timer {
    void(^block)(NSTimer *timer) = timer.userInfo;
    if ( block ) block(timer);
}

@end


#pragma mark -








#pragma mark -

static SJScreenshotView *SJVideoPlayer_screenshotView;
static NSMutableArray<UIImage *> * SJVideoPlayer_screenshotImagesM;





#pragma mark -

@interface UIViewController (SJVideoPlayerExtension)

@property (class, nonatomic, strong, readonly) SJScreenshotView *SJVideoPlayer_screenshotView;
@property (class, nonatomic, strong, readonly) NSMutableArray<UIImage *> * SJVideoPlayer_screenshotImagesM;

@end

@implementation UIViewController (SJVideoPlayerExtension)

+ (void)load {
    Class vc = [self class];
    
    
    // dismiss
    Method dismissViewControllerAnimatedCompletion = class_getInstanceMethod(vc, @selector(dismissViewControllerAnimated:completion:));
    Method SJVideoPlayer_dismissViewControllerAnimatedCompletion = class_getInstanceMethod(vc, @selector(SJVideoPlayer_dismissViewControllerAnimated:completion:));
    
    method_exchangeImplementations(SJVideoPlayer_dismissViewControllerAnimatedCompletion, dismissViewControllerAnimatedCompletion);
}

- (void)SJVideoPlayer_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    if ( !self.navigationController ) {
        // call origin method
        [self SJVideoPlayer_dismissViewControllerAnimated:flag completion:completion];
        return;
    }
    
    // reset image
    if ( self.presentingViewController ) [self SJVideoPlayer_resetScreenshotImage];
    
    // call origin method
    [self SJVideoPlayer_dismissViewControllerAnimated:flag completion:completion];
}

- (void)SJVideoPlayer_resetScreenshotImage {
    // remove last screenshot
    [[[self class] SJVideoPlayer_screenshotImagesM] removeLastObject];
    // update screenshotImage
    [[[self class] SJVideoPlayer_screenshotView] setImage:[[[self class] SJVideoPlayer_screenshotImagesM] lastObject]];
}

+ (SJScreenshotView *)SJVideoPlayer_screenshotView {
    if ( SJVideoPlayer_screenshotView ) return SJVideoPlayer_screenshotView;
    SJVideoPlayer_screenshotView = [SJScreenshotView new];
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat width = MIN(bounds.size.width, bounds.size.height);
    CGFloat height = MAX(bounds.size.width, bounds.size.height);
    SJVideoPlayer_screenshotView.frame = CGRectMake(0, 0, width, height);
    SJVideoPlayer_screenshotView.transform = CGAffineTransformMakeTranslation(SJ_Shift, 0);
    return SJVideoPlayer_screenshotView;
}

+ (NSMutableArray<UIImage *> *)SJVideoPlayer_screenshotImagesM {
    if ( SJVideoPlayer_screenshotImagesM ) return SJVideoPlayer_screenshotImagesM;
    SJVideoPlayer_screenshotImagesM = [NSMutableArray array];
    return SJVideoPlayer_screenshotImagesM;
}

@end



#pragma mark -




@interface UINavigationController (SJVideoPlayerExtension)

@end

@implementation UINavigationController (SJVideoPlayerExtension)

+ (void)load {
    
    // App launching
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SJVideoPlayer_addscreenshotImageViewToWindow) name:UIApplicationDidFinishLaunchingNotification object:nil];
    
    Class nav = [self class];
    
    // Init
    Method initWithRootViewController = class_getInstanceMethod(nav, @selector(initWithRootViewController:));
    Method SJVideoPlayer_initWithRootViewController = class_getInstanceMethod(nav, @selector(SJVideoPlayer_initWithRootViewController:));
    method_exchangeImplementations(SJVideoPlayer_initWithRootViewController, initWithRootViewController);
    
    // Push
    Method pushViewControllerAnimated = class_getInstanceMethod(nav, @selector(pushViewController:animated:));
    Method SJVideoPlayer_pushViewControllerAnimated = class_getInstanceMethod(nav, @selector(SJVideoPlayer_pushViewController:animated:));
    method_exchangeImplementations(SJVideoPlayer_pushViewControllerAnimated, pushViewControllerAnimated);
    
    
    // Pop
    Method popViewControllerAnimated = class_getInstanceMethod(nav, @selector(popViewControllerAnimated:));
    Method SJVideoPlayer_popViewControllerAnimated = class_getInstanceMethod(nav, @selector(SJVideoPlayer_popViewControllerAnimated:));
    method_exchangeImplementations(popViewControllerAnimated, SJVideoPlayer_popViewControllerAnimated);
}

// App launching
+ (void)SJVideoPlayer_addscreenshotImageViewToWindow {
    UIWindow *window = [(id)[UIApplication sharedApplication].delegate valueForKey:@"window"];
    [window insertSubview:self.SJVideoPlayer_screenshotView atIndex:0];
}


// Init
- (instancetype)SJVideoPlayer_initWithRootViewController:(UIViewController *)rootViewController {
    __weak typeof(rootViewController) _rootViewController = rootViewController;
    [[NSTimer SJVideoPlayer_scheduledTimerWithTimeInterval:0.05 exeBlock:^(NSTimer *timer) {
        if ( !_rootViewController ) { [timer invalidate]; return ; }
        if ( !_rootViewController.navigationController ) return;
        // timer invalidate
        [timer invalidate];
        // get nav
        UINavigationController *nav = _rootViewController.navigationController;
        // 禁用原生手势
        nav.interactivePopGestureRecognizer.enabled = NO;
        // 添加自定义手势
        [nav.view addGestureRecognizer:nav.pan];
        // 添加阴影
        nav.view.layer.shadowOffset = CGSizeMake(-1, 0);
        nav.view.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        nav.view.layer.shadowRadius = 1;
        nav.view.layer.shadowOpacity = 1;
        
    } repeats:YES] fire];
    return [self SJVideoPlayer_initWithRootViewController:rootViewController];
}


// Push
- (void)SJVideoPlayer_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // get scrrenshort
    id appDelegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = [appDelegate valueForKey:@"window"];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(window.frame.size.width, window.frame.size.height), YES, 0);
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // add to container
    [[self class].SJVideoPlayer_screenshotImagesM addObject:viewImage];
    // change screenshotImage
    [[self class].SJVideoPlayer_screenshotView setImage:viewImage];
    
    // call origin method
    [self SJVideoPlayer_pushViewController:viewController animated:animated];
}

// Pop
- (UIViewController *)SJVideoPlayer_popViewControllerAnimated:(BOOL)animated {
    
    // reset image
    [self SJVideoPlayer_resetScreenshotImage];
    
    // call origin method
    return [self SJVideoPlayer_popViewControllerAnimated:animated];
}

@end






#pragma mark -

@implementation UINavigationController (SJVideoPlayerAdd)

- (UIPanGestureRecognizer *)pan {
    UIPanGestureRecognizer *pan = objc_getAssociatedObject(self, _cmd);
    if ( pan ) return pan;
    pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(SJVideoPlayer_handlePanGR:)];
    pan.delegate = self;
    objc_setAssociatedObject(self, _cmd, pan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return pan;
}


- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.view != self.view) return NO;
    CGPoint translate = [gestureRecognizer translationInView:self.view];
    BOOL possible = translate.x != 0 && fabs(translate.y) == 0;
    if ( possible ) return YES;
    else return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] || [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIPanGestureRecognizer")]|| [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPagingSwipeGestureRecognizer")]) {
        UIView *aView = otherGestureRecognizer.view;
        if ( [aView isKindOfClass:[UIScrollView class]] ) {
            return [self SJVideoPlayer_considerScrollView:(UIScrollView *)aView];
        }
        return NO;
    }
    return YES;
}

- (BOOL)SJVideoPlayer_considerScrollView:(UIScrollView *)sv {
    if ( [sv isKindOfClass:[UICollectionView class]] ) {
        UIView *sup = sv.superview;
        if ( [sup isKindOfClass:[UITableViewCell class]] ) return NO;
        // 如果是 TableView 嵌套 CollectionView, 尽量不同时识别.
        for ( int i = 0 ; i < 4; ++ i ) {
            sup = sup.superview;
            if ( [sup isKindOfClass:[UITableViewCell class]] ) return NO;
        }
    }
    if ( sv.contentOffset.x == 0 ) return YES;
    return NO;
}

- (void)SJVideoPlayer_handlePanGR:(UIPanGestureRecognizer *)pan {
    if ( self.childViewControllers.count <= 1 ) return;
    
    CGFloat offset = [pan translationInView:self.view].x;
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            [self SJVideoPlayer_ViewWillBeginDragging];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            // 如果从右往左滑
            if ( offset < 0 ) return;
            [self SJVideoPlayer_ViewDidDrag:offset];
        }
            break;
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            [self SJVideoPlayer_ViewDidEndDragging:offset];
        }
            break;
    }
}

- (void)SJVideoPlayer_ViewWillBeginDragging {
    [self.view endEditing:YES];
    
    // call block
    if ( self.topViewController.sj_viewWillBeginDragging ) self.topViewController.sj_viewWillBeginDragging(self.topViewController);
    
    
    // begin animation
    
}

- (void)SJVideoPlayer_ViewDidDrag:(CGFloat)offset {
    self.view.transform = CGAffineTransformMakeTranslation(offset, 0);
    
    // call block
    if ( self.topViewController.sj_viewDidDrag ) self.topViewController.sj_viewDidDrag(self.topViewController);
    
    // continuous animation
    CGFloat rate = offset / self.view.frame.size.width;
    [[self class] SJVideoPlayer_screenshotView].transform = CGAffineTransformMakeTranslation(SJ_Shift - SJ_Shift * rate, 0);
    [[[self class] SJVideoPlayer_screenshotView] setShadeAlpha:1 - rate];
}

- (void)SJVideoPlayer_ViewDidEndDragging:(CGFloat)offset {
    CGFloat rate = offset / self.view.frame.size.width;
    if ( rate < self.scMaxOffset ) {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.transform = CGAffineTransformIdentity;
            
            // reset status
            [[self class] SJVideoPlayer_screenshotView].transform = CGAffineTransformMakeTranslation(SJ_Shift, 0);
            [[[self class] SJVideoPlayer_screenshotView] setShadeAlpha:1];
        }];
    }
    else {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
            
            // finished animation
            [[self class] SJVideoPlayer_screenshotView].transform = CGAffineTransformMakeTranslation(0, 0);
            [[[self class] SJVideoPlayer_screenshotView] setShadeAlpha:0.001];
        } completion:^(BOOL finished) {
            [self popViewControllerAnimated:NO];
            self.view.transform = CGAffineTransformIdentity;
        }];
    }

    // call block
    if ( self.topViewController.sj_viewDidEndDragging ) self.topViewController.sj_viewDidEndDragging(self.topViewController);
    
}

@end







#pragma mark - Settings

@implementation UINavigationController (Settings)

- (void)setScMaxOffset:(float)scMaxOffset {
    objc_setAssociatedObject(self, @selector(scMaxOffset), @(scMaxOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)scMaxOffset {
    float offset = [objc_getAssociatedObject(self, _cmd) floatValue];
    if ( 0 == offset ) return 0.35;
    return offset;
}

@end





