//
//  SJViewControllerManagerDefines.h
//  Pods
//
//  Created by 畅三江 on 2019/11/23.
//

#ifndef SJViewControllerManagerDefines_h
#define SJViewControllerManagerDefines_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJViewControllerManager <NSObject>
@property (nonatomic, readonly, getter=isViewDisappeared) BOOL viewDisappeared;
@property (nonatomic, readonly) UIStatusBarStyle preferredStatusBarStyle;
@property (nonatomic, readonly) BOOL prefersStatusBarHidden;

- (void)viewDidAppear;
- (void)viewWillDisappear;
- (void)viewDidDisappear;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)showStatusBar;
- (void)hiddenStatusBar;
- (void)setNeedsStatusBarAppearanceUpdate;
@end
NS_ASSUME_NONNULL_END
#endif /* SJViewControllerManagerDefines_h */
