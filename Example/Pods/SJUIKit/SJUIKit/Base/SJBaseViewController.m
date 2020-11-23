//
//  SJBaseViewController.m
//  SJUIKit_Example
//
//  Created by 畅三江 on 2018/12/23.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "SJBaseViewController.h"
#import "NSObject+SJObserverHelper.h"
#import "SJAppearStateObserver.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJBaseViewController ()
@property (nonatomic) SJAppearState appearState;

- (void)_base_showOrHiddenNavigationBarIfNeeded;
- (void)_base_invokeOnceMethodsIfNeeded;
@end

#pragma mark - 
@implementation SJBaseViewController {
    /// navigation bar
    BOOL _needHiddenNavigationBar;
    
    /// once methods
    BOOL _is_invoked_once_viewDidAppear_method;
    
    /// status base manager
    id<SJStatusBarManager> _sj_base_statusBarManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _sj_base_setupViews];
    // Do any additional setup after loading the view.
}

- (void)_sj_base_setupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.appearState = SJAppearState_WillAppear;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.appearState = SJAppearState_DidAppear;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.appearState = SJAppearState_WillDisappear;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.appearState = SJAppearState_DidDisappear;
}

/// Status bar
- (BOOL)prefersStatusBarHidden {
    if ( !_sj_base_statusBarManager )
        return NO;
    return _sj_base_statusBarManager.prefersStatusBarHidden();
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ( !_sj_base_statusBarManager )
        return UIStatusBarStyleDefault;
    return _sj_base_statusBarManager.preferredStatusBarStyle();
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

/// Show Or Hidden NavigationBar
- (void)_base_showOrHiddenNavigationBarIfNeeded {
    if ( SJAppearState_WillAppear == _appearState ) {
        if ( _needHiddenNavigationBar ) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
        else if ( [self.navigationController isNavigationBarHidden] &&
                  [self.navigationController.viewControllers containsObject:self] ) {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
    }
    else if ( SJAppearState_WillDisappear == _appearState ) {
        /// 是否恢复导航栏显示
        /// - 当前导航栏已隐藏
        /// - 只需考虑`push`的情况
        if ( _needHiddenNavigationBar && !self.presentedViewController ) {
            UIViewController *appear = self.navigationController.childViewControllers.lastObject;
            if ( [appear isKindOfClass:[SJBaseViewController class]] &&
                ((SJBaseViewController *)appear).needHiddenNavigationBar )
                return;
            [self.navigationController setNavigationBarHidden:NO animated:YES]; // 恢复显示
        }
    }
}

- (void)_base_invokeOnceMethodsIfNeeded {
    if ( SJAppearState_DidAppear == _appearState ) {
        if ( !_is_invoked_once_viewDidAppear_method ) {
            [self once_viewDidAppear_method];
        }
    }
}

- (void)setAppearState:(SJAppearState)appearState {
    if ( appearState == _appearState )
        return;
    _appearState = appearState;
    [self _base_showOrHiddenNavigationBarIfNeeded];
    [self _base_invokeOnceMethodsIfNeeded];
}

@end
NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN
@implementation SJBaseViewController (HiddenNavigationBar)
- (void)setNeedHiddenNavigationBar:(BOOL)needHiddenNavigationBar {
    if ( needHiddenNavigationBar == _needHiddenNavigationBar )
        return;
    _needHiddenNavigationBar = needHiddenNavigationBar;
    [self _base_showOrHiddenNavigationBarIfNeeded];
}

- (BOOL)needHiddenNavigationBar {
    return _needHiddenNavigationBar;
}
@end
NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN
@implementation SJBaseViewController (AppearState)
- (id<SJAppearStateObserver>)getAppearStateObserver {
    return [[SJAppearStateObserver alloc] initWithViewController:self];
}
@end
NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN
@implementation SJBaseViewController (Once)
- (void)once_viewDidAppear_method {
    _is_invoked_once_viewDidAppear_method = YES;
}
@end
NS_ASSUME_NONNULL_END


#import "SJStatusBarManager.h"
NS_ASSUME_NONNULL_BEGIN
@implementation SJBaseViewController (StatusBarManager)
- (id<SJStatusBarManager>)statusBarManager {
    if ( _sj_base_statusBarManager )
        return _sj_base_statusBarManager;
    
    return _sj_base_statusBarManager = [SJStatusBarManager new];
}
@end
NS_ASSUME_NONNULL_END
