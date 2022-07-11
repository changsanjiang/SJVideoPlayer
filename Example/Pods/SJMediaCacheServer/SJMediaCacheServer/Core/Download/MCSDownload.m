//
//  SJDataDownload.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/5/30.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSDownload.h"
#import "MCSConsts.h"
#import "MCSError.h"
#import "MCSUtils.h"
#import "MCSQueue.h"
#import "MCSLogger.h"
#import "NSURLRequest+MCS.h"

@interface NSURLSessionTask (MCSDownloadExtended)<MCSDownloadTask>

@end

@interface MCSDownload () <NSURLSessionDataDelegate> {
    NSURLSession *mSession;
    NSOperationQueue *mSessionDelegateQueue;
    NSURLSessionConfiguration *mSessionConfiguration;
    NSMutableDictionary<NSNumber *, NSError *> *mErrorDictionary;
    NSMutableDictionary<NSNumber *, id<MCSDownloadTaskDelegate>> *mDelegateDictionary;
    UIBackgroundTaskIdentifier mBackgroundTask;

    NSMutableURLRequest *_Nullable(^mRequestHandler)(NSMutableURLRequest *request);
    void (^mDidFinishCollectingMetrics)(NSURLSession *session, NSURLSessionTask *task, NSURLSessionTaskMetrics *metrics) API_AVAILABLE(ios(10.0));
    NSData *(^mDataEncoder)(NSURLRequest *request, NSUInteger offset, NSData *data);
    void(^mErrorCallback)(NSURLRequest *request, NSError *error);
    NSTimeInterval mTimeoutInterval;
    NSInteger mTaskCount;
}
@end

@implementation MCSDownload

