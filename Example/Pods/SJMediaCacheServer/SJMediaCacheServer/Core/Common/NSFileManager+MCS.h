//
//  NSFileManager+MCS.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (MCS)

- (UInt64)mcs_fileSizeAtPath:(NSString *)path;

- (UInt64)mcs_directorySizeAtPath:(NSString *)path;

- (UInt64)mcs_freeDiskSpace;

- (void)mcs_createDirectoryAtPath:(NSString *)path backupable:(BOOL)backupable;

@end

NS_ASSUME_NONNULL_END
