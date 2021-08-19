//
//  SJPageMenuBar.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJPageMenuBar.h"
#import "SJPageMenuBarScrollIndicator.h"
#import "SJPageMenuBarSubclass.h"
#import "UIColor+SJPageMenuBarExtended.h"
#import "SJPageViewController.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJPageMenuBarGestureHandler : NSObject<SJPageMenuBarGestureHandler>

@end

@implementation SJPageMenuBarGestureHandler
@synthesize singleTapHandler = _singleTapHandler;
@end


@interface SJPageMenuBar ()
@property (nonatomic, weak, nullable) SJPageViewController *pageViewController;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, nullable) NSMutableArray<__kindof UIView<SJPageMenuItemView> *> *itemViews;
@property (nonatomic, strong, nullable) CAGradientLayer *fadeMaskLayer;
@property (nonatomic) NSUInteger focusedIndex;
@property (nonatomic) CGRect previousBounds;
@property (nonatomic) BOOL needsReloadData;
@end

@implementation SJPageMenuBar
@synthesize focusedIndex = _focusedIndex;
@synthesize itemTintColor = _itemTintColor;
@synthesize focusedItemTintColor = _focusedItemTintColor;
@synthesize scrollIndicatorTintColor = _scrollIndicatorTintColor;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        [self _setupViews];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if ( self ) {
        [self _setupViews];
    }
    return self;
}

- (void)setFocusedIndex:(NSUInteger)focusedIndex {
    [self _reloadDataIfNeeded];
    if ( [self _isSafeIndexForGetting:focusedIndex] && focusedIndex != _focusedIndex ) {
        _focusedIndex = focusedIndex;
        
        [_itemViews enumerateObjectsUsingBlock:^(UIView<SJPageMenuItemView> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.focusedMenuItem = idx == focusedIndex;
        }];
         
        if ( [self.delegate respondsToSelector:@selector(pageMenuBar:focusedIndexDidChange:)] ) {
            [self.delegate pageMenuBar:self focusedIndexDidChange:focusedIndex];
        }
        else if ( self.pageViewController != nil && ![self.pageViewController isViewControllerVisibleAtIndex:focusedIndex] ) {
            [self.pageViewController setViewControllerAtIndex:focusedIndex];
        }
    }
}

#pragma mark -

- (void)scrollToItemAtIndex:(NSUInteger)toIdx animated:(BOOL)animated {
    [self _reloadDataIfNeeded];
    if ( [self _isSafeIndexForGetting:toIdx] && _focusedIndex != toIdx ) {
        NSUInteger previousIdx = self.focusedIndex;
        [self _performWithAnimated:animated actions:^{
            [self _remakeConstraintsWithBeginIndex:MIN(toIdx, previousIdx) focusedIndex:toIdx];
            [self _setContentOffsetForScrollViewToIndex:toIdx];
            self.focusedIndex = toIdx;
        }];
    }
}

- (void)scrollInRange:(NSRange)range distanceProgress:(CGFloat)progress {
    [self _reloadDataIfNeeded];

    if ( [self _isSafeIndexForGetting:range.location] && [self _isSafeIndexForGetting:NSMaxRange(range)] ) {
        [self _scrollInRange:range distanceProgress:progress];
    }
}

#pragma mark -

- (void)reloadData {
    self.needsReloadData = YES;
    [self _reloadDataIfNeeded];
}

- (nullable __kindof UIView<SJPageMenuItemView> *)viewForItemAtIndex:(NSUInteger)index {
    return [self _isSafeIndexForGetting:index] ? _itemViews[index] : nil;
}

- (nullable __kindof UIView<SJPageMenuItemView> *)viewForItemAtPoint:(CGPoint)location {
    return [self viewForItemAtIndex:[self indexOfItemViewAtPoint:location]];
}

- (NSInteger)indexOfItemView:(UIView<SJPageMenuItemView> *)itemView {
    if ( itemView != nil )
        return [_itemViews indexOfObject:itemView];
    return NSNotFound;
}

