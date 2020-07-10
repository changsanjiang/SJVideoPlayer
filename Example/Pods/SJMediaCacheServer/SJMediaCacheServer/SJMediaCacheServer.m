//
//  SJMediaCacheServer.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/5/30.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJMediaCacheServer.h"
#import "MCSProxyServer.h"
#import "MCSResourceManager.h"
#import "MCSResource.h"
#import "MCSURLRecognizer.h"
#import "MCSSessionTask.h"
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

- (NSURL *)playbackURLWithURL:(NSURL *)URL {
    if ( URL.isFileURL )
        return URL;
    MCSResource *resource = [MCSResourceManager.shared resourceWithURL:URL];
    
    // playback URL for cache
    if ( resource.isCacheFinished )
        return [resource playbackURLForCacheWithURL:URL];
    
    // proxy URL
    if ( _server.isRunning )
        return [MCSURLRecognizer.shared proxyURLWithURL:URL];

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
    return [MCSPrefetcherManager.shared prefetchWithURL:URL preloadSize:preloadSize];
}

- (id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL preloadSize:(NSUInteger)preloadSize progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock {
    return [MCSPrefetcherManager.shared prefetchWithURL:URL preloadSize:preloadSize progress:progressBlock completed:completionBlock];
}

- (void)cancelCurrentRequestsForURL:(NSURL *)URL {
    if ( URL == nil )
        return;
    MCSResource *resource = [MCSResourceManager.shared resourceWithURL:URL];
    [MCSResourceManager.shared cancelCurrentReadsForResource:resource];
}

- (void)cancelAllPrefetchTasks {
    [MCSPrefetcherManager.shared cancelAllPrefetchTasks];
}

#pragma mark - MCSProxyServerDelegate

- (id<MCSSessionTask>)server:(MCSProxyServer *)server taskWithRequest:(NSURLRequest *)request delegate:(id<MCSSessionTaskDelegate>)delegate {
    return [MCSSessionTask.alloc initWithRequest:request delegate:delegate];
}
@end


@implementation SJMediaCacheServer (Request)

- (void)setRequestHandler:(NSMutableURLRequest * _Nullable (^)(NSMutableURLRequest * _Nonnull))requestHandler {
    MCSDownload.shared.requestHandler = requestHandler;
}
- (NSMutableURLRequest * _Nullable (^)(NSMutableURLRequest * _Nonnull))requestHandler {
    return MCSDownload.shared.requestHandler;
}

- (void)resourceURL:(NSURL *)URL setValue:(nullable NSString *)value forHTTPAdditionalHeaderField:(NSString *)field ofType:(MCSDataType)type {
    MCSResource *resource = [MCSResourceManager.shared resourceWithURL:URL];
    [resource.configuration setValue:value forHTTPAdditionalHeaderField:field ofType:type];
}
- (nullable NSDictionary *)resourceURL:(NSURL *)URL HTTPAdditionalHeadersForDataRequestsOfType:(MCSDataType)type {
    MCSResource *resource = [MCSResourceManager.shared resourceWithURL:URL];
    return [resource.configuration HTTPAdditionalHeadersForDataRequestsOfType:type];
}
@end



@implementation SJMediaCacheServer (Convert)
- (void)setResolveResourceIdentifier:(NSString * _Nonnull (^)(NSURL * _Nonnull))resolveResourceIdentifier {
    MCSURLRecognizer.shared.resolveResourceIdentifier = resolveResourceIdentifier;
}
- (NSString * _Nonnull (^)(NSURL * _Nonnull))resolveResourceIdentifier {
    return MCSURLRecognizer.shared.resolveResourceIdentifier;
}

- (void)setWriteDataEncoder:(NSData * _Nonnull (^)(NSURLRequest * _Nonnull, NSUInteger, NSData * _Nonnull))writeDataEncoder {
    MCSDownload.shared.dataEncoder = writeDataEncoder;
}
- (NSData * _Nonnull (^)(NSURLRequest * _Nonnull, NSUInteger, NSData * _Nonnull))writeDataEncoder {
    return MCSDownload.shared.dataEncoder;
}

- (void)setReadDataDecoder:(NSData * _Nonnull (^)(NSURLRequest * _Nonnull, NSUInteger, NSData * _Nonnull))readDataDecoder {
    MCSResourceManager.shared.readDataDecoder = readDataDecoder;
}
- (NSData * _Nonnull (^)(NSURLRequest * _Nonnull, NSUInteger, NSData * _Nonnull))readDataDecoder {
    return MCSResourceManager.shared.readDataDecoder;
}
@end


@implementation SJMediaCacheServer (Log)

- (void)setEnabledConsoleLog:(BOOL)enabledConsoleLog {
    MCSLogger.shared.enabledConsoleLog = enabledConsoleLog;
}

- (BOOL)isEnabledConsoleLog {
    return MCSLogger.shared.enabledConsoleLog;
}
@end

@implementation SJMediaCacheServer (Cache)
- (void)setCacheCountLimit:(NSUInteger)cacheCountLimit {
    MCSResourceManager.shared.cacheCountLimit = cacheCountLimit;
}

- (NSUInteger)cacheCountLimit {
    return MCSResourceManager.shared.cacheCountLimit;
}

- (void)setMaxDiskAgeForCache:(NSTimeInterval)maxDiskAgeForCache {
    MCSResourceManager.shared.maxDiskAgeForCache = maxDiskAgeForCache;
}
- (NSTimeInterval)maxDiskAgeForCache {
    return MCSResourceManager.shared.maxDiskAgeForCache;
}

- (void)setMaxDiskSizeForCache:(NSUInteger)maxDiskSizeForCache {
    MCSResourceManager.shared.maxDiskSizeForCache = maxDiskSizeForCache;
}
- (NSUInteger)maxDiskSizeForCache {
    return MCSResourceManager.shared.maxDiskSizeForCache;
}

- (void)setReservedFreeDiskSpace:(NSUInteger)reservedFreeDiskSpace {
    MCSResourceManager.shared.reservedFreeDiskSpace = reservedFreeDiskSpace;
}
- (NSUInteger)reservedFreeDiskSpace {
    return MCSResourceManager.shared.reservedFreeDiskSpace;
}

- (void)removeAllCaches {
    [MCSResourceManager.shared removeAllResources];
}

- (void)removeCacheForURL:(NSURL *)URL {
    [MCSResourceManager.shared removeResourceForURL:URL];
}

- (NSUInteger)cachedSize {
    return [MCSResourceManager.shared cachedSizeForResources];
}

@end
