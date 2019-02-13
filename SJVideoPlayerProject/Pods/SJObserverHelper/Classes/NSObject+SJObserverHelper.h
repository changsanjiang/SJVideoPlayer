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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// KVO
@interface NSObject (SJObserverHelper)
/// Add an observer, you don't need to remove observer (autoremove)
/// 添加观察者, 无需移除 (将会自动移除)
- (void)sj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

/// Add an observer, you don't need to remove observer (autoremove)
/// 添加观察者, 无需移除 (将会自动移除)
- (void)sj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context;

/// Add an observer, you don't need to remove observer (autoremove)
/// 添加观察者, 无需移除 (将会自动移除)
- (void)sj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;
@end

/// Notification
@interface NSObject (SJNotificationHelper)
/// Autoremove
- (void)sj_observeWithNotification:(NSNotificationName)notification target:(id _Nullable)target usingBlock:(void(^)(id self, NSNotification *note))block;

/// Autoremove
- (void)sj_observeWithNotification:(NSNotificationName)notification target:(id _Nullable)target queue:(NSOperationQueue *_Nullable)queue usingBlock:(void(^)(id self, NSNotification *note))block;
@end
NS_ASSUME_NONNULL_END
