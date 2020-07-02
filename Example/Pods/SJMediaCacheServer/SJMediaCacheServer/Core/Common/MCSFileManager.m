//
//  MCSFileManager.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSFileManager.h"
#import <sys/xattr.h>

MCSFileExtension const MCSHLSIndexFileExtension = @".m3u8";
MCSFileExtension const MCSHLSTsFileExtension = @".ts";
MCSFileExtension const MCSHLSAESKeyFileExtension = @".key";

@implementation MCSFileManager
static dispatch_semaphore_t _semaphore;
static NSString *VODPrefix = @"vod";
static NSString *HLSPrefix = @"hls";

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _semaphore = dispatch_semaphore_create(1);
    });
}

+ (void)lock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

+ (void)unlock {
    dispatch_semaphore_signal(_semaphore);
}

+ (NSString *)rootDirectoryPath {
    static NSString *rootDirectoryPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rootDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"com.SJMediaCacheServer.cache"];
        if ( ![NSFileManager.defaultManager fileExistsAtPath:rootDirectoryPath] ) {
            [NSFileManager.defaultManager createDirectoryAtPath:rootDirectoryPath withIntermediateDirectories:YES attributes:nil error:NULL];
            const char *filePath = [rootDirectoryPath fileSystemRepresentation];
            const char *attrName = "com.apple.MobileBackup";
            u_int8_t attrValue = 1;
            setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        }
    });
    return rootDirectoryPath;
}

+ (NSString *)databasePath {
    return [[self rootDirectoryPath] stringByAppendingPathComponent:@"cache.db"];
}

+ (NSString *)getResourcePathWithName:(NSString *)name {
    return [[self rootDirectoryPath] stringByAppendingPathComponent:name];
}

+ (NSString *)getFilePathWithName:(NSString *)name inResource:(NSString *)resourceName {
    return [[self getResourcePathWithName:resourceName] stringByAppendingPathComponent:name];
}
   
+ (nullable NSArray<MCSResourcePartialContent *> *)getContentsInResource:(NSString *)resourceName {
    NSString *resourcePath = [self getResourcePathWithName:resourceName];
    NSMutableArray *m = NSMutableArray.array;
    [[NSFileManager.defaultManager contentsOfDirectoryAtPath:resourcePath error:NULL] enumerateObjectsUsingBlock:^(NSString * _Nonnull filename, NSUInteger idx, BOOL * _Nonnull stop) {
        // VOD
        if      ( [filename hasPrefix:VODPrefix] ) {
            NSString *path = [resourcePath stringByAppendingPathComponent:filename];
            NSUInteger offset = [self vod_offsetOfContent:filename];
            NSUInteger length = [self fileSizeAtPath:path];
            __auto_type content = [MCSResourcePartialContent.alloc initWithFilename:filename offset:offset length:length];
            [m addObject:content];
        }
        // HLS
        else if ( [filename hasPrefix:HLSPrefix] ) {
            NSString *path = [resourcePath stringByAppendingPathComponent:filename];
            if      ( [filename containsString:MCSHLSTsFileExtension] ) {
                NSString *TsName = [self hls_TsNameOfContent:filename];
                NSUInteger totalLength = [self hls_TsTotalLengthOfContent:filename];
                NSUInteger length = [self fileSizeAtPath:path];
                __auto_type content = [MCSResourcePartialContent.alloc initWithFilename:filename tsName:TsName  tsTotalLength:totalLength length:length];
                [m addObject:content];
            }
            else if ( [filename containsString:MCSHLSAESKeyFileExtension] ) {
                NSString *AESKeyName = [self hls_AESKeyNameOfContent:filename];
                NSUInteger totalLength = [self hls_AESKeyTotalLengthOfContent:filename];
                NSUInteger length = [self fileSizeAtPath:path];
                __auto_type content = [MCSResourcePartialContent.alloc initWithFilename:filename AESKeyName:AESKeyName AESKeyTotalLength:totalLength length:length];
                [m addObject:content];
            }
        }
    }];
    return m;
}

@end


#pragma mark -


@implementation MCSFileManager (VOD)

