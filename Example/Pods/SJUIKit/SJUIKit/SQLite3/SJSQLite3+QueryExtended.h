//
//  SJSQLite3+QueryExtended.h
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//
//  这里将会是对 SJSQLite3 的扩展.
//

#import "SJSQLite3.h"
@class SJSQLite3ColumnOrder, SJSQLite3Condition;


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

#pragma mark -

typedef enum : NSInteger {
    SJSQLite3RelationLessThanOrEqual = -1,
    SJSQLite3RelationEqual,
    SJSQLite3RelationGreaterThanOrEqual,
    SJSQLite3RelationUnequal,
    
    SJSQLite3RelationLessThan,
    SJSQLite3RelationGreaterThan,
} SJSQLite3Relation;

/// WHERE
///
@interface SJSQLite3Condition : NSObject
+ (instancetype)conditionWithColumn:(NSString *)column relatedBy:(SJSQLite3Relation)relation value:(id)value;
+ (instancetype)conditionWithColumn:(NSString *)column value:(id)value; ///< `relation == SJSQLite3RelationEqual`
+ (instancetype)conditionWithColumn:(NSString *)column in:(NSArray *)values;
+ (instancetype)conditionWithColumn:(NSString *)column between:(id)start and:(id)end;
+ (instancetype)conditionWithIsNullColumn:(NSString *)column;
- (instancetype)initWithCondition:(NSString *)condition;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@property (nonatomic, copy, readonly) NSString *condition;
@end

/// ORDER BY
///
@interface SJSQLite3ColumnOrder : NSObject
+ (instancetype)orderWithColumn:(NSString *)column ascending:(BOOL)ascending;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@property (nonatomic, copy, readonly) NSString *order;
@end
NS_ASSUME_NONNULL_END
