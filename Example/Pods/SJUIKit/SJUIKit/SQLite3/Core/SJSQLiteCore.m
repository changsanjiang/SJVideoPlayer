//
//  SJSQLiteCore.m
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLiteCore.h"
#import "SJSQLiteErrors.h"
#import "SJSQLiteTableInfo.h"
#import "SJSQLiteColumnInfo.h"
#import "SJSQLiteObjectInfo.h"
#import "SJSQLite3Logger.h"
#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN
@implementation NSMutableString (SJSQLite3CoreExtended)
- (void)sjsql_deleteSuffix:(NSString *)str {
    if ( [self hasSuffix:str] ) {
        [self deleteCharactersInRange:NSMakeRange(self.length - str.length, str.length)];
    }
}
@end


NSString *
sj_sqlite3_obj_get_default_table_name(Class cls) {
    return [NSString stringWithFormat:@"%s", object_getClassName(cls)];
}

id
sj_sqlite3_obj_filter_obj_value(id value) {
    if ( [value isKindOfClass:NSString.class] ) {
        return [(NSString *)value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    }
    else if ( [value isKindOfClass:NSArray.class] ) {
        NSMutableArray *m = [NSMutableArray new];
        for ( id item in value ) {
            [m addObject:sj_sqlite3_obj_filter_obj_value(item)];
        }
        return m;
    }
    else if ( [value isKindOfClass:NSDictionary.class] ) {
        NSMutableDictionary *m = [NSMutableDictionary new];
        [(NSDictionary *)value enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            m[key] = sj_sqlite3_obj_filter_obj_value(obj);
        }];
        return m;
    }
    else if ( [value isKindOfClass:NSSet.class] ) {
        NSMutableSet *m = [NSMutableSet new];
        for ( id item  in value ) {
            [m addObject:sj_sqlite3_obj_filter_obj_value(item)];
        }
        return m;
    }
    return value;
}

/// 生成创建表的sql语句. 只处理当前表, 不处理相关表.
///
NSString *
sj_sqlite3_stmt_create_table(SJSQLiteTableInfo *table) {
    // CREATE TABLE IF NOT EXISTS Account ('id' INTEGER  PRIMARY KEY AUTOINCREMENT,'user' INTEGER  NOT NULL);
    NSMutableString *sql = NSMutableString.new;
    SJSQLiteColumnInfo *last = table.columns.lastObject;
    [sql appendFormat:@"CREATE TABLE %@ (", table.name]; {
        for ( SJSQLiteColumnInfo *column in table.columns ) {
            [sql appendFormat:@"'%@' %@", column.name, column.type];
            if ( column.constraints ) [sql appendFormat:@" %@", column.constraints];
            if ( column != last ) [sql appendString:@","];
        }
    } [sql appendString:@");"];
    return sql.copy;
}

/// 生成插入的sql语句. 只处理当前对象, 不处理相关对象.
///
NSString *
sj_sqlite3_stmt_insert_or_update(SJSQLiteObjectInfo *objInfo) {
    // INSERT OR REPLACE INTO 'Account' ('id', 'user') VALUES (1, 12);
    // INSERT OR REPLACE INTO 'Person' ('id', 'tags') VALUES (1, `array json`);
    NSMutableString *sql = NSMutableString.new;
    NSMutableString *fields = NSMutableString.new;
    NSMutableString *values = NSMutableString.new;
    
    __auto_type columns = objInfo.table.columns;
    __auto_type last = columns.lastObject;
    for ( SJSQLiteColumnInfo *column in columns ) {
        id _Nullable value = [objInfo.obj valueForKey:column.name];
        if ( value == nil ) continue;
        
        if ( column.isAutoincrement && [value integerValue] == 0 ) continue;
        
        // - fields
        [fields appendFormat:@"'%@'", column.name];
        if ( column != last) [fields appendString:@","];
        
        // - values
        [values appendFormat:@"'%@'", sj_sqlite3_stmt_get_column_value(column, value)];
        if ( column != last) [values appendFormat:@","];
    }
    [fields sjsql_deleteSuffix:@","];
    [values sjsql_deleteSuffix:@","];
    [sql appendFormat:@"REPLACE INTO '%@' (%@) VALUES (%@);", objInfo.table.name, fields, values];
    return sql.copy;
}

NSString *
sj_sqlite3_stmt_get_column_value(SJSQLiteColumnInfo *column, id value) {
    NSString *data = nil;
    if ( column.associatedTableInfo == nil ) {
        data = [NSString stringWithFormat:@"%@", sj_sqlite3_obj_filter_obj_value(value)];
    }
    else {
        SJSQLiteTableInfo *subtable = column.associatedTableInfo;
        if ( column.isModelArray ) {
            data = sj_sqlite3_stmt_get_primary_values_json_string(value, subtable.primaryKey);
        }
        else {
            id subvalue = [value valueForKey:subtable.primaryKey];
            data = [NSString stringWithFormat:@"%@", subvalue];
        }
    }
    return data;
}

NSString *_Nullable
sj_sqlite3_stmt_get_primary_values_json_string(NSArray *models, NSString *primaryKey) {
    NSMutableArray *subvalues = [NSMutableArray arrayWithCapacity:[models count]];
    [models enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id subvalue = [obj valueForKey:primaryKey];
        [subvalues addObject:subvalue];
    }];
    NSData *subvaluesData = [NSJSONSerialization dataWithJSONObject:subvalues options:0 error:nil];
    return [[NSString alloc] initWithData:subvaluesData encoding:NSUTF8StringEncoding];
}

