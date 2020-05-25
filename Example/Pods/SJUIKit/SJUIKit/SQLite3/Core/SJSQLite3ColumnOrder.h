//
//  SJSQLite3ColumnOrder.h
//  AFNetworking
//
//  Created by 畅三江 on 2019/7/26.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// ORDER BY
///
@interface SJSQLite3ColumnOrder : NSObject
+ (instancetype)orderWithColumn:(NSString *)column ascending:(BOOL)ascending;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@property (nonatomic, copy, readonly) NSString *order;
@end

NS_ASSUME_NONNULL_END
