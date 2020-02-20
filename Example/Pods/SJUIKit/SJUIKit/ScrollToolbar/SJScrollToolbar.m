//
//  SJScrollToolbar.m
//  SJScrollToolbar
//
//  Created by 畅三江 on 2019/12/23.
//

#import "SJScrollToolbar.h"
#import "SJScrollToolbarItemView.h"
#import "SJScrollToolbarConfiguration.h"
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJScrollToolbar ()<SJScrollToolbarItemViewDelegate> {
    CGSize _previousSize;
}
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) NSMutableArray<SJScrollToolbarItemView *> *views;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong, readonly) UIView *line;
@end

@implementation SJScrollToolbar
@dynamic delegate;

- (instancetype)initWithConfiguration:(SJScrollToolbarConfiguration *)config frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _focusedIndex = NSNotFound;
        _views = [NSMutableArray array];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        _tapGesture = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(_handleTap:)];
        [self addGestureRecognizer:_tapGesture];
        
        _contentView = [UIView.alloc initWithFrame:CGRectZero];
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        
        _line = [UIView.alloc initWithFrame:CGRectZero];
        _line.hidden = YES;
        [self addSubview:_line];
        [self updateConfiguration:config animated:NO];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithConfiguration:SJScrollToolbarConfiguration.configuration frame:frame];
}

- (void)_handleTap:(UITapGestureRecognizer *)tap {
    CGPoint location = [tap locationInView:tap.view];
    [self.views enumerateObjectsUsingBlock:^(SJScrollToolbarItemView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( CGRectContainsPoint(view.frame, CGPointMake(location.x, view.frame.origin.y)) ) {
            [self scrollToItemAtIndex:idx animated:YES];
            *stop = YES;
        }
    }];
}

- (void)scrollToItemAtIndex:(NSInteger)idx animated:(BOOL)animated {
    if ( [self _isSafeIndex:idx] ) {
        if ( _focusedIndex != idx ) {
            [UIView animateWithDuration:animated ? self.configuration.animationDuration : 0.0 animations:^{
                [self _scrollToItemAtIndex:idx];
            }];
        }
    }
}

- (void)scrollInRange:(NSRange)range distanceProgress:(CGFloat)progress {
    if ( [self _isSafeIndex:NSMaxRange(range)] ) {
        [self _scrollInRange:range distanceProgress:progress];
    }
}

- (void)resetItems:(NSArray<SJScrollToolbarItem *> *)items scrollToItemAtIndex:(NSInteger)idx animated:(BOOL)animated {
    _items = items.copy;
    _line.hidden = items.count == 0;
    [self _reloadItemsWithFocusedIndex:idx animated:animated];
}

- (void)updateConfiguration:(SJScrollToolbarConfiguration *)configuration animated:(BOOL)animated {
    _configuration = configuration;
    
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
        make.height.offset(configuration.barHeight);
        if ( configuration.distribution == SJScrollToolbarDistributionFillEqually ) {
            make.width.offset(self.bounds.size.width);
        }
    }];

    if ( _line.isHidden == NO ) {
        [_line mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.offset(-configuration.lineBottomMargin);
            make.width.offset(configuration.lineSize.width);
            make.height.offset(configuration.lineSize.height);
        }];
    }
    
    [UIView animateWithDuration:animated ? configuration.animationDuration : 0.0 animations:^{
        [self.views enumerateObjectsUsingBlock:^(SJScrollToolbarItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self _updateConfigurationForItemAtIndex:idx];
            [self _remakeConstraintsForItemAtIndex:idx];
        }];
        self.line.layer.cornerRadius = configuration.lineCornerRadius;
        self.line.backgroundColor = configuration.lineTintColor;
        self.backgroundColor = configuration.barTintColor;
        [self.views makeObjectsPerformSelector:@selector(invalidateIntrinsicContentSize)];
        [self.views makeObjectsPerformSelector:@selector(layoutIfNeeded)];
        [self invalidateIntrinsicContentSize];
        [self layoutIfNeeded];
    }];
}

