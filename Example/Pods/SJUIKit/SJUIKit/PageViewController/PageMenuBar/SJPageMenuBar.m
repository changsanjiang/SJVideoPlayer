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

@interface SJPageMenuBarGestureHandler : NSObject<SJPageMenuBarGestureHandler>

@end

@implementation SJPageMenuBarGestureHandler
@synthesize singleTapHandler = _singleTapHandler;
@end


@interface SJPageMenuBar ()
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, nullable) CAGradientLayer *fadeMaskLayer;
@property (nonatomic) NSUInteger focusedIndex;
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
        if ( @available(iOS 13.0, *) )
            self.backgroundColor = UIColor.systemGroupedBackgroundColor;
        else
            self.backgroundColor = UIColor.groupTableViewBackgroundColor;
        [self _setupViews];
    }
    return self;
}

- (void)setFocusedIndex:(NSUInteger)focusedIndex {
    if ( focusedIndex != _focusedIndex ) {
        _focusedIndex = focusedIndex;
        
        [_itemViews enumerateObjectsUsingBlock:^(UIView<SJPageMenuItemView> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.focusedMenuItem = idx == focusedIndex;
        }];
        
        if ( [self.delegate respondsToSelector:@selector(pageMenuBar:focusedIndexDidChange:)] ) {
            [self.delegate pageMenuBar:self focusedIndexDidChange:focusedIndex];
        }
    }
}

#pragma mark -

- (void)scrollToItemAtIndex:(NSUInteger)toIdx animated:(BOOL)animated {
     if ( [self _isSafeIndex:toIdx] && _focusedIndex != toIdx ) {
         NSUInteger previousIdx = self.focusedIndex;
         [self _performWithAnimated:animated actions:^{
             [self _remakeConstraintsWithBeginIndex:MIN(toIdx, previousIdx) focusedIndex:toIdx];
             [self _setContentOffsetForScrollViewToIndex:toIdx];
             self.focusedIndex = toIdx;
         }];
     }
}

- (void)scrollInRange:(NSRange)range distanceProgress:(CGFloat)progress {
    if ( [self _isSafeIndex:range.location] && [self _isSafeIndex:NSMaxRange(range)] ) {
        [self _scrollInRange:range distanceProgress:progress];
    }
}

#pragma mark -

