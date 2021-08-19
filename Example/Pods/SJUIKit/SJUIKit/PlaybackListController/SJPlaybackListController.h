//
//  SJPlaybackListController.h
//  SJPlaybackListController_Example
//
//  Created by 蓝舞者 on 2021/6/17.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "SJPlaybackListControllerInterfaces.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJPlaybackListController<ItemType> : NSObject<SJPlaybackListController>
- (instancetype)initWithPlaybackController:(nullable id<SJPlaybackController>)playbackController queue:(dispatch_queue_t)queue;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, weak, readonly, nullable) id<SJPlaybackController> playbackController;

// observer

- (void)registerObserver:(id<SJPlaybackListControllerObserver>)observer;
- (void)removeObserver:(id<SJPlaybackListControllerObserver>)observer;

// items

@property (nonatomic, readonly) NSInteger numberOfItems;
- (nullable ItemType <SJPlaybackItem>)itemAtIndex:(NSInteger)index;
- (NSInteger)indexOfItem:(ItemType <SJPlaybackItem>)item;

- (void)addItem:(ItemType <SJPlaybackItem>)item;
- (void)addItemsFromArray:(NSArray<ItemType <SJPlaybackItem>> *)items;
- (void)insertItemToNextPlay:(ItemType <SJPlaybackItem>)item;

- (void)replaceItemsFromArray:(NSArray<id<SJPlaybackItem>> *)items;
- (void)replaceItemAtIndex:(NSInteger)index withItem:(id<SJPlaybackItem>)item;

- (void)removeAllItems;
- (void)removeItemAtIndex:(NSInteger)index;

- (void)enumerateItemsUsingBlock:(void(NS_NOESCAPE ^)(ItemType <SJPlaybackItem> item, NSInteger index, BOOL *stop))block;

// playback mode

@property (nonatomic, readonly) SJPlaybackMode mode;
@property (nonatomic) SJPlaybackModeMask supportedModes;
- (void)switchToMode:(SJPlaybackMode)mode;
- (void)switchMode;
  
// playback control

@property (nonatomic, readonly) NSInteger curIndex;
- (void)playItemAtIndex:(NSInteger)index;
- (void)playNextItem;
- (void)playPreviousItem;
@end

NS_ASSUME_NONNULL_END
