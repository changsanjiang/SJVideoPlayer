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
@protocol SJPageViewControllerDataSource, SJPageViewControllerDelegate, SJPageMenuItemView;
@class SJPageMenuBar;

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
typedef NS_ENUM(NSUInteger, SJPageViewControllerHeaderMode) {
    SJPageViewControllerHeaderModeTracking,
    SJPageViewControllerHeaderModePinnedToTop,
    SJPageViewControllerHeaderModeAspectFill,
};

NS_ASSUME_NONNULL_BEGIN
typedef NSString *SJPageViewControllerOptionsKey;
UIKIT_EXTERN SJPageViewControllerOptionsKey const SJPageViewControllerOptionInterPageSpacingKey;

@interface SJPageViewController : UIViewController
+ (instancetype)pageViewControllerWithOptions:(nullable NSDictionary<SJPageViewControllerOptionsKey, id> *)options;
- (instancetype)initWithOptions:(nullable NSDictionary<SJPageViewControllerOptionsKey, id> *)options;

@property (nonatomic, weak, nullable) id<SJPageViewControllerDataSource> dataSource;
@property (nonatomic, weak, nullable) id<SJPageViewControllerDelegate> delegate;

- (void)reloadPageViewController;
- (void)setViewControllerAtIndex:(NSInteger)index;

- (nullable __kindof UIViewController *)viewControllerAtIndex:(NSInteger)index;
- (NSInteger)indexOfViewController:(UIViewController *)viewController;
- (BOOL)isViewControllerVisibleAtIndex:(NSInteger)idx;

@property (nonatomic) CGFloat maximumTopInset; // childScrollView.contentInset.top
@property (nonatomic) CGFloat minimumBottomInset; // childScrollView.contentInset.bottom
@property (nonatomic) BOOL bounces;

@property (nonatomic, readonly) NSInteger focusedIndex;
@property (nonatomic, readonly) NSInteger numberOfViewControllers;
@property (nonatomic, readonly, nullable) __kindof UIViewController *focusedViewController;
@property (nonatomic, readonly, nullable) NSArray<__kindof UIViewController *> *cachedViewControllers;
@property (nonatomic, readonly, nullable) __kindof UIView *headerView;
@property (nonatomic, readonly) CGFloat heightForHeaderPinToVisibleBounds;
@property (nonatomic, readonly) CGFloat heightForHeaderBounds;
@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, readonly) CGPoint contentOffset;
@property (nonatomic, readonly, getter=isDragging) BOOL dragging;
@property (nonatomic, readonly, getter=isDecelerating) BOOL decelerating;
@end


@interface SJPageViewController (SJPageMenuBarControl)
/// 设置`pageMenuBar`进行联动
///
@property (nonatomic, strong, nullable) SJPageMenuBar *pageMenuBar;
@end
 
@protocol SJPageViewControllerHeaderViewProtocol <NSObject>
/// Use auto layout in the header view.
///
///\code
///    [self addSubview:_contentView];
///    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
///        // 左右两边宽度等于父视图
///        // 中心Y对齐
///        // 高度根据子视图自适应
///        make.left.right.offset(0);
///        make.centerY.offset(0);
///    }];
///
///    [_contentView addSubview:_subview1];
///    [_subview1 mas_makeConstraints:^(MASConstraintMaker *make) {
///         make.top.offset(0);
///         make.left.right.offset(0);
///         make.height.offset(100);
///    }];
///
///    [_contentView addSubview:_subview2];
///    [_subview2 mas_makeConstraints:^(MASConstraintMaker *make) {
///         make.top.equalTo(_subview1.mas_bottom).offset(12);
///         make.left.right.offset(0);
///         make.height.offset(50);
///    }];
///
///    [_contentView addSubview:_lastSubview];
///    [_lastSubview mas_makeConstraints:^(MASConstraintMaker *make) {
///         make.top.equalTo(_subview2.mas_bottom).offset(12);
///         make.left.right.offset(0);
///         make.height.offset(100);
///         make.bottom.offset(0);
///    }];
///\endcode
@property (nonatomic, strong, readonly) __kindof UIView *contentView;
@end

