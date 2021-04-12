//
//  MCSData.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/7/7.
//

#import "MCSContents.h"

@implementation MCSContents {
    dispatch_semaphore_t _semaphore;
    NSMutableData *_m;
    NSError *_error;
    void(^_willPerformHTTPRedirection)(NSURLRequest *newRequest);
}

+ (void)request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority willPerformHTTPRedirection:(void(^_Nullable)(NSURLRequest *newRequest))block completed:(void(^)(NSData *_Nullable data, NSError *_Nullable error))completionHandler {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            NSError *error = nil;
            NSData *data = [self dataWithContentsOfRequest:request networkTaskPriority:networkTaskPriority error:&error willPerformHTTPRedirection:block];
            if ( completionHandler ) completionHandler(data, error);
        }
    });
}

+ (NSData *)dataWithContentsOfRequest:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority error:(NSError **)error willPerformHTTPRedirection:(void(^_Nullable)(NSURLRequest *newRequest))block {
    MCSContents *contents = [MCSContents.alloc initWithContentsOfRequest:request networkTaskPriority:networkTaskPriority error:error willPerformHTTPRedirection:block];
    return contents != nil ? contents->_m : nil;
}

- (instancetype)initWithContentsOfRequest:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority error:(NSError **)error willPerformHTTPRedirection:(void(^)(NSURLRequest *newRequest))block {
    self = [super init];
    if ( self ) {
        _willPerformHTTPRedirection = block;
        _m = NSMutableData.data;
        [MCSDownload.shared downloadWithRequest:request priority:networkTaskPriority delegate:self];
        _semaphore = dispatch_semaphore_create(0);
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        if ( _error != nil && error != NULL ) *error = _error;
    }
    return self;
}

- (void)downloadTask:(id<MCSDownloadTask>)task willPerformHTTPRedirectionWithNewRequest:(NSURLRequest *)request {
    if ( _willPerformHTTPRedirection != nil ) _willPerformHTTPRedirection(request);
}

- (void)downloadTask:(id<MCSDownloadTask>)task didReceiveResponse:(id<MCSDownloadResponse>)response { }

- (void)downloadTask:(id<MCSDownloadTask>)task didReceiveData:(NSData *)data {
    [_m appendData:data];
}

- (void)downloadTask:(id<MCSDownloadTask>)task didCompleteWithError:(NSError *)error {
    _error = error;
    dispatch_semaphore_signal(_semaphore);
}
@end
