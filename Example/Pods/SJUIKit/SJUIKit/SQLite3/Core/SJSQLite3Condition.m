//
//  SJSQLite3Condition.m
//  AFNetworking
//
//  Created by 畅三江 on 2019/7/26.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLite3Condition.h"
#import "SJSQLiteCore.h"

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
            [conds appendFormat:@"< '%@'", sj_sqlite3_obj_filter_obj_value(value)];
            break;
        case SJSQLite3RelationGreaterThan:
            [conds appendFormat:@"> '%@'", sj_sqlite3_obj_filter_obj_value(value)];
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
    if ( values.count == 0 ) {
        return [SJSQLite3Condition.alloc initWithCondition:@""];
    }
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

/// IN操作符 指定一组值, 匹配不在其中的数据
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
+ (instancetype)conditionWithColumn:(NSString *)column notIn:(NSArray *)values {
    if ( values.count == 0 ) {
        return [SJSQLite3Condition.alloc initWithCondition:@""];
    }
    //    WHERE prod_price IN (3.49, 5);
    NSMutableString *conds = NSMutableString.new;
    [conds appendFormat:@"\"%@\" NOT IN (", column];
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

/// Like 模糊匹配
///
/// @param  column          指定比较的列名.
///
/// @param  like            搜索模式.
///
/// \code
/// // 例如 'Fish%'查询任意以Fish开头的词, 创建条件如下:
/// SJSQLite3Condition *cond =[SJSQLite3Condition conditionWithColumn:@"name" like:@"Fish%%"];
/// NSArray *results = [SJSQLite3.shared objectsForClass:Product.class conditions:@[cond] orderBy:nil error:NULL];
/// \endcode
///
+ (instancetype)conditionWithColumn:(NSString *)column like:(NSString *)like {
    return [[SJSQLite3Condition alloc] initWithCondition:[NSString stringWithFormat:@"%@ LIKE '%@'", column, like]];
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

