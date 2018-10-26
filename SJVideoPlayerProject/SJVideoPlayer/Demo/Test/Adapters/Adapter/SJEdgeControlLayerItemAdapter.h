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
@property (nonatomic, strong, readonly) UIView *view;

- (void)reload;
- (void)updateContentForItemWithTag:(SJEdgeControlButtonItemTag)tag;
- (void)addItem:(SJEdgeControlButtonItem *)item;
- (void)insertItem:(SJEdgeControlButtonItem *)item atIndex:(NSInteger)index;
- (void)removeItemAtIndex:(NSInteger)index;
- (nullable SJEdgeControlButtonItem *)itemAtIndex:(NSInteger)index;
- (nullable SJEdgeControlButtonItem *)itemForTag:(SJEdgeControlButtonItemTag)tag;
- (NSInteger)indexOfItemForTag:(SJEdgeControlButtonItemTag)tag;

@property (nonatomic, readonly) NSInteger itemCount;
- (nullable NSArray<SJEdgeControlButtonItem *> *)itemsWithRange:(NSRange)range;
- (BOOL)itemsIsHiddenWithRange:(NSRange)range; // 此范围的items是否已隐藏

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
