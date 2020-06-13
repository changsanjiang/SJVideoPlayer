//
//  MCSFileManager.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCSResourcePartialContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSFileManager : NSObject
+ (NSString *)rootDirectoryPath;
+ (NSString *)databasePath;
+ (NSString *)getResourcePathWithName:(NSString *)name;
+ (NSString *)getFilePathWithName:(NSString *)name inResource:(NSString *)resourceName;
// HLS
//
+ (nullable NSString *)hls_AESKeyFilenameForURI:(NSString *)URI;

// HLS
//
+ (nullable NSString *)hls_tsNameForUrl:(NSString *)url inResource:(NSString *)resource;

// HLS
//
+ (nullable NSString *)hls_tsNameForTsProxyURL:(NSURL *)URL;

// HLS
//
+ (nullable NSString *)hls_resourceNameForTsProxyURL:(NSURL *)URL;

// HLS
//
+ (nullable NSString *)hls_indexFilePathInResource:(NSString *)resourceName;

// HLS
//
+ (nullable NSString *)hls_tsFragmentsFilePathInResource:(NSString *)resourceName;

// HLS
//
+ (nullable NSString *)hls_tsNamesFilePathInResource:(NSString *)resourceName;

// VOD
//      注意: 返回文件名
+ (nullable NSString *)createContentFileInResource:(NSString *)resourceName atOffset:(NSUInteger)offset pathExtension:(nullable NSString *)pathExtension;

// HLS
//      注意: 返回文件名
+ (nullable NSString *)hls_createContentFileInResource:(NSString *)resourceName tsName:(NSString *)tsName tsTotalLength:(NSUInteger)length;

+ (nullable NSArray<MCSResourcePartialContent *> *)getContentsInResource:(NSString *)resourceName;

@end

@interface MCSFileManager (FileSize)
+ (NSUInteger)rootDirectorySize;
+ (NSUInteger)systemFreeSize;

+ (NSUInteger)fileSizeAtPath:(NSString *)path;
+ (NSUInteger)directorySizeAtPath:(NSString *)path;
@end
NS_ASSUME_NONNULL_END
