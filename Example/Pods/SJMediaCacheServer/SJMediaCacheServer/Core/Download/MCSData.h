//
//  MCSData.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/7/7.
//

#import "MCSDownload.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSData : NSObject<MCSDownloadTaskDelegate>

+ (NSData *)dataWithContentsOfRequest:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
