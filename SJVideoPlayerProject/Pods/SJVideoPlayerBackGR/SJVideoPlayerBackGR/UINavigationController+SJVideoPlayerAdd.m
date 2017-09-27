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

static UIImageView *SJVideoPlayer_screenshortImageView;
static NSMutableArray<UIImage *> * SJVideoPlayer_screenshortImagesM;





#pragma mark -

@interface UIViewController (SJVideoPlayerExtension)

@property (class, nonatomic, strong, readonly) UIImageView *SJVideoPlayer_screenshortImageView;
@property (class, nonatomic, strong, readonly) NSMutableArray<UIImage *> * SJVideoPlayer_screenshortImagesM;

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
    NSLog(@"%zd - %s", __LINE__, __func__);
    if ( !self.navigationController ) return;
    
    // rest image
    [self SJVideoPlayer_resetScreenshortImage];
    
    // call origin method
    [self SJVideoPlayer_dismissViewControllerAnimated:flag completion:completion];
}

- (void)SJVideoPlayer_resetScreenshortImage {
    // remove last screenshort
    [[[self class] SJVideoPlayer_screenshortImagesM] removeLastObject];
    // update screenshortImage
    [[[self class] SJVideoPlayer_screenshortImageView] setImage:[[[self class] SJVideoPlayer_screenshortImagesM] lastObject]];
}

+ (UIImageView *)SJVideoPlayer_screenshortImageView {
    if ( SJVideoPlayer_screenshortImageView ) return SJVideoPlayer_screenshortImageView;
    SJVideoPlayer_screenshortImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SJVideoPlayer_screenshortImageView.image = [UIImage imageNamed:@"test.png"];
    return SJVideoPlayer_screenshortImageView;
}

+ (NSMutableArray<UIImage *> *)SJVideoPlayer_screenshortImagesM {
    if ( SJVideoPlayer_screenshortImagesM ) return SJVideoPlayer_screenshortImagesM;
    SJVideoPlayer_screenshortImagesM = [NSMutableArray array];
    return SJVideoPlayer_screenshortImagesM;
}

@end



#pragma mark -




@interface UINavigationController (SJVideoPlayerExtension)

@end

@implementation UINavigationController (SJVideoPlayerExtension)

+ (void)load {
    
    // App launching
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SJVideoPlayer_addscreenshortImageViewToWindow) name:UIApplicationDidFinishLaunchingNotification object:nil];
    
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
+ (void)SJVideoPlayer_addscreenshortImageViewToWindow {
    UIWindow *window = [(id)[UIApplication sharedApplication].delegate valueForKey:@"window"];
    [window insertSubview:self.SJVideoPlayer_screenshortImageView atIndex:0];
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
        self.view.layer.shadowOffset = CGSizeMake(-1, 0);
        self.view.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        self.view.layer.shadowRadius = 1;
        self.view.layer.shadowOpacity = 1;
        
    } repeats:YES] fire];
    return [self SJVideoPlayer_initWithRootViewController:rootViewController];
}


// Push
- (void)SJVideoPlayer_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"%zd - %s", __LINE__, __func__);
    
    // get scrrenshort
    id appDelegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = [appDelegate valueForKey:@"window"];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(window.frame.size.width, window.frame.size.height), YES, 0);
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // add to container
    [[self class].SJVideoPlayer_screenshortImagesM addObject:viewImage];
    // change screenshortImage
    [[self class].SJVideoPlayer_screenshortImageView setImage:viewImage];
    
    
    // call origin method
    [self SJVideoPlayer_pushViewController:viewController animated:animated];
}

// Pop
- (UIViewController *)SJVideoPlayer_popViewControllerAnimated:(BOOL)animated {
    
    NSLog(@"%zd - %s", __LINE__, __func__);
    
    // reset image
    [self SJVideoPlayer_resetScreenshortImage];
    
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
    objc_setAssociatedObject(self, _cmd, pan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return pan;
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
    // call block
    if ( self.topViewController.sj_viewWillBeginDragging ) self.topViewController.sj_viewWillBeginDragging(self.topViewController);
}

- (void)SJVideoPlayer_ViewDidDrag:(CGFloat)offset {
    self.view.transform = CGAffineTransformMakeTranslation(offset, 0);
    
    // call block
    if ( self.topViewController.sj_viewDidDrag ) self.topViewController.sj_viewDidDrag(self.topViewController);
}

- (void)SJVideoPlayer_ViewDidEndDragging:(CGFloat)offset {
    CGFloat rate = offset / self.view.frame.size.width;
    if ( rate < 0.35 ) {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.transform = CGAffineTransformIdentity;
        }];
    }
    else {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
        } completion:^(BOOL finished) {
            [self popViewControllerAnimated:NO];
            self.view.transform = CGAffineTransformIdentity;
        }];
    }
    
    // call block
    if ( self.topViewController.sj_viewDidEndDragging ) self.topViewController.sj_viewDidEndDragging(self.topViewController);
}

@end













