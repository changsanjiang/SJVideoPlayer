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
@property (nonatomic, weak, nullable) id<MCSPrefetcherDelegate> delegate;

- (void)prepare;
- (void)close;

@property (nonatomic, readonly) float progress;
@property (nonatomic, readonly) BOOL isClosed;
@property (nonatomic, readonly) BOOL isDone;
@end

@protocol MCSPrefetcherDelegate <NSObject>
- (void)prefetcher:(id<MCSPrefetcher>)prefetcher progressDidChange:(float)progress;
- (void)prefetcher:(id<MCSPrefetcher>)prefetcher didCompleteWithError:(NSError *_Nullable)error;
@end
NS_ASSUME_NONNULL_END

#endif /* MCSPrefetcherDefines_h */
