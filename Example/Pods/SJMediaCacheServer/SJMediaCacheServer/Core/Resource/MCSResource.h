//
//  MCSResource.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSDefines.h"
@class MCSResourceUsageLog;

NS_ASSUME_NONNULL_BEGIN

@interface MCSResource : NSObject<MCSResource>
@property (nonatomic, readonly) MCSResourceType type;

- (id<MCSResourceReader>)readerWithRequest:(NSURLRequest *)request;

@property (nonatomic, strong, readonly) MCSResourceUsageLog *log;

@property (nonatomic, readonly) BOOL isCacheFinished;

- (nullable NSURL *)playbackURLForCacheWithURL:(NSURL *)URL;

@property (nonatomic, strong, readonly) dispatch_queue_t readerOperationQueue;
@end

NS_ASSUME_NONNULL_END
