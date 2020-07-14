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

@interface MCSDownload () <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *sessionDelegateQueue;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSError *> *errorDictionary;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, id<MCSDownloadTaskDelegate>> *delegateDictionary;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, strong) dispatch_queue_t queue;
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
        _queue = dispatch_get_global_queue(0, 0);
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
    __block NSURLSessionDataTask *task = nil;
    dispatch_barrier_sync(_queue, ^{
        NSURLRequest *request = [self _requestWithParam:requestParam];
        if ( request == nil )
            return;
        
        task = [_session dataTaskWithRequest:request];
        self->_delegateDictionary[@(task.taskIdentifier)] = delegate;
        task.priority = priority;
        [task resume];
    });
    return task;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    dispatch_barrier_sync(_queue, ^{
        completionHandler(request);
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)task didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    dispatch_barrier_sync(_queue, ^{
        NSError *error = nil;
        if ( response.statusCode > 400 ) {
            error = [NSError mcs_responseUnavailable:task.currentRequest.URL request:task.currentRequest response:task.response];
        }
        
        if ( error == nil && response.statusCode == 206 ) {
            NSUInteger contentLength = MCSGetResponseContentLength(response);
            if ( contentLength == 0 ) {
                error = [NSError mcs_responseUnavailable:task.currentRequest.URL request:task.currentRequest response:response];
            }
        }
        
        if ( error == nil && response.statusCode == 206 ) {
            NSRange requestRange = MCSGetRequestNSRange(MCSGetRequestContentRange(task.currentRequest.allHTTPHeaderFields));
            NSRange responseRange = MCSGetResponseNSRange(MCSGetResponseContentRange(response));
            
            if ( !MCSNSRangeIsUndefined(requestRange) ) {
                if ( MCSNSRangeIsUndefined(responseRange) || !NSEqualRanges(requestRange, responseRange) ) {
                    error = [NSError mcs_nonsupportContentType:task.currentRequest.URL request:task.currentRequest response:task.response];
                }
            }
        }
        
        NSNumber *key = @(task.taskIdentifier);
        if ( error == nil ) {
            id<MCSDownloadTaskDelegate> delegate = _delegateDictionary[key];
            [delegate downloadTask:task didReceiveResponse:response];
            completionHandler(NSURLSessionResponseAllow);
        }
        else {
            _errorDictionary[key] = error;
            completionHandler(NSURLSessionResponseCancel);
        }
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)dataParam {
    dispatch_barrier_sync(_queue, ^{
        NSNumber *key = @(dataTask.taskIdentifier);
        __auto_type delegate = _delegateDictionary[key];
        NSData *data = dataParam;
        if ( _dataEncoder != nil ) data = _dataEncoder(dataTask.currentRequest, (NSUInteger)(dataTask.countOfBytesReceived - dataParam.length), dataParam);
        [delegate downloadTask:dataTask didReceiveData:data];
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)errorParam {
    dispatch_barrier_sync(_queue, ^{
        NSNumber *key = @(task.taskIdentifier);
        NSError *error = errorParam;
        if ( _errorDictionary[key] != nil )
            error = _errorDictionary[key];
        
        __auto_type delegate = _delegateDictionary[key];
        [delegate downloadTask:task didCompleteWithError:error];
        
        _delegateDictionary[key] = nil;
        _errorDictionary[key] = nil;
        
        if ( _delegateDictionary.count == 0 )
            [self endBackgroundTaskDelay];
    });
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
    dispatch_barrier_sync(_queue, ^{
        if ( _delegateDictionary.count > 0 )
            [self beginBackgroundTask];
    });
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self endBackgroundTask];
}

- (void)endBackgroundTaskDelay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_barrier_sync(self->_queue, ^{
            if ( self->_delegateDictionary.count == 0 )
                [self endBackgroundTask];
        });
    });
}

- (void)beginBackgroundTask {
    _backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
}

- (void)endBackgroundTask {
    if ( _backgroundTask != UIBackgroundTaskInvalid ) {
        [UIApplication.sharedApplication endBackgroundTask:_backgroundTask];
        _backgroundTask = UIBackgroundTaskInvalid;
    }
}

@end