+ (instancetype)shared {
    static MCSDownload *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init {
    if (self = [super init]) {
        mTimeoutInterval = 30.0f;
        mBackgroundTask = UIBackgroundTaskInvalid;
        mErrorDictionary = [NSMutableDictionary dictionary];
        mDelegateDictionary = [NSMutableDictionary dictionary];
        mSessionDelegateQueue = [[NSOperationQueue alloc] init];
        mSessionDelegateQueue.qualityOfService = NSQualityOfServiceUserInteractive;
        mSessionDelegateQueue.maxConcurrentOperationCount = 1;
        mSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        mSessionConfiguration.timeoutIntervalForRequest = mTimeoutInterval;
        mSessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        mSession = [NSURLSession sessionWithConfiguration:mSessionConfiguration delegate:self delegateQueue:mSessionDelegateQueue];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setRequestHandler:(NSMutableURLRequest * _Nullable (^_Nullable)(NSMutableURLRequest * _Nonnull))requestHandler {
    mcs_queue_sync(^{
        mRequestHandler = requestHandler;
    });
}

- (NSMutableURLRequest * _Nullable (^_Nullable)(NSMutableURLRequest * _Nonnull))requestHandler {
    __block id retv;
    mcs_queue_sync(^{
        retv = mRequestHandler;
    });
    return retv;
}

- (void)setDidFinishCollectingMetrics:(void (^)(NSURLSession * _Nonnull, NSURLSessionTask * _Nonnull, NSURLSessionTaskMetrics * _Nonnull))didFinishCollectingMetrics {
    mcs_queue_sync(^{
        mDidFinishCollectingMetrics = didFinishCollectingMetrics;
    });
}

- (void (^)(NSURLSession * _Nonnull, NSURLSessionTask * _Nonnull, NSURLSessionTaskMetrics * _Nonnull))didFinishCollectingMetrics {
    __block id retv;
    mcs_queue_sync(^{
        retv = mDidFinishCollectingMetrics;
    });
    return retv;
}

- (void)setDataEncoder:(NSData * _Nonnull (^_Nullable)(NSURLRequest * _Nonnull, NSUInteger, NSData * _Nonnull))dataEncoder {
    mcs_queue_sync(^{
        mDataEncoder = dataEncoder;
    });
}

- (NSData * _Nonnull (^_Nullable)(NSURLRequest * _Nonnull, NSUInteger, NSData * _Nonnull))dataEncoder {
    __block id retv;
    mcs_queue_sync(^{
        retv = mDataEncoder;
    });
    return retv;
}

- (void)setErrorCallback:(void (^_Nullable)(NSURLRequest * _Nonnull, NSError * _Nonnull))errorCallback {
    mcs_queue_sync(^{
        mErrorCallback = errorCallback;
    });
}

- (void (^_Nullable)(NSURLRequest * _Nonnull, NSError * _Nonnull))errorCallback {
    __block id retv;
    mcs_queue_sync(^{
        retv = mErrorCallback;
    });
    return retv;
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    mcs_queue_sync(^{
        mTimeoutInterval = timeoutInterval;
    });
}

- (NSTimeInterval)timeoutInterval {
    __block NSTimeInterval interval;
    mcs_queue_sync(^{
        interval = mTimeoutInterval;
    });
    return interval;
}

- (NSInteger)taskCount {
  __block NSInteger taskCount = 0;
  mcs_queue_sync(^{
      taskCount = mTaskCount;
  });
  return taskCount;
}

#pragma mark - mark

- (nullable id<MCSDownloadTask>)downloadWithRequest:(NSURLRequest *)request priority:(float)priority delegate:(id<MCSDownloadTaskDelegate>)delegate {
    __block NSURLSessionTask *task;
    mcs_queue_sync(^{
        NSMutableURLRequest *cur = [request mutableCopy];
        cur.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        cur.timeoutInterval = mTimeoutInterval;
        if ( mRequestHandler != nil ) cur = mRequestHandler(cur);
        if ( cur == nil ) return;
        task = [mSession dataTaskWithRequest:cur];
        task.priority = priority;
        mTaskCount += 1;
        mDelegateDictionary[@(task.taskIdentifier)] = delegate;
        [task resume];
        MCSDownloaderDebugLog(@"%@: <%p>.downloadWithRequest { task: %lu, request: %@ };\n", NSStringFromClass(self.class), self, (unsigned long)task.taskIdentifier, [cur mcs_description]);
    });
    return task;
}

- (void)cancelAllDownloadTasks {
    mcs_queue_sync(^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [mSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
            [dataTasks makeObjectsPerformSelector:@selector(cancel)];
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        mTaskCount = 0;
    });
}

- (void)customSessionConfig:(void (^)(NSURLSessionConfiguration * _Nonnull))config {
    mcs_queue_sync(^{
        config(mSession.configuration);
    });
}
  
#pragma mark - mark

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    mcs_queue_async(^{
        id<MCSDownloadTaskDelegate> delegate = self->mDelegateDictionary[@(task.taskIdentifier)];
        [delegate downloadTask:task willPerformHTTPRedirectionWithNewRequest:request];
    });
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)task didReceiveResponse:(__kindof NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    MCSDownloaderDebugLog(@"%@: <%p>.didReceiveResponse { task: %lu, response: %@ };\n", NSStringFromClass(self.class), self, (unsigned long)task.taskIdentifier, response);

    NSError *error = nil;
    
    if ( [response isKindOfClass:NSURLResponse.class] ) {
        NSHTTPURLResponse *res = response;
        
        if      ( res.statusCode < MCS_RESPONSE_CODE_OK || res.statusCode > MCS_RESPONSE_CODE_BAD ) {
            error = [NSError mcs_errorWithCode:MCSInvalidResponseError userInfo:@{
                MCSErrorUserInfoObjectKey : response,
                MCSErrorUserInfoReasonKey : [NSString stringWithFormat:@"响应无效: statusCode(%ld)!", (long)res.statusCode]
            }];
        }
    }
    
    mcs_queue_async(^{
        NSNumber *key = @(task.taskIdentifier);
        if ( error != nil ) {
            self->mErrorDictionary[key] = error;
            completionHandler(NSURLSessionResponseCancel);
            /* return */
            return;
        }
        
        id<MCSDownloadTaskDelegate> delegate = self->mDelegateDictionary[key];
        [delegate downloadTask:task didReceiveResponse:[MCSDownloadResponse.alloc initWithHTTPResponse:response]];
        completionHandler(NSURLSessionResponseAllow);
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)dataParam {
    MCSDownloaderDebugLog(@"%@: <%p>.didReceiveData { task: %lu, dataLength: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)dataTask.taskIdentifier, (unsigned long)dataParam.length);
    mcs_queue_async(^{
        id<MCSDownloadTaskDelegate> delegate = self->mDelegateDictionary[@(dataTask.taskIdentifier)];
        NSData *data = dataParam;
        if ( self->mDataEncoder != nil ) data = self->mDataEncoder(dataTask.currentRequest, (NSUInteger)(dataTask.countOfBytesReceived - dataParam.length), dataParam);
        [delegate downloadTask:dataTask didReceiveData:data];
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(ios(10.0)) {
    mcs_queue_async(^{
        if (self->mDidFinishCollectingMetrics != nil) {
            self->mDidFinishCollectingMetrics(session, task, metrics);
        }
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)errorParam {
    MCSDownloaderDebugLog(@"%@: <%p>.didCompleteWithError { task: %lu, error: %@ };\n", NSStringFromClass(self.class), self, (unsigned long)task.taskIdentifier, errorParam);
    mcs_queue_async(^{
        if ( self->mTaskCount > 0 ) self->mTaskCount -= 1;
        NSNumber *key = @(task.taskIdentifier);
        NSError *error = self->mErrorDictionary[key] ?: errorParam;
        id<MCSDownloadTaskDelegate> delegate = self->mDelegateDictionary[key];
        [delegate downloadTask:task didCompleteWithError:error];
        if ( error != nil && error.code != NSUserCancelledError && self->mErrorCallback != nil ) {
            self->mErrorCallback(task.originalRequest, error);
        }
       
        self->mDelegateDictionary[key] = nil;
        self->mErrorDictionary[key] = nil;
    });
}
  
#pragma mark - Background Task

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self _beginBackgroundTaskIfNeeded];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self _endBackgroundTaskIfNeeded];
}

- (void)_endBackgroundTaskDelay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(28 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _endBackgroundTaskIfNeeded];
    });
}

- (void)_beginBackgroundTaskIfNeeded {
    mcs_queue_sync(^{
        if ( mDelegateDictionary.count != 0 && mBackgroundTask == UIBackgroundTaskInvalid ) {
            mBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [self _endBackgroundTaskIfNeeded];
            }];
        }
    });
}

- (void)_endBackgroundTaskIfNeeded {
    mcs_queue_sync(^{
        if ( mDelegateDictionary.count == 0 && mBackgroundTask != UIBackgroundTaskInvalid ) {
            [UIApplication.sharedApplication endBackgroundTask:mBackgroundTask];
            mBackgroundTask = UIBackgroundTaskInvalid;
        }
    });
}
@end


@implementation MCSDownloadResponse
- (instancetype)initWithHTTPResponse:(NSHTTPURLResponse *)response {
    NSString *contentType = MCSResponseGetContentType(response);
    if ( response.statusCode == MCS_RESPONSE_CODE_PARTIAL_CONTENT ) {
        MCSResponseContentRange contentRange = MCSResponseGetContentRange(response);
        NSUInteger totalLength = contentRange.totalLength;
        NSRange range = MCSResponseRange(contentRange);
        self = [super initWithTotalLength:totalLength range:range contentType:contentType];
    }
    else {
        NSUInteger totalLength = response.expectedContentLength != NSURLResponseUnknownLength ? response.expectedContentLength : MCSResponseGetContentLength(response);
        self = [super initWithTotalLength:totalLength contentType:contentType];
    }
    
    if ( self ) {
        _statusCode = response.statusCode;
        _pathExtension = MCSSuggestedFilepathExtension(response);
        _URL = response.URL;
    }
    return self;
}
@end
