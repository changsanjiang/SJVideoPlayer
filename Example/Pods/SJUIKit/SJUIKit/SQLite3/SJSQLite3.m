//
//  SJSQLite3.m
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLite3.h"
#import "SJSQLite3+Private.h"
#import "SJSQLite3TableInfoCache.h"
#import "SJSQLiteErrors.h"
#import "SJSQLiteCore.h"
#import "SJSQLite3Condition.h"
#import "SJSQLite3ColumnOrder.h"
#import <objc/message.h>
#import <stdlib.h>
#import <sqlite3.h>

#if __has_include(<YYModel/YYModel.h>)
#import <YYModel/NSObject+YYModel.h>
#elif __has_include(<YYKit/YYKit.h>)
#import <YYKit/YYKit.h>
#endif


NS_ASSUME_NONNULL_BEGIN
#define SJSQLite3_Lock()                        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER)
#define SJSQLite3_Unlock()                      dispatch_semaphore_signal(_lock)

#define SJSQLite3_TANSACTION_BEGIN()            SJSQLite3_Lock(); \
                                                sj_sqlite3_obj_begin_transaction(self.db);

#define SJSQLite3_TANSACTION_ROLLBACK()         sj_sqlite3_obj_rollback(self.db); \
                                                SJSQLite3_Unlock();

#define SJSQLite3_TANSACTION_COMMIT()           sj_sqlite3_obj_commit(self.db);    \
                                                SJSQLite3_Unlock();
 
@interface SJSQLite3 ()
@property (nonatomic, strong, readonly) SJSQLite3TableClassCache *tableClassCache;
@property (nonatomic, strong, readonly) dispatch_semaphore_t lock;
@property (nonatomic, copy, readonly) NSString *dbPath;
@property (nonatomic, readonly) sqlite3 *db;
@end

@implementation SJSQLite3
+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *defaultPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"com.sj.databasesDefaultFolder"];
        defaultPath = [defaultPath stringByAppendingPathComponent:@"sjdb.db"];
        _instance = [[SJSQLite3 alloc] initWithDatabasePath:defaultPath];
    });
    return _instance;
}

