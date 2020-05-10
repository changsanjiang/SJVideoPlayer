//
//  SJPageMenuBar.h
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJPageMenuItemViewDefines.h"
@protocol SJPageMenuBarDelegate, SJPageMenuBarGestureHandler, SJPageMenuBarScrollIndicator;

typedef enum : NSUInteger {
    SJPageMenuBarDistributionEqualSpacing,
    
    ///
    /// fill equally 将忽略 spacing, 所有 item 等宽分布
    ///
    SJPageMenuBarDistributionFillEqually,
} SJPageMenuBarDistribution;

typedef enum : NSUInteger {
    SJPageMenuBarScrollIndicatorLayoutModeSpecifiedWidth,
    SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewContentWidth,
    SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewLayoutWidth,
} SJPageMenuBarScrollIndicatorLayoutMode;

NS_ASSUME_NONNULL_BEGIN
@interface SJPageMenuBar : UIView
@property (nonatomic, weak, nullable) id<SJPageMenuBarDelegate> delegate;
@property (nonatomic, readonly) NSUInteger focusedIndex;
 
- (void)scrollToItemAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)scrollInRange:(NSRange)range distanceProgress:(CGFloat)progress;
 
@property (nonatomic, copy, nullable) NSArray<__kindof UIView<SJPageMenuItemView> *> *itemViews;
@property (nonatomic, readonly) NSUInteger numberOfItems;
- (nullable __kindof UIView<SJPageMenuItemView> *)viewForItemAtIndex:(NSUInteger)index;

- (void)insertItemAtIndex:(NSUInteger)index view:(__kindof UIView<SJPageMenuItemView> *)newView animated:(BOOL)animated;
- (void)deleteItemAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)reloadItemAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)moveItemAtIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex animated:(BOOL)animated;

@property (nonatomic) SJPageMenuBarDistribution distribution;       ///< default is `SJPageMenuBarDistributionEqualSpacing`.
@property (nonatomic) UIEdgeInsets contentInsets;                   ///< default is `UIEdgeInsetsZero`.
@property (nonatomic) CGFloat itemSpacing;                          ///< default is `16`.
@property (nonatomic, strong, null_resettable) UIColor *itemTintColor;
@property (nonatomic, strong, null_resettable) UIColor *focusedItemTintColor;
@property (nonatomic) CGFloat minimumZoomScale;                     ///< default is `1.0`.
@property (nonatomic) CGFloat maximumZoomScale;                     ///< default is `1.0`. must be > minimum zoom scale to enable zooming.

@property (nonatomic) BOOL showsScrollIndicator;                    ///< default is `YES`.
@property (nonatomic) CGSize scrollIndicatorSize;                   ///< default is `CGSize(12, 2)`.
@property (nonatomic) CGSize scrollIndicatorExpansionSize;          ///< default is .zero. scrollIndicator.size = scrollIndicatorSize + scrollIndicatorExpansionSize
@property (nonatomic) CGFloat scrollIndicatorBottomInset;           ///< default is `3.0`.
@property (nonatomic, strong, null_resettable) UIColor *scrollIndicatorTintColor;
@property (nonatomic) SJPageMenuBarScrollIndicatorLayoutMode scrollIndicatorLayoutMode;

@property (nonatomic) CGFloat centerlineOffset;                     ///< default is `0`.

@property (nonatomic, strong, null_resettable) id<SJPageMenuBarGestureHandler> gestureHandler;
@property (nonatomic, strong, null_resettable) UIView<SJPageMenuBarScrollIndicator> *scrollIndicator;

@property (nonatomic, getter=isEnabledFadeIn) BOOL enabledFadeIn;        ///< enable fade in on the left. default is `NO`.
@property (nonatomic, getter=isEnabledFadeOut) BOOL enabledFadeOut;      ///< enable fade out on the right. default is `NO`.
@end


@protocol SJPageMenuBarDelegate <NSObject>
@optional
- (void)pageMenuBar:(SJPageMenuBar *)bar focusedIndexDidChange:(NSUInteger)index;
@end


@protocol SJPageMenuBarGestureHandler <NSObject>
@property (nonatomic, copy, nullable) void(^singleTapHandler)(SJPageMenuBar *bar, CGPoint location); // 单击手势的处理, 默认为滚动到点击的位置
@end  
NS_ASSUME_NONNULL_END
