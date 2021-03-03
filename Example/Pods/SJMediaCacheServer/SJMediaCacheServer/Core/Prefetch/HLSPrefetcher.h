//
//  HLSPrefetcher.h
//  CocoaAsyncSocket
//
//  Created by BlueDancer on 2020/6/11.
//

#import "MCSPrefetcherDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLSPrefetcher : NSObject<MCSPrefetcher>

- (instancetype)initWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes delegate:(nullable id<MCSPrefetcherDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

// numberOfPreloadedFiles指加载ts的数量, 而且还会存在如下情况的处理:
//      - 当遇到`VARIANT_STREAM`时, 将会下载第一个`STREAM`中指定数量的ts文件.
//      - 当遇到`AES_KEY`时, 也会一并下载, 不计入数量.
- (instancetype)initWithURL:(NSURL *)URL numberOfPreloadedFiles:(NSUInteger)num delegate:(nullable id<MCSPrefetcherDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

- (instancetype)initWithURL:(NSURL *)URL delegate:(nullable id<MCSPrefetcherDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

@end

NS_ASSUME_NONNULL_END
