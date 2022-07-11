//
//  MCSProxyServer.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/5/30.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSProxyServer.h"
#import "NSURLRequest+MCS.h"
#import "MCSLogger.h"
#import "MCSQueue.h"
#import <objc/message.h>
#if __has_include(<KTVCocoaHTTPServer/KTVCocoaHTTPServer.h>)
#import <KTVCocoaHTTPServer/KTVCocoaHTTPServer.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#else
#import "KTVCocoaHTTPServer.h"
#import "GCDAsyncSocket.h"
#endif

@interface MCSTimer : NSObject
- (instancetype)initWithQueue:(dispatch_queue_t)queue start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(MCSTimer *timer))block;

@property (nonatomic, readonly, getter=isValid) BOOL valid;

- (void)resume;
- (void)suspend;
- (void)invalidate;
@end
 
@implementation MCSTimer {
    dispatch_semaphore_t _semaphore;
    dispatch_source_t _timer;
    NSTimeInterval _timeInterval;
    BOOL _repeats;
    BOOL _valid;
    BOOL _suspend;
}

/// @param start 启动后延迟多少秒回调block
- (instancetype)initWithQueue:(dispatch_queue_t)queue start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(MCSTimer *timer))block {
    self = [super init];
    if ( self ) {
        _repeats = repeats;
        _timeInterval = interval;
        _valid = YES;
        _suspend = YES;
        _semaphore = dispatch_semaphore_create(1);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, (start * NSEC_PER_SEC)), (interval * NSEC_PER_SEC), 0);
        __weak typeof(self) _self = self;
        dispatch_source_set_event_handler(_timer, ^{
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
            block(self);
            if ( !repeats )
                [self invalidate];
        });
    }
    return self;
}

- (void)resume {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    if ( _valid && _suspend ) {
        _suspend = NO;
        dispatch_resume(_timer);
    }
    dispatch_semaphore_signal(_semaphore);
}

- (void)suspend {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    if ( _valid && !_suspend ) {
        _suspend = YES;
        dispatch_suspend(_timer);
    }
    dispatch_semaphore_signal(_semaphore);
}

- (void)invalidate {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    if ( _valid ) {
        dispatch_source_cancel(_timer);
        if ( _suspend )
            dispatch_resume(_timer);
        _timer = NULL;
        _valid = NO;
    }
    dispatch_semaphore_signal(_semaphore);
}

- (BOOL)isValid {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    BOOL isValid = _valid;
    dispatch_semaphore_signal(_semaphore);
    return isValid;
}

- (void)dealloc {
    [self invalidate];
}

@end

@interface MCSHTTPServer : HTTPServer
- (instancetype)initWithProxyServer:(__weak MCSProxyServer *)proxyServer;
@property (nonatomic, weak, readonly, nullable) MCSProxyServer *mcs_server;
@end

@implementation MCSHTTPServer
- (instancetype)initWithProxyServer:(__weak MCSProxyServer *)proxyServer {
    self = [super init];
    if ( self ) {
        _mcs_server = proxyServer;
    }
    return self;
}

- (HTTPConfig *)config {
    return [HTTPConfig.alloc initWithServer:self documentRoot:self->documentRoot queue:mcs_queue()];
}
@end

@interface MCSHTTPConnection : HTTPConnection
- (HTTPMessage *)mcs_request;
- (MCSProxyServer *)mcs_server;
@end
 
@interface MCSHTTPResponse : NSObject<HTTPResponse, MCSProxyTaskDelegate>
- (instancetype)initWithConnection:(MCSHTTPConnection *)connection;
@property (nonatomic, strong) NSURLRequest * request;
@property (nonatomic, strong) id<MCSProxyTask> task;
@property (nonatomic, weak) MCSHTTPConnection *connection;
- (void)prepareForReadingData;
@end

@interface NSURLRequest (MCSHTTPConnectionExtended)
+ (NSMutableURLRequest *)mcs_requestWithMessage:(HTTPMessage *)message;
@end

