//
//  SJSQLite3+SJSQLite3Extended.h
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//
//  这里将会是对 SJSQLite3 的扩展.
//

#import "SJSQLite3.h"
@class SJSQLite3ColumnOrder, SJSQLite3Condition;


NS_ASSUME_NONNULL_BEGIN
@interface SJSQLite3 (SJSQLite3Extended)

- (nullable NSArray *)objectsForClass:(Class)cls conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders error:(NSError **)error;

- (nullable NSArray *)objectsForClass:(Class)cls conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders range:(NSRange)range error:(NSError **)error;

- (NSUInteger)countOfObjectsForClass:(Class)cls conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions error:(NSError **)error;
@end

#pragma mark -

typedef enum : NSInteger {
    SJSQLite3RelationLessThanOrEqual = -1,
    SJSQLite3RelationEqual,
    SJSQLite3RelationGreaterThanOrEqual,
    SJSQLite3RelationUnequal,
} SJSQLite3Relation;

/// WHERE
///
@interface SJSQLite3Condition : NSObject
+ (instancetype)conditionWithColumn:(NSString *)column relatedBy:(SJSQLite3Relation)relation value:(id)value;
+ (instancetype)conditionWithColumn:(NSString *)column in:(NSArray *)values;
+ (instancetype)conditionWithColumn:(NSString *)column between:(id)value1 and:(id)value2;
+ (instancetype)conditionWithIsNullColumn:(NSString *)column;
/// 可自定义查询条件, 例如:
///    name LIKE '200%'     查找以 200 开头的任意值
///    name LIKE '%200%'    查找任意位置包含 200 的任意值
///    name LIKE '_00%'     查找第二位和第三位为 00 的任意值
///    name LIKE '2_%_%'    查找以 2 开头，且长度至少为 3 个字符的任意值
///    name LIKE '%2'       查找以 2 结尾的任意值
///    name LIKE '_2%3'     查找第二位为 2，且以 3 结尾的任意值
///    name LIKE '2___3'    查找长度为 5 位数，且以 2 开头以 3 结尾的任意值
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
