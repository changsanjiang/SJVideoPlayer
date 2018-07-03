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
@interface SJObserverHelper: NSObject
@property (nonatomic, readonly) const char *key; // lazy load
@property (nonatomic, unsafe_unretained) id target;
@property (nonatomic, unsafe_unretained) id observer;
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, weak) SJObserverHelper *factor;
@end

@implementation SJObserverHelper {
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
    _key = malloc(keyStr.length * sizeof(char) + 1);
    strcpy(_key, keyStr.UTF8String);
    return _key;
}
- (void)dealloc {
    if ( _key ) free(_key);
    if ( _factor ) {
        [_target removeObserver:_observer forKeyPath:_keyPath];
    }
}
@end

@implementation NSObject (ObserverHelper)

- (void)sj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    [self sj_addObserver:observer forKeyPath:keyPath context:NULL];
}

- (void)sj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context {
    NSParameterAssert(observer);
    NSParameterAssert(keyPath);
    
    if ( !observer || !keyPath ) return;
    
    NSString *hashstr = [NSString stringWithFormat:@"%lu-%@", (unsigned long)[observer hash], keyPath];
    
    if ( [[self sj_observerhashSet] containsObject:hashstr] ) return;
    else [[self sj_observerhashSet] addObject:hashstr];
    
    [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:context];
    
    SJObserverHelper *helper = [SJObserverHelper new];
    SJObserverHelper *sub = [SJObserverHelper new];
    
    sub.target = helper.target = self;
    sub.observer = helper.observer = observer;
    sub.keyPath = helper.keyPath = keyPath;
    
    helper.factor = sub;
    sub.factor = helper;
    
    objc_setAssociatedObject(self, helper.key, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(observer, helper.key, sub, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableSet<NSString *> *)sj_observerhashSet {
    NSMutableSet<NSString *> *set = objc_getAssociatedObject(self, _cmd);
    if ( set ) return set;
    set = [NSMutableSet set];
    objc_setAssociatedObject(self, _cmd, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return set;
}
@end
NS_ASSUME_NONNULL_END
