//
//  SJSQLite3Condition.h
//  AFNetworking
//
//  Created by 畅三江 on 2019/7/26.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
+ (instancetype)conditionWithColumn:(NSString *)column notIn:(NSArray *)values;
+ (instancetype)conditionWithColumn:(NSString *)column between:(id)start and:(id)end;
+ (instancetype)conditionWithColumn:(NSString *)column like:(NSString *)like;
+ (instancetype)conditionWithIsNullColumn:(NSString *)column;
- (instancetype)initWithCondition:(NSString *)condition;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@property (nonatomic, copy, readonly) NSString *condition;
@end

NS_ASSUME_NONNULL_END
