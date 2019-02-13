//
//  SJEdgeControlLayerItemAdapter.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/19.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerItemAdapter.h"
#import "SJButtonItemCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJCollectionViewLayout : UICollectionViewLayout
@property (nonatomic, readonly) CGSize maxSizeOfFrameLayout;

@property (nonatomic, copy, nullable) void(^maxSizeDidUpdateOfFrameLayoutExeBlock)(CGSize size);
@property (nonatomic, copy, nullable) NSArray<SJEdgeControlButtonItem *> *items;
@property (nonatomic) SJAdapterItemsLayoutType layoutType;
@end

@implementation SJCollectionViewLayout {
    @public NSMutableArray<UICollectionViewLayoutAttributes *> *_layoutAttributes;
    CGSize _maxSizeOfFrameLayout;
}
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _layoutAttributes = NSMutableArray.array;
    return self;
}

- (void)invalidateLayout {
    [super invalidateLayout];
}

- (void)prepareLayout {
    [super prepareLayout];
    [_layoutAttributes removeAllObjects];
    
    switch ( _layoutType ) {
        case SJAdapterItemsLayoutTypeVerticalLayout: {
            [self _prepareLayout_Vertical];
        }
            break;
        case SJAdapterItemsLayoutTypeHorizontalLayout: {
            [self _prepareLayout_Horizontal];
        }
            break;
        case SJAdapterItemsLayoutTypeFrameLayout: {
            [self _prepareLayout_Frame];
        }
            break;
    }
}

- (void)_prepareLayout_Horizontal {
    if ( CGSizeEqualToSize(self.collectionView.bounds.size, CGSizeZero) ) {
        return;
    }
    CGFloat content_w = 0;              // 内容宽度
    CGRect bounds_arr[_items.count];    // 所有内容的bounds
    NSMutableArray<NSNumber *> *fillIndexes = [NSMutableArray new];
    CGFloat height = self.collectionView.bounds.size.height;
    for ( NSInteger i = 0 ; i < _items.count ; ++ i ) {
        CGFloat width = 0;
        SJEdgeControlButtonItem *item = _items[i];
        if ( item.fill )
            [fillIndexes addObject:@(i)];
        else if ( item.isHidden ) { }
        else if ( 0 != item.size )
            width = item.size;
        else if ( item.placeholderType == SJButtonItemPlaceholderType_49x49 )
            width = height;
        else if ( item.customView ) {
            if ( item.placeholderType == SJButtonItemPlaceholderType_49xAutoresizing ) {
                width = [self autoresizingWithView:item.customView maxSize:CGSizeMake(CGFLOAT_MAX, height)].width;
            }
            else {
                width = item.customView.frame.size.width;
            }
        }
        else if ( 0 != item.title.length )
            width = [self sizeWithAttrString:item.title width:CGFLOAT_MAX height:height].width;
        else if ( item.image )
            width = height;
        
        CGRect bounds = (CGRect){CGPointZero, (CGSize){width, height}};
        content_w += item.insets.front + bounds.size.width + item.insets.rear;
        bounds_arr[i] = bounds;
    }
    
    // 填充剩余空间
    if ( fillIndexes.count != 0 ) {
        CGFloat max_w = self.collectionView.bounds.size.width;
        CGFloat remanentW = max_w - content_w;
        CGFloat itemW = remanentW / fillIndexes.count;
        for ( NSNumber *idx in fillIndexes ) {
            bounds_arr[[idx integerValue]] = (CGRect){CGPointZero, (CGSize){itemW, height}};
        }
    }
    
    // create `LayoutAttributes`
    CGFloat current_x = 0;
    for ( NSInteger i = 0 ; i < _items.count ; ++ i ) {
        SJEdgeControlButtonItem *item = _items[i];
        current_x += item.insets.front;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = (CGRect){(CGPoint){current_x, 0}, (CGSize)bounds_arr[i].size};
        [_layoutAttributes addObject:attributes];
        current_x += bounds_arr[i].size.width + item.insets.rear;
    }
}