- (nullable instancetype)initWithDatabasePath:(NSString *)dbPath {
    sqlite3 *db = NULL;
    if ( sj_sqlite3_obj_open_database(dbPath, &db) == NO )
        return nil;
    
    self = [super init];
    if ( self ) {
        _lock = dispatch_semaphore_create(1);
        _dbPath = dbPath.copy;
        _db = db;
        _tableClassCache = SJSQLite3TableClassCache.alloc.init;
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    sj_sqlite3_obj_close_database(_db);
}

#pragma mark - Common Methods

/// 将对象数据保存到数据库表中(insert or update). 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param object               需要保存的对象. 该对象的Class必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`.
///
/// @param error                执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @return                     操作是否成功.
///
- (BOOL)save:(id)object error:(NSError **)error {
    if ( [object isKindOfClass:NSArray.class] ) {
        return [self saveObjects:object error:error];
    }
    return [self saveObjects:object?@[object]:@[] error:error];
}

/// 将对象数据保存到数据库表中(insert or update). 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param objectArray          需要保存的对象集合. 该集合中的对象的Class必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`.
///
/// @param error                执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @return                     操作是否成功.
///
- (BOOL)saveObjects:(NSArray *)objectArray error:(NSError **)error {
    if ( objectArray.count == 0 ) {
        if ( error != NULL ) *error = sqlite3_error_invalid_parameter();
        return NO;
    }
    
    SJSQLite3_TANSACTION_BEGIN();
    NSError *_Nullable inner_error = [self _insertOrUpdateObjects:objectArray];
    if ( inner_error != nil ) {
        if ( error != NULL ) *error = inner_error;
        SJSQLite3_TANSACTION_ROLLBACK();
        return NO;
    }
    SJSQLite3_TANSACTION_COMMIT();
    return YES;
}

/// 更新数据(update). 请确保数据已存在. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param properties           需要更新的属性集合.
///
/// @param error                执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @return                     操作是否成功.
///
- (BOOL)update:(id)object forKeys:(NSArray<NSString *> *)properties error:(NSError **)error {
    if ( object == nil || properties.count == 0 ) {
        if ( error != NULL ) *error = sqlite3_error_invalid_parameter();
        return NO;
    }
    return [self updateObjects:@[object] forKeys:properties error:error];
}

/// 更新数据(update). 请确保数据已存在. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param property             需要更新的属性.
///
/// @param error                执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @return                     操作是否成功.
///
- (BOOL)update:(id)object forKey:(NSString *)property error:(NSError **)error {
    if ( object == nil || property.length == 0 ) {
        if ( error != NULL ) *error = sqlite3_error_invalid_parameter();
        return NO;
    }
    return [self update:object forKeys:@[property] error:error];
}

/// 更新数据(update). 请确保数据已存在. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param properties           需要更新的属性集合.
///
/// @param error                执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @return                     操作是否成功.
///
- (BOOL)updateObjects:(NSArray *)objectArray forKeys:(NSArray<NSString *> *)properties error:(NSError **)error {
    if ( objectArray.count == 0 || properties.count == 0 ) {
        if ( error != NULL ) *error = sqlite3_error_invalid_parameter();
        return NO;
    }
    
    SJSQLite3_TANSACTION_BEGIN();
    NSError *inner_error = nil;
    for ( id object in objectArray ) {
        SJSQLiteObjectInfo *_Nullable objectInfo = [self objectInfoWithObject:object error:&inner_error];
        if ( inner_error != nil ) break;
        inner_error = [self _update:objectInfo forKeys:properties];
        if ( inner_error != nil ) break;
    }
    
    if ( inner_error != nil ) {
        if ( error != NULL ) *error = inner_error;
        SJSQLite3_TANSACTION_ROLLBACK();
        return NO;
    }
    SJSQLite3_TANSACTION_COMMIT();
    return YES;
}

/// 获取指定的主键值所对应存储的对象.
///
/// @param cls              数据库表所对应的类. (该类必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`)
///
/// @param primaryKeyValue  需要获取的对象的主键值.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句.
///
/// @return 返回指定的主键值所对应存储的对象. 如果不存在, 将返回nil.
///
- (nullable id)objectForClass:(Class)cls primaryKeyValue:(id)primaryKeyValue error:(NSError **)error {
    SJSQLiteTableInfo *_Nullable table = [self tableInfoForClass:cls error:error];
    if ( table == nil ) return nil;
    
    NSError *_Nullable inner_error = nil;
    id _Nullable result = nil;
    SJSQLite3_Lock();
    NSDictionary *_Nullable rowData = sj_sqlite3_obj_get_row_data(self.db, table, primaryKeyValue, &inner_error);
    if ( inner_error == nil ) {
        result = [self _transformRowData:rowData toObjectOfClass:cls error:&inner_error];
    }
    
    if ( inner_error != nil ) {
        if ( error != nil ) *error = inner_error;
        SJSQLite3_Unlock();
        return nil;
    }
    SJSQLite3_Unlock();
    return result;
}

/// 删除某个类对应的表存储的所有数据(删除表). 操作不可逆, 请谨慎操作. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param cls              数据库表所对应的类. (该类必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`)
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
- (void)removeAllObjectsForClass:(Class)cls error:(NSError **)error {
    SJSQLiteTableInfo *_Nullable table = [self tableInfoForClass:cls error:error];
    if ( table == nil ) return;

    SJSQLite3_TANSACTION_BEGIN();
    NSError *inner_error = nil;
    sj_sqlite3_obj_drop_table(self.db, table.name, &inner_error);
    if ( inner_error != nil ) {
        if ( error != nil ) *error = inner_error;
        SJSQLite3_TANSACTION_ROLLBACK();
        return;
    }
    [self.tableClassCache removeClass:cls];
    SJSQLite3_TANSACTION_COMMIT();
}

/// 删除指定的主键值的数据. 操作不可逆, 请谨慎操作. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param cls              数据库表所对应的类. (该类必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`)
///
/// @param value            需要删除的数据的主键值.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
- (void)removeObjectForClass:(Class)cls primaryKeyValue:(id)value error:(NSError **)error {
    [self removeObjectsForClass:cls primaryKeyValues:@[value] error:error];
}

/// 删除指定的主键值的数据. 操作不可逆, 请谨慎操作. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param cls              数据库表所对应的类. (该类必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`)
///
/// @param primaryKeyValues 需要删除的数据的主键值的集合.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
- (void)removeObjectsForClass:(Class)cls primaryKeyValues:(NSArray<id> *)primaryKeyValues error:(NSError **)error {
    SJSQLiteTableInfo *_Nullable table = [self tableInfoForClass:cls error:error];
    if ( table == nil ) return;
    
    SJSQLite3_TANSACTION_BEGIN();
    NSError *inner_error = nil;
    sj_sqlite3_obj_delete_row_datas(self.db, table, primaryKeyValues, error);
    if ( inner_error != nil ) {
        if ( error != nil ) *error = inner_error;
        SJSQLite3_TANSACTION_ROLLBACK();
        return;
    }
    SJSQLite3_TANSACTION_COMMIT();
}

/// 执行自定义的sql(适合执行查询操作). 返回的结果需调用`objectsForClass:rowDatas:error:`来转换为相应的模型数据.
///
/// @param sql              需要执行的sql语句.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句.
///
/// @return sql执行所返回的结果.
///
- (nullable NSArray<SJSQLite3RowData *> *)exec:(NSString *)sql error:(NSError **)error {
    SJSQLite3_Lock();
    id result = sj_sqlite3_obj_exec(self.db, sql, error);;
    SJSQLite3_Unlock();
    return result;
}

/// 执行自定义的sql. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态. (适合执行修改操作)
///
/// @param sql              需要执行的sql语句.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @return sql执行所返回的结果.
///
- (nullable NSArray<SJSQLite3RowData *> *)execInTransaction:(NSString *)sql error:(NSError **)error {
    SJSQLite3_TANSACTION_BEGIN();
    NSError *innser_error = nil;
    id result = sj_sqlite3_obj_exec(self.db, sql, &innser_error);
    if ( innser_error != nil ) {
        if ( error != nil ) *error = innser_error;
        SJSQLite3_TANSACTION_ROLLBACK();
        return nil;
    }
    SJSQLite3_TANSACTION_COMMIT();
    return result;
}

/// 开启一个新的事务, 同步执行block块. 当块执行返回NO时, 数据库将回滚到执行之前的状态.
///
/// @param block              需要执行的块.
///
- (void)execInTransaction:(BOOL (^)(SJSQLite3 * _Nonnull))block {
    if ( block != nil ) {
        SJSQLite3_TANSACTION_BEGIN();
        if ( block(self) ) {
            SJSQLite3_TANSACTION_COMMIT();
        }
        else {
            SJSQLite3_TANSACTION_ROLLBACK();
        }
    }
}

/// 将执行的查询结果转换为对应的类的对象.
///
/// @param cls              数据库表所对应的类. (该类必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`)
///
/// @param rowDatas         该参数为`exec:error:`执行后的返回值.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
- (nullable NSArray *)objectsForClass:(Class)cls rowDatas:(NSArray<SJSQLite3RowData *> *)rowDatas error:(NSError **)error {
    if ( rowDatas.count == 0 ) return nil;
    SJSQLite3_Lock();
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:rowDatas.count];
    NSError *inner_error = nil;
    for ( SJSQLite3RowData * rowData in rowDatas ) {
        id result = [self _transformRowData:rowData toObjectOfClass:cls error:&inner_error];
        if ( inner_error != nil ) break;
        [arr addObject:result];
    }
    
    if ( inner_error != nil ) {
        if ( error != nil ) *error = inner_error;
        SJSQLite3_Unlock();
        return nil;
    }
    SJSQLite3_Unlock();
    return arr;
}

