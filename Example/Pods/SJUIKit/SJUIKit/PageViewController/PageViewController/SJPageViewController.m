//
//  SJPageViewController.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/1/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJPageViewController.h"
#import "SJPageViewControllerItemCell.h"
#import "SJPageCollectionView.h"
#import "UIViewController+SJPageViewControllerExtended.h"
#import "UIScrollView+SJPageViewControllerExtended.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

SJPageViewControllerOptionsKey const SJPageViewControllerOptionInterPageSpacingKey = @"SJPageViewControllerOptionInterPageSpacingKey";

static NSString *const kContentOffset = @"contentOffset";
static NSString *const kState = @"state";
static NSString *const kBounds = @"bounds";
static NSString *const kReuseIdentifierForCell = @"1";

@interface SJPageViewController ()<UICollectionViewDataSource, SJPageCollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    NSDictionary<SJPageViewControllerOptionsKey, id> *_Nullable _options;
    CGRect _previousBounds;
    CGFloat _previousOffset;
    BOOL _isResponse_focusedIndexDidChange;
    BOOL _isResponse_willDisplayViewController;
    BOOL _isResponse_didEndDisplayingViewController;
    BOOL _isResponse_didScrollInRange;
    BOOL _isResponse_headerViewVisibleRectDidChange;
    
    BOOL _isResponse_heightForHeaderPinToVisibleBounds;
    BOOL _isResponse_heightForHeaderBounds;
    BOOL _isResponse_modeForHeader;
    BOOL _isResponse_viewForHeader;
}
@property (nonatomic, getter=isDataSourceLoaded) BOOL dataSourceLoaded;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, __kindof UIViewController *> *viewControllers;
@property (nonatomic, strong, readonly, nullable) __kindof UIViewController *currentVisibleViewController;
@property (nonatomic, strong, readonly) SJPageCollectionView *collectionView;
@property (nonatomic) NSInteger focusedIndex;

@property (nonatomic) BOOL hasHeader;
@property (nonatomic, strong, nullable) __kindof UIView *headerView;
@property (nonatomic, readonly) CGFloat heightForIntersectionBounds;
@property (nonatomic, readonly) SJPageViewControllerHeaderMode modeForHeader;
@property (nonatomic) CGFloat heightForHeaderBounds;
@end

@implementation SJPageViewController
+ (instancetype)pageViewControllerWithOptions:(nullable NSDictionary<SJPageViewControllerOptionsKey,id> *)options {
    return [SJPageViewController.alloc initWithOptions:options];
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    return [self initWithOptions:nil];
}

- (instancetype)initWithOptions:(nullable NSDictionary<SJPageViewControllerOptionsKey,id> *)options {
    self = [super initWithNibName:nil bundle:nil];
    if ( self ) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        _focusedIndex = NSNotFound;
        _options = options;
        _viewControllers = NSMutableDictionary.new;
    }
    return self;
}

- (void)dealloc {
    [self _cleanHeaderView];
    [self _cleanPageItems];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    [self reloadPageViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setViewControllerAtIndex:_focusedIndex];
}

- (void)reloadPageViewController {
    if ( self.isViewLoaded ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_reloadPageViewController) object:nil];
        [self performSelector:@selector(_reloadPageViewController) withObject:nil afterDelay:0 inModes:@[NSRunLoopCommonModes]];
    }
}

- (void)setViewControllerAtIndex:(NSInteger)index {
    if ( [self _isSafeIndex:index] ) {
        [UIView performWithoutAnimation:^{
            if ( self.collectionView.bounds.size.width != 0 ) {
                CGFloat offset = index * self.collectionView.bounds.size.width;
                [self.collectionView setContentOffset:CGPointMake(offset, 0) animated:NO];
            }            
        }];
        self.focusedIndex = index;
    }
}

