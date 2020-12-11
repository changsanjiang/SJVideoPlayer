//
//  SJSQLiteObjectInfo.h
//  Pods
//
//  Created by 畅三江 on 2019/7/30.
//

#import <Foundation/Foundation.h>
#import "SJSQLiteTableInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJSQLiteObjectInfo : NSObject
+ (nullable instancetype)objectInfoWithObject:(id)obj tableInfo:(SJSQLiteTableInfo *)tableInfo;

@property (nonatomic, strong, readonly) id obj;
@property (nonatomic, strong, readonly) SJSQLiteTableInfo *table;
@property (nonatomic, strong, readonly) SJSQLiteColumnInfo *primaryKeyColumnInfo;
@property (nonatomic, copy, readonly, nullable) NSArray<SJSQLiteColumnInfo *> *autoincrementColumns;
@end

@interface SJSQLiteColumnInfo (SJSQLiteObjectInfoExtended)
///
/// \code
/// @interface Account : NSObject
/// @property (nonatomic, strong) User *user; // associated Object
/// @end
/// \endcode
///
@property (nonatomic, strong, readonly, nullable) NSArray<SJSQLiteObjectInfo *> *associatedObjectInfos;
@end
NS_ASSUME_NONNULL_END
