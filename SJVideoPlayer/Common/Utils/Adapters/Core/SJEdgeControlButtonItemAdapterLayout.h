//
//  SJEdgeControlButtonItemAdapterLayout.h
//  Pods
//
//  Created by 畅三江 on 2019/12/9.
//

#import <Foundation/Foundation.h>
#import "SJEdgeControlButtonItem.h"
@class SJEdgeControlButtonItemLayoutAttributes;

typedef enum : NSUInteger {
    ///
    /// 垂直布局
    ///
    SJAdapterLayoutTypeVerticalLayout,
    
    ///
    /// 水平布局
    ///
    SJAdapterLayoutTypeHorizontalLayout,
    
    ///
    /// 帧布局(一层一层往上盖, 并居中显示)
    ///
    SJAdapterLayoutTypeFrameLayout,
} SJAdapterLayoutType;

NS_ASSUME_NONNULL_BEGIN
@interface SJEdgeControlButtonItemAdapterLayout : NSObject
- (instancetype)initWithLayoutType:(SJAdapterLayoutType)type;

@property (nonatomic, readonly) CGSize intrinsicContentSize;
@property (nonatomic) SJAdapterLayoutType layoutType;
@property (nonatomic, copy, nullable) NSArray<SJEdgeControlButtonItem *> *items;
@property (nonatomic) CGSize preferredMaxLayoutSize;
@property (nonatomic) CGSize itemFillSizeForFrameLayout;

- (void)prepareLayout;
- (nullable NSArray<SJEdgeControlButtonItemLayoutAttributes *> *)layoutAttributesForItems;
- (nullable SJEdgeControlButtonItemLayoutAttributes *)layoutAttributesForItemAtIndex:(NSInteger)index;
@end

@interface SJEdgeControlButtonItemLayoutAttributes : NSObject
+ (instancetype)layoutAttributesForItemWithIndex:(NSInteger)index;
@property (nonatomic) NSInteger index;
@property (nonatomic) CGRect frame;
@property (nonatomic) CGSize size;
@property (nonatomic) CGPoint center;
@end
NS_ASSUME_NONNULL_END
