//
//  HLSAsset.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSInterfaces.h"
#import "HLSAssetParser.h"
#import "HLSAssetDefines.h"
#import "MCSReadwrite.h"

NS_ASSUME_NONNULL_BEGIN
@interface HLSAsset : MCSReadwrite<MCSAsset>
@property (nonatomic, readonly) MCSAssetType type;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) id<MCSConfiguration> configuration;
@property (nonatomic, copy, readonly, nullable) NSString *TsContentType;
@property (nonatomic, readonly) NSUInteger tsCount;
@property (nonatomic, readonly) BOOL isStored;
@property (nonatomic, strong, nullable) HLSAssetParser *parser; 

- (NSString *)indexFilepath;
- (NSString *)indexFileRelativePath;
- (NSString *)AESKeyFilepathWithURL:(NSURL *)URL;
- (nullable NSArray<id<HLSAssetTsContent>> *)TsContents;
- (nullable id<HLSAssetTsContent>)TsContentReadwriteForRequest:(NSURLRequest *)request;
- (nullable id<MCSAssetContent>)createContentReadwriteWithDataType:(MCSDataType)dataType response:(id<MCSDownloadResponse>)response;
@end
NS_ASSUME_NONNULL_END
