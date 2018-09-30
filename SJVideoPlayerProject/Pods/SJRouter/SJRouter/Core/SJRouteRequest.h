//
//  SJRouteRequest.h
//  Pods
//
//  Created by 畅三江 on 2018/9/14.
//

#import <Foundation/Foundation.h>
#import "SJRouteHandler.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJRouteRequest : NSObject
- (instancetype)initWithURL:(NSURL *)URL;
- (instancetype)initWithPath:(NSString *)requestPath parameters:(nullable SJParameters)parameters;
@property (nonatomic, strong, readonly) NSString *requestPath;
@property (nonatomic, strong, readonly, nullable) SJParameters prts;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;

@property (nonatomic, strong, readonly, nullable) NSURL *originalURL;
@end
NS_ASSUME_NONNULL_END
