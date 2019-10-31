//
//  SJSQLite3.m
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLite3.h"
#import "SJSQLite3TableInfosCache.h"
#import "SJSQLiteTableInfo.h"
#import "SJSQLiteObjectInfo.h"
#import "SJSQLiteErrors.h"
#import "SJSQLiteCore.h"
#import <objc/message.h>
#import <stdlib.h>

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


/// 存储 已创建了表的类
///
@interface SJSQLite3ClassesCache : NSObject
- (BOOL)containsClass:(Class)cls;
- (void)addClass:(Class)cls;
- (void)addClasses:(NSSet<Class> *)set;
- (void)removeClass:(Class)cls;
- (void)removeClasses:(NSSet<Class> *)set;
@end

@implementation SJSQLite3ClassesCache {
    NSMutableSet *_set;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _set = NSMutableSet.new;
    }
    return self;
}

- (BOOL)containsClass:(Class)cls {
    return [_set containsObject:cls];
}
- (void)addClass:(Class)cls {
    if ( cls ) {
        [_set addObject:cls];
    }
}
- (void)addClasses:(NSSet<Class> *)set {
    if ( set ) {
        [_set unionSet:set];
    }
}
- (void)removeClass:(Class)cls {
    if ( cls ) {
        [_set removeObject:cls];
    }
}
- (void)removeClasses:(NSSet<Class> *)set {
    if ( set ) {
        [_set minusSet:set];
    }
}
@end