- (NSInteger)indexOfItemViewAtPoint:(CGPoint)location {
    __block NSInteger retv = NSNotFound;
    [_itemViews enumerateObjectsUsingBlock:^(UIView<SJPageMenuItemView> * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( CGRectContainsPoint(view.frame, CGPointMake(location.x, view.frame.origin.y)) ) {
            retv = idx;
            *stop = YES;
        }
    }];
    return retv;
}

- (NSUInteger)numberOfItems {
    return _itemViews.count;
}

#pragma mark -

- (void)insertItemAtIndex:(NSUInteger)index animated:(BOOL)animated {
    [self _reloadDataIfNeeded];
    if ( [self _isSafeIndexForInserting:index] ) {
        UIView<SJPageMenuItemView> *newView = [_dataSource pageMenuBar:self viewForItemAtIndex:index];
        [_itemViews insertObject:newView atIndex:index];
        [self.scrollView insertSubview:newView atIndex:index];
        [newView sizeToFit];

        __auto_type preView = [self viewForItemAtIndex:index - 1];
        CGRect frame = newView.frame;
        frame.origin.x = CGRectGetMaxX(preView.frame) - frame.size.width;
        frame.origin.y = (CGRectGetHeight(self.scrollView.bounds) - CGRectGetHeight(frame)) * 0.5;
        newView.frame = frame;
        newView.alpha = 0.001;
        
        [self _performWithAnimated:animated actions:^{
            newView.alpha = 1;
            NSUInteger focusedIndex = [self _fixedFocusedIndex];
            [self _remakeConstraintsWithBeginIndex:index focusedIndex:focusedIndex];
            self.focusedIndex = focusedIndex;
        }];
    }
}

- (void)deleteItemAtIndex:(NSUInteger)index animated:(BOOL)animated {
    [self _reloadDataIfNeeded];
    __auto_type view = [self viewForItemAtIndex:index];
    if ( view != nil ) {
        [self _performWithAnimated:animated actions:^{
            [self.itemViews removeObjectAtIndex:index];
            view.alpha = 0.001;
            NSUInteger focusedIndex = [self _fixedFocusedIndex];
            [self _remakeConstraintsWithBeginIndex:index != 0 ? (index - 1) : 0 focusedIndex:focusedIndex];
            [self _remakeConstraintsForScrollIndicatorWithFocusedIndex:focusedIndex];
            self.focusedIndex = focusedIndex;
        } completion:^(BOOL finished) {
            // remove
            [view removeFromSuperview];
            view.alpha = 1;
        }];
    }
}

- (void)reloadItemAtIndex:(NSUInteger)index animated:(BOOL)animated {
    [self _reloadDataIfNeeded];
    if ( [self _isSafeIndexForGetting:index] ) {
        UIView<SJPageMenuItemView> *view = [_dataSource pageMenuBar:self viewForItemAtIndex:index];
        if ( view != nil ) {
            [_itemViews replaceObjectAtIndex:index withObject:view];
            [self _performWithAnimated:animated actions:^{
                [view sizeToFit];
                [self _remakeConstraintsWithBeginIndex:index focusedIndex:self.focusedIndex];
            }];
        }
    }
}

- (void)moveItemAtIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex animated:(BOOL)animated {
    [self _reloadDataIfNeeded];
    if ( index == newIndex ) return;
    if ( [self _isSafeIndexForGetting:index] && [self _isSafeIndexForGetting:newIndex] ) {
        [self _performWithAnimated:animated actions:^{
            [self.itemViews exchangeObjectAtIndex:index withObjectAtIndex:newIndex];
            [self.scrollView exchangeSubviewAtIndex:index withSubviewAtIndex:newIndex];
            NSInteger focusedIndex = self.focusedIndex;
            if      ( index == self.focusedIndex ) focusedIndex = newIndex;
            else if ( newIndex == self.focusedIndex ) focusedIndex = index;
            [self _remakeConstraintsWithBeginIndex:MIN(index, newIndex) focusedIndex:focusedIndex];
            self.focusedIndex = focusedIndex;
        }];
    }
}
 
#pragma mark -