- (nullable __kindof UIViewController *)viewControllerAtIndex:(NSInteger)index {
    if ( [self _isSafeIndex:index] ) {
        NSNumber *idx = @(index);
        __auto_type _Nullable vc = self.viewControllers[idx];
        if ( vc == nil ) {
            vc = [self.dataSource pageViewController:self viewControllerAtIndex:index];
            NSAssert(vc != nil, @"The view controller can't be nil!");
            self.viewControllers[idx] = vc;
        }
        return vc;
    }
    return nil;
}

- (BOOL)isViewControllerVisibleAtIndex:(NSInteger)idx {
    if ( [self _isSafeIndex:idx] ) {
        if ( idx == _focusedIndex ) return YES;
        for ( NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems ) {
            if ( indexPath.item == idx ) {
                SJPageViewControllerItemCell *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
                return cell.viewController != nil &&
                CGRectContainsRect([cell convertRect:cell.bounds toView:self.view],
                                   [_collectionView convertRect:_collectionView.bounds toView:self.view]);
            }
        }
    }
    return NO;
}

- (nullable __kindof UIViewController *)focusedViewController {
    return [self viewControllerAtIndex:self.focusedIndex];
}

- (nullable NSArray<__kindof UIViewController *> *)cachedViewControllers {
    return self.viewControllers.allValues;
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    return self.collectionView.panGestureRecognizer;
}

#pragma mark -

- (void)setFocusedIndex:(NSInteger)focusedIndex {
    if ( focusedIndex != _focusedIndex ) {
        _focusedIndex = focusedIndex;
        if ( _isResponse_focusedIndexDidChange ) {
            [self.delegate pageViewController:self focusedIndexDidChange:focusedIndex];
        }
    }
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    _collectionView.bounces = bounces;
}

- (void)setDataSource:(nullable id<SJPageViewControllerDataSource>)dataSource {
    if ( dataSource != _dataSource ) {
        _dataSource = dataSource;
        
        _isResponse_heightForHeaderPinToVisibleBounds = [dataSource respondsToSelector:@selector(heightForHeaderPinToVisibleBoundsWithPageViewController:)];
        _isResponse_modeForHeader = [dataSource respondsToSelector:@selector(modeForHeaderWithPageViewController:)];
        _isResponse_viewForHeader = [dataSource respondsToSelector:@selector(viewForHeaderInPageViewController:)];
        [self reloadPageViewController];
    }
}

- (void)setDelegate:(nullable id<SJPageViewControllerDelegate>)delegate {
    if ( delegate != _delegate ) {
        _delegate = delegate;
        
        _isResponse_focusedIndexDidChange = [delegate respondsToSelector:@selector(pageViewController:focusedIndexDidChange:)];
        _isResponse_willDisplayViewController = [delegate respondsToSelector:@selector(pageViewController:willDisplayViewController:atIndex:)];
        _isResponse_didEndDisplayingViewController = [delegate respondsToSelector:@selector(pageViewController:didEndDisplayingViewController:atIndex:)];
        _isResponse_didScrollInRange = [delegate respondsToSelector:@selector(pageViewController:didScrollInRange:distanceProgress:)];
        _isResponse_headerViewVisibleRectDidChange = [delegate respondsToSelector:@selector(pageViewController:headerViewVisibleRectDidChange:)];
    }
}

#pragma mark - SJPageCollectionView

// SJPageCollectionView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ( scrollView.isDragging || scrollView.isDecelerating ) {
        [self _updateFocusedIndex];
        [self _callScrollInRange];
    }
    [self _insertHeaderViewForRootViewController];
}

// SJPageCollectionView
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ( !decelerate ) [self scrollViewDidEndDecelerating:scrollView];
}

// SJPageCollectionView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _insertHeaderViewForFocusedViewController];
}
 
