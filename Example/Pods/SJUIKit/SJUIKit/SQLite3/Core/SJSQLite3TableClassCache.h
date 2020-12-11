//
//  SJSQLite3TableClassCache.h
//  AFNetworking
//
//  Created by 畅三江 on 2019/7/26.
//  Copyright © 2019 SanJiang. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 存储 已创建了表的类
///
@interface SJSQLite3TableClassCache : NSObject
- (BOOL)containsClass:(Class)cls;
- (void)addClass:(Class)cls;
- (void)addClasses:(NSSet<Class> *)set;
- (void)removeClass:(Class)cls;
- (void)removeClasses:(NSSet<Class> *)set;
@end

NS_ASSUME_NONNULL_END
