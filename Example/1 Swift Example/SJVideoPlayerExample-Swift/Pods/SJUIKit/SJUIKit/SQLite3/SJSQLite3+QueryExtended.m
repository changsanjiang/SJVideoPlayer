//
//  SJSQLite3+QueryExtended.m
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//

#import "SJSQLite3+QueryExtended.h"
#import "SJSQLite3TableInfosCache.h"
#import "SJSQLiteErrors.h"

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
    SJSQLiteTableInfo *_Nullable table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    if ( table == nil ) {
        if ( error ) *error = sqlite3_error_get_table_failed(cls);
        return nil;
    }
    
    NSMutableString *selectColumns = nil;
    if ( columns.count != 0 ) {
        selectColumns = NSMutableString.new;
        for ( NSString *column in columns ) {
            [selectColumns appendFormat:@"%@,", column];
        }
        [selectColumns sjsql_deleteSubffix:@","];
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
        [where sjsql_deleteSubffix:@" AND "];
    }
    
    NSMutableString *orderBy = nil;
    if ( orders.count != 0 ) {
        orderBy = NSMutableString.new;
        for ( SJSQLite3ColumnOrder *order in orders ) {
            [orderBy appendFormat:@"%@,", order.order];
        }
        [orderBy sjsql_deleteSubffix:@","];
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
    SJSQLiteTableInfo *_Nullable table = [SJSQLite3TableInfosCache.shared getTableInfoForClass:cls];
    if ( table == nil ) {
        if ( error ) *error = sqlite3_error_get_table_failed(cls);
        return nil;
    }
    
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

@implementation SJSQLite3Condition
+ (instancetype)conditionWithColumn:(NSString *)column value:(id)value {
    return [self conditionWithColumn:column relatedBy:SJSQLite3RelationEqual value:value];
}

/// 条件操作符
///
/// @param  column          指定比较的列名.
///
/// @param  relation        指定`SJSQLite3Relation`中的任意值(>=, <=, !=, =, >, <).
///
/// @param  value           指定比较的值.
///
/// \code
/// // 例如查询`price = 12.0`的商品, 创建条件如下:
/// SJSQLite3Condition *cond =[SJSQLite3Condition conditionWithColumn:@"price" relatedBy:SJSQLite3RelationEqual value:@(12.0)];
/// NSArray *results = [SJSQLite3.shared objectsForClass:Product.class conditions:@[cond] orderBy:nil error:NULL];
/// \endcode
///
+ (instancetype)conditionWithColumn:(NSString *)column relatedBy:(SJSQLite3Relation)relation value:(id)value {
//    WHERE prod_price = 5;
    NSMutableString *conds = NSMutableString.new;
    [conds appendFormat:@"\"%@\" ", column];
    switch ( relation ) {
        case SJSQLite3RelationLessThanOrEqual:
            [conds appendFormat:@"<= '%@'", sj_sqlite3_obj_filter_obj_value(value)];
            break;
        case SJSQLite3RelationEqual:
            [conds appendFormat:@"= '%@'", sj_sqlite3_obj_filter_obj_value(value)];
            break;
        case SJSQLite3RelationGreaterThanOrEqual:
            [conds appendFormat:@">= '%@'", sj_sqlite3_obj_filter_obj_value(value)];
            break;
        case SJSQLite3RelationUnequal:
            [conds appendFormat:@"!= '%@'", sj_sqlite3_obj_filter_obj_value(value)];
            break;
        case SJSQLite3RelationLessThan:
            [conds appendFormat:@"> '%@'", sj_sqlite3_obj_filter_obj_value(value)];
            break;
        case SJSQLite3RelationGreaterThan:
            [conds appendFormat:@"< '%@'", sj_sqlite3_obj_filter_obj_value(value)];
            break;
    }
    return [[SJSQLite3Condition alloc] initWithCondition:conds];
}

/// IN操作符 指定一组值, 匹配其中的任意值
///
/// @param  column          指定比较的列名.
///
/// @param  values          指定一组值, 匹配其中的任意值.
///
/// \code
/// // 例如查询`price = 12.0 或 price = 9.0`的商品, 创建条件如下:
/// SJSQLite3Condition *cond =[SJSQLite3Condition conditionWithColumn:@"price" in:@[@(12.0), @(9.0)]];
/// NSArray *results = [SJSQLite3.shared objectsForClass:Product.class conditions:@[cond] orderBy:nil error:NULL];
/// \endcode
///
+ (instancetype)conditionWithColumn:(NSString *)column in:(NSArray *)values {
//    WHERE prod_price IN (3.49, 5);
    NSMutableString *conds = NSMutableString.new;
    [conds appendFormat:@"\"%@\" IN (", column];
    id last = values.lastObject;
    for ( id value in values ) {
        [conds appendFormat:@"'%@'%@", sj_sqlite3_obj_filter_obj_value(value), last!=value?@",":@""];
    }
    [conds appendString:@")"];
    return [[SJSQLite3Condition alloc] initWithCondition:conds];
}

/// BETWEEN操作符 用来匹配某个范围的值
///
/// @param  column          指定比较的列名.
///
/// @param  start           范围的开始
///
/// @param  end             范围的结束
///
/// \code
/// // 例如查询`3.49 和 5.0 之间`的商品, 创建条件如下:
/// SJSQLite3Condition *cond =[SJSQLite3Condition conditionWithColumn:@"price" between:@(3.49) and:@(5.0)];
/// NSArray *results = [SJSQLite3.shared objectsForClass:Product.class conditions:@[cond] orderBy:nil error:NULL];
/// \endcode
///
+ (instancetype)conditionWithColumn:(NSString *)column between:(id)start and:(id)end {
//    WHERE prod_price BETWEEN 3.49 AND 5;
    NSMutableString *conds = NSMutableString.new;
    [conds appendFormat:@"(\"%@\" BETWEEN ", column];
    [conds appendFormat:@"%@", sj_sqlite3_obj_filter_obj_value(start)];
    [conds appendString:@" AND "];
    [conds appendFormat:@"%@", sj_sqlite3_obj_filter_obj_value(end)];
    [conds appendFormat:@")"];
    return [[SJSQLite3Condition alloc] initWithCondition:conds];
}

/// 空值匹配
///
/// @param  column          指定比较的列名.
///
+ (instancetype)conditionWithIsNullColumn:(NSString *)column {
//    WHERE prod_desc IS NULL;
    return [[SJSQLite3Condition alloc] initWithCondition:[NSString stringWithFormat:@"%@ IS NULL", column]];
}
/// 自定义查询条件
///
/// 例如 进行模糊查询:
///
///    name LIKE '200%'     查找以 200 开头的任意值
///
///    name LIKE '%200%'    查找任意位置包含 200 的任意值
///
///    name LIKE '_00%'     查找第二位和第三位为 00 的任意值
///
///    name LIKE '2_%_%'    查找以 2 开头，且长度至少为 3 个字符的任意值
///
///    name LIKE '%2'       查找以 2 结尾的任意值
///
///    name LIKE '_2%3'     查找第二位为 2，且以 3 结尾的任意值
///
///    name LIKE '2___3'    查找长度为 5 位数，且以 2 开头以 3 结尾的任意值
///
- (instancetype)initWithCondition:(NSString *)condition {
    self = [super init];
    if ( self ) {
        _condition = condition.copy;
    }
    return self;
}
@end

@implementation SJSQLite3ColumnOrder
/// 排序数据
///
/// @param  column          依据此列进行排序
///
/// @param  ascending       指定排序方向. (升序 == YES `A->Z`, 降序 == NO `Z->A`)
///
+ (instancetype)orderWithColumn:(NSString *)column ascending:(BOOL)ascending {
    return [[self alloc] initWithColumn:column ascending:ascending];
}

- (instancetype)initWithColumn:(NSString *)column ascending:(BOOL)ascending {
    self = [super init];
    if ( !self ) return nil;
    _order = [NSString stringWithFormat:@"\"%@\" %@", column, ascending?@"ASC":@"DESC"];
    return self;
}
@end
NS_ASSUME_NONNULL_END