#pragma mark - child scroll view

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( context == &kContentOffset ) {
        [self _childScrollViewContentOffsetDidChange:object change:change];
    }
    else if ( context == &kState ) {
        UIGestureRecognizer *gesture = object;
        if ( gesture.state == UIGestureRecognizerStateBegan ) {
            [self _insertHeaderViewForFocusedViewController];
        }
    }
    else if ( context == &kBounds ) {
        _heightForHeaderBounds = _headerView.bounds.size.height;
        [self _setupContentInsetForChildScrollView:self.focusedViewController.sj_lookupScrollView];
    }
}

- (void)_childScrollViewContentOffsetDidChange:(UIScrollView *)childScrollView change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change {
    if ( _collectionView.isDecelerating || _collectionView.isDragging ) return;

    CGFloat newValue = [change[NSKeyValueChangeNewKey] CGPointValue].y;
    CGFloat oldValue = [change[NSKeyValueChangeOldKey] CGPointValue].y;

    if ( newValue == oldValue ) return;
    [self _setupContentInsetForChildScrollView:childScrollView];

    // 同步 pageItem, 当前 child scrollView 的 contentOffset
    if ( ![childScrollView sj_locked] ) {
        for ( UIViewController *vc in self.viewControllers.allValues ) {
            SJPageItem *pageItem = vc.sj_pageItem;
            if ( childScrollView == pageItem.scrollView ) {
                pageItem.contentOffset = childScrollView.contentOffset;
                break;
            }
        }
    }
    
    // header的悬浮控制
    if ( childScrollView == self.currentVisibleViewController.sj_pageItem.scrollView ) {
        
        [self _insertHeaderViewForFocusedViewController];
        
        CGFloat offset = childScrollView.contentOffset.y;
        CGRect frame = _headerView.frame;

        CGFloat heightForHeaderBounds = self.heightForHeaderBounds;
        CGFloat heightForHeaderPinToVisibleBounds = self.heightForHeaderPinToVisibleBounds;
        __auto_type modeForHeader = self.modeForHeader;
        CGFloat topPinOffset = offset - heightForHeaderBounds + heightForHeaderPinToVisibleBounds;
        CGFloat y = frame.origin.y;
        // 向上移动
        if ( newValue >= oldValue ) {
            if ( y <= topPinOffset ) y = topPinOffset;
        }
        // 向下移动
        else {
            y += newValue - oldValue;
            if ( y <= -heightForHeaderBounds ) y = -heightForHeaderBounds;
        }
        
        switch ( modeForHeader ) {
            case SJPageViewControllerHeaderModeTracking: {
                frame.origin.x = 0;
                frame.origin.y = y;
            }
                break;
            case SJPageViewControllerHeaderModePinnedToTop: {
                if ( offset <= -heightForHeaderBounds ) {
                    y = offset;
                }
                
                frame.origin.x = 0;
                frame.origin.y = y;
            }
                break;
            case SJPageViewControllerHeaderModeAspectFill: {
                CGFloat extend = (-offset - heightForHeaderBounds);
                if ( offset <= -heightForHeaderBounds ) {
                    y = offset;
                }
                else {
                    extend = 0;
                }
                
                frame.origin.x = -extend * 0.5;
                frame.origin.y = y;
                frame.size.width = self.view.bounds.size.width + extend;
                frame.size.height = heightForHeaderBounds + extend;
            }
                break;
        }
        
        _headerView.frame = frame;
        if ( modeForHeader == SJPageViewControllerHeaderModeAspectFill ) [_headerView layoutIfNeeded];
        
        CGFloat indictorTopInset = heightForHeaderBounds;
        if ( y <= -heightForHeaderBounds ) indictorTopInset = -y;
        if ( childScrollView.scrollIndicatorInsets.top != indictorTopInset ) {
            childScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(indictorTopInset, 0, 0, 0);
        }
        
        if ( _isResponse_headerViewVisibleRectDidChange ) {
            CGFloat progress = 1 - ABS(y - offset) / heightForHeaderBounds;
            if ( progress <= 0 ) progress = 0;
            else if ( progress >= 1 ) progress = 1;
            CGRect rect = (CGRect){0, 0, frame.size.width, frame.size.height * progress};
            [self.delegate pageViewController:self headerViewVisibleRectDidChange:rect];
        }
    }
}

