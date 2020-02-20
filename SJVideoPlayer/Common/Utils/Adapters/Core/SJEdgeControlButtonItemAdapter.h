//
//  SJEdgeControlButtonItemAdapter.h
//  Pods
//
//  Created by 畅三江 on 2019/12/9.
//

#import <UIKit/UIKit.h>
#import "SJEdgeControlButtonItemAdapterLayout.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJEdgeControlButtonItemAdapter : UIView
- (instancetype)initWithFrame:(CGRect)frame layoutType:(SJAdapterLayoutType)type;

///
/// 刷新
///
- (void)reload;
- (void)updateContentForItemWithTag:(SJEdgeControlButtonItemTag)tag;

///
/// 布局方式
///
/// - 注意: 修改后, 记得调用刷新
///
@property (nonatomic) SJAdapterLayoutType layoutType;

@property (nonatomic) CGSize itemFillSizeForFrameLayout;

///
/// 获取
///
- (nullable SJEdgeControlButtonItem *)itemAtIndex:(NSInteger)index;
- (nullable SJEdgeControlButtonItem *)itemForTag:(SJEdgeControlButtonItemTag)tag;
- (NSInteger)indexOfItemForTag:(SJEdgeControlButtonItemTag)tag;
- (nullable NSArray<SJEdgeControlButtonItem *> *)itemsWithRange:(NSRange)range;
- (BOOL)isHiddenWithRange:(NSRange)range; // 此范围的items是否已隐藏
- (BOOL)itemContainsPoint:(CGPoint)point; // 某个点是否在item中
- (nullable SJEdgeControlButtonItem *)itemAtPoint:(CGPoint)point;
- (BOOL)containsItem:(SJEdgeControlButtonItem *)item;

///
/// 添加
///
/// - 注意: 添加后, 记得调用刷新
///
- (void)addItem:(SJEdgeControlButtonItem *)item;
- (void)addItemsFromArray:(NSArray<SJEdgeControlButtonItem *> *)items;
- (void)insertItem:(SJEdgeControlButtonItem *)item atIndex:(NSInteger)index;
- (void)insertItem:(SJEdgeControlButtonItem *)item frontItem:(SJEdgeControlButtonItemTag)tag;
- (void)insertItem:(SJEdgeControlButtonItem *)item rearItem:(SJEdgeControlButtonItemTag)tag;

///
/// 删除
///
/// - 注意: 删除后, 记得调用刷新
///
- (void)removeItemAtIndex:(NSInteger)index;
- (void)removeItemForTag:(SJEdgeControlButtonItemTag)tag;
- (void)removeAllItems;

///
/// 交换位置
///
/// - 注意: 交换后, 记得调用刷新
///
- (void)exchangeItemAtIndex:(NSInteger)idx1 withItemAtIndex:(NSInteger)idx2;
- (void)exchangeItemForTag:(SJEdgeControlButtonItemTag)tag1 withItemForTag:(SJEdgeControlButtonItemTag)tag2;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;

///
/// item的数量
///
@property (nonatomic, readonly) NSInteger numberOfItems;


//
// 以下为兼容老的adapter
//
@property (nonatomic, strong, readonly) SJEdgeControlButtonItemAdapter *view;
@property (nonatomic, readonly) NSInteger itemCount;
@end


typedef SJEdgeControlButtonItemAdapter SJEdgeControlLayerItemAdapter;
NS_ASSUME_NONNULL_END
