//
//  SJRouter.m
//  Pods
//
//  Created by 畅三江 on 2018/9/14.
//

#import "SJRouter.h"
#import <objc/message.h>
#import "SJRouteObject+Private.h"

NS_ASSUME_NONNULL_BEGIN
static UIViewController *_sj_get_top_view_controller() {
    UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (  [vc isKindOfClass:[UINavigationController class]] ||
             [vc isKindOfClass:[UITabBarController class]] ||
              vc.presentedViewController ) {
        if ( [vc isKindOfClass:[UINavigationController class]] )
            vc = [(UINavigationController *)vc topViewController];
        if ( [vc isKindOfClass:[UITabBarController class]] )
            vc = [(UITabBarController *)vc selectedViewController];
        if ( vc.presentedViewController )
            vc = vc.presentedViewController;
    }
    return vc;
}

@interface SJRouter()
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<SJRouteHandler>> *handlersM;
@property (nonatomic, strong, readonly) dispatch_semaphore_t lock;
@end

@implementation SJRouter
static SEL sel_handler_v1 __deprecated_msg("use `sel_handler_v2`");
static SEL sel_handler_v2;
static SEL sel_instance;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        sel_handler_v1 = @selector(handleRequestWithParameters:topViewController:completionHandler:);
#pragma clang diagnostic pop
        sel_handler_v2 = @selector(handleRequest:topViewController:completionHandler:);
        sel_instance = @selector(instanceWithRequest:completionHandler:);
    });
}

+ (instancetype)shared {
    static id _instace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    return _instace;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _lock = dispatch_semaphore_create(0);
    _handlersM = [NSMutableDictionary new];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        /// Thanks @yehot, @Potato121
        /// https://www.jianshu.com/p/534eccb63974
        /// https://github.com/changsanjiang/SJRouter/pull/1
        unsigned int img_count = 0;
        const char **imgs = objc_copyImageNames(&img_count);
        const char *main = NSBundle.mainBundle.bundlePath.UTF8String;
        SEL sel_path = @selector(routePath);
        SEL sel_multiPath = @selector(multiRoutePath);
        SEL sel_add_routes = @selector(addRoutesToRouter:);
        Protocol *protocol = @protocol(SJRouteHandler);
        for ( unsigned int i = 0 ; i < img_count ; ++ i ) {
            const char *image = imgs[i];
            if ( !strstr(image, main) ) continue;
            unsigned int cls_count = 0;
            const char **names = objc_copyClassNamesForImage(image, &cls_count);
            for ( unsigned int i = 0 ; i < cls_count ; ++ i ) {
                const char *cls_name = names[i];
                Class _Nullable cls = objc_getClass(cls_name);
                Class _Nullable supercls = cls;
                /// Thanks @Patrick-Q  2019/3/20 14:43:37
                while ( supercls && !class_conformsToProtocol(supercls, protocol) )
                    supercls = class_getSuperclass(supercls);
                if ( !supercls ) continue;

                Class metaClass = (Class)object_getClass(cls);
                if ( class_respondsToSelector(metaClass, sel_path) ) {
                    IMP func = class_getMethodImplementation(metaClass, sel_path);
                    NSString *routePath = ((NSString *(*)(id, SEL))func)(cls, sel_path);
                    if ( routePath.length > 0 ) {
                        self->_handlersM[routePath] = (id)cls;
                    }
                }
                else if ( class_respondsToSelector(metaClass, sel_multiPath) ) {
                    IMP func = class_getMethodImplementation(metaClass, sel_multiPath);
                    for ( NSString *routePath in ((NSArray<NSString *> *(*)(id, SEL))func)(cls, sel_multiPath) ) {
                        if ( routePath.length > 0 ) {
                            self->_handlersM[routePath] = (id)cls;
                        }
                    }
                }
                if ( class_respondsToSelector(metaClass, sel_add_routes) ) {
                    IMP func = class_getMethodImplementation(metaClass, sel_add_routes);
                    ((void(*)(id, SEL, SJRouter *))func)(cls, sel_add_routes, self);
                }
            }
            if ( names ) free(names);
        }
        if ( imgs ) free(imgs);
        dispatch_semaphore_signal(self->_lock);
    });
    return self;
}

