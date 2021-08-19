//
//  SJPlaybackListController.m
//  SJPlaybackListController_Example
//
//  Created by 蓝舞者 on 2021/6/17.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "SJPlaybackListController.h"
 
static void *mQueueKey = &mQueueKey;

FOUNDATION_STATIC_INLINE void
sj_queue_sync(dispatch_queue_t queue, NS_NOESCAPE dispatch_block_t block) {
    if ( dispatch_get_specific(mQueueKey) != NULL ) {
        block();
    }
    else {
        dispatch_sync(queue, block);
    }
}

@interface SJPlaybackListController ()<SJPlaybackControllerObserver> {
    dispatch_queue_t _queue;
    NSMutableArray<id<SJPlaybackItem>> *_items;
    SJPlaybackModeMask _supportedModes;
    SJPlaybackMode _mode;
    NSInteger _curIndex;
}
@property (nonatomic) SJPlaybackMode mode;
@end

@implementation SJPlaybackListController {
    NSHashTable<id<SJPlaybackListControllerObserver>> *_observers;
}

- (instancetype)initWithPlaybackController:(nullable id<SJPlaybackController>)playbackController queue:(dispatch_queue_t)queue {
    self = [super init];
    if ( self ) {
        _queue = queue;
        dispatch_queue_set_specific(queue, mQueueKey, mQueueKey, NULL);
        _playbackController = playbackController;
        [_playbackController registerObserver:self];
        _items = NSMutableArray.array;
        _supportedModes = SJPlaybackModeMaskAll;
        _curIndex = NSNotFound;
    }
    return self;
}
 
- (void)registerObserver:(id<SJPlaybackListControllerObserver>)observer {
    if ( observer != nil ) {
        sj_queue_sync(_queue, ^{
            if ( _observers == nil ) {
                _observers = [NSHashTable weakObjectsHashTable];
            }
            [_observers addObject:observer];
        });
    }
}

- (void)removeObserver:(id<SJPlaybackListControllerObserver>)observer {
    if ( observer != nil ) {
        sj_queue_sync(_queue, ^{
            [_observers removeObject:observer];
        });
    }
}

- (NSInteger)numberOfItems {
    __block NSInteger count = 0;
    sj_queue_sync(_queue, ^{
        count = _items.count;
    });
    return count;
}

- (nullable id<SJPlaybackItem>)itemAtIndex:(NSInteger)index {
    __block id item = nil;
    sj_queue_sync(_queue, ^{
        item = [self _itemAtIndex:index];
    });
    return item;
}

- (NSInteger)indexOfItem:(id<SJPlaybackItem>)item {
    __block NSInteger idx = NSNotFound;
    sj_queue_sync(_queue, ^{
        idx = [self _indexOfItem:item];
    });
    return idx;
}
 
/// 向列表中添加单个播放项目
///
- (void)addItem:(id<SJPlaybackItem>)item {
    if ( item != nil ) {
        [self addItemsFromArray:@[item]];
    }
}

/// 向列表中添加多个播放项目
///
- (void)addItemsFromArray:(NSArray *)items {
    if ( items.count != 0 ) {
        sj_queue_sync(_queue, ^{
            for ( id<SJPlaybackItem> item in items ) {
                [self _addItem:item];
            }
            [self _notifyObserversItemListDidUpdate];
        });
    }
}

/// 添加到下一个播放
///
- (void)insertItemToNextPlay:(id<SJPlaybackItem>)item {
    if ( item == nil )
        return;
    
    sj_queue_sync(_queue, ^{
        [self _insertItemToNextPlay:item];
        [self _notifyObserversItemListDidUpdate];
    });
}

/// 替换列表
///
- (void)replaceItemsFromArray:(NSArray *)items {
    if ( items.count == 0 ) {
        [self removeAllItems];
        return;
    }
    
    sj_queue_sync(_queue, ^{
        [self _replaceItemsFromArray:items];
        [self _stopIfNeeded]; // 如果当前播放的item不存在就stop
        [self _notifyObserversItemListDidUpdate];
    });
}

- (void)replaceItemAtIndex:(NSInteger)index withItem:(id<SJPlaybackItem>)item {
    if ( item == nil )
        return;
    sj_queue_sync(_queue, ^{
        [self _replaceItemAtIndex:index withItem:item];
        [self _stopIfNeeded]; // 如果当前播放的item不存在就stop
        [self _notifyObserversItemListDidUpdate];
    });
}

- (void)removeAllItems {
    sj_queue_sync(_queue, ^{
        [self _removeAllItems];
        [self _stopIfNeeded];
        [self _notifyObserversItemListDidUpdate];
    });
}

- (void)removeItemAtIndex:(NSInteger)index {
    sj_queue_sync(_queue, ^{
        [self _removeItemAtIndex:index];
        [self _playOrStopIfNeeded];
        [self _notifyObserversItemListDidUpdate];
    });
}

