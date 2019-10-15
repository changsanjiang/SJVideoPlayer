//
//  SJSQLiteTableModelConstraints.m
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/26.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLiteTableModelConstraints.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJSQLiteTableModelConstraints
- (instancetype)initWithClass:(Class<SJSQLiteTableModelProtocol>)cls {
    self = [super init];
    if ( self ) {
        
        static NSArray<NSString *> *objc_sysProperties;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            objc_sysProperties = @[@"hash", @"debugDescription", @"description"];
        });
        
        _objc_sysProperties = objc_sysProperties;
        
        if ( [cls respondsToSelector:@selector(sql_blacklist)] ) {
            _sql_blacklist = [cls sql_blacklist];
        }
        
        if ( [cls respondsToSelector:@selector(sql_whitelist)] ) {
            _sql_whitelist = [cls sql_whitelist];
        }
        
        if ( [cls respondsToSelector:@selector(sql_customKeyMapper)] ) {
            _sql_customKeyMapper = [cls sql_customKeyMapper];
        }
        
        if ( [cls respondsToSelector:@selector(sql_uniquelist)] ) {
            _sql_uniquelist = [cls sql_uniquelist];
        }
        
        if ( [cls respondsToSelector:@selector(sql_arrayPropertyGenericClass)] ) {
            _sql_arrayPropertyGenericClass = [cls sql_arrayPropertyGenericClass];
        }
        
        if ( [cls respondsToSelector:@selector(sql_autoincrementlist)] ) {
            _sql_autoincrementlist = [cls sql_autoincrementlist];
        }
        
        if ( [cls respondsToSelector:@selector(sql_primaryKey)] ) {
            _sql_primaryKey = [cls sql_primaryKey];
        }
        
        if ( [cls respondsToSelector:@selector(sql_notnulllist)] ) {
            _sql_notnulllist = [cls sql_notnulllist];
        }
        
        if ( [cls respondsToSelector:@selector(sql_tableName)] ) {
            _sql_tableName = [cls sql_tableName];
        }
    }
    return self;
}
@end
NS_ASSUME_NONNULL_END