- (void)_prepareLayout_Vertical {
    if ( CGSizeEqualToSize(self.collectionView.bounds.size, CGSizeZero) ) {
        return;
    }
    CGFloat content_h = 0;              // 内容宽度
    CGRect bounds_arr[_items.count];    // 所有内容的bounds
    
    CGFloat width = self.collectionView.bounds.size.width;
    NSMutableArray<NSNumber *> *fillIndexes = [NSMutableArray new];
    for ( NSInteger i = 0 ; i < _items.count ; ++ i ) {
        CGFloat height = 0;
        SJEdgeControlButtonItem *item = _items[i];
        if ( item.fill )
            [fillIndexes addObject:@(i)];
        else if ( item.isHidden ) { }
        else if ( 0 != item.size )
            height = item.size;
        else if ( item.placeholderType == SJButtonItemPlaceholderType_49x49 )
            height = width;
        else if ( item.customView ) {
            if ( item.placeholderType == SJButtonItemPlaceholderType_49xAutoresizing ) {
                height = [self autoresizingWithView:item.customView maxSize:CGSizeMake(width, CGFLOAT_MAX)].height;
            }
            else {
                height = item.customView.frame.size.height;
            }
        }
        else if ( 0 != item.title.length )
            height = [self sizeWithAttrString:item.title width:width height:CGFLOAT_MAX].height;
        else if ( item.image )
            height = width;
        
        CGRect bounds = (CGRect){CGPointZero, (CGSize){width, height}};
        content_h += item.insets.front + bounds.size.height + item.insets.rear;
        bounds_arr[i] = bounds;
    }
    
    // 填充剩余空间
    CGFloat max_h = self.collectionView.bounds.size.height;
    if ( fillIndexes.count != 0 ) {
        CGFloat remanentH = max_h - content_h;
        CGFloat itemH = remanentH / fillIndexes.count;
        for ( NSNumber *idx in fillIndexes ) {
            bounds_arr[[idx integerValue]] = (CGRect){CGPointZero, (CGSize){width, itemH}};
        }
    }
    
    CGFloat current_y = floor((max_h - content_h) * 0.5);
    for ( NSInteger i = 0 ; i < _items.count ; ++ i ) {
        SJEdgeControlButtonItem *item = _items[i];
        current_y += item.insets.front;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = (CGRect){(CGPoint){0, current_y}, (CGSize)bounds_arr[i].size};
        [_layoutAttributes addObject:attributes];
        current_y += bounds_arr[i].size.height + item.insets.rear;
    }
}

- (void)_prepareLayout_Frame {
    CGSize beforeMaxSize = _maxSizeOfFrameLayout;
    _maxSizeOfFrameLayout = CGSizeZero;
    
    CGRect bounds_arr[_items.count];
    for ( NSInteger i = 0 ; i < _items.count ; ++ i ) {
        CGRect bounds = CGRectZero;
        SJEdgeControlButtonItem *item = _items[i];
        bounds = item.customView.bounds;
        bounds_arr[i] = bounds;
        if ( bounds.size.width > _maxSizeOfFrameLayout.width )
            _maxSizeOfFrameLayout.width = bounds.size.width;
        if ( bounds.size.height > _maxSizeOfFrameLayout.height )
            _maxSizeOfFrameLayout.height = bounds.size.height;
    }
    
    CGPoint center = (CGPoint){_maxSizeOfFrameLayout.width * 0.5, _maxSizeOfFrameLayout.height * 0.5};
    for ( NSInteger i = 0 ; i < _items.count ; ++ i ) {
        CGRect bounds = bounds_arr[i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.size = bounds.size;
        attributes.center = center;
        [_layoutAttributes addObject:attributes];
    }
    
    if ( !CGSizeEqualToSize(beforeMaxSize, _maxSizeOfFrameLayout) ) {
        if ( _maxSizeDidUpdateOfFrameLayoutExeBlock ) _maxSizeDidUpdateOfFrameLayoutExeBlock(_maxSizeOfFrameLayout);
    }
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return _layoutAttributes;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.item >= _layoutAttributes.count ) return nil;
    return _layoutAttributes[indexPath.item];
}

