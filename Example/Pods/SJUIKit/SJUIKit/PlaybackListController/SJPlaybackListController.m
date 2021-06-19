//
//  SJPlaybackListController.m
//  SJPlaybackListController_Example
//
//  Created by 蓝舞者 on 2021/6/17.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "SJPlaybackListController.h"

@interface NSArray (SJPlaybackListControllerExtended)
- (NSInteger)_indexOfItemForItemKey:(nullable id)itemKey;
@end

@implementation NSArray (SJPlaybackListControllerExtended)
- (NSInteger)_indexOfItemForItemKey:(nullable id)itemKey {
    if ( itemKey != nil ) {
        for ( NSInteger i = 0 ; i < self.count ; ++ i ) {
            id<SJPlaybackItem> item = self[i];
            if ( [item.itemKey isEqual:itemKey] )
                return i;
        }
    }
    return NSNotFound;
}
@end

@interface SJPlaybackListController () {
    NSMutableArray<id<SJPlaybackItem>> *_items;
    dispatch_semaphore_t _semaphore;
    SJPlaybackModeMask _supportedModes;
    SJPlaybackMode _mode;
    NSInteger _curIndex;
}
@property (nonatomic) SJPlaybackMode mode;
@end

@implementation SJPlaybackListController {
    NSHashTable<id<SJPlaybackListControllerObserver>> *_observers;
}

- (instancetype)initWithPlaybackController:(nullable id<SJPlaybackController>)playbackController {
    self = [super init];
    if ( self ) {
        _playbackController = playbackController;
        __weak typeof(self) _self = self;
        _playbackController.playbackCompletionHandler = ^{
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
            [self _playbackDidComplete];
        };
        _items = NSMutableArray.array;
        _supportedModes = SJPlaybackModeMaskAll;
        _curIndex = NSNotFound;
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}
 
- (void)registerObserver:(id<SJPlaybackListControllerObserver>)observer {
    if ( observer != nil ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( self->_observers == nil ) {
                self->_observers = [NSHashTable weakObjectsHashTable];
            }
            [self->_observers addObject:observer];
        });
    }
}

- (void)removeObserver:(id<SJPlaybackListControllerObserver>)observer {
    if ( observer != nil ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_observers removeObject:observer];
        });
    }
}

- (NSInteger)numberOfItems {
    __block NSInteger count = 0;
    [self _lockInBlock:^{
        count = _items.count;
    }];
    return count;
}

- (nullable id<SJPlaybackItem>)itemAtIndex:(NSInteger)index {
    __block id item = nil;
    [self _lockInBlock:^{
        item = [self _itemAtIndex:index];
    }];
    return item;
}

- (NSInteger)indexOfItem:(id<SJPlaybackItem>)item {
    __block NSInteger idx = NSNotFound;
    if ( item != nil ) {
        [self _lockInBlock:^{
            idx = [_items indexOfObject:item];
        }];
    }
    return idx;
}

- (NSInteger)indexOfItemForKey:(id)itemKey {
    __block NSInteger idx = NSNotFound;
    if ( itemKey != nil ) {
        [self _lockInBlock:^{
            idx = [_items _indexOfItemForItemKey:itemKey];
        }];
    }
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
        [self _lockInBlock:^{
            for ( id<SJPlaybackItem> item in items ) {
                [self _addItem:item];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _enumerateObserversUsingBlock:^(id<SJPlaybackListControllerObserver> observer, NSInteger index, BOOL *stop) {
                    if ( [observer respondsToSelector:@selector(itemListDidChangeForPlaybackListController:)] ) {
                        [observer itemListDidChangeForPlaybackListController:self];
                    }
                }];
            });
        }];
    }
}

/// 添加到下一个播放
///
- (void)insertItemToNextPlay:(id<SJPlaybackItem>)item {
    if ( item == nil || item.itemKey == nil )
        return;
    
    [self _lockInBlock:^{
        id itemKey = item.itemKey;
        id curItemKey = [self _itemAtIndex:_curIndex].itemKey;
        if ( [itemKey isEqual:curItemKey] )
            return;
        
        if ( _items.count == 0 ) {
            [_items addObject:item];
            _curIndex = 0;
        }
        else {
            NSInteger index = [_items _indexOfItemForItemKey:itemKey];
            if ( index != NSNotFound ) {
                [_items removeObjectAtIndex:index];
                if ( index < _curIndex )
                    _curIndex -= 1;
            }
            [_items insertObject:item atIndex:_curIndex + 1];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _enumerateObserversUsingBlock:^(id<SJPlaybackListControllerObserver> observer, NSInteger index, BOOL *stop) {
                if ( [observer respondsToSelector:@selector(itemListDidChangeForPlaybackListController:)] ) {
                    [observer itemListDidChangeForPlaybackListController:self];
                }
            }];
        });
    }];
}

