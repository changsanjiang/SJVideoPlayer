//
//  SJRouteRequest.m
//  Pods
//
//  Created by 畅三江 on 2018/9/14.
//

#import "SJRouteRequest.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJRouteRequest
- (instancetype)initWithPath:(NSString *)rq parameters:(nullable SJParameters)prts {
    NSParameterAssert(rq);
    self = [super init];
    if ( !self ) return nil;
    while ( [rq hasPrefix:@"/"] ) rq = [rq substringFromIndex:1];
    _requestPath = rq.copy?:@"";
    _prts = prts;
    return self;
}
@end

@implementation SJRouteRequest(CreateByURL)
- (instancetype)initWithURL:(NSURL *)URL {
    SJParameters parameters = nil;
    NSURLComponents *c = [[NSURLComponents alloc] initWithURL:URL resolvingAgainstBaseURL:YES];
    if ( 0 != c.queryItems.count ) {
        NSMutableDictionary *m = [NSMutableDictionary new];
        for ( NSURLQueryItem *item in c.queryItems ) {
            m[item.name] = item.value;
        }
        parameters = m.copy;
    }
    self = [self initWithPath:URL.path.stringByDeletingPathExtension parameters:parameters];
    if ( !self ) return nil;
    self.originalURL = URL;
    return self;
}
- (void)setOriginalURL:(NSURL * _Nullable)originalURL {
    objc_setAssociatedObject(self, @selector(originalURL), originalURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSURL *_Nullable)originalURL {
    return objc_getAssociatedObject(self, _cmd);
}
- (NSString *)description {
    return
    [NSString stringWithFormat:@"[%@<%p>] {\n \
     requestPath = %@; \n \
     parameters = %@; \n \
     originalURL = %@; \n \
     }", NSStringFromClass([self class]), self, _requestPath, _prts, self.originalURL];
}
@end
NS_ASSUME_NONNULL_END
