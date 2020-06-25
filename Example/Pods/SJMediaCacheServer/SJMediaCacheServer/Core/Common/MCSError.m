//
//  MCSError.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSError.h"

NSString * const MCSErrorDomain = @"lib.changsanjiang.SJMediaCacheServer.error";
NSString * const MCSErrorUserInfoURLKey = @"URL";
NSString * const MCSErrorUserInfoRequestKey = @"Request";
NSString * const MCSErrorUserInfoResponseKey = @"Response";

@implementation NSError(MCSExtended)
+ (NSError *)mcs_responseUnavailable:(NSURL *)URL request:(NSURLRequest *)request response:(NSURLResponse *)response {
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    userInfo[MCSErrorUserInfoURLKey] = URL;
    userInfo[MCSErrorUserInfoRequestKey] = request;
    userInfo[MCSErrorUserInfoResponseKey] = response;
    return [NSError errorWithDomain:MCSErrorDomain code:MCSResponseUnavailableError userInfo:userInfo];
}

+ (NSError *)mcs_nonsupportContentType:(NSURL *)URL request:(NSURLRequest *)request response:(NSURLResponse *)response {
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    userInfo[MCSErrorUserInfoURLKey] = URL;
    userInfo[MCSErrorUserInfoRequestKey] = request;
    userInfo[MCSErrorUserInfoResponseKey] = response;
    return [NSError errorWithDomain:MCSErrorDomain code:MCSNonsupportContentTypeError userInfo:userInfo];
}

+ (NSError *)mcs_exception:(NSException *)exception {
    return [NSError errorWithDomain:MCSErrorDomain code:MCSExceptionError userInfo:exception.userInfo];
}

+ (NSError *)mcs_removedResource:(NSURL *)URL {
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    userInfo[MCSErrorUserInfoURLKey] = URL;
    return [NSError errorWithDomain:MCSErrorDomain code:MCSResourceHasBeenRemovedError userInfo:userInfo];
}

+ (NSError *)mcs_HLSFileParseError:(NSURL *)URL {
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    userInfo[MCSErrorUserInfoURLKey] = URL;
    return [NSError errorWithDomain:MCSErrorDomain code:MCSHLSFileParseError userInfo:userInfo];
}

+ (NSError *)mcs_fileNotExistError:(NSURL *)URL {
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    userInfo[MCSErrorUserInfoURLKey] = URL;
    userInfo[NSLocalizedDescriptionKey] = @"The corresponding file does not exist";
    return [NSError errorWithDomain:MCSErrorDomain code:MCSFileNotExistError userInfo:userInfo];
}

+ (NSError *)mcs_userCancelledError:(NSURL *)URL {
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    userInfo[MCSErrorUserInfoURLKey] = URL;
    userInfo[NSLocalizedDescriptionKey] = @"The user canceled the request.";
    return [NSError errorWithDomain:MCSErrorDomain code:MCSUserCancelledError userInfo:userInfo];
}
@end
