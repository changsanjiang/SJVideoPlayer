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
- (instancetype)initWithPort:(UInt16)port;
@property (nonatomic, weak, nullable) id<MCSProxyServerDelegate> delegate;

@property (nonatomic, readonly) UInt16 port;
@property (nonatomic, readonly, getter=isRunning) BOOL running;
@property (nonatomic, strong, readonly) NSURL *serverURL;

- (void)start;
- (void)stop;
@end

@protocol MCSProxyServerDelegate <NSObject>
- (id<MCSProxyTask>)server:(MCSProxyServer *)server taskWithRequest:(NSURLRequest *)request delegate:(id<MCSProxyTaskDelegate>)delegate;
@end
NS_ASSUME_NONNULL_END
