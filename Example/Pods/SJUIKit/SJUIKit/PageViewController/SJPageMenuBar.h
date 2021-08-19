//
//  SJPageMenuBar.h
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJPageMenuItemViewDefines.h"
@protocol SJPageMenuBarDataSource, SJPageMenuBarDelegate, SJPageMenuBarGestureHandler, SJPageMenuBarScrollIndicator;
@class SJPageMenuBarScrollInRangeTransitionContext;

typedef NS_ENUM(NSUInteger, SJPageMenuBarDistribution) {
    SJPageMenuBarDistributionEqualSpacing,
    
    ///
    /// fill equally 将忽略 spacing, 所有 item 等宽分布
    ///
    SJPageMenuBarDistributionFillEqually,
};

typedef NS_ENUM(NSUInteger, SJPageMenuBarScrollIndicatorLayoutMode) {
    SJPageMenuBarScrollIndicatorLayoutModeSpecifiedWidth,
    SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewContentWidth,
    SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewLayoutWidth,
};

NS_ASSUME_NONNULL_BEGIN
@interface SJPageMenuBar : UIView
- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, weak, nullable) id<SJPageMenuBarDataSource> dataSource;
@property (nonatomic, weak, nullable) id<SJPageMenuBarDelegate> delegate;
- (void)reloadData;

@property (nonatomic, readonly) NSUInteger focusedIndex;
@property (nonatomic, readonly) NSUInteger numberOfItems;
 
- (void)scrollToItemAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)scrollInRange:(NSRange)range distanceProgress:(CGFloat)progress;
 
- (nullable __kindof UIView<SJPageMenuItemView> *)viewForItemAtIndex:(NSUInteger)index;
- (nullable __kindof UIView<SJPageMenuItemView> *)viewForItemAtPoint:(CGPoint)location;
- (NSInteger)indexOfItemView:(UIView<SJPageMenuItemView> *)itemView;
- (NSInteger)indexOfItemViewAtPoint:(CGPoint)location;

- (void)insertItemAtIndex:(NSUInteger)index animated:(BOOL)animated;
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

@property (nonatomic) CGFloat baselineOffset;                       ///< default is `0`.
@property (nonatomic) CGFloat centerPositionOffset;                 ///< default is `0`.

@property (nonatomic, strong, null_resettable) id<SJPageMenuBarGestureHandler> gestureHandler;
@property (nonatomic, strong, null_resettable) UIView<SJPageMenuBarScrollIndicator> *scrollIndicator;

@property (nonatomic, getter=isEnabledFadeIn) BOOL enabledFadeIn;        ///< enable fade in on the left. default is `NO`.
@property (nonatomic, getter=isEnabledFadeOut) BOOL enabledFadeOut;      ///< enable fade out on the right. default is `NO`.

@property (nonatomic, copy, nullable) void(^layoutSubviewsExecuteBlock)(__kindof SJPageMenuBar *pageMenuBar);
@end


@protocol SJPageMenuBarDataSource <NSObject>
@required
- (NSUInteger)numberOfItemsInPageMenuBar:(SJPageMenuBar *)bar;
- (__kindof UIView<SJPageMenuItemView> *)pageMenuBar:(SJPageMenuBar *)bar viewForItemAtIndex:(NSInteger)index;
@end


@protocol SJPageMenuBarDelegate <NSObject>
@optional
- (void)pageMenuBar:(SJPageMenuBar *)bar focusedIndexDidChange:(NSUInteger)index;

- (UIColor *)pageMenuBar:(SJPageMenuBar *)bar tintColorForItemAtIndex:(NSUInteger)index inContext:(SJPageMenuBarScrollInRangeTransitionContext *)context;
@end


@protocol SJPageMenuBarGestureHandler <NSObject>
@property (nonatomic, copy, nullable) void(^singleTapHandler)(SJPageMenuBar *bar, CGPoint location); // 单击手势的处理, 默认为滚动到点击的位置
@end


@interface SJPageMenuBarScrollInRangeTransitionContext : NSObject
- (instancetype)initWithRange:(NSRange)range distanceProgress:(CGFloat)progress;

@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly) CGFloat distanceProgress;
@end
NS_ASSUME_NONNULL_END
