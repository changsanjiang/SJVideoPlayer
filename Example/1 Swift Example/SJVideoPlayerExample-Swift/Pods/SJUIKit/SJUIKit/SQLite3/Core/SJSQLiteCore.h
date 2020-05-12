//
//  SJSQLiteCore.h
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/6/18.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#ifndef SJSQLiteCore_h
#define SJSQLiteCore_h

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SJSQLiteTableInfo.h"
#import "SJSQLiteColumnInfo.h"
#import "SJSQLiteObjectInfo.h"
/**
 这里是一些常用的sql操作.
 */
NS_ASSUME_NONNULL_BEGIN

#define sj_sqlite3_obj_copy_str(_str_)     char cstr[strlen(_str_.UTF8String) + 1]; strcpy(cstr, _str_.UTF8String)

@interface NSMutableString (SJSQLite3CoreExtended)
- (void)sjsql_deleteSubffix:(NSString *)str;
@end


FOUNDATION_EXPORT NSString *
sj_sqlite3_obj_get_default_table_name(Class cls);

FOUNDATION_EXPORT id
sj_sqlite3_obj_filter_obj_value(id value);

/// 生成创建表的sql语句. 只处理当前表, 不处理相关表.
///
FOUNDATION_EXPORT NSString *
sj_sqlite3_stmt_create_table(SJSQLiteTableInfo *table);

/// 生成插入的sql语句. 只处理当前对象, 不处理相关对象.
///
FOUNDATION_EXPORT NSString *
sj_sqlite3_stmt_insert_or_update(SJSQLiteObjectInfo *objInfo);

FOUNDATION_EXPORT NSString *
sj_sqlite3_stmt_get_column_value(SJSQLiteColumnInfo *column, id value);

FOUNDATION_EXPORT NSString *_Nullable
sj_sqlite3_stmt_get_primary_values_json_string(NSArray *models, NSString *primaryKey);

FOUNDATION_EXPORT NSArray<id> *_Nullable
sj_sqlite3_stmt_get_primary_values_array(NSString *jsonString);

FOUNDATION_EXPORT NSString *
sj_sqlite3_stmt_get_last_row(SJSQLiteObjectInfo *objInfo);

#pragma mark -

/// sqlite3_exec每次执行结果的回调
///
FOUNDATION_EXPORT int
sj_sqlite3_obj_exec_each_result_callback(void *para, int ncolumn, char *_Nullable*_Nullable columnvalue, char *_Nullable*_Nullable columnname);

/// 打开数据库链接
///
FOUNDATION_EXPORT BOOL
sj_sqlite3_obj_open_database(NSString *path, sqlite3 *_Nullable*_Nonnull db);

/// 关闭数据库链接
///
FOUNDATION_EXPORT BOOL
sj_sqlite3_obj_close_database(sqlite3 *db);

/// 执行sql
///
FOUNDATION_EXPORT NSArray<NSDictionary *> *_Nullable
sj_sqlite3_obj_exec(sqlite3 *db, NSString *sql, NSError *_Nullable*_Nullable error);

/// 开启事物
///
FOUNDATION_EXPORT void
sj_sqlite3_obj_begin_transaction(sqlite3 *db);

/// 提交事物
///
FOUNDATION_EXPORT void
sj_sqlite3_obj_commit(sqlite3 *db);

/// 回滚提交
///
FOUNDATION_EXPORT void
sj_sqlite3_obj_rollback(sqlite3 *db);

/// 查询某个表是否存在
///
FOUNDATION_EXPORT BOOL
sj_sqlite3_obj_table_exists(sqlite3 *db, NSString *name);

/// 删除表
///
FOUNDATION_EXPORT void
sj_sqlite3_obj_drop_table(sqlite3 *db, NSString *name, NSError **error);

/// 删除指定的行数据
///
FOUNDATION_EXPORT void
sj_sqlite3_obj_delete_row_datas(sqlite3 *db, SJSQLiteTableInfo *table, NSArray<id> *primaryKeyValues, NSError **error);

/// 获取行数据
///
FOUNDATION_EXPORT NSDictionary *_Nullable
sj_sqlite3_obj_get_row_data(sqlite3 *db, SJSQLiteTableInfo *table, id primaryKeyValue, NSError **error);
NS_ASSUME_NONNULL_END

#endif /* SJSQLiteCore_h */
