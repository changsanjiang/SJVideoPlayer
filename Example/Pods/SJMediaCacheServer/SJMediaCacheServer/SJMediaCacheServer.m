//
//  SJMediaCacheServer.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/5/30.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJMediaCacheServer.h"
#import "MCSProxyServer.h"
#import "MCSAssetManager.h"
#import "MCSURLRecognizer.h"
#import "MCSProxyTask.h"
#import "MCSLogger.h"
#import "MCSDownload.h"

@interface SJMediaCacheServer ()<MCSProxyServerDelegate>
@property (nonatomic, strong, readonly) MCSProxyServer *server;
@end

@implementation SJMediaCacheServer
+ (instancetype)shared {
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _server = [MCSProxyServer.alloc initWithPort:2000];
        _server.delegate = self;
        [_server start];
        
        MCSURLRecognizer.shared.server = _server;
    }
    return self;
}

- (nullable NSURL *)playbackURLWithURL:(NSURL *)URL {
    if ( URL == nil )
        return nil;
    
    if ( URL.isFileURL )
        return URL;
    
    // proxy URL
    if ( _server.isRunning ) {
        [MCSAssetManager.shared willReadAssetForURL:URL];
        return [MCSURLRecognizer.shared proxyURLWithURL:URL];
    }

    // param URL
    return URL;
}

- (void)setMaxConcurrentPrefetchCount:(NSInteger)maxConcurrentPrefetchCount {
    MCSPrefetcherManager.shared.maxConcurrentPrefetchCount = maxConcurrentPrefetchCount;
}
 
- (NSInteger)maxConcurrentPrefetchCount {
    return MCSPrefetcherManager.shared.maxConcurrentPrefetchCount;
}

