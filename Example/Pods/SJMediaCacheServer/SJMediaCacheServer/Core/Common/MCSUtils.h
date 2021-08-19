//
//  MCSUtils.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN BOOL
MCSRequestIsRangeRequest(NSURLRequest *request);

typedef struct response_content_range {
    NSUInteger start; // `NSNotFound` means undefined
    NSUInteger end;
    NSUInteger totalLength;
} MCSResponseContentRange;

FOUNDATION_EXTERN MCSResponseContentRange
MCSResponseGetContentRange(NSHTTPURLResponse *response);

FOUNDATION_EXTERN NSRange
MCSResponseRange(MCSResponseContentRange range);

FOUNDATION_EXTERN NSString *
MCSResponseGetServer(NSHTTPURLResponse *response);

FOUNDATION_EXTERN NSString *
MCSResponseGetContentType(NSHTTPURLResponse *response);

FOUNDATION_EXPORT NSUInteger
MCSResponseGetContentLength(NSHTTPURLResponse *response);

FOUNDATION_EXTERN MCSResponseContentRange const MCSResponseContentRangeUndefined;

FOUNDATION_EXPORT BOOL
MCSResponseRangeIsUndefined(MCSResponseContentRange range);

#pragma mark -

typedef struct request_content_range {
    NSUInteger start; // `NSNotFound` means undefined
    NSUInteger end;
} MCSRequestContentRange;

FOUNDATION_EXTERN MCSRequestContentRange
MCSRequestGetContentRange(NSDictionary *requestHeaders);

FOUNDATION_EXTERN NSRange
MCSRequestRange(MCSRequestContentRange range);

FOUNDATION_EXTERN MCSRequestContentRange const MCSRequestContentRangeUndefined;

FOUNDATION_EXPORT BOOL
MCSRequestRangeIsUndefined(MCSRequestContentRange range);

#pragma mark -

FOUNDATION_EXTERN NSRange const MCSNSRangeUndefined;

FOUNDATION_EXPORT BOOL
MCSNSRangeIsUndefined(NSRange range);

FOUNDATION_EXPORT BOOL
MCSNSRangeContains(NSRange main, NSRange sub);

FOUNDATION_EXPORT NSString *_Nullable
MCSSuggestedFilepathExtension(NSHTTPURLResponse *response);

#ifdef DEBUG
FOUNDATION_EXPORT uint64_t
MCSStartTime(void);

FOUNDATION_EXPORT NSTimeInterval
MCSEndTime(uint64_t elapsed_time);

#else
#define MCSStartTime()
#define MCSEndTime(...)
#endif

#pragma mark - DEBUG

//#ifdef DEBUG
//#define MCS_QUEUE_ENABLE_DEBUG
//#endif

#ifdef MCS_QUEUE_ENABLE_DEBUG
#define MCS_QUEUE_CHECK_INTERVAL 5
#define mcs_dispatch_queue_create(__label__, __attr__) __mcs_dispatch_queue_create(__label__, __attr__)
FOUNDATION_EXPORT dispatch_queue_t
__mcs_dispatch_queue_create(const char *_Nullable label, dispatch_queue_attr_t _Nullable attr);
#else
#define mcs_dispatch_queue_create(__label__, __attr__) dispatch_queue_create(__label__, __attr__)
#endif


FOUNDATION_EXPORT NSArray *_Nullable
MCSAllHashTableObjects(NSHashTable *table);
NS_ASSUME_NONNULL_END
