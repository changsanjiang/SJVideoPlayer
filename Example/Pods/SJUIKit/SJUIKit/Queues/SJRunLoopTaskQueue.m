//
//  SJRunLoopTaskQueue.m
//  SJUIKit
//
//  Created by changsanjiang@gmail.com on 07/17/2018.
//  Copyright (c) 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "SJRunLoopTaskQueue.h"
#import <stdlib.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJRunLoopTaskQueues : NSObject
- (void)addQueue:(SJRunLoopTaskQueue *)q;
- (void)removeQueue:(NSString *)name;
- (nullable SJRunLoopTaskQueue *)getQueue:(NSString *)name;
@end

@implementation SJRunLoopTaskQueues {
    NSMutableDictionary *_m;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _m = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addQueue:(SJRunLoopTaskQueue *)q {
    if ( !q ) return;
    [_m setValue:q forKey:q.name];
}

- (void)removeQueue:(NSString *)name {
    [_m removeObjectForKey:name];
}
- (nullable SJRunLoopTaskQueue *)getQueue:(NSString *)name {
    SJRunLoopTaskQueue *_Nullable q = _m[name];
    return q;
}
@end

#pragma mark -

typedef struct {
    CFRunLoopRef rlr;
    CFRunLoopMode mode;
    CFRunLoopObserverRef _Nullable obr;
} SJRunLoopObserverRef;

typedef struct SJRunLoopTaskItem {
    struct SJRunLoopTaskItem *_Nullable next;
    CFTypeRef _Nullable task;
} SJRunLoopTaskItem;

static inline SJRunLoopTaskItem *
_SJRunLoopTaskItemCreate(SJRunLoopTaskHandler task) {
    SJRunLoopTaskItem *new_item = malloc(sizeof(SJRunLoopTaskItem));
    new_item->next = NULL;
    new_item->task = CFBridgingRetain(task);
    return new_item;
}

static inline void
_SJRunLoopTaskItemFree(SJRunLoopTaskItem *item) {
    if ( item->task != NULL ) {
        CFRelease(item->task);
        item->task = NULL;
    }
    free(item);
}

static NSString *const kSJRunLoopTaskMainQueue = @"com.SJRunLoopTaskQueue.main";

@interface SJRunLoopTaskQueue ()
@property (nonatomic, readonly) SJRunLoopObserverRef observerRef;
@property (nonatomic, nullable) SJRunLoopTaskItem *head;
@property (nonatomic, nullable) SJRunLoopTaskItem *tail;
@property (nonatomic) NSUInteger delayNum;
@property (nonatomic) NSUInteger countDown;
@property (nonatomic, weak, readonly) NSThread *onThread;
@end

@implementation SJRunLoopTaskQueue
static SJRunLoopTaskQueues *_queues;
/// 在当前的RunLoop中创建一个任务队列
///
/// - 请使用唯一的队列名称, 同名的队列将会被移除
/// - 调用destroy后, 该队列将会被移除
+ (SJRunLoopTaskQueue * _Nonnull (^)(NSString * _Nonnull))queue {
    return ^SJRunLoopTaskQueue *(NSString *name) {
        NSParameterAssert(name);
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _queues = [SJRunLoopTaskQueues new];
        });
        SJRunLoopTaskQueue *_Nullable q = [_queues getQueue:name];
        if ( !q ) {
            if ( name != kSJRunLoopTaskMainQueue ) {
                q = [[SJRunLoopTaskQueue alloc] initWithName:name runLoop:CFRunLoopGetCurrent() mode:kCFRunLoopCommonModes];
            }
            else {
                q = [[SJRunLoopTaskQueue alloc] initWithName:name runLoop:CFRunLoopGetMain() mode:kCFRunLoopCommonModes];
            }
            [_queues addQueue:q];
        }
        return q;
    };
}

/// 在mainRunLoop中创建的任务队列
///
/// - 调用destroy后, 再次获取该队列将会重新创建
+ (SJRunLoopTaskQueue *)main {
    return self.queue(kSJRunLoopTaskMainQueue);
}

/// 销毁某个队列
+ (void (^)(NSString * _Nonnull))destroy {
    return ^(NSString *name) {
        if ( name.length < 1 )
            return ;
        SJRunLoopTaskQueue *_Nullable q = [_queues getQueue:name];
        if ( q ) q.destroy();
    };
}

