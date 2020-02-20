//
//  SJScrollToolbarDefines.h
//  Pods
//
//  Created by 畅三江 on 2019/12/23.
//

#ifndef SJScrollToolbarDefines_h
#define SJScrollToolbarDefines_h
#import <UIKit/UIKit.h>
@protocol SJScrollToolbarItem, SJScrollToolbarDelegate, SJScrollToolbarConfiguration;

NS_ASSUME_NONNULL_BEGIN
@protocol SJScrollToolbar <NSObject>
- (instancetype)initWithConfiguration:(id<SJScrollToolbarConfiguration>)config frame:(CGRect)frame;

- (void)scrollToItemAtIndex:(NSInteger)idx animated:(BOOL)animated;
- (void)scrollInRange:(NSRange)range distanceProgress:(CGFloat)progress;

- (void)resetItems:(NSArray<id<SJScrollToolbarItem>> *)items scrollToItemAtIndex:(NSInteger)idx animated:(BOOL)animated;

- (void)updateConfiguration:(id<SJScrollToolbarConfiguration>)configuration animated:(BOOL)animated;
- (void)updateContentsForItemAtIndex:(NSInteger)idx animated:(BOOL)animated;

- (nullable id<SJScrollToolbarItem>)itemAtIndex:(NSInteger)idx;

@property (nonatomic, strong, readonly, nullable) id<SJScrollToolbarConfiguration> configuration;
@property (nonatomic, copy, readonly, nullable) NSArray<id<SJScrollToolbarItem>> *items;
@property (nonatomic, weak, nullable) id<SJScrollToolbarDelegate> delegate;
@property (nonatomic, readonly) NSInteger focusedIndex;
@end

@protocol SJScrollToolbarDelegate <UIScrollViewDelegate>
- (void)scrollToolbar:(id<SJScrollToolbar>)bar focusedIndexDidChange:(NSInteger)index;
@end

typedef enum : NSUInteger {
    SJScrollToolbarDistributionEqualSpacing,
    
    ///
    /// fill equally 将忽略 spacing, 所有 item 等宽分布
    ///
    SJScrollToolbarDistributionFillEqually,
} SJScrollToolbarDistribution;

typedef enum : NSUInteger {
    SJScrollToolbarAlignmentBottom,
    SJScrollToolbarAlignmentCenter,
} SJScrollToolbarAlignment;

@protocol SJScrollToolbarConfiguration <NSObject>
@property (nonatomic, readonly) CGFloat barHeight;
@property (nonatomic, readonly) SJScrollToolbarDistribution distribution;
@property (nonatomic, readonly) SJScrollToolbarAlignment alignment;
@property (nonatomic, readonly) CGFloat spacing;
@property (nonatomic, strong, readonly, nullable) UIColor *barTintColor;
@property (nonatomic, strong, readonly, nullable) UIColor *itemTintColor;
@property (nonatomic, strong, readonly, nullable) UIColor *focusedItemTintColor;
@property (nonatomic, strong, readonly, nullable) UIFont *maximumFont;
@property (nonatomic, readonly) CGFloat minimumZoomScale;
@property (nonatomic, readonly) NSTimeInterval animationDuration;

@property (nonatomic, readonly) CGSize lineSize;
@property (nonatomic, readonly) CGFloat lineCornerRadius;
@property (nonatomic, readonly) CGFloat lineBottomMargin;
@property (nonatomic, strong, readonly, nullable) UIColor *lineTintColor;
@end

@protocol SJScrollToolbarItem <NSObject>
@property (nonatomic, copy, nullable) NSAttributedString *attributedString;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *imageUrl;
@property (nonatomic, strong, nullable) UIImage *image;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END

#endif /* SJScrollToolbarDefines_h */
