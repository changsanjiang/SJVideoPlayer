//
//  MCSURLRecognizer.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSInterfaces.h"
#import "MCSProxyServer.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSURLRecognizer : NSObject
+ (instancetype)shared;

@property (nonatomic, strong, nullable) MCSProxyServer *server;

@property (nonatomic, copy, nullable) NSString *(^resolveAssetIdentifier)(NSURL *URL);

- (NSURL *)proxyURLWithURL:(NSURL *)URL;
- (NSURL *)URLWithProxyURL:(NSURL *)proxyURL;

- (NSString *)assetNameForURL:(NSURL *)URL;
- (MCSAssetType)assetTypeForURL:(NSURL *)URL;


- (NSString *)nameWithUrl:(NSString *)url suffix:(NSString *)suffix;
@end


@interface MCSURLRecognizer (HLS)
- (NSURL *)proxyURLWithTsURI:(NSString *)TsURI;
- (NSString *)proxyTsURIWithUrl:(NSString *)url inAsset:(NSString *)asset;
- (NSString *)proxyAESKeyURIWithUrl:(NSString *)url inAsset:(NSString *)asset;
@end
NS_ASSUME_NONNULL_END
