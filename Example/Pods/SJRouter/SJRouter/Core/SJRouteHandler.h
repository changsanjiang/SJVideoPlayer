//
//  SJRouteHandler.h
//  Pods
//
//  Created by 畅三江 on 2018/9/14.
//

#ifndef SJRouteHandler_h
#define SJRouteHandler_h
#import "SJRouteRequest.h"
@class UIViewController, SJRouter;

NS_ASSUME_NONNULL_BEGIN
typedef void(^SJCompletionHandler)(id _Nullable result, NSError *_Nullable error);
typedef void(^SJRouterUnhandledCallback)(SJRouteRequest *request, UIViewController *topViewController, SJCompletionHandler _Nullable completionHandler);
typedef void(^SJRouterUnableToGetAnInstanceCallback)(SJRouteRequest *request, SJCompletionHandler _Nullable completionHandler);

@protocol SJRouteHandler
@optional
///
/// 添加路由
///     第一步 遵守协议: <SJRouteHandler>
///     第二步 实现协议方法:`addRoutesToRouter:`, SJRouter 将在初始化期间调用它
///
///\code
///    // 示例:
///    @interface MyModule()<SJRouteHandler>          // 1.
///    @end
///
///    @implementation MyModule
///    + (void)addRoutesToRouter:(SJRouter *)router { // 2.
///        [router addRoute:[SJRouteObject.alloc initWithPath:@"video/playback" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
///            NSLog(@"%@", request.prts);
///            MyViewController *vc = [[MyViewController alloc] init];
///            if ( completionHandler != nil ) completionHandler(vc, nil);
///        }]];
///
///
///        [router addRoute:[SJRouteObject.alloc initWithPath:@"video/list" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
///            MyViewController2 *vc = [[MyViewController2 alloc] init];
///            if ( completionHandler != nil ) completionHandler(vc, nil);
///        }]];
///
///         /// 添加拦截器
///         ///
///         ///     拦截向"video/list"的请求. 决定是否可以处理路由
///         ///
///         ///     什么场景下适合添加拦截器?
///         ///         比如跳转B界面需要用户登录, 否则需要跳转至登录界面. 因此从任何地方跳转B界面, 都需要能够及时拦截到, 增加对用户登录态的判断来决定是否允许跳转B界面
///         ///
///        [router addInterceptor:[SJRouteInterceptor interceptorWithPath:@"video/list" handler:^(SJRouteRequest * _Nonnull request, SJRouterInterceptionPolicyDecisionHandler  _Nonnull decisionHandler) {
///           // - 对登录态的判断
///           if ( !User.isLogin ) {
///                 // 取消此次路由
///                 decisionHandler(SJRouterInterceptionPolicyCancel);
///                 // 跳转登录页面
///                 SJRouteRequest *newRequest = [SJRouteRequest.alloc initWithPath:@"user/login" parameters:nil];
///                 [SJRouter.shared handleRequest:newRequest completionHandler:nil];
///                return;
///           }
///
///           // - 也可以添加一些自己需要的参数
///           [request setValue:@"sjsjsjs" forParameterKey:@"keykeykey"];
///
///           // - 允许此次路由
///           decisionHandler(SJRouterInterceptionPolicyAllow);
///        }]];
///    }
///    @end
///\endcode
///
+ (void)addRoutesToRouter:(SJRouter *)router;

#pragma mark - 以下为第二种添加路由的方式

+ (NSArray<NSString *> *)multiRoutePath; // 多路径 可以从这个方法返回
+ (NSString *)routePath;                 // 单路径 可以用这个方法返回

///
/// 处理某个请求
///
///     当调用SJRouter的`-handleRequest:completionHandler:`时, SJRouter将通过对应的`handler`调用到此方法
///
+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(nullable SJCompletionHandler)completionHandler;

///
/// 获取某个实例
///
///     当调用SJRouter的`-instanceWithRequest:completionHandler:`时, SJRouter将通过对应的`handler`调用到此方法
///
+ (void)instanceWithRequest:(SJRouteRequest *)request completionHandler:(nullable SJCompletionHandler)completionHandler;
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
