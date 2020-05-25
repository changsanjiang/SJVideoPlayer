//
//  SJSQLite3+QueryExtended.m
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//

#import "SJSQLite3+QueryExtended.h"
#import "SJSQLiteErrors.h"
#import "SJSQLite3+Private.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJSQLite3 (QueryObjectsExtended)
/// 获取满足指定条件的数据. (返回的数据已转为相应的模型)
///
/// @param cls              数据库表所对应的类. (该类必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`)
///
/// @param conditions       搜索条件.
///
/// @param orders           将结果排序. 例如: 将结果按id倒序和name倒序排列, 可传入
///                         @[[SJSQLite3ColumnOrder orderWithColumn:@"id" ascending:NO],
///                           [SJSQLite3ColumnOrder orderWithColumn:@"name" ascending:NO]]
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @return                 返回满足条件的对象集合. 如果条件不满足, 则返回nil.
///
- (nullable NSArray *)objectsForClass:(Class)cls conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders error:(NSError **)error {
    return [self objectsForClass:cls conditions:conditions orderBy:orders range:NSMakeRange(0, NSUIntegerMax) error:error];
}

/// 获取满足指定条件及指定数量的数据. (如果数据量过大, 可以使用此方法进行分页获取. 返回的数据已转为相应的模型)
///
/// @param cls              数据库表所对应的类. (该类必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`)
///
/// @param conditions       搜索条件.
///
/// @param orders           将结果排序. 例如: 将结果按id倒序和name倒序排列, 可传入
///                         @[[SJSQLite3ColumnOrder orderWithColumn:@"id" ascending:NO],
///                           [SJSQLite3ColumnOrder orderWithColumn:@"name" ascending:NO]]
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @param range            限制返回的数据的数量.
///
/// @return                 返回满足条件的对象集合. 如果条件不满足, 则返回nil.
///
- (nullable NSArray *)objectsForClass:(Class)cls conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders range:(NSRange)range error:(NSError **)error {
    NSError *inner_error = nil;
    __auto_type results = [self _rowDataForClass:cls resultColumns:@[@"*"] conditions:conditions orderBy:orders range:range error:&inner_error];
    if ( inner_error != nil ) {
        if ( error ) *error = inner_error;
        return nil;
    }
    return [self objectsForClass:cls rowDatas:results error:error];
}

/// 查询数量
///
/// @param cls              数据库表所对应的类. (该类必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`)
///
/// @param conditions       搜索条件.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @return                 返回满足条件的数据的数量.
///
- (NSUInteger)countOfObjectsForClass:(Class)cls conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions error:(NSError **)error {
    NSError *inner_error = nil;
    __auto_type results = [self _rowDataForClass:cls resultColumns:@[@"count(*)"] conditions:conditions orderBy:nil range:NSMakeRange(0, NSUIntegerMax) error:&inner_error];
    if ( inner_error != nil ) {
        if ( error ) *error = inner_error;
        return 0;
    }
    return [results.firstObject[@"count(*)"] integerValue];
}

- (nullable NSArray<SJSQLite3RowData *> *)_rowDataForClass:(Class)cls resultColumns:(nullable NSArray<NSString *> *)columns conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders range:(NSRange)range error:(NSError **)error {
    SJSQLiteTableInfo *_Nullable table = [self tableInfoForClass:cls error:error];
    if ( table == nil ) return nil;
    
    NSMutableString *selectColumns = nil;
    if ( columns.count != 0 ) {
        selectColumns = NSMutableString.new;
        for ( NSString *column in columns ) {
            [selectColumns appendFormat:@"%@,", column];
        }
        [selectColumns sjsql_deleteSuffix:@","];
    }
    else {
        selectColumns = @"*".mutableCopy;
    }
    
    NSMutableString *where = nil;
    if ( conditions.count != 0 ) {
        where = NSMutableString.new;
        for ( SJSQLite3Condition *obj in conditions ) {
            [where appendFormat:@"%@ AND ", obj.condition];
        }
        [where sjsql_deleteSuffix:@" AND "];
    }
    
    NSMutableString *orderBy = nil;
    if ( orders.count != 0 ) {
        orderBy = NSMutableString.new;
        for ( SJSQLite3ColumnOrder *order in orders ) {
            [orderBy appendFormat:@"%@,", order.order];
        }
        [orderBy sjsql_deleteSuffix:@","];
    }
    
    NSString *limit = nil;
    if ( range.length != NSUIntegerMax ) {
        limit = [NSString stringWithFormat:@"%ld, %ld", (long)range.location, (long)range.length];
    }
    
    NSMutableString *sql = NSMutableString.new;
    [sql appendFormat:@"SELECT %@ FROM '%@'", selectColumns, table.name];
    if ( where )    [sql appendFormat:@" WHERE %@", where];
    if ( orderBy )  [sql appendFormat:@" ORDER BY %@", orderBy];
    if ( limit )    [sql appendFormat:@" LIMIT %@", limit];
    [sql appendString:@";"];
    
    NSError *inner_error = nil;
    __auto_type results = [self exec:sql error:&inner_error];
    if ( inner_error != nil ) {
        if ( error ) *error = inner_error;
        return nil;
    }
    return results;
}
@end