- (void)updateContentsForItemAtIndex:(NSInteger)idx animated:(BOOL)animated {
    if ( [self _isSafeIndex:idx] ) {
        SJScrollToolbarItemView *view = _views[idx];
        
        [UIView animateWithDuration:animated ? self.configuration.animationDuration : 0.0 animations:^{
            view.item = self.items[idx];
            [view invalidateIntrinsicContentSize];
            [self layoutIfNeeded];
        }];
    }
}

- (nullable SJScrollToolbarItem *)itemAtIndex:(NSInteger)idx {
    if ( [self _isSafeIndex:idx] ) {
        return self.items[idx];
    }
    return nil;
}

#pragma mark -

- (void)itemViewDidFinishLoadImage:(SJScrollToolbarItemView *)view {
    [self invalidateIntrinsicContentSize];
    [self layoutIfNeeded];
    [self _setContentOffsetToIndex:self.focusedIndex];
}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = self.frame.size;
    if ( !CGSizeEqualToSize(size, _previousSize) ) {
        _previousSize = size;
        [self _barSizeDidChange];
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIScreen.mainScreen.bounds.size.width, self.configuration.barHeight);
}

#pragma mark -

- (void)_reloadItemsWithFocusedIndex:(NSInteger)index animated:(BOOL)animated {
    NSArray<SJScrollToolbarItem *> *items = _items;
    //
    // 移除多余的视图
    //
    if ( items.count < _views.count ) {
        NSRange range = NSMakeRange(items.count, _views.count - items.count);
        NSArray<UIView *> *uselessViews = [_views subarrayWithRange:range];
        [uselessViews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( obj.superview == self ) [obj removeFromSuperview];
        }];
        [_views removeObjectsInRange:range];
    }
    //
    // 补充新增的视图
    //
    else if ( items.count > _views.count ) {
        for ( NSInteger i = _views.count ; i < items.count ; ++ i ) {
            SJScrollToolbarItemView *view = [SJScrollToolbarItemView.alloc initWithFrame:CGRectZero];
            view.delegate = self;
            [_views addObject:view];
            [self.contentView addSubview:view];
        }
    }
    //
    // 重置状态
    //
    _focusedIndex = NSNotFound;
    //
    // config
    //
    [_views enumerateObjectsUsingBlock:^(SJScrollToolbarItemView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        view.item = items[idx];
        [self _updateConfigurationForItemAtIndex:idx];
        [self _remakeConstraintsForItemAtIndex:idx];
    }];
    
    [self scrollToItemAtIndex:[self _isSafeIndex:index] ? index : 0 animated:animated];
}
 
- (void)_scrollToItemAtIndex:(NSInteger)toIdx {
    if ( ![self _isSafeIndex:toIdx] ) return;
    NSInteger previousIdx = self.focusedIndex;
    _focusedIndex = toIdx;
    
    // previous
    if ( previousIdx != toIdx && [self _isSafeIndex:previousIdx] ) {
        [self _updateConfigurationForItemAtIndex:previousIdx];
    }
    
    // to
    SJScrollToolbarItemView *toView = self.views[toIdx];
    [self _remakeConstraintsForLineWithLineWidth:self.configuration.lineSize.width andCenterEqualToView:toView offset:0];
    [self _updateConfigurationForItemAtIndex:toIdx];
    [self.views makeObjectsPerformSelector:@selector(invalidateIntrinsicContentSize)];
    [self layoutIfNeeded];
    [self _setContentOffsetToIndex:toIdx];

    if ( previousIdx != toIdx ) {
        if ( [self.delegate respondsToSelector:@selector(scrollToolbar:focusedIndexDidChange:)] ) {
            [self.delegate scrollToolbar:self focusedIndexDidChange:toIdx];
        }
    }
}

