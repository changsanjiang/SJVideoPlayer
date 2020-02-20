//
//  SJEdgeControlButtonItemAdapterLayout.m
//  Pods
//
//  Created by 畅三江 on 2019/12/9.
//

#import "SJEdgeControlButtonItemAdapterLayout.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJEdgeControlButtonItemAdapterLayout () {
    NSMutableArray<SJEdgeControlButtonItemLayoutAttributes *> *_layoutAttributes;
}
@end

@implementation SJEdgeControlButtonItemAdapterLayout
- (instancetype)initWithLayoutType:(SJAdapterLayoutType)type {
    self = [super init];
    if ( self ) {
        _layoutType = type;
        _layoutAttributes = NSMutableArray.array;
    }
    return self;
}

- (void)prepareLayout {
    _intrinsicContentSize = CGSizeZero;
    [_layoutAttributes removeAllObjects];
    
    switch ( _layoutType ) {
        case SJAdapterLayoutTypeVerticalLayout:
            [self _prepareLayout_Vertical];
            break;
        case SJAdapterLayoutTypeHorizontalLayout:
            [self _prepareLayout_Horizontal];
            break;
        case SJAdapterLayoutTypeFrameLayout:
            [self _prepareLayout_Frame];
            break;
        default: break;
    }
}

- (nullable NSArray<SJEdgeControlButtonItemLayoutAttributes *> *)layoutAttributesForItems {
    return _layoutAttributes.count != 0 ? _layoutAttributes : nil;
}

- (nullable SJEdgeControlButtonItemLayoutAttributes *)layoutAttributesForItemAtIndex:(NSInteger)index {
    if ( index < _layoutAttributes.count && index >= 0 ) {
        return [_layoutAttributes objectAtIndex:index];
    }
    return nil;
}

#pragma mark -

- (void)_prepareLayout_Horizontal {
    if ( CGSizeEqualToSize(_preferredMaxLayoutSize, CGSizeZero) )
        return;
    
    CGFloat content_w = 0;              // 内容宽度
    CGRect bounds_arr[_items.count];    // 所有内容的bounds
    NSMutableArray<NSNumber *> *fillIndexes = [NSMutableArray new];
    CGFloat height = _preferredMaxLayoutSize.height;
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
                width = [self _autoresizingForView:item.customView maxSize:CGSizeMake(CGFLOAT_MAX, height)].width;
            }
            else {
                width = item.customView.frame.size.width;
            }
        }
        else if ( 0 != item.title.length )
            width = [self _sizeForAttributedString:item.title width:CGFLOAT_MAX height:height].width;
        else if ( item.image )
            width = height;
        
        CGRect bounds = (CGRect){CGPointZero, (CGSize){width, height}};
        content_w += item.insets.front + bounds.size.width + item.insets.rear;
        bounds_arr[i] = bounds;
    }
    
    // 填充剩余空间
    if ( fillIndexes.count != 0 ) {
        CGFloat max_w = _preferredMaxLayoutSize.width;
        CGFloat remanentW = max_w - content_w;
        CGFloat itemW = remanentW / fillIndexes.count;
        for ( NSNumber *idx in fillIndexes ) {
            bounds_arr[[idx integerValue]] = (CGRect){CGPointZero, (CGSize){itemW, height}};
        }
    }
    
    // create `LayoutAttributes`
    CGFloat current_x = 0;
    for ( NSInteger index = 0 ; index < _items.count ; ++ index ) {
        SJEdgeControlButtonItem *item = _items[index];
        current_x += item.insets.front;
        SJEdgeControlButtonItemLayoutAttributes *attrs = [SJEdgeControlButtonItemLayoutAttributes layoutAttributesForItemWithIndex:index];
        attrs.frame = (CGRect){(CGPoint){current_x, 0}, (CGSize)bounds_arr[index].size};
        [_layoutAttributes addObject:attrs];
        current_x += bounds_arr[index].size.width + item.insets.rear;
    }
    
    _intrinsicContentSize = CGSizeMake(CGRectGetMaxX(_layoutAttributes.lastObject.frame),
                                       CGRectGetMaxY(_layoutAttributes.lastObject.frame));
}

