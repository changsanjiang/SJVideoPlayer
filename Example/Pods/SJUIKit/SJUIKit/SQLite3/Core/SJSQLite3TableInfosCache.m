//
//  SJSQLite3TableInfosCache.m
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//

#import "SJSQLite3TableInfosCache.h"
#import "SJSQLiteTableInfo.h"

@implementation SJSQLite3TableInfosCache {
    NSMutableDictionary<NSString *, SJSQLiteTableInfo *> *_map;
    dispatch_semaphore_t _lock;
}
+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}
- (instancetype)init {
    self = [super init];
    if ( self ) {
        _map = NSMutableDictionary.new;
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}
- (nullable SJSQLiteTableInfo *)getTableInfoForClass:(Class)cls {
    NSString *_Nullable clsname = NSStringFromClass(cls);
    if ( clsname == nil ) {
        return nil;
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    SJSQLiteTableInfo *_Nullable tableInfo = _map[clsname];
    if ( tableInfo == nil ) {
        _map[clsname] = tableInfo = [SJSQLiteTableInfo tableInfoWithClass:cls];
    }
    dispatch_semaphore_signal(_lock);
    return tableInfo;
}
@end