@interface SJSQLite3 ()
@property (nonatomic, readonly) sqlite3 *db;
@property (nonatomic, copy, readonly) NSString *dbPath;
@property (nonatomic, strong, readonly) SJSQLite3ClassesCache *classesCache;
@property (nonatomic, strong, readonly) dispatch_semaphore_t lock;
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
        _classesCache = SJSQLite3ClassesCache.alloc.init;
        _dbPath = dbPath.copy;
        _db = db;
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
/// @param objsArray            需要保存的对象集合. 该集合中的对象的Class必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`.
///
/// @param error                执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @return                     操作是否成功.
///
- (BOOL)saveObjects:(NSArray *)objsArray error:(NSError **)error {
    if ( objsArray.count == 0 ) {
        if ( error != NULL ) *error = sqlite3_error_invalid_parameter();
        return NO;
    }
    
    SJSQLite3_TANSACTION_BEGIN();
    NSError *_Nullable inner_error = [self _insertOrUpdateObjects:objsArray];
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
    if ( properties.count == 0 ) {
        if ( error != NULL ) *error = sqlite3_error_invalid_parameter();
        return NO;
    }
    
    SJSQLiteObjectInfo *_Nullable objectInfo = [SJSQLiteObjectInfo objectInfoWithObject:object];
    if ( objectInfo == nil ) {
        if ( error != NULL ) *error = sqlite3_error_get_table_failed([object class]);
        return NO;
    }
    
    SJSQLite3_TANSACTION_BEGIN();
    NSError *inner_error = [self _update:objectInfo forKeys:properties];
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
/// @param property             需要更新的属性.
///
/// @param error                执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @return                     操作是否成功.
///
- (BOOL)update:(id)object forKey:(NSString *)property error:(NSError **)error {
    if ( property.length == 0 ) {
        if ( error != nil ) *error = sqlite3_error_invalid_parameter();
        return NO;
    }
    return [self update:object forKeys:@[property] error:error];
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
    SJSQLiteTableInfo *_Nullable table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    if ( table == nil ) {
        if ( error != nil ) *error = sqlite3_error_get_table_failed(cls);
        return nil;
    }
    
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
    SJSQLiteTableInfo *_Nullable table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    if ( table == nil ) return;

    SJSQLite3_TANSACTION_BEGIN();
    NSError *inner_error = nil;
    sj_sqlite3_obj_drop_table(self.db, table.name, &inner_error);
    if ( inner_error != nil ) {
        if ( error != nil ) *error = inner_error;
        SJSQLite3_TANSACTION_ROLLBACK();
        return;
    }
    [self.classesCache removeClass:cls];
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
    SJSQLiteTableInfo *_Nullable table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
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
- (nullable NSArray<NSDictionary *> *)exec:(NSString *)sql error:(NSError *_Nullable *_Nullable)error {
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

#pragma mark -

/// 只处理参数类, 不处理相关类
///
- (BOOL)_tableExists:(Class)cls {
    SJSQLiteTableInfo *table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    return sj_sqlite3_obj_table_exists(self.db, table.name);
}

/// 只处理参数类, 不处理相关类
///
- (nullable NSError *)_alterTableIfNeeded:(Class)cls {
    SJSQLiteTableInfo *table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    
    NSString *query = [NSString stringWithFormat:@"SELECT sql FROM sqlite_master WHERE name='%@';", table.name];
    NSString *stosql = [[sj_sqlite3_obj_exec(self.db, query, NULL) firstObject][@"sql"] stringByAppendingString:@";"];
    NSString *cursql = sj_sqlite3_stmt_create_table(table);
    if ( [cursql isEqualToString:stosql] ) {
        return nil;
    }
    
    NSString *tmpname = [NSString stringWithFormat:@"%@_ME_TMP", table.name];
    NSString *altsql = [NSString stringWithFormat:@"ALTER TABLE '%@' RENAME TO '%@';", table.name, tmpname];
    NSError *_Nullable error = nil;
    sj_sqlite3_obj_exec(self.db, altsql, &error);
    if ( error != nil ) return error;
    
    sj_sqlite3_obj_exec(self.db, cursql, &error);
    if ( error != nil ) return error;
    
    NSString *tmpinfosql = [NSString stringWithFormat:@"PRAGMA table_info('%@');", tmpname];
    NSString *curinfosql = [NSString stringWithFormat:@"PRAGMA table_info('%@');", table.name];
    NSArray<NSDictionary *> *tmpInfo = sj_sqlite3_obj_exec(self.db, tmpinfosql, &error);
    if ( error != nil ) return error;
    NSArray<NSDictionary *> *curInfo = sj_sqlite3_obj_exec(self.db, curinfosql, &error);
    if ( error != nil ) return error;
    
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
    [fields sjsql_deleteSubffix:@","];
    
    NSString *inssql = [NSString stringWithFormat:@"INSERT INTO '%@' (%@) SELECT %@ FROM '%@';", table.name, fields, fields, tmpname];
    sj_sqlite3_obj_exec(self.db, inssql, &error);
    if ( error != nil ) return error;
    
    sj_sqlite3_obj_drop_table(self.db, tmpname, &error);
    return error;
}

/// 只处理参数类, 不处理相关类
///
- (nullable NSError *)_createTable:(Class)cls {
    SJSQLiteTableInfo *table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    NSString *sql = sj_sqlite3_stmt_create_table(table);
    NSError *error = nil;
    sj_sqlite3_obj_exec(self.db, sql, &error);
    return error;
}

/// 检出参数类相关的表, 相关类对应的表也会被创建或更新
///
- (nullable NSError *)_checkoutTable:(Class)cls {
    if ( [self.classesCache containsClass:cls] )
        return nil;
    
    // 获取表信息
    SJSQLiteTableInfo *_Nullable tableInfo = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    if ( tableInfo == nil ) {
        return sqlite3_error_get_table_failed(cls);
    }
    
    for ( Class cls in tableInfo.allClasses ) {
        // 查询是否已进行过缓存
        if ( ![self.classesCache containsClass:cls] ) {
            // 查询某个表是否已创建
            if ( ![self _tableExists:cls] ) {
                // 创建新表
                NSError *_Nullable error = [self _createTable:cls];
                if ( error != nil ) {
                    return error;
                }
            }
            else {
                // 查询是否需要更新表字段
                NSError *_Nullable error = [self _alterTableIfNeeded:cls];
                if ( error != nil ) {
                    return error;
                }
            }
        }
    }
    
    // 加入到缓存
    [self.classesCache addClasses:tableInfo.allClasses];
    return nil;
}

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
    [sql sjsql_deleteSubffix:@","];
    
    NSString *primaryKey = objectInfo.table.primaryKey;
    id primaryValue = [objectInfo.obj valueForKey:primaryKey];
    [sql appendFormat:@" WHERE %@ = %@;", primaryKey, primaryValue];
    NSError *_Nullable error = nil;
    sj_sqlite3_obj_exec(self.db, sql, &error);
    return error;
}

- (nullable NSError *)_insertOrUpdateObjects:(NSArray *)objsArray {
    NSError *_Nullable error = nil;
    for ( id obj in objsArray ) {
        SJSQLiteObjectInfo *_Nullable objectInfo = [SJSQLiteObjectInfo objectInfoWithObject:obj];
        if ( objectInfo == nil ) {
            error = sqlite3_error_get_table_failed([obj class]);
            return error;
        }
        
        for ( Class cls in objectInfo.table.allClasses ) {
            error = [self _checkoutTable:cls];
            if ( error != nil ) return error;
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
    
    NSString *sql = sj_sqlite3_stmt_insert_or_update(objectInfo);
    
    sj_sqlite3_obj_exec(self.db, sql, &error);
    
    if ( error == nil && objectInfo.autoincrementColumns ) {
        NSString *sql = sj_sqlite3_stmt_get_last_row(objectInfo);
        __auto_type _Nullable results = [sj_sqlite3_obj_exec(self.db, sql, &error) firstObject];
        if ( error != nil ) return error;
        id obj = objectInfo.obj;
        for ( SJSQLiteColumnInfo *column in objectInfo.autoincrementColumns ) {
            NSString *key = column.name;
            [obj setValue:results[key] forKey:key];
        }
    }
    
    return error;
}

- (nullable id)_transformRowData:(NSDictionary *)rowData toObjectOfClass:(Class)cls error:(NSError **)error {
    if ( rowData == nil || cls == nil ) return nil;
    NSError *inner_error = nil;
    NSMutableDictionary *result = [rowData mutableCopy];
    SJSQLiteTableInfo *_Nullable table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    if ( table == nil ) {
        inner_error = sqlite3_error_get_table_failed(cls);
        goto handle_error;
    }
    
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
@end
NS_ASSUME_NONNULL_END

