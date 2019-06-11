//
//  SJRouteHandler.h
//  Pods
//
//  Created by 畅三江 on 2018/9/14.
//

#ifndef SJRouteHandler_h
#define SJRouteHandler_h
#import "SJRouteRequest.h"
@protocol SJRouteHandlerDeprecatedMethods;
@class UIViewController;

NS_ASSUME_NONNULL_BEGIN
typedef void(^SJCompletionHandler)(id _Nullable result, NSError *_Nullable error);

@protocol SJRouteHandler
@required
+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(nullable SJCompletionHandler)completionHandler;

@optional
+ (NSString *)routePath;                 // 单路径 可以用这个方法返回
+ (NSArray<NSString *> *)multiRoutePath; // 多路径 可以从这个方法返回

@end
NS_ASSUME_NONNULL_END






NS_ASSUME_NONNULL_BEGIN
/// 已过期的方法, 请勿使用
DEPRECATED_ATTRIBUTE
@protocol SJRouteHandlerDeprecatedMethods
+ (void)handleRequestWithParameters:(nullable SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(nullable  SJCompletionHandler)completionHandler __deprecated_msg("use handleRequest:topViewController:completionHandler:");
@end
NS_ASSUME_NONNULL_END

#endif /* SJRouteHandler_h */
