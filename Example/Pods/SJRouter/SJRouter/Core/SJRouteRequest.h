//
//  SJRouteRequest.h
//  Pods
//
//  Created by 畅三江 on 2018/9/14.
//

#import <Foundation/Foundation.h>
typedef id SJParameters;

NS_ASSUME_NONNULL_BEGIN
@interface SJRouteRequest : NSObject
- (nullable instancetype)initWithPath:(NSString *)requestPath parameters:(nullable SJParameters)parameters;
@property (nonatomic, strong, readonly, nullable) NSString *requestPath;
@property (nonatomic, strong, readonly, nullable) SJParameters prts; // 请求的参数
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@end


@interface SJRouteRequest(CreateByURL)
- (nullable instancetype)initWithURL:(NSURL *)URL;
@property (nonatomic, strong, readonly, nullable) NSURL *originalURL;

/// 追加参数
- (void)setValue:(nullable id)value forParameterKey:(NSString *)key;
- (void)addParameters:(NSDictionary *)parameters;
@end
NS_ASSUME_NONNULL_END
