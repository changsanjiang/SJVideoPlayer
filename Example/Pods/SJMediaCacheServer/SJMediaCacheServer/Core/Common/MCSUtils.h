//
//  MCSUtils.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef struct response_content_range {
    NSUInteger start; // `NSNotFound` means undefined
    NSUInteger end;
    NSUInteger totalLength;
} MCSResponseContentRange;


FOUNDATION_EXTERN MCSResponseContentRange
MCSGetResponseContentRange(NSHTTPURLResponse *response);

FOUNDATION_EXTERN NSRange
MCSGetResponseNSRange(MCSResponseContentRange responseRange);

FOUNDATION_EXTERN NSString *
MCSGetResponseServer(NSHTTPURLResponse *response);

FOUNDATION_EXTERN NSString *
MCSGetResponseContentType(NSHTTPURLResponse *response);

FOUNDATION_EXPORT NSUInteger
MCSGetResponseContentLength(NSHTTPURLResponse *response);

#pragma mark -

typedef struct request_content_range {
    NSUInteger start; // `NSNotFound` means undefined
    NSUInteger end;
} MCSRequestContentRange;

FOUNDATION_EXTERN MCSRequestContentRange
MCSGetRequestContentRange(NSDictionary *requestHeaders);

FOUNDATION_EXTERN NSRange
MCSGetRequestNSRange(MCSRequestContentRange requestRange);

#pragma mark -

FOUNDATION_EXPORT BOOL
MCSNSRangeIsUndefined(NSRange range);

FOUNDATION_EXPORT BOOL
MCSNSRangeContains(NSRange main, NSRange sub);

FOUNDATION_EXPORT NSString *_Nullable
MCSSuggestedFilePathExtension(NSHTTPURLResponse *response);

#ifdef DEBUG
FOUNDATION_EXPORT uint64_t
MCSStartTime(void);

FOUNDATION_EXPORT NSTimeInterval
MCSEndTime(uint64_t elapsed_time);

#else
#define MCSStartTime()
#define MCSEndTime(...)
#endif
NS_ASSUME_NONNULL_END
