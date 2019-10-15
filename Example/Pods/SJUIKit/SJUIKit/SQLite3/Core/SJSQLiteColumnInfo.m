//
//  SJSQLiteColumnInfo.m
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/26.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLiteColumnInfo.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJSQLiteColumnInfo
- (NSString *)description {
    return [NSString stringWithFormat:@"SJSQLiteColumnInfo:<%p> { name: %@, type: %@, constraints: %@ };", self, _name, _type, _constraints];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return self;
}
@end
NS_ASSUME_NONNULL_END
