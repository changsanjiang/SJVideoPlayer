//
//  SJSQLiteErrors.h
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSError *
sqlite3_error_make_error(NSString *error_msg);

FOUNDATION_EXTERN NSError *
sqlite3_error_get_table_failed(Class cls);

FOUNDATION_EXPORT NSError *
sqlite3_error_get_column_failed(Class cls);

FOUNDATION_EXTERN NSError *
sqlite3_error_invalid_parameter(void);

NS_ASSUME_NONNULL_END