///
/// 获取某个实例
///
///         对应的handler需实现方法: `instanceWithRequest:completionHandler`
///
///\code
///    @interface AModule()<SJRouteHandler>
///    @end
///
///    @implementation AModule
///    + (void)addRoutesToRouter:(SJRouter *)router {
///        [router addRoute:[SJRouteObject.alloc initWithPath:@"video/playback" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
///            MyViewController *vc = [[MyViewController alloc] initWithVideoId:[request.prts[@"id"] integerValue]];
///            //
///            // 以block的形式返回, 是为了适用异步时的场景
///            //    例如: 此处可以发起网络请求, 处理完毕后, 再进行相应跳转等等
///            //
///            if ( completionHandler != nil ) completionHandler(vc, nil);
///        }]];
///
///        [router addRoute:[SJRouteObject.alloc initWithPath:@"video/list" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
///            MyViewController2 *vc = [[MyViewController2 alloc] init];
///            if ( completionHandler != nil ) completionHandler(vc, nil);
///        }]];
///    }
///    @end
///
///    // 跳转播放页
///    SJRouteRequest *request = [SJRouteRequest.alloc initWithPath:@"video/list" parameters:nil];
///    [SJRouter.shared instanceWithRequest:request completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
///        if ( error != nil ) {
///            // handle error .....
///            return ;
///        }
///
///        // [self presentViewController:result animated:YES completion:nil];
///        [self.navigationController pushViewController:result animated:YES];
///    }];
///\endcode
///
- (void)instanceWithRequest:(SJRouteRequest *)request completionHandler:(nullable SJCompletionHandler)completionHandler {
    if ( request == nil ) return;
    id _Nullable handler = [self _handlerForRoutePath:request.requestPath];
    if ( [handler respondsToSelector:sel_instance] ) {
        [handler instanceWithRequest:request completionHandler:completionHandler];
    }
    else {
#ifdef DEBUG
        printf("\n(-_-) unable to get an instance: [%s]\n", request.description.UTF8String);
#endif
        if ( self->_unableToGetAnInstanceCallback ) self->_unableToGetAnInstanceCallback(request, completionHandler);
    }
}

///
/// 处理某个请求
///
///         对应的handler需实现方法: `handleRequest:topViewController:completionHandler:`
///
///\code
///    @interface AModule()<SJRouteHandler>
///    @end
///
///    @implementation AModule
///    + (void)addRoutesToRouter:(SJRouter *)router {
///        [router addRoute:[SJRouteObject.alloc initWithPath:@"video/playback" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
///            MyViewController *vc = [[MyViewController alloc] initWithVideoId:[request.prts[@"id"] integerValue]];
///            //
///            // 以block的形式返回, 是为了适用异步时的场景
///            //    例如: 此处可以发起网络请求, 处理完毕后, 再进行相应跳转等等
///            //
///            if ( completionHandler != nil ) completionHandler(vc, nil);
///        }]];
///
///
///        [router addRoute:[SJRouteObject.alloc initWithPath:@"video/list" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
///            MyViewController2 *vc = [[MyViewController2 alloc] init];
///            if ( completionHandler != nil ) completionHandler(vc, nil);
///        }]];
///    }
///    @end
///
///    // 跳转播放页
///    SJRouteRequest *request = [[SJRouteRequest alloc] initWithPath:@"video/playback" parameters:@{@"id":@"123"}];
///    [SJRouter.shared handleRequest:request completionHandler:nil];
///\endcode
///
- (void)handleRequest:(SJRouteRequest *)request completionHandler:(nullable SJCompletionHandler)completionHandler {
    if ( request == nil ) return;
    id _Nullable handler = [self _handlerForRoutePath:request.requestPath];
    if      ( [handler respondsToSelector:sel_handler_v2] ) {
        [handler handleRequest:request topViewController:_sj_get_top_view_controller() completionHandler:completionHandler];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    else if ( [handler respondsToSelector:sel_handler_v1] ) {
        [(id<SJRouteHandlerDeprecatedMethods>)handler handleRequestWithParameters:request.prts topViewController:_sj_get_top_view_controller() completionHandler:completionHandler];
    }
#pragma clang diagnostic pop
    else {
#ifdef DEBUG
        printf("\n(-_-) Unhandled request: [%s]\n", request.description.UTF8String);
#endif
        if ( self->_unhandledCallback ) self->_unhandledCallback(request, _sj_get_top_view_controller(), completionHandler);
    }
}

///
/// 是否可以处理某个路径
///
- (BOOL)canHandleRoutePath:(NSString *)routePath {
    return [self _handlerForRoutePath:routePath] != nil;
}

///
/// 手动添加路由
///
///     注意: 为保证线程安全应该总是在`+addRoutesToRouter:`中调用该方法
///
- (void)addRoute:(SJRouteObject *)object {
    if ( object != nil ) {
        for ( NSString *path in object.paths ) {
            _handlersM[path] = (id)object;
        }
    }
}

#pragma mark -
- (nullable id)_handlerForRoutePath:(NSString *)path {
    id handler = nil;
    if ( path.length != 0 ) {
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        handler = self->_handlersM[path];
        dispatch_semaphore_signal(_lock);
    }
    return handler;
}
@end
NS_ASSUME_NONNULL_END