@protocol SJPageViewControllerDataSource <NSObject>
@required
- (NSUInteger)numberOfViewControllersInPageViewController:(SJPageViewController *)pageViewController;
- (__kindof UIViewController *)pageViewController:(SJPageViewController *)pageViewController viewControllerAtIndex:(NSInteger)index;

@optional
/// 请设置 headerView 的 frame
///
///     width 和 height 最好设置为整数
///
- (nullable __kindof UIView *)viewForHeaderInPageViewController:(SJPageViewController *)pageViewController;
@end


@protocol SJPageViewControllerDelegate <NSObject>
@optional
/// HeaderView 钉在顶部时保留的高度
///
- (CGFloat)heightForHeaderPinToVisibleBoundsWithPageViewController:(SJPageViewController *)pageViewController;

/// HeaderView 的控制模式
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
- (SJPageViewControllerHeaderMode)modeForHeaderWithPageViewController:(SJPageViewController *)pageViewController;

/// 设置子控制器视图中的`childScrollView.contentInset.bottom`
///
- (CGFloat)pageViewController:(SJPageViewController *)pageViewController minimumBottomInsetForViewController:(__kindof UIViewController *)viewController;

/// 设置子控制器视图中的`childScrollView.contentInset.top`
///
- (CGFloat)pageViewController:(SJPageViewController *)pageViewController maximumTopInsetForViewController:(__kindof UIViewController *)viewController;

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

- (void)pageViewController:(SJPageViewController *)pageViewController focusedIndexDidChange:(NSUInteger)index;
- (void)pageViewController:(SJPageViewController *)pageViewController willDisplayViewController:(nullable __kindof UIViewController *)viewController atIndex:(NSInteger)index;
- (void)pageViewController:(SJPageViewController *)pageViewController didEndDisplayingViewController:(nullable __kindof UIViewController *)viewController atIndex:(NSInteger)index;

- (void)pageViewControllerDidScroll:(SJPageViewController *)pageViewController;

- (void)pageViewControllerWillBeginDragging:(SJPageViewController *)pageViewController;
- (void)pageViewControllerDidEndDragging:(SJPageViewController *)pageViewController willDecelerate:(BOOL)decelerate;

- (void)pageViewControllerWillBeginDecelerating:(SJPageViewController *)pageViewController;
- (void)pageViewControllerDidEndDecelerating:(SJPageViewController *)pageViewController;

- (void)pageViewControllerWillLayoutSubviews:(SJPageViewController *)pageViewController;
@end


@interface SJPageItem : NSObject
- (instancetype)initWithType:(NSInteger)type viewController:(UIViewController *)viewController menuView:(UIView<SJPageMenuItemView> *)menuView;
@property (nonatomic, readonly) NSInteger type;
@property (nonatomic, strong, readonly) UIViewController *viewController;
@property (nonatomic, strong, readonly) UIView<SJPageMenuItemView> *menuView;
@end

@interface SJPageItemManager : NSObject
@property (nonatomic, readonly) NSInteger numberOfPageItems;
- (nullable __kindof UIViewController *)viewControllerAtIndex:(NSInteger)index;
- (nullable __kindof UIView<SJPageMenuItemView> *)menuViewAtIndex:(NSInteger)index;
- (nullable SJPageItem *)pageItemForType:(NSInteger)type;
- (nullable SJPageItem *)pageItemForViewController:(UIViewController *)viewController;

- (void)addPageItem:(SJPageItem *)pageItem;
- (void)addPageItemWithType:(NSInteger)type viewController:(UIViewController *)viewController menuView:(UIView<SJPageMenuItemView> *)menuView;

- (void)removeAllPageItems;
@end
NS_ASSUME_NONNULL_END

