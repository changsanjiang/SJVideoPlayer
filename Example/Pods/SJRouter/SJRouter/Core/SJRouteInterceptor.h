//
//  SJRouteInterceptor.h
//  Pods
//
//  Created by 畅三江 on 2020/4/11.
//

#import <Foundation/Foundation.h>
#import "SJRouteHandler.h"

typedef enum : NSUInteger {
    SJRouterInterceptionPolicyCancel,
    SJRouterInterceptionPolicyAllow,
} SJRouterInterceptionPolicy;

NS_ASSUME_NONNULL_BEGIN
typedef void(^SJRouterInterceptionPolicyDecisionHandler)(SJRouterInterceptionPolicy policy);
typedef void(^SJRouteInterceptHandler)(SJRouteRequest *request, SJRouterInterceptionPolicyDecisionHandler decisionHandler);


@interface SJRouteInterceptor : NSObject
+ (instancetype)interceptorWithPaths:(NSArray<NSString *> *)paths handler:(SJRouteInterceptHandler)handler;
- (instancetype)initWithPaths:(NSArray<NSString *> *)paths handler:(SJRouteInterceptHandler)handler;

+ (instancetype)interceptorWithPath:(NSString *)path handler:(SJRouteInterceptHandler)handler;
- (instancetype)initWithPath:(NSString *)path handler:(SJRouteInterceptHandler)handler;

@property (nonatomic, copy, nullable) NSArray<NSString *> *paths;
@property (nonatomic, copy, nullable) SJRouteInterceptHandler handler;

@end
NS_ASSUME_NONNULL_END
