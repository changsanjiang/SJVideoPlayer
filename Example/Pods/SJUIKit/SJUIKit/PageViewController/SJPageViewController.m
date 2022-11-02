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
#if __has_include("SJPageMenuBar.h")
#import "SJPageMenuBar.h"
#endif
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

SJPageViewControllerOptionsKey const SJPageViewControllerOptionInterPageSpacingKey = @"SJPageViewControllerOptionInterPageSpacingKey";

static NSString *const kContentOffset = @"contentOffset";
static NSString *const kState = @"state";
static NSString *const kBounds = @"bounds";
static NSString *const kFrame = @"frame";
static NSString *const kReuseIdentifierForCell = @"1";

#if __has_include("SJPageMenuBar.h")
@interface SJPageMenuBar (SJPageMenuBarPrivate)
@property (nonatomic, weak, nullable) SJPageViewController *pageViewController;
@end
#endif

@interface SJPageViewController ()<UICollectionViewDataSource, SJPageCollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    NSDictionary<SJPageViewControllerOptionsKey, id> *_Nullable _options;
    CGRect _previousBounds;
    CGFloat _previousOffset;
    BOOL _isResponse_focusedIndexDidChange;
    BOOL _isResponse_willDisplayViewController;
    BOOL _isResponse_didEndDisplayingViewController;
    BOOL _isResponse_didScrollInRange;
    BOOL _isResponse_headerViewVisibleRectDidChange;
    
    BOOL _isResponse_minimumBottomInsetForViewController;
    BOOL _isResponse_maximumTopInsetForViewController;
    BOOL _isResponse_heightForHeaderPinToVisibleBounds;
    BOOL _isResponse_modeForHeader;
    BOOL _isResponse_viewForHeader;
     
    BOOL _isResponse_willBeginDragging;
    BOOL _isResponse_didEndDragging;
    BOOL _isResponse_didScroll;
    BOOL _isResponse_willBeginDecelerating;
    BOOL _isResponse_didEndDecelerating;
    BOOL _isResponse_willLayoutSubviews;
    
    BOOL _needsReloadPageViewController;
    NSInteger _numberOfViewControllers;
    __kindof UIView *_headerView;
    BOOL _hasHeader;
}
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, __kindof UIViewController *> *viewControllers;
@property (nonatomic, strong, readonly, nullable) __kindof UIViewController *currentVisibleViewController;
@property (nonatomic, strong, readonly) SJPageCollectionView *collectionView;
@property (nonatomic) NSInteger focusedIndex;

@property (nonatomic, readonly) CGFloat heightForIntersectionBounds;
@property (nonatomic, readonly) SJPageViewControllerHeaderMode modeForHeader;
@property (nonatomic) CGFloat heightForHeaderBounds;

#if __has_include("SJPageMenuBar.h")
@property (nonatomic, strong, nullable) SJPageMenuBar *pageMenuBar;
#endif
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
        _needsReloadPageViewController = YES;
    }
    return self;
}

