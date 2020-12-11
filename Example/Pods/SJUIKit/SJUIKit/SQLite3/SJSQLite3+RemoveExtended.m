//
//  SJSQLite3+RemoveExtended.m
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLite3+RemoveExtended.h" 
#import "SJSQLiteErrors.h"
#import "SJSQLite3+Private.h"

@implementation SJSQLite3 (RemoveExtended)
/// 删除满足指定条件的数据. 操作不可逆, 请谨慎操作. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param cls              数据库表所对应的类. (该类必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`)
///
/// @param conditions       删除条件.
///
/// @param error            执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
- (void)removeAllObjectsForClass:(Class)cls conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions error:(NSError *__autoreleasing  _Nullable *)error {
    SJSQLiteTableInfo *_Nullable table = [self tableInfoForClass:cls error:error];
    if ( table == nil ) {
        return;
    }

    NSMutableString *where = nil;
    if ( conditions.count != 0 ) {
        where = NSMutableString.new;
        for ( SJSQLite3Condition *obj in conditions ) {
            [where appendFormat:@"%@ AND ", obj.condition];
        }
        [where sjsql_deleteSuffix:@" AND "];
    }

    NSMutableString *sql = NSMutableString.new;
    [sql appendFormat:@"DELETE FROM '%@' WHERE %@;", table.name, where];
    [self execInTransaction:sql error:error];
}
@end
