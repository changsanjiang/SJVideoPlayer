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
@protocol SJPlaybackItem, SJPlaybackController, SJPlaybackListControllerObserver;

NS_ASSUME_NONNULL_BEGIN
@protocol SJPlaybackListController <NSObject>

@property (nonatomic, weak, readonly, nullable) id<SJPlaybackController> playbackController;

// observer

- (void)registerObserver:(id<SJPlaybackListControllerObserver>)observer;
- (void)removeObserver:(id<SJPlaybackListControllerObserver>)observer;

// items

@property (nonatomic, readonly) NSInteger numberOfItems;
- (nullable id<SJPlaybackItem>)itemAtIndex:(NSInteger)index;
- (NSInteger)indexOfItem:(id<SJPlaybackItem>)item;
- (NSInteger)indexOfItemForKey:(id)itemKey;

- (void)addItem:(id<SJPlaybackItem>)item;
- (void)addItemsFromArray:(NSArray<id<SJPlaybackItem>> *)items;
- (void)insertItemToNextPlay:(id<SJPlaybackItem>)item;
- (void)replaceItemsFromArray:(NSArray<id<SJPlaybackItem>> *)items;

- (void)removeAllItems;
- (void)removeItemAtIndex:(NSInteger)index;

- (void)enumerateItemsUsingBlock:(void(NS_NOESCAPE ^)(id<SJPlaybackItem> item, NSInteger index, BOOL *stop))block;

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

@protocol SJPlaybackItem <NSObject>
@property (nonatomic, strong, readonly) id itemKey;
@end

typedef void(^SJPlaybackCompletionHandler)(void);

@protocol SJPlaybackController <NSObject>
/// 该block由列表控制进行设置.
/// 播放控制请在播放完毕后调用该block.
/// 列表控制将会通过该block来监听播放完成的时机, 以此来切换下一个item.
@property (nonatomic, copy, nullable) SJPlaybackCompletionHandler playbackCompletionHandler;
@property (nonatomic, strong, readonly, nullable) id<SJPlaybackItem> curItem;
@property (nonatomic, readonly) BOOL isPaused;
- (void)playWithItem:(id<SJPlaybackItem>)item;
- (void)replay;
- (void)stop;
@end

@protocol SJPlaybackListControllerObserver <NSObject>
@optional
- (void)playbackListController:(id<SJPlaybackListController>)controller didPlayItem:(id<SJPlaybackItem>)item;
- (void)playbackListController:(id<SJPlaybackListController>)controller modeDidChange:(SJPlaybackMode)mode;
- (void)itemListDidChangeForPlaybackListController:(id<SJPlaybackListController>)controller;
@end
NS_ASSUME_NONNULL_END

#endif /* SJPlaybackListControllerInterfaces_h */
