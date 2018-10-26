//
//  SJEdgeControlLayerItemAdapter.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/19.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJEdgeControlButtonItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJEdgeControlLayerItemAdapter : NSObject
- (instancetype)initWithDirection:(UICollectionViewScrollDirection)direction;
/// 刷新
- (void)reload;
- (void)updateContentForItemWithTag:(SJEdgeControlButtonItemTag)tag;

/// 获取
- (nullable SJEdgeControlButtonItem *)itemAtIndex:(NSInteger)index;
- (nullable SJEdgeControlButtonItem *)itemForTag:(SJEdgeControlButtonItemTag)tag;
- (NSInteger)indexOfItemForTag:(SJEdgeControlButtonItemTag)tag;
- (nullable NSArray<SJEdgeControlButtonItem *> *)itemsWithRange:(NSRange)range;
- (BOOL)itemsIsHiddenWithRange:(NSRange)range; // 此范围的items是否已隐藏

/// 添加
/// - 注意: 添加后, 记得调用刷新
- (void)addItem:(SJEdgeControlButtonItem *)item;
- (void)insertItem:(SJEdgeControlButtonItem *)item atIndex:(NSInteger)index;

/// 删除
/// - 注意: 删除后, 记得调用刷新
- (void)removeItemAtIndex:(NSInteger)index;

/// 交互位置
/// - 注意: 交互后, 记得调用刷新
- (void)exchangeItemAtIndex:(NSInteger)idx1 withItemAtIndex:(NSInteger)idx2;
- (void)exchangeItemForTag:(SJEdgeControlButtonItemTag)tag1 withItemForTag:(SJEdgeControlButtonItemTag)tag2;

@property (nonatomic, strong, readonly) UIView *view;
@property (nonatomic, readonly) NSInteger itemCount;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
