//
//  SJSQLite3+TableExtended.m
//  AFNetworking
//
//  Created by BlueDancer on 2020/5/16.
//

#import "SJSQLite3+TableExtended.h"
#import "SJSQLite3+Private.h"

@implementation SJSQLite3 (TableExtended)
/// 查询表中是否包含某列
///
/// @param column          指定列名.
///
/// @param cls             数据库表所对应的类. (该类必须实现`SJSQLiteTableModelProtocol.sql_primaryKey`)
///
- (BOOL)containsColumn:(NSString *)column inTableForClass:(Class)cls {
    SJSQLiteTableInfo *tableInfo = [self tableInfoForClass:cls error:NULL];
    if ( tableInfo == nil ) return NO;
    
    NSError *error = nil;
    __auto_type result = [self exec:[NSString stringWithFormat:@"PRAGMA table_info('%@');", tableInfo.name] error:&error];
    if ( error != nil ) return NO;
    
    BOOL contains = NO;
    for ( SJSQLite3RowData *row in result ) {
        if ( [row[@"name"] isEqualToString:column] ) {
            contains = YES;
            break;
        }
    }
    return contains;
}
@end
