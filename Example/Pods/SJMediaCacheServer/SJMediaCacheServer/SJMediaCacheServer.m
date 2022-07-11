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
#import "MCSAssetCacheManager.h"
#import "MCSAssetExporterManager.h"
#import "MCSURL.h"
#import "MCSProxyTask.h"
#import "MCSLogger.h"
#import "MCSDownload.h"
#import "MCSPrefetcherManager.h"
#import "MCSQueue.h"

NSNotificationName const MCSPlayBackRequestTaskDidFailedNotification = @"MCSPlayBackRequestTaskDidFailedNotification";
NSString *const MCSPlayBackRequestURLUserInfoKey = @"MCSPlayBackRequestURLUserInfoKey";
NSString *const MCSPlayBackRequestFailureUserInfoKey = @"MCSPlayBackRequestFailureUserInfoKey";

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
        mcs_queue_init();
        
        _server = [MCSProxyServer.alloc init];
        _server.delegate = self;
        [_server start];
        
        MCSURL.shared.serverURL = _server.serverURL;
        
        self.resolveAssetIdentifier = ^NSString * _Nonnull(NSURL * _Nonnull URL) {
            NSString *retv = URL.absoluteString;
            NSString *query = URL.query;
            if ( query.length != 0 ) {
                retv = [retv substringToIndex:retv.length - (query.length + 1 /*'?'.length*/)];
            }
            return retv;
        };
    }
    return self;
}

- (nullable NSURL *)playbackURLWithURL:(NSURL *)URL {
    if ( URL == nil )
        return nil;
    
    if ( URL.isFileURL )
        return URL;
    
    if ( !_server.isRunning )
        [_server start];
    
    // proxy URL
    if ( _server.isRunning )
        return [MCSURL.shared proxyURLWithURL:URL];

    // param URL
    return URL;
}

- (BOOL)isActive {
    return _server.isRunning;
}

- (void)setActive:(BOOL)active {
    active ? [_server start] : [_server stop];
}

#pragma mark - MCSProxyServerDelegate

- (id<MCSProxyTask>)server:(MCSProxyServer *)server taskWithRequest:(NSURLRequest *)request delegate:(id<MCSProxyTaskDelegate>)delegate {
    return [MCSProxyTask.alloc initWithRequest:request delegate:delegate];
}

- (void)server:(MCSProxyServer *)server performTask:(id<MCSProxyTask>)task failure:(NSError *)error {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSURL *proxyURL = task.request.URL;
    NSURL *URL = [MCSURL.shared URLWithProxyURL:proxyURL];
    userInfo[MCSPlayBackRequestURLUserInfoKey] = URL;
    userInfo[MCSPlayBackRequestFailureUserInfoKey] = error;
    
    [NSNotificationCenter.defaultCenter postNotificationName:MCSPlayBackRequestTaskDidFailedNotification
                                                      object:nil userInfo:userInfo];
}

@end


@implementation SJMediaCacheServer (Prefetch)

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