- (void)dealloc {
    [self _removeHeaderView];
    [self _removeViewControllers];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

- (void)reloadPageViewController {
    [self _setNeedsReloadPageViewController];
}

- (void)setViewControllerAtIndex:(NSInteger)index {
    [self _reloadPageViewControllerIfNeeded];
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
    [self _reloadPageViewControllerIfNeeded];
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

- (NSInteger)indexOfViewController:(UIViewController *)viewController {
    [self _reloadPageViewControllerIfNeeded];
    __block NSInteger index = NSNotFound;
    [self.viewControllers enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, __kindof UIViewController * _Nonnull obj, BOOL * _Nonnull stop) {
        if ( viewController == obj ) {
            index = key.integerValue;
            *stop = YES;
        }
    }];
    return index;
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

- (CGPoint)contentOffset {
    return _collectionView.contentOffset;
}

- (BOOL)isDragging {
    return _collectionView.isDragging;
}

- (BOOL)isDecelerating {
    return _collectionView.isDecelerating;
}

- (void)setPageMenuBar:(nullable SJPageMenuBar *)pageMenuBar {
#if __has_include("SJPageMenuBar.h")
    _pageMenuBar.pageViewController = nil;
    _pageMenuBar = pageMenuBar;
    _pageMenuBar.pageViewController = self;
    NSInteger focusedIndex = pageMenuBar.focusedIndex;
    if ( focusedIndex != NSNotFound && focusedIndex != self.focusedIndex ) {
        [self setViewControllerAtIndex:focusedIndex];
    }
#endif
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
        
        _isResponse_viewForHeader = [dataSource respondsToSelector:@selector(viewForHeaderInPageViewController:)];
        [self reloadPageViewController];
    }
}

- (void)setDelegate:(nullable id<SJPageViewControllerDelegate>)delegate {
    if ( delegate != _delegate ) {
        _delegate = delegate;
        
        _isResponse_heightForHeaderPinToVisibleBounds = [delegate respondsToSelector:@selector(heightForHeaderPinToVisibleBoundsWithPageViewController:)];
        _isResponse_modeForHeader = [delegate respondsToSelector:@selector(modeForHeaderWithPageViewController:)];
        _isResponse_focusedIndexDidChange = [delegate respondsToSelector:@selector(pageViewController:focusedIndexDidChange:)];
        _isResponse_willDisplayViewController = [delegate respondsToSelector:@selector(pageViewController:willDisplayViewController:atIndex:)];
        _isResponse_didEndDisplayingViewController = [delegate respondsToSelector:@selector(pageViewController:didEndDisplayingViewController:atIndex:)];
        _isResponse_didScrollInRange = [delegate respondsToSelector:@selector(pageViewController:didScrollInRange:distanceProgress:)];
        _isResponse_headerViewVisibleRectDidChange = [delegate respondsToSelector:@selector(pageViewController:headerViewVisibleRectDidChange:)];
        _isResponse_didScroll = [delegate respondsToSelector:@selector(pageViewControllerDidScroll:)];
        _isResponse_willBeginDragging = [delegate respondsToSelector:@selector(pageViewControllerWillBeginDragging:)];
        _isResponse_didEndDragging = [delegate respondsToSelector:@selector(pageViewControllerDidEndDragging:willDecelerate:)];
        _isResponse_willBeginDecelerating = [delegate respondsToSelector:@selector(pageViewControllerWillBeginDecelerating:)];
        _isResponse_didEndDecelerating = [delegate respondsToSelector:@selector(pageViewControllerDidEndDecelerating:)];
        _isResponse_maximumTopInsetForViewController = [delegate respondsToSelector:@selector(pageViewController:maximumTopInsetForViewController:)];
        _isResponse_minimumBottomInsetForViewController = [delegate respondsToSelector:@selector(pageViewController:minimumBottomInsetForViewController:)];
        _isResponse_willLayoutSubviews = [delegate respondsToSelector:@selector(pageViewControllerWillLayoutSubviews:)];
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
    
    if ( _isResponse_didScroll )
        [_delegate pageViewControllerDidScroll:self];
}

// SJPageCollectionView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ( _isResponse_willBeginDragging )
        [_delegate pageViewControllerWillBeginDragging:self];
}

// SJPageCollectionView
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ( !decelerate ) [self _insertHeaderViewForFocusedViewController];
    
    if ( _isResponse_didEndDragging )
        [_delegate pageViewControllerDidEndDragging:self willDecelerate:decelerate];
}

// SJPageCollectionView
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ( _isResponse_willBeginDecelerating )
        [_delegate pageViewControllerWillBeginDecelerating:self];
}

// SJPageCollectionView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _insertHeaderViewForFocusedViewController];
    
    if ( _isResponse_didEndDecelerating )
        [_delegate pageViewControllerDidEndDecelerating:self];
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
    else if ( context == &kBounds || context == &kFrame ) {
        if ( !_headerView.sj_locked ) {
            UIView *target = object;
            CGFloat height = target.bounds.size.height;
            if ( height != _heightForHeaderBounds ) {
                CGFloat offsetY = height - _heightForHeaderBounds;
                _heightForHeaderBounds = height;
                if ( target != _headerView ) {
                    CGRect bounds = _headerView.frame;
                    bounds.size.height = _heightForHeaderBounds;
                    [_headerView sj_lock];
                    _headerView.frame = bounds;
                    [_headerView sj_unlock];
                }
                [self _setupContentInsetForChildScrollView:self.focusedViewController.sj_lookupScrollView];
                UIScrollView *childScrollView = self.focusedViewController.sj_lookupScrollView;
                if ( childScrollView != nil ) {
                    [self _setupContentInsetForChildScrollView:childScrollView];
                    CGPoint offset = childScrollView.contentOffset;
                    offset.y -= offsetY;
                    [childScrollView setContentOffset:offset];
                }
            }
        }
    }
}

