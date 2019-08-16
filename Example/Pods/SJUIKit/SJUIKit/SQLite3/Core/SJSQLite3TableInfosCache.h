//
//  SJSQLite3TableInfosCache.h
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//

#import <Foundation/Foundation.h>
@class SJSQLiteTableInfo;

NS_ASSUME_NONNULL_BEGIN

/// 存储 表信息
///
@interface SJSQLite3TableInfosCache : NSObject
+ (instancetype)shared;
- (nullable SJSQLiteTableInfo *)getTableInfoForClass:(Class)cls;
@end

NS_ASSUME_NONNULL_END