/// 替换列表
///
- (void)replaceItemsFromArray:(NSArray *)items {
    if ( items.count == 0 ) {
        [self removeAllItems];
        return;
    }
    
    [self _lockInBlock:^{
        NSMutableArray<id<SJPlaybackItem>> *m = [NSMutableArray arrayWithCapacity:items.count];
        for ( id<SJPlaybackItem> a in items ) {
            BOOL isExists = NO;
            for ( id<SJPlaybackItem> b in m ) {
                isExists = [a.itemKey isEqual:b.itemKey];
                if ( isExists )
                    break;
            }
            if ( isExists ) continue;
            [m addObject:a];
        }
        
        id curItemKey = [self _itemAtIndex:_curIndex].itemKey;
        [_items removeAllObjects];
        [_items addObjectsFromArray:m];
        
        NSInteger newIndex = [_items _indexOfItemForItemKey:curItemKey];
        _curIndex = newIndex;
        if ( newIndex == NSNotFound && _items.count != 0 ) {
            _curIndex = 0;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL needsStop = newIndex == NSNotFound;
            if ( needsStop )
                [self.playbackController stop];
            [self _enumerateObserversUsingBlock:^(id<SJPlaybackListControllerObserver> observer, NSInteger index, BOOL *stop) {
                if ( [observer respondsToSelector:@selector(itemListDidChangeForPlaybackListController:)] ) {
                    [observer itemListDidChangeForPlaybackListController:self];
                }
            }];
        });
    }];
}

- (void)removeAllItems {
    [self _lockInBlock:^{
        if ( _items.count != 0 ) {
            [_items removeAllObjects];
            _curIndex = NSNotFound;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playbackController stop];
                [self _enumerateObserversUsingBlock:^(id<SJPlaybackListControllerObserver> observer, NSInteger index, BOOL *stop) {
                    if ( [observer respondsToSelector:@selector(itemListDidChangeForPlaybackListController:)] ) {
                        [observer itemListDidChangeForPlaybackListController:self];
                    }
                }];
            });
        }
    }];
}
- (void)removeItemAtIndex:(NSInteger)index {
    [self _lockInBlock:^{
        if ( [self _isSafeIndexForGetting:index] ) {
            BOOL isCurItem = _curIndex == index;
            [_items removeObjectAtIndex:index];
             
            BOOL needsStop = NO;
            if ( _items.count == 0 ) {
                _curIndex = NSNotFound;
                needsStop = YES;
            }
            // 当前item被移除
            // - 确定是否需要播放下一个
            else if ( isCurItem ) {
                // 删除当前正在播放的item时, 如果播放控制正在处于播放中, 则切换下一个项目进行播放
                // 删除最后一个项目时, 重置索引为0
                if ( index == _items.count )
                    _curIndex = 0;
                _playbackController.isPaused ? (needsStop = YES) : [self _playItemAtIndex:_curIndex];
            }
            else if ( index < _curIndex ) {
                _curIndex -= 1;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( needsStop )
                    [self.playbackController stop];
                [self _enumerateObserversUsingBlock:^(id<SJPlaybackListControllerObserver> observer, NSInteger index, BOOL *stop) {
                    if ( [observer respondsToSelector:@selector(itemListDidChangeForPlaybackListController:)] ) {
                        [observer itemListDidChangeForPlaybackListController:self];
                    }
                }];
            });
        }
    }];
}

- (void)enumerateItemsUsingBlock:(void(NS_NOESCAPE ^)(id<SJPlaybackItem> item, NSInteger index, BOOL *stop))block {
    __block NSArray *items = nil;
    [self _lockInBlock:^{
        items = _items.copy;
    }];
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj, idx, stop);
    }];
}

- (SJPlaybackMode)mode {
    __block SJPlaybackMode mode = 0;
    [self _lockInBlock:^{
        mode = _mode;
    }];
    return mode;
}

- (void)setSupportedModes:(SJPlaybackModeMask)supportedModes {
    NSParameterAssert(supportedModes != 0);
    NSParameterAssert(supportedModes <= SJPlaybackModeMaskAll);
    [self _lockInBlock:^{
        _supportedModes = supportedModes;
    }];
}

- (SJPlaybackModeMask)supportedModes {
    __block SJPlaybackModeMask supportedModes = 0;
    [self _lockInBlock:^{
        supportedModes = _supportedModes;
    }];
    return supportedModes;
}

- (void)switchToMode:(SJPlaybackMode)mode {
    [self _lockInBlock:^{
        if ( [self _isModeSupported:mode] ) {
            [self _switchToMode:mode];
        }
    }];
}

- (void)switchMode {
    [self _lockInBlock:^{
        SJPlaybackMode mode = _mode;
        if ( _supportedModes == (1 << mode) ) return;
        
        do {
            mode = (mode + 1) % 3;
        } while ( ![self _isModeSupported:mode] );
        [self _switchToMode:mode];
    }];
}


