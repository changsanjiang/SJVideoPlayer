//
//  SJSQLite3+QueryExtended.h
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//
//  这里将会是对 SJSQLite3 的扩展.
//

#import "SJSQLite3.h"
#import "SJSQLite3Condition.h" 
#import "SJSQLite3ColumnOrder.h"

NS_ASSUME_NONNULL_BEGIN
///
/// 查询数据(返回的结果已转为对应的模型). 如需未转换的数据, 请查看分类`SJSQLite3 (SJSQLite3QueryDataExtended)`
///
@interface SJSQLite3 (QueryObjectsExtended)

- (nullable NSArray *)objectsForClass:(Class)cls conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders error:(NSError **)error;

- (nullable NSArray *)objectsForClass:(Class)cls conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders range:(NSRange)range error:(NSError **)error;

- (NSUInteger)countOfObjectsForClass:(Class)cls conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions error:(NSError **)error;
@end


///
/// 查询数据(返回的结果为字典数组, 未转换成模型). 如需转换为对应的模型, 请查看分类`SJSQLite3 (QueryExtended)`
///
@interface SJSQLite3 (QueryDataExtended)

- (nullable NSArray<NSDictionary *> *)queryDataForClass:(Class)cls resultColumns:(nullable NSArray<NSString *> *)columns conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders error:(NSError **)error;

- (nullable NSArray<NSDictionary *> *)queryDataForClass:(Class)cls resultColumns:(nullable NSArray<NSString *> *)columns conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders range:(NSRange)range error:(NSError **)error;

@end 
NS_ASSUME_NONNULL_END