- (void)_prepareLayout_Vertical {
    if ( CGSizeEqualToSize(_preferredMaxLayoutSize, CGSizeZero) )
        return;
    
    CGFloat content_h = 0;              // 内容宽度
    CGRect bounds_arr[_items.count];    // 所有内容的bounds
    CGFloat width = _preferredMaxLayoutSize.width;
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
                height = [self _autoresizingForView:item.customView maxSize:CGSizeMake(width, CGFLOAT_MAX)].height;
            }
            else {
                height = item.customView.frame.size.height;
            }
        }
        else if ( 0 != item.title.length )
            height = [self _sizeForAttributedString:item.title width:width height:CGFLOAT_MAX].height;
        else if ( item.image )
            height = width;
        
        CGRect bounds = (CGRect){CGPointZero, (CGSize){width, height}};
        content_h += item.insets.front + bounds.size.height + item.insets.rear;
        bounds_arr[i] = bounds;
    }
    
    // 填充剩余空间
    CGFloat max_h = _preferredMaxLayoutSize.height;
    if ( fillIndexes.count != 0 ) {
        CGFloat remanentH = max_h - content_h;
        CGFloat itemH = remanentH / fillIndexes.count;
        for ( NSNumber *idx in fillIndexes ) {
            bounds_arr[[idx integerValue]] = (CGRect){CGPointZero, (CGSize){width, itemH}};
        }
    }
    
    CGFloat current_y = floor((max_h - content_h) * 0.5);
    for ( NSInteger index = 0 ; index < _items.count ; ++ index ) {
        SJEdgeControlButtonItem *item = _items[index];
        current_y += item.insets.front;
        SJEdgeControlButtonItemLayoutAttributes *attrs = [SJEdgeControlButtonItemLayoutAttributes layoutAttributesForItemWithIndex:index];
        attrs.frame = (CGRect){CGPointMake(0, current_y), (CGSize)bounds_arr[index].size};
        [_layoutAttributes addObject:attrs];
        current_y += bounds_arr[index].size.height + item.insets.rear;
    }
    
    _intrinsicContentSize = CGSizeMake(CGRectGetMaxX(_layoutAttributes.lastObject.frame),
                                       CGRectGetMaxY(_layoutAttributes.lastObject.frame));
}

- (void)_prepareLayout_Frame {
    CGSize maxContentSize = CGSizeZero;
    CGRect bounds_arr[_items.count];
    for ( NSInteger i = 0 ; i < _items.count ; ++ i ) {
        CGSize size = CGSizeZero;
        SJEdgeControlButtonItem *item = _items[i];
        if ( item.isHidden ) { }
        else if ( item.fill ) {
            size = _itemFillSizeForFrameLayout;
        }
        else if ( item.isFrameLayout ) {
            if ( !CGSizeEqualToSize(CGSizeZero, item.customView.bounds.size) ) {
                size = item.customView.bounds.size;
            }
            else {
                size = [self _autoresizingForView:item.customView maxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
            }
        }
        else if ( 0 != item.size ) {
            size = CGSizeMake(item.size, item.size);
        }
        else if ( item.placeholderType == SJButtonItemPlaceholderType_49x49 || item.image != nil ) {
            size = CGSizeMake(49, 49);
        }
        else if ( 0 != item.title.length ) {
            size = [self _sizeForAttributedString:item.title width:CGFLOAT_MAX height:CGFLOAT_MAX];
        }
        
        CGRect bounds = (CGRect){0, 0, size};
        bounds_arr[i] = bounds;
        if ( bounds.size.width > maxContentSize.width )
            maxContentSize.width = bounds.size.width;
        if ( bounds.size.height > maxContentSize.height )
            maxContentSize.height = bounds.size.height;
    }
    
    CGPoint center = (CGPoint){maxContentSize.width * 0.5, maxContentSize.height * 0.5};
    for ( NSInteger index = 0 ; index < _items.count ; ++ index ) {
        CGRect bounds = bounds_arr[index];
        SJEdgeControlButtonItemLayoutAttributes *attrs = [SJEdgeControlButtonItemLayoutAttributes layoutAttributesForItemWithIndex:index];
        attrs.size = bounds.size;
        attrs.center = center;
        [_layoutAttributes addObject:attrs];
    }
    
    _intrinsicContentSize = maxContentSize;
}

- (CGSize)_sizeForAttributedString:(NSAttributedString *)attrStr width:(double)width height:(double)height {
    if ( 0 == attrStr.length ) { return CGSizeZero; }
    CGRect bounds = [attrStr boundingRectWithSize:(CGSize){width, height} options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    bounds.size.width = ceil(bounds.size.width);
    bounds.size.height = ceil(bounds.size.height);
    return bounds.size;
}

- (CGSize)_autoresizingForView:(UIView *)view maxSize:(CGSize)maxSize {
    CGSize size = [view systemLayoutSizeFittingSize:maxSize];
    CGFloat maxWidth = _preferredMaxLayoutSize.width;
    CGFloat maxHeight = _preferredMaxLayoutSize.height;
    if ( maxWidth != 0 && size.width > maxWidth ) size.width = maxWidth;
    if ( maxHeight != 0 && size.height > maxHeight ) size.height = maxHeight;
    return size;
}

@end

@implementation SJEdgeControlButtonItemLayoutAttributes
+ (instancetype)layoutAttributesForItemWithIndex:(NSInteger)index {
    SJEdgeControlButtonItemLayoutAttributes *attrs = SJEdgeControlButtonItemLayoutAttributes.alloc.init;
    attrs.index = index;
    return attrs;
}

- (void)setFrame:(CGRect)frame {
    _frame = frame;
}

- (void)setSize:(CGSize)size {
    _frame.size = size;
}

- (CGSize)size {
    return _frame.size;
}

- (void)setCenter:(CGPoint)center {
    CGFloat x = center.x - self.size.width * 0.5;
    CGFloat y = center.y - self.size.height * 0.5;
    _frame.origin = (CGPoint){x, y};
}

- (CGPoint)center {
    return (CGPoint){_frame.origin.x + self.size.width * 0.5,
                     _frame.origin.y + self.size.height * 0.5};
}
@end
NS_ASSUME_NONNULL_END
