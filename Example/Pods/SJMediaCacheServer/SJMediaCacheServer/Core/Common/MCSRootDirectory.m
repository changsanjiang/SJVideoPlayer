//
//  MCSRootDirectory.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/26.
//

#import "MCSRootDirectory.h"
#import <sys/xattr.h>
#import "NSFileManager+MCS.h"

@implementation MCSRootDirectory
+ (NSString *)path {
    static NSString *path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"com.SJMediaCacheServer.cache"];
        if ( ![NSFileManager.defaultManager fileExistsAtPath:path] ) {
            [NSFileManager.defaultManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
            const char *filePath = [path fileSystemRepresentation];
            const char *attrName = "com.apple.MobileBackup";
            u_int8_t attrValue = 1;
            setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        }
    });
    return path;
}

+ (unsigned long long)size {
    return [NSFileManager.defaultManager mcs_directorySizeAtPath:self.path];
}

+ (NSString *)assetPathForFilename:(NSString *)filename {
    return [self.path stringByAppendingPathComponent:filename];
}

+ (NSString *)databasePath {
    return [self.path stringByAppendingPathComponent:@"mcs.db"];
}
@end