- (void)_scrollInRange:(NSRange)range distanceProgress:(CGFloat)progress {
    NSInteger leftIdx = range.location;
    NSInteger rightIdx = NSMaxRange(range);
    if ( leftIdx < 0 || rightIdx >= self.views.count )
        return;
    
    if      ( leftIdx == rightIdx ) {
        [self scrollToItemAtIndex:leftIdx animated:YES];
    }
    else if ( progress <= 0 ) {
        [self scrollToItemAtIndex:range.location animated:YES];
    }
    else if ( progress >= 1 ) {
        [self scrollToItemAtIndex:NSMaxRange(range) animated:YES];
    }
    else {
        CGFloat maximumZoomScale = 1;
        CGFloat minimumZoomScale = self.configuration.minimumZoomScale;
        CGFloat zoomScaleRange = maximumZoomScale - minimumZoomScale;
        SJScrollToolbarItemView *leftView = self.views[leftIdx];
        [self _setZoomScale:maximumZoomScale - zoomScaleRange * progress forItemAtIndex:leftIdx];
        [self _setGradientColorWithProgress:1 - progress forItemAtIndex:leftIdx];
        
        SJScrollToolbarItemView *rightView = self.views[rightIdx];
        [self _setZoomScale:minimumZoomScale + zoomScaleRange * progress forItemAtIndex:rightIdx];
        [self _setGradientColorWithProgress:progress forItemAtIndex:rightIdx];
        
        CGFloat distance = CGRectGetMaxX(rightView.frame) - CGRectGetMinX(leftView.frame);
        CGSize lineSize = self.configuration.lineSize;
        CGFloat lineWidth = 0;
        // 小于 0.5 开始变长
        if ( progress < 0.5 ) {
            lineWidth = distance * progress + lineSize.width;
        }
        // 超过 0.5 开始缩小
        else {
            lineWidth = (1 - progress) * distance + lineSize.width;
        }
        CGFloat maxOffset = rightView.center.x - leftView.center.x;
        CGFloat offset = maxOffset * progress;
        [self _remakeConstraintsForLineWithLineWidth:lineWidth andCenterEqualToView:leftView offset:offset];
        [_views makeObjectsPerformSelector:@selector(invalidateIntrinsicContentSize)];
        [self layoutIfNeeded];
    }
}

- (void)_barSizeDidChange {
    if ( _configuration.distribution == SJScrollToolbarDistributionFillEqually && _contentView.bounds.size.width != self.bounds.size.width ) {
        [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
            make.height.offset(self.configuration.barHeight);
            make.width.offset(self.bounds.size.width);
        }];
    }
    
    if ( _focusedIndex != NSNotFound && _focusedIndex >= 0 && _focusedIndex < _items.count ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _scrollToItemAtIndex:self.focusedIndex];
        });
    }
}

- (void)_setContentOffsetToIndex:(NSInteger)index {
    if ( ![self _isSafeIndex:index] ) return;
    SJScrollToolbarItemView *toView = [self.views objectAtIndex:index];
    UIEdgeInsets insets = self.contentInset;
    CGFloat half = CGRectGetWidth(self.frame) * 0.5;
    CGRect rect = [toView.superview convertRect:toView.frame toView:self];
    CGFloat offset = CGRectGetMidX(rect) - half; // 距离中心的距离
    
    if ( CGRectGetMidX(rect) > half ) {
        // 是否需要滚动到终点
        CGFloat last = insets.left + self.contentSize.width + insets.right - half;
        if ( last + half < CGRectGetWidth(self.frame) ) {
            offset = insets.left;
        }
        else {
            // 滚动居中|last
            offset = (CGRectGetMidX(rect) - last) < 0 ? (CGRectGetMidX(toView.frame) - half) : (last - half);
        }
    }
    else if ( offset < -insets.left )
        offset = -insets.left;
    [self setContentOffset:CGPointMake(offset, 0) animated:NO];
}

- (void)_updateConfigurationForItemAtIndex:(NSInteger)index {
    if ( ![self _isSafeIndex:index] ) return;
    SJScrollToolbarItemView *view = [self.views objectAtIndex:index];
    view.maximumFont = self.configuration.maximumFont;
    view.textColor = self.focusedIndex != index ? self.configuration.itemTintColor : self.configuration.focusedItemTintColor;
    [self _setZoomScale:self.focusedIndex != index ? self.configuration.minimumZoomScale : 1.0 forItemAtIndex:index];
}