- (void)_childScrollViewContentOffsetDidChange:(UIScrollView *)childScrollView change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change {
    if ( _collectionView.isDecelerating || _collectionView.isDragging ) return;

    CGFloat newValue = [change[NSKeyValueChangeNewKey] CGPointValue].y;
    CGFloat oldValue = [change[NSKeyValueChangeOldKey] CGPointValue].y;

    if ( newValue == oldValue ) return;
    [self _setupContentInsetForChildScrollView:childScrollView];

    // 同步 scrollViewItem, 当前 child scrollView 的 contentOffset
    if ( ![childScrollView sj_locked] ) {
        for ( UIViewController *vc in self.viewControllers.allValues ) {
            SJPageScrollViewItem *scrollViewItem = vc.sj_scrollViewItem;
            if ( childScrollView == scrollViewItem.scrollView ) {
                scrollViewItem.contentOffset = childScrollView.contentOffset;
                break;
            }
        }
    }
    
    // header的悬浮控制
    if ( childScrollView == self.currentVisibleViewController.sj_scrollViewItem.scrollView ) {
        
        [self _insertHeaderViewForFocusedViewController];
        
        CGFloat offset = childScrollView.contentOffset.y;
        CGRect frame = _headerView.frame;

        CGFloat topInset = [self _maximumTopInsetForChildScrollView:childScrollView];
        CGFloat headerHeight = self.heightForHeaderBounds;
        CGFloat maxTopOffset = headerHeight + topInset;
        CGFloat pinnedHeight = self.heightForHeaderPinToVisibleBounds;
        __auto_type headerMode = self.modeForHeader;
        CGFloat pinnedOffset = offset - headerHeight + pinnedHeight;
        CGFloat y = frame.origin.y;
        // 向上移动
        if ( newValue >= oldValue ) {
            if ( y <= pinnedOffset ) y = pinnedOffset;
        }
        // 向下移动
        else {
            y += newValue - oldValue;
            if ( y <= -maxTopOffset ) y = -maxTopOffset;
        }
        
        switch ( headerMode ) {
            case SJPageViewControllerHeaderModeTracking: {
                frame.origin.x = 0;
                frame.origin.y = y;
            }
                break;
            case SJPageViewControllerHeaderModePinnedToTop: {
                if ( offset <= -maxTopOffset ) {
                    y = offset;
                }
                
                frame.origin.x = 0;
                frame.origin.y = y;
            }
                break;
            case SJPageViewControllerHeaderModeAspectFill: {
                CGFloat extend = 0;
                if ( offset <= -maxTopOffset ) {
                    extend = (-offset - maxTopOffset);
                    y = offset;
                }
                
                frame.origin.x = -extend * 0.5;
                frame.origin.y = y;
                frame.size.width = self.view.bounds.size.width + extend;
                frame.size.height = headerHeight + extend;
            }
                break;
        }
        
        [_headerView sj_lock];
        _headerView.frame = frame;
        [_headerView sj_unlock];
        if ( headerMode == SJPageViewControllerHeaderModeAspectFill ) [_headerView layoutIfNeeded];
        
        CGFloat indictorTopInset = headerHeight;
        if ( y <= -headerHeight ) indictorTopInset = -y;
        if ( childScrollView.scrollIndicatorInsets.top != indictorTopInset ) {
            childScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(indictorTopInset, 0, 0, 0);
        }
        
        if ( _isResponse_headerViewVisibleRectDidChange ) {
            CGFloat progress = 1 - ABS(y - offset) / maxTopOffset;
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
    return _numberOfViewControllers;
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
        [newViewController.view layoutIfNeeded];
        
        if ( _hasHeader ) {
            UIScrollView *childScrollView = [newViewController sj_lookupScrollView];
            NSAssert(childScrollView != nil, @"The scrollView can't be nil!");
            CGRect bounds = cell.bounds;
            SJPageScrollViewItem *_Nullable scrollViewItem = newViewController.sj_scrollViewItem;
            if ( scrollViewItem == nil ) {
                scrollViewItem = SJPageScrollViewItem.new;
                scrollViewItem.scrollView = childScrollView;
                newViewController.sj_scrollViewItem = scrollViewItem;

                // scrollViewItem 为空, 则为首次出现
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
                CGFloat topInset = [self _maximumTopInsetForChildScrollView:childScrollView];
                CGFloat offset = heightForHeaderBounds + topInset;
                if ( _headerView.superview == nil ) {
                    [_headerView sj_lock];
                    _headerView.frame = CGRectMake(0, -offset, bounds.size.width, heightForHeaderBounds);
                    [_headerView sj_unlock];
                    [childScrollView addSubview:_headerView];
                }
                childScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(offset, 0, 0, 0);
                [self _setupContentInsetForChildScrollView:childScrollView];
                [childScrollView setContentOffset:CGPointMake(0, -offset) animated:NO];
                [childScrollView addObserver:self forKeyPath:kContentOffset options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(void *)&kContentOffset];
                [childScrollView.panGestureRecognizer addObserver:self forKeyPath:kState options:NSKeyValueObservingOptionNew context:(void *)&kState];
                scrollViewItem.contentOffset = CGPointMake(0, -topInset);
            }
            else {
                [self _setupContentInsetForChildScrollView:childScrollView];
            }
            
            if ( [scrollViewItem.scrollView sj_locked] == NO ) {
                CGFloat intersection = self.heightForIntersectionBounds;
                CGPoint contentOffset = scrollViewItem.contentOffset;
                contentOffset.y += scrollViewItem.intersection - intersection;
                if ( !CGPointEqualToPoint(scrollViewItem.scrollView.contentOffset, contentOffset) ) {
                    [scrollViewItem.scrollView sj_lock];
                    [scrollViewItem.scrollView setContentOffset:contentOffset animated:NO];
                    [scrollViewItem.scrollView sj_unlock];
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
        SJPageScrollViewItem *scrollViewItem = viewController.sj_scrollViewItem;
        scrollViewItem.intersection = self.heightForIntersectionBounds;
        scrollViewItem.contentOffset = scrollViewItem.scrollView.contentOffset;
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

/// childScrollView.contentInset.top
- (CGFloat)_maximumTopInsetForChildScrollView:(UIScrollView *)childScrollView {
    if ( _isResponse_maximumTopInsetForViewController ) {
        return [_delegate pageViewController:self maximumTopInsetForViewController:[childScrollView sj_page_lookupResponderForClass:UIViewController.class]];
    }
    return _maximumTopInset;
}

/// childScrollView.contentInset.bottom
- (CGFloat)_minimumBottomInsetForChildScrollView:(UIScrollView *)childScrollView {
    if ( _isResponse_minimumBottomInsetForViewController ) {
        return [_delegate pageViewController:self minimumBottomInsetForViewController:[childScrollView sj_page_lookupResponderForClass:UIViewController.class]];
    }
    return _minimumBottomInset;
}

- (CGFloat)heightForIntersectionBounds {
    if ( _headerView != nil ) {
        CGRect rect = [_headerView convertRect:_headerView.bounds toView:self.view];
        CGRect intersection = CGRectIntersection(self.view.bounds, rect);
        return (CGRectIsEmpty(intersection) || CGRectIsNull(intersection)) ? 0 : intersection.size.height;
    }
    return 0;
}

- (NSInteger)numberOfViewControllers {
    return _numberOfViewControllers;
}

- (CGFloat)heightForHeaderPinToVisibleBounds {
    if ( _isResponse_heightForHeaderPinToVisibleBounds ) {
        return [self.delegate heightForHeaderPinToVisibleBoundsWithPageViewController:self];
    }
    return 0;
}

- (SJPageViewControllerHeaderMode)modeForHeader {
    if ( _isResponse_modeForHeader )
        return [self.delegate modeForHeaderWithPageViewController:self];
    return 0;
}

- (__kindof UIView *_Nullable)headerView {
    return _headerView;
}

- (nullable __kindof UIViewController *)currentVisibleViewController {
    return [(SJPageViewControllerItemCell *)self.collectionView.visibleCells.lastObject viewController];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect bounds = self.view.bounds;
    if ( !CGRectEqualToRect(_previousBounds, bounds) ) {
        _previousBounds = bounds;
        [self _remakeConstraints];
    }
    if ( _isResponse_willLayoutSubviews ) {
        [_delegate pageViewControllerWillLayoutSubviews:self];
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
        
        NSRange range = NSMakeRange(left, right - left);
        
        if ( _isResponse_didScrollInRange )
            [self.delegate pageViewController:self didScrollInRange:NSMakeRange(left, right - left) distanceProgress:progress];
#if __has_include("SJPageMenuBar.h")
        else if ( _pageMenuBar != nil )
            [_pageMenuBar scrollInRange:range distanceProgress:progress];
#endif
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
        [_headerView sj_lock];
        _headerView.frame = frame;
        [_headerView sj_unlock];
        if ( _headerView.superview != self.view ) {
            [self.view insertSubview:_headerView aboveSubview:_collectionView];
        }
    }
}

- (void)_insertHeaderViewForFocusedViewController {
    if ( _hasHeader ) {
        // 停止滑动时, 将 headerView 恢复到 child scrollView 中
        UIScrollView *childScrollView = self.focusedViewController.sj_scrollViewItem.scrollView;
        CGRect frame = [_headerView.superview convertRect:_headerView.frame toView:childScrollView];
//        frame.size = CGSizeMake(self.view.bounds.size.width, self.heightForHeaderBounds);
        [_headerView sj_lock];
        _headerView.frame = frame;
        [_headerView sj_unlock];
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

- (void)_setupContentInsetForChildScrollView:(UIScrollView *)childScrollView {
    if ( !childScrollView ) return;
    CGFloat heightForHeaderBounds = self.heightForHeaderBounds;
    CGFloat heightForHeaderPinToVisibleBounds = self.heightForHeaderPinToVisibleBounds;

    CGFloat minimumBottomInset = [self _minimumBottomInsetForChildScrollView:childScrollView];
    CGFloat maximumTopInset = [self _maximumTopInsetForChildScrollView:childScrollView];
    
    CGRect bounds = self.view.bounds;
    CGFloat boundsHeight = bounds.size.height;
    CGFloat contentHeight = childScrollView.contentSize.height;
    
    CGFloat topInset = heightForHeaderBounds + maximumTopInset;
    CGFloat bottomInset = minimumBottomInset;
    if ( contentHeight < boundsHeight ) {
        bottomInset = ceil(boundsHeight - contentHeight - heightForHeaderPinToVisibleBounds);
    }
    if ( bottomInset < minimumBottomInset ) bottomInset = minimumBottomInset;
    
    UIEdgeInsets insets = childScrollView.contentInset;
    if ( insets.top != topInset || insets.bottom != bottomInset ) {
        insets.top = topInset;
        insets.bottom = bottomInset;
        childScrollView.contentInset = insets;
    }
}

- (void)_setNeedsReloadPageViewController {
    _needsReloadPageViewController = YES;
    [self performSelectorOnMainThread:@selector(_reloadPageViewControllerIfNeeded) withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
}

- (void)_reloadPageViewControllerIfNeeded {
    if ( _needsReloadPageViewController ) {
        [self _reloadPageViewController];
    }
}

- (void)_reloadPageViewController {
    _needsReloadPageViewController = NO;
     
    [self _removeHeaderView];
    [self _removeViewControllers];
    [self _reloadViewControllers];
    if ( _numberOfViewControllers != 0 ) [self _reloadHeaderView];
    [self _fixFocusedIndex];
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
    
    [self.collectionView reloadData];
    [self setViewControllerAtIndex:self.focusedIndex];
}

- (void)_fixFocusedIndex {
    if ( _numberOfViewControllers != 0 ) {
        NSInteger focusedIndex = _focusedIndex;
        if ( focusedIndex == NSNotFound )
            focusedIndex = 0;
        else if ( focusedIndex >= _numberOfViewControllers )
            focusedIndex = _numberOfViewControllers - 1;
        [self setViewControllerAtIndex:focusedIndex];
    }
}

- (void)_reloadViewControllers {
    _numberOfViewControllers = [_dataSource numberOfViewControllersInPageViewController:self];
    [self.collectionView reloadData];
}

- (void)_reloadHeaderView {
    if ( _isResponse_viewForHeader ) {
        _headerView = [_dataSource viewForHeaderInPageViewController:self];
        if ( _headerView != nil ) {
            _hasHeader = YES;
            UIView *target = [_headerView conformsToProtocol:@protocol(SJPageViewControllerHeaderViewProtocol)] ? [(id<SJPageViewControllerHeaderViewProtocol>)_headerView contentView] : _headerView;
            [target addObserver:self forKeyPath:kBounds options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:(void *)&kBounds];
            [target addObserver:self forKeyPath:kFrame options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:(void *)&kFrame];
        }
    }
}

- (void)_removeViewControllers {
    for ( UIViewController *vc in self.viewControllers.allValues ) {
        SJPageScrollViewItem *item = vc.sj_scrollViewItem;
        if ( item != nil ) {
            [item.scrollView.panGestureRecognizer removeObserver:self forKeyPath:kState];
            [item.scrollView removeObserver:self forKeyPath:kContentOffset];
            vc.sj_scrollViewItem = nil;
        }
    }
    [self.viewControllers removeAllObjects];
}

- (void)_removeHeaderView {
    if ( _headerView != nil ) {
        UIView *target = [_headerView conformsToProtocol:@protocol(SJPageViewControllerHeaderViewProtocol)] ? [(id<SJPageViewControllerHeaderViewProtocol>)_headerView contentView] : _headerView;
        [target removeObserver:self forKeyPath:kBounds];
        [target removeObserver:self forKeyPath:kFrame];
        [_headerView removeFromSuperview];
        _headerView = nil;
        _hasHeader = NO;
    }
}

- (void)_removePageChildViewController:(UIViewController *)viewController {
    if ( viewController == nil ) return;
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
    [viewController didMoveToParentViewController:nil];
}
@end

@implementation SJPageItem {
    CGSize _size;
    UIViewController *(^_Nullable _viewControllerLoader)(void);
    UIView<SJPageMenuItemView> *(^_Nullable _menuViewLoader)(void);
}

- (instancetype)initWithViewControllerLoader:(nullable UIViewController *_Nullable(^)(void))viewControllerLoader menuViewLoader:(nullable UIView<SJPageMenuItemView> *_Nullable(^)(void))menuViewLoader {
    return [self initWithTag:0 viewControllerLoader:viewControllerLoader menuViewLoader:menuViewLoader];
}
- (instancetype)initWithViewControllerLoader:(nullable UIViewController *_Nullable(^)(void))viewControllerLoader {
    return [self initWithTag:0 viewControllerLoader:viewControllerLoader menuViewLoader:nil];
}
- (instancetype)initWithViewController:(nullable UIViewController *)viewController menuView:(nullable UIView<SJPageMenuItemView> *)menuView {
    return [self initWithTag:0 viewController:viewController menuView:menuView];
}
- (instancetype)initWithViewController:(nullable UIViewController *)viewController {
    return [self initWithTag:0 viewController:viewController menuView:nil];
}

- (instancetype)initWithMenuViewLoader:(nullable UIView<SJPageMenuItemView> *_Nullable(^)(void))menuViewLoader {
    return [self initWithTag:0 viewControllerLoader:nil menuViewLoader:menuViewLoader];
}
- (instancetype)initWithMenuView:(nullable UIView<SJPageMenuItemView> *)menuView {
    return [self initWithTag:0 viewController:nil menuView:menuView];
}

- (instancetype)initWithTag:(NSInteger)tag viewControllerLoader:(nullable UIViewController *_Nullable(^)(void))viewControllerLoader menuViewLoader:(nullable UIView<SJPageMenuItemView> *_Nullable(^)(void))menuViewLoader {
    self = [self initWithTag:tag];
    if ( self ) {
        if ( viewControllerLoader != nil ) _viewControllerLoader = viewControllerLoader;
        if ( menuViewLoader != nil ) _menuViewLoader = menuViewLoader;
    }
    return self;
}
- (instancetype)initWithTag:(NSInteger)tag viewControllerLoader:(nullable UIViewController *_Nullable(^)(void))viewControllerLoader {
    return [self initWithTag:tag viewControllerLoader:viewControllerLoader menuViewLoader:nil];
}
- (instancetype)initWithTag:(NSInteger)tag viewController:(nullable UIViewController *)viewController menuView:(nullable UIView<SJPageMenuItemView> *)menuView {
    self = [self initWithTag:tag];
    if ( self ) {
        if ( viewController != nil ) _viewController = viewController;
        if ( menuView != nil ) _menuView = menuView;
    }
    return self;
}
- (instancetype)initWithTag:(NSInteger)tag viewController:(nullable UIViewController *)viewController {
    return [self initWithTag:tag viewController:viewController menuView:nil];
}
- (instancetype)initWithTag:(NSInteger)tag menuViewLoader:(nullable UIView<SJPageMenuItemView> *_Nullable(^)(void))menuViewLoader {
    return [self initWithTag:tag viewControllerLoader:nil menuViewLoader:menuViewLoader];
}
- (instancetype)initWithTag:(NSInteger)tag menuView:(nullable UIView<SJPageMenuItemView> *)menuView {
    return [self initWithTag:tag viewController:nil menuView:menuView];
}
- (instancetype)initWithTag:(NSInteger)tag {
    self = [super init];
    if ( self ) {
        if ( tag != 0 ) _tag = tag;
    }
    return self;
}
 
@synthesize menuView = _menuView;
- (nullable __kindof UIView<SJPageMenuItemView> *)menuView {
    if ( _menuView == nil && _menuViewLoader != nil ) {
        _menuView = _menuViewLoader();
    }
    return _menuView;
}

@synthesize viewController = _viewController;
- (nullable __kindof UIViewController *)viewController {
    if ( _viewController == nil && _viewControllerLoader != nil ) {
        _viewController = _viewControllerLoader();
    }
    return _viewController;
}

- (CGSize)sizeForMenuViewWithTransitionProgress:(CGFloat)transitionProgress {
    if ( _size.width == 0 ) {
        [self sizeToFit];
    }
    return _size;
}

- (void)sizeToFit {
    UIView<SJPageMenuItemView> *view = [self menuView];
    [view sizeToFit];
    _size = view.bounds.size;
}
@end

@implementation SJPageItemManager {
    NSMutableArray<SJPageItem *> *_items;
}

- (NSInteger)numberOfPageItems {
    return _items.count;
}

- (nullable __kindof UIViewController *)viewControllerAtIndex:(NSInteger)index {
    if ( [self _isGettingSafeIndex:index] ) {
        return _items[index].viewController;
    }
    return nil;
}

- (nullable __kindof UIView<SJPageMenuItemView> *)menuViewAtIndex:(NSInteger)index {
    if ( [self _isGettingSafeIndex:index] ) {
        return _items[index].menuView;
    }
    return nil;
}

- (nullable SJPageItem *)pageItemForTag:(NSInteger)tag {
    for ( SJPageItem *item in _items ) {
        if ( item.tag == tag )
            return item;
    }
    return nil;
}

- (nullable SJPageItem *)pageItemForViewController:(UIViewController *)viewController {
    for ( SJPageItem *item in _items ) {
        if ( item.viewController == viewController )
            return item;
    }
    return nil;
}

- (nullable SJPageItem *)pageItemAtIndex:(NSInteger)index {
    return _items[index];
}

- (CGSize)sizeForMenuViewAtIndex:(NSInteger)index transitionProgress:(CGFloat)transitionProgress {
    return [_items[index] sizeForMenuViewWithTransitionProgress:transitionProgress];
}

- (void)addPageItem:(SJPageItem *)pageItem {
    if ( pageItem == nil )
        return;
    if ( _items == nil )
        _items = NSMutableArray.array;
    [_items addObject:pageItem];
}

- (void)addPageItemWithType:(NSInteger)type viewController:(UIViewController *)viewController menuView:(UIView<SJPageMenuItemView> *)menuView {
    return [self addPageItem:[SJPageItem.alloc initWithTag:type viewController:viewController menuView:menuView]];
}

- (void)removeAllPageItems {
    [_items removeAllObjects];
}

#pragma mark - mark

- (BOOL)_isGettingSafeIndex:(NSInteger)index {
    return index >= 0 && index < _items.count;
}

@end


NS_ASSUME_NONNULL_END
