//
//  FILEPrefetcher.h
//  CocoaAsyncSocket
//
//  Created by BlueDancer on 2020/6/11.
//

#import "MCSPrefetcherDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface FILEPrefetcher : NSObject<MCSPrefetcher>

- (instancetype)initWithURL:(NSURL *)URL preloadSize:(NSUInteger)bytes delegate:(nullable id<MCSPrefetcherDelegate>)delegate delegateQueue:(dispatch_queue_t)queue;

- (instancetype)initWithURL:(NSURL *)URL delegate:(nullable id<MCSPrefetcherDelegate>)delegate delegateQueue:(dispatch_queue_t)queue;

@end

NS_ASSUME_NONNULL_END
