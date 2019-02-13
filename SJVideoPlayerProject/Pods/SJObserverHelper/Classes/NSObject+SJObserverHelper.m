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
@interface __SJKVOAutoremove: NSObject
@property (nonatomic, readonly) const char *key;        // lazy load
@property (nonatomic, unsafe_unretained) id target;
@property (nonatomic, unsafe_unretained) id observer;
@property (nonatomic, weak, nullable) __SJKVOAutoremove *factor;
@property (nonatomic, strong) NSString *keyPath;
@end

@implementation __SJKVOAutoremove {
    char *_key;
}
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _key = NULL;
    return self;
}
- (const char *)key {
    if ( _key ) return _key;
    NSString *keyStr = [NSString stringWithFormat:@"sanjiang:%lu", (unsigned long)[self hash]];
    _key = malloc((keyStr.length + 1) * sizeof(char));
    strcpy(_key, keyStr.UTF8String);
    return _key;
}
- (void)dealloc {
    if ( _key ) free(_key);
    if ( _factor ) {
        [_target removeObserver:_observer forKeyPath:_keyPath];
        _factor = nil;
    }
}
@end

@implementation NSObject (ObserverHelper)

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
    
    if ( [[self sj_observerhashSet] containsObject:hashstr] ) return;
    else [[self sj_observerhashSet] addObject:hashstr];
    
    [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:context];
    
    __SJKVOAutoremove *helper = [__SJKVOAutoremove new];
    __SJKVOAutoremove *sub = [__SJKVOAutoremove new];
    
    sub.target = helper.target = self;
    sub.observer = helper.observer = observer;
    sub.keyPath = helper.keyPath = keyPath;
    
    helper.factor = sub;
    sub.factor = helper;
    
    objc_setAssociatedObject(self, helper.key, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(observer, sub.key, sub, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

@interface __SJNotificationAutoremove : NSObject
- (instancetype)initWithToken:(id)token;
@property (nonatomic, readonly) const char *key;        // lazy load
@end

@implementation __SJNotificationAutoremove {
    id _token;
    char *_key;
}
- (instancetype)initWithToken:(id)token {
    self = [super init];
    if ( !self ) return nil;
    _token = token;
    return self;
}
- (const char *)key {
    if ( _key ) return _key;
    NSString *keyStr = [NSString stringWithFormat:@"sanjiang:%lu", (unsigned long)[self hash]];
    _key = malloc((keyStr.length + 1) * sizeof(char));
    strcpy(_key, keyStr.UTF8String);
    return _key;
}
- (void)dealloc {
    if ( _key ) free(_key);
    if ( _token ) {
        [NSNotificationCenter.defaultCenter removeObserver:_token];
    }
}
@end

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
    
    __SJNotificationAutoremove *helper = [[__SJNotificationAutoremove alloc] initWithToken:token];
    objc_setAssociatedObject(self, helper.key, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
NS_ASSUME_NONNULL_END
