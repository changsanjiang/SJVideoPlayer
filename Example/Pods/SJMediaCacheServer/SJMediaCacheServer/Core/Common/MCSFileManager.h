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
typedef NSString *MCSFileExtension;

UIKIT_EXTERN MCSFileExtension const MCSHLSIndexFileExtension;
UIKIT_EXTERN MCSFileExtension const MCSHLSTsFileExtension;
UIKIT_EXTERN MCSFileExtension const MCSHLSAESKeyFileExtension;

@interface MCSFileManager : NSObject
+ (void)lockWithBlock:(void(^)(void))block;
+ (NSString *)rootDirectoryPath;
+ (NSString *)databasePath;
+ (NSString *)getResourcePathWithName:(NSString *)name;
+ (NSString *)getFilePathWithName:(NSString *)name inResource:(NSString *)resourceName;
+ (nullable NSArray<MCSResourcePartialContent *> *)getContentsInResource:(NSString *)resourceName;
@end


@interface MCSFileManager (VOD)
//      注意: 返回文件名
+ (nullable NSString *)vod_createContentFileInResource:(NSString *)resourceName atOffset:(NSUInteger)offset pathExtension:(nullable NSString *)pathExtension;

+ (NSUInteger)vod_offsetOfContent:(NSString *)contentFilename;
@end


@interface MCSFileManager (HLS_Index)
+ (NSString *)hls_indexFilePathInResource:(NSString *)resourceName;
@end


@interface MCSFileManager (HLS_AESKey)

+ (NSString *)hls_AESKeyFilePathInResource:(NSString *)resourceName AESKeyName:(NSString *)AESKeyName;

@end


@interface MCSFileManager (HLS_TS)
//      注意: 返回文件名
+ (nullable NSString *)hls_createContentFileInResource:(NSString *)resourceName tsName:(NSString *)tsName tsTotalLength:(NSUInteger)length;

+ (nullable NSString *)hls_TsNameOfContent:(NSString *)contentFilename;

+ (NSUInteger)hls_TsTotalLengthOfContent:(NSString *)contentFilename;

@end

@interface MCSFileManager (FileSize)
+ (NSUInteger)rootDirectorySize;
+ (NSUInteger)systemFreeSize;

+ (NSUInteger)fileSizeAtPath:(NSString *)path;
+ (NSUInteger)directorySizeAtPath:(NSString *)path;
@end

@interface MCSFileManager (FileManager)
+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;
+ (BOOL)fileExistsAtPath:(NSString *)path;

+ (BOOL)checkoutResourceWithName:(NSString *)name error:(NSError **)error;
+ (BOOL)removeResourceWithName:(NSString *)name error:(NSError **)error;
+ (BOOL)removeContentWithName:(NSString *)name inResource:(NSString *)resourceName error:(NSError **)error;
@end
NS_ASSUME_NONNULL_END
