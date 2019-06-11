//
//  SJRouter.h
//  Pods
//
//  Created by 畅三江 on 2018/9/14.
//
//  https://github.com/changsanjiang/SJRouter
//
//  QQ群: 719616775
//
//  Email: changsanjiang@gmail.com
//

#import <Foundation/Foundation.h>
#import "SJRouteHandler.h"
@class UIViewController;

NS_ASSUME_NONNULL_BEGIN
typedef void(^SJRouterUnhandledCallback)(SJRouteRequest *request, UIViewController *topViewController); // 无法处理时的回调

@interface SJRouter : NSObject
+ (instancetype)shared;

- (void)handleRequest:(SJRouteRequest *)request completionHandler:(nullable SJCompletionHandler)completionHandler;

@property (nonatomic, copy, nullable) SJRouterUnhandledCallback unhandledCallback;
- (BOOL)canHandleRoutePath:(NSString *)routePath; // 是否可以处理某个路径
@end
NS_ASSUME_NONNULL_END
