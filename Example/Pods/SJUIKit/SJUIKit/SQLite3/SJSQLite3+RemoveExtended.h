//
//  SJSQLite3+RemoveExtended.h
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/30.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLite3.h"
#import "SJSQLite3+QueryExtended.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJSQLite3 (RemoveExtended)

- (void)removeAllObjectsForClass:(Class)cls conditions:(nullable NSArray<SJSQLite3Condition *> *)conditions error:(NSError *__autoreleasing  _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
