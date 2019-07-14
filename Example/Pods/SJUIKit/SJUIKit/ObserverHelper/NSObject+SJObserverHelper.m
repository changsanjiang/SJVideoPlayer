//
//  NSObject+SJObserverHelper.h
//  TmpProject
//
//  Created by 畅三江 on 2017/12/8.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//
//  GitHub:     https://github.com/changsanjiang/SJObserverHelper
//
//  Contact:    changsanjiang@gmail.com
//
//  QQGroup:    719616775
//

#import "NSObject+SJObserverHelper.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@interface __SJKVOAutoremove: NSObject {
@public
    char _key;
}
@property (nonatomic, unsafe_unretained, nullable) id target;
@property (nonatomic, unsafe_unretained, nullable) id observer;
@property (nonatomic, weak, nullable) __SJKVOAutoremove *factor;
@property (nonatomic, copy, nullable) NSString *keyPath;
@end

@implementation __SJKVOAutoremove
- (void)dealloc {
    if ( _factor ) {
        [_target removeObserver:_observer forKeyPath:_keyPath];
        _factor = nil;
    }
}
@end

@implementation NSObject (SJKVOHelper)
- (void)sj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    [self sj_addObserver:observer forKeyPath:keyPath context:NULL];
}

- (void)sj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context {
    [self sj_addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:context];
}

- (void)sj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context {
    NSParameterAssert(observer);
    NSParameterAssert(keyPath);
    
    if ( !observer || !keyPath ) return;
    
    NSString *hashstr = [NSString stringWithFormat:@"%lu-%@", (unsigned long)[observer hash], keyPath];
    
    static dispatch_semaphore_t lock = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    NSMutableSet *set = [self sj_observerhashSet];
    if ( [set containsObject:hashstr] ) {
        dispatch_semaphore_signal(lock);
        return;
    }
    
    [set addObject:hashstr];
    dispatch_semaphore_signal(lock);
    
    [self addObserver:observer forKeyPath:keyPath options:options context:context];
    
    __SJKVOAutoremove *helper = [__SJKVOAutoremove new];
    __SJKVOAutoremove *sub = [__SJKVOAutoremove new];
    
    sub.target = helper.target = self;
    sub.observer = helper.observer = observer;
    sub.keyPath = helper.keyPath = keyPath;
    
    helper.factor = sub;
    sub.factor = helper;
    
    __weak typeof(self) _self = self;
    [observer sj_addDeallocCallbackTask:^(id  _Nonnull obj) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        [set removeObject:hashstr];
        dispatch_semaphore_signal(lock);
    }];
    
    objc_setAssociatedObject(self, &helper->_key, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(observer, &sub->_key, sub, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableSet<NSString *> *)sj_observerhashSet {
    NSMutableSet<NSString *> *set = objc_getAssociatedObject(self, _cmd);
    if ( set ) return set;
    set = [NSMutableSet set];
    objc_setAssociatedObject(self, _cmd, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return set;
}

@end


#pragma mark - Notification
@implementation NSObject (SJNotificationHelper)
- (void)sj_observeWithNotification:(NSNotificationName)notification target:(id _Nullable)target usingBlock:(void(^)(id self, NSNotification *note))block {
    [self sj_observeWithNotification:notification target:target queue:NSOperationQueue.mainQueue usingBlock:block];
}
- (void)sj_observeWithNotification:(NSNotificationName)notification target:(id _Nullable)target queue:(NSOperationQueue *_Nullable)queue usingBlock:(void(^)(id self, NSNotification *note))block {
    __weak typeof(self) _self = self;
    id token = [NSNotificationCenter.defaultCenter addObserverForName:notification object:target queue:queue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self, note);
    }];
    
    [self sj_addDeallocCallbackTask:^(id  _Nonnull obj) {
        [NSNotificationCenter.defaultCenter removeObserver:token];
    }];
}
@end


#pragma mark - SJDeallocCallback
@interface __SJDeallockCallback : NSObject {
@public
    char _key;
}
@property (nonatomic, unsafe_unretained, nullable) id target;
@property (nonatomic, copy, nullable) SJDeallockCallbackTask task;
@end

@implementation __SJDeallockCallback
- (void)dealloc {
    if ( _task ) _task(_target);
}
@end

@implementation NSObject (SJDeallocCallback)
- (void)sj_addDeallocCallbackTask:(SJDeallockCallbackTask)block {
    __SJDeallockCallback *callback = [__SJDeallockCallback new];
    callback.target = self;
    callback.task = block;
    objc_setAssociatedObject(self, &callback->_key, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@interface __SJKVOObserver : NSObject {
@public
    char _key;
}
@property (nonatomic, unsafe_unretained, readonly) id target;
@property (nonatomic, copy, readonly) NSString *keyPath;
@property (nonatomic, readonly) NSKeyValueObservingOptions options;
@property (nonatomic, copy, readonly) SJKVOObservedChangeHandler hanlder;
@end
@implementation __SJKVOObserver
- (instancetype)initWithTarget:(__unsafe_unretained id)target
                    forKeyPath:(NSString *)keyPath
                       options:(NSKeyValueObservingOptions)options
                        change:(SJKVOObservedChangeHandler)hanlder {
    self = [super init];
    if ( !self ) return nil;
    _target = target;
    _keyPath = [keyPath copy];
    _hanlder = hanlder;
    [_target addObserver:self forKeyPath:keyPath options:options context:NULL];
    return self;
}
- (void)dealloc {
    @try {
        [_target removeObserver:self forKeyPath:_keyPath];
    } @catch (NSException *__unused exception) { }
}
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( _hanlder ) _hanlder(object, change);
}
@end

SJKVOObserverToken
sjkvo_observe(id target, NSString *keyPath, SJKVOObservedChangeHandler handler) {
    return sjkvo_observe(target, keyPath, NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld, handler);
}

SJKVOObserverToken __attribute__((overloadable))
sjkvo_observe(id target, NSString *keyPath, NSKeyValueObservingOptions options, SJKVOObservedChangeHandler handler) {
    if ( !target )
        return 0;
    __SJKVOObserver *observer = [[__SJKVOObserver alloc] initWithTarget:target forKeyPath:keyPath options:options change:handler];
    objc_setAssociatedObject(target, &observer->_key, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return (SJKVOObserverToken)&observer->_key;
}

void
sjkvo_remove(id target, SJKVOObserverToken token) {
    objc_setAssociatedObject(target, (void *)token, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
NS_ASSUME_NONNULL_END
