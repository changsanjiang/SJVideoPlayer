//
//  SJSQLiteTableModelConstraints.h
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/26.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJSQLiteTableModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJSQLiteTableModelConstraints : NSObject
- (instancetype)initWithClass:(Class<SJSQLiteTableModelProtocol>)cls NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, strong, readonly) NSArray<NSString *> *objc_sysProperties;
@property (nonatomic, strong, nullable) NSString *sql_primaryKey;
@property (nonatomic, strong, nullable) NSArray<NSString *> *sql_autoincrementlist;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, Class<SJSQLiteTableModelProtocol>> *sql_arrayPropertyGenericClass;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *sql_customKeyMapper;
@property (nonatomic, strong, nullable) NSArray<NSString *> *sql_uniquelist;
@property (nonatomic, strong, nullable) NSArray<NSString *> *sql_whitelist;
@property (nonatomic, strong, nullable) NSArray<NSString *> *sql_blacklist;
@property (nonatomic, strong, nullable) NSArray<NSString *> *sql_notnulllist;
@property (nonatomic, strong, nullable) NSString *sql_tableName;
@end
NS_ASSUME_NONNULL_END
