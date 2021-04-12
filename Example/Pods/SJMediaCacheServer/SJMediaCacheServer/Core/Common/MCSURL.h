//
//  MCSURL.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSInterfaces.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSURL : NSObject
+ (instancetype)shared;

@property (nonatomic, strong, nullable) NSURL *serverURL;

@property (nonatomic, copy, nullable) NSString *(^resolveAssetIdentifier)(NSURL *URL);

- (NSURL *)proxyURLWithURL:(NSURL *)URL;
- (NSURL *)URLWithProxyURL:(NSURL *)proxyURL;

- (NSString *)assetNameForURL:(NSURL *)URL;
- (MCSAssetType)assetTypeForURL:(NSURL *)URL;
- (MCSDataType)dataTypeForProxyURL:(NSURL *)proxyURL;

- (NSString *)nameWithUrl:(NSString *)url suffix:(NSString *)suffix;

- (NSURL *)proxyURLWithRelativePath:(NSString *)path inAsset:(NSString *)assetName;
@end


@interface MCSURL (HLS)
- (NSString *)HLS_proxyURIWithURL:(NSString *)url suffix:(NSString *)suffix inAsset:(NSString *)asset;
- (NSURL *)HLS_URLWithProxyURI:(NSString *)proxyURI;
- (NSURL *)HLS_proxyURLWithProxyURI:(NSString *)uri;
@end


@interface NSURL (MCSExtended)
- (NSURL *)mcs_URLByAppendingPathComponent:(NSString *)pathComponent;
- (NSURL *)mcs_URLByDeletingLastPathComponentAndQuery;
@end
NS_ASSUME_NONNULL_END
