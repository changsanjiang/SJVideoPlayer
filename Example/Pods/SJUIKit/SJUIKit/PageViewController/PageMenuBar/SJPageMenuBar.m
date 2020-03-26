//
//  SJPageMenuBar.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJPageMenuBar.h"
#import "SJPageMenuBarScrollIndicator.h"
#import "SJPageMenuItemView.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIView (SJPageMenuBarExtended)
@property (nonatomic) CGFloat sj_pageZoomScale;
@end

@implementation UIView (SJPageMenuBarExtended)
- (void)setSj_pageZoomScale:(CGFloat)sj_pageZoomScale {
    objc_setAssociatedObject(self, @selector(sj_pageZoomScale), @(sj_pageZoomScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGFloat)sj_pageZoomScale {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}
@end


@interface SJPageMenuBar ()
@property (nonatomic, strong, readonly) NSMutableArray<UIView<SJPageMenuItemView> *> *menuItemViews;
@property (nonatomic, strong, readonly) SJPageMenuBarScrollIndicator *scrollIndicator;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic) NSInteger focusedIndex;
@property (nonatomic) CGRect previousBounds;
@end

@implementation SJPageMenuBar
@synthesize focusedIndex = _focusedIndex;
@synthesize itemTintColor = _itemTintColor;
@synthesize focusedItemTintColor = _focusedItemTintColor;
@synthesize scrollIndicatorTintColor = _scrollIndicatorTintColor;
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _distribution = SJPageMenuBarDistributionEqualSpacing;
        _focusedIndex = NSNotFound;
        _itemSpacing = 16;
        _minimumZoomScale = 1.0;
        _maximumZoomScale = 1.0;
        _scrollIndicatorSize = CGSizeMake(12, 2);
        _scrollIndicatorBottomInset = 3.0;
        _menuItemViews = [NSMutableArray array];
        if ( @available(iOS 13.0, *) )
            self.backgroundColor = UIColor.systemGroupedBackgroundColor;
        else
            self.backgroundColor = UIColor.groupTableViewBackgroundColor;
        [self _setupViews];
    }
    return self;
}

- (nullable NSArray<UIView<SJPageMenuItemView> *> *)itemViews {
    return _menuItemViews.copy;
}

- (nullable __kindof UIView<SJPageMenuItemView> *)viewForItemAtIndex:(NSInteger)index {
    if ( [self _isSafeIndex:index] ) {
        return _menuItemViews[index];
    }
    return nil;
}

- (void)setItemViews:(nullable NSArray<UIView<SJPageMenuItemView> *> *)itemViews {
    [_menuItemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_menuItemViews removeAllObjects];
    if ( itemViews.count != 0 ) {
        [_menuItemViews addObjectsFromArray:itemViews];
        for ( NSInteger index = 0 ; index < itemViews.count ; ++ index ) {
            __auto_type itemView = itemViews[index];
            [itemView sizeToFit];
            [self.scrollView addSubview:itemView];
        }
    }
    self.focusedIndex = (itemViews.count == 0) ? NSNotFound : 0;
    [self _remakeConstraints];
}

- (NSInteger)numberOfItems {
    return _menuItemViews.count;
}

- (void)reloadItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    UIView<SJPageMenuItemView> *view = [self viewForItemAtIndex:index];
    if ( view != nil ) {
        [UIView animateWithDuration:animated ? 0.25 : 0 animations:^{
            [view sizeToFit];
            [self _remakeConstraintsWithBeginIndex:index];
        }];
    }
}

- (void)scrollToItemAtIndex:(NSInteger)toIdx animated:(BOOL)animated {
     if ( [self _isSafeIndex:toIdx] && _focusedIndex != toIdx ) {
         NSInteger previousIdx = self.focusedIndex;
         self.focusedIndex = toIdx;
         if ( self.bounds.size.height == 0 || self.bounds.size.width == 0 ) return;
         [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
             [self _remakeConstraintsForMenuItemViewWithBeginIndex:previousIdx < toIdx ? previousIdx : toIdx];
             [self _remakeConstraintsForScrollIndicator];
             [self _setContentOffsetForScrollViewToIndex:toIdx];
         }];
     }
}

- (void)scrollInRange:(NSRange)range distanceProgress:(CGFloat)progress {
    if ( [self _isSafeIndex:range.location] && [self _isSafeIndex:NSMaxRange(range)] ) {
        [self _scrollInRange:range distanceProgress:progress];
    }
}