- (void)setItemViews:(nullable NSArray<__kindof UIView<SJPageMenuItemView> *> *)itemViews {
    if ( _itemViews != nil ) [_itemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _itemViews = itemViews.copy;
    for ( NSUInteger index = 0 ; index < itemViews.count ; ++ index ) {
        __auto_type itemView = itemViews[index];
        [itemView sizeToFit];
        [self.scrollView addSubview:itemView];
    }
    NSUInteger focusedIndex = (itemViews.count == 0) ? NSNotFound : 0;
    [self _remakeConstraintsWithBeginIndex:0 focusedIndex:focusedIndex];
    self.focusedIndex = focusedIndex;
}

- (nullable __kindof UIView<SJPageMenuItemView> *)viewForItemAtIndex:(NSUInteger)index {
    return [self _isSafeIndex:index] ? _itemViews[index] : nil;
}

- (NSUInteger)numberOfItems {
    return _itemViews.count;
}

#pragma mark -

- (void)insertItemAtIndex:(NSUInteger)index view:(__kindof UIView<SJPageMenuItemView> *)newView animated:(BOOL)animated {
    if ( newView == nil ) return;
    
    if ( [self _isSafeIndex:index] || index == self.numberOfItems ) {
        NSMutableArray *views = _itemViews != nil ? [_itemViews mutableCopy] : NSMutableArray.array;
        [views insertObject:newView atIndex:index];
        [self.scrollView insertSubview:newView atIndex:index];
        _itemViews = views.copy;
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
    __auto_type view = [self viewForItemAtIndex:index];
    if ( view != nil ) {
        [self _performWithAnimated:animated actions:^{
            NSMutableArray *views = [self->_itemViews mutableCopy];
            [views removeObjectAtIndex:index];
            self->_itemViews = views.copy;
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
    UIView<SJPageMenuItemView> *view = [self viewForItemAtIndex:index];
    if ( view != nil ) {
        [self _performWithAnimated:animated actions:^{
            [view sizeToFit];
            [self _remakeConstraintsWithBeginIndex:index focusedIndex:self.focusedIndex];
        }];
    }
}

- (void)moveItemAtIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex animated:(BOOL)animated {
    if ( index == newIndex ) return;
    if ( [self _isSafeIndex:index] && [self _isSafeIndex:newIndex] ) {
        [self _performWithAnimated:animated actions:^{
            NSMutableArray *views = [self->_itemViews mutableCopy];
            [views exchangeObjectAtIndex:index withObjectAtIndex:newIndex];
            self->_itemViews = views.copy;
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

- (void)setCenterlineOffset:(CGFloat)centerlineOffset {
    if ( centerlineOffset != _centerlineOffset ) {
        _centerlineOffset = centerlineOffset;
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
        if ( [self _isSafeIndex:_focusedIndex] )
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
            [bar.itemViews enumerateObjectsUsingBlock:^(UIView<SJPageMenuItemView> * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
                if ( CGRectContainsPoint(view.frame, CGPointMake(location.x, view.frame.origin.y)) ) {
                    [bar scrollToItemAtIndex:idx animated:YES];
                    *stop = YES;
                }
            }];
        };
    }
    return _gestureHandler;
}

#pragma mark -

- (BOOL)_isSafeIndex:(NSUInteger)index {
    return index < self.numberOfItems;
}

- (void)_remakeConstraints {
    [self _remakeConstraintsWithBeginIndex:0 focusedIndex:_focusedIndex];
}

- (void)_remakeConstraintsWithBeginIndex:(NSUInteger)index focusedIndex:(NSUInteger)focusedIndex {
    if ( self.bounds.size.height == 0 || self.bounds.size.width == 0 ) return;
    if ( [self _isSafeIndex:index] ) {
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
    } centerlineOffset:^CGFloat(NSUInteger index) {
        return focusedIndex == index ? 0 : self.centerlineOffset;;
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
        CGFloat maximumZoomScale = _maximumZoomScale;
        CGFloat minimumZoomScale = _minimumZoomScale;
        [self _remakeConstraintsForMenuItemViewWithBeginIndex:left zoomScale:^CGFloat(NSUInteger index) {
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
            if      ( index == left )
                return [self _gradientColorWithProgress:1 - progress];
            else if ( index == right )
                return [self _gradientColorWithProgress:progress];
            return self.itemTintColor;
        } centerlineOffset:^CGFloat(NSUInteger index) {
            if      ( index == left )
                return self.centerlineOffset * progress;
            else if ( index == right )
                return (1 - progress) * self.centerlineOffset;
            return self.centerlineOffset;
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

- (void)_remakeConstraintsForMenuItemViewWithBeginIndex:(NSUInteger)safeIndex  zoomScale:(CGFloat(^)(NSUInteger index))zoomScaleBlock transitionProgress:(CGFloat(^)(NSUInteger index))transitionProgress tintColor:(UIColor *(^)(NSUInteger index))tintColorBlock centerlineOffset:(CGFloat(^)(NSUInteger index))centerlineOffsetBlock {
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
        [self _setZoomScale:zoomScale forMenuItemViewAtIndex:index];
        
        // transitionProgress
        curr.transitionProgress = transitionProgress(index);
        
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
    
    [self.scrollView setContentSize:CGSizeMake(CGRectGetMaxX(self.itemViews.lastObject.frame), self.bounds.size.height)];
}

- (void)_setContentOffsetForScrollViewToIndex:(NSUInteger)safeIndex {
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

- (void)_setZoomScale:(CGFloat)zoomScale forMenuItemViewAtIndex:(NSUInteger)safeIndex {
    __auto_type view = self.itemViews[safeIndex];
    view.transform = CGAffineTransformMakeScale(zoomScale, zoomScale);
    view.sj_pageZoomScale = zoomScale;
}

struct color {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
};

// progress [0,1],  0 为 itemTintColor, 1 为 focusedTintColor, 相互转换
- (UIColor *)_gradientColorWithProgress:(CGFloat)progress {
    if ( [self.focusedItemTintColor isEqual:self.itemTintColor] ) return self.itemTintColor;
    
    struct color tintColor, focusedTintColor;
    [self.itemTintColor getRed:&tintColor.red green:&tintColor.green blue:&tintColor.blue alpha:&tintColor.alpha];
    [self.focusedItemTintColor getRed:&focusedTintColor.red green:&focusedTintColor.green blue:&focusedTintColor.blue alpha:&focusedTintColor.alpha];
    
    return [UIColor colorWithRed:tintColor.red + (focusedTintColor.red - tintColor.red) * progress
                            green:tintColor.green + (focusedTintColor.green - tintColor.green) * progress
                            blue:tintColor.blue + (focusedTintColor.blue - tintColor.blue) * progress
                           alpha:tintColor.alpha + (focusedTintColor.alpha - tintColor.alpha) * progress];
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
@end
NS_ASSUME_NONNULL_END
