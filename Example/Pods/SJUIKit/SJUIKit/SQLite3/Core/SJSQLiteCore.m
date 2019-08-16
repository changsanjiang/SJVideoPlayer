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

NS_ASSUME_NONNULL_BEGIN
NSString *
sqlite3_obj_get_default_table_name(Class cls) {
    return [NSString stringWithFormat:@"%s", object_getClassName(cls)];
}

id
sqlite3_obj_filter_obj_value(id value) {
    if ( [value isKindOfClass:NSString.class] ) {
        return [(NSString *)value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    }
    else if ( [value isKindOfClass:NSArray.class] ) {
        NSMutableArray *m = [NSMutableArray new];
        for ( id item in value ) {
            [m addObject:sqlite3_obj_filter_obj_value(item)];
        }
        return m;
    }
    else if ( [value isKindOfClass:NSDictionary.class] ) {
        NSMutableDictionary *m = [NSMutableDictionary new];
        [(NSDictionary *)value enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            m[key] = sqlite3_obj_filter_obj_value(obj);
        }];
        return m;
    }
    else if ( [value isKindOfClass:NSSet.class] ) {
        NSMutableSet *m = [NSMutableSet new];
        for ( id item  in value ) {
            [m addObject:sqlite3_obj_filter_obj_value(item)];
        }
        return m;
    }
    return value;
}

/// 生成创建表的sql语句. 只处理当前表, 不处理相关表.
///
NSString *
sqlite3_stmt_create_table(SJSQLiteTableInfo *table) {
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
sqlite3_stmt_insert_or_update(SJSQLiteObjectInfo *objInfo) {
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
        if ( column.associatedTableInfo == nil ) {
            [values appendFormat:@"'%@'", sqlite3_obj_filter_obj_value(value)];
            if ( column != last) [values appendFormat:@","];
        }
        else {
            SJSQLiteTableInfo *subtable = column.associatedTableInfo;
            if ( column.isArrayJSONText ) {
                NSMutableArray *subvalues = [NSMutableArray arrayWithCapacity:[value count]];
                [value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    id subvalue = [obj valueForKey:subtable.primaryKey];
                    [subvalues addObject:subvalue];
                }];
                NSData *subvaluesData = [NSJSONSerialization dataWithJSONObject:subvalues options:0 error:nil];
                NSString *subvaluesStr = [[NSString alloc] initWithData:subvaluesData encoding:NSUTF8StringEncoding];
                [values appendFormat:@"'%@'", subvaluesStr];
                if ( column != last) [values appendFormat:@","];
            }
            else {
                id subvalue = [value valueForKey:subtable.primaryKey];
                [values appendFormat:@"'%@'", subvalue];
                if ( column != last) [values appendFormat:@","];
            }
        }
    }
    if ( [fields hasSuffix:@","] ) [fields deleteCharactersInRange:NSMakeRange(fields.length - 1, 1)];
    if ( [values hasSuffix:@","] ) [values deleteCharactersInRange:NSMakeRange(values.length - 1, 1)];
    [sql appendFormat:@"INSERT OR REPLACE INTO '%@' (%@) VALUES (%@);", objInfo.table.name, fields, values];
    return sql.copy;
}

NSString *
sqlite3_stmt_get_last_row(SJSQLiteObjectInfo *objInfo) {
    return [NSString stringWithFormat:@"SELECT * FROM '%@' ORDER BY \"%@\" DESC LIMIT 1;", objInfo.table.name, objInfo.primaryKeyColumnInfo.name];
}

#pragma mark -

/// sqlite3_exec每次执行结果的回调
///
int
sqlite3_obj_exec_each_result_callback(void *para, int ncolumn, char **columnvalue, char **columnname) {
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
sqlite3_obj_open_database(NSString *path, sqlite3 **db) {
    sqlite3_obj_copy_str(path);
    return SQLITE_OK == sqlite3_open(cstr, db);
}

/// 关闭数据库链接
///
BOOL
sqlite3_obj_close_database(sqlite3 *db) {
    return sqlite3_close(db);
}

/// 执行sql
///
NSArray<NSDictionary *> *_Nullable
sqlite3_obj_exec(sqlite3 *db, NSString *sql, NSError *_Nullable*_Nullable error) {
    if ( sql.length == 0 ) return nil;
    
    sqlite3_obj_copy_str(sql);
    
    char *errmsg = NULL;
    NSMutableArray<NSDictionary *> *results = NSMutableArray.new;
    // https://sqlite.org/c3ref/exec.html
    sqlite3_exec(db, cstr, sqlite3_obj_exec_each_result_callback, (__bridge void *)results, &errmsg);
    
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
    
    printf("SJSQLite: %s\t%s\n", [dateFormatter stringFromDate:NSDate.date].UTF8String, cstr);
    if ( errmsg != NULL ) {
        printf("SJSQLite: %s\terror_msg=%s\n", [dateFormatter stringFromDate:NSDate.date].UTF8String, errmsg);
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
sqlite3_obj_begin_transaction(sqlite3 *db) {
    sqlite3_obj_exec(db, @"BEGIN TRANSACTION", nil);
}

/// 提交事物
///
void
sqlite3_obj_commit(sqlite3 *db) {
    sqlite3_obj_exec(db, @"COMMIT", nil);
}

/// 回滚提交
///
void
sqlite3_obj_rollback(sqlite3 *db) {
    sqlite3_obj_exec(db, @"ROLLBACK", nil);
}

/// 查询某个表是否存在
///
BOOL
sqlite3_obj_table_exists(sqlite3 *db, NSString *name) {
    return sqlite3_obj_exec(db, [NSString stringWithFormat:@"SELECT tbl_name FROM sqlite_master WHERE name='%@';", name], nil) != nil;
}

/// 删除表
///
void
sqlite3_obj_drop_table(sqlite3 *db, NSString *name, NSError **error) {
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@;", name];
    sqlite3_obj_exec(db, sql, error);
}

/// 删除指定的行数据
///
void
sqlite3_obj_delete_row_datas(sqlite3 *db, SJSQLiteTableInfo *table, NSArray<NSNumber *> *primaryKeyValues, NSError **error) {
    NSMutableString *values = NSMutableString.new;
    NSNumber *last = primaryKeyValues.lastObject;
    for ( NSNumber *num in primaryKeyValues ) {
        [values appendFormat:@"%@", num];
        if ( num != last ) [values appendString:@","];
    }
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE \"%@\" in (%@);", table.name, table.primaryKey, values];
    sqlite3_obj_exec(db, sql, error);
}

/// 获取行数据
///
NSDictionary *_Nullable
sqlite3_obj_get_row_data(sqlite3 *db, SJSQLiteTableInfo *table, NSInteger primaryKeyValue, NSError **error) {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE \"%@\"=%ld;", table.name, table.primaryKey, (long)primaryKeyValue];
    return [[sqlite3_obj_exec(db, sql, error) firstObject] mutableCopy];
}
NS_ASSUME_NONNULL_END
