//
//  SJDataDownload.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/5/30.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSDownload.h"
#import "MCSError.h"
#import "MCSUtils.h"
#import "MCSQueue.h"
#import "MCSLogger.h"

static dispatch_queue_t mcs_queue;

@interface MCSDownload () <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *sessionDelegateQueue;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSError *> *errorDictionary;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, id<MCSDownloadTaskDelegate>> *delegateDictionary;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@end

@implementation MCSDownload

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mcs_queue = dispatch_queue_create("queue.MCSDownload", DISPATCH_QUEUE_CONCURRENT);
    });
}

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
        _timeoutInterval = 30.0f;
        _backgroundTask = UIBackgroundTaskInvalid;
        _errorDictionary = [NSMutableDictionary dictionary];
        _delegateDictionary = [NSMutableDictionary dictionary];
        _sessionDelegateQueue = [[NSOperationQueue alloc] init];
        _sessionDelegateQueue.qualityOfService = NSQualityOfServiceUserInteractive;
        _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionConfiguration.timeoutIntervalForRequest = _timeoutInterval;
        _sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        _session = [NSURLSession sessionWithConfiguration:_sessionConfiguration delegate:self delegateQueue:_sessionDelegateQueue];
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
 
- (nullable NSURLSessionTask *)downloadWithRequest:(NSURLRequest *)requestParam priority:(float)priority delegate:(id<MCSDownloadTaskDelegate>)delegate {
    NSURLRequest *request = [self _requestWithParam:requestParam];
    if ( request == nil )
        return nil;
    
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request];
    task.priority = priority;
    dispatch_barrier_sync(mcs_queue, ^{
        _taskCount += 1;
    });
    [self _setDelegate:delegate forTask:task];
    [task resume];
    
    MCSDownloaderDebugLog(@"%@: <%p>.downloadWithRequest { task: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)task.taskIdentifier);

    return task;
}

- (void)cancelAllDownloadTasks {
    dispatch_barrier_sync(mcs_queue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [_session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
            [dataTasks makeObjectsPerformSelector:@selector(cancel)];
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        _taskCount = 0;
    });
}
 
@synthesize taskCount = _taskCount;
- (NSInteger)taskCount {
    __block NSInteger taskCount = 0;
    dispatch_barrier_sync(mcs_queue, ^{
        taskCount = _taskCount;
    });
    return taskCount;
}