- (instancetype)initWithName:(NSString *)name runLoop:(CFRunLoopRef)runLoop mode:(CFRunLoopMode)mode {
    self = [super init];
    if (self) {
        _name = name;
        _observerRef = (SJRunLoopObserverRef){runLoop, mode, NULL};
        _onThread = (runLoop == CFRunLoopGetMain())?NSThread.mainThread:NSThread.currentThread;
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif
    if ( _head != nil ) [self _empty];
    [self _removeRunLoopObserver];
}

#pragma mark -

- (SJRunLoopTaskQueue * _Nullable (^)(CFRunLoopRef _Nonnull, CFRunLoopMode _Nonnull))update {
    return ^SJRunLoopTaskQueue *(CFRunLoopRef rlr, CFRunLoopMode mode) {
        [self _updateObserverRunLoop:rlr mode:mode];
        return self;
    };
}

- (SJRunLoopTaskQueue * _Nullable (^)(SJRunLoopTaskHandler _Nonnull))enqueue {
    return ^SJRunLoopTaskQueue *(SJRunLoopTaskHandler task) {
        SJRunLoopTaskItem *new_item = _SJRunLoopTaskItemCreate(task);
        [self _enqueue:new_item];
        [self _addRunLoopObserverIfNeeded];
        return self;
    };
}

- (SJRunLoopTaskQueue * _Nullable (^)(void))dequeue {
    return ^SJRunLoopTaskQueue *(void) {
        [self _dequeue:NO];
        return self;
    };
}

- (SJRunLoopTaskQueue * _Nullable (^)(NSUInteger))delay {
    return ^SJRunLoopTaskQueue *(NSUInteger num) {
        self.delayNum = num;
        return self;
    };
}

- (SJRunLoopTaskQueue * _Nullable (^)(void))empty {
    return ^SJRunLoopTaskQueue *(void) {
        [self _empty];
        return self;
    };
}

- (void (^)(void))destroy {
    return ^ {
        [self _empty];
        [self _removeRunLoopObserver];
        [_queues removeQueue:self.name];
    };
}

#pragma mark -
- (void)_performTask:(SJRunLoopTaskHandler)task {
    !task?:task();
}

- (void)_addRunLoopObserverIfNeeded {
    if ( !_observerRef.obr && _head != nil ) {
        __weak typeof(self) _self = self;
        CFRunLoopObserverRef obr = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopBeforeWaiting, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( !self.head )
                return;
            
            if ( self.countDown > 0 ) {
                --self.countDown;
            }
            else {
                [self _dequeue:YES];
                self.countDown = self.delayNum;
            }
        });
        CFRunLoopAddObserver(_observerRef.rlr, obr, _observerRef.mode);
        CFRelease(obr);
        _observerRef.obr = obr;
    }
}

- (void)_removeRunLoopObserver {
    if ( _observerRef.obr != NULL ) {
        CFRunLoopRemoveObserver(_observerRef.rlr, _observerRef.obr, _observerRef.mode);
        _observerRef.obr = NULL;
    }
}

- (void)_updateObserverRunLoop:(CFRunLoopRef)rlr mode:(CFRunLoopMode)mode {
    if ( _observerRef.rlr != rlr || _observerRef.mode != mode ) {
        _observerRef.rlr = rlr;
        _observerRef.mode = mode;
        
        if ( _observerRef.obr != nil ) {
            [self _removeRunLoopObserver];
            [self _addRunLoopObserverIfNeeded];
        }
    }
}

- (void)_dequeue:(BOOL)needPerformTask {
    if ( _head != nil ) {
        SJRunLoopTaskItem *item = _head;
        _head = item->next;
        if ( !_head ) {
            _tail = NULL;
        }
        
        if ( needPerformTask ) {
            [self performSelector:@selector(_performTask:)
                         onThread:_onThread
                       withObject:(__bridge id _Nullable)(item->task)
                    waitUntilDone:NO
                            modes:@[(__bridge NSString *)(_observerRef.mode)]];
        }
        _SJRunLoopTaskItemFree(item);
    }
}

- (void)_enqueue:(SJRunLoopTaskItem *)new_item {
    if (__builtin_expect(!_head, 0) ) {
        _head = new_item;
    }
    else {
        _tail->next = new_item;
    }
    _tail = new_item;
}

- (void)_empty {
    while ( _head != nil ) {
        [self _dequeue:NO];
    }
}

- (NSInteger)count {
    NSInteger count = 0;
    SJRunLoopTaskItem *_Nullable  next = _head;
    while ( next != nil ) {
        count += 1;
        next = next ->next;
    }
    return count;
}
@end
NS_ASSUME_NONNULL_END
