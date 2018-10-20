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
@property (nonatomic, copy, nullable) NSArray<SJEdgeControlButtonItem *> *items;
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
@end

@implementation SJCollectionViewLayout {
    @private NSMutableArray<UICollectionViewLayoutAttributes *> *_layoutAttributes;
}
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _layoutAttributes = NSMutableArray.array;
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    if ( _scrollDirection == UICollectionViewScrollDirectionHorizontal ) {
        [self _prepareLayout_Horizontal];
    }
    else {
        [self _prepareLayout_Vertical];
    }
    
}

- (void)_prepareLayout_Horizontal {
    [_layoutAttributes removeAllObjects];
    CGFloat content_w = 0; // 内容宽度
    CGRect bounds_arr[_items.count]; // 所有内容的bounds
    int fill_idx = kCFNotFound; // 需要填充的item的索引
    
    for ( int i = 0 ; i < _items.count ; ++ i ) {
        CGRect bounds = CGRectZero;
        SJEdgeControlButtonItem *item = _items[i];
        if ( item.fill ) {
            fill_idx = i;
            continue;
        }
        else if ( item.customView ) {
            bounds = (CGRect){CGPointZero, (CGSize){item.customView.frame.size.width, 44}};
        }
        else if ( 0 != item.title.length )
            bounds = (CGRect){CGPointZero, (CGSize){[self sizeWithAttrString:item.title width:CGFLOAT_MAX height:44].width, 44}};
        else if ( item.image )
            bounds = (CGRect){CGPointZero, (CGSize){44, 44}};
        
        content_w += item.insets.left + bounds.size.width + item.insets.right;
        bounds_arr[i] = bounds;
    }
    
    // 填充剩余空间
    if ( fill_idx != kCFNotFound ) {
        CGFloat max_w = self.collectionView.bounds.size.width;
        if ( max_w > content_w ) bounds_arr[fill_idx] = (CGRect){CGPointZero, (CGSize){max_w - content_w, 44}};
    }
    
    CGFloat current_x = 0;
    for ( int i = 0 ; i < _items.count ; ++ i ) {
        SJEdgeControlButtonItem *item = _items[i];
        current_x += item.insets.left;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = (CGRect){(CGPoint){current_x, 0}, (CGSize)bounds_arr[i].size};
        [_layoutAttributes addObject:attributes];
        current_x += bounds_arr[i].size.width + item.insets.right;
    }
}

- (void)_prepareLayout_Vertical {
    [_layoutAttributes removeAllObjects];
    
    CGFloat content_h = 0; // 内容宽度
    CGRect bounds_arr[_items.count]; // 所有内容的bounds
    int fill_idx = kCFNotFound; // 需要填充的item的索引
    
    for ( int i = 0 ; i < _items.count ; ++ i ) {
        CGRect bounds = CGRectZero;
        SJEdgeControlButtonItem *item = _items[i];
        if ( item.fill ) {
            fill_idx = i;
            continue;
        }
        else if ( item.customView ) {
            bounds = (CGRect){CGPointZero, (CGSize){44, item.customView.frame.size.width}};
        }
        else if ( 0 != item.title.length )
            bounds = (CGRect){CGPointZero, (CGSize){44, [self sizeWithAttrString:item.title width:CGFLOAT_MAX height:44].height}};
        else if ( item.image )
            bounds = (CGRect){CGPointZero, (CGSize){44, 44}};
        
        content_h += item.insets.left + bounds.size.height + item.insets.right;
        bounds_arr[i] = bounds;
    }
    
    // 填充剩余空间
    CGFloat max_h = self.collectionView.bounds.size.height;
    if ( fill_idx != kCFNotFound ) {
        if ( max_h > content_h ) bounds_arr[fill_idx] = (CGRect){CGPointZero, (CGSize){44, max_h - content_h}};
    }
    
    CGFloat current_y = floor((max_h - content_h) * 0.5);
    for ( int i = 0 ; i < _items.count ; ++ i ) {
        SJEdgeControlButtonItem *item = _items[i];
        current_y += item.insets.left;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = (CGRect){(CGPoint){0, current_y}, (CGSize)bounds_arr[i].size};
        [_layoutAttributes addObject:attributes];
        current_y += bounds_arr[i].size.height + item.insets.right;
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
    return CGSizeMake(CGRectGetMaxX(_layoutAttributes.lastObject.frame), CGRectGetMaxY(_layoutAttributes.lastObject.frame));
}

- (CGSize)sizeWithAttrString:(NSAttributedString *)attrStr width:(double)width height:(double)height {
    if ( 0 == attrStr.length ) { return CGSizeZero; }
    CGRect bounds = [attrStr boundingRectWithSize:(CGSize){width, height} options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    bounds.size.width = ceil(bounds.size.width);
    bounds.size.height = ceil(bounds.size.height);
    return bounds.size;
}
@end


@interface SJEdgeControlLayerItemAdapter ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong, readonly) NSMutableArray<SJEdgeControlButtonItem *> *itemsM;
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, readonly) UICollectionViewScrollDirection direction;
@end

@implementation SJEdgeControlLayerItemAdapter {
    SJCollectionViewLayout *_layout;
}
- (instancetype)initWithDirection:(UICollectionViewScrollDirection)direction {
    self = [super init];
    if ( !self ) return nil;
    _itemsM = NSMutableArray.array;
    
    _layout = [SJCollectionViewLayout new];
    _layout.scrollDirection = direction;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    [SJButtonItemCollectionViewCell registerWithCollectionView:_collectionView];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    return self;
}
- (UIView *)view {
    return _collectionView;
}
- (void)reload {
    _layout.items = _itemsM;
    [_layout invalidateLayout];
    [_collectionView reloadData];
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
- (void)removeItemAtIndex:(NSInteger)index {
    if ( index < 0 ) return;
    if ( index >= self.numberOfItems ) return;
    [_itemsM removeObjectAtIndex:index];
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
    NSInteger index = kCFNotFound;
    for ( int i = 0 ; i < _itemsM.count ; ++ i ) {
        if ( _itemsM[i].tag != tag ) continue;
        index = i;
        break;
    }
    return index;
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
    if ( item.customView ) {
        cell.button.hidden = YES;
        item.customView.frame = cell.contentView.bounds;
        item.customView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:item.customView];
    }
    else if ( 0 != item.title.length  ) {
        cell.button.hidden = NO;
        [cell.button setAttributedTitle:item.title forState:UIControlStateNormal];
        [cell.button addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
    }
    else if ( item.image ) {
        cell.button.hidden = NO;
        [cell.button setImage:item.image forState:UIControlStateNormal];
        [cell.button addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
    }
}
@end
NS_ASSUME_NONNULL_END
