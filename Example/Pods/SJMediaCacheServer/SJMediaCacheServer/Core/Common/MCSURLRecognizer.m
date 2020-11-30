//
//  MCSURLRecognizer.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSURLRecognizer.h"
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
    NSString *name = self.lastPathComponent;
    NSRange range = [name rangeOfString:@"?"];
    if ( range.location != NSNotFound ) {
        name = [name substringToIndex:range.location];
    }
    return name;
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


@implementation MCSURLRecognizer
+ (instancetype)shared {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSURL *)proxyURLWithURL:(NSURL *)URL {
    NSParameterAssert(_server);
    
    NSURL *serverURL = _server.serverURL;
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
    NSParameterAssert(URL.host);
    
    NSString *url = URL.absoluteString;
    
    // 判断是否为代理URL
    if ( [URL.host isEqualToString:_server.serverURL.host] ) {
        // 包含 mcsproxy 为 HLS 内部资源的请求, 此处返回path后面资源的名字
        NSRange range = [url rangeOfString:mcsproxy];
        if ( range.location != NSNotFound ) {
            // format: mcsproxy/asset/name.extension?url=base64EncodedUrl
            return [[url substringFromIndex:NSMaxRange(range) + 1] componentsSeparatedByString:@"/"].firstObject;
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

- (NSString *)nameWithUrl:(NSString *)url suffix:(NSString *)suffix {
    NSString *filename = url.mcs_fname;
    // 添加扩展名
    if ( ![filename hasSuffix:suffix] )
        filename = [filename stringByAppendingString:suffix];
    return filename;
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

@implementation MCSURLRecognizer (HLS)
- (NSURL *)proxyURLWithTsURI:(NSString *)TsURI {
    return [NSURL URLWithString:[_server.serverURL.absoluteString stringByAppendingFormat:@"/%@", TsURI]];
}

- (NSString *)proxyTsURIWithUrl:(NSString *)url inAsset:(NSString *)asset {
    NSParameterAssert(asset);
    
    // format: mcsproxy/asset/tsName.ts?url=base64EncodedUrl
    return [self _proxyURIWithUrl:url inAsset:asset suffix:HLS_SUFFIX_TS];
}

- (NSString *)proxyAESKeyURIWithUrl:(NSString *)url inAsset:(NSString *)asset {
    // format: mcsproxy/asset/AESName.key?url=base64EncodedUrl
    return [self _proxyURIWithUrl:url inAsset:asset suffix:HLS_SUFFIX_AES_KEY];
}

// format: mcsproxy/asset/name.extension?url=base64EncodedUrl
- (NSString *)_proxyURIWithUrl:(NSString *)url inAsset:(NSString *)asset suffix:(NSString *)suffix {
    NSString *fname = [self nameWithUrl:url suffix:suffix];
    NSURLQueryItem *query = [self encodedURLQueryItemWithUrl:url];
    NSString *URI = [NSString stringWithFormat:@"%@/%@/%@?%@=%@", mcsproxy, asset, fname, query.name, query.value];
    return URI;
}
@end
