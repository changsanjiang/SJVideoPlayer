//
//  SJPageMenuBar.h
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJPageMenuItemViewDefines.h"
@protocol SJPageMenuBarDelegate;
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

@property (nonatomic, readonly) NSInteger focusedIndex;
@property (nonatomic, readonly) NSInteger numberOfItems;

@property (nonatomic, copy, nullable) NSArray<UIView<SJPageMenuItemView> *> *itemViews;
- (nullable __kindof UIView<SJPageMenuItemView> *)viewForItemAtIndex:(NSInteger)index;

- (void)reloadItemAtIndex:(NSInteger)index animated:(BOOL)animated;

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)scrollInRange:(NSRange)range distanceProgress:(CGFloat)progress;

@property (nonatomic) SJPageMenuBarDistribution distribution;       // default is `SJPageMenuBarDistributionEqualSpacing`.
@property (nonatomic) UIEdgeInsets contentInsets;                   // default is UIEdgeInsetsZero.
@property (nonatomic) CGFloat itemSpacing;                          // default is `16`.
@property (nonatomic, strong, null_resettable) UIColor *itemTintColor;
@property (nonatomic, strong, null_resettable) UIColor *focusedItemTintColor;
@property (nonatomic) CGFloat minimumZoomScale;                     // default is `1.0`.
@property (nonatomic) CGFloat maximumZoomScale;                     // default is `1.0`. must be > minimum zoom scale to enable zooming.

@property (nonatomic) BOOL showsScrollIndicator;                    // default is `YES`.
@property (nonatomic) CGSize scrollIndicatorSize;                   // default is `CGSize(12, 2)`.
@property (nonatomic) CGFloat scrollIndicatorBottomInset;           // default is `3.0`.
@property (nonatomic, strong, null_resettable) UIColor *scrollIndicatorTintColor;
@property (nonatomic) SJPageMenuBarScrollIndicatorLayoutMode scrollIndicatorLayoutMode;

@property (nonatomic) CGFloat centerlineOffset;                     // default is `0`.
@end


@protocol SJPageMenuBarDelegate <NSObject>
@optional
- (void)pageMenuBar:(SJPageMenuBar *)bar focusedIndexDidChange:(NSInteger)index;
@end
NS_ASSUME_NONNULL_END