- (void)playItemAtIndex:(NSInteger)index {
    [self _lockInBlock:^{
        [self _playItemAtIndex:index];
    }];
}

- (void)playCurrentItem {
    [self _lockInBlock:^{
        [self _playItemAtIndex:_curIndex];
    }];
}

- (void)playNextItem {
    [self _lockInBlock:^{
        [self _playNextItem];
    }];
}

- (void)playPreviousItem {
    [self _lockInBlock:^{
        NSInteger count = _items.count;
        
       if ( count == 0 )
           return;
        
        if ( count == 1 ) {
            id<SJPlaybackItem> item = [self _itemAtIndex:0];
            [_playbackController.curItem.itemKey isEqual:item.itemKey] ? [self _replay] : [self _playItemAtIndex:0];
            return;
        }
        
        if ( _mode == SJPlaybackModeShuffle ) {
            [self _shufflePlay];
            return;
        }
         
        NSInteger previousIdx = _curIndex - 1;
        if ( previousIdx == -1 ) {
            previousIdx = count - 1;
        }
        [self _playItemAtIndex:previousIdx];
    }];
}

#pragma mark -

- (void)_lockInBlock:(void(NS_NOESCAPE ^)(void))block {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    block();
    dispatch_semaphore_signal(_semaphore);
}

- (BOOL)_isSafeIndexForGetting:(NSInteger)index {
    return index >= 0 && index < _items.count;
}

- (BOOL)_isSafeIndexForInserting:(NSInteger)index {
    return index >= 0 && index <= _items.count;
}

- (BOOL)_isModeSupported:(SJPlaybackMode)mode {
    return (1 << mode) & _supportedModes;
}

- (void)_enumerateObserversUsingBlock:(void(NS_NOESCAPE ^)(id<SJPlaybackListControllerObserver> observer, NSInteger index, BOOL *stop))block {
    if ( _observers.count != 0 ) {
        [NSAllHashTableObjects(_observers) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            block(obj, idx, stop);
        }];
    }
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

- (void)_shufflePlay {
    if ( _items.count == 1 ) {
        [self _playItemAtIndex:0];
        return;
    }
    
    NSInteger nextIdx = 0;
    do {
        nextIdx = arc4random() % _items.count;
    } while ( nextIdx == _curIndex);
    [self _playItemAtIndex:nextIdx];
}

- (void)_playItemAtIndex:(NSInteger)index {
    id item = [self _isSafeIndexForGetting:index] ? [_items objectAtIndex:index] : nil;
    if ( item == nil ) return;
    _curIndex = index;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( index != self.curIndex )
            return;
        [self.playbackController playWithItem:item];
        [self _enumerateObserversUsingBlock:^(id<SJPlaybackListControllerObserver> observer, NSInteger index, BOOL *stop) {
            if ( [observer respondsToSelector:@selector(playbackListController:didPlayItem:)] ) {
                [observer playbackListController:self didPlayItem:item];
            }
        }];
    });
}

- (void)_replay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.playbackController replay];
    });
}

- (void)_playNextItem {
    NSInteger count = _items.count;
    
   if ( count == 0 )
       return;
    
    if ( _items.count == 1 ) {
        id<SJPlaybackItem> item = [self _itemAtIndex:0];
        [_playbackController.curItem.itemKey isEqual:item.itemKey] ? [self _replay] : [self _playItemAtIndex:0];
        return;
    }
    
    if ( _mode == SJPlaybackModeShuffle ) {
        [self _shufflePlay];
        return;
    }
    
    NSInteger nextIdx = _curIndex + 1;
    if ( nextIdx == count ) {
        nextIdx = 0;
    }
    [self _playItemAtIndex:nextIdx];
}

- (nullable id<SJPlaybackItem>)_itemAtIndex:(NSInteger)index {
    return [self _isSafeIndexForGetting:index] ? [_items objectAtIndex:index] : nil;
}

- (void)_addItem:(id<SJPlaybackItem>)item {
    id itemKey = item.itemKey;
    if ( itemKey == nil ) return;
    id curItemKey = [self _itemAtIndex:_curIndex].itemKey;
    if ( [itemKey isEqual:curItemKey] ) return;
    NSInteger index = [_items _indexOfItemForItemKey:itemKey];
    if ( index != NSNotFound ) {
        [_items removeObjectAtIndex:index];
        if ( index < _curIndex )
            _curIndex -= 1;
    }
    [_items addObject:item];

    if ( _curIndex == NSNotFound )
        _curIndex = 0;
}

- (void)_playbackDidComplete {
    [self _lockInBlock:^{
        if ( _items.count == 0 )
            return;
        
        if ( _mode == SJPlaybackModeRepeatOne ) {
            [self _replay];
            return;
        }
        
        [self _playNextItem];
    }];
}

@end
