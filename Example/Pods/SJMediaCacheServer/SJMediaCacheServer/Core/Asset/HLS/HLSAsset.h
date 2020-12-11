//
//  HLSAsset.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSInterfaces.h"
#import "HLSParser.h"
#import "HLSContentTs.h"

NS_ASSUME_NONNULL_BEGIN
@interface HLSAsset : NSObject<MCSAsset>
@property (nonatomic, readonly) MCSAssetType type;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) id<MCSConfiguration> configuration;
@property (nonatomic, copy, readonly, nullable) NSString *TsContentType;
@property (nonatomic, readonly) NSUInteger TsCount;
@property (nonatomic, readonly) BOOL isStored;
@property (nonatomic, strong, nullable) HLSParser *parser;

- (void)lock:(void(^)(void))block;
- (NSString *)indexFilePath;
- (NSString *)AESKeyFilePathWithURL:(NSURL *)URL;
- (nullable id<MCSAssetContent>)createTsContentWithResponse:(NSHTTPURLResponse *)response;
- (nullable NSArray<id<MCSAssetContent>> *)TsContents;
- (nullable NSString *)TsContentFilePathForFilename:(NSString *)filename;
- (nullable id<MCSAssetContent>)TsContentForURL:(NSURL *)URL;
@end
NS_ASSUME_NONNULL_END
