//
//  SJViewControllerManager.m
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2019/11/23.
//

#import "SJViewControllerManager.h"
#import "UIView+SJBaseVideoPlayerExtended.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJViewControllerManager ()
@end

@implementation SJViewControllerManager {
    BOOL _tmpShowStatusBar;
    BOOL _tmpHiddenStatusBar;
}
@synthesize viewDisappeared = _viewDisappeared;
@synthesize fitOnScreenManager = _fitOnScreenManager;
@synthesize rotationManager = _rotationManager;
@synthesize controlLayerAppearManager = _controlLayerAppearManager;
@synthesize presentView = _presentView;
@synthesize lockedScreen = _lockedScreen;

- (BOOL)prefersStatusBarHidden {
    if ( _tmpShowStatusBar ) return NO;
    if ( _tmpHiddenStatusBar ) return YES;
    if ( _lockedScreen ) return YES;
    if ( _controlLayerAppearManager.isAppeared ) return NO;
    if ( _rotationManager.isTransitioning ) return NO;
    if ( _fitOnScreenManager.isTransitioning ) return NO;
    
    // 全屏时, 使状态栏根据控制层显示或隐藏
    if ( _rotationManager.isFullscreen || _fitOnScreenManager.isFitOnScreen )
        return !_controlLayerAppearManager.isAppeared;
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ( _rotationManager.isTransitioning || _fitOnScreenManager.isTransitioning )
        return UIStatusBarStyleLightContent;
    
    // 全屏时, 使状态栏变成白色
    if ( _rotationManager.isFullscreen || _fitOnScreenManager.isFitOnScreen )
        return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
}

- (void)viewDidAppear {
    _viewDisappeared = NO;
}

- (void)viewWillDisappear {
    _viewDisappeared = YES;
}

- (void)viewDidDisappear {
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UINavigationController *nav = [_presentView lookupResponderForClass:UINavigationController.class];
    if ( nav == nil ) return;
    [_rotationManager rotate:SJOrientation_Portrait animated:YES completionHandler:^(id<SJRotationManager>  _Nonnull mgr) {
        [nav pushViewController:viewController animated:animated];
    }];
}

- (void)showStatusBar {
    if ( _tmpShowStatusBar ) return;
    _tmpShowStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_tmpShowStatusBar = NO;
    });
}

- (void)hiddenStatusBar {
    if ( _tmpHiddenStatusBar ) return;
    _tmpHiddenStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_tmpHiddenStatusBar = NO;
    });
}

- (void)setNeedsStatusBarAppearanceUpdate {
    [UIApplication.sharedApplication.keyWindow.rootViewController setNeedsStatusBarAppearanceUpdate];
}
@end
NS_ASSUME_NONNULL_END
