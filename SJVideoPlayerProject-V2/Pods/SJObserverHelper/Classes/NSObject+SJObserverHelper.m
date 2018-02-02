//
//  NSObject+SJObserverHelper.m
//  TmpProject
//
//  Created by BlueDancer on 2017/12/8.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "NSObject+SJObserverHelper.h"
#import <objc/message.h>

@interface SJObserverHelper : NSObject
@property (nonatomic, unsafe_unretained) id target;
@property (nonatomic, unsafe_unretained) id observer;
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, weak) SJObserverHelper *factor;
@end

@implementation SJObserverHelper
- (void)dealloc {
    if ( _factor ) {
        [_target removeObserver:_observer forKeyPath:_keyPath];
    }
}
@end

@implementation NSObject (ObserverHelper)

- (void)sj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    
    [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    
    SJObserverHelper *helper = [SJObserverHelper new];
    SJObserverHelper *sub = [SJObserverHelper new];
    
    sub.target = helper.target = self;
    sub.observer = helper.observer = observer;
    sub.keyPath = helper.keyPath = keyPath;
    helper.factor = sub;
    sub.factor = helper;
    
    const char *helpeKey = [[keyPath mutableCopy] UTF8String];
    const char *subKey = [[keyPath mutableCopy] UTF8String];
    objc_setAssociatedObject(self, helpeKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(observer, subKey, sub, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

