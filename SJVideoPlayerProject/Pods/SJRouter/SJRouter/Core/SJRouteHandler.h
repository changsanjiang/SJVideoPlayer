//
//  SJRouteHandler.h
//  Pods
//
//  Created by 畅三江 on 2018/9/14.
//

#ifndef SJRouteHandler_h
#define SJRouteHandler_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef id SJParameters;

typedef void(^SJCompletionHandler)(id _Nullable result, NSError *_Nullable error);

@protocol SJRouteHandler
+ (NSString *)routePath;

+ (void)handleRequestWithParameters:(nullable SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(nullable SJCompletionHandler)completionHandler;
@end
NS_ASSUME_NONNULL_END

#endif /* SJRouteHandler_h */
