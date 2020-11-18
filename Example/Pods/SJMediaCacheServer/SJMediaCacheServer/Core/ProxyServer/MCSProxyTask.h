//
//  MCSProxyTask.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSInterfaces.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSProxyTask : NSObject<MCSProxyTask>
- (instancetype)initWithRequest:(NSURLRequest *)request delegate:(id<MCSProxyTaskDelegate>)delegate;

- (void)prepare;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic, readonly) BOOL isDone;
- (void)close;

@end

NS_ASSUME_NONNULL_END
