//
//  SJMediaCacheServer.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/5/30.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//
//  Github: https://github.com/changsanjiang/SJMediaCacheServer.git
//
//  QQGroup: 930508201
//

#import <Foundation/Foundation.h>
#import "MCSPrefetcherDefines.h"
#import "MCSAssetExporterDefines.h"
#import "MCSDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// MCSPlayBackRequestTaskDidFailedNotification:
///     Playback request failure will past by this notificaion.
///     One playback item may has multiple request task.
///     So this notification may be posted multiple time.
/// MCSPlayBackRequestURLUserInfoKey:
///     Request URL in this key, Type URL
/// MCSPlayBackFailureUserInfoKey:
///     Request error in this key, type NSError
extern NSNotificationName const MCSPlayBackRequestTaskDidFailedNotification;
extern NSString *const MCSPlayBackRequestURLUserInfoKey;
extern NSString *const MCSPlayBackRequestFailureUserInfoKey;

@interface SJMediaCacheServer : NSObject
+ (instancetype)shared;

/// Convert the URL to the playback URL.
///
/// @param URL      An instance of NSURL that references a media asset.
///
/// @return It may return the HTTP proxy URL, but when there is the proxy service is not running, it will return the parameter URL.
///
/// @note return nil if URL is nil.
///
/// \code
/// @implementation YourPlayerController {
///     AVPlayer *_player
/// }
///
/// - (instancetype)initWithURL:(NSURL *)URL {
///     self = [super init];
///     if ( self ) {
///         NSURL *playbackURL = [SJMediaCacheServer.shared playbackURLWithURL:URL];
///         _player = [AVPlayer playerWithURL:playbackURL];
///     }
///     return self;
/// }
///
/// - (void)play {
///     [SJMediaCacheServer.shared setActive:YES];
///     [_player play];
/// }
///
/// - (void)seekToTime:(NSTimeInterval)time {
///     [SJMediaCacheServer.shared setActive:YES];
///     [_player seekToTime:time];
/// }
/// @end
/// \endcode
///
- (nullable NSURL *)playbackURLWithURL:(NSURL *)URL; // 获取播放地址

@property (nonatomic, readonly, getter=isActive) BOOL active;

/// App进入后台后, 当所有链接关闭时`CacheServer`将会停止服务
///
///     请在播放时激活`CacheServer`
///
/// \code
/// @implementation YourPlayerController
/// - (void)play {
///     [SJMediaCacheServer.shared setActive:YES];
///     [_player play];
/// }
///
/// - (void)seekToTime:(NSTimeInterval)time {
///     [SJMediaCacheServer.shared setActive:YES];
///     [_player seekToTime:time];
/// }
/// @end
/// \endcode
///
- (void)setActive:(BOOL)active;
@end


@interface SJMediaCacheServer (Prefetch)

/// The maximum number of queued prefetch tasks that can execute at same time.
///
///     The default value is 1.
///
@property (nonatomic) NSInteger maxConcurrentPrefetchCount;

