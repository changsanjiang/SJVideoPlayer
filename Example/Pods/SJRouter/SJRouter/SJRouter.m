//
//  SJRouter.m
//  Pods
//
//  Created by 畅三江 on 2018/9/14.
//

#import "SJRouter.h"
#import <objc/message.h>

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

static SEL sel_handler_v1;
static SEL sel_handler_v2;

@interface SJRouter()
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, Class> *handlersM;
@end

@implementation SJRouter {
    dispatch_group_t _group;
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
    sel_handler_v1 = @selector(handleRequestWithParameters:topViewController:completionHandler:);
    sel_handler_v2 = @selector(handleRequest:topViewController:completionHandler:);
    
    _handlersM = [NSMutableDictionary new];
    _group = dispatch_group_create();
    dispatch_group_async(_group, dispatch_get_global_queue(0, 0), ^{
        /// Thanks @yehot, @Potato121
        /// https://www.jianshu.com/p/534eccb63974
        /// https://github.com/changsanjiang/SJRouter/pull/1
        unsigned int img_count = 0;
        const char **imgs = objc_copyImageNames(&img_count);
        const char *main = NSBundle.mainBundle.bundlePath.UTF8String;
        SEL sel_path = @selector(routePath);
        SEL sel_multiPath = @selector(multiRoutePath);
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
                        self->_handlersM[routePath] = cls;
                    }
                }
                else if ( class_respondsToSelector(metaClass, sel_multiPath) ) {
                    IMP func = class_getMethodImplementation(metaClass, sel_multiPath);
                    for ( NSString *routePath in ((NSArray<NSString *> *(*)(id, SEL))func)(cls, sel_multiPath) ) {
                        if ( routePath.length > 0 ) {
                            self->_handlersM[routePath] = cls;
                        }
                    }
                }
            }
            if ( names ) free(names);
        }
        if ( imgs ) free(imgs);
    });
    
    return self;
}
- (void)handleRequest:(SJRouteRequest *)request completionHandler:(nullable SJCompletionHandler)completionHandler {
    NSParameterAssert(request); if ( !request ) return;
    dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
        Class<SJRouteHandler, SJRouteHandlerDeprecatedMethods> _Nullable handler = self->_handlersM[request.requestPath];
        if ( [(id)handler respondsToSelector:sel_handler_v1] ) {
            [handler handleRequestWithParameters:request.prts topViewController:_sj_get_top_view_controller() completionHandler:completionHandler];
        }
        else if ( [(id)handler respondsToSelector:sel_handler_v2] ) {
            [handler handleRequest:request topViewController:_sj_get_top_view_controller() completionHandler:completionHandler];
        }
        else {
#ifdef DEBUG
            printf("\n (-_-) Unhandled request: %s", request.description.UTF8String);
#endif
            if ( self->_unhandledCallback ) self->_unhandledCallback(request, _sj_get_top_view_controller());
        }
    });
}
- (BOOL)canHandleRoutePath:(NSString *)routePath {
    if ( 0 == routePath.length ) return NO;
    return _handlersM[routePath] != nil;
}
@end
NS_ASSUME_NONNULL_END