- (void)enumerateItemsUsingBlock:(void(NS_NOESCAPE ^)(id<SJPlaybackItem> item, NSInteger index, BOOL *stop))block {
    sj_queue_sync(_queue, ^{
        [_items.copy enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            block(obj, idx, stop);
        }];
    });
}

- (SJPlaybackMode)mode {
    __block SJPlaybackMode mode = 0;
    sj_queue_sync(_queue, ^{
        mode = _mode;
    });
    return mode;
}

- (void)setSupportedModes:(SJPlaybackModeMask)supportedModes {
    NSParameterAssert(supportedModes != 0);
    NSParameterAssert(supportedModes <= SJPlaybackModeMaskAll);
    sj_queue_sync(_queue, ^{
        _supportedModes = supportedModes;
    });
}

- (SJPlaybackModeMask)supportedModes {
    __block SJPlaybackModeMask supportedModes = 0;
    sj_queue_sync(_queue, ^{
        supportedModes = _supportedModes;
    });
    return supportedModes;
}

- (void)switchToMode:(SJPlaybackMode)mode {
    sj_queue_sync(_queue, ^{
        if ( [self _isModeSupported:mode] ) {
            [self _switchToMode:mode];
        }
    });
}

- (void)switchMode {
    sj_queue_sync(_queue, ^{
        SJPlaybackMode mode = _mode;
        if ( _supportedModes == (1 << mode) ) return;
        
        do {
            mode = (mode + 1) % 3;
        } while ( ![self _isModeSupported:mode] );
        [self _switchToMode:mode];
    });
}

- (void)playItemAtIndex:(NSInteger)index {
    sj_queue_sync(_queue, ^{
        [self _playItemAtIndex:index];
    });
}

- (void)playCurrentItem {
    sj_queue_sync(_queue, ^{
        [self _playItemAtIndex:_curIndex];
    });
}

- (void)playNextItem {
    sj_queue_sync(_queue, ^{
        [self _playNextItem];
    });
}

- (void)playPreviousItem {
    sj_queue_sync(_queue, ^{
        [self _playPreviousItem];
    });
}

#pragma mark - SJPlaybackControllerObserver

- (void)playbackControllerDidFinishPlaying:(id<SJPlaybackController>)controller {
    sj_queue_sync(_queue, ^{
        if ( _items.count == 0 )
            return;
        
        if ( _mode == SJPlaybackModeRepeatOne ) {
            [self _replay];
            return;
        }
        
        [self _playNextItem];
    });
}

#pragma mark -

- (void)_notifyObserversItemListDidUpdate {
    [self _enumerateObserversUsingBlock:^(id<SJPlaybackListControllerObserver> observer, NSInteger index, BOOL *stop) {
        if ( [observer respondsToSelector:@selector(itemListDidUpdateForPlaybackListController:)] ) {
            [observer itemListDidUpdateForPlaybackListController:self];
        }
    }];
}

- (BOOL)_isSafeIndexForGetting:(NSInteger)index {
    return index >= 0 && index < _items.count;
}

- (BOOL)_isSafeIndexForInserting:(NSInteger)index {
    return index >= 0 && index <= _items.count;
}

- (nullable id<SJPlaybackItem>)_itemAtIndex:(NSInteger)index {
    return [self _isSafeIndexForGetting:index] ? [_items objectAtIndex:index] : nil;
}

- (NSInteger)_indexOfItem:(id<SJPlaybackItem>)item {
   if ( item != nil ) {
       for ( NSInteger i = 0 ; i < _items.count ; ++ i ) {
           if ( [_items[i] isEqualToPlaybackItem:item] )
               return i;
       }
   }
   return NSNotFound;
}

- (void)_enumerateObserversUsingBlock:(void(NS_NOESCAPE ^)(id<SJPlaybackListControllerObserver> observer, NSInteger index, BOOL *stop))block {
    if ( _observers.count != 0 ) {
        [NSAllHashTableObjects(_observers) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            block(obj, idx, stop);
        }];
    }
}

- (void)_addItem:(id<SJPlaybackItem>)item {
    if ( item == nil ) return;
    // 如果为curItem, 则return
    if ( [[self _itemAtIndex:_curIndex] isEqualToPlaybackItem:item] ) return;
    [self _removeItem:item];
    [_items addObject:item];

    // 添加新的item时, 将索引自动置位0
    if ( _curIndex == NSNotFound )
        _curIndex = 0;
}

- (void)_insertItemToNextPlay:(id<SJPlaybackItem>)item {
    if ( item == nil ) return;
    if ( [[self _itemAtIndex:_curIndex] isEqualToPlaybackItem:item] ) return;
    
    if ( _items.count == 0 ) {
        [_items addObject:item];
        _curIndex = 0;
    }
    else {
        [self _removeItem:item];
        [_items insertObject:item atIndex:_curIndex + 1];
    }
}