- (nullable id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL numberOfPreloadedFiles:(NSUInteger)num progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock {
    if ( URL == nil )
        return nil;
    return [MCSPrefetcherManager.shared prefetchWithURL:URL numberOfPreloadedFiles:num progress:progressBlock completed:completionBlock];
}

- (void)cancelAllPrefetchTasks {
    [MCSPrefetcherManager.shared cancelAllPrefetchTasks];
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

- (void)customSessionConfig:(nullable void(^)(NSURLSessionConfiguration *))config {
    [MCSDownload.shared customSessionConfig:config];
}

@end



@implementation SJMediaCacheServer (Convert)

- (void)setDidFinishCollectingMetrics:(void (^)(NSURLSession * _Nonnull, NSURLSessionTask * _Nonnull, NSURLSessionTaskMetrics * _Nonnull))didFinishCollectingMetrics {
    MCSDownload.shared.didFinishCollectingMetrics = didFinishCollectingMetrics;
}

- (void (^)(NSURLSession * _Nonnull, NSURLSessionTask * _Nonnull, NSURLSessionTaskMetrics * _Nonnull))didFinishCollectingMetrics {
    return MCSDownload.shared.didFinishCollectingMetrics;
}

- (void)setResolveAssetIdentifier:(NSString * _Nonnull (^)(NSURL * _Nonnull))resolveAssetIdentifier {
    MCSURL.shared.resolveAssetIdentifier = resolveAssetIdentifier;
}
- (NSString * _Nonnull (^)(NSURL * _Nonnull))resolveAssetIdentifier {
    return MCSURL.shared.resolveAssetIdentifier;
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
    MCSAssetCacheManager.shared.cacheCountLimit = cacheCountLimit;
}

- (NSUInteger)cacheCountLimit {
    return MCSAssetCacheManager.shared.cacheCountLimit;
}

- (void)setMaxDiskAgeForCache:(NSTimeInterval)maxDiskAgeForCache {
    MCSAssetCacheManager.shared.maxDiskAgeForCache = maxDiskAgeForCache;
}
- (NSTimeInterval)maxDiskAgeForCache {
    return MCSAssetCacheManager.shared.maxDiskAgeForCache;
}

- (void)setMaxDiskSizeForCache:(NSUInteger)maxDiskSizeForCache {
    MCSAssetCacheManager.shared.maxDiskSizeForCache = maxDiskSizeForCache;
}
- (NSUInteger)maxDiskSizeForCache {
    return MCSAssetCacheManager.shared.maxDiskSizeForCache;
}

- (void)setReservedFreeDiskSpace:(NSUInteger)reservedFreeDiskSpace {
    MCSAssetCacheManager.shared.reservedFreeDiskSpace = reservedFreeDiskSpace;
}
- (NSUInteger)reservedFreeDiskSpace {
    return MCSAssetCacheManager.shared.reservedFreeDiskSpace;
}

- (void)removeAllRemovableCaches {
    [MCSPrefetcherManager.shared cancelAllPrefetchTasks];
    [MCSAssetCacheManager.shared removeAllRemovableCaches];
}

- (BOOL)removeCacheForURL:(NSURL *)URL {
    return [MCSAssetCacheManager.shared removeCacheForURL:URL];
}

- (UInt64)countOfBytesRemovableCaches {
    return MCSAssetCacheManager.shared.countOfBytesRemovableCaches;
}

- (BOOL)isStoredForURL:(NSURL *)URL {
    if ( URL == nil )
        return NO;
    return [MCSAssetManager.shared isAssetStoredForURL:URL];
}
@end

@implementation SJMediaCacheServer (Export)

- (void)registerExportObserver:(id<MCSAssetExportObserver>)observer {
    [MCSAssetExporterManager.shared registerObserver:observer];
}
 
- (void)removeExportObserver:(id<MCSAssetExportObserver>)observer {
    [MCSAssetExporterManager.shared removeObserver:observer];
}

- (void)setMaxConcurrentExportCount:(NSInteger)maxConcurrentExportCount {
    MCSAssetExporterManager.shared.maxConcurrentExportCount = maxConcurrentExportCount;
}

- (NSInteger)maxConcurrentExportCount {
    return MCSAssetExporterManager.shared.maxConcurrentExportCount;
}

- (nullable NSArray<id<MCSAssetExporter>> *)allExporters {
    return MCSAssetExporterManager.shared.allExporters;
}

- (nullable NSArray<id<MCSAssetExporter>> *)exportsForMask:(MCSAssetExportStatusQueryMask)mask {
    return [MCSAssetExporterManager.shared exportsForMask:mask];
}

- (nullable id<MCSAssetExporter>)exportAssetWithURL:(NSURL *)URL {
    return [self exportAssetWithURL:URL resumes:NO];
}

- (nullable id<MCSAssetExporter>)exportAssetWithURL:(NSURL *)URL resumes:(BOOL)resumes {
    id<MCSAssetExporter> exporter = [MCSAssetExporterManager.shared exportAssetWithURL:URL];
    if ( resumes ) [exporter resume];
    return exporter;
}
 
- (MCSAssetExportStatus)exportStatusWithURL:(NSURL *)URL {
    return [MCSAssetExporterManager.shared statusWithURL:URL];
}

- (float)exportProgressWithURL:(NSURL *)URL {
    return [MCSAssetExporterManager.shared progressWithURL:URL];
}

- (void)synchronizeForExporterWithAssetURL:(NSURL *)URL {
    [MCSAssetExporterManager.shared synchronizeForExporterWithAssetURL:URL];
}

- (void)synchronizeForExporters {
    [MCSAssetExporterManager.shared synchronize];
}

- (UInt64)countOfBytesAllExportedAssets {
    return [MCSAssetExporterManager.shared countOfBytesAllExportedAssets];
}

- (void)removeExportAssetWithURL:(NSURL *)URL {
    [MCSAssetExporterManager.shared removeAssetWithURL:URL];
}

- (void)removeAllExportAssets {
    [MCSAssetExporterManager.shared removeAllAssets];
}
@end
