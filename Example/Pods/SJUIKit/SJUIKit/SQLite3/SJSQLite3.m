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

NS_ASSUME_NONNULL_BEGIN
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
    if ( sqlite3_obj_open_database(dbPath, &db) == NO )
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
    sqlite3_obj_close_database(_db);
}

#pragma mark -

/// 只处理参数类, 不处理相关类
///
- (BOOL)_tableExists:(Class)cls {
    SJSQLiteTableInfo *table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    return sqlite3_obj_table_exists(self.db, table.name);
}

/// 只处理参数类, 不处理相关类
///
- (nullable NSError *)_alterTableIfNeeded:(Class)cls {
    SJSQLiteTableInfo *table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    
    NSString *query = [NSString stringWithFormat:@"SELECT sql FROM sqlite_master WHERE name='%@';", table.name];
    NSString *stosql = [[sqlite3_obj_exec(self.db, query, NULL) firstObject][@"sql"] stringByAppendingString:@";"];
    NSString *cursql = sqlite3_stmt_create_table(table);
    if ( [cursql isEqualToString:stosql] ) {
        return nil;
    }
    
    NSString *tmpname = [NSString stringWithFormat:@"%@_ME_TMP", table.name];
    NSString *altsql = [NSString stringWithFormat:@"ALTER TABLE '%@' RENAME TO '%@';", table.name, tmpname];
    NSError *_Nullable error = nil;
    sqlite3_obj_exec(self.db, altsql, &error);
    if ( error ) return error;

    sqlite3_obj_exec(self.db, cursql, &error);
    if ( error ) return error;

    NSString *tmpinfosql = [NSString stringWithFormat:@"PRAGMA table_info('%@');", tmpname];
    NSString *curinfosql = [NSString stringWithFormat:@"PRAGMA table_info('%@');", table.name];
    NSArray<NSDictionary *> *tmpInfo = sqlite3_obj_exec(self.db, tmpinfosql, &error);
    if ( error ) return error;
    NSArray<NSDictionary *> *curInfo = sqlite3_obj_exec(self.db, curinfosql, &error);
    if ( error ) return error;
    
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
    [fields deleteCharactersInRange:NSMakeRange(fields.length - 1, 1)];
    
    NSString *inssql = [NSString stringWithFormat:@"INSERT INTO '%@' (%@) SELECT %@ FROM '%@';", table.name, fields, fields, tmpname];
    sqlite3_obj_exec(self.db, inssql, &error);
    if ( error ) return error;

    sqlite3_obj_drop_table(self.db, tmpname, &error);
    return error;
}

