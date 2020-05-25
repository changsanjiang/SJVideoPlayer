//
//  SJSQLite3ColumnOrder.m
//  AFNetworking
//
//  Created by 畅三江 on 2019/7/26.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLite3ColumnOrder.h"

@implementation SJSQLite3ColumnOrder
/// 排序数据
///
/// @param  column          依据此列进行排序
///
/// @param  ascending       指定排序方向. (升序 == YES `A->Z`, 降序 == NO `Z->A`)
///
+ (instancetype)orderWithColumn:(NSString *)column ascending:(BOOL)ascending {
    return [[self alloc] initWithColumn:column ascending:ascending];
}

/// 排序数据
///
/// @param  column          依据此列进行排序
///
/// @param  ascending       指定排序方向. (升序 == YES `A->Z`, 降序 == NO `Z->A`)
///
- (instancetype)initWithColumn:(NSString *)column ascending:(BOOL)ascending {
    self = [super init];
    if ( !self ) return nil;
    _order = [NSString stringWithFormat:@"\"%@\" %@", column, ascending?@"ASC":@"DESC"];
    return self;
}
@end
