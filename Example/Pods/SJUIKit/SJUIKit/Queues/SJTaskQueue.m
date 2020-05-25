//
//  SJTaskQueue.m
//  Pods
//
//  Created by 畅三江 on 2019/2/28.
//

#import "SJTaskQueue.h"
#import "SJQueue.h"
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

@interface SJTaskQueue ()
@property (nonatomic, strong, readonly) SJQueue<SJTaskHandler> *queue;
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
        _queue = SJQueue.queue;
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif
    [_queue empty];
}

#pragma mark -

- (SJTaskQueue * _Nullable (^)(SJTaskHandler _Nonnull))enqueue {
    return ^SJTaskQueue *(SJTaskHandler task) {
        [self.queue enqueue:task];
        [self _performNextTaskIfNeeded];
        return self;
    };
}

- (SJTaskQueue * _Nullable (^)(void))dequeue {
    return ^SJTaskQueue *(void) {
        [self.queue dequeue];
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
        [self _cancelPreviousPerformRequests];
        [self.queue empty];
        return self;
    };
}

- (void (^)(void))destroy {
    return ^ {
        [self _cancelPreviousPerformRequests];
        self.empty();
        [_queues removeQueue:self->_name];
    };
}

- (NSInteger)count {
    return self.queue.size;
}
#pragma mark -
- (void)_performNextTaskIfNeeded {
    if ( _isDelaying || self.queue.size == 0 ) return;
    
    _isDelaying = YES;
    [self performSelector:@selector(_performTask:) withObject:self.queue.dequeue afterDelay:_delaySecs];
}

- (void)_performTask:(SJTaskHandler)task {
    !task?:task();
    _isDelaying = NO;
    [self _performNextTaskIfNeeded];
}

- (void)_cancelPreviousPerformRequests {
    if ( _isDelaying ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_performTask:) object:nil];
        _isDelaying = NO;
    }
}
@end
NS_ASSUME_NONNULL_END
