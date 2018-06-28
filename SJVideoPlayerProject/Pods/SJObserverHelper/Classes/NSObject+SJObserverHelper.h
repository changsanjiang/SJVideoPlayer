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
@interface NSObject (SJObserverHelper)

/// 添加观察者, 无需移除 (将会自动移除)
- (void)sj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

/// 添加观察者, 无需移除 (将会自动移除)
- (void)sj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context;

@end
NS_ASSUME_NONNULL_END
