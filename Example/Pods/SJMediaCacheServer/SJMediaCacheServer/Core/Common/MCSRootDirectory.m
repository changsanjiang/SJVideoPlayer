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
static NSString *mcs_path;
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mcs_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"com.SJMediaCacheServer.cache"];
        if ( ![NSFileManager.defaultManager fileExistsAtPath:mcs_path] ) {
            [NSFileManager.defaultManager createDirectoryAtPath:mcs_path withIntermediateDirectories:YES attributes:nil error:NULL];
            const char *filePath = [mcs_path fileSystemRepresentation];
            const char *attrName = "com.apple.MobileBackup";
            u_int8_t attrValue = 1;
            setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        }
    });
}

+ (NSString *)path {
    return mcs_path;
}

+ (unsigned long long)size {
    return [NSFileManager.defaultManager mcs_directorySizeAtPath:mcs_path];
}

+ (NSString *)assetPathForFilename:(NSString *)filename {
    return [mcs_path stringByAppendingPathComponent:filename];
}

+ (NSString *)databasePath {
    return [mcs_path stringByAppendingPathComponent:@"mcs.db"];
}
@end
