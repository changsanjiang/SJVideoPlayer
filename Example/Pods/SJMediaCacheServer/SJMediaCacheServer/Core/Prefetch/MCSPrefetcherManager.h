//
//  MCSPrefetcherManager.h
//  CocoaAsyncSocket
//
//  Created by BlueDancer on 2020/6/12.
//

#import <Foundation/Foundation.h>
@protocol MCSPrefetchTask;

NS_ASSUME_NONNULL_BEGIN
@interface MCSPrefetcherManager : NSObject
+ (instancetype)shared;

@property (nonatomic) NSInteger maxConcurrentPrefetchCount;

- (nullable id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock;
- (nullable id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL preloadSize:(NSUInteger)preloadSize;
- (nullable id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL preloadSize:(NSUInteger)preloadSize progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock;
- (nullable id<MCSPrefetchTask>)prefetchWithHLSURL:(NSURL *)HLSURL numberOfPreloadFiles:(NSUInteger)num progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock;

- (void)cancelAllPrefetchTasks;
@end

@protocol MCSPrefetchTask <NSObject>
@property (nonatomic, readonly) NSUInteger preloadSize;
@property (nonatomic, strong, readonly) NSURL *URL;

- (void)cancel;
@end
NS_ASSUME_NONNULL_END