- (CGSize)collectionViewContentSize {
    if ( _layoutType != SJAdapterItemsLayoutTypeFrameLayout )
        return CGSizeMake(CGRectGetMaxX(_layoutAttributes.lastObject.frame), CGRectGetMaxY(_layoutAttributes.lastObject.frame));
    return _maxSizeOfFrameLayout;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

//

- (CGSize)sizeWithAttrString:(NSAttributedString *)attrStr width:(double)width height:(double)height {
    if ( 0 == attrStr.length ) { return CGSizeZero; }
    CGRect bounds = [attrStr boundingRectWithSize:(CGSize){width, height} options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    bounds.size.width = ceil(bounds.size.width);
    bounds.size.height = ceil(bounds.size.height);
    return bounds.size;
}

- (CGSize)autoresizingWithView:(UIView *)view maxSize:(CGSize)maxSize {
    CGSize size = [view systemLayoutSizeFittingSize:maxSize];
    CGFloat maxWidth = self.collectionView.bounds.size.width;
    CGFloat maxHeight = self.collectionView.bounds.size.height;
    if ( size.width > maxWidth )
        size.width = maxWidth;
    if ( size.height > maxHeight )
        size.height = maxHeight;
    return size;
}
@end


@interface SJEdgeControlLayerItemAdapter ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong, readonly) NSMutableArray<SJEdgeControlButtonItem *> *itemsM;
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) SJCollectionViewLayout *layout;
@end

@implementation SJEdgeControlLayerItemAdapter {
    SJCollectionViewLayout *_layout;
}
- (instancetype)initWithLayoutType:(SJAdapterItemsLayoutType)layoutType {
    self = [super init];
    if ( !self ) return nil;
    _itemsM = NSMutableArray.array;
    
    _layout = [SJCollectionViewLayout new];
    _layout.layoutType = layoutType;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    [SJButtonItemCollectionViewCell registerWithCollectionView:_collectionView];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:_collectionView];
    _collectionView.frame = _view.bounds;
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return self;
}
@synthesize view = _view;
- (UIView *)view {
    if ( _view ) return _view;
    return _view = [UIView new];
}
- (void)setMaxSizeDidUpdateOfFrameLayoutExeBlock:(void (^_Nullable)(CGSize))maxSizeDidUpdateOfFrameLayoutExeBlock {
    _layout.maxSizeDidUpdateOfFrameLayoutExeBlock = maxSizeDidUpdateOfFrameLayoutExeBlock;
}
- (void (^_Nullable)(CGSize))maxSizeDidUpdateOfFrameLayoutExeBlock {
    return _layout.maxSizeDidUpdateOfFrameLayoutExeBlock;
}
- (void)reload {
    _layout.items = _itemsM;
    [_collectionView reloadData];
}
- (void)updateContentForItemWithTag:(SJEdgeControlButtonItemTag)tag {
    NSInteger index = [self indexOfItemForTag:tag];
    SJEdgeControlButtonItem *item = [self itemForTag:tag];
    if ( !item ) return;
    if ( 0 == [_collectionView numberOfItemsInSection:0] ) return;
    [self _updateContentOfCell:(id)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]] forItem:item atIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}