/// 表信息.
///
///         根据该类遵守的`SJSQLiteTableModelProtocol`生成, 并不一定是数据库中对应的表信息
///
/// @param cls             实现了`SJSQLiteTableModelProtocol`的类
///
/// @param error           如果该类未正确实现`SJSQLiteTableModelProtocol`, 将返回错误
///
- (nullable SJSQLiteTableInfo *)tableInfoForClass:(Class)cls error:(NSError *__autoreleasing  _Nullable *)error {
    if ( !cls ) {
        if ( error != NULL ) *error = sqlite3_error_invalid_parameter();
        return nil;
    }
    
    SJSQLiteTableInfo *_Nullable table = [SJSQLite3TableInfoCache.shared getTableInfoForClass:cls];
    if ( table == nil ) {
        if ( error != NULL ) *error = sqlite3_error_get_table_failed(cls);
        return nil;
    }
    return table;
}

/// 对象信息.
///
///         根据该实例的类遵守的`SJSQLiteTableModelProtocol`生成, 并不一定是数据库中对应的表信息
///
/// @param object          实现了`SJSQLiteTableModelProtocol`的类的实例
///
/// @param error           如果该实例的类未正确实现`SJSQLiteTableModelProtocol`, 将返回错误
///
- (nullable SJSQLiteObjectInfo *)objectInfoWithObject:(id)object error:(NSError **)error {
    if ( !object ) {
        if ( error != NULL ) *error = sqlite3_error_invalid_parameter();
        return nil;
    }
    
    SJSQLiteTableInfo *_Nullable table = [self tableInfoForClass:[object class] error:error];
    if ( table == nil ) return nil;
    
    return [SJSQLiteObjectInfo objectInfoWithObject:object tableInfo:table];
}

