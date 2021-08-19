//
//  HLSAssetContentProvider.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/25.
//
 
#import "HLSAssetDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLSAssetContentProvider : NSObject
- (instancetype)initWithDirectory:(NSString *)directory;

- (NSString *)indexFilepath;
- (NSString *)indexFileRelativePath;
- (NSString *)AESKeyFilepathWithName:(NSString *)AESKeyName;

- (nullable NSArray<id<HLSAssetTsContent>> *)TsContents;
- (nullable id<HLSAssetTsContent>)createTsContentWithName:(NSString *)name totalLength:(NSUInteger)totalLength;
- (nullable id<HLSAssetTsContent>)createTsContentWithName:(NSString *)name totalLength:(NSUInteger)totalLength rangeInAsset:(NSRange)range;
- (nullable NSString *)TsContentFilepath:(id<HLSAssetTsContent>)content;
- (void)removeTsContent:(id<HLSAssetTsContent>)content;
@end
NS_ASSUME_NONNULL_END
