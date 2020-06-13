//
//  MCSError.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSError.h"

NSString * const MCSErrorDomain = @"lib.changsanjiang.SJMediaServerCache.error";
NSString * const MCSErrorUserInfoURLKey = @"URL";
NSString * const MCSErrorUserInfoRequestKey = @"Request";
NSString * const MCSErrorUserInfoResponseKey = @"Response";

@implementation NSError(MCSExtended)
+ (NSError *)mcs_errorForResponseUnavailable:(NSURL *)URL request:(NSURLRequest *)request response:(NSURLResponse *)response {
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    userInfo[MCSErrorUserInfoURLKey] = URL;
    userInfo[MCSErrorUserInfoRequestKey] = request;
    userInfo[MCSErrorUserInfoResponseKey] = response;
    return [NSError errorWithDomain:MCSErrorDomain code:MCSResponseUnavailableError userInfo:userInfo];
}

+ (NSError *)mcs_errorForNonsupportContentType:(NSURL *)URL request:(NSURLRequest *)request response:(NSURLResponse *)response {
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    userInfo[MCSErrorUserInfoURLKey] = URL;
    userInfo[MCSErrorUserInfoRequestKey] = request;
    userInfo[MCSErrorUserInfoResponseKey] = response;
    return [NSError errorWithDomain:MCSErrorDomain code:MCSNonsupportContentTypeError userInfo:userInfo];
}

+ (NSError *)mcs_errorForException:(NSException *)exception {
    return [NSError errorWithDomain:MCSErrorDomain code:MCSExceptionError userInfo:exception.userInfo];
}

+ (NSError *)mcs_errorForRemovedResource:(NSURL *)URL {
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    userInfo[MCSErrorUserInfoURLKey] = URL;
    return [NSError errorWithDomain:MCSErrorDomain code:MCSResourceHasBeenRemovedError userInfo:userInfo];
}

+ (NSError *)mcs_errorForHLSFileParseError:(NSURL *)URL {
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    userInfo[MCSErrorUserInfoURLKey] = URL;
    return [NSError errorWithDomain:MCSErrorDomain code:MCSHLSFileParseError userInfo:userInfo];
}

+ (NSError *)mcs_errorForFileHandleError:(NSURL *)URL {
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    userInfo[MCSErrorUserInfoURLKey] = URL;
    return [NSError errorWithDomain:MCSErrorDomain code:MCSFileHandleError userInfo:userInfo];
}
@end
