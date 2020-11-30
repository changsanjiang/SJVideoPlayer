//
//  NSFileManager+MCS.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (MCS)

- (unsigned long long)mcs_fileSizeAtPath:(NSString *)path;

- (unsigned long long)mcs_directorySizeAtPath:(NSString *)path;

- (unsigned long long)mcs_freeDiskSpace;
@end

NS_ASSUME_NONNULL_END
