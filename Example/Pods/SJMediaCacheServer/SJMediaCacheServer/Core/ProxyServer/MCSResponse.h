//
//  MCSProxyTaskResponse.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/18.
//

#import "MCSInterfaces.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSResponse : NSObject<MCSResponse>

- (instancetype)initWithTotalLength:(NSUInteger)totalLength;
- (instancetype)initWithTotalLength:(NSUInteger)totalLength range:(NSRange)range;

@property (nonatomic, readonly) NSUInteger totalLength;
@property (nonatomic, readonly) NSRange range;
@end

NS_ASSUME_NONNULL_END
