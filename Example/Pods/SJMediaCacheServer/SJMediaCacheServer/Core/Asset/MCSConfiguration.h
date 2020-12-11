//
//  MCSConfiguration.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/7/6.
//

#import "MCSInterfaces.h"

NS_ASSUME_NONNULL_BEGIN
@interface MCSConfiguration : NSObject<MCSConfiguration>

- (void)setValue:(nullable NSString *)value forHTTPAdditionalHeaderField:(NSString *)field ofType:(MCSDataType)type;
- (nullable NSDictionary<NSString *, NSString *> *)HTTPAdditionalHeadersForDataRequestsOfType:(MCSDataType)type;

@end
NS_ASSUME_NONNULL_END
