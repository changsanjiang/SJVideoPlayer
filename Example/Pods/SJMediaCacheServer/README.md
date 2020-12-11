
# SJMediaCacheServer

SJMediaCacheServer is a HTTP Media Caching Framework. It can cache FILE or HLS media.

## Features
- Support cache FILE and HLS media.
- Support prefetch media. 


## Installation
```ruby
pod 'SJUIKit/SQLite3', :podspec => 'https://gitee.com/changsanjiang/SJUIKit/raw/master/SJUIKit-YYModel.podspec'
pod 'SJMediaCacheServer'
```

## 使用介绍

- https://juejin.im/post/5ee31be851882557525a8b18

## Usage

- Play
```Objective-C
#import <SJMediaCacheServer/SJMediaCacheServer.h>

    NSURL *URL = [NSURL URLWithString:@"http://.../auido.mp3"];
    NSURL *playbackURL = [SJMediaCacheServer.shared playbackURLWithURL:URL];
    AVPlayer *player = [AVPlayer playerWithURL:playbackURL];
    [player play];
``` 

- Prefetch
```Objective-C
#import <SJMediaCacheServer/SJMediaCacheServer.h>
    
    [SJMediaCacheServer.shared prefetchWithURL:URL preloadSize:20 * 1024 * 1024 progress:^(float progress) {
        NSLog(@"%lf", progress);
    } completed:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
    
    // The task to cancel the current prefetching.
    id<MCSPrefetchTask> task = [SJMediaCacheServer.shared prefetchWithURL:URL preloadSize:20 * 1024 * 1024 progress:^(float progress) {
        NSLog(@"%lf", progress);
    } completed:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
    // cancel 
    [task cancel];
```
 
- Download request configuration

```Objective-C
    SJMediaCacheServer.shared.requestHandler = ^NSMutableURLRequest * _Nullable(NSMutableURLRequest * _Nonnull request) {
        [request addValue:@"value1" forHTTPHeaderField:@"header filed1"];
        [request addValue:@"value2" forHTTPHeaderField:@"header filed2"];
      return request;
    };
```

- Other configuration  

```Objective-C
    @interface SJMediaCacheServer (Convert)

    /// Resolve the identifier of the resource referenced by the URL.
    ///
    ///     The resource identifier represents a unique resource. When different URLs references the same resource, you can set the block to resolve the identifier.
    ///
    ///     This identifier will be used to identify the local cache. The same identifier will references the same cache.
    ///
    @property (nonatomic, copy, nullable) NSString *(^resolveResourceIdentifier)(NSURL *URL); // URL参数不固定时, 请设置该block返回一个唯一标识符

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

    @end


    @interface SJMediaCacheServer (Cache)

    /// The maximum number of resources the cache should hold.
    ///
    ///     If 0, there is no count limit. The default value is 0.
    ///
    ///     This is not a strict limit—if the cache goes over the limit, a resource in the cache could be evicted instantly, later, or possibly never, depending on the usage details of the resource.
    ///
    @property (nonatomic) NSUInteger cacheCountLimit; // 个数限制

    /// The maximum length of time to keep a resource in the cache, in seconds.
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
    ///     When the free disk space of device is less than or equal to this value, some resources will be removed.
    ///
    ///     If 0, there is no disk space limit. The default value is 0.
    ///
    @property (nonatomic) NSUInteger reservedFreeDiskSpace; // 剩余磁盘空间限制

    /// Empties the cache. This method may blocks the calling thread until file delete finished.
    ///
    - (void)removeAllCaches; // 删除全部缓存
    @end
```

## License

SJMediaCacheServer is released under the MIT license.

## Feedback

- GitHub : [changsanjiang](https://github.com/changsanjiang)
- Email : changsanjiang@gmail.com
- QQGroup: 930508201

## Reference
- [KTVHTTPCache](https://github.com/ChangbaDevs/KTVHTTPCache) - KTVHTTPCache is a powerful media cache framework. It can cache HTTP request, and very suitable for media resources.

- https://tools.ietf.org/html/rfc7233#section-2.1