#pragma mark -

@interface MCSProxyServer ()
@property (nonatomic, strong, nullable) MCSHTTPServer *localServer;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
- (id<MCSProxyTask>)taskWithRequest:(NSURLRequest *)request delegate:(id<MCSProxyTaskDelegate>)delegate;
@property (nonatomic, strong, nullable) MCSTimer *timer;
@end

@implementation MCSProxyServer
- (instancetype)init {
    self = [super init];
    if ( self ) {
        _backgroundTask = UIBackgroundTaskInvalid;
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterForegroundWithNote:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidEnterBackgroundWithNote:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(HTTPConnectionDidDieWithNote:) name:HTTPConnectionDidDieNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)start {
    _running = YES;
    if ( _serverURL == nil ) {
        _localServer = [MCSHTTPServer.alloc initWithProxyServer:self];
        [_localServer setConnectionClass:MCSHTTPConnection.class];
        [_localServer setType:@"_http._tcp"];
    
        UInt16 port = 2000;
        for ( int i = 0 ; i < 10 ; ++ i ) {
            [_localServer setPort:port];
            if ( [self _start:NULL] ) {
                _serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://127.0.0.1:%d", port]];
                break;
            }
            port += (UInt16)(arc4random() % 1000 + 1);
        }
    }
    else {
        [self _start:NULL];
    }
}

- (void)stop {
    _running = NO;
    [self _stop];
}

- (id<MCSProxyTask>)taskWithRequest:(NSURLRequest *)request delegate:(id<MCSProxyTaskDelegate>)delegate {
    return [self.delegate server:self taskWithRequest:request delegate:delegate];
}

- (UInt16)port {
    return _localServer.listeningPort;
}

#pragma mark -
 
- (void)applicationDidEnterBackgroundWithNote:(NSNotification *)note {
    [self _beginBackgroundTask];
}
 
- (void)applicationWillEnterForegroundWithNote:(NSNotification *)note {
    if ( _running ) [self _start:nil];
    [self _endBackgroundTaskIfNeeded];
}

- (void)HTTPConnectionDidDieWithNote:(NSNotification *)note {
    [_timer invalidate];
    _timer = [MCSTimer.alloc initWithQueue:dispatch_get_main_queue() start:1.0 interval:0 repeats:NO block:^(MCSTimer *timer) {
        if ( self->_localServer.isRunning && UIApplication.sharedApplication.applicationState == UIApplicationStateBackground && self->_localServer.numberOfHTTPConnections == 0 ) {
            [self _stop];
        }
        [timer invalidate];
        self->_timer = nil;
    }];
    [_timer resume];
}

#pragma mark -

- (BOOL)_start:(NSError **)errorPtr {
    if ( _localServer != nil ) {
        if ( [_localServer isRunning] && [_localServer numberOfHTTPConnections] == 0 ) {
            [self _stop];
        }
        return [_localServer start:errorPtr];
    }
    return NO;
}

- (void)_stop {
    [_timer invalidate];
    _timer = nil;
    [_localServer stop];
    [self _endBackgroundTaskIfNeeded];
}

- (void)_beginBackgroundTask {
    [self _endBackgroundTaskIfNeeded];
    if ( UIApplication.sharedApplication.applicationState == UIApplicationStateBackground ) {
        _backgroundTask = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
            [self _endBackgroundTaskIfNeeded];
        }];
    }
}

- (void)_endBackgroundTaskIfNeeded {
    if ( _backgroundTask != UIBackgroundTaskInvalid ) {
        [UIApplication.sharedApplication endBackgroundTask:_backgroundTask];
        _backgroundTask = UIBackgroundTaskInvalid;
    }
}
@end

#pragma mark -

