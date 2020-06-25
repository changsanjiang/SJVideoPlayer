//
//  MCSVODNetworkDataReader.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSResourceDefines.h"
#import "MCSResourceResponse.h"
@class MCSVODResource;

NS_ASSUME_NONNULL_BEGIN

@interface MCSVODNetworkDataReader : NSObject<MCSResourceDataReader>
- (instancetype)initWithResource:(__weak MCSVODResource *)resource request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<MCSResourceDataReaderDelegate>)delegate delegateQueue:(dispatch_queue_t)queue;

@property (nonatomic, readonly) NSRange range;

- (void)prepare;
@property (nonatomic, strong, readonly, nullable) NSHTTPURLResponse *response;
@property (nonatomic, readonly) BOOL isPrepared;
@property (nonatomic, readonly) BOOL isDone;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
- (void)close;
@end
NS_ASSUME_NONNULL_END
