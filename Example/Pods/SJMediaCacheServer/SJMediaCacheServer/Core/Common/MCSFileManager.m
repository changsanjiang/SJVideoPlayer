//
//  MCSFileManager.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSFileManager.h"
#import <sys/xattr.h>

static NSString *VODPrefix = @"vod";
static NSString *HLSPrefix = @"hls";

@implementation MCSFileManager
+ (NSString *)rootDirectoryPath {
    static NSString *rootDirectoryPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rootDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"com.SJMediaCacheServer.cache"];
        if ( ![[NSFileManager defaultManager] fileExistsAtPath:rootDirectoryPath] ) {
            [[NSFileManager defaultManager] createDirectoryAtPath:rootDirectoryPath withIntermediateDirectories:YES attributes:nil error:NULL];
            const char *filePath = [rootDirectoryPath fileSystemRepresentation];
            const char *attrName = "com.apple.MobileBackup";
            u_int8_t attrValue = 1;
            setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        }
    });
    return rootDirectoryPath;
}

+ (NSString *)getResourcePathWithName:(NSString *)name {
    return [[self rootDirectoryPath] stringByAppendingPathComponent:name];
}

+ (NSString *)databasePath {
    return [[self rootDirectoryPath] stringByAppendingPathComponent:@"cache.db"];
}

+ (NSString *)getFilePathWithName:(NSString *)name inResource:(NSString *)resourceName {
    return [[self getResourcePathWithName:resourceName] stringByAppendingPathComponent:name];
}
// HLS
//
+ (nullable NSString *)hls_AESKeyFilenameForURI:(NSString *)URI {
    return @"aes.key";
}

// format: resourceName_tsName
// HLS
+ (nullable NSString *)hls_tsNameForUrl:(NSString *)url inResource:(nonnull NSString *)resource {
    NSString *component = url.lastPathComponent;
    NSRange range = [component rangeOfString:@"?"];
    if ( range.location != NSNotFound ) {
        component = [component substringToIndex:range.location];
    }
    return [NSString stringWithFormat:@"%@_%@", resource, component];
}

+ (nullable NSString *)hls_tsNameForTsProxyURL:(NSURL *)URL {
    NSString *component = URL.absoluteString.lastPathComponent;
    NSRange range = [component rangeOfString:@"?"];
    if ( range.location != NSNotFound ) {
        component = [component substringToIndex:range.location];
    }
    return component;
}

// format: resourceName_tsName
// HLS
+ (nullable NSString *)hls_resourceNameForTsProxyURL:(NSURL *)URL {
    return [[self hls_tsNameForTsProxyURL:URL] componentsSeparatedByString:@"_"].firstObject;
}

+ (NSString *)hls_indexFilePathInResource:(NSString *)resourceName {
    NSString *filename = @"index.m3u8";
    return [self getFilePathWithName:filename inResource:resourceName];
}

// HLS
//
+ (nullable NSString *)hls_tsFragmentsFilePathInResource:(NSString *)resourceName {
    NSString *filename = @"fragments.plist";
    return [self getFilePathWithName:filename inResource:resourceName];
}

// HLS
//
+ (nullable NSString *)hls_tsNamesFilePathInResource:(NSString *)resourceName {
    NSString *filename = @"names.plist";
    return [self getFilePathWithName:filename inResource:resourceName];
}

// VOD
+ (NSString *)createContentFileInResource:(NSString *)resourceName atOffset:(NSUInteger)offset pathExtension:(NSString *)pathExtension {
    NSString *resourcePath = [self getResourcePathWithName:resourceName];
    [self checkoutDirectoryWithPath:resourcePath];
    
    NSUInteger sequence = 0;
    while (true) {
        // VOD前缀_偏移量_序号_扩展名
        NSString *filename = [NSString stringWithFormat:@"%@_%lu_%lu", VODPrefix, (unsigned long)offset, (unsigned long)sequence++];
        if ( pathExtension.length != 0 ) filename = [filename stringByAppendingPathExtension:pathExtension];
        NSString *filepath = [self getFilePathWithName:filename inResource:resourceName];
        if ( ![NSFileManager.defaultManager fileExistsAtPath:filepath] ) {
            [NSFileManager.defaultManager createFileAtPath:filepath contents:nil attributes:nil];
            return filename;
        }
    }
    return nil;
}

