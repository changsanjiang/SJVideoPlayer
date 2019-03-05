//
//  SJBaseVideoPlayerAutoRefreshContext.h
//  Pods
//
//  Created by BlueDancer on 2019/3/4.
//

#import <Foundation/Foundation.h>
@class SJVideoPlayerURLAsset;

NS_ASSUME_NONNULL_BEGIN
@interface SJBaseVideoPlayerAutoRefreshContext : NSObject
- (instancetype)initWithAsset:(SJVideoPlayerURLAsset *)asset delay:(NSTimeInterval)delay;
@property (nonatomic, strong, readonly) SJVideoPlayerURLAsset *asset;
@property (nonatomic, copy, nullable) void(^after)(SJBaseVideoPlayerAutoRefreshContext *context);
- (void)pause;
- (void)resume;
@end
NS_ASSUME_NONNULL_END
