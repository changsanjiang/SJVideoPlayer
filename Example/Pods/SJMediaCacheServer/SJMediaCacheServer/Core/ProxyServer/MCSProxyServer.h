//
//  MCSProxyServer.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/5/30.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSInterfaces.h"
@protocol MCSProxyServerDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface MCSProxyServer : NSObject
- (instancetype)init;
@property (nonatomic, weak, nullable) id<MCSProxyServerDelegate> delegate;

/// return 0 if the server is not running.
@property (nonatomic, readonly) UInt16 port;
@property (nonatomic, readonly, getter=isRunning) BOOL running;
@property (nonatomic, strong, readonly) NSURL *serverURL;

- (void)start;
- (void)stop;
@end

@protocol MCSProxyServerDelegate <NSObject>
- (id<MCSProxyTask>)server:(MCSProxyServer *)server taskWithRequest:(NSURLRequest *)request delegate:(id<MCSProxyTaskDelegate>)delegate;
- (void)server:(MCSProxyServer *)server performTask:(id<MCSProxyTask>)task failure:(NSError *)error;

@end
NS_ASSUME_NONNULL_END