/// 查询表是否已存在
///
///         只检测参数类, 不处理相关类
///
/// @param cls             数据库表所对应的类. (该类必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`)
///
- (BOOL)containsTableForClass:(Class)cls {
    SJSQLite3_Lock();
    BOOL result = [self _containsTableForClass:cls];
    SJSQLite3_Unlock();
    return result;
}

#pragma mark -

/// 更新. 
///
- (nullable NSError *)_update:(SJSQLiteObjectInfo *)objectInfo forKeys:(NSArray<NSString *> *)properties {
    NSMutableString *sql = NSMutableString.new;
    [sql appendFormat:@"UPDATE %@ SET ", objectInfo.table.name];
    for ( NSString *key in properties ) {
        SJSQLiteColumnInfo *_Nullable column = [objectInfo.table columnInfoForProperty:key];
        if ( column == nil ) {
            return sqlite3_error_get_column_failed(objectInfo.table.cls);
        }
        
        id _Nullable newvalue = [objectInfo.obj valueForKey:key];
        if ( newvalue != nil && column.associatedTableInfo != nil ) {
            return [self _insertOrUpdateObjects:column.isModelArray ? newvalue : @[newvalue]];
        }
        if ( newvalue ) {
            [sql appendFormat:@"'%@' = '%@',", column.name, sj_sqlite3_stmt_get_column_value(column, newvalue)];
        }
        else {
            [sql appendFormat:@"'%@' = NULL,", column.name];
        }
    }
    [sql sjsql_deleteSuffix:@","];
    
    NSString *primaryKey = objectInfo.table.primaryKey;
    id primaryValue = [objectInfo.obj valueForKey:primaryKey];
    [sql appendFormat:@" WHERE %@ = %@;", primaryKey, primaryValue];
    NSError *_Nullable error = nil;
    sj_sqlite3_obj_exec(self.db, sql, &error);
    return error;
}

/// 插入或更新
///
- (nullable NSError *)_insertOrUpdateObjects:(NSArray *)objsArray {
    NSError *_Nullable error = nil;
    for ( id obj in objsArray ) {
        SJSQLiteObjectInfo *_Nullable objectInfo = [self objectInfoWithObject:obj error:&error];
        if ( error != nil ) return error;
        
        for ( Class cls in objectInfo.table.allClasses ) {
            if ( ![self _checkoutAllTablesForClass:cls error:&error] ) return error;
        }
        
        error = [self _insertOrUpdateObject:objectInfo];
    }
    return error;
}

- (nullable NSError *)_insertOrUpdateObject:(SJSQLiteObjectInfo *)objectInfo {
    NSError *error = nil;
    SJSQLiteTableInfo *table = objectInfo.table;
    for ( SJSQLiteColumnInfo *column in table.columns ) {
        if ( column.associatedObjectInfos != nil ) {
            for ( SJSQLiteObjectInfo *info in column.associatedObjectInfos ) {
                error = [self _insertOrUpdateObject:info];
                if ( error != nil ) return error;
            }
        }
    }
    
    if ( objectInfo.autoincrementColumns != nil ) {
        id object = objectInfo.obj;
        // 对于新增数据, 它的自增键在执行到这里之前是不能有值的
        //
        // 执行到这里后, 会进行自增键赋值
        //
        // 此处检测了自增键中的某个字段是否有值, 依据此条件来判断是否是新增的数据
        SJSQLiteColumnInfo *column = objectInfo.autoincrementColumns.firstObject;
        NSString *key = column.name;
        NSInteger value = [[object valueForKey:key] integerValue];
        if ( value == 0 ) {
            NSString *sql = sj_sqlite3_stmt_get_last_row(objectInfo.table);
            __auto_type _Nullable result = [sj_sqlite3_obj_exec(self.db, sql, &error) firstObject];
            if ( error != nil ) return error;
            for ( SJSQLiteColumnInfo *column in objectInfo.autoincrementColumns ) {
                NSString *key = column.name;
                // 自增键进行+1操作
                NSInteger value = [[result valueForKey:key] integerValue] + 1;
                [object setValue:@(value) forKey:key];
            }
        }
    }
    
    NSString *sql = sj_sqlite3_stmt_insert_or_update(objectInfo);
    
    sj_sqlite3_obj_exec(self.db, sql, &error);
    return error;
}

