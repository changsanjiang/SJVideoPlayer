//
//  SJTaskQueue.m
//  Pods
//
//  Created by BlueDancer on 2019/2/28.
//

#import "SJTaskQueue.h"
#import <stdlib.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJTaskQueues : NSObject
- (void)addQueue:(SJTaskQueue *)q;
- (void)removeQueue:(NSString *)name;
- (nullable SJTaskQueue *)getQueue:(NSString *)name;
@end

@implementation SJTaskQueues {
    NSMutableDictionary *_m;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _m = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addQueue:(SJTaskQueue *)q {
    if ( !q ) return;
    [_m setValue:q forKey:q.name];
}

- (void)removeQueue:(NSString *)name {
    [_m removeObjectForKey:name];
}
- (nullable SJTaskQueue *)getQueue:(NSString *)name {
    SJTaskQueue *_Nullable q = _m[name];
    return q;
}
@end

#pragma mark -
typedef struct SJTaskItem {
    struct SJTaskItem *_Nullable next;
    CFTypeRef _Nullable task;
} SJTaskItem;

static inline SJTaskItem *
_SJTaskItemCreate(SJTaskHandler task) {
    SJTaskItem *new_item = malloc(sizeof(SJTaskItem));
    new_item->next = NULL;
    new_item->task = CFBridgingRetain(task);
    return new_item;
}

static inline void
_SJTaskItemFree(SJTaskItem *item) {
    if ( item->task != NULL ) {
        CFRelease(item->task);
        item->task = NULL;
    }
    free(item);
}

@interface SJTaskQueue ()
@property (nonatomic, nullable) SJTaskItem *head;
@property (nonatomic, nullable) SJTaskItem *tail;
@property (nonatomic) NSTimeInterval delaySecs;
@property BOOL isDelaying;
@end

@implementation SJTaskQueue
static SJTaskQueues *_queues;

+ (SJTaskQueue * _Nonnull (^)(NSString * _Nonnull))queue {
    return ^SJTaskQueue *(NSString *name) {
        NSParameterAssert(name);
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _queues = [SJTaskQueues new];
        });
        SJTaskQueue *_Nullable q = [_queues getQueue:name];
        if ( !q ) {
            q = [[SJTaskQueue alloc] initWithName:name];
            [_queues addQueue:q];
        }
        return q;
    };
}

+ (SJTaskQueue *)main {
    static NSString *const kSJTaskMainQueue = @"com.SJTaskQueue.main";
    return self.queue(kSJTaskMainQueue);
}

/// 销毁某个队列
+ (void (^)(NSString * _Nonnull))destroy {
    return ^(NSString *name) {
        if ( name.length < 1 )
            return ;
        SJTaskQueue *_Nullable q = [_queues getQueue:name];
        if ( q ) q.destroy();
    };
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif
    if ( _head != nil ) [self _empty];
}

#pragma mark -

- (SJTaskQueue * _Nullable (^)(SJTaskHandler _Nonnull))enqueue {
    return ^SJTaskQueue *(SJTaskHandler task) {
        SJTaskItem *new_item = _SJTaskItemCreate(task);
        [self _enqueue:new_item];
        [self _performNextTaskIfNeeded];
        return self;
    };
}

- (SJTaskQueue * _Nullable (^)(void))dequeue {
    return ^SJTaskQueue *(void) {
        [self _dequeue:@(NO)];
        return self;
    };
}

- (SJTaskQueue * _Nullable (^)(NSTimeInterval secs))delay {
    return ^SJTaskQueue *(NSTimeInterval secs) {
        self.delaySecs = secs;
        return self;
    };
}

- (SJTaskQueue * _Nullable (^)(void))empty {
    return ^SJTaskQueue *(void) {
        if ( self->_head != nil ) [self _empty];
        return self;
    };
}

- (void (^)(void))destroy {
    return ^ {
        if ( self->_head != nil ) [self _empty];
        [_queues removeQueue:self->_name];
    };
}

#pragma mark -
- (void)_performNextTaskIfNeeded {
    if ( _isDelaying || !_head )
        return;
    
    _isDelaying = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_dequeue:) object:nil];
    [self performSelector:@selector(_dequeue:) withObject:@(YES) afterDelay:_delaySecs];
}

- (void)_dequeue:(NSNumber *)needPerformTask {
    if ( _head != nil ) {
        SJTaskItem *item = _head;
        _head = item->next;
        if ( !_head ) {
            _tail = NULL;
        }
        
        BOOL exe = [needPerformTask boolValue];
        if ( exe ) {
            SJTaskHandler block = (__bridge SJTaskHandler)item->task;
            !block?:block();
        }
        
        _SJTaskItemFree(item);
        
        if ( exe ) {
            _isDelaying = NO;
            [self _performNextTaskIfNeeded];
        }
    }
}

- (void)_enqueue:(SJTaskItem *)new_item {
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
        [self _dequeue:@(NO)];
    }

    if ( _isDelaying ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_dequeue:) object:nil];
        _isDelaying = NO;
    }
}

- (NSInteger)count {
    NSInteger count = 0;
    SJTaskItem *_Nullable next = _head;
    while ( next != nil ) {
        count += 1;
        next = next->next;
    }
    return count;
}
@end
NS_ASSUME_NONNULL_END