#pragma mark - mark

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)task didReceiveResponse:(__kindof NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    MCSDownloaderDebugLog(@"%@: <%p>.didReceiveResponse { task: %lu, response: %@ };\n", NSStringFromClass(self.class), self, (unsigned long)task.taskIdentifier, response);

    NSError *error = nil;
    
    if ( [response isKindOfClass:NSURLResponse.class] ) {
        NSHTTPURLResponse *res = response;
        
        if      ( res.statusCode < 200 || res.statusCode > 400 ) {
            error = [NSError mcs_errorWithCode:MCSInvalidResponseError userInfo:@{
                MCSErrorUserInfoObjectKey : response,
                MCSErrorUserInfoReasonKey : [NSString stringWithFormat:@"响应无效: statusCode(%ld)!", (long)res.statusCode]
            }];
        }
        else if ( res.statusCode == 206 && 0 == MCSGetResponseContentLength(res) ) {
            error = [NSError mcs_errorWithCode:MCSInvalidResponseError userInfo:@{
                MCSErrorUserInfoObjectKey : response,
                MCSErrorUserInfoReasonKey : @"响应无效: contentLength 为 0!"
            }];
        }
        else if ( res.statusCode == 206 ) {
            NSRange range1 = MCSGetRequestNSRange(MCSGetRequestContentRange(task.currentRequest.allHTTPHeaderFields));
            NSRange range2 = MCSGetResponseNSRange(MCSGetResponseContentRange(res));
            if ( !MCSNSRangeIsUndefined(range1) && !NSEqualRanges(range1, range2)) {
                if ( !MCSNSRangeIsUndefined(range2) && NSMaxRange(range1) <= NSMaxRange(range2) ) {
                    error = [NSError mcs_errorWithCode:MCSInvalidResponseError userInfo:@{
                        MCSErrorUserInfoObjectKey : response,
                        MCSErrorUserInfoReasonKey : [NSString stringWithFormat:@"响应无效: requestRange(%@), responseRange(%@) range无效!", NSStringFromRange(range1), NSStringFromRange(range2)]
                    }];
                }
            }
        }
    }
    
    if ( error != nil ) {
        [self _setError:error forTask:task];
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    
    id<MCSDownloadTaskDelegate> delegate = [self _delegateForTask:task];
    if ( delegate != nil ) {
        [delegate downloadTask:task didReceiveResponse:response];
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)dataParam {
    MCSDownloaderDebugLog(@"%@: <%p>.didReceiveData { task: %lu, dataLength: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)dataTask.taskIdentifier, (unsigned long)dataParam.length);

    __auto_type delegate = [self _delegateForTask:dataTask];
    NSData *data = dataParam;
    if ( _dataEncoder != nil )
        data = _dataEncoder(dataTask.currentRequest, (NSUInteger)(dataTask.countOfBytesReceived - dataParam.length), dataParam);
    [delegate downloadTask:dataTask didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)errorParam {
    MCSDownloaderDebugLog(@"%@: <%p>.didCompleteWithError { task: %lu, error: %@ };\n", NSStringFromClass(self.class), self, (unsigned long)task.taskIdentifier, errorParam);

    
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _taskCount > 0 ) _taskCount -= 1;
    });
    NSError *error = [self _errorForTask:task] ?: errorParam;
    
    __auto_type delegate = [self _delegateForTask:task];
    [delegate downloadTask:task didCompleteWithError:error];
    
    [self _setDelegate:nil forTask:task];
    [self _setError:nil forTask:task];
}

#pragma mark -

- (NSURLRequest *)_requestWithParam:(NSURLRequest *)param {
    NSMutableURLRequest *request = [param mutableCopy];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    request.timeoutInterval = _timeoutInterval;
    
    if ( _requestHandler != nil )
        request = _requestHandler(request);
    
    return request;
}

#pragma mark - Background Task

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self _beginBackgroundTaskIfNeeded];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self _endBackgroundTaskIfNeeded];
}

- (void)_endBackgroundTaskDelay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _endBackgroundTaskIfNeeded];
    });
}

- (void)_beginBackgroundTaskIfNeeded {
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _delegateDictionary.count != 0 && self->_backgroundTask == UIBackgroundTaskInvalid ) {
            self->_backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [self _endBackgroundTaskIfNeeded];
            }];
        }
    });
}

- (void)_endBackgroundTaskIfNeeded {
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _delegateDictionary.count == 0 && self->_backgroundTask != UIBackgroundTaskInvalid ) {
            [UIApplication.sharedApplication endBackgroundTask:_backgroundTask];
            _backgroundTask = UIBackgroundTaskInvalid;
        }
    });
}

#pragma mark -

- (void)_setDelegate:(nullable id<MCSDownloadTaskDelegate>)delegate forTask:(NSURLSessionTask *)task {
    dispatch_barrier_sync(mcs_queue, ^{
        self->_delegateDictionary[@(task.taskIdentifier)] = delegate;
        if ( delegate == nil && self->_delegateDictionary.count == 0 ) {
            [self _endBackgroundTaskDelay];
        }
    });
}
- (nullable id<MCSDownloadTaskDelegate>)_delegateForTask:(NSURLSessionTask *)task {
    __block id<MCSDownloadTaskDelegate> delegate = nil;
    dispatch_sync(mcs_queue, ^{
        delegate = self->_delegateDictionary[@(task.taskIdentifier)];
    });
    return delegate;
}

- (void)_setError:(nullable NSError *)error forTask:(NSURLSessionTask *)task {
    dispatch_barrier_sync(mcs_queue, ^{
        self->_errorDictionary[@(task.taskIdentifier)] = error;
    });
}

- (nullable NSError *)_errorForTask:(NSURLSessionTask *)task {
    __block NSError *error;
    dispatch_sync(mcs_queue, ^{
        error = self->_errorDictionary[@(task.taskIdentifier)];
    });
    return error;
}
@end