NSArray<id> *_Nullable
sj_sqlite3_stmt_get_primary_values_array(NSString *jsonString) {
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

NSString *
sj_sqlite3_stmt_get_last_row(SJSQLiteTableInfo *table) {
    return [NSString stringWithFormat:@"SELECT * FROM '%@' ORDER BY \"%@\" DESC LIMIT 1;", table.name, table.primaryKey];
}

#pragma mark -

/// sqlite3_exec每次执行结果的回调
///
int
sj_sqlite3_obj_exec_each_result_callback(void *para, int ncolumn, char **columnvalue, char **columnname) {
    NSMutableArray<NSDictionary *> *results = (__bridge NSMutableArray *)para;
    NSMutableDictionary *result = NSMutableDictionary.new;
    for ( int i = 0 ; i < ncolumn ; ++ i ) {
        char *_Nullable value = columnvalue[i];
        if ( value ) result[[NSString stringWithUTF8String:columnname[i]]] = [NSString stringWithUTF8String:value];
    }
    
    [results addObject:result];
    return 0;
}

/// 打开数据库链接
///
BOOL
sj_sqlite3_obj_open_database(NSString *path, void *db) {
    NSString *directory = [path stringByDeletingLastPathComponent];
    if ( ![NSFileManager.defaultManager fileExistsAtPath:directory] ) {
        [NSFileManager.defaultManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    sj_sqlite3_obj_copy_str(path);
    return SQLITE_OK == sqlite3_open(cstr, db);
}

/// 关闭数据库链接
///
BOOL
sj_sqlite3_obj_close_database(void *db) {
    return sqlite3_close(db);
}

/// 执行sql
///
NSArray<NSDictionary *> *_Nullable
sj_sqlite3_obj_exec(void *db, NSString *sql, NSError *_Nullable*_Nullable error) {
    if ( sql.length == 0 ) return nil;
    
    sj_sqlite3_obj_copy_str(sql);
    
    char *errmsg = NULL;
    NSMutableArray<NSDictionary *> *results = NSMutableArray.array;
    
    void *var = (__bridge void *)results;

    // https://sqlite.org/c3ref/exec.html
    sqlite3_exec(db, cstr, sj_sqlite3_obj_exec_each_result_callback, var, &errmsg);
    
#ifdef DEBUG
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        //        RFC3339DateFormatter = [[NSDateFormatter alloc] init];
        //        RFC3339DateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        //        RFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        //        RFC3339DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        //
        //        /* 39 minutes and 57 seconds after the 16th hour of December 19th, 1996 with an offset of -08:00 from UTC (Pacific Standard Time) */
        //        NSString *string = @"1996-12-19T16:39:57-08:00";
        //        NSDate *date = [RFC3339DateFormatter dateFromString:string];
        dateFormatter.dateFormat = @"HH:mm:ss";
    });
    
    SJSQLite3Log(@"SJSQLite: %@\t%s\n", [dateFormatter stringFromDate:NSDate.date], cstr);
    
    if ( errmsg != NULL ) {
        SJSQLite3Log(@"SJSQLite: %@\t%s\n", [dateFormatter stringFromDate:NSDate.date], errmsg);
    }
#endif
    
    if ( errmsg != NULL ) {
        if ( error != nil )
            *error = sqlite3_error_make_error([NSString stringWithUTF8String:errmsg]);
        sqlite3_free(errmsg);
        return nil;
    }
    
    return results.count != 0 ? results.copy : nil;
}

/// 开启事物
///
void
sj_sqlite3_obj_begin_transaction(void *db) {
    sj_sqlite3_obj_exec(db, @"BEGIN TRANSACTION", nil);
}

/// 提交事物
///
void
sj_sqlite3_obj_commit(void *db) {
    sj_sqlite3_obj_exec(db, @"COMMIT", nil);
}

/// 回滚提交
///
void
sj_sqlite3_obj_rollback(void *db) {
    sj_sqlite3_obj_exec(db, @"ROLLBACK", nil);
}

/// 查询某个表是否存在
///
BOOL
sj_sqlite3_obj_table_exists(void *db, NSString *name) {
    return sj_sqlite3_obj_exec(db, [NSString stringWithFormat:@"SELECT tbl_name FROM sqlite_master WHERE name='%@';", name], nil) != nil;
}

/// 删除表
///
void
sj_sqlite3_obj_drop_table(void *db, NSString *name, NSError **error) {
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@;", name];
    sj_sqlite3_obj_exec(db, sql, error);
}

/// 删除指定的行数据
///
void
sj_sqlite3_obj_delete_row_datas(void *db, SJSQLiteTableInfo *table, NSArray<id> *primaryKeyValues, NSError **error) {
    NSMutableString *values = NSMutableString.new;
    NSNumber *last = primaryKeyValues.lastObject;
    for ( id value in primaryKeyValues ) {
        [values appendFormat:@"'%@'", sj_sqlite3_obj_filter_obj_value(value)];
        if ( value != last ) [values appendString:@","];
    }
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE \"%@\" in (%@);", table.name, table.primaryKey, values];
    sj_sqlite3_obj_exec(db, sql, error);
}

/// 获取行数据
///
NSDictionary *_Nullable
sj_sqlite3_obj_get_row_data(void *db, SJSQLiteTableInfo *table, id primaryKeyValue, NSError **error) {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE \"%@\"='%@';", table.name, table.primaryKey, sj_sqlite3_obj_filter_obj_value(primaryKeyValue)];
    return [[sj_sqlite3_obj_exec(db, sql, error) firstObject] mutableCopy];
}
NS_ASSUME_NONNULL_END
