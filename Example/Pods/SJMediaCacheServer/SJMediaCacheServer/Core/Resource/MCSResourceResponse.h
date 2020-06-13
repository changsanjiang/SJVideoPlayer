//
//  MCSResourceResponse.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/4.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSResourceResponse : NSObject<MCSResourceResponse>
- (instancetype)initWithResponse:(NSHTTPURLResponse *)response;
- (instancetype)initWithServer:(NSString *)server contentType:(NSString *)contentType totalLength:(NSUInteger)totalLength contentRange:(NSRange)contentRange;
- (instancetype)initWithServer:(NSString *)server contentType:(NSString *)contentType totalLength:(NSUInteger)totalLength;

@property (nonatomic, copy, readonly, nullable) NSDictionary *responseHeaders;
@property (nonatomic, copy, readonly, nullable) NSString *contentType;
@property (nonatomic, copy, readonly, nullable) NSString *server;
@property (nonatomic, readonly) NSUInteger totalLength;
@property (nonatomic, readonly) NSRange contentRange;
@end

NS_ASSUME_NONNULL_END
