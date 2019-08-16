//
//  SJSQLite3.h
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLiteCore.h"
#import "SJSQLiteTableModelProtocol.h"
#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJSQLite3 : NSObject
+ (instancetype)shared;
- (nullable instancetype)initWithDatabasePath:(NSString *)dbPath NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

// 更多扩展方法, 请前往文件`SJSQLite3+SJSQLite3Extended.h`

- (BOOL)save:(id)object error:(NSError **)error;
- (BOOL)saveObjects:(NSArray *)objsArray error:(NSError **)error;

- (nullable id)objectForClass:(Class)cls primaryKeyValue:(NSInteger)value error:(NSError **)error;

- (void)removeAllObjectsForClass:(Class)cls error:(NSError **)error;
- (void)removeObjectsForClass:(Class)cls primaryKeyValues:(NSArray<NSNumber *> *)values error:(NSError **)error;
- (void)removeObjectForClass:(Class)cls primaryKeyValue:(NSInteger)value error:(NSError **)error;
@end


@interface SJSQLite3 (Core)
typedef NSDictionary SJSQLite3RowData;
- (nullable NSArray<SJSQLite3RowData *> *)exec:(NSString *)sql error:(NSError **)error;
- (nullable NSArray<SJSQLite3RowData *> *)execInTransaction:(NSString *)sql error:(NSError **)error;
- (nullable NSArray *)objectsForClass:(Class)cls rowDatas:(NSArray<SJSQLite3RowData *> *)rowDatas error:(NSError **)error;
@end
NS_ASSUME_NONNULL_END