- (nullable id)_transformRowData:(NSDictionary *)rowData toObjectOfClass:(Class)cls error:(NSError **)error {
    if ( rowData == nil || cls == nil ) return nil;
    NSError *inner_error = nil;
    NSMutableDictionary *result = [rowData mutableCopy];
    SJSQLiteTableInfo *_Nullable table = [self tableInfoForClass:cls error:&inner_error];
    if ( inner_error != nil ) goto handle_error;
    
    for ( SJSQLiteColumnInfo *column in table.columns ) {
        if ( column.associatedTableInfo == nil ) continue;
        id _Nullable value = rowData[column.name];
        if ( value == nil ) continue;
        
        SJSQLiteTableInfo *subtable = column.associatedTableInfo;
        if ( column.isModelArray ) {
            __auto_type primaryValues = sj_sqlite3_stmt_get_primary_values_array(value);
            NSMutableArray<id> *subObjArr = NSMutableArray.new;
            BOOL intact = YES;
            for ( NSNumber *num in primaryValues ) {
                NSDictionary *subrow = sj_sqlite3_obj_get_row_data(self.db, subtable, num, &inner_error);
                if ( inner_error != nil ) goto handle_error;
                id _Nullable subobj = [self _transformRowData:subrow toObjectOfClass:subtable.cls error:&inner_error];
                if ( inner_error != nil ) goto handle_error;
                if ( subobj == nil ) { intact = NO; break; }
                [subObjArr addObject:subobj];
            }
            result[column.name] = intact?subObjArr.copy:nil;
        }
        else {
            NSDictionary *subrow = sj_sqlite3_obj_get_row_data(self.db, subtable, value, &inner_error);
            if ( inner_error != nil ) goto handle_error;
            id _Nullable subobj = [self _transformRowData:subrow toObjectOfClass:subtable.cls error:&inner_error];
            if ( inner_error != nil ) goto handle_error;
            result[column.name] = subobj;
        }
    }
    
handle_error:
    if ( inner_error != nil ) {
        if ( error ) *error = inner_error;
        return nil;
    }
    
    id obj = nil;
#if __has_include(<YYModel/YYModel.h>)
    obj = [table.cls yy_modelWithDictionary:result];
#elif __has_include(<YYKit/YYKit.h>)
    obj = [table.cls modelWithDictionary:result];
#endif
    return obj;
}

/// 检出所有相关的表
///
///         相关类对应的表也会被创建或更新, 请在开启事物的情况下调用
///
/// @param cls             实现了`SJSQLiteTableModelProtocol`的类.
///
/// @param error           执行出错.
///
- (BOOL)_checkoutAllTablesForClass:(Class)cls error:(NSError **)error {
    if ( [self.tableClassCache containsClass:cls] ) return YES;
    
    SJSQLiteTableInfo *_Nullable tableInfo = [self tableInfoForClass:cls error:error];
    if ( tableInfo == nil ) return NO;

    NSError *inner_error = nil;
    for ( Class cls in tableInfo.allClasses ) {
        if ( [self.tableClassCache containsClass:cls] ) continue;

        if ( [self _containsTableForClass:cls]) {
            if ( ![self _alterTableIfNeeded:cls error:&inner_error] ) break;
        }
        else {
            if ( ![self _createTableForClass:cls error:&inner_error] ) break;
        }
    }
    
    if ( inner_error != nil ) {
        if ( error != NULL ) *error = inner_error;
        return NO;
    }
    
    [self.tableClassCache addClasses:tableInfo.allClasses];
    
    return YES;
}
  