/// 只处理参数类, 不处理相关类
///
- (nullable NSError *)_createTable:(Class)cls {
    SJSQLiteTableInfo *table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    NSString *sql = sqlite3_stmt_create_table(table);
    NSError *error = nil;
    sqlite3_obj_exec(self.db, sql, &error);
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

#pragma mark - Common Methods

/// 将对象数据保存到数据库表中. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
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

/// 将对象数据保存到数据库表中. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param objsArray            需要保存的对象集合. 该集合中的对象的Class必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`.
///
/// @param error                执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @return                     操作是否成功.
///
- (BOOL)saveObjects:(NSArray *)objsArray error:(NSError **)error {
    if ( objsArray.count == 0 ) {
        if ( error ) *error = sqlite3_error_invalid_parameter();
        return NO;
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    sqlite3_obj_begin_transaction(self.db);
    
    NSError *inner_error = nil;
    for ( id obj in objsArray ) {
        SJSQLiteObjectInfo *_Nullable objectInfo = [SJSQLiteObjectInfo objectInfoWithObject:obj];
        if ( objectInfo == nil ) {
            inner_error = sqlite3_error_get_table_failed([obj class]);
            goto handle_error;
        }
        
        for ( Class cls in objectInfo.table.allClasses ) {
            inner_error = [self _checkoutTable:cls];
            if ( inner_error ) goto handle_error;
        }
        
        inner_error = [self _insertOrUpdateObject:objectInfo];
        if ( inner_error ) goto handle_error;
    }
    
handle_error:
    if ( inner_error ) {
        if ( error != NULL ) *error = inner_error;
        sqlite3_obj_rollback(self.db);
        dispatch_semaphore_signal(_lock);
        return NO;
    }
    
    sqlite3_obj_commit(self.db);
    dispatch_semaphore_signal(_lock);
    return YES;
}

/// 获取指定的主键值所对应存储的对象.
///
/// @param cls              数据库表所对应的类.
///
/// @param primaryKeyValue  需要获取的对象的主键值.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句.
///
/// @return 返回指定的主键值所对应存储的对象. 如果不存在, 将返回nil.
///
- (nullable id)objectForClass:(Class)cls primaryKeyValue:(NSInteger)primaryKeyValue error:(NSError **)error {
    SJSQLiteTableInfo *_Nullable table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    if ( table == nil ) {
        if ( error ) *error = sqlite3_error_get_table_failed(cls);
        return nil;
    }
    
    NSError *_Nullable inner_error = nil;
    id _Nullable result = nil;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    NSDictionary *_Nullable rowData = sqlite3_obj_get_row_data(self.db, table, primaryKeyValue, &inner_error);
    if ( inner_error == nil ) result = [self _transformRowData:rowData toObjectOfClass:cls error:&inner_error];
    
    if ( inner_error ) {
        if ( error ) *error = inner_error;
        dispatch_semaphore_signal(_lock);
        return nil;
    }
    dispatch_semaphore_signal(_lock);
    return result;
}

/// 删除某个类对应的表存储的所有数据(删除表). 操作不可逆, 请谨慎操作. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param cls              数据库表所对应的类.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
- (void)removeAllObjectsForClass:(Class)cls error:(NSError **)error {
    SJSQLiteTableInfo *_Nullable table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    if ( table == nil ) return;

    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    NSError *inner_error = nil;
    sqlite3_obj_drop_table(self.db, table.name, &inner_error);
    if ( inner_error ) {
        if ( error ) *error = inner_error;
        sqlite3_obj_rollback(self.db);
        dispatch_semaphore_signal(_lock);
        return;
    }
    sqlite3_obj_commit(self.db);
    [self.classesCache removeClass:cls];
    dispatch_semaphore_signal(_lock);
}

/// 删除指定的主键值的数据. 操作不可逆, 请谨慎操作. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param cls              数据库表所对应的类.
///
/// @param value            需要删除的数据的主键值.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
- (void)removeObjectForClass:(Class)cls primaryKeyValue:(NSInteger)value error:(NSError **)error {
    [self removeObjectsForClass:cls primaryKeyValues:@[@(value)] error:error];
}

/// 删除指定的主键值的数据. 操作不可逆, 请谨慎操作. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param cls              数据库表所对应的类.
///
/// @param primaryKeyValues 需要删除的数据的主键值的集合.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
- (void)removeObjectsForClass:(Class)cls primaryKeyValues:(NSArray<NSNumber *> *)primaryKeyValues error:(NSError **)error {
    SJSQLiteTableInfo *_Nullable table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    if ( table == nil ) return;
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    sqlite3_obj_begin_transaction(self.db);
    NSError *inner_error = nil;
    sqlite3_obj_delete_row_datas(self.db, table, primaryKeyValues, error);
    if ( inner_error ) {
        if ( error ) *error = inner_error;
        sqlite3_obj_rollback(self.db);
        dispatch_semaphore_signal(_lock);
        return;
    }
    sqlite3_obj_commit(self.db);
    dispatch_semaphore_signal(_lock);
}

/// 执行自定义的sql. (适合执行查询操作)
///
/// @param sql              需要执行的sql语句.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句.
///
/// @return sql执行所返回的结果.
///
- (nullable NSArray<NSDictionary *> *)exec:(NSString *)sql error:(NSError *_Nullable *_Nullable)error {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    id result = sqlite3_obj_exec(self.db, sql, error);;
    dispatch_semaphore_signal(_lock);
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
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    sqlite3_obj_begin_transaction(self.db);
    NSError *innser_error = nil;
    id result = sqlite3_obj_exec(self.db, sql, &innser_error);
    if ( innser_error != nil ) {
        sqlite3_obj_rollback(self.db);
        if ( error ) *error = innser_error;
        dispatch_semaphore_signal(_lock);
        return nil;
    }
    sqlite3_obj_commit(self.db);
    dispatch_semaphore_signal(_lock);
    return result;
}

/// 将执行的查询结果转换为对应的类的对象.
///
/// @param cls              数据库表所对应的类.
///
/// @param rowDatas         该参数为`exec:error:`执行后的返回值.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
- (nullable NSArray *)objectsForClass:(Class)cls rowDatas:(NSArray<SJSQLite3RowData *> *)rowDatas error:(NSError **)error {
    if ( rowDatas.count == 0 ) return nil;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:rowDatas.count];
    NSError *inner_error = nil;
    for ( SJSQLite3RowData * rowData in rowDatas ) {
        id result = [self _transformRowData:rowData toObjectOfClass:cls error:&inner_error];
        if ( inner_error ) break;
        [arr addObject:result];
    }
    
    if ( inner_error ) {
        if ( error ) *error = inner_error;
        dispatch_semaphore_signal(_lock);
        return nil;
    }
    dispatch_semaphore_signal(_lock);
    return arr;
} 

#pragma mark -

- (nullable NSError *)_insertOrUpdateObject:(SJSQLiteObjectInfo *)objectInfo {
    NSError *error = nil;
    SJSQLiteTableInfo *table = objectInfo.table;
    for ( SJSQLiteColumnInfo *column in table.columns ) {
        if ( column.associatedObjectInfos != nil ) {
            for ( SJSQLiteObjectInfo *info in column.associatedObjectInfos ) {
                error = [self _insertOrUpdateObject:info];
                if ( error ) return error;
            }
        }
    }
    
    NSString *sql = sqlite3_stmt_insert_or_update(objectInfo);
    
    sqlite3_obj_exec(self.db, sql, &error);
    
    if ( error == nil && objectInfo.autoincrementColumns ) {
        NSString *sql = sqlite3_stmt_get_last_row(objectInfo);
        __auto_type _Nullable results = [sqlite3_obj_exec(self.db, sql, &error) firstObject];
        if ( error ) return error;
        id obj = objectInfo.obj;
        for ( SJSQLiteColumnInfo *column in objectInfo.autoincrementColumns ) {
            NSString *key = column.name;
            [obj setValue:results[key] forKey:key];
        }
    }
    
    return error;
}

- (nullable id)_transformRowData:(NSDictionary *)rowData toObjectOfClass:(Class)cls error:(NSError **)out_error {
    if ( rowData == nil || cls == nil ) return nil;
    NSError *error = nil;
    NSMutableDictionary *result = [rowData mutableCopy];
    SJSQLiteTableInfo *_Nullable table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    if ( table == nil ) {
        error = sqlite3_error_get_table_failed(cls);
        goto handle_error;
    }
    
    for ( SJSQLiteColumnInfo *column in table.columns ) {
        if ( column.associatedTableInfo == nil ) continue;
        id _Nullable value = rowData[column.name];
        if ( value == nil ) continue;
        
        SJSQLiteTableInfo *subtable = column.associatedTableInfo;
        if ( column.isArrayJSONText ) {
            NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSArray<NSNumber *> *primaryValues = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if ( error != nil ) goto handle_error;
            
            NSMutableArray<id> *subObjArr = NSMutableArray.new;
            BOOL intact = YES;
            for ( NSNumber *num in primaryValues ) {
                NSDictionary *subrow = sqlite3_obj_get_row_data(self.db, subtable, num.integerValue, &error);
                if ( error != nil ) goto handle_error;
                id _Nullable subobj = [self _transformRowData:subrow toObjectOfClass:subtable.cls error:&error];
                if ( error != nil ) goto handle_error;
                if ( subobj == nil ) { intact = NO; break; }
                [subObjArr addObject:subobj];
            }
            result[column.name] = intact?subObjArr.copy:nil;
        }
        else {
            NSDictionary *subrow = sqlite3_obj_get_row_data(self.db, subtable, [value integerValue], &error);
            if ( error != nil ) goto handle_error;
            id _Nullable subobj = [self _transformRowData:subrow toObjectOfClass:subtable.cls error:&error];
            if ( error != nil ) goto handle_error;
            result[column.name] = subobj;
        }
    }
    
handle_error:
    if ( error != nil ) {
        if ( out_error ) *out_error = error;
        return nil;
    }
    
    id obj = [[table.cls alloc] init];
    [obj setValuesForKeysWithDictionary:result];
    return obj;
}
@end
NS_ASSUME_NONNULL_END