#pragma mark -

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

- (void)setFocusedIndex:(NSInteger)focusedIndex {
    if ( focusedIndex != _focusedIndex ) {
        _focusedIndex = focusedIndex;
        
        [_menuItemViews enumerateObjectsUsingBlock:^(UIView<SJPageMenuItemView> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.focusedMenuItem = idx == focusedIndex;
        }];
        
        if ( [self.delegate respondsToSelector:@selector(pageMenuBar:focusedIndexDidChange:)] ) {
            [self.delegate pageMenuBar:self focusedIndexDidChange:focusedIndex];
        }
    }
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
        [self _remakeConstraintsForScrollIndicator];
    }
}

- (void)setScrollIndicatorBottomInset:(CGFloat)scrollIndicatorBottomInset {
    if ( scrollIndicatorBottomInset != _scrollIndicatorBottomInset ) {
        _scrollIndicatorBottomInset = scrollIndicatorBottomInset;
        [self _remakeConstraintsForScrollIndicator];
    }
}

- (void)setScrollIndicatorTintColor:(nullable UIColor *)scrollIndicatorTintColor {
    _scrollIndicatorTintColor = scrollIndicatorTintColor;
    _scrollIndicator.backgroundColor = self.scrollIndicatorTintColor;
}

- (void)setScrollIndicatorLayoutMode:(SJPageMenuBarScrollIndicatorLayoutMode)scrollIndicatorLayoutMode {
    _scrollIndicatorLayoutMode = scrollIndicatorLayoutMode;
    [self _remakeConstraintsForScrollIndicator];
}

- (void)setCenterlineOffset:(CGFloat)centerlineOffset {
    if ( centerlineOffset != _centerlineOffset ) {
        _centerlineOffset = centerlineOffset;
        [self _remakeConstraints];
    }
}

#pragma mark -

- (NSInteger)focusedIndex {
    return self.numberOfItems != 0 ? _focusedIndex : NSNotFound;
}
 
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
        [self _remakeConstraints];
        [self _setContentOffsetForScrollViewToIndex:_focusedIndex];
    }
}

@synthesize menuItemViews = _menuItemViews;
- (NSMutableArray<UIView<SJPageMenuItemView> *> *)menuItemViews {
    if ( _menuItemViews == nil ) {
        _menuItemViews = NSMutableArray.new;
    }
    return _menuItemViews;
}

