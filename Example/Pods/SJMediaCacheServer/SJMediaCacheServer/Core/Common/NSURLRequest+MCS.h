//
//  NSURLRequest+MCS.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (MCS)
+ (NSMutableURLRequest *)mcs_requestWithURL:(NSURL *)URL headers:(nullable NSDictionary *)headers;

+ (NSMutableURLRequest *)mcs_requestWithURL:(NSURL *)URL range:(NSRange)range;

- (NSDictionary *)mcs_headers;
- (NSRange)mcs_range;
- (NSString *)mcs_description;
@end

NS_ASSUME_NONNULL_END