@implementation MCSHTTPConnection
- (id)initWithAsyncSocket:(GCDAsyncSocket *)newSocket configuration:(HTTPConfig *)aConfig {
    self = [super initWithAsyncSocket:newSocket configuration:aConfig];
    if ( self ) {
        MCSHTTPConnectionDebugLog(@"\n%@: <%p>.init;\n", NSStringFromClass(self.class), self);
    }
    return self;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    MCSHTTPResponse *response = [MCSHTTPResponse.alloc initWithConnection:self];
    
    MCSHTTPConnectionDebugLog(@"%@: <%p>.response { URL: %@, method: %@, range: %@ };\n", NSStringFromClass(self.class), self, method, response.request.URL, NSStringFromRange(response.request.mcs_range));
    
    [response prepareForReadingData];
    return response;
}

- (HTTPMessage *)mcs_request {
    return request;
}

- (MCSProxyServer *)mcs_server {
    return ((MCSHTTPServer *)config.server).mcs_server;
}

- (void)finishResponse {
    [super finishResponse];
    
    MCSHTTPConnectionDebugLog(@"%@: <%p>.finishResponse;\n", NSStringFromClass(self.class), self);
}

- (void)die {
    [super die];
    MCSHTTPConnectionDebugLog(@"%@: <%p>.die;\n", NSStringFromClass(self.class), self);
}

- (void)dealloc {
    MCSHTTPConnectionDebugLog(@"%@: <%p>.dealloc;\n\n", NSStringFromClass(self.class), self);
}

- (void)responseDidAbort:(NSObject<HTTPResponse> *)sender {
    [super responseDidAbort:sender];
    MCSHTTPConnectionDebugLog(@"%@: <%p>.abort;\n", NSStringFromClass(self.class), self);
}
@end

@implementation NSURLRequest (MCSHTTPConnectionExtended)
+ (NSMutableURLRequest *)mcs_requestWithMessage:(HTTPMessage *)message {
    return [self mcs_requestWithURL:message.url headers:message.allHeaderFields];
}
@end

@implementation MCSHTTPResponse
- (instancetype)initWithConnection:(MCSHTTPConnection *)connection {
    self = [super init];
    if ( self ) {
        _connection = connection;
        
        MCSProxyServer *server = [connection mcs_server];
        _request = [NSURLRequest mcs_requestWithMessage:connection.mcs_request];
        _task = [server taskWithRequest:_request delegate:self];
    }
    return self;
}

- (void)prepareForReadingData {
    [_task prepare];
}

- (NSData *)readDataOfLength:(NSUInteger)length {
    return [_task readDataOfLength:length];
}

- (BOOL)isDone {
    return _task.isDone;
}

- (void)connectionDidClose {
    [_task close];
}

- (NSDictionary *)httpHeaders {
    NSMutableDictionary *headers = NSMutableDictionary.dictionary;
    headers[@"Server"] = @"localhost";
    headers[@"Content-Type"] = _task.response.contentType;
    headers[@"Accept-Ranges"] = @"bytes";
    headers[@"Connection"] = @"keep-alive";
    return headers;
}

- (BOOL)delayResponseHeaders {
    return _task != nil ? !_task.isPrepared : YES;
}

- (void)task:(id<MCSProxyTask>)task didReceiveResponse:(id<MCSResponse>)response {
    [_connection responseHasAvailableData:self];
}

- (void)task:(id<MCSProxyTask>)task hasAvailableDataWithLength:(NSUInteger)length {
    [_connection responseHasAvailableData:self];
}

- (void)task:(id<MCSProxyTask>)task didAbortWithError:(nullable NSError *)error {
    [_connection responseDidAbort:self];
    MCSProxyServer *server = [_connection mcs_server];
    [server.delegate server:server performTask:task failure:error];
}

#pragma mark - Chunked
 
- (UInt64)contentLength {
    if ( _task.isPrepared ) {
        NSParameterAssert(_task.response.totalLength != 0);
    }
    return _task.response.totalLength;
}

- (UInt64)offset {
    return (UInt64)_task.offset;
}

- (void)setOffset:(UInt64)offset { }
@end
