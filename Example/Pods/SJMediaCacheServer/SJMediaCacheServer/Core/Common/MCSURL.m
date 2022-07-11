//
//  MCSURL.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSURL.h"
#import "MCSConsts.h"
#include <CommonCrypto/CommonCrypto.h>

static NSString * const mcsproxy = @"mcsproxy";

static inline NSString *
MCSMD5(NSString *str) {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}


@interface NSString (MCSFileManagerExtended)
- (NSString *)mcs_fname;
@end

@implementation NSString (MCSFileManagerExtended)
- (NSString *)mcs_fname {
    return MCSMD5(self);
}
@end

@interface NSURL (MCSFileManagerExtended)
- (NSString *)mcs_fname;
@end
@implementation NSURL (MCSFileManagerExtended)
- (NSString *)mcs_fname {
    return self.absoluteString.mcs_fname;
}
@end


@implementation MCSURL
+ (instancetype)shared {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSString *)proxyPath {
    return mcsproxy;
}

- (NSURL *)proxyURLWithURL:(NSURL *)URL {
    NSAssert(_serverURL != nil, @"The serverURL can't be nil!");
    
    NSURL *serverURL = _serverURL;
    if ( [URL.host isEqualToString:serverURL.host] )
        return URL;
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:serverURL resolvingAgainstBaseURL:NO];
    components.path = URL.path;
    NSString *url = [self encodeUrl:URL.absoluteString];
    [components setQuery:[NSString stringWithFormat:@"url=%@", url]];
    return components.URL;
}

- (NSURL *)URLWithProxyURL:(NSURL *)proxyURL {
    NSURLComponents *components = [NSURLComponents componentsWithURL:proxyURL resolvingAgainstBaseURL:NO];
    for ( NSURLQueryItem *query in components.queryItems ) {
        if ( [query.name isEqualToString:@"url"] ) {
            NSString *url = [self decodeUrl:query.value];
            return [NSURL URLWithString:url];
        }
    }
    return proxyURL;
}

// 此处的URL参数可能为代理URL也可能为原始URL
- (NSString *)assetNameForURL:(NSURL *)URL {
    NSAssert(_serverURL != nil, @"The serverURL can't be nil!");

    NSParameterAssert(URL.host);
    
    NSString *url = URL.absoluteString;
    
    // 判断是否为代理URL
    if ( [URL.host isEqualToString:_serverURL.host] ) {
        // 包含 mcsproxy 为 HLS 内部资源的请求, 此处返回path后面资源的名字
        if ( [url containsString:mcsproxy] ) {
            // format: mcsproxy/asset/name.extension?url=base64EncodedUrl
            return URL.path.stringByDeletingLastPathComponent.lastPathComponent;
        }
        else {
            // 不包含 mcsproxy 时, 将代理URL转换为原始的URL
            URL = [self URLWithProxyURL:URL];
            url = URL.absoluteString;
        }
    }

    NSString *str = self.resolveAssetIdentifier != nil ? self.resolveAssetIdentifier(URL) : url;
    NSParameterAssert(str);
    return MCSMD5(str);
}

- (MCSAssetType)assetTypeForURL:(NSURL *)URL {
    return [URL.path containsString:HLS_SUFFIX_INDEX] ||
           [URL.path containsString:HLS_SUFFIX_TS] ||
           [URL.path containsString:HLS_SUFFIX_AES_KEY] ? MCSAssetTypeHLS : MCSAssetTypeFILE;
}

- (MCSDataType)dataTypeForProxyURL:(NSURL *)proxyURL {
    NSString *last = proxyURL.lastPathComponent;
    if ( [last containsString:HLS_SUFFIX_INDEX] )
        return MCSDataTypeHLSPlaylist;
    
    if ( [last containsString:HLS_SUFFIX_AES_KEY] )
        return MCSDataTypeHLSAESKey;

    if ( [last containsString:HLS_SUFFIX_TS] )
        return MCSDataTypeHLSTs;
    
    return MCSDataTypeFILE;
}

- (NSString *)nameWithUrl:(NSString *)url suffix:(NSString *)suffix {
    NSString *filename = url.mcs_fname;
    // 添加扩展名
    if ( ![filename hasSuffix:suffix] )
        filename = [filename stringByAppendingString:suffix];
    return filename;
}

- (NSURL *)proxyURLWithRelativePath:(NSString *)path inAsset:(NSString *)assetName {
    // format: mcsproxy/asset/path
    return [_serverURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@", mcsproxy, assetName, path]];
}

- (NSString *)encodeUrl:(NSString *)url {
    return [[url dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}

- (NSString *)decodeUrl:(NSString *)url {
    return [NSString.alloc initWithData:[NSData.alloc initWithBase64EncodedString:url options:0] encoding:NSUTF8StringEncoding];
}

- (NSURLQueryItem *)encodedURLQueryItemWithUrl:(NSString *)url {
    return [NSURLQueryItem.alloc initWithName:@"url" value:[self encodeUrl:url]];
}

@end

@implementation MCSURL (HLS)
// format: mcsproxy/asset/name.extension?url=base64EncodedUrl
- (NSString *)HLS_proxyURIWithURL:(NSString *)url suffix:(NSString *)suffix inAsset:(NSString *)asset {
    NSString *fname = [self nameWithUrl:url suffix:suffix];
    NSURLQueryItem *query = [self encodedURLQueryItemWithUrl:url];
    NSString *URI = [NSString stringWithFormat:@"%@/%@/%@?%@=%@", mcsproxy, asset, fname, query.name, query.value];
    return URI;
}

- (NSURL *)HLS_URLWithProxyURI:(NSString *)proxyURI {
    return [self URLWithProxyURL:[NSURL URLWithString:proxyURI]];
}

- (NSURL *)HLS_proxyURLWithProxyURI:(NSString *)uri {
    NSAssert(_serverURL != nil, @"The serverURL can't be nil!");
    
    return [_serverURL mcs_URLByAppendingPathComponent:uri];
}
@end


@implementation NSURL (MCSExtended)
- (NSURL *)mcs_URLByAppendingPathComponent:(NSString *)pathComponent {
    if ( [pathComponent isEqualToString:@"/"] )
        return self;
    NSString *url = self.absoluteString;
    while ( [url hasSuffix:@"/"] ) url = [url substringToIndex:url.length - 1];
    NSString *path = pathComponent;
    while ( [path hasPrefix:@"/"] ) path = [path substringFromIndex:1];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", url, path]];
}

- (NSURL *)mcs_URLByDeletingLastPathComponentAndQuery {
    NSString *query = self.query;
    if ( query.length != 0 ) {
        NSString *absoluteString = self.absoluteString;
        NSString *url = [absoluteString substringToIndex:absoluteString.length - query.length - 1];
        return [NSURL URLWithString:url].URLByDeletingLastPathComponent;
    }
    return self.URLByDeletingLastPathComponent;
}
@end