/// 只处理参数类, 不处理相关类
///
- (BOOL)_createTableForClass:(Class)cls error:(NSError *__autoreleasing  _Nullable *)error {
    SJSQLiteTableInfo *_Nullable table = [self tableInfoForClass:cls error:error];
    if ( table == nil ) return NO;
    NSString *sql = sj_sqlite3_stmt_create_table(table);
    NSError *inner_error = nil;
    sj_sqlite3_obj_exec(self.db, sql, &inner_error);
    if ( error != NULL ) *error = inner_error;
    return inner_error == nil;
}

/// 只处理参数类, 不处理相关类
///
- (BOOL)_alterTableIfNeeded:(Class)cls error:(NSError **)error {
    SJSQLiteTableInfo *_Nullable table = [self tableInfoForClass:cls error:error];
    if ( table == nil ) return NO;
    
    NSString *query = [NSString stringWithFormat:@"SELECT sql FROM sqlite_master WHERE name='%@';", table.name];
    NSString *stosql = [[sj_sqlite3_obj_exec(self.db, query, NULL) firstObject][@"sql"] stringByAppendingString:@";"];
    NSString *cursql = sj_sqlite3_stmt_create_table(table);
    if ( [cursql isEqualToString:stosql] ) {
        return YES;
    }

    NSString *tmpname = [NSString stringWithFormat:@"%@_ME_TMP", table.name];
    NSString *altsql = [NSString stringWithFormat:@"ALTER TABLE '%@' RENAME TO '%@';", table.name, tmpname];
    NSError *_Nullable inner_error = nil;
    sj_sqlite3_obj_exec(self.db, altsql, &inner_error);
    if ( inner_error != nil ) {
        if ( error != NULL ) *error = inner_error;
        return NO;
    }
    
    sj_sqlite3_obj_exec(self.db, cursql, &inner_error);
    if ( inner_error != nil ) {
        if ( error != NULL ) *error = inner_error;
        return NO;
    }
    
    NSString *tmpinfosql = [NSString stringWithFormat:@"PRAGMA table_info('%@');", tmpname];
    NSString *curinfosql = [NSString stringWithFormat:@"PRAGMA table_info('%@');", table.name];
    NSArray<NSDictionary *> *tmpInfo = sj_sqlite3_obj_exec(self.db, tmpinfosql, &inner_error);
        if ( inner_error != nil ) {
        if ( error != NULL ) *error = inner_error;
        return NO;
    }
    
    NSArray<NSDictionary *> *curInfo = sj_sqlite3_obj_exec(self.db, curinfosql, &inner_error);
    if ( inner_error != nil ) {
        if ( error != NULL ) *error = inner_error;
        return NO;
    }

    NSMutableSet<NSString *> *tmpFieldsSet = NSMutableSet.new;
    for ( NSDictionary *column in tmpInfo ) {
        [tmpFieldsSet addObject:column[@"name"]];
    }

    NSMutableSet<NSString *> *curFieldsSet = NSMutableSet.new;
    for ( NSDictionary *column in curInfo ) {
        [curFieldsSet addObject:column[@"name"]];
    }

    [tmpFieldsSet intersectSet:curFieldsSet];

    NSMutableString *fields = NSMutableString.new;
    for ( NSString *name in tmpFieldsSet ) {
        [fields appendFormat:@"\"%@\",", name];
    }
    [fields sjsql_deleteSuffix:@","];

    NSString *inssql = [NSString stringWithFormat:@"INSERT INTO '%@' (%@) SELECT %@ FROM '%@';", table.name, fields, fields, tmpname];
    sj_sqlite3_obj_exec(self.db, inssql, &inner_error);
    if ( inner_error != nil ) {
        if ( error != NULL ) *error = inner_error;
        return NO;
    }
    
    sj_sqlite3_obj_drop_table(self.db, tmpname, &inner_error);
    if ( inner_error != nil ) {
        if ( error != NULL ) *error = inner_error;
        return NO;
    }
    
    return YES;
}

/// 查询表是否已存在
///
///         只检测参数类, 不处理相关类
///
/// @param cls             数据库表所对应的类. (该类必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`)
///
- (BOOL)_containsTableForClass:(Class)cls {
    SJSQLiteTableInfo *table = [self tableInfoForClass:cls error:NULL];
    if ( table == nil ) return nil;
    return sj_sqlite3_obj_table_exists(self.db, table.name);
}
@end
NS_ASSUME_NONNULL_END

