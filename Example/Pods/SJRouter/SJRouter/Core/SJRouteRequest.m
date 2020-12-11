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
- (nullable instancetype)initWithPath:(NSString *)rq parameters:(nullable SJParameters)prts {
#ifdef DEBUG
    NSParameterAssert(rq);
#endif
    if ( rq == nil ) return nil;
    return [self _initWithPath:rq parameters:prts];
}

- (instancetype)_initWithPath:(nullable NSString *)rq parameters:(nullable SJParameters)prts {
    self = [super init];
    if ( self ) {
        while ( [rq hasPrefix:@"/"] ) rq = [rq substringFromIndex:1];
        _requestPath = rq.copy;
        _prts = prts;
    }
    return self;
}

- (nullable instancetype)initWithURL:(NSURL *)URL {
#ifdef DEBUG
    NSParameterAssert(URL);
#endif
    if ( URL == nil ) return nil;
    SJParameters parameters = nil;
    NSURLComponents *c = [[NSURLComponents alloc] initWithURL:URL resolvingAgainstBaseURL:YES];
    if ( 0 != c.queryItems.count ) {
        NSMutableDictionary *m = [NSMutableDictionary new];
        for ( NSURLQueryItem *item in c.queryItems ) {
            m[item.name] = item.value;
        }
        parameters = m.copy;
    }
    self = [self _initWithPath:URL.path.stringByDeletingPathExtension parameters:parameters];
    if ( self ) {
        _originalURL = URL;
    }
    return self;
}

- (void)setValue:(nullable id)value forParameterKey:(NSString *)key {
    if ( key.length != 0 ) {
        NSMutableDictionary *dictm = _prts ? [_prts mutableCopy] : NSMutableDictionary.new;
        dictm[key] = value;
        _prts = dictm.copy;
        
        if ( _originalURL != nil ) {
            NSURLComponents *components = [[NSURLComponents alloc] initWithURL:_originalURL resolvingAgainstBaseURL:YES];
            NSMutableArray<NSURLQueryItem *> *arrm = components.queryItems ? [components.queryItems mutableCopy] : NSMutableArray.new;
            __block NSInteger index = NSNotFound;
            [arrm enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSURLQueryItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                if ( [item.name isEqualToString:key] ) {
                    index = idx;
                    *stop = YES;
                }
            }];
            
            if ( index == NSNotFound ) index = arrm.count;
            
            if ( value == nil ) {
                if ( index < arrm.count ) [arrm removeObjectAtIndex:index];
            }
            else {
                NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:[NSString stringWithFormat:@"%@", value]];
                [arrm insertObject:item atIndex:index];
            }
            components.queryItems = [arrm copy];
            _originalURL = components.URL;
        }
    }
}

- (void)addParameters:(NSDictionary *)parameters {
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self setValue:obj forParameterKey:key];
    }];
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
NS_ASSUME_NONNULL_END
