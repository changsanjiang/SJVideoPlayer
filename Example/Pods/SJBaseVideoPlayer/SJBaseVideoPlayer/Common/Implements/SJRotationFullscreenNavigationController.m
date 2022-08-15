//
//  SJRotationFullscreenNavigationController.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJRotationFullscreenNavigationController.h"
 
@implementation SJRotationFullscreenNavigationController {
    __weak id<SJRotationFullscreenNavigationControllerDelegate> _sj_delegate;
}
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController delegate:(nullable id<SJRotationFullscreenNavigationControllerDelegate>)delegate {
    self = [super initWithRootViewController:rootViewController];
    if ( self ) {
        _sj_delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setNavigationBarHidden:YES animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden { }

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated { }

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}
- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}
- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ( self.viewControllers.count < 1 ) {
        [super pushViewController:viewController animated:animated];
    }
    else if ( [_sj_delegate respondsToSelector:@selector(pushViewController:animated:)] ) {
        [_sj_delegate pushViewController:viewController animated:animated];
    }
}
@end

