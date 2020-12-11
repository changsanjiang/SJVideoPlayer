//
//  NSFileManager+MCS.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/26.
//

#import "NSFileManager+MCS.h"

@implementation NSFileManager (MCS)

- (unsigned long long)mcs_fileSizeAtPath:(NSString *)path {
    return [NSFileManager.defaultManager attributesOfItemAtPath:path error:NULL].fileSize;
}

- (unsigned long long)mcs_directorySizeAtPath:(NSString *)path {
    NSUInteger size = 0;
    for ( NSString *subpath in [NSFileManager.defaultManager subpathsAtPath:path] )
        size += [self mcs_fileSizeAtPath:[path stringByAppendingPathComponent:subpath]];
    return size;
}

- (unsigned long long)mcs_freeDiskSpace {
    return [[self attributesOfFileSystemForPath:NSHomeDirectory() error:NULL][NSFileSystemFreeSize] unsignedLongLongValue];
}

@end
