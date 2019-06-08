//
//  SJBaseViewController.h
//  SJUIKit_Example
//
//  Created by 畅三江 on 2018/12/23.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJBaseProtocols.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJBaseViewController : UIViewController
/// REQUIRES SUPER
- (void)viewDidLoad NS_REQUIRES_SUPER;
- (void)viewWillAppear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)viewDidAppear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)viewWillDisappear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)viewDidDisappear:(BOOL)animated NS_REQUIRES_SUPER;
@end


@interface SJBaseViewController (HiddenNavigationBar)<SJHiddenNavigationBarProtocol>
/// Whether to hide the navigation bar.
/// Default value is NO.
@property (nonatomic) BOOL needHiddenNavigationBar;
@end


@interface SJBaseViewController (AppearState)<SJAppearProtocol>
/// ViewController appear state.
@property (nonatomic, readonly) SJAppearState appearState;

/// Get an Observer, that will be observe appear state of ViewController.
/// You don't have to remove it.
- (id<SJAppearStateObserver>)getAppearStateObserver;
@end


/// The following methods will only be executed once of SJBaseViewController.
/// You should not call them directly.
@interface SJBaseViewController (Once)
- (void)once_viewDidAppear_method NS_REQUIRES_SUPER;
@end


@interface SJBaseViewController (StatusBarManager)
@property (nonatomic, strong, readonly) id<SJStatusBarManager> statusBarManager;
@end
NS_ASSUME_NONNULL_END
