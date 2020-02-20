//
//  SJScrollToolbar.h
//  SJScrollToolbar
//
//  Created by 畅三江 on 2019/12/23.
//

#import <UIKit/UIKit.h>
#import "SJScrollToolbarDefines.h"
#import "SJScrollToolbarItem.h"
#import "SJScrollToolbarConfiguration.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJScrollToolbar : UIScrollView<SJScrollToolbar>
- (instancetype)initWithConfiguration:(SJScrollToolbarConfiguration *)configuration frame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@property (nonatomic, weak, nullable) id<SJScrollToolbarDelegate> delegate;

- (void)scrollToItemAtIndex:(NSInteger)idx animated:(BOOL)animated;
- (void)scrollInRange:(NSRange)range distanceProgress:(CGFloat)progress;

- (void)resetItems:(NSArray<SJScrollToolbarItem *> *)items scrollToItemAtIndex:(NSInteger)idx animated:(BOOL)animated;

- (void)updateConfiguration:(SJScrollToolbarConfiguration *)configuration animated:(BOOL)animated;
- (void)updateContentsForItemAtIndex:(NSInteger)idx animated:(BOOL)animated;

- (nullable SJScrollToolbarItem *)itemAtIndex:(NSInteger)idx;

@property (nonatomic, strong, readonly, nullable) SJScrollToolbarConfiguration * configuration;
@property (nonatomic, copy, readonly, nullable) NSArray<SJScrollToolbarItem *> *items;
@property (nonatomic, readonly) NSInteger focusedIndex;
@end
NS_ASSUME_NONNULL_END
