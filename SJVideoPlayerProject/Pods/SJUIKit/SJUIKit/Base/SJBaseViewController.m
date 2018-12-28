//
//  SJBaseViewController.m
//  SJUIKit_Example
//
//  Created by 畅三江 on 2018/12/23.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "SJBaseViewController.h"
#import <SJObserverHelper/NSObject+SJObserverHelper.h>
#import "SJAppearStateObserver.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJBaseViewController ()
@property (nonatomic) SJAppearState appearState;

/// navigation bar
@property (nonatomic) BOOL needHiddenNavigationBar;
- (void)_base_showOrHiddenNavigationBarIfNeeded;

/// once methods
@property (nonatomic) BOOL is_invoked_once_viewDidAppear_method;
- (void)_base_invokeOnceMethodsIfNeeded;
@end

#pragma mark - 
@implementation SJBaseViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _base_setupViews];
    // Do any additional setup after loading the view.
}

- (void)_base_setupViews {
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

- (void)_base_showOrHiddenNavigationBarIfNeeded {
    if ( SJAppearState_WillAppear == _appearState ) {
        if ( _needHiddenNavigationBar ) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
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

- (void)setNeedHiddenNavigationBar:(BOOL)needHiddenNavigationBar {
    if ( needHiddenNavigationBar == _needHiddenNavigationBar )
        return;
    _needHiddenNavigationBar = needHiddenNavigationBar;
    [self _base_showOrHiddenNavigationBarIfNeeded];
}

- (void)setAppearState:(SJAppearState)appearState {
    if ( appearState == _appearState )
        return;
    _appearState = appearState;
    [self _base_showOrHiddenNavigationBarIfNeeded];
    [self _base_invokeOnceMethodsIfNeeded];
}
@end

#pragma mark -
@implementation SJBaseViewController (HiddenNavigationBar)

@end

#pragma mark -
@implementation SJBaseViewController (AppearState)
- (id<SJAppearStateObserver>)getAppearStateObserver {
    return [[SJAppearStateObserver alloc] initWithViewController:self];
}
@end

#pragma mark -
@implementation SJBaseViewController (Once)
- (void)once_viewDidAppear_method {
    _is_invoked_once_viewDidAppear_method = YES;
}
@end
NS_ASSUME_NONNULL_END
