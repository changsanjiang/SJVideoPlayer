//
//  SJRouteInterceptor.m
//  Pods
//
//  Created by 畅三江 on 2020/4/11.
//

#import "SJRouteInterceptor.h"

@implementation SJRouteInterceptor
+ (instancetype)interceptorWithPaths:(NSArray<NSString *> *)paths handler:(SJRouteInterceptHandler)handler {
    return [SJRouteInterceptor.alloc initWithPaths:paths handler:handler];
}
- (instancetype)initWithPaths:(NSArray<NSString *> *)paths handler:(SJRouteInterceptHandler)handler {
    self = [super init];
    if ( self ) {
        _paths = paths;
        _handler = handler;
    }
    return self;
}

+ (instancetype)interceptorWithPath:(NSString *)path handler:(SJRouteInterceptHandler)handler {
    return [SJRouteInterceptor.alloc initWithPath:path handler:handler];
}
- (instancetype)initWithPath:(NSString *)path handler:(SJRouteInterceptHandler)handler {
    return [self initWithPaths:@[path ?: @""] handler:handler];
}
@end
