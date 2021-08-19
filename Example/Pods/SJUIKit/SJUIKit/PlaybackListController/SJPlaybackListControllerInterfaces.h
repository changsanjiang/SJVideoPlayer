//
//  SJPlaybackListControllerInterfaces.h
//  SJPlaybackListController
//
//  Created by 蓝舞者 on 2021/6/17.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#ifndef SJPlaybackListControllerInterfaces_h
#define SJPlaybackListControllerInterfaces_h

#import "SJPlaybackListControllerDefines.h"
@protocol SJPlaybackItem, SJPlaybackListControllerObserver, SJPlaybackController, SJPlaybackControllerObserver;

NS_ASSUME_NONNULL_BEGIN

@protocol SJPlaybackItem <NSObject>
- (BOOL)isEqualToPlaybackItem:(id<SJPlaybackItem>)item;
@end

#pragma mark - SJPlaybackListController

@protocol SJPlaybackListController <NSObject>

@property (nonatomic, weak, readonly, nullable) id<SJPlaybackController> playbackController;

// observer

- (void)registerObserver:(id<SJPlaybackListControllerObserver>)observer;
- (void)removeObserver:(id<SJPlaybackListControllerObserver>)observer;

// items

@property (nonatomic, readonly) NSInteger numberOfItems;
- (nullable id<SJPlaybackItem>)itemAtIndex:(NSInteger)index;
- (NSInteger)indexOfItem:(id<SJPlaybackItem>)item;

- (void)addItem:(id<SJPlaybackItem>)item;
- (void)addItemsFromArray:(NSArray<id<SJPlaybackItem>> *)items;
- (void)insertItemToNextPlay:(id<SJPlaybackItem>)item;
- (void)replaceItemsFromArray:(NSArray<id<SJPlaybackItem>> *)items;

- (void)removeAllItems;
- (void)removeItemAtIndex:(NSInteger)index;

- (void)enumerateItemsUsingBlock:(void(NS_NOESCAPE ^)(__kindof id<SJPlaybackItem> item, NSInteger index, BOOL *stop))block;

// playback mode

@property (nonatomic, readonly) SJPlaybackMode mode;
@property (nonatomic, readonly) SJPlaybackModeMask supportedModes;
- (void)switchToMode:(SJPlaybackMode)mode;
- (void)switchMode;
   
// playback control

@property (nonatomic, readonly) NSInteger curIndex;
- (void)playItemAtIndex:(NSInteger)index;
- (void)playCurrentItem;
- (void)playNextItem;
- (void)playPreviousItem;
@end

@protocol SJPlaybackListControllerObserver <NSObject>
@optional
- (void)playbackListController:(id<SJPlaybackListController>)controller modeDidChange:(SJPlaybackMode)mode;
- (void)itemListDidUpdateForPlaybackListController:(id<SJPlaybackListController>)controller;
@end

#pragma mark - SJPlaybackController

@protocol SJPlaybackController <NSObject>
@property (nonatomic, readonly) BOOL isPaused;
@property (nonatomic, strong, readonly, nullable) id<SJPlaybackItem> currentItem;
- (void)playWithItem:(id<SJPlaybackItem>)item;
- (void)replay;
- (void)stop;

- (void)registerObserver:(id<SJPlaybackControllerObserver>)observer;
- (void)removeObserver:(id<SJPlaybackControllerObserver>)observer;
@end

@protocol SJPlaybackControllerObserver <NSObject>
@optional
- (void)playbackControllerDidFinishPlaying:(id<SJPlaybackController>)controller;
@end
NS_ASSUME_NONNULL_END

#endif /* SJPlaybackListControllerInterfaces_h */