- (void)_remakeConstraintsForItemAtIndex:(NSInteger)idx {
    if ( ![self _isSafeIndex:idx] ) return;
    SJScrollToolbarAlignment alignment = self.configuration.alignment;
    SJScrollToolbarDistribution distribution  = self.configuration.distribution;
    CGFloat itemSpacing = distribution != SJScrollToolbarDistributionFillEqually ? self.configuration.spacing : 0;
    SJScrollToolbarItemView *view = [self.views objectAtIndex:idx];
    [view mas_remakeConstraints:^(MASConstraintMaker *make) {
        alignment == SJScrollToolbarAlignmentBottom ? make.bottom.offset([self _descenderForItemAtIndex:idx]) : make.centerY.offset(0);
        idx == 0 ? make.left.offset(0) : make.left.equalTo(self.views[idx - 1].mas_right).offset(itemSpacing);
        if ( distribution == SJScrollToolbarDistributionFillEqually ) make.width.equalTo(self.contentView).multipliedBy(1.0 / self.views.count);
        if ( view == self.views.lastObject ) make.right.offset(0);
    }];
}

- (void)_setZoomScale:(CGFloat)scale forItemAtIndex:(NSInteger)idx {
    if ( ![self _isSafeIndex:idx] ) return;
    SJScrollToolbarItemView *view = self.views[idx];
    view.zoomScale = scale;
    SJScrollToolbarAlignment alignment = self.configuration.alignment;
    if ( alignment == SJScrollToolbarAlignmentBottom ) {
        [view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.offset([self _descenderForItemAtIndex:idx]);
        }];
    }
}

- (void)_remakeConstraintsForLineWithLineWidth:(CGFloat)lineWidth andCenterEqualToView:(SJScrollToolbarItemView *)view offset:(CGFloat)offset {
    [_line mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(lineWidth);
        make.centerX.equalTo(view).offset(offset);
        make.bottom.offset(-self.configuration.lineBottomMargin);
        make.height.offset(self.configuration.lineSize.height);
    }];
}

// progress [0,1],  0 为 itemTintColor, 1 为 focusedTintColor
- (void)_setGradientColorWithProgress:(CGFloat)progress forItemAtIndex:(NSInteger)idx {
    if ( ![self _isSafeIndex:idx] ) return;
    if ( [_configuration.focusedItemTintColor isEqual:_configuration.itemTintColor] ) return;
    struct color {
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        CGFloat alpah;
    };
    
    struct color tintColor, focusedTintColor;
    [_configuration.itemTintColor getRed:&tintColor.red green:&tintColor.green blue:&tintColor.blue alpha:&tintColor.alpah];
    [_configuration.focusedItemTintColor getRed:&focusedTintColor.red green:&focusedTintColor.green blue:&focusedTintColor.blue alpha:&focusedTintColor.alpah];
    
    SJScrollToolbarItemView *view = self.views[idx];
    view.textColor = [UIColor colorWithRed:tintColor.red + (focusedTintColor.red - tintColor.red) * progress
                                     green:tintColor.green + (focusedTintColor.green - tintColor.green) * progress
                                      blue:tintColor.blue + (focusedTintColor.blue - tintColor.blue) * progress
                                     alpha:tintColor.alpah + (focusedTintColor.alpah - tintColor.alpah) * progress];
}

- (BOOL)_isSafeIndex:(NSInteger)idx {
    return idx < _items.count && idx >= 0;
}

- (CGFloat)_descenderForItemAtIndex:(NSInteger)idx {
    if ( [self _isSafeIndex:idx] ) {
        SJScrollToolbarItemView *view = self.views[idx];
        return -(3 + ABS(self.configuration.maximumFont.descender * (1 - view.zoomScale)));
    }
    return 0;
}
@end
NS_ASSUME_NONNULL_END
