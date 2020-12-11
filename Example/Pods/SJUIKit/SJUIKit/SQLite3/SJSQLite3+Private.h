//
//  SJSQLite3+Private.h
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLite3.h"
#import "SJSQLite3TableClassCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJSQLite3 (Core)
typedef NSDictionary SJSQLite3RowData;
- (nullable NSArray<SJSQLite3RowData *> *)exec:(NSString *)sql error:(NSError **)error;
- (nullable NSArray<SJSQLite3RowData *> *)execInTransaction:(NSString *)sql error:(NSError **)error;
- (void)execInTransaction:(BOOL(^)(SJSQLite3 *sqlite3))block;
- (nullable NSArray *)objectsForClass:(Class)cls rowDatas:(NSArray<SJSQLite3RowData *> *)rowDatas error:(NSError **)error;

#pragma mark -
- (nullable SJSQLiteTableInfo *)tableInfoForClass:(Class)cls error:(NSError **)error;
- (nullable SJSQLiteObjectInfo *)objectInfoWithObject:(id)object error:(NSError **)error;
- (BOOL)containsTableForClass:(Class)cls;
@end

NS_ASSUME_NONNULL_END
