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
#import <objc/message.h>
#import "HTTPServer.h"
#import "HTTPConnection.h"
#import "HTTPResponse.h"
#import "HTTPMessage.h"


@interface HTTPServer (MCSProxyServerExtended)
@property (nonatomic, weak, nullable) MCSProxyServer *mcs_server;
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
@property (nonatomic, strong) HTTPServer *localServer;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

- (id<MCSProxyTask>)taskWithRequest:(NSURLRequest *)request delegate:(id<MCSProxyTaskDelegate>)delegate;

@end

@implementation MCSProxyServer
- (instancetype)initWithPort:(UInt16)port {
    self = [super init];
    if ( self ) {
        _port = port;
        
        _localServer = HTTPServer.alloc.init;
        _localServer.mcs_server = self;
        [_localServer setConnectionClass:MCSHTTPConnection.class];
        [_localServer setType:@"_http._tcp"];
        [_localServer setPort:port];
        
        _backgroundTask = UIBackgroundTaskInvalid;
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (BOOL)isRunning {
    return _localServer.isRunning;
}

- (void)start {
    if ( self.isRunning )
        return;
    
    for ( int i = 0 ; i < 10 ; ++ i ) {
        if ( [self _start:NULL] ) {
            _serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://127.0.0.1:%d", _port]];
            break;
        }
        [_localServer setPort:_port += (UInt16)(arc4random() % 1000 + 1)];
    }
}

- (void)stop {
    [self _stop];
}

- (id<MCSProxyTask>)taskWithRequest:(NSURLRequest *)request delegate:(id<MCSProxyTaskDelegate>)delegate {
    return [self.delegate server:self taskWithRequest:request delegate:delegate];
}

#pragma mark -

- (void)applicationDidEnterBackground {
    [self _beginBackgroundTask];
}

- (void)applicationWillEnterForeground {
    if ( self.backgroundTask == UIBackgroundTaskInvalid && !self.isRunning ) {
        [self _start:nil];
    }
    [self _endBackgroundTask];
}

#pragma mark -

- (BOOL)_start:(NSError **)error {
    return [_localServer start:error];
}

- (void)_stop {
    [_localServer stop];
}

- (void)_beginBackgroundTask {
    if ( self.backgroundTask == UIBackgroundTaskInvalid ) {
        self.backgroundTask = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
            [self _stop];
            [self _endBackgroundTask];
        }];
    }
}

- (void)_endBackgroundTask {
    if ( self.backgroundTask != UIBackgroundTaskInvalid ) {
        [UIApplication.sharedApplication endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}
@end

#pragma mark -

@implementation HTTPServer (MCSProxyServerExtended)
- (void)setMcs_server:(MCSProxyServer *)mcs_server {
    objc_setAssociatedObject(self, @selector(mcs_server), mcs_server, OBJC_ASSOCIATION_ASSIGN);
}

- (MCSProxyServer *)mcs_server {
    return objc_getAssociatedObject(self, _cmd);
}
@end

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
    return config.server.mcs_server;
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

- (void)taskPrepareDidFinish:(id<MCSProxyTask>)task {
    [_connection responseHasAvailableData:self];
}

- (void)taskHasAvailableData:(id<MCSProxyTask>)task {
    [_connection responseHasAvailableData:self];
}

- (void)task:(id<MCSProxyTask>)task anErrorOccurred:(NSError *)error {
    [_connection responseDidAbort:self];
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
