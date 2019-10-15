//
//  SJSQLiteTableInfo.h
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/26.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJSQLiteColumnInfo.h"
@protocol SJSQLiteTableModelProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface SJSQLiteTableInfo : NSObject
+ (nullable instancetype)tableInfoWithClass:(Class<SJSQLiteTableModelProtocol>)cls;

@property (nonatomic, readonly) Class cls;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *primaryKey;
@property (nonatomic, copy, readonly, nullable) NSArray<SJSQLiteColumnInfo *> *columns;
@property (nonatomic, copy, readonly, nullable) NSDictionary<SJSQLiteColumnInfo *, SJSQLiteTableInfo *> *columnAssociatedTableInfos;
@property (nonatomic, copy, readonly) NSSet<Class> *allClasses; // 相关的所有的类
- (nullable SJSQLiteColumnInfo *)columnInfoForProperty:(NSString *)key;
- (nullable SJSQLiteColumnInfo *)columnInfoForColumnName:(NSString *)key;
@end

@interface SJSQLiteColumnInfo (SJSQLiteTableInfoExtended)
///
/// \code
/// @interface Account : NSObject
/// @property (nonatomic, strong) User *user; // associated table
/// @end
/// \endcode
///
@property (nonatomic, strong, readonly, nullable) SJSQLiteTableInfo *associatedTableInfo;
@end
NS_ASSUME_NONNULL_END