- (void)setDataSource:(nullable id<SJPageMenuBarDataSource>)dataSource {
    if ( dataSource != _dataSource ) {
        _dataSource = dataSource;
        self.needsReloadData = YES;
    }
}

- (void)setNeedsReloadData:(BOOL)needsReloadData {
    if ( needsReloadData != _needsReloadData ) {
        _needsReloadData = needsReloadData;
        
        if ( needsReloadData ) {
            [self performSelectorOnMainThread:@selector(_reloadDataIfNeeded) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)setDistribution:(SJPageMenuBarDistribution)distribution {
    if ( distribution != _distribution ) {
        _distribution = distribution;
        [self _remakeConstraints];
    }
} 

- (void)setItemSpacing:(CGFloat)itemSpacing {
    if ( _itemSpacing != itemSpacing ) {
        _itemSpacing = itemSpacing;
        [self _remakeConstraints];
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    if ( !UIEdgeInsetsEqualToEdgeInsets(contentInsets, _contentInsets) ) {
        _contentInsets = contentInsets;
        _scrollView.contentInset = contentInsets;
        [self _remakeConstraints];
    }
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale {
    if ( _minimumZoomScale != minimumZoomScale ) {
        _minimumZoomScale = minimumZoomScale;
        [self _remakeConstraints];
    }
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale {
    if ( _maximumZoomScale != maximumZoomScale ) {
        _maximumZoomScale = maximumZoomScale;
        [self _remakeConstraints];
    }
}

- (void)setShowsScrollIndicator:(BOOL)showsScrollIndicator {
    _scrollIndicator.hidden = !showsScrollIndicator;
}

- (void)setItemTintColor:(nullable UIColor *)itemTintColor {
    _itemTintColor = itemTintColor;
    [self _resetTintColorForMenuItemViews];
}

- (void)setFocusedItemTintColor:(nullable UIColor *)focusedItemTintColor {
    _focusedItemTintColor = focusedItemTintColor;
    [self _resetTintColorForMenuItemViews];
}

- (void)setScrollIndicatorSize:(CGSize)scrollIndicatorSize {
    if ( !CGSizeEqualToSize(scrollIndicatorSize, _scrollIndicatorSize) ) {
        _scrollIndicatorSize = scrollIndicatorSize;
        [self _remakeConstraintsForScrollIndicatorWithFocusedIndex:self.focusedIndex];
    }
}

- (void)setScrollIndicatorExpansionSize:(CGSize)scrollIndicatorExpansionSize {
    if ( !CGSizeEqualToSize(scrollIndicatorExpansionSize, _scrollIndicatorExpansionSize) ) {
        _scrollIndicatorExpansionSize = scrollIndicatorExpansionSize;
        [self _remakeConstraintsForScrollIndicatorWithFocusedIndex:self.focusedIndex];
    }
}

- (void)setScrollIndicatorBottomInset:(CGFloat)scrollIndicatorBottomInset {
    if ( scrollIndicatorBottomInset != _scrollIndicatorBottomInset ) {
        _scrollIndicatorBottomInset = scrollIndicatorBottomInset;
        [self _remakeConstraintsForScrollIndicatorWithFocusedIndex:self.focusedIndex];
    }
}

- (void)setScrollIndicatorTintColor:(nullable UIColor *)scrollIndicatorTintColor {
    _scrollIndicatorTintColor = scrollIndicatorTintColor;
    _scrollIndicator.backgroundColor = self.scrollIndicatorTintColor;
}

- (void)setScrollIndicatorLayoutMode:(SJPageMenuBarScrollIndicatorLayoutMode)scrollIndicatorLayoutMode {
    _scrollIndicatorLayoutMode = scrollIndicatorLayoutMode;
    [self _remakeConstraintsForScrollIndicatorWithFocusedIndex:self.focusedIndex];
}

- (void)setBaselineOffset:(CGFloat)baselineOffset {
    if ( baselineOffset != _baselineOffset ) {
        _baselineOffset = baselineOffset;
        [self _remakeConstraints];
    }
}

- (void)setEnabledFadeIn:(BOOL)enabledFadeIn {
    if ( enabledFadeIn != _enabledFadeIn ) {
        _enabledFadeIn = enabledFadeIn;
        [self _resetMask];
    }
}

- (void)setEnabledFadeOut:(BOOL)enabledFadeOut {
    if ( enabledFadeOut != _enabledFadeOut ) {
        _enabledFadeOut = enabledFadeOut;
        [self _resetMask];
    }
}

- (void)setScrollIndicator:(nullable UIView<SJPageMenuBarScrollIndicator> *)scrollIndicator {
    if ( _scrollIndicator != scrollIndicator ) {
        [_scrollIndicator removeFromSuperview];
        _scrollIndicator = scrollIndicator;
        [self.scrollView addSubview:self.scrollIndicator];
        if ( [self _isSafeIndexForGetting:_focusedIndex] )
            [self _remakeConstraintsForScrollIndicatorWithFocusedIndex:_focusedIndex];
    }
}

#pragma mark -
 
- (UIColor *)itemTintColor {
    if ( _itemTintColor == nil ) {
        _itemTintColor = UIColor.systemGrayColor;
    }
    return _itemTintColor;
}

- (UIColor *)focusedItemTintColor {
    if ( _focusedItemTintColor == nil ) {
        _focusedItemTintColor = UIColor.systemBlueColor;
    }
    return _focusedItemTintColor;
}

- (BOOL)showsScrollIndicator {
    return !_scrollIndicator.isHidden;
}

- (UIColor *)scrollIndicatorTintColor {
    if ( _scrollIndicatorTintColor == nil ) {
        _scrollIndicatorTintColor = UIColor.systemBlueColor;
    }
    return _scrollIndicatorTintColor;
}

#pragma mark -
 
- (void)_setupViews {
    _distribution = SJPageMenuBarDistributionEqualSpacing;
    _focusedIndex = NSNotFound;
    _itemSpacing = 16;
    _minimumZoomScale = 1.0;
    _maximumZoomScale = 1.0;
    _scrollIndicatorSize = CGSizeMake(12, 2);
    _scrollIndicatorBottomInset = 3.0;
    if ( @available(iOS 13.0, *) )
        self.backgroundColor = UIColor.systemGroupedBackgroundColor;
    else
        self.backgroundColor = UIColor.groupTableViewBackgroundColor;

    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.scrollIndicator];
    
    UITapGestureRecognizer *tap = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(_handleTap:)];
    [self.scrollView addGestureRecognizer:tap];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    if ( !CGRectEqualToRect(self.previousBounds, bounds) ) {
        self.previousBounds = bounds;
        _scrollView.frame = bounds;
        [self _resetMask];
        [self _remakeConstraints];
        [self _setContentOffsetForScrollViewToIndex:_focusedIndex];
    }
    
    if ( _layoutSubviewsExecuteBlock != nil ) _layoutSubviewsExecuteBlock(self);
}

@synthesize scrollIndicator = _scrollIndicator;
- (UIView<SJPageMenuBarScrollIndicator> *)scrollIndicator {
    if ( _scrollIndicator == nil ) {
        _scrollIndicator = [SJPageMenuBarScrollIndicator.alloc initWithFrame:CGRectZero];
        _scrollIndicator.backgroundColor = self.scrollIndicatorTintColor;
    }
    return _scrollIndicator;
}

@synthesize scrollView = _scrollView;
- (UIScrollView *)scrollView {
    if ( _scrollView == nil ) {
        _scrollView = [UIScrollView.alloc initWithFrame:CGRectZero];
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (id<SJPageMenuBarGestureHandler>)gestureHandler {
    if ( _gestureHandler == nil ) {
        _gestureHandler = SJPageMenuBarGestureHandler.alloc.init;
        // 默认实现为: 点击之后滚动过去
        _gestureHandler.singleTapHandler = ^(SJPageMenuBar * _Nonnull bar, CGPoint location) {
            [bar scrollToItemAtIndex:[bar indexOfItemViewAtPoint:location] animated:YES];
        };
    }
    return _gestureHandler;
}

#pragma mark -

- (BOOL)_isSafeIndexForInserting:(NSUInteger)index {
    return index <= self.numberOfItems;
}

- (BOOL)_isSafeIndexForGetting:(NSUInteger)index {
    return index < self.numberOfItems;
}

- (void)_reloadDataIfNeeded {
    if ( !_needsReloadData )
        return;
    
    _needsReloadData = NO;
    
    // clean
    if ( _itemViews.count != 0 ) {
        [_itemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_itemViews removeAllObjects];
    }
    
    if ( _dataSource == nil )
        return;
    
    if ( _itemViews == nil ) {
        _itemViews = NSMutableArray.array;
    }
    
    NSUInteger nItems = [_dataSource numberOfItemsInPageMenuBar:self];
    for ( NSUInteger idx = 0 ; idx < nItems ; ++ idx ) {
        UIView<SJPageMenuItemView> *itemView = [_dataSource pageMenuBar:self viewForItemAtIndex:idx];
        [itemView sizeToFit];
        [_itemViews addObject:itemView];
        [self.scrollView addSubview:itemView];
    }
    
    NSUInteger focusedIndex = _focusedIndex;
    if ( focusedIndex != NSNotFound ) {
        if ( focusedIndex >= nItems ) {
            focusedIndex = nItems - 1;
        }
    }
    else if ( nItems != 0 ) {
        focusedIndex = 0;
    }
    
    [self _remakeConstraintsWithBeginIndex:0 focusedIndex:focusedIndex];
    self.focusedIndex = focusedIndex;
}

- (void)_remakeConstraints {
    [self _remakeConstraintsWithBeginIndex:0 focusedIndex:_focusedIndex];
}

- (void)_remakeConstraintsWithBeginIndex:(NSUInteger)index focusedIndex:(NSUInteger)focusedIndex {
    if ( self.bounds.size.height == 0 || self.bounds.size.width == 0 ) return;
    if ( [self _isSafeIndexForGetting:index] ) {
        [self _remakeConstraintsForMenuItemViewWithBeginIndex:index focusedIndex:focusedIndex];
        [self _remakeConstraintsForScrollIndicatorWithFocusedIndex:focusedIndex];
    }
}

- (void)_remakeConstraintsForMenuItemViewWithBeginIndex:(NSUInteger)safeIndex focusedIndex:(NSUInteger)focusedIndex {
    [self _remakeConstraintsForMenuItemViewWithBeginIndex:safeIndex zoomScale:^CGFloat(NSUInteger index) {
        return focusedIndex == index ? self.maximumZoomScale : self.minimumZoomScale;
    } transitionProgress:^CGFloat(NSUInteger index) {
        return focusedIndex == index ? 1 : 0;
    } tintColor:^UIColor * _Nonnull(NSUInteger index) {
        return focusedIndex == index ? self.focusedItemTintColor : self.itemTintColor;
    } baselineOffset:^CGFloat(NSUInteger index) {
        return focusedIndex == index ? 0 : self.baselineOffset;;
    }];
}

- (void)_remakeConstraintsForScrollIndicatorWithFocusedIndex:(NSInteger)focusedIndex {
    if ( self.bounds.size.height == 0 || self.bounds.size.width == 0 ) return;
    CGSize size = [self _sizeForScrollIndicatorAtIndex:focusedIndex];
    CGRect frame = (CGRect){0, 0, size};
    frame.origin.y = self.bounds.size.height - _scrollIndicatorBottomInset - _scrollIndicatorSize.height;
    frame.origin.x = [self viewForItemAtIndex:focusedIndex].center.x - frame.size.width * 0.5;
    self.scrollIndicator.frame = frame;
}

- (void)_scrollInRange:(NSRange)range distanceProgress:(CGFloat)progress {
    NSUInteger left = range.location;
    NSUInteger right = NSMaxRange(range);
    
    if      ( left == right || progress <= 0 ) {
        [self scrollToItemAtIndex:left animated:YES];
    }
    else if ( progress >= 1 ) {
        [self scrollToItemAtIndex:right animated:YES];
    }
    else {
        NSUInteger startIndexForRemakeConstraints = left;
        SJPageMenuBarScrollInRangeTransitionContext *context = nil;
        if ( [self.delegate respondsToSelector:@selector(pageMenuBar:tintColorForItemAtIndex:inContext:)] ) {
            context = [SJPageMenuBarScrollInRangeTransitionContext.alloc initWithRange:range distanceProgress:progress];
            startIndexForRemakeConstraints = 0;
        }
        CGFloat maximumZoomScale = _maximumZoomScale;
        CGFloat minimumZoomScale = _minimumZoomScale;
        [self _remakeConstraintsForMenuItemViewWithBeginIndex:startIndexForRemakeConstraints zoomScale:^CGFloat(NSUInteger index) {
            CGFloat zoomScaleLength = maximumZoomScale - minimumZoomScale;
            if      ( index == left )
                return maximumZoomScale - zoomScaleLength * progress;
            else if ( index == right )
                return minimumZoomScale + zoomScaleLength * progress;
            return minimumZoomScale;
        } transitionProgress:^CGFloat(NSUInteger index) {
            if      ( index == left )
                return 1 - progress;
            else if ( index == right )
                return progress;
            return 0;
        } tintColor:^UIColor * _Nonnull(NSUInteger index) {
            if      ( context != nil )
                return [self.delegate pageMenuBar:self tintColorForItemAtIndex:index inContext:context];
            else if ( index == left )
                return [self.itemTintColor transitionToColor:self.focusedItemTintColor progress:1 - progress];
            else if ( index == right )
                return [self.itemTintColor transitionToColor:self.focusedItemTintColor progress:progress];
            return self.itemTintColor;
        } baselineOffset:^CGFloat(NSUInteger index) {
            if      ( index == left )
                return self.baselineOffset * progress;
            else if ( index == right )
                return (1 - progress) * self.baselineOffset;
            return self.baselineOffset;
        }];
        
        __auto_type leftView = self.itemViews[left];
        __auto_type rightView = self.itemViews[right];
        CGSize leftSize = [self _sizeForScrollIndicatorAtIndex:left];
        CGSize rightSize = [self _sizeForScrollIndicatorAtIndex:right];
        CGFloat factor = 1 - ABS(rightSize.width - leftSize.width) / MAX(rightSize.width, leftSize.width);
        CGFloat distance = (CGRectGetMaxX(rightView.frame) - CGRectGetMinX(leftView.frame)) * factor;
        CGFloat indicatorWidth = 0;
        // 小于 0.5 开始变长
        if ( progress < 0.5 ) {
            indicatorWidth = leftSize.width * ( 1 - progress ) + rightSize.width * progress + distance * progress;
        }
        // 超过 0.5 开始缩小
        else {
            indicatorWidth = leftSize.width * ( 1 - progress ) + rightSize.width * progress + distance * ( 1 - progress);
        }
        CGFloat maxOffset = rightView.center.x - leftView.center.x;
        CGFloat currOffset = leftView.center.x + maxOffset * progress - indicatorWidth * 0.5;
        CGRect frame = self.scrollIndicator.frame;
        frame.size.width = indicatorWidth;
        frame.origin.x = currOffset;
        _scrollIndicator.frame = frame;
    }
}

- (void)_remakeConstraintsForMenuItemViewWithBeginIndex:(NSUInteger)safeIndex  zoomScale:(CGFloat(^NS_NOESCAPE)(NSUInteger index))zoomScaleBlock transitionProgress:(CGFloat(^NS_NOESCAPE)(NSUInteger index))transitionProgress tintColor:(UIColor *(^NS_NOESCAPE)(NSUInteger index))tintColorBlock baselineOffset:(CGFloat(^NS_NOESCAPE)(NSUInteger index))baselineOffsetBlock {
    if ( self.bounds.size.height == 0 || self.bounds.size.width == 0 ) return;
    CGFloat contentLayoutHeight = self.bounds.size.height - self.contentInsets.top - self.contentInsets.bottom;
    CGFloat contentLayoutWidth = self.bounds.size.width - _contentInsets.left - _contentInsets.right;
    CGFloat itemWidth = contentLayoutWidth / self.numberOfItems;
    CGFloat itemSpacing = _distribution == SJPageMenuBarDistributionEqualSpacing ? _itemSpacing : 0;
    UIView<SJPageMenuItemView> *prev = [self viewForItemAtIndex:safeIndex - 1];
    for (NSUInteger index = safeIndex ; index < _itemViews.count ; ++ index ) {
        __auto_type curr = _itemViews[index];
        // zoomScale
        CGFloat zoomScale = zoomScaleBlock(index);
        // transitionProgress
        CGFloat progress = transitionProgress(index);
        // tintColor
        UIColor *tintColor = tintColorBlock(index);
        // bounds
        CGRect bounds = curr.bounds;
        switch ( _distribution ) {
            case SJPageMenuBarDistributionEqualSpacing:
                break;
            case SJPageMenuBarDistributionFillEqually:
                bounds.size.width = itemWidth * 1 / zoomScale;
                break;
        }
        // center
        CGPoint center = CGPointZero;
        // center.x
        center.x = bounds.size.width * 0.5 * zoomScale;
        if ( prev != nil ) {
            CGFloat presx = prev.transform.a;
            center.x += prev.center.x + prev.bounds.size.width * 0.5 * presx + itemSpacing ;
        }
        // center.y
        center.y = contentLayoutHeight * 0.5 + baselineOffsetBlock(index);
        
        [self updateForItemView:curr zoomScale:zoomScale transitionProgress:progress tintColor:tintColor bounds:bounds center:center];
        prev = curr;
    }
    
    [self.scrollView setContentSize:CGSizeMake(CGRectGetMaxX(self.itemViews.lastObject.frame), self.bounds.size.height)];
}

- (void)_setContentOffsetForScrollViewToIndex:(NSUInteger)safeIndex {
    if ( _distribution == SJPageMenuBarDistributionFillEqually ) {
        return;
    }
    __auto_type toView = [self viewForItemAtIndex:safeIndex];
    CGFloat offsetX = toView.center.x + _centerPositionOffset - _scrollView.bounds.size.width * 0.5;
    CGFloat minX = -_scrollView.contentInset.left;
    CGFloat maxX = _scrollView.contentSize.width + _scrollView.contentInset.right - _scrollView.bounds.size.width;
    if ( offsetX > maxX )
        offsetX = maxX;
    if ( offsetX < minX )
        offsetX = minX;
    _scrollView.contentOffset = CGPointMake(offsetX, 0);
}
 
- (void)_resetTintColorForMenuItemViews {
    [self.itemViews enumerateObjectsUsingBlock:^(UIView<SJPageMenuItemView> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.tintColor = (idx == self.focusedIndex) ? self.focusedItemTintColor : self.itemTintColor;
    }];
}

- (void)_handleTap:(UITapGestureRecognizer *)tap {
    CGPoint location = [tap locationInView:tap.view];
    if ( self.gestureHandler.singleTapHandler != nil ) self.gestureHandler.singleTapHandler(self, location);
}

- (CGSize)_sizeForScrollIndicatorAtIndex:(NSUInteger)index {
    if ( self.numberOfItems == 0 ) return CGSizeZero;
    CGSize size = CGSizeZero;
    switch ( _scrollIndicatorLayoutMode ) {
        case SJPageMenuBarScrollIndicatorLayoutModeSpecifiedWidth:
            size = _scrollIndicatorSize;
            break;
        case SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewContentWidth: {
            size = [self.itemViews[index] sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
            size.height = _scrollIndicatorSize.height;
        }
            break;
        case SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewLayoutWidth:
            size = CGSizeMake(self.itemViews[index].bounds.size.width, _scrollIndicatorSize.height);
            break;
    }
    size.width += _scrollIndicatorExpansionSize.width;
    size.height += _scrollIndicatorExpansionSize.height;
    return size;
}

- (void)_performWithAnimated:(BOOL)animated actions:(void (^)(void))actions {
    [self _performWithAnimated:animated actions:actions completion:nil];
}

- (void)_performWithAnimated:(BOOL)animated actions:(void (^)(void))actions completion:(void(^_Nullable)(BOOL finished))completion {
    animated ? [UIView animateWithDuration:0.25 animations:actions completion:completion] : actions();
}

- (NSUInteger)_fixedFocusedIndex {
    if ( self.numberOfItems == 0 ) {
        return NSNotFound;
    }
    else if ( self.focusedIndex >= self.numberOfItems ) {
        return self.numberOfItems - 1;
    }
    return _focusedIndex;
}

- (void)_resetMask {
    if ( self.isEnabledFadeIn || self.isEnabledFadeOut ) {
        CGRect bounds = self.bounds;
        if ( bounds.size.width == 0 ) return;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if ( _fadeMaskLayer == nil ) {
            _fadeMaskLayer = CAGradientLayer.layer;
            _fadeMaskLayer.startPoint = CGPointMake(0, 0);
            _fadeMaskLayer.endPoint = CGPointMake(1, 0);
            _fadeMaskLayer.frame = self.bounds;
        }
        
        CGFloat width = 16;
        CGFloat widthCenti = width / bounds.size.width;
        
        NSMutableArray<NSNumber *> *locations = [NSMutableArray arrayWithCapacity:4];
        NSMutableArray<UIColor *> *colors = [NSMutableArray arrayWithCapacity:4];
        if ( self.isEnabledFadeIn ) {
            [locations addObjectsFromArray: @[@0.0, @(widthCenti)]];
            [colors addObjectsFromArray:@[
                (__bridge id)UIColor.clearColor.CGColor,
                (__bridge id)UIColor.whiteColor.CGColor,
            ]];
            
            [locations addObjectsFromArray:@[@(widthCenti), @(1 - widthCenti)]];
            [colors addObjectsFromArray:@[
                (__bridge id)UIColor.whiteColor.CGColor,
                (__bridge id)UIColor.whiteColor.CGColor,
            ]];
        }
        
        if ( self.isEnabledFadeOut ) {
            if ( !self.isEnabledFadeIn ) {
                [locations addObjectsFromArray:@[@(0), @(1 - widthCenti)]];
                [colors addObjectsFromArray:@[
                    (__bridge id)UIColor.whiteColor.CGColor,
                    (__bridge id)UIColor.whiteColor.CGColor,
                ]];
            }
            
            [locations addObjectsFromArray:@[@(1 - widthCenti), @1.0]];
            [colors addObjectsFromArray:@[
                (__bridge id)UIColor.whiteColor.CGColor,
                (__bridge id)UIColor.clearColor.CGColor,
            ]];
        }
        _fadeMaskLayer.locations = locations;
        _fadeMaskLayer.colors = colors;
        _fadeMaskLayer.frame = bounds;
        [CATransaction commit];

        if ( self.layer.mask != _fadeMaskLayer ) self.layer.mask = _fadeMaskLayer;
    }
    else if ( _fadeMaskLayer != nil ) {
        self.layer.mask = nil;
        _fadeMaskLayer = nil;
    }
}

#pragma mark - subclass

- (void)updateForItemView:(__kindof UIView<SJPageMenuItemView> *)itemView zoomScale:(CGFloat)scale transitionProgress:(CGFloat)progress tintColor:(UIColor *)tintColor bounds:(CGRect)bounds center:(CGPoint)center {
    itemView.transform = CGAffineTransformMakeScale(scale, scale);
    itemView.transitionProgress = progress;
    itemView.tintColor = tintColor;
    itemView.bounds = bounds;
    itemView.center = center;
}

@end

@implementation SJPageMenuBarScrollInRangeTransitionContext
- (instancetype)initWithRange:(NSRange)range distanceProgress:(CGFloat)progress {
    self = [super init];
    if ( self ) {
        _range = range;
        _distanceProgress = progress;
    }
    return self;
}
@end
NS_ASSUME_NONNULL_END
