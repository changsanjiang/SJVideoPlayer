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

- (id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL preloadSize:(NSUInteger)preloadSize;
- (id<MCSPrefetchTask>)prefetchWithURL:(NSURL *)URL preloadSize:(NSUInteger)preloadSize progress:(void(^_Nullable)(float progress))progressBlock completed:(void(^_Nullable)(NSError *_Nullable error))completionBlock;
@end

@protocol MCSPrefetchTask <NSObject>
@property (nonatomic, readonly) NSUInteger preloadSize;
@property (nonatomic, strong, readonly) NSURL *URL;

- (void)cancel;
@end
NS_ASSUME_NONNULL_END
