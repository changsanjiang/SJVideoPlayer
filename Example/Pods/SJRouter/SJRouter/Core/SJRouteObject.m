//
//  SJRouteObject.m
//  Pods
//
//  Created by BlueDancer on 2019/12/25.
//

#import "SJRouteObject.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJRouteObject ()
@property (nonatomic, copy, readonly) SJCreateInstanceBlock createInstanceBlock;
@property (nonatomic, copy, readonly) NSArray<NSString *> *paths;
@end

@implementation SJRouteObject

///
/// 指定路径, 创建对应的路由处理者
///
/// @param path                     可处理的路径
///
/// @param mode                     决定转场时是调用`pushViewController:`还是`presentViewController:`方法
///
/// @param createInstanceBlock      创建相应的实例对象的block
///
- (nullable instancetype)initWithPath:(NSString *)path transitionMode:(SJViewControllerTransitionMode)mode createInstanceBlock:(nonnull SJCreateInstanceBlock)createInstanceBlock {
    if ( path == nil ) return nil;
    return [self initWithPaths:@[path] transitionMode:mode createInstanceBlock:createInstanceBlock transitionAnimated:YES];
}

///
/// 指定路径, 创建对应的路由处理者
///
/// @param paths                    可处理的路径
///
/// @param mode                     决定转场时是调用`pushViewController:`还是`presentViewController:`方法
///
/// @param createInstanceBlock      创建相应的实例对象的block
///
/// @param animated                 转场时, 是否动画
///
- (nullable instancetype)initWithPaths:(NSArray<NSString *> *)paths transitionMode:(SJViewControllerTransitionMode)mode createInstanceBlock:(SJCreateInstanceBlock)createInstanceBlock transitionAnimated:(BOOL)animated {
    if ( paths.count == 0 ) return nil;
    self = [super init];
    if ( self ) {
        _paths = paths.copy;
        _mode = mode;
        _createInstanceBlock = createInstanceBlock;
        _animated = animated;
    }
    return self;
}

#pragma mark -

- (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(nullable SJCompletionHandler)completionHandler {
    if ( self.createInstanceBlock != nil ) {
        self.createInstanceBlock(request, ^(id  _Nullable result, NSError * _Nullable error) {
            if ( error != nil ) {
                if ( completionHandler ) completionHandler(nil, error);
                return ;
            }
            
            switch ( self.mode ) {
                case SJViewControllerTransitionModeNavigation: {
                    [topViewController.navigationController pushViewController:result animated:self.animated];
                    if ( completionHandler ) completionHandler(result, nil);
                }
                    break;
                case SJViewControllerTransitionModeModal: {
                    [topViewController presentViewController:result animated:self.animated completion:nil];
                    if ( completionHandler ) completionHandler(result, nil);
                }
                    break;
            }
        });
    }
}

- (void)instanceWithRequest:(SJRouteRequest *)request completionHandler:(nullable SJCompletionHandler)completionHandler {
    if ( _createInstanceBlock != nil ) _createInstanceBlock(request, completionHandler);
}
@end
NS_ASSUME_NONNULL_END