@synthesize scrollIndicator = _scrollIndicator;
- (UIView *)scrollIndicator {
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

#pragma mark -

- (BOOL)_isSafeIndex:(NSInteger)index {
    return (index >= 0 && index < self.numberOfItems);
}

- (void)_reloadPageMenuBar {
    [self.menuItemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.menuItemViews removeAllObjects];
    
    if ( self.numberOfItems != 0 ) {
        for ( NSInteger index = 0 ; index < self.numberOfItems ; ++ index ) {
            __auto_type menuItemView = [self viewForItemAtIndex:index];
            [self.menuItemViews addObject:menuItemView];
            [self.scrollView addSubview:menuItemView];
        }
    }
    [self _remakeConstraints];
}

- (void)_remakeConstraints {
    [self _remakeConstraintsWithBeginIndex:0];
}

- (void)_remakeConstraintsWithBeginIndex:(NSInteger)index {
    if ( [self _isSafeIndex:index] ) {
        [self _remakeConstraintsForMenuItemViewWithBeginIndex:index];
        [self _remakeConstraintsForScrollIndicator];
    }
}

- (void)_remakeConstraintsForMenuItemViewWithBeginIndex:(NSInteger)safeIndex {
    [self _remakeConstraintsForMenuItemViewWithBeginIndex:safeIndex zoomScale:^CGFloat(NSInteger index) {
        return self.focusedIndex == index ? self.maximumZoomScale : self.minimumZoomScale;
    } tintColor:^UIColor * _Nonnull(NSInteger index) {
        return self.focusedIndex == index ? self.focusedItemTintColor : self.itemTintColor;
    } centerlineOffset:^CGFloat(NSInteger index) {
        return self.focusedIndex == index ? 0 : self.centerlineOffset;;
    }];
}

- (void)_remakeConstraintsForScrollIndicator {
    if ( self.bounds.size.height == 0 || self.bounds.size.width == 0 ) return;
    if ( self.menuItemViews.count <= _focusedIndex ) return;
    CGSize size = [self _sizeForScrollIndicatorAtIndex:_focusedIndex];
    CGRect frame = (CGRect){0, 0, size};
    frame.origin.y = self.bounds.size.height - _scrollIndicatorBottomInset - _scrollIndicatorSize.height;
    frame.origin.x = self.menuItemViews[_focusedIndex].center.x - frame.size.width * 0.5;
    _scrollIndicator.frame = frame;
}

- (void)_scrollInRange:(NSRange)range distanceProgress:(CGFloat)progress {
    NSInteger left = range.location;
    NSInteger right = NSMaxRange(range);
    
    if      ( left == right || progress <= 0 ) {
        [self scrollToItemAtIndex:left animated:YES];
    }
    else if ( progress >= 1 ) {
        [self scrollToItemAtIndex:right animated:YES];
    }
    else {
        CGFloat maximumZoomScale = _maximumZoomScale;
        CGFloat minimumZoomScale = _minimumZoomScale;
        [self _remakeConstraintsForMenuItemViewWithBeginIndex:left zoomScale:^CGFloat(NSInteger index) {
            CGFloat zoomScaleLength = maximumZoomScale - minimumZoomScale;
            // zoomScale
            if      ( index == left )
                return maximumZoomScale - zoomScaleLength * progress;
            else if ( index == right )
                return minimumZoomScale + zoomScaleLength * progress;
            return minimumZoomScale;
        } tintColor:^UIColor * _Nonnull(NSInteger index) {
            // tintColor
            if      ( index == left )
                return [self _gradientColorWithProgress:1 - progress];
            else if ( index == right )
                return [self _gradientColorWithProgress:progress];
            return self.itemTintColor;
        } centerlineOffset:^CGFloat(NSInteger index) {
            if      ( index == left )
                return self.centerlineOffset * progress;
            else if ( index == right )
                return (1 - progress) * self.centerlineOffset;
            return self.centerlineOffset;
        }];
        
        __auto_type leftView = self.menuItemViews[left];
        __auto_type rightView = self.menuItemViews[right];
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
        CGRect frame = _scrollIndicator.frame;
        frame.size.width = indicatorWidth;
        frame.origin.x = currOffset;
        _scrollIndicator.frame = frame;
    }
}

- (void)_remakeConstraintsForMenuItemViewWithBeginIndex:(NSInteger)safeIndex zoomScale:(CGFloat(^)(NSInteger index))zoomScaleBlock tintColor:(UIColor *(^)(NSInteger index))tintColorBlock centerlineOffset:(CGFloat(^)(NSInteger index))centerlineOffsetBlock {
    if ( self.bounds.size.height == 0 || self.bounds.size.width == 0 ) return;
    CGFloat contentLayoutHeight = self.bounds.size.height - self.contentInsets.top - self.contentInsets.bottom;
    CGFloat contentLayoutWidth = self.bounds.size.width - _contentInsets.left - _contentInsets.right;
    CGFloat itemWidth = contentLayoutWidth / self.numberOfItems;
    CGFloat itemSpacing = _distribution == SJPageMenuBarDistributionEqualSpacing ? _itemSpacing : 0;
    UIView<SJPageMenuItemView> *prev = safeIndex == 0 ? nil : _menuItemViews[safeIndex - 1];
    for (NSInteger index = safeIndex ; index < self.menuItemViews.count ; ++ index ) {
        __auto_type curr = self.menuItemViews[index];
        // zoomScale
        CGFloat zoomScale = zoomScaleBlock(index);
        [self _setZoomScale:zoomScale forMenuItemViewAtIndex:index];
        
        // tintColor
        UIColor *tintColor = tintColorBlock(index);
        curr.tintColor = tintColor;

        // bounds
        CGRect bounds = curr.bounds;
        switch ( _distribution ) {
            case SJPageMenuBarDistributionEqualSpacing:
                break;
            case SJPageMenuBarDistributionFillEqually:
                bounds.size.width = itemWidth * 1 / zoomScale;
                break;
        }
        curr.bounds = bounds;
        
        // center
        CGPoint center = CGPointZero;
        // center.x
        center.x = bounds.size.width * 0.5 * zoomScale;
        if ( prev != nil ) {
            CGFloat prez = prev.sj_pageZoomScale;
            center.x += prev.center.x + prev.bounds.size.width * 0.5 * prez + itemSpacing ;
        }
        // center.y
        center.y = contentLayoutHeight * 0.5 + centerlineOffsetBlock(index);

        curr.center = center;
        
        prev = curr;
    }
    
    [self.scrollView setContentSize:CGSizeMake(CGRectGetMaxX(self.menuItemViews.lastObject.frame), self.bounds.size.height)];
}

- (void)_setContentOffsetForScrollViewToIndex:(NSInteger)safeIndex {
    if ( _distribution == SJPageMenuBarDistributionFillEqually ) {
        return;
    }
    __auto_type toView = [self viewForItemAtIndex:safeIndex];
    CGFloat size = self.frame.size.width;
    CGFloat middle = size * 0.5;
    CGFloat min = middle;
    CGFloat max = _scrollView.contentSize.width - middle + _contentInsets.left + _contentInsets.right;
    CGFloat centerX = toView.center.x;
    if ( centerX < min || max < middle ) {
        centerX = -_contentInsets.left;
    }
    else if ( centerX > max ) {
        centerX = _scrollView.contentSize.width - size + _contentInsets.right;
    }
    else {
        centerX -= middle;
    }
    _scrollView.contentOffset = CGPointMake(centerX, 0);
}

struct color {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpah;
};

// progress [0,1],  0 为 itemTintColor, 1 为 focusedTintColor, 相互转换
- (UIColor *)_gradientColorWithProgress:(CGFloat)progress {
    if ( [self.focusedItemTintColor isEqual:self.itemTintColor] ) return self.itemTintColor;
    
    struct color tintColor, focusedTintColor;
    [self.itemTintColor getRed:&tintColor.red green:&tintColor.green blue:&tintColor.blue alpha:&tintColor.alpah];
    [self.focusedItemTintColor getRed:&focusedTintColor.red green:&focusedTintColor.green blue:&focusedTintColor.blue alpha:&focusedTintColor.alpah];
    
    return [UIColor colorWithRed:tintColor.red + (focusedTintColor.red - tintColor.red) * progress
                            green:tintColor.green + (focusedTintColor.green - tintColor.green) * progress
                            blue:tintColor.blue + (focusedTintColor.blue - tintColor.blue) * progress
                           alpha:tintColor.alpah + (focusedTintColor.alpah - tintColor.alpah) * progress];
}

- (void)_setZoomScale:(CGFloat)zoomScale forMenuItemViewAtIndex:(NSInteger)safeIndex {
    if ( _minimumZoomScale >= _maximumZoomScale ) zoomScale = _maximumZoomScale;
    __auto_type view = self.menuItemViews[safeIndex];
    view.transform = CGAffineTransformMakeScale(zoomScale, zoomScale);
    view.sj_pageZoomScale = zoomScale;
}

- (void)_resetTintColorForMenuItemViews {
    [self.menuItemViews enumerateObjectsUsingBlock:^(UIView<SJPageMenuItemView> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.tintColor = idx == self.focusedIndex ? self.focusedItemTintColor : self.itemTintColor;
    }];
}

- (void)_handleTap:(UITapGestureRecognizer *)tap {
    CGPoint location = [tap locationInView:tap.view];
    [self.menuItemViews enumerateObjectsUsingBlock:^(UIView<SJPageMenuItemView> * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( CGRectContainsPoint(view.frame, CGPointMake(location.x, view.frame.origin.y)) ) {
            [self scrollToItemAtIndex:idx animated:YES];
            *stop = YES;
        }
    }];
}

- (CGSize)_sizeForScrollIndicatorAtIndex:(NSInteger)index {
    CGSize size = CGSizeZero;
    switch ( _scrollIndicatorLayoutMode ) {
        case SJPageMenuBarScrollIndicatorLayoutModeSpecifiedWidth:
            size = _scrollIndicatorSize;
            break;
        case SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewContentWidth: {
            size = [self.menuItemViews[index] sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
            size.height = _scrollIndicatorSize.height;
        }
            break;
        case SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewLayoutWidth:
            size = CGSizeMake(self.menuItemViews[index].bounds.size.width, _scrollIndicatorSize.height);
            break;
    }
    return size;
}
@end
NS_ASSUME_NONNULL_END
