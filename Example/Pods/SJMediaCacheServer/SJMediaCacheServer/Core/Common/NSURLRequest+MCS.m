//
//  NSURLRequest+MCS.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "NSURLRequest+MCS.h"
#import "MCSUtils.h"

@implementation NSURLRequest (MCS)
+ (instancetype)mcs_requestWithURL:(NSURL *)URL headers:(nullable NSDictionary<NSString *, NSString *> *)headers {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    static NSArray<NSString *> *availableHeaderKeys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        availableHeaderKeys = @[
            @"User-Agent", @"user-agent",
            @"Connection", @"connection",
            @"Accept", @"accept",
            @"Accept-Encoding", @"accept-encoding",
            @"Accept-Language", @"accept-language",
            @"Range", @"range"
        ];
    });
    
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ( [availableHeaderKeys containsObject:key] ) {
            [request setValue:obj forHTTPHeaderField:key];
        }
    }];
    return request;
}

+ (instancetype)mcs_requestWithURL:(NSURL *)URL range:(NSRange)range {
    return [self mcs_requestWithURL:URL headers:nil range:range];
}

+ (NSMutableURLRequest *)mcs_requestWithURL:(NSURL *)URL headers:(nullable NSDictionary *)headers range:(NSRange)range {
    NSMutableURLRequest *request = [self mcs_requestWithURL:URL headers:headers];
    return [request mcs_requestWithRange:range];
}

- (NSRange)mcs_range {
    return MCSRequestRange(MCSRequestGetContentRange(self.mcs_headers));
}

- (NSDictionary *)mcs_headers {
    return self.allHTTPHeaderFields;
}

- (NSString *)mcs_description {
    return [NSString stringWithFormat:@"%@:<%p> { URL: %@, headers: %@\n };", NSStringFromClass(self.class), self, self.URL, self.allHTTPHeaderFields];
}

- (NSMutableURLRequest *)mcs_requestWithRange:(NSRange)range {
    NSMutableURLRequest *request = [self mutableCopy];
    if ( NSMaxRange(range) == NSNotFound ) {
        if ( range.location != NSNotFound )
            [request setValue:[NSString stringWithFormat:@"bytes=%lu-", (unsigned long)range.location] forHTTPHeaderField:@"Range"];
        else
            [request setValue:[NSString stringWithFormat:@"bytes=-%lu", (unsigned long)range.length] forHTTPHeaderField:@"Range"];
    }
    else {
        [request setValue:[NSString stringWithFormat:@"bytes=%lu-%lu", (unsigned long)range.location, (unsigned long)NSMaxRange(range) - 1] forHTTPHeaderField:@"Range"];
    }
    return request;
}

- (NSMutableURLRequest *)mcs_requestWithRedirectURL:(NSURL *)URL range:(NSRange)range {
    return [NSMutableURLRequest mcs_requestWithURL:URL headers:self.allHTTPHeaderFields range:range];
}

- (NSMutableURLRequest *)mcs_requestWithRedirectURL:(NSURL *)URL {
    return [NSMutableURLRequest mcs_requestWithURL:URL headers:self.allHTTPHeaderFields];
}

- (NSMutableURLRequest *)mcs_requestWithHTTPAdditionalHeaders:(nullable NSDictionary<NSString *,NSString *> *)HTTPAdditionalHeaders {
    NSMutableURLRequest *request = nil;
    if ( [self isKindOfClass:NSMutableURLRequest.class] ) {
        request = (NSMutableURLRequest *)self;
    }
    else {
        request = [self mutableCopy];
    }
    
    if ( HTTPAdditionalHeaders != nil ) {
        NSDictionary *current = request.allHTTPHeaderFields;
        [HTTPAdditionalHeaders enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            if ( current[key] == nil )
                [request setValue:obj forHTTPHeaderField:key];
        }];
    }
    return request;
}
@end