- (void)_replaceItemsFromArray:(NSArray<id<SJPlaybackItem>> *)items {
    id<SJPlaybackItem> curItem = [self _itemAtIndex:_curIndex];
    [self _removeAllItems];
    if ( items.count == 0 ) return;
    for ( id<SJPlaybackItem> item in items ) {
        [self _addItem:item];
    }
    NSInteger newIndex = [self _indexOfItem:curItem];
    if ( newIndex != NSNotFound ) {
        _curIndex = newIndex;
    }
}

- (void)_replaceItemAtIndex:(NSInteger)index withItem:(id<SJPlaybackItem>)item {
    if ( item == nil ) return;
    if ( ![self _isSafeIndexForGetting:index] ) return;
    [_items replaceObjectAtIndex:index withObject:item];
    if ( index == _curIndex && ![[self _itemAtIndex:_curIndex] isEqualToPlaybackItem:_playbackController.currentItem] ) {
        [_playbackController stop];
    }
}

- (void)_removeItem:(id<SJPlaybackItem>)item {
    [self _removeItemAtIndex:[self _indexOfItem:item]];
}

- (void)_removeItemAtIndex:(NSInteger)index {
    if ( index != NSNotFound ) {
        [_items removeObjectAtIndex:index];
        // 删除时, 维护curIndex
        if ( index < _curIndex ) {
            _curIndex -= 1;
        }
    }
}

- (void)_removeAllItems {
    [_items removeAllObjects];
    _curIndex = NSNotFound;
}

#pragma mark - mark

- (BOOL)_isModeSupported:(SJPlaybackMode)mode {
    return (1 << mode) & _supportedModes;
}

- (void)_switchToMode:(SJPlaybackMode)mode {
    if ( mode != _mode ) {
        _mode = mode;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _enumerateObserversUsingBlock:^(id<SJPlaybackListControllerObserver> observer, NSInteger index, BOOL *stop) {
                if ( [observer respondsToSelector:@selector(playbackListController:modeDidChange:)] ) {
                    [observer playbackListController:self modeDidChange:mode];
                }
            }];
        });
    }
}

#pragma mark - mark

- (void)_shufflePlay {
    NSInteger count = _items.count;
   if ( count == 0 )
       return;

    if ( count == 1 ) {
        [self _playItemAtIndex:0];
        return;
    }
    
    NSInteger nextIdx = 0;
    do {
        nextIdx = arc4random() % count;
    } while ( nextIdx == _curIndex);
    [self _playItemAtIndex:nextIdx];
}

- (void)_playItemAtIndex:(NSInteger)index {
    id item = [self _isSafeIndexForGetting:index] ? [_items objectAtIndex:index] : nil;
    if ( item == nil ) return;
    _curIndex = index;
    [_playbackController playWithItem:item];
}

- (void)_replay {
    [_playbackController replay];
}

- (void)_playNextItem {
    if ( _mode == SJPlaybackModeShuffle ) {
        [self _shufflePlay];
        return;
    }

    NSInteger count = _items.count;
   if ( count == 0 )
       return;
    
    if ( count == 1 ) {
        id<SJPlaybackItem> item = [self _itemAtIndex:0];
        [_playbackController.currentItem isEqualToPlaybackItem:item] ? [self _replay] : [self _playItemAtIndex:0];
        return;
    }
     
    NSInteger nextIdx = _curIndex + 1;
    if ( nextIdx == count ) {
        nextIdx = 0;
    }
    [self _playItemAtIndex:nextIdx];
}

- (void)_playPreviousItem {
    if ( _mode == SJPlaybackModeShuffle ) {
        [self _shufflePlay];
        return;
    }

    NSInteger count = _items.count;
   if ( count == 0 )
       return;
    
    if ( count == 1 ) {
        id<SJPlaybackItem> item = [self _itemAtIndex:0];
        [_playbackController.currentItem isEqualToPlaybackItem:item] ? [self _replay] : [self _playItemAtIndex:0];
        return;
    }
     
    NSInteger previousIdx = _curIndex - 1;
    if ( previousIdx == -1 ) {
        previousIdx = count - 1;
    }
    [self _playItemAtIndex:previousIdx];
}

- (void)_stopIfNeeded {
    if ( _curIndex == NSNotFound || ![[self _itemAtIndex:_curIndex] isEqualToPlaybackItem:_playbackController.currentItem] ) {
        // clean currentItem for controller
        [_playbackController stop];
    }
}

- (void)_playOrStopIfNeeded {
    if ( _curIndex != NSNotFound && ![[self _itemAtIndex:_curIndex] isEqualToPlaybackItem:_playbackController.currentItem] ) {
        BOOL isPaused = _playbackController.isPaused;
        // `clean currentItem for controller` or `play new item if controller before is playing`
        isPaused ? [_playbackController stop] : [self _playItemAtIndex:_curIndex];
    }
}
@end