// HLS
+ (nullable NSString *)hls_createContentFileInResource:(NSString *)resourceName tsName:(NSString *)tsName tsTotalLength:(NSUInteger)length {
    NSString *resourcePath = [self getResourcePathWithName:resourceName];
    [self checkoutDirectoryWithPath:resourcePath];
    
    NSUInteger sequence = 0;
    while (true) {
        // format: HLS前缀_ts长度_序号_ts文件名
        //
        NSString *filename = [NSString stringWithFormat:@"%@_%lu_%lu_%@", HLSPrefix, (unsigned long)length, (unsigned long)sequence++, tsName];
        NSString *filepath = [self getFilePathWithName:filename inResource:resourceName];
        if ( ![NSFileManager.defaultManager fileExistsAtPath:filepath] ) {
            [NSFileManager.defaultManager createFileAtPath:filepath contents:nil attributes:nil];
            return filename;
        }
    }
    return nil;
}

+ (nullable NSArray<MCSResourcePartialContent *> *)getContentsInResource:(NSString *)resourceName {
    NSString *resourcePath = [self getResourcePathWithName:resourceName];
    NSMutableArray *m = NSMutableArray.array;
    [[NSFileManager.defaultManager contentsOfDirectoryAtPath:resourcePath error:NULL] enumerateObjectsUsingBlock:^(NSString * _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
        // VOD
        if      ( [name hasPrefix:VODPrefix] ) {
            NSString *path = [resourcePath stringByAppendingPathComponent:name];
            NSUInteger offset = [self offsetOfContent:name];
            NSUInteger length = (NSUInteger)[[NSFileManager.defaultManager attributesOfItemAtPath:path error:NULL] fileSize];
            __auto_type content = [MCSResourcePartialContent.alloc initWithName:name offset:offset length:length];
            [m addObject:content];
        }
        // HLS
        else if ( [name hasPrefix:HLSPrefix] ) {
            NSString *path = [resourcePath stringByAppendingPathComponent:name];
            NSString *tsName = [self tsNameOfContent:name];
            NSUInteger tsTotalLength = [self tsTotalLengthOfContent:name];
            NSUInteger length = (NSUInteger)[[NSFileManager.defaultManager attributesOfItemAtPath:path error:NULL] fileSize];;
            __auto_type content = [MCSResourcePartialContent.alloc initWithName:name tsName:tsName  tsTotalLength:tsTotalLength length:length];
            [m addObject:content];
        }
    }];
    return m;
}

#pragma mark -
+ (void)checkoutDirectoryWithPath:(NSString *)path {
    if ( ![NSFileManager.defaultManager fileExistsAtPath:path] ) {
        [NSFileManager.defaultManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

// format: // VOD前缀_偏移量_序号_扩展名
// VOD
+ (NSUInteger)offsetOfContent:(NSString *)name {
    return (NSUInteger)[[name componentsSeparatedByString:name][1] longLongValue];
}

// format: HLS前缀_ts长度_序号_ts文件名
// HLS
+ (NSString *)tsNameOfContent:(NSString *)name {
    NSArray<NSString *> *components = [name componentsSeparatedByString:@"_"];
    NSUInteger length = components[0].length + components[1].length + components[2].length + 3;
    return [name substringFromIndex:length];
}

// format: HLS前缀_ts长度_序号_ts文件名
// HLS
+ (NSUInteger)tsTotalLengthOfContent:(NSString *)name {
    return (NSUInteger)[[name componentsSeparatedByString:@"_"][1] longLongValue];
}
@end

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
