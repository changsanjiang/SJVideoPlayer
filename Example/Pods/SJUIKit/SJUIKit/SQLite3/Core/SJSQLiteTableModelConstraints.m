//
//  SJSQLiteTableModelConstraints.m
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/26.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLiteTableModelConstraints.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJSQLiteTableModelConstraints
static SEL sel_sql_blacklist;
static SEL sel_sql_whitelist;
static SEL sel_sql_customKeyMapper;
static SEL sel_sql_uniquelist;
static SEL sel_sql_arrayPropertyGenericClass;
static SEL sel_sql_autoincrementlist;
static SEL sel_sql_primaryKey;
static SEL sel_sql_notnulllist;
static SEL sel_sql_tableName;

- (instancetype)initWithClass:(Class<SJSQLiteTableModelProtocol>)cls {
    self = [super init];
    if ( self ) {
        
        static NSArray<NSString *> *objc_sysProperties;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            objc_sysProperties = @[@"hash", @"debugDescription", @"description"];
            sel_sql_blacklist = @selector(sql_blacklist);
            sel_sql_whitelist = @selector(sql_whitelist);
            sel_sql_customKeyMapper = @selector(sql_customKeyMapper);
            sel_sql_uniquelist = @selector(sql_uniquelist);
            sel_sql_arrayPropertyGenericClass = @selector(sql_arrayPropertyGenericClass);
            sel_sql_autoincrementlist = @selector(sql_autoincrementlist);
            sel_sql_primaryKey = @selector(sql_primaryKey);
            sel_sql_notnulllist = @selector(sql_notnulllist);
            sel_sql_tableName = @selector(sql_tableName);
        });
        
        _objc_sysProperties = objc_sysProperties;
        
        Class metaClass = (Class)object_getClass(cls);
        
        if ( class_respondsToSelector(metaClass, sel_sql_blacklist) ) {
            IMP func = class_getMethodImplementation(metaClass, sel_sql_blacklist);
            _sql_blacklist = ((id(*)(id, SEL))func)(cls, sel_sql_blacklist);
        }
        
        if ( class_respondsToSelector(metaClass, sel_sql_whitelist) ) {
            IMP func = class_getMethodImplementation(metaClass, sel_sql_whitelist);
            _sql_whitelist = ((id(*)(id, SEL))func)(cls, sel_sql_whitelist);
        }
        
        if ( class_respondsToSelector(metaClass, sel_sql_customKeyMapper) ) {
            IMP func = class_getMethodImplementation(metaClass, sel_sql_customKeyMapper);
            _sql_customKeyMapper = ((id(*)(id, SEL))func)(cls, sel_sql_customKeyMapper);
        }
        
        if ( class_respondsToSelector(metaClass, sel_sql_uniquelist) ) {
            IMP func = class_getMethodImplementation(metaClass, sel_sql_uniquelist);
            _sql_uniquelist = ((id(*)(id, SEL))func)(cls, sel_sql_uniquelist);
        }
        
        if ( class_respondsToSelector(metaClass, sel_sql_arrayPropertyGenericClass) ) {
            IMP func = class_getMethodImplementation(metaClass, sel_sql_arrayPropertyGenericClass);
            _sql_arrayPropertyGenericClass = ((id(*)(id, SEL))func)(cls, sel_sql_arrayPropertyGenericClass);
        }
        
        if ( class_respondsToSelector(metaClass, sel_sql_autoincrementlist) ) {
            IMP func = class_getMethodImplementation(metaClass, sel_sql_autoincrementlist);
            _sql_autoincrementlist = ((id(*)(id, SEL))func)(cls, sel_sql_autoincrementlist);
        }
        
        if ( class_respondsToSelector(metaClass, sel_sql_primaryKey) ) {
            IMP func = class_getMethodImplementation(metaClass, sel_sql_primaryKey);
            _sql_primaryKey = ((id(*)(id, SEL))func)(cls, sel_sql_primaryKey);
        }
        
        if ( class_respondsToSelector(metaClass, sel_sql_notnulllist) ) {
            IMP func = class_getMethodImplementation(metaClass, sel_sql_notnulllist);
            _sql_notnulllist = ((id(*)(id, SEL))func)(cls, sel_sql_notnulllist);
        }
        
        if ( class_respondsToSelector(metaClass, sel_sql_tableName) ) {
            IMP func = class_getMethodImplementation(metaClass, sel_sql_tableName);
            _sql_tableName = ((id(*)(id, SEL))func)(cls, sel_sql_tableName);
        }
    }
    return self;
}
@end
NS_ASSUME_NONNULL_END
