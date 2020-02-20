//
//  SJPageViewController.h
//  SJPageViewController_Example
//
//  Created by 畅三江 on 2020/1/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//
//  https://github.com/changsanjiang/SJPageViewController
//
//  QQGroup: 930508201
//

#import <UIKit/UIKit.h>
@protocol SJPageViewControllerDataSource, SJPageViewControllerDelegate;
typedef NSString *SJPageViewControllerOptionsKey;

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN SJPageViewControllerOptionsKey const SJPageViewControllerOptionInterPageSpacingKey;

@interface SJPageViewController : UIViewController
+ (instancetype)pageViewControllerWithOptions:(nullable NSDictionary<SJPageViewControllerOptionsKey, id> *)options;
- (instancetype)initWithOptions:(nullable NSDictionary<SJPageViewControllerOptionsKey, id> *)options;

@property (nonatomic, readonly) NSInteger focusedIndex;
@property (nonatomic, weak, nullable) id<SJPageViewControllerDataSource> dataSource;
@property (nonatomic, weak, nullable) id<SJPageViewControllerDelegate> delegate;
@property (nonatomic, readonly) NSInteger numberOfViewControllers;
- (void)reloadPageViewController;
- (void)setViewControllerAtIndex:(NSInteger)index;

- (nullable __kindof UIViewController *)viewControllerAtIndex:(NSInteger)index;
- (BOOL)isViewControllerVisibleAtIndex:(NSInteger)idx;

@property (nonatomic) CGFloat minimumBottomInsetForChildScrollView;
@property (nonatomic) BOOL bounces;
@property (nonatomic, getter=isScrollEnabled) BOOL scrollEnabled;
@property (nonatomic, readonly, nullable) __kindof UIView *headerView;
@property (nonatomic, readonly, nullable) __kindof UIViewController *focusedViewController;
@property (nonatomic, readonly, nullable) NSArray<__kindof UIViewController *> *cachedViewControllers;
@end

///
/// SJPageViewControllerHeaderModeTracking
///     - 顶部下拉时, headerView 跟随移动
///
/// SJPageViewControllerHeaderModePinnedToTop
///     - 顶部下拉时, headerView 固定在顶部
///
/// SJPageViewControllerHeaderModeAspectFill
///     - 顶部下拉时, headerView 同比放大
///
typedef enum : NSUInteger {
    SJPageViewControllerHeaderModeTracking,
    SJPageViewControllerHeaderModePinnedToTop,
    SJPageViewControllerHeaderModeAspectFill,
} SJPageViewControllerHeaderMode;

@protocol SJPageViewControllerDataSource <NSObject>
@required
- (NSUInteger)numberOfViewControllersInPageViewController:(SJPageViewController *)pageViewController;
- (__kindof UIViewController *)pageViewController:(SJPageViewController *)pageViewController viewControllerAtIndex:(NSInteger)index;

@optional
- (nullable __kindof UIView *)viewForHeaderInPageViewController:(SJPageViewController *)pageViewController;
- (CGFloat)heightForHeaderBoundsWithPageViewController:(SJPageViewController *)pageViewController;
- (CGFloat)heightForHeaderPinToVisibleBoundsWithPageViewController:(SJPageViewController *)pageViewController;
- (SJPageViewControllerHeaderMode)modeForHeaderWithPageViewController:(SJPageViewController *)pageViewController;
@end

@protocol SJPageViewControllerDelegate <NSObject>
@optional
- (void)pageViewController:(SJPageViewController *)pageViewController headerViewScrollProgressDidChange:(CGFloat)progress;
- (void)pageViewController:(SJPageViewController *)pageViewController didScrollInRange:(NSRange)range distanceProgress:(CGFloat)progress;

- (void)pageViewController:(SJPageViewController *)pageViewController focusedIndexDidChange:(NSInteger)index;
- (void)pageViewController:(SJPageViewController *)pageViewController willDisplayViewController:(nullable __kindof UIViewController *)viewController atIndex:(NSInteger)index;
- (void)pageViewController:(SJPageViewController *)pageViewController didEndDisplayingViewController:(nullable __kindof UIViewController *)viewController atIndex:(NSInteger)index;
@end
NS_ASSUME_NONNULL_END

