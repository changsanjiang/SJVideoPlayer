//
//  MCSFileManager.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCSAssetContent.h"

NS_ASSUME_NONNULL_BEGIN
typedef NSString *MCSFileExtension;

UIKIT_EXTERN MCSFileExtension const HLSFileExtensionIndex;
UIKIT_EXTERN MCSFileExtension const HLSFileExtensionTS;
UIKIT_EXTERN MCSFileExtension const HLSFileExtensionAESKey;

@interface MCSFileManager : NSObject
+ (void)lockWithBlock:(void(^)(void))block;
+ (NSString *)rootDirectoryPath;
+ (NSString *)databasePath;
+ (NSString *)getAssetPathWithName:(NSString *)name;
+ (NSString *)getFilePathWithName:(NSString *)name inAsset:(NSString *)assetName;
+ (nullable NSArray<MCSAssetContent *> *)getContentsInAsset:(NSString *)assetName;
@end


@interface MCSFileManager (FILE)
//      注意: 返回文件名
+ (nullable NSString *)FILE_createContentFileInAsset:(NSString *)assetName atOffset:(NSUInteger)offset pathExtension:(nullable NSString *)pathExtension;

+ (NSUInteger)FILE_offsetOfContent:(NSString *)contentFilename;
@end


@interface MCSFileManager (HLS_Index)
+ (NSString *)HLS_indexFilePathInAsset:(NSString *)assetName;
@end


@interface MCSFileManager (HLS_AESKey)

+ (NSString *)HLS_AESKeyFilePathInAsset:(NSString *)assetName AESKeyName:(NSString *)AESKeyName;

@end


@interface MCSFileManager (HLS_TS)
//      注意: 返回文件名
+ (nullable NSString *)HLS_createContentFileInAsset:(NSString *)assetName tsName:(NSString *)tsName tsTotalLength:(NSUInteger)length;

+ (nullable NSString *)HLS_TsNameOfContent:(NSString *)contentFilename;

+ (NSUInteger)HLS_TsTotalLengthOfContent:(NSString *)contentFilename;

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

+ (BOOL)checkoutAssetWithName:(NSString *)name error:(NSError **)error;
+ (BOOL)removeAssetWithName:(NSString *)name error:(NSError **)error;
+ (BOOL)removeContentWithName:(NSString *)name inAsset:(NSString *)assetName error:(NSError **)error;
@end
NS_ASSUME_NONNULL_END
