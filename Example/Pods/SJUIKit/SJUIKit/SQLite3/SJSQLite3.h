//
//  SJSQLite3.h
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLiteCore.h"
#import "SJSQLiteTableModelProtocol.h"
#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN
/// 数据库模型映射及增删改查
///
/// - 模型类需实现`SJSQLiteTableModelProtocol`
///
/// - 模型中的数据支持的类型包括: 整型, 浮点型, 布尔值, NSString, 单个模型或数组(涉及到的模型类需实现协议)
///
/// - 注意: 除以上类型, 未来不会扩展或支持其他的类型.
///
/// - 更多方法, 请查看分类.
///
@interface SJSQLite3 : NSObject
+ (instancetype)shared;
- (nullable instancetype)initWithDatabasePath:(NSString *)dbPath NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (BOOL)save:(id)object error:(NSError **)error;
- (BOOL)saveObjects:(NSArray *)objsArray error:(NSError **)error;

- (BOOL)update:(id)object forKeys:(NSArray<NSString *> *)properties error:(NSError **)error;
- (BOOL)update:(id)object forKey:(NSString *)property error:(NSError **)error;

- (nullable id)objectForClass:(Class)cls primaryKeyValue:(id)value error:(NSError **)error;

- (void)removeAllObjectsForClass:(Class)cls error:(NSError **)error;
- (void)removeObjectsForClass:(Class)cls primaryKeyValues:(NSArray<id> *)values error:(NSError **)error;
- (void)removeObjectForClass:(Class)cls primaryKeyValue:(id)value error:(NSError **)error;
@end


@interface SJSQLite3 (Core)
typedef NSDictionary SJSQLite3RowData;
- (nullable NSArray<SJSQLite3RowData *> *)exec:(NSString *)sql error:(NSError **)error;
- (nullable NSArray<SJSQLite3RowData *> *)execInTransaction:(NSString *)sql error:(NSError **)error;
- (nullable NSArray *)objectsForClass:(Class)cls rowDatas:(NSArray<SJSQLite3RowData *> *)rowDatas error:(NSError **)error;
@end
NS_ASSUME_NONNULL_END