- (id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL preloadSize:(NSUInteger)preloadSize {
    if ( URL == nil )
        return nil;
    return [MCSPrefetcherManager.shared prefetchWithURL:URL preloadSize:preloadSize];
}

- (id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL preloadSize:(NSUInteger)preloadSize progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock {
    if ( URL == nil )
        return nil;
    return [MCSPrefetcherManager.shared prefetchWithURL:URL preloadSize:preloadSize progress:progressBlock completed:completionBlock];
}

- (nullable id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock {
    if ( URL == nil )
        return nil;
    return [MCSPrefetcherManager.shared prefetchWithURL:URL progress:progressBlock completed:completionBlock];
}

- (void)cancelAllPrefetchTasks {
    [MCSPrefetcherManager.shared cancelAllPrefetchTasks];
}

#pragma mark - MCSProxyServerDelegate

- (id<MCSProxyTask>)server:(MCSProxyServer *)server taskWithRequest:(NSURLRequest *)request delegate:(id<MCSProxyTaskDelegate>)delegate {
    return [MCSProxyTask.alloc initWithRequest:request delegate:delegate];
}
@end


@implementation SJMediaCacheServer (Request)

- (void)setRequestHandler:(NSMutableURLRequest * _Nullable (^)(NSMutableURLRequest * _Nonnull))requestHandler {
    MCSDownload.shared.requestHandler = requestHandler;
}
- (NSMutableURLRequest * _Nullable (^)(NSMutableURLRequest * _Nonnull))requestHandler {
    return MCSDownload.shared.requestHandler;
}

- (void)assetURL:(NSURL *)URL setValue:(nullable NSString *)value forHTTPAdditionalHeaderField:(NSString *)field ofType:(MCSDataType)type {
    if ( URL == nil )
        return;
    id<MCSAsset> asset = [MCSAssetManager.shared assetWithURL:URL];
    [asset.configuration setValue:value forHTTPAdditionalHeaderField:field ofType:type];
}
- (nullable NSDictionary *)assetURL:(NSURL *)URL HTTPAdditionalHeadersForDataRequestsOfType:(MCSDataType)type {
    if ( URL == nil )
        return nil;
    id<MCSAsset> asset = [MCSAssetManager.shared assetWithURL:URL];
    return [asset.configuration HTTPAdditionalHeadersForDataRequestsOfType:type];
}
@end



@implementation SJMediaCacheServer (Convert)
- (void)setResolveAssetIdentifier:(NSString * _Nonnull (^)(NSURL * _Nonnull))resolveAssetIdentifier {
    MCSURLRecognizer.shared.resolveAssetIdentifier = resolveAssetIdentifier;
}
- (NSString * _Nonnull (^)(NSURL * _Nonnull))resolveAssetIdentifier {
    return MCSURLRecognizer.shared.resolveAssetIdentifier;
}

- (void)setWriteDataEncoder:(NSData * _Nonnull (^)(NSURLRequest * _Nonnull, NSUInteger, NSData * _Nonnull))writeDataEncoder {
    MCSDownload.shared.dataEncoder = writeDataEncoder;
}
- (NSData * _Nonnull (^)(NSURLRequest * _Nonnull, NSUInteger, NSData * _Nonnull))writeDataEncoder {
    return MCSDownload.shared.dataEncoder;
}

- (void)setReadDataDecoder:(NSData * _Nonnull (^)(NSURLRequest * _Nonnull, NSUInteger, NSData * _Nonnull))readDataDecoder {
    MCSAssetManager.shared.readDataDecoder = readDataDecoder;
}
- (NSData * _Nonnull (^)(NSURLRequest * _Nonnull, NSUInteger, NSData * _Nonnull))readDataDecoder {
    return MCSAssetManager.shared.readDataDecoder;
}
@end


@implementation SJMediaCacheServer (Log)

- (void)setEnabledConsoleLog:(BOOL)enabledConsoleLog {
    MCSLogger.shared.enabledConsoleLog = enabledConsoleLog;
}

- (BOOL)isEnabledConsoleLog {
    return MCSLogger.shared.enabledConsoleLog;
}

- (void)setLogOptions:(MCSLogOptions)logOptions {
    MCSLogger.shared.options = logOptions;
}

- (MCSLogOptions)logOptions {
    return MCSLogger.shared.options;
}

- (void)setLogLevel:(MCSLogLevel)logLevel {
    MCSLogger.shared.level = logLevel;
}

- (MCSLogLevel)logLevel {
    return MCSLogger.shared.level;
}
@end

@implementation SJMediaCacheServer (Cache)
- (void)setCacheCountLimit:(NSUInteger)cacheCountLimit {
    MCSAssetManager.shared.cacheCountLimit = cacheCountLimit;
}

- (NSUInteger)cacheCountLimit {
    return MCSAssetManager.shared.cacheCountLimit;
}

- (void)setMaxDiskAgeForCache:(NSTimeInterval)maxDiskAgeForCache {
    MCSAssetManager.shared.maxDiskAgeForCache = maxDiskAgeForCache;
}
- (NSTimeInterval)maxDiskAgeForCache {
    return MCSAssetManager.shared.maxDiskAgeForCache;
}

- (void)setMaxDiskSizeForCache:(NSUInteger)maxDiskSizeForCache {
    MCSAssetManager.shared.maxDiskSizeForCache = maxDiskSizeForCache;
}
- (NSUInteger)maxDiskSizeForCache {
    return MCSAssetManager.shared.maxDiskSizeForCache;
}

- (void)setReservedFreeDiskSpace:(NSUInteger)reservedFreeDiskSpace {
    MCSAssetManager.shared.reservedFreeDiskSpace = reservedFreeDiskSpace;
}
- (NSUInteger)reservedFreeDiskSpace {
    return MCSAssetManager.shared.reservedFreeDiskSpace;
}

- (void)removeAllCaches {
    [MCSDownload.shared cancelAllDownloadTasks];
    [MCSPrefetcherManager.shared cancelAllPrefetchTasks];
    [MCSAssetManager.shared removeAllAssets];
}

- (void)removeCacheForURL:(NSURL *)URL {
    if ( URL == nil )
        return;
    [MCSAssetManager.shared removeAssetForURL:URL];
}

- (unsigned long long)cachedSize {
    return [MCSAssetManager.shared cachedSizeForAssets];
}

- (BOOL)isStoredForURL:(NSURL *)URL {
    if ( URL == nil )
        return NO;
    id<MCSAsset> asset = [MCSAssetManager.shared assetWithURL:URL];
    return asset.isStored;
}
@end
