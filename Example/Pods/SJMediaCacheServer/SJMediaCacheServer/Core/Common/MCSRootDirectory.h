//
//  MCSRootDirectory.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCSRootDirectory : NSObject
@property (class, readonly) NSString *path;
@property (class, readonly) unsigned long long size;
@property (class, readonly) unsigned long long databaseSize;
+ (NSString *)assetPathForFilename:(NSString *)filename;
+ (NSString *)databasePath;
@end

NS_ASSUME_NONNULL_END
