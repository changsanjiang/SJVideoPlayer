//
//  SJEdgeControlLayerItemAdapter.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/19.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJEdgeControlButtonItem.h"

typedef enum : NSUInteger {
    /// 垂直布局
    SJAdapterItemsLayoutTypeVerticalLayout = UICollectionViewScrollDirectionVertical,
    /// 水平布局
    SJAdapterItemsLayoutTypeHorizontalLayout = UICollectionViewScrollDirectionHorizontal,
    /// 帧布局(一层一层往上盖, 并居中显示)
    SJAdapterItemsLayoutTypeFrameLayout,
} SJAdapterItemsLayoutType;

NS_ASSUME_NONNULL_BEGIN
@interface SJEdgeControlLayerItemAdapter : NSObject
- (instancetype)initWithLayoutType:(SJAdapterItemsLayoutType)layoutType;
/// 刷新
///
- (void)reload;
- (void)updateContentForItemWithTag:(SJEdgeControlButtonItemTag)tag;

/// 布局方式
///
/// - 注意: 修改后, 记得调用刷新
@property (nonatomic) SJAdapterItemsLayoutType layoutType;

/// 获取
///
- (nullable SJEdgeControlButtonItem *)itemAtIndex:(NSInteger)index;
- (nullable SJEdgeControlButtonItem *)itemForTag:(SJEdgeControlButtonItemTag)tag;
- (NSInteger)indexOfItemForTag:(SJEdgeControlButtonItemTag)tag;
- (nullable NSArray<SJEdgeControlButtonItem *> *)itemsWithRange:(NSRange)range;
- (BOOL)itemsIsHiddenWithRange:(NSRange)range; // 此范围的items是否已隐藏
- (BOOL)itemContainsPoint:(CGPoint)point; // 某个点是否在item中
- (nullable SJEdgeControlButtonItem *)itemAtPoint:(CGPoint)point;
- (BOOL)containsItem:(SJEdgeControlButtonItem *)item;

/// 添加
///
/// - 注意: 添加后, 记得调用刷新
- (void)addItem:(SJEdgeControlButtonItem *)item;
- (void)addItemsFromArray:(NSArray<SJEdgeControlButtonItem *> *)items;
- (void)insertItem:(SJEdgeControlButtonItem *)item atIndex:(NSInteger)index;
- (void)insertItem:(SJEdgeControlButtonItem *)item frontItem:(SJEdgeControlButtonItemTag)tag;
- (void)insertItem:(SJEdgeControlButtonItem *)item rearItem:(SJEdgeControlButtonItemTag)tag;

/// 删除
///
/// - 注意: 删除后, 记得调用刷新
- (void)removeItemAtIndex:(NSInteger)index;
- (void)removeItemForTag:(SJEdgeControlButtonItemTag)tag;
- (void)removeAllItems;

/// 交互位置
///
/// - 注意: 交换后, 记得调用刷新
- (void)exchangeItemAtIndex:(NSInteger)idx1 withItemAtIndex:(NSInteger)idx2;
- (void)exchangeItemForTag:(SJEdgeControlButtonItemTag)tag1 withItemForTag:(SJEdgeControlButtonItemTag)tag2;


@property (nonatomic, strong, readonly) UIView *view;
@property (nonatomic, readonly) NSInteger itemCount;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@property (nonatomic, copy, nullable) void(^frameLayoutContentSizeDidChangeExeBlock)(CGSize size); // 只有在frameLayout布局时, 才会被调用
@property (nonatomic) CGSize frameLayoutItemFillSize;
@end
NS_ASSUME_NONNULL_END
