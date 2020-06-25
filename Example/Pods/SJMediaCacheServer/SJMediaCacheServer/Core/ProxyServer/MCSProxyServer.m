//
//  MCSProxyServer.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/5/30.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSProxyServer.h"
#import "NSURLRequest+MCS.h"
#import "MCSURLRecognizer.h"
#import "MCSLogger.h"
#import <objc/message.h>
#import <CocoaHTTPServer/HTTPServer.h>
#import <CocoaHTTPServer/HTTPConnection.h>
#import <CocoaHTTPServer/HTTPResponse.h>
#import <CocoaHTTPServer/HTTPMessage.h>


@interface HTTPServer (MCSProxyServerExtended)
@property (nonatomic, weak, nullable) MCSProxyServer *mcs_server;
@end

@interface MCSHTTPConnection : HTTPConnection
- (HTTPMessage *)mcs_request;
- (MCSProxyServer *)mcs_server;
@end
 
@interface MCSHTTPResponse : NSObject<HTTPResponse, MCSSessionTaskDelegate>
- (instancetype)initWithConnection:(MCSHTTPConnection *)connection;
@property (nonatomic, strong) NSURLRequest * request;
@property (nonatomic, strong) id<MCSSessionTask> task;
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

- (id<MCSSessionTask>)taskWithRequest:(NSURLRequest *)request delegate:(id<MCSSessionTaskDelegate>)delegate;

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
        [_localServer setPort:_port += 2];
    }
}

- (void)stop {
    [self _stop];
}

- (id<MCSSessionTask>)taskWithRequest:(NSURLRequest *)request delegate:(id<MCSSessionTaskDelegate>)delegate {
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
        MCSLog(@"\n%@: <%p>.init;\n", NSStringFromClass(self.class), self);
    }
    return self;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    MCSHTTPResponse *response = [MCSHTTPResponse.alloc initWithConnection:self];
    
    MCSLog(@"%@: <%p>.response { URL: %@, method: %@, range: %@ };\n", NSStringFromClass(self.class), self, method, response.request.URL, NSStringFromRange(response.request.mcs_range));
    
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
    
    MCSLog(@"%@: <%p>.finishResponse;\n", NSStringFromClass(self.class), self);
}

- (void)die {
    [super die];
    MCSLog(@"%@: <%p>.die;\n", NSStringFromClass(self.class), self);
}

- (void)dealloc {
    MCSLog(@"%@: <%p>.dealloc;\n\n", NSStringFromClass(self.class), self);
}

- (void)responseDidAbort:(NSObject<HTTPResponse> *)sender {
    [super responseDidAbort:sender];
    MCSLog(@"%@: <%p>.abort;\n", NSStringFromClass(self.class), self);
}
@end

@implementation NSURLRequest (MCSHTTPConnectionExtended)
+ (NSMutableURLRequest *)mcs_requestWithMessage:(HTTPMessage *)message {
    NSURL *URL = [MCSURLRecognizer.shared URLWithProxyURL:message.url];
    return [self mcs_requestWithURL:URL headers:message.allHeaderFields];
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

- (UInt64)contentLength {
    return (UInt64)_task.contentLength;
}

- (UInt64)offset {
    return (UInt64)_task.offset;
}

- (void)setOffset:(UInt64)offset { }

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
    return _task.responseHeaders;
}

- (BOOL)delayResponseHeaders {
    return _task != nil ? !_task.isPrepared : YES;
}

- (void)taskPrepareDidFinish:(id<MCSSessionTask>)task {
    [_connection responseHasAvailableData:self];
}

- (void)taskHasAvailableData:(id<MCSSessionTask>)task {
    [_connection responseHasAvailableData:self];
}

- (void)task:(id<MCSSessionTask>)task anErrorOccurred:(NSError *)error {
    [_connection responseDidAbort:self];
}

- (BOOL)isChunked {
    return YES;
}
@end
