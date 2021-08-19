//
//  MCSPrefetcherDefines.h
//  Pods
//
//  Created by BlueDancer on 2020/6/11.
//

#ifndef MCSPrefetcherDefines_h
#define MCSPrefetcherDefines_h

#import <Foundation/Foundation.h>
@protocol MCSPrefetcherDelegate;

NS_ASSUME_NONNULL_BEGIN
@protocol MCSPrefetcher <NSObject>
@property (nonatomic, weak, readonly, nullable) id<MCSPrefetcherDelegate> delegate;
@property (nonatomic, strong, readonly, nullable) dispatch_queue_t delegateQueue;

- (void)prepare;
- (void)close;

@property (nonatomic, readonly) float progress;
@end

@protocol MCSPrefetcherDelegate <NSObject>
- (void)prefetcher:(id<MCSPrefetcher>)prefetcher progressDidChange:(float)progress;
- (void)prefetcher:(id<MCSPrefetcher>)prefetcher didCompleteWithError:(NSError *_Nullable)error;
@end

@protocol MCSPrefetchTask <NSObject>
@property (nonatomic, readonly) NSUInteger preloadSize;
@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, copy, nullable) void(^startedExecuteBlock)(id<MCSPrefetchTask> task);
- (void)cancel;
@end
NS_ASSUME_NONNULL_END

#endif /* MCSPrefetcherDefines_h */