@implementation SJSQLite3 (QueryDataExtended)

/// 获取满足指定条件的数据. (返回的数据未做转换)
///
/// @param cls              数据库表所对应的类. (该类必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`)
///
/// @param columns          返回的结果列(字典的keys). 如果为空, 将返回所有的列.
///
/// @param conditions       搜索条件.
///
/// @param orders           将结果排序. 例如: 将结果按id倒序和name倒序排列, 可传入
///                         @[[SJSQLite3ColumnOrder orderWithColumn:@"id" ascending:NO],
///                           [SJSQLite3ColumnOrder orderWithColumn:@"name" ascending:NO]]
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @return                 返回满足条件的对象集合. 如果条件不满足, 则返回nil.
///
- (nullable NSArray<NSDictionary *> *)queryDataForClass:(Class)cls resultColumns:(nullable NSArray<NSString *> *)columns conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders error:(NSError **)error {
    return [self queryDataForClass:cls resultColumns:columns conditions:conditions orderBy:orders range:NSMakeRange(0, NSUIntegerMax) error:error];
}

/// 获取满足指定条件的数据. (返回的数据未做转换)
///
/// @param cls              数据库表所对应的类. (该类必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`)
///
/// @param columns          返回的结果列(字典的keys). 如果为空, 将返回所有的列.
///
/// @param conditions       搜索条件.
///
/// @param orders           将结果排序. 例如: 将结果按id倒序和name倒序排列, 可传入
///                         @[[SJSQLite3ColumnOrder orderWithColumn:@"id" ascending:NO],
///                           [SJSQLite3ColumnOrder orderWithColumn:@"name" ascending:NO]]
///
/// @param range            限制返回的数据的数量.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @return                 返回满足条件的对象集合. 如果条件不满足, 则返回nil.
///
- (nullable NSArray<NSDictionary *> *)queryDataForClass:(Class)cls resultColumns:(nullable NSArray<NSString *> *)columns conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders range:(NSRange)range error:(NSError **)error {
    SJSQLiteTableInfo *_Nullable table = [self tableInfoForClass:cls error:error];
    if ( table == nil ) return nil;
    
    NSError *inner_error = nil;
    __auto_type results = [self _rowDataForClass:cls resultColumns:columns conditions:conditions orderBy:orders range:range error:&inner_error];
    if ( inner_error != nil ) {
        if ( error ) *error = inner_error;
        return nil;
    }
    
    NSArray<SJSQLiteColumnInfo *> *columnsOfAssociatedTables = nil;
    if ( columns.count == 0 ) {
        columnsOfAssociatedTables = table.columnAssociatedTableInfos.allKeys;
    }
    else {
        NSMutableArray<SJSQLiteColumnInfo *> *m = NSMutableArray.new;
        for ( NSString *column in columns ) {
            SJSQLiteColumnInfo *info = [table columnInfoForColumnName:column];
            if ( info.associatedTableInfo != nil ) [m addObject:info];
        }
        if ( m.count != 0 ) columnsOfAssociatedTables = m.copy;
    }
    
    if ( columnsOfAssociatedTables.count == 0 )
        return results;
    
    NSMutableArray<NSDictionary *> *datas = [NSMutableArray.alloc initWithCapacity:results.count];
    for ( NSDictionary *rowData in results ) {
        NSMutableDictionary *m = rowData.mutableCopy;
        for ( SJSQLiteColumnInfo *column in columnsOfAssociatedTables ) {
            id value = rowData[column.name];
            if ( value == nil ) continue;
            SJSQLite3Condition *conditon = nil;
            if ( column.isModelArray ) {
                __auto_type primaryValues = sj_sqlite3_stmt_get_primary_values_array(value);
                conditon = [SJSQLite3Condition conditionWithColumn:column.associatedTableInfo.primaryKey in:primaryValues];
            }
            else {
                conditon = [SJSQLite3Condition conditionWithColumn:column.associatedTableInfo.primaryKey value:value];
            }

            m[column.name] = [self queryDataForClass:column.associatedTableInfo.cls resultColumns:nil conditions:@[conditon] orderBy:nil error:&inner_error];
            
            if ( inner_error != nil ) {
                if ( error ) *error = inner_error;
                return nil;
            }
        }
        [datas addObject:m];
    }
    return datas.copy;
}

@end
NS_ASSUME_NONNULL_END
