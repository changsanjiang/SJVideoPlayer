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

@interface MCSDownload () <NSURLSessionDataDelegate, NSLocking> {
    NSRecursiveLock *_lock;
}
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *sessionDelegateQueue;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSError *> *errorDictionary;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, id<MCSDownloadTaskDelegate>> *delegateDictionary;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
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
        _lock = NSRecursiveLock.alloc.init;
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

- (NSArray<NSString *> *)availableHeaderKeys {
    static NSArray<NSString *> *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = @[@"User-Agent",
                @"Connection",
                @"Accept",
                @"Accept-Encoding",
                @"Accept-Language",
                @"Range"];
    });
    return obj;
}
 
- (nullable NSURLSessionTask *)downloadWithRequest:(NSURLRequest *)requestParam priority:(float)priority delegate:(id<MCSDownloadTaskDelegate>)delegate {
    [self lock];
    @try {
        NSURLRequest *request = [self _requestWithParam:requestParam];
        
        if ( request == nil )
            return nil;
        
        NSURLSessionDataTask *task = [_session dataTaskWithRequest:request];
        _delegateDictionary[@(task.taskIdentifier)] = delegate;
        task.priority = priority;
        [task resume];
        return task;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    [self lock];
    completionHandler(request);
    [self unlock];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)task didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [self lock];
    @try {
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
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self lock];
    @try {
        NSNumber *key = @(dataTask.taskIdentifier);
        __auto_type delegate = _delegateDictionary[key];
        if ( _dataEncoder != nil ) data = _dataEncoder(dataTask.currentRequest, (NSUInteger)(dataTask.countOfBytesReceived - data.length), data);
        [delegate downloadTask:dataTask didReceiveData:data];
    } @catch (__unused NSException *exception) {
            
    } @finally {
        [self unlock];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [self lock];
    @try {
        NSNumber *key = @(task.taskIdentifier);
        if ( _errorDictionary[key] != nil )
            error = _errorDictionary[key];
        
        __auto_type delegate = _delegateDictionary[key];
        [delegate downloadTask:task didCompleteWithError:error];
        
        _delegateDictionary[key] = nil;
        _errorDictionary[key] = nil;
        
        if ( _delegateDictionary.count == 0 )
            [self endBackgroundTaskDelay];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

#pragma mark -

- (void)lock {
    [_lock lock];
}

- (void)unlock {
    [_lock unlock];
}

#pragma mark -

- (NSURLRequest *)_requestWithParam:(NSURLRequest *)param {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:param.URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:_timeoutInterval];
    __auto_type availableHeaderKeys = self.availableHeaderKeys;
    [param.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ( [availableHeaderKeys containsObject:key] ) {
            [request setValue:obj forHTTPHeaderField:key];
        }
    }];
    
    if ( _requestHandler != nil )
        request = _requestHandler(request);
    
    return request;
}

#pragma mark - Background Task

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self lock];
    @try {
        if ( _delegateDictionary.count > 0 )
            [self beginBackgroundTask];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self endBackgroundTask];
}

- (void)endBackgroundTaskDelay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self lock];
        @try {
            if ( self->_delegateDictionary.count == 0 )
                [self endBackgroundTask];
        } @catch (__unused NSException *exception) {
            
        } @finally {
            [self unlock];
        }
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
