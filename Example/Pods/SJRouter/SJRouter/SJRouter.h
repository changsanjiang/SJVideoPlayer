//
//  SJRouter.h
//  Pods
//
//  Created by 畅三江 on 2018/9/14.
//
//  https://github.com/changsanjiang/SJRouter
//
//  QQ群: 930508201
//
//  Email: changsanjiang@gmail.com
//

#import <Foundation/Foundation.h>
#import "SJRouteHandler.h"
#import "SJRouteObject.h"
#import "SJRouteInterceptor.h"
@class UIViewController;

NS_ASSUME_NONNULL_BEGIN
@interface SJRouter : NSObject
+ (instancetype)shared;

/// `-instanceWithRequest:completionHandler:`无对应handler时, 将会回调该block
@property (nonatomic, copy, nullable) SJRouterUnableToGetAnInstanceCallback unableToGetAnInstanceCallback;
- (void)instanceWithRequest:(SJRouteRequest *)request completionHandler:(nullable SJCompletionHandler)completionHandler;

/// `-handleRequest:completionHandler:`无对应handler时, 将会回调该block
@property (nonatomic, copy, nullable) SJRouterUnhandledCallback unhandledCallback;
- (void)handleRequest:(SJRouteRequest *)request completionHandler:(nullable SJCompletionHandler)completionHandler;

- (BOOL)canHandleRoutePath:(NSString *)routePath; 

- (void)addRoute:(SJRouteObject *)object;
@end


@interface SJRouter (SJRouteInterceptorExtended)

- (void)addInterceptor:(SJRouteInterceptor *)interceptor;

@end
NS_ASSUME_NONNULL_END
