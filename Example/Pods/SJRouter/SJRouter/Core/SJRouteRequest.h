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
- (instancetype)initWithPath:(NSString *)requestPath parameters:(nullable SJParameters)parameters NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) NSString *requestPath;
@property (nonatomic, strong, readonly, nullable) SJParameters prts;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@end


@interface SJRouteRequest(CreateByURL)
- (instancetype)initWithURL:(NSURL *)URL;

@property (nonatomic, strong, readonly, nullable) NSURL *originalURL;
@end
NS_ASSUME_NONNULL_END