// VOD
//      注意: 返回文件名
+ (nullable NSString *)vod_createContentFileInResource:(NSString *)resourceName atOffset:(NSUInteger)offset pathExtension:(nullable NSString *)pathExtension {
    [self lock];
    @try {
        NSUInteger sequence = 0;
        while (true) {
            // VOD前缀_偏移量_序号.扩展名
            NSString *filename = [NSString stringWithFormat:@"%@_%lu_%lu", VODPrefix, (unsigned long)offset, (unsigned long)sequence++];
            if ( pathExtension.length != 0 ) filename = [filename stringByAppendingPathExtension:pathExtension];
            NSString *filepath = [self getFilePathWithName:filename inResource:resourceName];
            if ( ![NSFileManager.defaultManager fileExistsAtPath:filepath] ) {
                [NSFileManager.defaultManager createFileAtPath:filepath contents:nil attributes:nil];
                return filename;
            }
        }
        return nil;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

// format: VOD前缀_偏移量_序号.扩展名
+ (NSUInteger)vod_offsetOfContent:(NSString *)contentFilename {
    return (NSUInteger)[[contentFilename componentsSeparatedByString:@"_"][1] longLongValue];
}
@end

#pragma mark -

@implementation MCSFileManager (HLS_Index)

+ (nullable NSString *)hls_indexFilePathInResource:(NSString *)resourceName {
    NSString *filename = @"index.m3u8";
    return [self getFilePathWithName:filename inResource:resourceName];
}

@end


#pragma mark -

@implementation MCSFileManager (HLS_AESKey)
+ (nullable NSString *)hls_createContentFileInResource:(NSString *)resourceName AESKeyName:(NSString *)AESKeyName totalLength:(NSUInteger)totalLength {
    [self lock];
    @try {
        NSUInteger sequence = 0;
        while (true) {
            // format: HLS前缀_长度_序号_AESKeyName
            //
            NSString *filename = [NSString stringWithFormat:@"%@_%lu_%lu_%@", HLSPrefix, (unsigned long)totalLength, (unsigned long)sequence++, AESKeyName];
            NSString *filepath = [self getFilePathWithName:filename inResource:resourceName];
            if ( ![NSFileManager.defaultManager fileExistsAtPath:filepath] ) {
                [NSFileManager.defaultManager createFileAtPath:filepath contents:nil attributes:nil];
                return filename;
            }
        }
        return nil;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

// HLS前缀_长度_序号_AESKeyName
+ (nullable NSString *)hls_AESKeyNameOfContent:(NSString *)contentFilename {
    return [contentFilename componentsSeparatedByString:@"_"].lastObject;
}

// HLS前缀_长度_序号_AESKeyName
+ (NSUInteger)hls_AESKeyTotalLengthOfContent:(NSString *)contentFilename {
    return (NSUInteger)[[contentFilename componentsSeparatedByString:@"_"][1] longLongValue];
}

@end

@implementation MCSFileManager (HLS_TS)
//      注意: 返回文件名
+ (nullable NSString *)hls_createContentFileInResource:(NSString *)resourceName tsName:(NSString *)tsName tsTotalLength:(NSUInteger)length {
    [self lock];
    @try {
        NSUInteger sequence = 0;
        while (true) {
            // format: HLS前缀_长度_序号_tsName
            //
            NSString *filename = [NSString stringWithFormat:@"%@_%lu_%lu_%@", HLSPrefix, (unsigned long)length, (unsigned long)sequence++, tsName];
            NSString *filepath = [self getFilePathWithName:filename inResource:resourceName];
            if ( ![NSFileManager.defaultManager fileExistsAtPath:filepath] ) {
                [NSFileManager.defaultManager createFileAtPath:filepath contents:nil attributes:nil];
                return filename;
            }
        }
        return nil;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

// format: HLS前缀_长度_序号_tsName
+ (nullable NSString *)hls_TsNameOfContent:(NSString *)contentFilename {
    return [contentFilename componentsSeparatedByString:@"_"].lastObject;
}

// format: HLS前缀_长度_序号_tsName
+ (NSUInteger)hls_TsTotalLengthOfContent:(NSString *)contentFilename {
    return (NSUInteger)[[contentFilename componentsSeparatedByString:@"_"][1] longLongValue];
}

@end

#pragma mark -


@implementation MCSFileManager (FileSize)
+ (NSUInteger)rootDirectorySize {
    return [self directorySizeAtPath:[self rootDirectoryPath]];
}

+ (NSUInteger)systemFreeSize {
    return [[NSFileManager.defaultManager attributesOfFileSystemForPath:NSHomeDirectory() error:NULL][NSFileSystemFreeSize] unsignedLongValue];
}
 
+ (NSUInteger)directorySizeAtPath:(NSString *)path {
    NSUInteger size = 0;
    for ( NSString *subpath in [NSFileManager.defaultManager subpathsAtPath:path] )
        size += [self fileSizeAtPath:[path stringByAppendingPathComponent:subpath]];
    return size;
}

+ (NSUInteger)fileSizeAtPath:(NSString *)path {
    return (NSUInteger)[NSFileManager.defaultManager attributesOfItemAtPath:path error:NULL].fileSize;
}
@end

@implementation MCSFileManager (FileManager)
+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError *__autoreleasing  _Nullable *)error {
    return [NSFileManager.defaultManager removeItemAtPath:path error:error];
}

+ (BOOL)fileExistsAtPath:(NSString *)path {
    return [NSFileManager.defaultManager fileExistsAtPath:path];
}

+ (BOOL)checkoutResourceWithName:(NSString *)name error:(NSError **)error {
    NSString *path = [MCSFileManager getResourcePathWithName:name];
    if ( ![MCSFileManager fileExistsAtPath:path] ) {
        return [NSFileManager.defaultManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
    }
    return YES;
}

+ (BOOL)removeResourceWithName:(NSString *)name error:(NSError **)error {
    NSString *path = [MCSFileManager getResourcePathWithName:name];
    return [NSFileManager.defaultManager removeItemAtPath:path error:NULL];
}

+ (BOOL)removeContentWithName:(NSString *)name inResource:(NSString *)resourceName error:(NSError **)error {
    NSString *path = [MCSFileManager getFilePathWithName:name inResource:resourceName];
    return [self removeItemAtPath:path error:error];
}
@end
