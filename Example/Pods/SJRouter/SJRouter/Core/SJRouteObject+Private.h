//
//  SJRouteObject+Private.h
//  Pods
//
//  Created by BlueDancer on 2019/12/25.
//

#import "SJRouteObject.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJRouteObject (Private)
@property (nonatomic, copy, readonly) NSArray<NSString *> *paths;
- (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(nullable SJCompletionHandler)completionHandler;
- (void)instanceWithRequest:(SJRouteRequest *)request completionHandler:(nullable SJCompletionHandler)completionHandler;
@end
NS_ASSUME_NONNULL_END
