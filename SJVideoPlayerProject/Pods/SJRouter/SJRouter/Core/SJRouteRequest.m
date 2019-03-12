//
//  SJRouteRequest.m
//  Pods
//
//  Created by 畅三江 on 2018/9/14.
//

#import "SJRouteRequest.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJRouteRequest ()
@property (nonatomic, strong, readonly, nullable) NSURL *originalURL;
@end

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

- (NSString *)description {
    return
    [NSString stringWithFormat:@"[%@<%p>] {\n \
     requestPath = %@; \n \
     parameters = %@; \n \
     originalURL = %@; \n \
     }", NSStringFromClass([self class]), self, _requestPath, _prts, _originalURL];
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
    _originalURL = URL;
    return self;
}
@end
NS_ASSUME_NONNULL_END
