//
//  SJSQLiteErrors.m
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//

#import "SJSQLiteErrors.h"

NS_ASSUME_NONNULL_BEGIN
NSError *
sqlite3_error_make_error(NSString *error_msg) {
    return [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"error_msg":error_msg?:@""}];
}

NSError *
sqlite3_error_get_table_failed(Class cls) {
    return sqlite3_error_make_error([NSString stringWithFormat:@"<%@>获取表信息失败, 请检查相关配置", NSStringFromClass(cls)]);
}

NSError *
sqlite3_error_get_column_failed(Class cls) {
    return sqlite3_error_make_error([NSString stringWithFormat:@"<%@>获取行信息失败, 请检查相关配置", NSStringFromClass(cls)]);
}

NSError *
sqlite3_error_invalid_parameter(void) {
    return sqlite3_error_make_error(@"无效的参数!");
}
NS_ASSUME_NONNULL_END