- (NSInteger)numberOfItems {
    return _itemsM.count;
}
- (void)addItem:(SJEdgeControlButtonItem *)item {
    if ( !item ) return;
    [_itemsM addObject:item];
}
- (void)insertItem:(SJEdgeControlButtonItem *)item atIndex:(NSInteger)index {
    if ( !item ) return;
    if ( index >= self.numberOfItems ) index = self.numberOfItems;
    if ( index < 0 ) index = 0;
    [_itemsM insertObject:item atIndex:index];
}
- (void)insertItem:(SJEdgeControlButtonItem *)item frontItem:(SJEdgeControlButtonItemTag)tag {
    [self insertItem:item atIndex:[self indexOfItemForTag:tag]+1];
}
- (void)insertItem:(SJEdgeControlButtonItem *)item rearItem:(SJEdgeControlButtonItemTag)tag {
    [self insertItem:item atIndex:[self indexOfItemForTag:tag]];
}
- (void)removeItemAtIndex:(NSInteger)index {
    if ( index < 0 ) return;
    if ( index >= self.numberOfItems ) return;
    [_itemsM removeObjectAtIndex:index];
}
- (void)removeItemForTag:(SJEdgeControlButtonItemTag)tag {
    NSInteger idx = [self indexOfItemForTag:tag];
    [self removeItemAtIndex:idx];
}
- (nullable SJEdgeControlButtonItem *)itemAtIndex:(NSInteger)index {
    if ( index >= self.numberOfItems ) return nil;
    if ( index < 0 ) return nil;
    return _itemsM[index];
}
- (nullable SJEdgeControlButtonItem *)itemForTag:(SJEdgeControlButtonItemTag)tag {
    for ( SJEdgeControlButtonItem *item in _itemsM ) {
        if ( item.tag != tag ) continue;
        return item;
    }
    return nil;
}
- (NSInteger)indexOfItemForTag:(SJEdgeControlButtonItemTag)tag {
    NSInteger index = NSNotFound;
    for ( int i = 0 ; i < _itemsM.count ; ++ i ) {
        if ( _itemsM[i].tag != tag ) continue;
        index = i;
        break;
    }
    return index;
}
- (void)exchangeItemAtIndex:(NSInteger)idx1 withItemAtIndex:(NSInteger)idx2 {
    if ( idx1 < 0 || idx1 >= _itemsM.count ) return;
    if ( idx2 < 0 || idx2 >= _itemsM.count ) return;
    if ( idx1 == idx2 ) return;
    [_itemsM exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}
- (void)exchangeItemForTag:(SJEdgeControlButtonItemTag)tag1 withItemForTag:(SJEdgeControlButtonItemTag)tag2 {
    NSInteger idx1 = [self indexOfItemForTag:tag1];
    NSInteger idx2 = [self indexOfItemForTag:tag2];
    [self exchangeItemAtIndex:idx1 withItemAtIndex:idx2];
}
- (NSInteger)itemCount {
    return _itemsM.count;
}
- (nullable NSArray<SJEdgeControlButtonItem *> *)itemsWithRange:(NSRange)range {
    if ( range.location >= _itemsM.count ) return nil;
    if ( range.location + range.length > _itemsM.count ) return nil;
    return [_itemsM subarrayWithRange:range];
}
- (BOOL)itemsIsHiddenWithRange:(NSRange)range {
    NSArray<SJEdgeControlButtonItem *> *items = [self itemsWithRange:range];
    if ( 0 == items.count ) return YES;
    for ( SJEdgeControlButtonItem *item in items ) {
        if ( !item.isHidden ) return NO;
    }
    return YES;
}
- (BOOL)itemContainsPoint:(CGPoint)point {
    for ( int i = 0 ; i < _layout -> _layoutAttributes.count ; ++ i ) {
        UICollectionViewLayoutAttributes *atr = _layout->_layoutAttributes[i];
        if ( CGRectContainsPoint(atr.frame, point) &&
             ![self itemAtIndex:i].isHidden )
            return YES;
    }
    return NO;
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [SJButtonItemCollectionViewCell cellWithCollectionView:collectionView indexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SJButtonItemCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    SJEdgeControlButtonItem *item = _itemsM[indexPath.item];
    [self _updateContentOfCell:cell forItem:item atIndexPath:indexPath];
}

- (void)_updateContentOfCell:(SJButtonItemCollectionViewCell *)cell forItem:(SJEdgeControlButtonItem *)item atIndexPath:(NSIndexPath *)indexPath {
    if ( !item ) return;
    if ( !cell ) return;
    
    cell.contentView.hidden = item.hidden;
    if ( item.hidden )
        return;
    
    UIView *customView = item.customView;
    if ( customView ) {
        cell.customViewContainerView.hidden = NO;
        cell.itemContentView.hidden = YES;
        cell.customViewContainerView.userInteractionEnabled = (nil == item.target);
        customView.frame = _layout->_layoutAttributes[indexPath.item].bounds;
        if ( cell->_customViewContainerView.subviews.lastObject != customView ) {
            [cell removeSubviewsFromCustomViewContainerView];
            [cell->_customViewContainerView addSubview:customView];
        }
    }
    else if ( 0 != item.title.length  ) {
        cell->_customViewContainerView.hidden = YES;
        cell.itemContentView.hidden = NO;
        cell.itemContentView.sj_titleLabel.attributedText = item.title;
        cell.itemContentView.sj_imageView.image = nil;
    }
    else if ( item.image ) {
        cell->_customViewContainerView.hidden = YES;
        cell.itemContentView.hidden = NO;
        cell.itemContentView.sj_titleLabel.attributedText = nil;
        cell.itemContentView.sj_imageView.image = item.image;
    }
    else {
        cell.itemContentView.hidden = YES;
        cell->_customViewContainerView.hidden = YES;
    }
    
    __weak typeof(self) _self = self;
    cell.clickedCellExeBlock = ^(SJButtonItemCollectionViewCell * _Nonnull cell) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ( [item.target respondsToSelector:item.action] ) {
            [item.target performSelector:item.action withObject:item];
            if ( self.executedTargetActionExeBlock ) self.executedTargetActionExeBlock(self);
        }
#pragma clang diagnostic pop
    };
}
@end
NS_ASSUME_NONNULL_END
