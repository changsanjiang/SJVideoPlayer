//
//  SJPageViewController.h
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/1/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//
//  https://github.com/changsanjiang/SJPageViewController
//
//  QQGroup: 930508201
//

#import <UIKit/UIKit.h>
@protocol SJPageViewControllerDataSource, SJPageViewControllerDelegate;
typedef NSString *SJPageViewControllerOptionsKey;

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

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN SJPageViewControllerOptionsKey const SJPageViewControllerOptionInterPageSpacingKey;

@interface SJPageViewController : UIViewController
+ (instancetype)pageViewControllerWithOptions:(nullable NSDictionary<SJPageViewControllerOptionsKey, id> *)options;
- (instancetype)initWithOptions:(nullable NSDictionary<SJPageViewControllerOptionsKey, id> *)options;

@property (nonatomic, weak, nullable) id<SJPageViewControllerDataSource> dataSource;
@property (nonatomic, weak, nullable) id<SJPageViewControllerDelegate> delegate;

- (void)reloadPageViewController;
- (void)setViewControllerAtIndex:(NSInteger)index;

- (nullable __kindof UIViewController *)viewControllerAtIndex:(NSInteger)index;
- (BOOL)isViewControllerVisibleAtIndex:(NSInteger)idx;

@property (nonatomic) CGFloat minimumBottomInsetForChildScrollView;
@property (nonatomic) BOOL bounces;

@property (nonatomic, readonly) NSInteger focusedIndex;
@property (nonatomic, readonly) NSInteger numberOfViewControllers;
@property (nonatomic, readonly, nullable) __kindof UIViewController *focusedViewController;
@property (nonatomic, readonly, nullable) NSArray<__kindof UIViewController *> *cachedViewControllers;
@property (nonatomic, readonly, nullable) __kindof UIView *headerView;
@property (nonatomic, readonly) CGFloat heightForHeaderPinToVisibleBounds;
@property (nonatomic, readonly) CGFloat heightForHeaderBounds;
@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@end


@protocol SJPageViewControllerDataSource <NSObject>
@required
- (NSUInteger)numberOfViewControllersInPageViewController:(SJPageViewController *)pageViewController;
- (__kindof UIViewController *)pageViewController:(SJPageViewController *)pageViewController viewControllerAtIndex:(NSInteger)index;

@optional
- (nullable __kindof UIView *)viewForHeaderInPageViewController:(SJPageViewController *)pageViewController;
- (CGFloat)heightForHeaderPinToVisibleBoundsWithPageViewController:(SJPageViewController *)pageViewController;
- (SJPageViewControllerHeaderMode)modeForHeaderWithPageViewController:(SJPageViewController *)pageViewController;
@end


@protocol SJPageViewControllerDelegate <NSObject>
@optional
///
/// HeaderView 可见范围发生改变的回调
///
- (void)pageViewController:(SJPageViewController *)pageViewController headerViewVisibleRectDidChange:(CGRect)visibleRect;

///
/// 正在某个范围内滚动
///
///     @range          滚动的范围. range.location 为左边,  NSMaxRange(range) 为右边
///
///     @progress       滚动位置距离左右两边的进度. 0为最左边, 1为最右边
///
- (void)pageViewController:(SJPageViewController *)pageViewController didScrollInRange:(NSRange)range distanceProgress:(CGFloat)progress;

- (void)pageViewController:(SJPageViewController *)pageViewController focusedIndexDidChange:(NSInteger)index;
- (void)pageViewController:(SJPageViewController *)pageViewController willDisplayViewController:(nullable __kindof UIViewController *)viewController atIndex:(NSInteger)index;
- (void)pageViewController:(SJPageViewController *)pageViewController didEndDisplayingViewController:(nullable __kindof UIViewController *)viewController atIndex:(NSInteger)index;
@end
NS_ASSUME_NONNULL_END