/// Prefetch all data for the specified asset.
///
/// @param URL      An instance of NSURL that references a media asset.
///
/// @return The task to cancel the current prefetching.
///
/// @note return nil if URL is nil.
///
- (nullable id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock; // 预加载所有数据

/// Prefetch some assets in the cache for future use. assets are downloaded in low priority.
///
/// @param URL      An instance of NSURL that references a media asset.
///
/// @param bytes    Preload size in bytes.
///
/// @return The task to cancel the current prefetching.
///
/// @note return nil if URL is nil.
///
- (nullable id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes; // 预加载指定大小的数据

/// Prefetch some assets in the cache for future use. assets are downloaded in low priority.
///
/// @param URL      An instance of NSURL that references a media asset.
///
/// @param bytes    Preload size in bytes.
///
/// @param progressBlock   This block will be invoked when progress updates.
///
/// @param completionBlock This block will be invoked when the current prefetching is completed. If an error occurred, an error object indicating how the prefetch failed, otherwise nil.
///
/// @return The task to cancel the current prefetching.
///
/// @note return nil if URL is nil.
///
- (nullable id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock; // 预加载指定大小的数据

/// Prefetch some assets in the cache for future use. assets are downloaded in low priority.
///
/// @param URL      An instance of NSURL that references a media asset.
///
/// @param num      The number of preloaded files. HLS media usually contains multiple ts files, you can specify the number of files to be preloaded.
///
/// @param progressBlock   This block will be invoked when progress updates.
///
/// @param completionBlock This block will be invoked when the current prefetching is completed. If an error occurred, an error object indicating how the prefetch failed, otherwise nil.
///
/// @return The task to cancel the current prefetching.
///
/// @note return nil if URL is nil.
///
- (nullable id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL numberOfPreloadedFiles:(NSUInteger)num progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock;

/// Cancels all queued and executing prefetch tasks.
///
- (void)cancelAllPrefetchTasks; // 取消所有的预加载任务

@end


@interface SJMediaCacheServer (Request)

/// Add a request header or something to a data request.
///
///     This block will be invoked when the download server creates new download task.
///
@property (nonatomic, copy, nullable) NSMutableURLRequest *_Nullable(^requestHandler)(NSMutableURLRequest *request); // 为下载请求添加请求头或做一些其他事情

/// Sets a value for the header field.
///
/// @param URL      An instance of NSURL that references a media asset.
///
/// @param value    The new value for the header field. Any existing value for the field is replaced by the new value.
///
/// @param field    The name of the header field to set. In keeping with the HTTP RFC, HTTP header field names are case insensitive.
///
/// @param type     The data type of a partial content in the asset. For example, MCSDataTypeHLSPlaylist indicates setting the header for the request of the m3u8 playlist file.
///
- (void)assetURL:(NSURL *)URL setValue:(nullable NSString *)value forHTTPAdditionalHeaderField:(NSString *)field ofType:(MCSDataType)type;

/// A dictionary of additional headers to send with the asset data requests.
///
///     Note that these headers are added to the request only if not already present.
///
- (nullable NSDictionary<NSString *, NSString *> *)assetURL:(NSURL *)URL HTTPAdditionalHeadersForDataRequestsOfType:(MCSDataType)type;

/// custom URLSessionConfiguration
/// @param config the using config, to be customed
- (void)customSessionConfig:(nullable void(^)(NSURLSessionConfiguration *))config;
@end


@interface SJMediaCacheServer (Convert)

/// Access metrics in this block. This may not be executed in main thread.
@property (nonatomic, copy, nullable) void (^didFinishCollectingMetrics)(NSURLSession *session, NSURLSessionTask *task, NSURLSessionTaskMetrics *metrics) API_AVAILABLE(ios(10.0));

/// Resolve the identifier of the asset referenced by the URL.
///
///     The asset identifier represents a unique asset. When different URLs references the same asset, you can return the same identifier in the block.
///
///     This identifier will be used to identify the local cache. The same identifier will references the same cache.
///
@property (nonatomic, copy, nullable) NSString *(^resolveAssetIdentifier)(NSURL *URL); // URL参数不固定时, 请设置该block返回一个唯一标识符

/// Encode the received data.
///
///     This block will be invoked when the download server receives the data, where you can perform some encoding operations on the data.
///
@property (nonatomic, copy, nullable) NSData *(^writeDataEncoder)(NSURLRequest *request, NSUInteger offset, NSData *data); // 对下载的数据进行编码

/// Decode the read data.
///
///     This block will be invoked when the reader reads the data, where you can perform some decoding operations on the data.
///
@property (nonatomic, copy, nullable) NSData *(^readDataDecoder)(NSURLRequest *request, NSUInteger offset, NSData *data); // 对读取的数据进行解码

@end


@interface SJMediaCacheServer (Log)

/// Whether to open the console log, only in debug mode. release mode will not generate any logs.
///
///     If yes, the log will be output on the console. The default value is NO.
///
@property (nonatomic, getter=isEnabledConsoleLog) BOOL enabledConsoleLog; // 是否开启控制日志

/// Set more options to output more detailed log.
///
///     The default value is MCSLogOptionDefault.
///
@property (nonatomic) MCSLogOptions logOptions; // 设置日志选项, 以提供更加详细的日志.

@property (nonatomic) MCSLogLevel logLevel;
@end


@interface SJMediaCacheServer (Cache)

/// The maximum number of assets the cache should hold.
///
///     If 0, there is no count limit. The default value is 0.
///
///     This is not a strict limit—if the cache goes over the limit, an asset in the cache could be removed instantly, later, or possibly never, depending on the usage details of the asset.
///
@property (nonatomic) NSUInteger cacheCountLimit; // 个数限制

/// The maximum length of time to keep an asset in the cache, in seconds.
///
///     If 0, there is no expiring limit.  The default value is 0.
///
@property (nonatomic) NSTimeInterval maxDiskAgeForCache; // 保存时长限制

/// The maximum size of the disk cache, in bytes.
///
///     If 0, there is no cache size limit. The default value is 0.
///
@property (nonatomic) NSUInteger maxDiskSizeForCache; // 缓存占用的磁盘空间限制

/// The maximum length of free disk space the device should reserved, in bytes.
///
///     When the free disk space of device is less than or equal to this value, some assets will be removed.
///
///     If 0, there is no disk space limit. The default value is 0.
///
@property (nonatomic) NSUInteger reservedFreeDiskSpace; // 剩余磁盘空间限制

/// Protected caches are not included.
///
@property (nonatomic, readonly) UInt64 countOfBytesRemovableCaches; // 可被删除的缓存所占用的大小

/// Removes the cache of the specified URL.
///
///     If the cache for asset is protected, it will not be removed.
///
- (BOOL)removeCacheForURL:(NSURL *)URL; // 删除某个缓存

/// Remove all unprotected caches for assets.
///
///     If the cache for asset is protected, it will not be removed.
///
///     This method may blocks the calling thread until file delete finished.
///
- (void)removeAllRemovableCaches; // 删除缓存

- (BOOL)isStoredForURL:(NSURL *)URL;

@end


/// What's the difference between export and prefetch?
///
/// The MCSAssetExporterManager manages the exported assets.
///
/// The MCSAssetCacheManager manages the cache generated during playback and the prefetched assets.
///
/// So, if you want to remove the an exported asset, you must use MCSAssetExporterManager to remove it.
///
@interface SJMediaCacheServer (Export)

/// Register an observer to listen for export events
///
///     You do not need to unregister the observer. if you forget or are unable to remove the observer, the manager will remove it automatically.
///
- (void)registerExportObserver:(id<MCSAssetExportObserver>)observer; // 监听导出相关的事件
 
/// Remove the listening.
///
///     You do not need to unregister the observer. if you forget or are unable to remove the observer, the manager will remove it automatically.
///
- (void)removeExportObserver:(id<MCSAssetExportObserver>)observer; // 移除监听

/// The maximum number of queued export tasks that can execute at same time.
///
///     The default value is 1.
///
///     In fact, it is a variant of `maxConcurrentPrefetchCount`, which will indirectly set `maxConcurrentPrefetchCount`.
///
@property (nonatomic) NSInteger maxConcurrentExportCount;

@property (nonatomic, strong, readonly, nullable) NSArray<id<MCSAssetExporter>> *allExporters;

- (nullable NSArray<id<MCSAssetExporter>> *)exportsForMask:(MCSAssetExportStatusQueryMask)mask; // 查询

/// 
///
/// \code
///     [SJMediaCacheServer.shared registerExportObserver:self];
///
///     id<MCSAssetExporter> exporter = [SJMediaCacheServer.shared exportAssetWithURL:URL];
///     [exporter resume];
/// \endcode
///
- (nullable id<MCSAssetExporter>)exportAssetWithURL:(NSURL *)URL;
- (nullable id<MCSAssetExporter>)exportAssetWithURL:(NSURL *)URL resumes:(BOOL)resumes; // 获取exporter, 如果不存在将会创建.
 
- (MCSAssetExportStatus)exportStatusWithURL:(NSURL *)URL; // 当前状态
- (float)exportProgressWithURL:(NSURL *)URL; // 当前进度 

/// Synchronize the cache to the exporter.
///
- (void)synchronizeForExporterWithAssetURL:(NSURL *)URL; // 同步进度
- (void)synchronizeForExporters; // 同步内存中的exporter的进度

@property (nonatomic, readonly) UInt64 countOfBytesAllExportedAssets; // 返回导出资源占用的缓存大小

- (void)removeExportAssetWithURL:(NSURL *)URL;
- (void)removeAllExportAssets;
@end
NS_ASSUME_NONNULL_END
