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
+ (instancetype)mcs_requestWithURL:(NSURL *)URL headers:(nullable NSDictionary *)headers {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    return request;
}

+ (instancetype)mcs_requestWithURL:(NSURL *)URL range:(NSRange)range {
    return [self mcs_requestWithURL:URL headers:nil range:range];
}

+ (NSMutableURLRequest *)mcs_requestWithURL:(NSURL *)URL headers:(nullable NSDictionary *)headers range:(NSRange)range {
    NSMutableURLRequest *request = [self mcs_requestWithURL:URL headers:headers];
    [request setValue:[NSString stringWithFormat:@"bytes=%lu-%lu", (unsigned long)range.location, (unsigned long)NSMaxRange(range) - 1] forHTTPHeaderField:@"Range"];
    return request;
}

- (NSRange)mcs_range {
    return MCSGetRequestNSRange(MCSGetRequestContentRange(self.mcs_headers));
}

- (NSDictionary *)mcs_headers {
    return self.allHTTPHeaderFields;
}

- (NSString *)mcs_description {
    return [NSString stringWithFormat:@"%@:<%p> { URL: %@, headers: %@\n };", NSStringFromClass(self.class), self, self.URL, self.allHTTPHeaderFields];
}

- (NSMutableURLRequest *)mcs_requestWithRange:(NSRange)range {
    NSMutableURLRequest *request = [self mutableCopy];
    [request setValue:[NSString stringWithFormat:@"bytes=%lu-%lu", (unsigned long)range.location, (unsigned long)NSMaxRange(range) - 1] forHTTPHeaderField:@"Range"];
    return request;
}
@end
