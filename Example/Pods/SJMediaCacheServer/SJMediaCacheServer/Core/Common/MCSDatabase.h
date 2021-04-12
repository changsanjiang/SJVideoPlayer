//
//  MCSDatabase.h
//  SJMediaCacheServer
//
//  Created by BD on 2021/3/20.
//

#import <Foundation/Foundation.h>
#import <SJUIKit/SJSQLite3.h>
#import <SJUIKit/SJSQLite3+QueryExtended.h>
#import <SJUIKit/SJSQLite3+RemoveExtended.h>
#import <SJUIKit/SJSQLite3+Private.h>
#import <SJUIKit/SJSQLite3+FoundationExtended.h>

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT SJSQLite3 *
MCSDatabase(void);
NS_ASSUME_NONNULL_END