#pragma mark -

- (void)_setupViews {
    self.view.clipsToBounds = YES;
    [self.view addSubview:self.collectionView];
}

@synthesize collectionView = _collectionView;
- (SJPageCollectionView *)collectionView {
    if ( _collectionView == nil ) {
        CGFloat spacing = [_options[SJPageViewControllerOptionInterPageSpacingKey] doubleValue];
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = spacing;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [SJPageCollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = UIColor.clearColor;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, spacing);
        _collectionView.bounces = _bounces;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:SJPageViewControllerItemCell.class forCellWithReuseIdentifier:kReuseIdentifierForCell];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}
 
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.isDataSourceLoaded ? self.numberOfViewControllers : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifierForCell forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SJPageViewControllerItemCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = indexPath.item;
    __auto_type oldViewController = cell.viewController;
    __auto_type newViewController = [self viewControllerAtIndex:indexPath.item];
    cell.viewController = newViewController;
    
    if ( oldViewController != newViewController ) {
        [self _removePageChildViewController:oldViewController];
        
        [self addChildViewController:newViewController];
        [newViewController.view setFrame:cell.bounds];
        [cell.contentView addSubview:newViewController.view];
        
        if ( _hasHeader ) {
            UIScrollView *childScrollView = [newViewController sj_lookupScrollView];
            NSAssert(childScrollView != nil, @"The scrollView can't be nil!");
            CGRect bounds = cell.bounds;
            SJPageItem *_Nullable pageItem = newViewController.sj_pageItem;
            if ( pageItem == nil ) {
                pageItem = SJPageItem.new;
                pageItem.scrollView = childScrollView;
                newViewController.sj_pageItem = pageItem;

                // pageItem 为空, 则为首次出现
                //      - 需修正 childScrollView 的 scrollIndicatorInsets & contentInset & contentOffset
                //      - 是否需要添加 headerView 到 第一个显示的 childScrollView 中
                //      - kvo contentOffset
                childScrollView.frame = bounds;
                if (@available(iOS 13.0, *)) {
                    childScrollView.automaticallyAdjustsScrollIndicatorInsets = NO;
                }
                if (@available(iOS 11.0, *)) {
                    childScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
                }
                CGFloat heightForHeaderBounds = self.heightForHeaderBounds;
                if ( _headerView.superview == nil ) {
                    _headerView.frame = CGRectMake(0, -heightForHeaderBounds, bounds.size.width, heightForHeaderBounds);
                    [childScrollView addSubview:_headerView];
                }
                childScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(heightForHeaderBounds, 0, 0, 0);
                [self _setupContentInsetForChildScrollView:childScrollView];
                [childScrollView setContentOffset:CGPointMake(0, -heightForHeaderBounds) animated:NO];
                [childScrollView addObserver:self forKeyPath:kContentOffset options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(void *)&kContentOffset];
                [childScrollView.panGestureRecognizer addObserver:self forKeyPath:kState options:NSKeyValueObservingOptionNew context:(void *)&kState];
            }
            else {
                [self _setupContentInsetForChildScrollView:childScrollView];
            }
            
            if ( [pageItem.scrollView sj_locked] == NO ) {
                CGFloat intersection = self.heightForIntersectionBounds;
                CGPoint contentOffset = pageItem.contentOffset;
                contentOffset.y += pageItem.intersection - intersection;
                if ( !CGPointEqualToPoint(pageItem.scrollView.contentOffset, contentOffset) ) {
                    [pageItem.scrollView sj_lock];
                    [pageItem.scrollView setContentOffset:contentOffset animated:NO];
                    [pageItem.scrollView sj_unlock];
                }
            }
            
            if ( self.focusedIndex == idx && !_collectionView.isDecelerating && !_collectionView.isDragging ) {
                [self _insertHeaderViewForFocusedViewController];
            }
        }
    }
     
    if ( _isResponse_willDisplayViewController ) {
        [self.delegate pageViewController:self willDisplayViewController:newViewController atIndex:idx];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(SJPageViewControllerItemCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = cell.viewController;
    if ( _hasHeader ) {
        SJPageItem *pageItem = viewController.sj_pageItem;
        pageItem.intersection = self.heightForIntersectionBounds;
        pageItem.contentOffset = pageItem.scrollView.contentOffset;
    }

    if ( _isResponse_didEndDisplayingViewController ) {
        [self.delegate pageViewController:self didEndDisplayingViewController:viewController atIndex:indexPath.item];
    }
    
    [self _removePageChildViewController:viewController];
    cell.viewController = nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size;
}
 

- (BOOL)collectionView:(UICollectionView *)collectionView gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( gestureRecognizer.state == UIGestureRecognizerStateFailed ||
         gestureRecognizer.state == UIGestureRecognizerStateCancelled )
        return NO;
    
    if ( gestureRecognizer == collectionView.panGestureRecognizer && self.numberOfViewControllers != 0 ) {
        CGPoint location = [gestureRecognizer locationInView:self.view];
        if ( _hasHeader ) {
            if ( CGRectContainsPoint([_headerView.superview convertRect:_headerView.frame toView:self.view], location) ) {
                gestureRecognizer.state = UIGestureRecognizerStateCancelled;
                return NO;
            }
        }
        
        CGRect leftEdgeRect = [self _rectForRectEdge:UIRectEdgeLeft];
        CGRect rightEdgeRect = [self _rectForRectEdge:UIRectEdgeRight];
        if ( CGRectContainsPoint(leftEdgeRect, location) ) {
            if ( [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIWebTouchEventsGestureRecognizer")] ) {
                otherGestureRecognizer.state = UIGestureRecognizerStateCancelled;
                return YES;
            }
            
            if ( [otherGestureRecognizer isKindOfClass:UIPanGestureRecognizer.class] ) {
                CGPoint translate = [gestureRecognizer translationInView:collectionView];
                if ( translate.x > 0 && translate.y == 0 && self.focusedIndex != 0 ) {
                    otherGestureRecognizer.state = UIGestureRecognizerStateCancelled;
                    return YES;
                }
            }
        }
        else if ( CGRectContainsPoint(rightEdgeRect, location) ) {
            if ( [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIWebTouchEventsGestureRecognizer")] ) {
                otherGestureRecognizer.state = UIGestureRecognizerStateCancelled;
                return YES;
            }
            
            if ( [otherGestureRecognizer isKindOfClass:UIPanGestureRecognizer.class] ) {
                CGPoint translate = [gestureRecognizer translationInView:collectionView];
                if ( translate.x < 0 && translate.y == 0 && self.focusedIndex != self.numberOfViewControllers - 1 ) {
                    otherGestureRecognizer.state = UIGestureRecognizerStateCancelled;
                    return YES;
                }
            }
        }
    }
    return NO;
}

#pragma mark -

- (CGFloat)heightForIntersectionBounds {
    if ( _headerView != nil ) {
        CGRect rect = [_headerView convertRect:_headerView.bounds toView:self.view];
        CGRect intersection = CGRectIntersection(self.view.bounds, rect);
        return (CGRectIsEmpty(intersection) || CGRectIsNull(intersection)) ? 0 : intersection.size.height;
    }
    return 0;
}

- (NSInteger)numberOfViewControllers {
    return [self.dataSource numberOfViewControllersInPageViewController:self];
}

- (CGFloat)heightForHeaderPinToVisibleBounds {
    if ( _isResponse_heightForHeaderPinToVisibleBounds ) {
        return [self.dataSource heightForHeaderPinToVisibleBoundsWithPageViewController:self];
    }
    return 0;
}

- (SJPageViewControllerHeaderMode)modeForHeader {
    if ( _isResponse_modeForHeader )
        return [self.dataSource modeForHeaderWithPageViewController:self];
    return 0;
}

- (__kindof UIView *_Nullable)headerView {
    if ( _headerView == nil ) {
        if ( _isResponse_viewForHeader ) {
            _headerView = [self.dataSource viewForHeaderInPageViewController:self];
        }
    }
    return _headerView;
}

- (nullable __kindof UIViewController *)currentVisibleViewController {
    return [(SJPageViewControllerItemCell *)self.collectionView.visibleCells.lastObject viewController];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect bounds = self.view.bounds;
    if ( !CGRectEqualToRect(_previousBounds, bounds) ) {
        _previousBounds = bounds;
        [self _remakeConstraints];
    }
}

- (void)willMoveToParentViewController:(nullable UIViewController *)parent {
    parent.edgesForExtendedLayout = UIRectEdgeNone;
    [super willMoveToParentViewController:parent];
}

#pragma mark -
 
- (void)_callScrollInRange {
    CGFloat horizontalOffset = _collectionView.contentOffset.x;
    CGFloat position = horizontalOffset / _collectionView.bounds.size.width;

    NSInteger left = (NSInteger)floor(position);
    NSInteger right = (NSInteger)ceil(position);

    if ( left >= 0 && right < self.numberOfViewControllers ) {
        CGFloat progress = position - left;
        
        if ( _isResponse_didScrollInRange )
            [self.delegate pageViewController:self didScrollInRange:NSMakeRange(left, right - left) distanceProgress:progress];
    }
}

- (void)_updateFocusedIndex {
    CGFloat horizontalOffset = _collectionView.contentOffset.x;
    CGFloat position = horizontalOffset / _collectionView.bounds.size.width;
    self.focusedIndex = (NSInteger)(horizontalOffset > _previousOffset ? ceil(position) : position);
    _previousOffset = horizontalOffset;
}

- (void)_insertHeaderViewForRootViewController {
    if ( _hasHeader ) {
        CGFloat horizontalOffset = _collectionView.contentOffset.x;
        CGRect frame = [_headerView.superview convertRect:_headerView.frame toView:self.view];
        CGFloat lastItemOffset = ( self.numberOfViewControllers - 1 ) * self.collectionView.bounds.size.width;
        if      ( horizontalOffset <= 0 ) {
            frame.origin.x = -horizontalOffset;
        }
        else if ( horizontalOffset >= lastItemOffset ) {
            frame.origin.x = lastItemOffset - horizontalOffset;
        }
        else {
            frame.origin.x = 0;
        }
        frame.size = CGSizeMake(self.view.bounds.size.width, self.heightForHeaderBounds);
        _headerView.frame = frame;
        if ( _headerView.superview != self.view ) {
            [self.view insertSubview:_headerView aboveSubview:_collectionView];
        }
    }
}

- (void)_insertHeaderViewForFocusedViewController {
    if ( _hasHeader ) {
        // 停止滑动时, 将 headerView 恢复到 child scrollView 中
        UIScrollView *childScrollView = self.focusedViewController.sj_pageItem.scrollView;
        CGRect frame = [_headerView.superview convertRect:_headerView.frame toView:childScrollView];
        frame.size = CGSizeMake(self.view.bounds.size.width, self.heightForHeaderBounds);
        _headerView.frame = frame;
        [childScrollView addSubview:_headerView];
    }
}

- (BOOL)_isSafeIndex:(NSInteger)index {
    return index < self.numberOfViewControllers && index >= 0;
}

- (CGRect)_rectForRectEdge:(UIRectEdge)edge {
    CGRect rect = CGRectZero;
    if ( edge & UIRectEdgeLeft ) {
        rect.size.width = 50;
        rect.size.height = self.view.bounds.size.height;
    }
    else if ( edge & UIRectEdgeRight ) {
        rect.origin.x = self.view.bounds.size.width - 50;
        rect.size.width = 50;
        rect.size.height = self.view.bounds.size.height;
    }
    return rect;
}

- (void)_cleanPageItems {
    for ( UIViewController *vc in self.viewControllers.allValues ) {
        SJPageItem *item = vc.sj_pageItem;
        if ( item != nil ) {
            [item.scrollView.panGestureRecognizer removeObserver:self forKeyPath:kState];
            [item.scrollView removeObserver:self forKeyPath:kContentOffset];
            vc.sj_pageItem = nil;
        }
    }
}

- (void)_cleanHeaderView {
    if ( _headerView != nil ) {
        [_headerView removeObserver:self forKeyPath:kBounds];
        [_headerView removeFromSuperview];
        _headerView = nil;
        _hasHeader = NO;
    }
}

- (void)_setupContentInsetForChildScrollView:(UIScrollView *)childScrollView {
    if ( !childScrollView ) return;
    CGFloat heightForHeaderBounds = self.heightForHeaderBounds;
    CGFloat heightForHeaderPinToVisibleBounds = self.heightForHeaderPinToVisibleBounds;
    CGRect bounds = self.view.bounds;
    CGFloat boundsHeight = bounds.size.height;
    CGFloat contentHeight = childScrollView.contentSize.height;
    CGFloat bottomInset = _minimumBottomInsetForChildScrollView;
    if ( contentHeight < boundsHeight ) {
        bottomInset = ceil(boundsHeight - contentHeight - heightForHeaderPinToVisibleBounds);
    }
    
    if ( bottomInset < _minimumBottomInsetForChildScrollView ) bottomInset = _minimumBottomInsetForChildScrollView;
    
    UIEdgeInsets insets = childScrollView.contentInset;
    if ( insets.top != heightForHeaderBounds || insets.bottom != bottomInset ) {
        insets.top = heightForHeaderBounds;
        insets.bottom = bottomInset;
        childScrollView.contentInset = insets;
    }
}

- (void)_reloadPageViewController {
    self.dataSourceLoaded = YES;
    [self _cleanHeaderView];
    [self _cleanPageItems];
    [self.viewControllers removeAllObjects];
    [self.collectionView reloadData];
    
    NSInteger numberOfViewControllers = self.numberOfViewControllers;
    if ( numberOfViewControllers != 0 ) {
        _hasHeader = self.headerView != nil;
        if ( _hasHeader ) {
            [_headerView addObserver:self forKeyPath:kBounds options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:(void *)&kBounds];
        }
        
        NSInteger focusedIndex = _focusedIndex;
        if ( focusedIndex == NSNotFound )
            focusedIndex = 0;
        else if ( focusedIndex >= numberOfViewControllers )
            focusedIndex = numberOfViewControllers - 1;
        [self setViewControllerAtIndex:focusedIndex];
    }
}

- (void)_remakeConstraints {
    CGRect bounds = self.view.bounds;
#ifdef SJDEBUG
    self.view.clipsToBounds = NO;
    // 扩大两倍 用于调试
    self.collectionView.frame = CGRectMake(0, 0, (bounds.size.width + [_options[SJPageViewControllerOptionInterPageSpacingKey] doubleValue]) * 2, bounds.size.height);
#else
    self.collectionView.frame = CGRectMake(0, 0, (bounds.size.width + [_options[SJPageViewControllerOptionInterPageSpacingKey] doubleValue]), bounds.size.height);
#endif

    if ( _hasHeader ) {
        CGRect frame = _headerView.frame;
        CGFloat width = bounds.size.width;
        if ( frame.size.width != width ) {
            frame.size.width = width;
            _headerView.frame = frame;
        }
    }
    
    [self setViewControllerAtIndex:self.focusedIndex];
}

- (void)_removePageChildViewController:(UIViewController *)viewController {
    if ( viewController == nil ) return;
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
    [viewController didMoveToParentViewController:nil];
}
@end
NS_ASSUME_NONNULL_END
